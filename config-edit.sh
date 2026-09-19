#!/usr/bin/env bash

# Empty variable to initialize current job
current_option=""

# Variable to set which property file to use
properties='server.properties'

# Common-use variables
dotted_line="--------------------------------------"

# Function for keeping lines tidy and nice looking
tidyline() {
	echo
	echo ${dotted_line}
	echo
}

# Print introduction
intro() {
	echo -e '\nWelcome to the MC server config editor!'
	tidyline
}

# Print options for changing the server config file
display_options() {
cat  <<  EOF
	.		-	Display current listed properties
	g 		-	Change gamemode
	h		-	Change to hardcore
	motd 		-	Change server message
	pvp 		-	Change PVP to true or false	
	d		-	Change difficulty
	f		- 	Change flight permission
	steve		-	Change server.properties file in vim	

EOF
}

# Print the gamemode options
display_difficulty() {
cat << EOF

	0 --- peaceful 
	1 --- easy
	2 --- normal
	3 --- hard

EOF
}

display_gamemode() {
cat << EOF

	0 --- survival
	1 --- creative

EOF
}


# Display current core settings - listed in display_options
display_current() {
	local gamemode=$(cat $properties | grep ^gamemode)
	local hardcore=$(cat $properties | grep ^hardcore)
	local motd=$(cat $properties | grep ^motd)
	local difficulty=$(cat $properties | grep ^difficulty)
	local pvp=$(cat $properties | grep ^pvp)
	local flight=$(cat $properties | grep ^allow-flight)
cat << EOF
	
	Current settings: 	
${dotted_line}

	gamemode = ${gamemode##*=}
	motd= "${motd##*=}"
	hardcore = ${hardcore##*=}
	difficulty = ${difficulty##*=}
	pvp = ${pvp##*=}
	flight = ${flight##*=}
EOF
tidyline
}

# Set the config files gamemode difficulty - if invalid, continue looping
# Use bash builtin sed to replace as needed
# TODO: add a quit option
set_difficulty() {
	local valid=1
	local difficulty=''
	while [[ valid -eq 1 ]]; do
		display_difficulty
		read -p "Which difficulty would you like to set? " difficulty_option
		echo 
		if [[ $difficulty_option -eq 0 ]]; then
					difficulty='peaceful'
					tidyline
					break
				elif [[ $difficulty_option -eq 1 ]]; then
					difficulty='easy'
					tidyline
					break
				elif [[ $difficulty_option -eq 2 ]]; then
					difficulty='normal'
					tidyline
					break
				elif [[ $difficulty_option -eq 3 ]]; then
					difficulty='hard'
					tidyline
					break
				else
					echo "Invalid option - please try again"
					echo ${dotted_line}
					continue
				fi
	done
	echo "Changing difficulty to ${difficulty}..."
	sed -i "s/difficulty=.*/difficulty=${difficulty}/g" ${properties}
	tidyline
}

set_gamemode() {
	display_gamemode
	local gamemode_setting=''
	read -p "Which gamemode would you like to set? " gamemode_setting
	echo 
	case ${gamemode_setting} in
		0)
			echo "Setting to survival..."
			sed -i "s/^gamemode=.*/gamemode=survival/g" ${properties}
			;;
		1)
			echo "Setting to creative..."
			sed -i "s/^gamemode=.*/gamemode=creative/g" ${properties}
			;;
		q)
			echo "Exiting without changing..."
			tidyline
			return 1
			;;
		*)
			echo "Invalid option - please try again..."
			tidyline
			return 1
	esac
	tidyline
}

# Toggle hardcore mode between true/false
toggle_hardcore() {
	local existing_setting=$(cat $properties | grep ^hardcore=.*)
	local setting=${existing_setting##*=}
	if [[ ${setting} == "true" ]]; then
		echo -e "\nToggling hardcore mode off...\n"
		sed -i "s/^hardcore=.*/hardcore=false/g" ${properties}
		tidyline
	else
		echo -e "\nToggling hardcore mode on...\n"
		sed -i "s/^hardcore=.*/hardcore=true/g" ${properties}
		tidyline
	fi
}

set_motd() {
	local motd=$(cat $properties | grep ^motd)
	echo "The current motd is = ${motd##*=}"
	read -p "Enter new motd: " new_motd
	echo "Setting..."
	sed -i "s/^motd=.*/motd=${new_motd}/g" ${properties}
	echo "MOTD set successfully! Returning to the main menu..."
	tidyline
	return 1
}

## TODO2: Create a true/false toggle helper function for the toggle settings
toggle_pvp() {
	local pvp=$(cat $properties | grep ^pvp)
	local current_pvp=${pvp##*=}
	echo "PVP is currently set to ${current_pvp}"
	if [[ ${current_pvp} == "true" ]]; then
		echo -e "Toggling PVP...\nPVP is now set to false"
		sed -i "s/^pvp=.*/pvp=false/g" ${properties}
	else
		echo -e "Toggling PVP...\nPVP is now set to true"
		sed -i "s/^pvp=.*/pvp=true/g" ${properties}
	fi
}

# Toggle flight permissions
toggle_flight() {
	local flight=$(cat $properties | grep ^allow-flight)
	local current_flight=${flight##*=}
	if [[ ${current_flight} == "true" ]]; then
		echo -e "\nFlight is currently set to true...\nToggling flight permissions...\nFlight is now set to false\n"
		sed -i "s/^allow-flight=.*/allow-flight=false/g" ${properties}
	else
		echo -e "\nFlight is currently set to false...\nToggling flight permissions...\nFlight is now set to true\n"
		sed -i "s/^allow-flight=.*/allow-flight=true/g" ${properties}
	fi
}

# Open server.properties file in vim
set_in_editor() {
	echo "Opening server.properties file in vim..."
	tidyline
	vim ./${properties}
	return 1
}

select_option() {
	continue=1
	while [[ continue -eq 1 ]]; do
		display_options
		read -p "Please choose from the following options, or 'q' to quit: " current_option
		case "${current_option}" in
			.)
				display_current
				;;
			d)
				set_difficulty
				;;
			g)	
				set_gamemode
				;;

			h)
				toggle_hardcore
				;;
			"motd")
				set_motd
				;;
			"pvp")
				toggle_pvp
				;;
			f)
				toggle_flight
				;;
			"steve")
				set_in_editor
				;;
			q) 
				return 1
				;;
			"exit")
				echo -e "\nQuitting entire process..."
				exit	
				;;
			*)
				echo "Invalid option, please try again..."
				echo
				continue
				;;
		esac
	done
}

# Allow user to choose from the following options, or to open entire config via vim if needed - continuous loop until exited
menu() {
	continue=1
	while [[ ${continue} -eq 1 ]]; do
		if [[ -s server.properties ]]; then
			echo -e "Existing config found...\nstarting server\n"
			continue
			# read -p "Found an existing config file! Would you like to edit this file? y/n " edit
			# echo
		    #    	chmod 777 server.properties	
			# case "${edit}" in
			# 	y)
			# 		select_option
			# 		continue=0
			# 		return 1
			# 		;;
			# 	n)
			# 		continue=0
			# 		return 1
			# 		;;
			# 	*)
			# 		echo -e "Invalid option, please try again...\n"
			# 		continue
			# 		;;
			# esac
		else
			echo -e "\nConfig file does not currently exist - creating one..."
			tidyline
			cp ../server.properties.bak ./server.properties
			chmod 777 server.properties
			select_option
			continue=0
			return 1
		fi
	done
}

main() {
	cd /opt/minecraft/data/
	cp ../eula.txt ./eula.txt
	intro
	menu
	echo -e "\nLaunching the server with current settings..."
	tidyline
	exec java -jar /opt/minecraft/server.jar
}

main
