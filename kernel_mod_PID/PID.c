/*Version 1.0*/

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
#include <linux/platform_device.h>
#include <asm/io.h>
#include <asm/uaccess.h>

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("Bas Janssen");


#define CLASS_NAME "PID"
#define DEVICE_NAME "PID"
#define HELLO_MSG_FIFO_SIZE 1024
#define HELLO_MSG_FIFO_MAX 128

#define BASE_ADDR 0x43C00000
#define FPGA_SPACING 1

static struct class* PID_class = NULL;
static struct device* PID_device = NULL;
static int PID_major = 0;

//Make sure only one proccess can accessour the device
static DEFINE_MUTEX(PID_device_mutex);

static unsigned int * base_addr_pointer;

static const struct of_device_id PID_dt_ids[] = {
	{ .compatible = "fontys,PID"},
	{},
};

MODULE_DEVICE_TABLE(of, PID_dt_ids);

struct PID_data {
	unsigned int * setpoint_address;
	unsigned int * position_address;
	unsigned int * P_address;
	unsigned int * I_address;
	unsigned int * D_address;
	unsigned int * state_address;
	unsigned int * update_address;
	unsigned int * emerg_address;
	int 			message_read;
	};


static ssize_t PID_read(struct file* filp, char __user *buffer, size_t lenght, loff_t* offset)
{
	struct PID_data *PID;
	ssize_t retval;
	ssize_t copied = 0;
	int fpga_value;
	char data[11];
	char temp_char;
	int i = 0;
	int tmp;
	char int_array[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	int j;

	PID = filp->private_data;

	//cat keeps requesting new data until it receives a "return 0", so we do a one shot.
	if(PID->message_read)
		return 0;
	//Read from the I/O register
	fpga_value = ioread32(PID->position_address);

	//As we dont have access to itoa(), we write it our selves. Convert the int to an array of chars, and filp it while trimming leading 0's.
    tmp = fpga_value;
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
			int_array[j+1] = '\0';
			int_array[j+2] = '\n';
			break;
		}
	}
	//Check how long the char array is after we build it.
	copied = sizeof(int_array);

	retval = copy_to_user(buffer, &int_array, copied);
	PID->message_read = 1;
	if(retval)
		return retval;
	return retval ? retval : copied;
	
}

static ssize_t PID_write(struct file* filp, const char __user *buffer, size_t lenght, loff_t* offset)
{
	struct PID_data *PID;
	ssize_t retval;
	int converted_value;
	ssize_t count = lenght;

	PID = filp->private_data;

	//Since the data we need is in userspace we need to copy it to kernel space so we can use it.
	retval = kstrtoint_from_user(buffer, count, 0, &converted_value);
	if(retval)
		return retval;
	//Write to the I/O register
	iowrite32(converted_value, PID->setpoint_address);
	return retval ? retval : count;
}

static int PID_open(struct inode* inode, struct file* filp)
{
	struct PID_data *PID;

	PID = kzalloc(sizeof(*PID), GFP_KERNEL);
	if(!PID)
		return -ENOMEM;
	//Try to lock the device, if it fails the device is already in use.
	if(!mutex_trylock(&PID_device_mutex))
	{
		printk(KERN_WARNING "Device is in use by another process\n");
		return -EBUSY;
	}

	PID->setpoint_address = base_addr_pointer + (iminor(inode) * 5 * FPGA_SPACING);
	PID->P_address = PID->setpoint_address + FPGA_SPACING;
	PID->position_address = PID->setpoint_address + (2 * FPGA_SPACING);
	PID->message_read = 0;

	filp->private_data = PID;
	
	return 0;
}

static int PID_release(struct inode* inode, struct file* filp)
{
	struct PID_data *PID;
	PID = filp->private_data;
	kfree(PID);
	//Remove the mutex lock, so other processes can use the device.
	mutex_unlock(&PID_device_mutex);
	return 0;
}

struct file_operations PID_fops = {
	.owner =	THIS_MODULE,
	.read =		PID_read,
	.write = 	PID_write,
	.open =		PID_open,
	.release =	PID_release,
};

