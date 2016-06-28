/****************************************************/
/*													*/
/*	Version 1.3		 								*/
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

#define CLASS_NAME "PID"
#define DEVICE_NAME "PID"

#define N_PID_MINORS 32

static struct class* PID_class = NULL;   // HKMS: netjes dat je "alles" static maakt! JNSN: Dank je.
static int PID_major = 0;

static DECLARE_BITMAP(minors, N_PID_MINORS);

static LIST_HEAD(device_list);
//This mutex is used to prevent creating or removing a device while a create or remove envent is being executed.
static DEFINE_MUTEX(device_list_lock);

//Make sure only one proccess can accessour the device
// HKMS: je hebt 2 mutexen, leg hier even kort uit waar ze toe dienen
static DEFINE_MUTEX(PID_device_mutex);

//Custom struct to store the data we want in the driver
struct PID_data{
	uint32_t* setpoint_address;
	uint32_t* position_address;
	uint32_t* P_address;
	uint32_t* I_address;
	uint32_t* D_address;
	uint32_t* state_address;
	uint32_t* update_address;
	uint32_t* emerg_address;
	int 	  message_read;
	uint32_t  base_register;
	struct list_head device_entry;
	dev_t		   devt;
	};

/*------------------------------------------------------------------------------------------------------------------*/
/*Device node handler functions and definition struct																*/
/*@PID_read the function to handle a read on the device node, returns the current position							*/
/*@PID_write the function the handle a write to the device node, sets the setpoint									*/
/*@PID_open handles the opening of the device node, gets the PID_data struct from memory and sets the device lock	*/
/*@PID_release handles the closing of the device node and removes the device lock									*/
/*@PID_fops defines the handler functions for the operations														*/
/*------------------------------------------------------------------------------------------------------------------*/

static ssize_t PID_read(struct file* filp, char __user *buffer, size_t lenght, loff_t* offset)
{
    // HKMS: ik mis het uitlezen van het minor nummer... die negeer je helemaal? Ik zou alsnog bewust 1 minor nummer gebruiken om toekomstige uitbreidingen niet in de weg te zitten
	// JNSN: Ik heb werkelijk waar geen idee wat ik met het minor nummer zou moeten doen. Als ik het goed berijp uit de Spidev driver, bevat de file struct mijn struct die ik er in gestopt heb.
	// JNSN: Uit deze struct kan ik mijn adressen halen.
	struct PID_data* PID;
	ssize_t retval = -1;
	ssize_t copied = 0;
	unsigned int fpga_value = 0;
	char int_array[20];

	//Grab the PID_data struct out of the file struct.
	PID = filp->private_data;

	//cat keeps requesting new data until it receives a "return 0", so we do a one shot.
	if(PID->message_read)
	{
		return 0;
	}
	//Read from the I/O register
	fpga_value = ioread32(PID->position_address);

	copied = snprintf(int_array, 20, "%i", fpga_value);

	retval = copy_to_user(buffer, &int_array, copied);
	PID->message_read = 1;

// HKMS: gebruik altijd accolades, ook al heb je maar 1 regel! Zie bijvoorbeeld deze security bug waarom: https://www.imperialviolet.org/2014/02/22/applebug.html
	return retval ? retval : copied;
}

static ssize_t PID_write(struct file* filp, const char __user *buffer, size_t lenght, loff_t* offset)
{
	struct PID_data *PID;
	ssize_t retval = -1;
	unsigned int converted_value;
	ssize_t count = lenght;

	//Grab the PID_data struct out of the file struct.
	PID = filp->private_data;

	//Since the data we need is in userspace we need to copy it to kernel space so we can use it.
	retval = kstrtouint_from_user(buffer, count, 0, &converted_value);
	converted_value = converted_value * 100000;
	//Write to the I/O register
	iowrite32(converted_value, PID->setpoint_address);

	return retval ? retval : count;
}

static int PID_open(struct inode* inode, struct file* filp)
{
	int status = -1;
	struct PID_data *PID;

	mutex_lock(&device_list_lock);

	//Find the address of the struct using the device_list and the device_entry member of the PID_data struct.
	list_for_each_entry(PID, &device_list, device_entry) {   // HKMS: ik snap niet helemaal waarom dit in een gelinkte lijst moet
															 // JNSN: dit komt rechtstreeks uit de voorbeelden in LDD3 en de Spidev driver. Als je een beter voorstel hebt hoor ik dat graag.
		//Check if the struct is the correct one.
		if(PID->devt == inode->i_rdev) {
			//Store the struct in the private_data member of the file struct so that it is usable in the read and write functions of the device node.
			PID->message_read = 0;
			filp->private_data = PID;

			status = 0;
		}
	}

	//Try to lock the device, if it fails the device is already in use.
	if(!mutex_trylock(&PID_device_mutex))
	{
		printk(KERN_WARNING "Device is in use by another process\n");
		return -EBUSY;
	}

	mutex_unlock(&device_list_lock);

	return 0;
}

