#!/bin/bash

#	requires exif in order to work

# cd "/mnt/c/Users/FabioGalvagni/Google Drive/The Twins/Temp/"

COL_ERR="\033[0;31m"
COL_WRN="\033[0;33m"
COL_DFT="\033[0m"


usage()
{
	# [ ! -z "$ARG" ] && echo "Unknown option: "$COL_ERR"${ARG%%=*}"$COL_DFT
	echo "Usage: "$COL_WRN"fmmt [--src_dir=|-sd]=<source_directory> [--tgt_dir=|-td]=<target_directory> [--prefix=|-p]=<prefix> [--check-only|-co]"$COL_DFT
	echo "Bye!"
	exit 1
}




read_args()
{
    # ARGS=$@
    [ -z "$ARGS" ] && usage
    for ARG in $ARGS #"$@"
    do
        case $ARG in
            -d|--debug)
            DEBUG="y"
            ;;
            
            -co|--check-only)
            CHECK_ONLY="y"
            ;;

            -td=*|--tgt_dir=*)
            DIR_TGT="${ARG#*=}"
            [ -z "$DIR_TGT" ] && usage
            ;;

            -sd=*|--src_dir=*)
            DIR_SRC="${ARG#*=}"
            [ -z "$DIR_SRC" ] && usage
            ;;

            -p=*|--prefix=*)
            PREFIX="${ARG#*=}"
            [ -z "$PREFIX" ] && usage
            ;;
            
            *)
            echo "ERROR - unkwnon argument: $COL_ERR"${ARG%%=*}$COL_DFT
            ;;
        esac
    done
}




check_args()
{
    if [ ! -z $DEBUG ]; then
        echo "Arguments:"
        echo " - DEBUG: \"$DEBUG\""
        echo " - CHECK_ONLY: \"$CHECK_ONLY\""
        echo " - DIR_SRC: \"$DIR_SRC\""
        echo " - All: "$ARGS
    fi

    if [ -z $DIR_SRC ] [ ! -z $DEBUG ] && ; then
        echo "ERROR - "$COL_ERR"DIR_SRC"$COL_DFT" cannot be null!"
        usage
    fi
}






boh()
{
    echo "DIR_SRC: "$DIR_SRC # DEBUG
    [ ! -z "$DIR_SRC" ] && cd $DIR_SRC


    echo "DIR_TGT: "$DIR_TGT # DEBUG
    [ ! -z "$DIR_TGT" ] && cd $DIR_TGT


    pwd

    # for FL in $(find . -type f \( -name "*.jpg" -o -name "*.jpeg" \))
    for FL in $(find . -type f \( -name "*.jpg" -o -name "*.jpeg" \) | sort | uniq) # command substitution
    # for FL in $(find . -type f \( -name "*.jpg" -o -name "*.jpeg" \) | grep -v $PREFIX | sort | uniq) # command substitution
    do
        FL_BASE=$(basename -- "$FL")
        echo "- "$FL_BASE

        GPSDATE=$(exif --tag=0x001d $FL_BASE | grep Value | sed -r 's/ Value\://' | sed 's/^ *//g' | sed -r 's/\:/\-/g' 1>/dev/null 2>&1) # removes the "Value :" substrings, trims the line, and changes the date format from YYYY:MM:DD to YYYY-MM-DD
        
        echo "GPSDATE: "$GPSDATE
        
        GPSDATE_YEAR=$(echo $GPSDATE | awk -F- '{print $1}')
        GPSDATE_MONTH=$(echo $GPSDATE | awk -F- '{print $2}')
        GPSDATE_DAY=$(echo $GPSDATE | awk -F- '{print $3}')

        FL_BASE_NEW=$PREFIX"_"$GPSDATE_YEAR"-"$GPSDATE_MONTH"-"$GPSDATE_DAY".jpg"
        echo "new filename: $FL_BASE_NEW"

        # check if the date is already in use! (check if new filename is already been used)

        ## do verbose
    done
}




ARGS=$@
read_args
check_args

# boh