//We want to be able to set the P factor for the controller, so we define a function to do so.
//The function works the same way as the write() for the device node.
static ssize_t sys_set_P(struct device* dev, struct device_attribute* attr, const char* buffer, size_t lenght)
{
	//@TODO Calculate register pointer.
 	int retval;
	int converted_value;
	int dev_minor = MINOR(dev->devt);
	int count = lenght;
	unsigned int * address = base_addr_pointer + FPGA_SPACING;
	//The buffer is allready in the kernel space
	retval = kstrtoint(buffer, 0, &converted_value);
	if(retval)
		return retval;
	iowrite32(converted_value, address);
	return retval ? retval : count;
}

static ssize_t sys_read_P(struct device* dev, struct device_attribute* attr, char *buffer)
{
	int retval;
	int copied;
	char data[11];
	char temp_char;
	int i = 0;
	int j = 0;
	char int_array[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	int tmp;
	unsigned int * address = base_addr_pointer + 3 * FPGA_SPACING;
	int fpga_value;
	fpga_value = ioread32(address);
	//As we dont have access to itoa(), we write it our selves. Convert the int to an array of chars, and filp it while trimming leading 0's.
    tmp = fpga_value;
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
			int_array[j+1] = '\0';
			int_array[j+2] = '\n';
			break;
		}
	}
	//Check how long the char array is after we build it.
	copied = sizeof(int_array);

	retval = copy_to_user(buffer, &int_array, copied);
	if(retval)
		return retval;
	return retval ? retval : copied;
}

//We alse want to be able to set the I factor.
static ssize_t sys_set_I(struct device* dev, struct device_attribute* attr, const char* buffer, size_t lenght)
{
	//@TODO Calculate register pointer.
 	int retval;
	int converted_value;
	int dev_minor = MINOR(dev->devt);
	unsigned int * address = base_addr_pointer + 3 * FPGA_SPACING;
	int count = lenght;
	retval = kstrtoint(buffer, 0, &converted_value);
	if(retval)
		return retval;
	iowrite32(converted_value, address);
	return retval ? retval : count;
}

static ssize_t sys_read_I(struct device* dev, struct device_attribute* attr, char *buffer)
{
	int retval;
	int copied;
	char data[11];
	char temp_char;
	int i = 0;
	int j = 0;
	char int_array[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	int tmp;
	unsigned int * address = base_addr_pointer + 3 * FPGA_SPACING;
	int fpga_value;
	fpga_value = ioread32(address);
	//As we dont have access to itoa(), we write it our selves. Convert the int to an array of chars, and filp it while trimming leading 0's.
    tmp = fpga_value;
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
			int_array[j+1] = '\0';
			int_array[j+2] = '\n';
			break;
		}
	}
	//Check how long the char array is after we build it.
	copied = sizeof(int_array);

	retval = copy_to_user(buffer, &int_array, copied);
	if(retval)
		return retval;
	return retval ? retval : copied;
}

//And the D factor
static ssize_t sys_set_D(struct device* dev, struct device_attribute* attr, const char* buffer, size_t lenght)
{
	//@TODO Calculate register pointer.
 	int retval;
	int converted_value;
	int dev_minor = MINOR(dev->devt);
	int count = lenght;
	unsigned int * address = base_addr_pointer + FPGA_SPACING;
	retval = kstrtoint(buffer, 0, &converted_value);
	if(retval)
		return retval;
	iowrite32(converted_value, address);
	return retval ? retval : count;
}

static ssize_t sys_read_D(struct device* dev, struct device_attribute* attr, char *buffer)
{
	int retval;
	int copied;
	char data[11];
	char temp_char;
	int i = 0;
	int j = 0;
	char int_array[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	int fpga_value;
	int tmp;
	unsigned int * address = base_addr_pointer + 3 * FPGA_SPACING;
	fpga_value = ioread32(address);
	//As we dont have access to itoa(), we write it our selves. Convert the int to an array of chars, and filp it while trimming leading 0's.
    tmp = fpga_value;
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
			int_array[j+1] = '\0';
			int_array[j+2] = '\n';
			break;
		}
	}
	//Check how long the char array is after we build it.
	copied = sizeof(int_array);

	retval = copy_to_user(buffer, &int_array, copied);
	if(retval)
		return retval;
	return retval ? retval : copied;
}