static int PID_release(struct inode* inode, struct file* filp)
{
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

/*------------------------------------------------------------------------------------------------------*/
/*Sysfs endpoint definitions and handler functions.														*/
/*The sysfs nodes are used to transfer settings to the PID controller and read status information.		*/
/*E.g. the values for the P, I and D factors for the settings, and Emergency stop for the status.		*/
/*																										*/
/*																										*/
/*------------------------------------------------------------------------------------------------------*/

static ssize_t sys_set_node(struct device* dev, struct device_attribute* attr, const char* buffer, size_t lenght)
{
	struct PID_data *PID;
 	int retval = -1;
	unsigned int converted_value = 0;
	unsigned int * address = 0;
	int count = lenght;

	//Find the address of the struct using the device_list and the device_entry member of the PID_data struct.
	list_for_each_entry(PID, &device_list, device_entry) {
		//Check if the struct is the correct one.
		if(PID->devt == dev->devt) {
			//Grab the address for the node that is being called.
		    // HKMS: ik zou een array maken van filenamen en adressen, loop door de namen om te kijken welke file
		    // HKMS: benaderd wordt en neem dan het bijpassende adres over. Makkelijker configureren en voorkomt
		    // HKMS: code explosie bij nog meer files
			if(strcmp(attr->attr.name, "P") == 0)
			{
				address = PID->P_address;
			}
			else if(strcmp(attr->attr.name, "I") == 0)
			{
				address = PID->I_address;
			}
			else if(strcmp(attr->attr.name, "D") == 0)
			{
				address = PID->D_address;
			}
			else if(strcmp(attr->attr.name, "Update") == 0)
			{
				address = PID->update_address;
			}
			else
			{
				printk(KERN_WARNING "Invalid sysfs node\n");
				return -ENXIO;
			}
		}
	}

	retval = kstrtoint(buffer, 0, &converted_value);
	converted_value = converted_value * 100000;
	
	iowrite32(converted_value, address);

	return retval ? retval : count;
}

static ssize_t sys_read_node(struct device* dev, struct device_attribute* attr, char *buffer)
{
	struct PID_data *PID;
	int retval = -1;
	int copied = 0;
	char int_array[20];
	unsigned int* address = 0;
	unsigned int fpga_value = 0;

	//Find the address of the struct using the device_list and the device_entry member of the PID_data struct.
	list_for_each_entry(PID, &device_list, device_entry) {
		//Check if the struct is the correct one.

		char* filenames[] = {"P", "I"};
		unsigned int* addresses[] = {PID->P_address, PID->I_address};
		const size_t nr_files = sizeof(filenames) / sizeof(filenames[0]);
		int i = 0;
		for(; i < nr_files; i++)
		{
			if (strcmp(attr->attr.name, filenames[i]) == 0)
			{
				address = addresses[i];
			}
		}

		if(PID->devt == dev->devt) {
			//Grab the address for the node that is being called.
			if(strcmp(attr->attr.name, "P") == 0)
			{
				address = PID->P_address;
			}
			else if(strcmp(attr->attr.name, "I") == 0)
			{
				address = PID->I_address;
			}
			else if(strcmp(attr->attr.name, "D") == 0)
			{
				address = PID->D_address;
			}
			else if(strcmp(attr->attr.name, "State") == 0)
			{
				address = PID->state_address;
			}
			else if(strcmp(attr->attr.name, "Emerg") == 0)
			{
				address = PID->emerg_address;
			}
			else
			{
				printk(KERN_WARNING "Invalid sysfs node\n");
				return -ENXIO;
			}
		}
	}
	
	fpga_value = ioread32(address) / 100000;
	
	copied = snprintf(int_array, 20, "%i", fpga_value);
	
	retval = copy_to_user(buffer, &int_array, copied);

	return retval ? retval : copied;
}

//Define the device attributes for the sysfs, and their handler functions.
static DEVICE_ATTR(P, S_IRUSR | S_IWUSR, sys_read_node, sys_set_node);
static DEVICE_ATTR(I, S_IRUSR | S_IWUSR, sys_read_node, sys_set_node);
static DEVICE_ATTR(D, S_IRUSR | S_IWUSR, sys_read_node, sys_set_node);
static DEVICE_ATTR(State, S_IRUSR, sys_read_node, NULL);
static DEVICE_ATTR(Update, S_IWUSR, NULL, sys_set_node);
static DEVICE_ATTR(Emerg, S_IRUSR, sys_read_node, NULL);

static struct attribute *PID_attrs[] = {
	&dev_attr_P.attr,
	&dev_attr_I.attr,
	&dev_attr_D.attr,
	&dev_attr_State.attr,
	&dev_attr_Update.attr,
	&dev_attr_Emerg.attr,
	NULL,
};

static struct attribute_group PID_attr_group = {
	.attrs = PID_attrs,
};

static const struct attribute_group* PID_attr_groups[] = {
	&PID_attr_group,
	NULL,
};

/*------------------------------------------------------------------------------------------------------*/
/*Platform driver functions and struct																	*/
/*@PID_dt_ids[] struct to store the compatible device tree names										*/
/*@PID_probe called when a compatible device is found in the device tree. Creates device and maps iomem	*/
/*@PID_remove called when the driver is removed from the kernel, removes the device and unmaps iomem	*/
/*@PID_driver struct to define the platform driver, contains the compatible ID's and the function names */
/*------------------------------------------------------------------------------------------------------*/

static const struct of_device_id PID_dt_ids[] = {
	{ .compatible = "fontys,PID"},
	{ .compatible = "xlnx,PID-Struct-1.0"},
	{},
};

MODULE_DEVICE_TABLE(of, PID_dt_ids);

static int PID_probe(struct platform_device *pltform_PID)
{
	int minor = 0;
	int status = -1;
	struct resource res;
	int rc = 0;

	struct PID_data *PID;

	PID = kzalloc(sizeof(*PID), GFP_KERNEL);
	if(!PID)
	{
		return -ENOMEM;
	}
	
	INIT_LIST_HEAD(&PID->device_entry);

	mutex_lock(&device_list_lock);
	minor = find_first_zero_bit(minors, N_PID_MINORS);
	if (minor < N_PID_MINORS)
	{
		struct device *dev;
		
		PID->devt = MKDEV(PID_major, minor);
		dev = device_create_with_groups(PID_class, NULL, PID->devt, NULL, PID_attr_groups, CLASS_NAME "%d", minor);
		status = PTR_ERR_OR_ZERO(dev);
	}
	else
	{
		printk(KERN_DEBUG "No minor number available!\n");
		status = -ENODEV;
	}
	if( status == 0)
	{
		printk(KERN_INFO "New PID controller PID%d\n", minor);
		set_bit(minor, minors);
		list_add(&PID->device_entry, &device_list);
		//Retreive the base address and request the memory region.
		rc = of_address_to_resource(pltform_PID->dev.of_node, 0, &res);
		if( request_mem_region(res.start, resource_size(&res), CLASS_NAME) == NULL)
		{
			printk(KERN_WARNING "Unable to obtain physical I/O addresses\n");
			goto failed_memregion;
		}
		PID->base_register = res.start;
		//Remap the memory region in to usable memory
		PID->setpoint_address =  of_iomap(pltform_PID->dev.of_node, 0);
		PID->P_address = PID->setpoint_address + 1;
		PID->I_address = PID->setpoint_address + 2;
		PID->D_address = PID->setpoint_address + 3;
		PID->update_address = PID->setpoint_address + 4;
		PID->state_address = PID->setpoint_address + 5;
		PID->emerg_address = PID->setpoint_address + 6;
		PID->position_address = PID->setpoint_address + 7;
	}
	mutex_unlock(&device_list_lock);
	
	if(status)
	{
		kfree(PID);
	}
	else
	{
		platform_set_drvdata(pltform_PID, PID);
	}

	return status;

failed_memregion:
		device_destroy(PID_class, PID->devt);
		clear_bit(MINOR(PID->devt), minors);
	return -ENODEV;
}

static int PID_remove(struct platform_device *pltform_PID)
{
	struct PID_data *PID = platform_get_drvdata(pltform_PID);
	struct resource res;
	int rc = 0;

	rc = of_address_to_resource(pltform_PID->dev.of_node, 0, &res);

	mutex_lock(&device_list_lock);
	//Unmap the iomem
	iounmap(PID->setpoint_address);
	//Delete the device from the list
	list_del(&PID->device_entry);
	//Destroy the device node
	device_destroy(PID_class, PID->devt);
	//Clear the minor bit
	clear_bit(MINOR(PID->devt), minors);
	if(PID->base_register)
	{
		release_mem_region(res.start, resource_size(&res));
	}
	//Free the kernel memory
	kfree(PID);
	mutex_unlock(&device_list_lock);

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

/*------------------------------------------------------------------------------------------------------*/
/*Module level functions																				*/
/*@PID_init initialisation function for the driver														*/
/*@PID_exit exit function for the driver																*/
/*------------------------------------------------------------------------------------------------------*/

static int PID_init(void)
{
	int retval;
	//Request a major device number from the kernel
	PID_major = register_chrdev(0, DEVICE_NAME, &PID_fops);
	//If the number is smaller than 0, it's an error. So jump to the error state.
	if(PID_major < 0)
	{
		printk(KERN_WARNING "PID: can't get major %d\n", PID_major);
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

	//Initialize the mutex lock.
	mutex_init(&PID_device_mutex);

	return 0;

failed_driverreg:
		class_destroy(PID_class);
failed_classreg:
		unregister_chrdev(PID_major, DEVICE_NAME);
failed_chrdevreg:
		return -1;
}

static void PID_exit(void)
{
	//When we remove the driver, destroy it's device(s), class and major number.
	//device_destroy(PID_class, MKDEV(PID_major, 0));
	platform_driver_unregister(&PID_driver);
	class_destroy(PID_class);
	unregister_chrdev(PID_major, DEVICE_NAME);
}

module_init(PID_init);
module_exit(PID_exit);

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("Bas Janssen");
