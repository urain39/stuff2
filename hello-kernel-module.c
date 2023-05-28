#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>


static int __init hello_init(void)
{
  printk("Hello Kernel!");
  return 0;
}

static void __exit hello_exit(void)
{
  printk("Goodbye Kernel!");
}


module_init(hello_init);
module_exit(hello_exit);
MODULE_LICENSE("GPL");


// Makefile:
// obj-m := hello.o


// Compile:
// make -C kernel M=$PWD modules
