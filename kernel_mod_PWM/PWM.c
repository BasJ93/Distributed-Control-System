/****************************************************/
/*													*/
/*	Version 1.0		 								*/
/*	Author: Bas Janssen								*/
/*	Lectoraat Robotics and High Tech Mechatronics 	*/
/*	2016				 							*/
/*													*/
/****************************************************/

#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/kernel.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/types.h>
#include <linux/kfifo.h>
#include <linux/ioport.h>
#include <linux/slab.h>
#include <linux/of.h>
#include <linux/of_device.h>
#include <linux/of_address.h>
#include <linux/platform_device.h>
#include <linux/list.h>
#include <asm/io.h>
#include <asm/uaccess.h>

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("Bas Janssen");

#define CLASS_NAME "PWM"
#define DEVICE_NAME "PWM"

#define FPGA_SPACING 1

#define N_PWM_MINORS 32

static struct class* PWM_class = NULL;
static int PWM_major = 0;

static DECLARE_BITMAP(minors, N_PWM_MINORS);

static LIST_HEAD(device_list);
static DEFINE_MUTEX(device_list_lock);

//Make sure only one proccess can accessour the device
static DEFINE_MUTEX(PWM_device_mutex);

static int memory_request = 0;

//Custom struct to store the data we want in the driver
struct PWM_data {
	unsigned int * pulsewidth_address;
	int 		   message_read;
	unsigned int   base_register;
	struct list_head device_entry;
	dev_t		   devt;
	};


