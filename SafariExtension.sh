#!/bin/bash
clear
plist=$(cat /Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/AppExtensions/Extensions.plist 2>/dev/null | sed 's/		<key>//g' | grep '	<key>' | sed 's/	<key>//g;s/<\/key>//g;s/\ /\\ /g' | awk '{ print "\""$0"\""}' | tr '\n' ' ')
blocker=$(cat /Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/AppExtensions/ContentBlockers.plist 2>/dev/null | sed 's/		<key>//g' | grep '	<key>' | sed 's/	<key>//g;s/<\/key>//g;s/\ /\\ /g' | awk '{ print "\""$0"\""}' | tr '\n' ' ')
webext=$( cat /Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/WebExtensions/Extensions.plist 2>/dev/null | sed 's/		<key>//g' | grep '	<key>' | sed 's/	<key>//g;s/<\/key>//g;s/\ /\\ /g' | awk '{ print "\""$0"\""}' | tr '\n' ' ')
[ -f /tmp/extlist ] && rm /tmp/extlist
printf "$plist" >>/tmp/extlist
printf "$blocker" >>/tmp/extlist
printf "$webext" >> /tmp/extlist
read -a myarray </tmp/extlist

printf "################################\n# Enable or Disable Extension? #\n################################\n"
select opt in "Enable Extension" "Disable Extension" "Cancel"; do
  case $opt in
    "Enable Extension")
		choice='true'
		break
      ;;
    "Disable Extension")
	  choice='false'
      break
      ;;
  "Cancel")
	  exit
	  ;;
    *)
      echo "This is not an option"
      ;;
  esac
done
clear
printf "############################################\n# What extension would you like to change? #\n############################################\n"
select opt in "${myarray[@]}" "Restart Safari" "Cancel"; do
  case $opt in
    \"*.*)
	  echo "Extension to enable/disable selected: $opt"
	  opt=$( echo "$opt" | sed 's/\"//g;s/\ /\\ '/g)
	  if [ -f /Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/AppExtensions/ContentBlockers.plist ] && grep -q "$opt" /Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/AppExtensions/ContentBlockers.plist ; then
		  pathname="/Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/AppExtensions/ContentBlockers.plist"
	  fi
	  if [ -f /Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/AppExtensions/Extensions.plist ] && grep -q "$opt" /Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/AppExtensions/Extensions.plist ; then
		  pathname="/Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/AppExtensions/Extensions.plist"
	  fi
	  if [ -f /Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/WebExtensions/Extensions.plist ] && grep -q "$opt" /Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/WebExtensions/Extensions.plist ; then
		  pathname="/Users/$(whoami)/Library/Containers/com.apple.Safari/Data/Library/Safari/WebExtensions/Extensions.plist"
	  fi
	  /usr/libexec/PlistBuddy -c "Remove :$opt:Enabled" "$pathname"
	  if       /usr/libexec/PlistBuddy -c "Add :$opt:Enabled bool $choice" "$pathname" ; then
		  echo Extension status for \"$( echo $opt | sed 's/\\ / /g' )\" successfully updated!
	  else
		   echo Extension status for \"$opt\" failed to update!
	   fi
      ;;
	"Restart Safari")
		killall Safari
		open /Applications/Safari.app
		exit
	  ;;
    "Cancel")
	  exit
      ;;
    *)
      echo "This is not an option"
      ;;
  esac
done
echo "Extension Enabled! Please restart Safari for the changes to take effect"
