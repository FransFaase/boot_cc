#!/bin/sh

set -x

# Build sources
make -C src

# Delete existing rootfs
rm -rf rootfs

# Create minimal directories
mkdir -p rootfs
mkdir -p rootfs/usr
mkdir -p rootfs/usr/bin
mkdir -p rootfs/tmp

# Create and fill bootstrap-seeds directory
mkdir -p rootfs/bootstrap-seeds
mkdir -p rootfs/bootstrap-seeds/POSIX
mkdir -p rootfs/bootstrap-seeds/POSIX/x86
cp -f src/kaem-minimal.x86 rootfs/bootstrap-seeds/POSIX/x86/kaem-optional-seed
cp -f src/hex0.x86 rootfs/bootstrap-seeds/POSIX/x86/hex0-seed

# Copy root kaem script
cp -f target_x86/kaem.x86 rootfs/kaem.x86

# Create and fill x86 specific directory with scripts and source files
mkdir -p rootfs/x86
mkdir -p rootfs/x86/artifact
cp -f -t rootfs/x86 \
    target_x86/tools-seed-kaem.kaem \
    target_x86/tools-mini-kaem.kaem \
    target_x86/check-tools.kaem \
    target_x86/tools-kaem.kaem \
    target_x86/after.kaem \
    src/hex0.x86_hex0 \
    src/kaem-minimal.x86_hex0 \
    src/hex2.x86_hex0 \
    src/blood-elf.macro_x86 \
    src/blood-elf.blood_elf_x86 \
    src/M1.macro_x86 \
    src/M1.blood_elf_x86 \
    src/stack_c.M1_x86 \
    src/stack_c_intro.M1 \
    M2libc/x86/ELF-x86-debug.hex2

# Create and fill directory for generic source files
mkdir -p rootfs/src
cp -f -t rootfs/src \
    src/stdlib.c \
    src/sys_syscall.h \
    src/tcc_cc.sl \
    src/kaem.c \
    src/catm.c \
    src/bootstrappable.c \
    src/match.c \
    src/mkdir.c \
    src/cp.c \
    src/chmod.c \
    src/rm.c \
    src/untar.c \
    src/ungz.c \
    src/unxz.c \
    src/unbz2.c \
    src/sha256sum.c \
    src/configurator.c \
    src/script-generator.c \
    src/stack_c_interpreter.c

# Also add source files for checking
cp -f -t rootfs/src \
    src/equal.c \
    src/hex0.c \
    src/hex2.c \
    src/blood-elf.c \
    src/M1.c \
    src/stack_c.c \
    src/tcc_cc.c \
    src/kaem-minimal.c

# Copy scripts for processing steps
cp -f target_x86/seed.kaem rootfs
cp -f target_x86/configurator.x86.checksums rootfs
cp -f target_x86/script-generator.x86.checksums rootfs

# Copy steps
cp -r steps rootfs
cp -f target_x86/bootstrap.cfg rootfs/steps

# Copy the necessary distribution files
mkdir rootfs/external
cp -r distfiles rootfs/external

# Execute kaem scripts in change root environment
sudo chroot --userspec=$(id -u):$(id -g) rootfs /bootstrap-seeds/POSIX/x86/kaem-optional-seed

# Alternative with strace to generate trace.txt file that can be used
# to generate documentation with the help op scan_trace.cpp
#sudo strace -f -o trace.txt -e trace=open,openat,close,chmod,chdir,dup,fcntl,link,linkat,unlink,fork,execve chroot --userspec=$(id -u):$(id -g) rootfs /bootstrap-seeds/POSIX/x86/kaem-optional-seed

