webtalk_init -webtalk_dir /home/bas/workspace/test_2/test_2.sdk/webtalk
webtalk_register_client -client project
webtalk_add_data -client project -key date_generated -value "Wed Feb 24 16:25:06 2016" -context "software_version_and_target_device"
webtalk_add_data -client project -key product_version -value "SDK v2015.4" -context "software_version_and_target_device"
webtalk_add_data -client project -key build_version -value "2015.4" -context "software_version_and_target_device"
webtalk_add_data -client project -key os_platform -value "amd64" -context "software_version_and_target_device"
webtalk_add_data -client project -key registration_id -value "" -context "software_version_and_target_device"
webtalk_add_data -client project -key tool_flow -value "SDK" -context "software_version_and_target_device"
webtalk_add_data -client project -key beta -value "false" -context "software_version_and_target_device"
webtalk_add_data -client project -key route_design -value "NA" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_family -value "NA" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_device -value "NA" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_package -value "NA" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_speed -value "NA" -context "software_version_and_target_device"
webtalk_add_data -client project -key random_id -value "7vf4aai2jnvaf2hlvtf5h08eun" -context "software_version_and_target_device"
webtalk_add_data -client project -key project_id -value "2015.4_6" -context "software_version_and_target_device"
webtalk_add_data -client project -key project_iteration -value "6" -context "software_version_and_target_device"
webtalk_add_data -client project -key os_name -value "" -context "user_environment"
webtalk_add_data -client project -key os_release -value "" -context "user_environment"
webtalk_add_data -client project -key cpu_name -value "" -context "user_environment"
webtalk_add_data -client project -key cpu_speed -value "" -context "user_environment"
webtalk_add_data -client project -key total_processors -value "" -context "user_environment"
webtalk_add_data -client project -key system_ram -value "" -context "user_environment"
webtalk_register_client -client sdk
webtalk_add_data -client sdk -key uid -value "1456321570000" -context "sdk\\\\bsp/1456321570000"
webtalk_add_data -client sdk -key hwid -value "1455797481000" -context "sdk\\\\bsp/1456321570000"
webtalk_add_data -client sdk -key os -value "device_tree" -context "sdk\\\\bsp/1456321570000"
webtalk_add_data -client sdk -key apptemplate -value "null" -context "sdk\\\\bsp/1456321570000"
webtalk_transmit -clientid 2920923792 -regid "" -xml /home/bas/workspace/test_2/test_2.sdk/webtalk/usage_statistics_ext_sdk.xml -html /home/bas/workspace/test_2/test_2.sdk/webtalk/usage_statistics_ext_sdk.html -wdm /home/bas/workspace/test_2/test_2.sdk/webtalk/sdk_webtalk.wdm -intro "<H3>SDK Usage Report</H3><BR>"
webtalk_terminate
