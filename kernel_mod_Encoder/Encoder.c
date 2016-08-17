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

#define CLASS_NAME "Encoder"
#define DEVICE_NAME "Encoder"

#define FPGA_SPACING 1

#define N_Encoder_MINORS 32

static struct class* Encoder_class = NULL;
static int Encoder_major = 0;

static DECLARE_BITMAP(minors, N_Encoder_MINORS);

static LIST_HEAD(device_list);
static DEFINE_MUTEX(device_list_lock);

//Make sure only one proccess can accessour the device
static DEFINE_MUTEX(Encoder_device_mutex);

static int memory_request = 0;

//Custom struct to store the data we want in the driver
struct Encoder_data {
	unsigned int * position_address;
	unsigned int * direction_address;
	unsigned int   base_register;
	int 		   message_read;
	struct list_head device_entry;
	dev_t		   devt;
	};


static int Encoder_itoa(int value, char *buffer)
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
/*@Encoder_read the function to handle a read on the device node, returns the current position							*/
/*@Encoder_write the function the handle a write to the device node, sets the setpoint									*/
/*@Encoder_open handles the opening of the device node, gets the Encoder_data struct from memory and sets the device lock	*/
/*@Encoder_release handles the closing of the device node and removes the device lock									*/
/*@Encoder_fops defines the handler functions for the operations														*/
/*------------------------------------------------------------------------------------------------------------------*/

