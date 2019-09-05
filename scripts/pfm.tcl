set name zcu104_min

platform -name $name -desc "ZCU104 minimum platform" -hw [format ./dsa/%s.xsa $name] -prebuilt -out ./output

domain -name xrt -display-name "A53 XRT Linux" -proc psu_cortexa53 -os linux -image ./sw_platform/image
domain config -boot ./sw_platform/boot
domain config -bif ./generics/linux/linux.bif
domain -runtime opencl

platform -generate
