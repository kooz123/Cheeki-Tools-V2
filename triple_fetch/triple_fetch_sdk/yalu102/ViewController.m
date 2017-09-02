//
//  ViewController.m
//  yalu102
//
//  Created by qwertyoruiop on 05/01/2017.
//  Copyright © 2017 kimjongcracks. All rights reserved.
//

#import "offsets.h"
#import <mach-o/loader.h>
#import <sys/mman.h>
#import <pthread.h>
#undef __IPHONE_OS_VERSION_MIN_REQUIRED
#import <mach/mach.h>
#include <sys/utsname.h>

extern uint64_t procoff;

typedef struct {
    mach_msg_header_t head;
    mach_msg_body_t msgh_body;
    mach_msg_ool_ports_descriptor_t desc[256];
    char pad[4096];
} sprz;


@implementation ViewController

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

char dt[128];
void performPatches(mach_port_t tfp)
{
    mach_port_t pt = MACH_PORT_NULL;
    task_get_special_port(foundport, 4, &pt); // get tfp0
    
    void exploit(mach_port_t, uint64_t, uint64_t);
    exploit(pt, kernel_base, allproc_offset);

}
