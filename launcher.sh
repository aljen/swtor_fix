#! /bin/bash

# All cudo's goes towards the original script! The added script below is purely cosmetic in comparison (in that the new part only automates a previously manual step).

unset OPTIMUS_PREFIX
# In case of an optimus-enabled laptop, the use of primusrun is recommended over    optirun.
# Don't uncomment this line in any other case.
# OPTIMUS_PREFIX="                              primusrun"

### BELOW HAS BEEN ADDED TO TURN OFF BIT RUNNER AND SUPPORT PLAYONLINUX ###

#Regardless of where our launcher is located, lets automatically find it and use it!  Even if this script is in a parent directory.
settingslocation=`echo \'``find . -name "launcher.settings" | grep "Star Wars - The Old Republic/launcher.settings"``echo \'`
launcherlocation=`echo \'``find . -name "launcher.exe" | grep "Star Wars - The Old Republic/launcher.exe"``echo \'`

if [ -z "$settingslocation" ]; then
    settingslocation=`echo \'``find . -name "launcher.settings" | grep "./launcher.settings"``echo \'`
fi

if [ -z "$launcherlocation" ]; then
    launcherlocation=`echo \'``find . -name "launcher.exe" | grep "./launcher.exe"``echo \'`
fi

#This is our main command!
LAUNCHER_COMMAND="wine $launcherlocation"

#The text to replace in order to turn off bit runner!
sourcetext=`echo \'`'"PatchingMode": "{ \\"swtor\\": \\"BR\\" }"'`echo \'`
replacetext=`echo \'`'"PatchingMode": "{ \\"swtor\\": \\"SSN\\" }"'`echo \'`

#Is launcher.settings setup for running bit runner?
cmd="grep -i $sourcetext $settingslocation"
istextfound=`eval $cmd`

if [ -n "$istextfound" ]; then
    echo "This will update the launcher.settings file so that bitraider is disabled!"
    echo
    echo "Replacing: $sourcetext"
    echo "with:      $replacetext"
    echo

    islaunchersettingsfixed=n
fi

#Has launcher.settings had  bit runner turned off?
cmd="grep -i $replacetext $settingslocation"
istextfound=`eval $cmd`

if [ -n "$istextfound" ]; then
    echo "This file has been updated so bitraider is disabled."
    echo
    echo "Ready to install!"
    echo

    islaunchersettingsfixed=y
fi

#If launcher.settings doesn't even have bit runner turned on or off, assume this is the first run of the launcher!
#  If it runs flawlessly, there will be no need to turn off bit runner.  This script will not need to be ran again!
if [ -z "$islaunchersettingsfixed" ]; then
    echo "The launcher has never been ran.  Please run the launcher for the first time."
    echo "Login using your user name and password.  Then run the launcher."
    echo
    echo "1.  If the launcher fails:  This is good! Please re-run this script. It will turn off bitraider the second time around."
    echo "2.  If the launcher succeeds:  The first time, there is no need to run this script again.  Please run the installer directly next time!"
    echo
fi

echo "Would you like to Continue? [y/n]"
read input

if [ ! $input = y ]; then
    echo
    echo "Thank you for using this script.  You have choosen $input which is not lower case y.  Exiting..."
    echo

    exit
fi

#Only backup launcher.settings and turn off bit runner in launcher.settings when bit runner is enabled.
if [ $islaunchersettingsfixed = n ]; then
    echo "Backing up launcher.settings to launcher.settings`date +%y%m%d_%H%M`.bak"
    settingsbackuplocation="$settingslocation`date +%y%m%d_%H%M`.bak"

    #Makes a backup of launcher.settings! This only gets done when launcher.settings does not have Bit Runner disabled.
    cmd="cp $settingslocation $settingsbackuplocation"
    eval $cmd

    echo
    echo "Making changes to launcher.settings..."

    #Removes ' from around these statements.  Sed will have its own ' around both statements.
    sourcetextstring=`echo $sourcetext | sed "s|'||g"`
    replacetextstring=`echo $replacetext | sed "s|'||g"`

    #Replaces the desired text in launcher.settings
    cmd="sed 's|$sourcetextstring|$replacetextstring|g' $settingsbackuplocation > $settingslocation"

    echo
    echo "It is strongly advised to allow bit runner to be turned off.  Unless you have a very good reason not to, please select y here.  Turn off bit runner? [Y/n]"
    read turnoffbitrunner

    if [ ! $turnoffbitrunner = n ]; then
        eval $cmd
    fi

    echo
    echo "Finished updating launcher.settings! You will now be able to use the installer to download swtor!"

    #Cleanup our local variables
    unset turnoffbitrunner
    unset replacetextstring
    unset sourcetextstring
    unset settingsbackuplocation
fi

echo
echo "Is your wine environment in 64 bit mode? (Choose y if unsure. If running this on playonlinux 'in 32 bit mode', choose n) [Y/n]"
read specifyarch

echo
echo "Would you like to configure wine to use a custom prefix? (Choose y if unsure. If running this on playonlinux, choose n) [Y/n]"
read specifyprefix

# Set up a new wineprefix in the game directory, and reduce debugging to improve performance.
# If you don't like it there, or running the script from somewhere else, change it.
# Please note that WINEARCH=win32 is REQUIRED.
if [ $specifyarch = y -o $specifyarch = Y -o $specifyarch = yes -o $specifyarch = Yes -o $specifyarch = YES ]; then
    export WINEARCH=win32
    export WINEDEBUG=-all
fi

if [ $specifyprefix = y -o $specifyprefix = Y -o $specifyprefix = yes -o $specifyprefix = Yes -o $specifyprefix = YES ]; then
    export WINEPREFIX="$( pwd )/wineprefix"
fi

# Clean up after ourselves.
unset settingslocation
unset launcherlocation

unset islauchersettingsfixed
unset specifyarch
unset specifyprefix
unset istextfound
unset input
unset cmd

### FROM HERE ON OUT IS THE ORIGINAL SCRIPT  ###

# Check if we have swtor_fix.exe, and download it if we don't.
# This can be placed anywhere on the system, and must be run parallel to the game.

if [ ! -f swtor_fix.exe ]; then
    wget -O swtor_fix.exe https://github.com/aljen/swtor_fix/raw/master/swtor_fix.exe
fi

# Start it parallely.
wine swtor_fix.exe &

# Give it a sec to fire up.
sleep 1

# Install and set up components in wineprefix.
# Since that command does nothing if already ran, we need no checks there.
winetricks msvcp90=native d3dx9_36 vcrun2008 msls31 winhttp

# Here we come!
eval $OPTIMUS_PREFIX $LAUNCHER_COMMAND

# Since wait for swtor_fix.exe to finish.
wait $!

# Clean up after ourselves.
unset WINEARCH
unset WINEPREFIX
unset WINEDEBUG

