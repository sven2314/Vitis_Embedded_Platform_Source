#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2024 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************

# Get current directory, used throughout script
set launchDir [file dirname [file normalize [info script]]]
set sourcesDir ${launchDir}/sources

# Create the project using board support
set_param board.repoPaths $::env(XILINX_VIVADO)/data/xhub/boards/XilinxBoardStore/boards/Xilinx
set projName "xilinx_zcu102_dynamic_0_1"
set my_board [get_board_parts xilinx.com:zcu102:part0:* -latest_file_version]
create_project $projName ./$projName -part [get_property PART_NAME [get_board_parts $my_board]] 
set_property board_part $my_board [current_project]

# Set required environment variables and params
set_param project.enablePRFlowIPI 1
set_param project.enablePRFlowIPIOOC 1
set_param chipscope.enablePRFlow 1
set_param bd.skipSupportedIPCheck 1
set_param checkpoint.useBaseFileNamesWhileWritingDCP 1
set_param platform.populateFeatureRomInWriteHwPlatform 0

# Specify and refresh the IP local repo
set_property ip_repo_paths "${sourcesDir}/iprepo" [current_project]
update_ip_catalog

# Import HDL, XDC, and other files
import_files -fileset constrs_1 -norecurse ${sourcesDir}/constraints/static_impl_early.xdc
import_files -fileset constrs_1 -norecurse ${sourcesDir}/constraints/dynamic_impl.xdc
set_property used_in_synthesis false [get_files *imp*.xdc]
set_property processing_order EARLY [get_files  *early.xdc]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Set platform project properties
set_property platform.vendor                        "xilinx"     [current_project]
set_property platform.board_id                      "xd"    [current_project]
set_property platform.name                          "${PLATFORM_NAME}"    [current_project]
set_property platform.version                       "${VER}"        [current_project]
set_property platform.description                   "This platform targets the ZCU102 Development Board. This platform features one PL and one PS channels of DDR4 SDRAM which are instantiated as required by the user kernels for high fabric resource availability ." [current_project]
set_property platform.platform_state                "impl"       [current_project]
set_property platform.uses_pr                       true         [current_project]
set_property platform.dr_inst_path                 {pfm_top_i/dynamic_region}                                              [current_project]
set_property platform.board_memories                { {mem0 ddr4 2GB}} [current_project]
set_property platform.pre_sys_link_overlay_tcl_hook         ${sourcesDir}/misc/dynamic_prelink.tcl                                  [current_project]
set_property platform.post_sys_link_overlay_tcl_hook        ${sourcesDir}/misc/dynamic_postlink.tcl                                 [current_project]
set_property platform.run.steps.opt_design.tcl.post ${sourcesDir}/misc/dynamic_postopt.tcl                                  [current_project]

set_property platform.ip_cache_dir                  ${launchDir}/build/${projName}/${projName}.cache/ip                           [current_project]
set_property platform.synth_constraint_files        [list "${sourcesDir}/constraints/dynamic_impl.xdc,NORMAL,implementation"] [current_project]

set_property platform.design_intent.server_managed "false" [current_project]
set_property platform.design_intent.external_host "false" [current_project]
set_property platform.design_intent.embedded "true" [current_project]
set_property platform.design_intent.datacenter "false" [current_proj]
set_property platform.default_output_type "xclbin" [current_project]

# Set any other project properties
set_property STEPS.OPT_DESIGN.TCL.POST ${sourcesDir}/misc/dynamic_postopt.tcl [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

# Construct reconfigurable BD and partition
create_bd_design pfm_dynamic
source ${sourcesDir}/misc/dynamic_prelink.tcl
source ${sourcesDir}/bd/dynamic.tcl
source ${sourcesDir}/misc/gen_hpfm_cmd_file.tcl
source ${sourcesDir}/misc/dynamic_bd_settings.tcl

# Construct static region BD
create_bd_design pfm_top
source ${sourcesDir}/bd/static.tcl
close_bd_design [get_bd_designs pfm_top]
open_bd_design  [get_files pfm_top.bd]

# Regenerate layout, validate, and save the BD
regenerate_bd_layout
validate_bd_design -force
save_bd_design

# Write BD wrapper HDL
set_property generate_synth_checkpoint true [get_files pfm_top.bd]
add_files -norecurse [make_wrapper -files [get_files pfm_top.bd] -top]
set_property top pfm_top_wrapper [current_fileset]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
