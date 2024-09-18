#!/bin/bash

#Execute on FTP mirror of metabolights
#Directory called MTBLSData

mkdir -p /tmp/Oracledata
touch /tmp/Oracledata/ISA-Tab.csv
touch /tmp/Oracledata/Keyword.csv
touch /tmp/Oracledata/Study.csv
touch /tmp/Oracledata/Protocol.csv
touch /tmp/Oracledata/has_keyword.csv
touch /tmp/Oracledata/has_tag.csv
touch /tmp/Oracledata/Tag.csv

for f in $(ls -d1 $PWD/MTBLSData/*); do
    #Change to directory
    cd $f    
    
    #Get line numbers for protocol names and protocols
    SPNLINENUM=$(grep -n "Study Protocol Name" ./i_Investigation.txt | cut -f1 -d:)
    SPDLINENUM=$(grep -n "Study Protocol Description" ./i_Investigation.txt | cut -f1 -d:)

    # If "Mass spectrometry" not in Study Protocol Name line, ignore this protocol
    if ! sed "$SPNLINENUM"'!d' ./i_Investigation.txt | grep -q '"Mass spectrometry"'
    then
	cd ..
	echo "No mass spectrometry"
	continue
    fi
    
    #Create ISA-Tab and Study table entries
    echo \"$(basename $f)\" >> /tmp/Oracledata/ISA-Tab.csv
    StudyID=$( grep "Study Identifier" ./i_Investigation.txt | cut -f2)
    echo "$StudyID,\"$(basename $f)\"" >> /tmp/Oracledata/Study.csv
    
    StudyID=$(echo $StudyID | tr -d '\n\r')

    KWLINENUM=$(grep -n -P "Study Design Type\t" ./i_Investigation.txt | cut -f1 -d:)
    IFS=$'|';KW=$(sed "$KWLINENUM"'!d' ./i_Investigation.txt)
    KEYWORDS=$(echo ${KW//$'\t'/'<'} | cut -d '<' -f2-)
    CHROM=false
    declare -a CHROMARRAY
    CINDEX=0
    IFS='<'; for k in $KEYWORDS 
    do
	k=$(echo $k | tr -d '\n\r')
	#k=$(echo $k | tr -d '\r')
	if echo $k | grep -q -i 'chromatography'
	then
	    CHROM=true
	    CHROMARRAY[$CINDEX]=$k
	    ((CINDEX++))
	fi
	IFS=$'|'; echo "$k,,\"$(basename $f)\"" >> /tmp/Oracledata/Keyword.csv
    done
    
    
    
    # Go through all protocols
    IFS="|"; PROTOCOLNAMES=$(sed "$SPNLINENUM"'!d' i_Investigation.txt)
    IFS="|"; PROTOCOLS=$(sed "$SPDLINENUM"'!d' i_Investigation.txt)
    i=0
    PNAMES=$(echo ${PROTOCOLNAMES//$'\t'/'<'} | cut -d '<' -f2-)
    PS=$(echo ${PROTOCOLS//$'\t'/'<'} | cut -d '<' -f2-)
    IFS='<'; read -ra ARR <<< "$PS"
    IFS='<';for x in $PNAMES
    do
	x=$(echo -e ${x//'"'/''} | sed -e 's/[ \t]*$//' | tr -d '\n\r')
	ARR[i]=$(echo ${ARR[i]} | tr -d '\n\r')
	echo "\"$x\",${ARR[i]},$StudyID" >> /tmp/Oracledata/Protocol.csv
	if echo ${ARR[i]} | grep -i -q "Arabidopsis"
	    then
	    echo "\"$x\",$StudyID,\"Arabidopsis\"" >> /tmp/Oracledata/has_tag.csv
	fi
	if echo ${ARR[i]} | grep -i -q "LTQ-Orbitrap"
	    then
	    echo "\"$x\",$StudyID,\"LTQ-Orbitrap\"" >> /tmp/Oracledata/has_tag.csv
	fi
	if echo ${ARR[i]} | grep -i -q "Electrospray"
	    then
	    echo "\"$x\",$StudyID,\"Electrospray\"" >> /tmp/Oracledata/has_tag.csv
	fi
	if [ "$CHROM" = true ] && [ "$x" == "Chromatography" ] ; then
	    for currentkeyword in "${CHROMARRAY[@]}"
	    do
		echo "\"$x\",$StudyID,$currentkeyword,\"$(basename $f)\"" >> /tmp/Oracledata/has_keyword.csv
	    done
	fi
	((i++))
    done
    unset IFS
    unset CHROMARRAY
    cd ..
done