//Define the device attributes for the sysfs, and their handler functions.
static DEVICE_ATTR(P, S_IRUSR | S_IWUSR, sys_read_P, sys_set_P);
static DEVICE_ATTR(I, S_IRUSR | S_IWUSR, sys_read_I, sys_set_I);
static DEVICE_ATTR(D, S_IRUSR | S_IWUSR, sys_read_D, sys_set_D);

static struct attribute *PID_attrs[] = {
	&dev_attr_P.attr,
	&dev_attr_I.attr,
	&dev_attr_D.attr,
	NULL,
};

static struct attribute_group PID_attr_group = {
	.attrs = PID_attrs,
};

static const struct attribute_group* PID_attr_groups[] = {
	&PID_attr_group,
	NULL,
};

static int PID_probe(void)
{
	return 0;
}

static int PID_remove(void)
{
	return 0;
}

static struct platform_driver PID_driver = {
	.driver = {
		.name = "PID",
		.owner = THIS_MODULE,
		.of_match_table = of_match_ptr(PID_dt_ids),
	},
	.probe = PID_probe,
	.remove = PID_remove,
};

static int PID_init(void)
{
	int retval;
	//Request a major device number from the kernel
	PID_major = register_chrdev(0, DEVICE_NAME, &PID_fops);
	//If the number is smaller than 0, it's an error. So jump to the error state.
	if(PID_major < 0)
	{
		printk(KERN_WARNING "hello: can't get major %d\n", PID_major);
		retval = PID_major;
		goto failed_chrdevreg;
	}
	//Now that we have a major number, create a device class.
	PID_class = class_create(THIS_MODULE, CLASS_NAME);
	//If there is an error, jump to the error state.
	if( IS_ERR(PID_class))
	{
		printk(KERN_NOTICE "Error while creating device class\n");
		retval =  PTR_ERR(PID_class);
		goto failed_classreg;
	}
	//Now that we have a class, we can create our device node.
	retval = platform_driver_register(&PID_driver);
	if(retval)
	{
		printk(KERN_NOTICE "Error while registering driver\n");
		goto failed_driverreg;
	}

	PID_device = device_create_with_groups(PID_class, NULL, MKDEV(PID_major, 0), NULL, PID_attr_groups, CLASS_NAME "_" DEVICE_NAME);
	//If ther is an error, jump to the error state.
	if( IS_ERR(PID_device))
	{
		printk(KERN_NOTICE "Error while creating device\n");
		retval = PTR_ERR(PID_device);
		goto failed_devreg;
	}

	if( request_mem_region(BASE_ADDR, PAGE_SIZE, CLASS_NAME) == NULL)
	{
		printk(KERN_WARNING "Unable to obtain physical I/O addresses\n");
		goto failed_memregion;
	}

	base_addr_pointer = ioremap(BASE_ADDR, PAGE_SIZE);

	//Initialize the mutex lock.
	mutex_init(&PID_device_mutex);

	return 0;

	failed_memregion:
	//If one of the registrations fails, undo all the parts that went before it as well.
	failed_devreg:
		platform_driver_unregister(&PID_driver);
	failed_driverreg:
		class_destroy(PID_class);
	failed_classreg:
		unregister_chrdev(PID_major, DEVICE_NAME);
	failed_chrdevreg:
		return -1;
}

static void PID_exit(void)
{
	//Unmap the I/O memmory
	iounmap(base_addr_pointer);
	//Release the memmory region so other proccesses can claim it.
	release_mem_region(BASE_ADDR, PAGE_SIZE);
	//When we remove the driver, destroy it's device(s), class and major number.
	device_destroy(PID_class, MKDEV(PID_major, 0));
	platform_driver_unregister(&PID_driver);
	class_destroy(PID_class);
	unregister_chrdev(PID_major, DEVICE_NAME);
}

module_init(PID_init);
module_exit(PID_exit);