static ssize_t Encoder_read(struct file* filp, char __user *buffer, size_t lenght, loff_t* offset)
{
	struct Encoder_data *Encoder;
	ssize_t retval;
	ssize_t copied = 0;
	unsigned int fpga_value;
	char int_array[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

	//Grab the Encoder_data struct out of the file struct.
	Encoder = filp->private_data;

	//cat keeps requesting new data until it receives a "return 0", so we do a one shot.
	if(Encoder->message_read)
		return 0;
	//Read from the I/O register
	fpga_value = ioread32(Encoder->position_address);
	
	Encoder_itoa(fpga_value, int_array);	

	//Check how long the char array is after we build it.
	copied = sizeof(int_array);

	retval = copy_to_user(buffer, &int_array, copied);
	Encoder->message_read = 1;
	if(retval)
		return retval;
	return retval ? retval : copied;
}

static ssize_t Encoder_write(struct file* filp, const char __user *buffer, size_t lenght, loff_t* offset)
{
//	@TODO: Write is not possible
/*	struct Encoder_data *Encoder;
	ssize_t retval;
	unsigned int converted_value;
	ssize_t count = lenght;

	//Grab the Encoder_data struct out of the file struct.
	Encoder = filp->private_data;

	//Since the data we need is in userspace we need to copy it to kernel space so we can use it.
	retval = kstrtouint_from_user(buffer, count, 0, &converted_value);
	if(retval)
		return retval;
	//Write to the I/O register
	iowrite32(converted_value, Encoder->setpoint_address);
	return retval ? retval : count;*/

	return -EPERM;
}

static int Encoder_open(struct inode* inode, struct file* filp)
{
	int status;
	struct Encoder_data *Encoder;
	mutex_lock(&device_list_lock);

	//Find the address of the struct using the device_list and the device_entry member of the Encoder_data struct.
	list_for_each_entry(Encoder, &device_list, device_entry) {
		//Check if the struct is the correct one.
		if(Encoder->devt == inode->i_rdev) {
			//Store the struct in the private_data member of the file struct so that it is usable in the read and write functions of the device node.
			Encoder->message_read = 0;
			filp->private_data = Encoder;

			status = 0;
		}
	}

	//Try to lock the device, if it fails the device is already in use.
	if(!mutex_trylock(&Encoder_device_mutex))
	{
		printk(KERN_WARNING "Device is in use by another process\n");
		return -EBUSY;
	}

	mutex_unlock(&device_list_lock);

	return 0;
}

static int Encoder_release(struct inode* inode, struct file* filp)
{
	//Remove the mutex lock, so other processes can use the device.
	mutex_unlock(&Encoder_device_mutex);
//	printk(KERN_INFO "Unlocking mutex\n");
	return 0;
}

struct file_operations Encoder_fops = {
	.owner =	THIS_MODULE,
	.read =		Encoder_read,
	.write = 	Encoder_write,
	.open =		Encoder_open,
	.release =	Encoder_release,
};

/*------------------------------------------------------------------------------------------------------*/
/*Sysfs endpoint definitions and handler functions														*/
/*																										*/
/*																										*/
/*																										*/
/*																										*/
/*------------------------------------------------------------------------------------------------------*/

/*
static ssize_t sys_set_node(struct device* dev, struct device_attribute* attr, const char* buffer, size_t lenght)
{
	struct Encoder_data *Encoder;
 	int retval;
	unsigned int converted_value;
	unsigned int * address;
	int count = lenght;

	//Find the address of the struct using the device_list and the device_entry member of the Encoder_data struct.
	list_for_each_entry(Encoder, &device_list, device_entry) {
		//Check if the struct is the correct one.
		if(Encoder->devt == dev->devt) {
			//Grab the address for the node that is being called.
			if(strcmp(attr->attr.name, "P") == 0)
				address = Encoder->P_address;
			else if(strcmp(attr->attr.name, "I") == 0)
				address = Encoder->I_address;
			else if(strcmp(attr->attr.name, "D") == 0)
				address = Encoder->D_address;
			else if(strcmp(attr->attr.name, "Update") == 0)
				address = Encoder->update_address;
		}
	}

	retval = kstrtoint(buffer, 0, &converted_value);
	if(retval)
		return retval;
	iowrite32(converted_value, address);
	return retval ? retval : count;
}
*/

static ssize_t sys_read_node(struct device* dev, struct device_attribute* attr, char *buffer)
{
	struct Encoder_data *Encoder;
	int retval;
	int copied;
	//char data[11];
	//char temp_char;
	//int i = 0;
	//int j = 0;
	char int_array[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	//int tmp;
	unsigned int * address;
	unsigned int fpga_value;

	//Find the address of the struct using the device_list and the device_entry member of the Encoder_data struct.
	list_for_each_entry(Encoder, &device_list, device_entry) {
		//Check if the struct is the correct one.
		if(Encoder->devt == dev->devt) {
/*			//Grab the address for the node that is being called.
			if(strcmp(attr->attr.name, "P") == 0)
				address = Encoder->P_address;
			else if(strcmp(attr->attr.name, "I") == 0)
				address = Encoder->I_address;
			else if(strcmp(attr->attr.name, "D") == 0)
				address = Encoder->D_address;
			else if(strcmp(attr->attr.name, "State") == 0)
				address = Encoder->state_address;
			else if(strcmp(attr->attr.name, "Emerg") == 0)
				address = Encoder->emerg_address;*/
			address = Encoder->direction_address;
		}
	}
	
	fpga_value = ioread32(address);

	Encoder_itoa(fpga_value, int_array);

	//Check how long the char array is after we build it.
	copied = sizeof(int_array);

	retval = copy_to_user(buffer, &int_array, copied);

	return retval ? retval : copied;
}

//Define the device attributes for the sysfs, and their handler functions.
static DEVICE_ATTR(Direction, S_IRUSR, sys_read_node, NULL);

static struct attribute *Encoder_attrs[] = {
	&dev_attr_Direction.attr,
	NULL,
};

static struct attribute_group Encoder_attr_group = {
	.attrs = Encoder_attrs,
};

static const struct attribute_group* Encoder_attr_groups[] = {
	&Encoder_attr_group,
	NULL,
};

/*----------------------------------------------------------------------------------------------------------*/
/*Platform driver functions and struct																		*/
/*@Encoder_dt_ids[] struct to store the compatible device tree names										*/
/*@Encoder_probe called when a compatible device is found in the device tree. Creates device and maps iomem	*/
/*@Encoder_remove called when the driver is removed from the kernel, removes the device and unmaps iomem	*/
/*@Encoder_driver struct to define the platform driver, contains the compatible ID's and the function names */
/*----------------------------------------------------------------------------------------------------------*/

static const struct of_device_id Encoder_dt_ids[] = {
	{ .compatible = "fontys,Encoder"},
	{ .compatible = "xlnx,IP-Enc-Struct-1.8"},
	{ .compatible = "xlnx,IP-Enc-Struct-2.1"},
	{},
};

MODULE_DEVICE_TABLE(of, Encoder_dt_ids);

static int Encoder_probe(struct platform_device *pltform_Encoder)
{
	int minor;
	int status;
	struct resource res;
	int rc;

	struct Encoder_data *Encoder;

	Encoder = kzalloc(sizeof(*Encoder), GFP_KERNEL);
	if(!Encoder)
		return -ENOMEM;
	
	INIT_LIST_HEAD(&Encoder->device_entry);

	mutex_lock(&device_list_lock);
	minor = find_first_zero_bit(minors, N_Encoder_MINORS);
	if (minor < N_Encoder_MINORS)
	{
		struct device *dev;
		
		Encoder->devt = MKDEV(Encoder_major, minor);
		dev = device_create_with_groups(Encoder_class, NULL, Encoder->devt, NULL, Encoder_attr_groups, CLASS_NAME "%d", minor);
		status = PTR_ERR_OR_ZERO(dev);
	}
	else
	{
		printk(KERN_DEBUG "No minor number available!\n");
		status = -ENODEV;
	}
	if( status == 0)
	{
		printk(KERN_INFO "New Encoder controller Encoder%d\n", minor);
		set_bit(minor, minors);
		list_add(&Encoder->device_entry, &device_list);
		//Retreive the base address and request the memory region.
		rc = of_address_to_resource(pltform_Encoder->dev.of_node, 0, &res);
		if( request_mem_region(res.start, resource_size(&res), CLASS_NAME) == NULL)
		{
			printk(KERN_WARNING "Unable to obtain physical I/O addresses\n");
			goto failed_memregion;
		}
		Encoder->base_register = res.start;
		//Remap the memory region in to usable memory
		Encoder->position_address =  of_iomap(pltform_Encoder->dev.of_node, 0);
		Encoder->direction_address = Encoder->position_address + 1;
	}
	mutex_unlock(&device_list_lock);
	
	if(status)
		kfree(Encoder);
	else
		platform_set_drvdata(pltform_Encoder, Encoder);

	return status;

	failed_memregion:
		device_destroy(Encoder_class, Encoder->devt);
		clear_bit(MINOR(Encoder->devt), minors);
	return -ENODEV;
}

static int Encoder_remove(struct platform_device *pltform_Encoder)
{
	struct Encoder_data *Encoder = platform_get_drvdata(pltform_Encoder);
	struct resource res;
	int rc;

	rc = of_address_to_resource(pltform_Encoder->dev.of_node, 0, &res);

	mutex_lock(&device_list_lock);
	//Unmap the iomem
	iounmap(Encoder->position_address);
	//Delete the device from the list
	list_del(&Encoder->device_entry);
	//Destroy the device node
	device_destroy(Encoder_class, Encoder->devt);
	//Clear the minor bit
	clear_bit(MINOR(Encoder->devt), minors);
	if(Encoder->base_register)
	{
		release_mem_region(res.start, resource_size(&res));
		memory_request = 0;
	}
	//Free the kernel memory
	kfree(Encoder);
	mutex_unlock(&device_list_lock);

	return 0;
}

static struct platform_driver Encoder_driver = {
	.driver = {
		.name = "Encoder",
		.owner = THIS_MODULE,
		.of_match_table = of_match_ptr(Encoder_dt_ids),
	},
	.probe = Encoder_probe,
	.remove = Encoder_remove,
};

/*------------------------------------------------------------------------------------------------------*/
/*Module level functions																				*/
/*@Encoder_init initialisation function for the driver														*/
/*@Encoder_exit exit function for the driver																*/
/*------------------------------------------------------------------------------------------------------*/

static int Encoder_init(void)
{
	int retval;
	//Request a major device number from the kernel
	Encoder_major = register_chrdev(0, DEVICE_NAME, &Encoder_fops);
	//If the number is smaller than 0, it's an error. So jump to the error state.
	if(Encoder_major < 0)
	{
		printk(KERN_WARNING "hello: can't get major %d\n", Encoder_major);
		retval = Encoder_major;
		goto failed_chrdevreg;
	}
	//Now that we have a major number, create a device class.
	Encoder_class = class_create(THIS_MODULE, CLASS_NAME);
	//If there is an error, jump to the error state.
	if( IS_ERR(Encoder_class))
	{
		printk(KERN_NOTICE "Error while creating device class\n");
		retval =  PTR_ERR(Encoder_class);
		goto failed_classreg;
	}
	//Now that we have a class, we can create our device node.
	retval = platform_driver_register(&Encoder_driver);
	if(retval)
	{
		printk(KERN_NOTICE "Error while registering driver\n");
		goto failed_driverreg;
	}

	//Initialize the mutex lock.
	mutex_init(&Encoder_device_mutex);

	return 0;

	failed_driverreg:
		class_destroy(Encoder_class);
	failed_classreg:
		unregister_chrdev(Encoder_major, DEVICE_NAME);
	failed_chrdevreg:
		return -1;
}

static void Encoder_exit(void)
{
	//When we remove the driver, destroy it's device(s), class and major number.
	//device_destroy(Encoder_class, MKDEV(Encoder_major, 0));
	platform_driver_unregister(&Encoder_driver);
	class_destroy(Encoder_class);
	unregister_chrdev(Encoder_major, DEVICE_NAME);
}

module_init(Encoder_init);
module_exit(Encoder_exit);
