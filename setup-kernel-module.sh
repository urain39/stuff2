KVERSION="3.18.31-g85ff375"


make -j8 O=KModule \
    defconfig \
    prepare \
    scripts


echo "$KVERSION" > KModule/include/config/kernel.release
sed -i "s/UTS_RELEASE \".*\"/UTS_RELEASE \"$KVERSION\"/g" \
     KModule/include/generated/utsrelease.h


# 注：你需要将内核模块中，Makefile 里的 obj-$(CONFIG_XXX) 改为 obj-m，
# 并确保 defconfig 配置出的 vermagic 符合目标平台的 vermagic。