static int PWM_itoa(int value, char *buffer)
{
	char data[11];
	char temp_char;
	int i = 0;
	int j;
	int tmp;
	char int_array[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	//As we dont have access to itoa(), we write it our selves. Convert the int to an array of chars, and flip it while trimming leading 0's.
    tmp = value;
    for(i = 0; i<11; i++)
    {
		temp_char = tmp % 10;
        data[i] = '0' + temp_char;
        tmp   = tmp/10;
    }
	for(i = 0; i<11; i++)
	{
		if(data[9-i] != '0')
		{
			for(j = 0; j<(11-i); j++)
			{
				int_array[j] = data[9-i-j];
			}
			if(j<11)
			{
				int_array[j-1] = '\n';
				int_array[j] = '\0';
			}
			else
			{
				int_array[10] = '\n';
				int_array[11] = '\0';
			}
			break;
		}
	}
	strcpy(buffer, int_array);
	return 0;
}

/*------------------------------------------------------------------------------------------------------------------*/
/*Device node handler functions and definition struct																*/
/*@PWM_read the function to handle a read on the device node, returns the current position							*/
/*@PWM_write the function the handle a write to the device node, sets the setpoint									*/
/*@PWM_open handles the opening of the device node, gets the PWM_data struct from memory and sets the device lock	*/
/*@PWM_release handles the closing of the device node and removes the device lock									*/
/*@PWM_fops defines the handler functions for the operations														*/
/*------------------------------------------------------------------------------------------------------------------*/

static ssize_t PWM_read(struct file* filp, char __user *buffer, size_t lenght, loff_t* offset)
{
	struct PWM_data *PWM;
	ssize_t retval;
	ssize_t copied = 0;
	unsigned int fpga_value;
	char int_array[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

	//Grab the PWM_data struct out of the file struct.
	PWM = filp->private_data;

	//cat keeps requesting new data until it receives a "return 0", so we do a one shot.
	if(PWM->message_read)
		return 0;
	//Read from the I/O register
	fpga_value = ioread32(PWM->pulsewidth_address);
	
	PWM_itoa(fpga_value, int_array);	

	//Check how long the char array is after we build it.
	copied = sizeof(int_array);

	retval = copy_to_user(buffer, &int_array, copied);
	PWM->message_read = 1;
	if(retval)
		return retval;
	return retval ? retval : copied;
}

static ssize_t PWM_write(struct file* filp, const char __user *buffer, size_t lenght, loff_t* offset)
{
	struct PWM_data *PWM;
	ssize_t retval;
	unsigned int converted_value;
	ssize_t count = lenght;

	//Grab the PWM_data struct out of the file struct.
	PWM = filp->private_data;

	//Since the data we need is in userspace we need to copy it to kernel space so we can use it.
	retval = kstrtouint_from_user(buffer, count, 0, &converted_value);
	if(retval > 8192)
		retval = 8192;
	if(retval)
		return retval;
	//Write to the I/O register
	iowrite32(converted_value, PWM->pulsewidth_address);
	return retval ? retval : count;
}

static int PWM_open(struct inode* inode, struct file* filp)
{
	int status;
	struct PWM_data *PWM;
	mutex_lock(&device_list_lock);

	//Find the address of the struct using the device_list and the device_entry member of the PWM_data struct.
	list_for_each_entry(PWM, &device_list, device_entry) {
		//Check if the struct is the correct one.
		if(PWM->devt == inode->i_rdev) {
			//Store the struct in the private_data member of the file struct so that it is usable in the read and write functions of the device node.
			PWM->message_read = 0;
			filp->private_data = PWM;

			status = 0;
		}
	}

	//Try to lock the device, if it fails the device is already in use.
	if(!mutex_trylock(&PWM_device_mutex))
	{
		printk(KERN_WARNING "Device is in use by another process\n");
		return -EBUSY;
	}

	mutex_unlock(&device_list_lock);

	return 0;
}

static int PWM_release(struct inode* inode, struct file* filp)
{
	//Remove the mutex lock, so other processes can use the device.
	mutex_unlock(&PWM_device_mutex);
//	printk(KERN_INFO "Unlocking mutex\n");
	return 0;
}

struct file_operations PWM_fops = {
	.owner =	THIS_MODULE,
	.read =		PWM_read,
	.write = 	PWM_write,
	.open =		PWM_open,
	.release =	PWM_release,
};

/*------------------------------------------------------------------------------------------------------*/
/*Platform driver functions and struct																	*/
/*@PWM_dt_ids[] struct to store the compatible device tree names										*/
/*@PWM_probe called when a compatible device is found in the device tree. Creates device and maps iomem	*/
/*@PWM_remove called when the driver is removed from the kernel, removes the device and unmaps iomem	*/
/*@PWM_driver struct to define the platform driver, contains the compatible ID's and the function names */
/*------------------------------------------------------------------------------------------------------*/

static const struct of_device_id PWM_dt_ids[] = {
	{ .compatible = "fontys,PWM"},
	{},
};

MODULE_DEVICE_TABLE(of, PWM_dt_ids);

static int PWM_probe(struct platform_device *pltform_PWM)
{
	int minor;
	int status;
	struct resource res;
	int rc;

	struct PWM_data *PWM;

	PWM = kzalloc(sizeof(*PWM), GFP_KERNEL);
	if(!PWM)
		return -ENOMEM;
	
	INIT_LIST_HEAD(&PWM->device_entry);

	mutex_lock(&device_list_lock);
	minor = find_first_zero_bit(minors, N_PWM_MINORS);
	if (minor < N_PWM_MINORS)
	{
		struct device *dev;
		
		PWM->devt = MKDEV(PWM_major, minor);
		dev = device_create_with_groups(PWM_class, NULL, PWM->devt, NULL, NULL, CLASS_NAME "%d", minor);
		status = PTR_ERR_OR_ZERO(dev);
	}
	else
	{
		printk(KERN_DEBUG "No minor number available!\n");
		status = -ENODEV;
	}
	if( status == 0)
	{
		printk(KERN_INFO "New PWM controller PWM%d\n", minor);
		set_bit(minor, minors);
		list_add(&PWM->device_entry, &device_list);
		//Retreive the base address and request the memory region.
		rc = of_address_to_resource(pltform_PWM->dev.of_node, 0, &res);
		if( request_mem_region(res.start, resource_size(&res), CLASS_NAME) == NULL)
		{
			printk(KERN_WARNING "Unable to obtain physical I/O addresses\n");
			goto failed_memregion;
		}
		PWM->base_register = res.start;
		//Remap the memory region in to usable memory
		PWM->pulsewidth_address =  of_iomap(pltform_PWM->dev.of_node, 0);
	}
	mutex_unlock(&device_list_lock);
	
	if(status)
		kfree(PWM);
	else
		platform_set_drvdata(pltform_PWM, PWM);

	return status;

	failed_memregion:
		device_destroy(PWM_class, PWM->devt);
		clear_bit(MINOR(PWM->devt), minors);
	return -ENODEV;
}

static int PWM_remove(struct platform_device *pltform_PWM)
{
	struct PWM_data *PWM = platform_get_drvdata(pltform_PWM);
	struct resource res;
	int rc;

	rc = of_address_to_resource(pltform_PWM->dev.of_node, 0, &res);

	mutex_lock(&device_list_lock);
	//Unmap the iomem
	iounmap(PWM->pulsewidth_address);
	//Delete the device from the list
	list_del(&PWM->device_entry);
	//Destroy the device node
	device_destroy(PWM_class, PWM->devt);
	//Clear the minor bit
	clear_bit(MINOR(PWM->devt), minors);
	if(PWM->base_register)
	{
		release_mem_region(res.start, resource_size(&res));
		memory_request = 0;
	}
	//Free the kernel memory
	kfree(PWM);
	mutex_unlock(&device_list_lock);

	return 0;
}

static struct platform_driver PWM_driver = {
	.driver = {
		.name = "PWM",
		.owner = THIS_MODULE,
		.of_match_table = of_match_ptr(PWM_dt_ids),
	},
	.probe = PWM_probe,
	.remove = PWM_remove,
};

/*------------------------------------------------------------------------------------------------------*/
/*Module level functions																				*/
/*@PWM_init initialisation function for the driver														*/
/*@PWM_exit exit function for the driver																*/
/*------------------------------------------------------------------------------------------------------*/

static int PWM_init(void)
{
	int retval;
	//Request a major device number from the kernel
	PWM_major = register_chrdev(0, DEVICE_NAME, &PWM_fops);
	//If the number is smaller than 0, it's an error. So jump to the error state.
	if(PWM_major < 0)
	{
		printk(KERN_WARNING "hello: can't get major %d\n", PWM_major);
		retval = PWM_major;
		goto failed_chrdevreg;
	}
	//Now that we have a major number, create a device class.
	PWM_class = class_create(THIS_MODULE, CLASS_NAME);
	//If there is an error, jump to the error state.
	if( IS_ERR(PWM_class))
	{
		printk(KERN_NOTICE "Error while creating device class\n");
		retval =  PTR_ERR(PWM_class);
		goto failed_classreg;
	}
	//Now that we have a class, we can create our device node.
	retval = platform_driver_register(&PWM_driver);
	if(retval)
	{
		printk(KERN_NOTICE "Error while registering driver\n");
		goto failed_driverreg;
	}

	//Initialize the mutex lock.
	mutex_init(&PWM_device_mutex);

	return 0;

	failed_driverreg:
		class_destroy(PWM_class);
	failed_classreg:
		unregister_chrdev(PWM_major, DEVICE_NAME);
	failed_chrdevreg:
		return -1;
}

static void PWM_exit(void)
{
	//When we remove the driver, destroy it's device(s), class and major number.
	//device_destroy(PWM_class, MKDEV(PWM_major, 0));
	platform_driver_unregister(&PWM_driver);
	class_destroy(PWM_class);
	unregister_chrdev(PWM_major, DEVICE_NAME);
}

module_init(PWM_init);
module_exit(PWM_exit);
