#!/bin/bash -
# Author: Manuel Bankmann
# Version: 1.0
# Description: This script is used to provide import-function for Synology contacts to a yealink IP-phone (T46G tested)
# Requirements: wget, gwak, tidy 

# predefined values
source .env

# get data from Synology
wget --user $USER --password $PASS --no-check-certificate $URL$FILE


# write one card for each contact
gawk ' /BEGIN:VCARD/ { close(fn); ++a; fn=sprintf("card_%02d.vcf", a);
        print "Writing: ", fn } { print $0 > fn; } ' $FILE



CARDS=$(ls | grep card)
echo $CARDS
touch outfile.xml
# iterate through elements found as vcards
for CARD in $CARDS;
        do
        NAME=$(grep "FN:" $CARD | awk -F":" '{print $2}')
        PHONE=$(grep "TEL:" $CARD | awk -F":" '{print $2}')
        echo $NAME
        echo $PHONE
        echo "<DirectoryEntry>" >> outfile.xml
        echo "<Name>">> outfile.xml ; echo "$NAME">> outfile.xml ;echo " </Name>">> outfile.xml
        echo "<Telephone>">> outfile.xml ; echo " $PHONE ">> outfile.xml ; echo "</Telephone>">> outfile.xml
        echo "</DirectoryEntry>">> outfile.xml
done
rm final.xml
tidy -xml outfile.xml
echo "<YealinkIPPhoneDirectory>" >> final.xml
cat outfile.xml >> final.xml
echo "</YealinkIPPhoneDirectory>" >> final.xml
rm outfile.xml
rm -f *.vcf
rm $FILE
exit 0
