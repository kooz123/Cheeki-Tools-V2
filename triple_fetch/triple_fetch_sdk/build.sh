#!/bin/bash
`xcrun --sdk iphoneos -f clang` -I . -fobjc-arc -framework IOKit -isysroot `xcrun --sdk iphoneos --show-sdk-path` -arch armv7 -o hello_world apple_ave_pwn.m apple_ave_utils.m devicesupport.m heap_spray.m hello_world.m iokitUser.m iosurface_utils.m jailbreak.m kernel_read.m log.m offsets.c offsets.m post_exploit.m remote_call.c remote_memory.c remote_ports.c rwx.m task_ports.c utils.m patchfinder64.o
mv hello_world ziva1
#ldid -S ziva1
