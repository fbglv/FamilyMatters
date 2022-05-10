#!/bin/zsh

#	requires exif in order to work




COL_ERR="\033[0;31m" # error output
COL_OK="\033[0;32m" # ok output 
COL_WRN="\033[0;33m" # warning output
COL_DFT="\033[0m" # default output
WAIT_SHORT=0.5
WAIT_LONG=0.75
BLANK_LONG="                                                        "




#
#   Informs the user about how to call the script
#
usage()
{
	echo "Usage: "$COL_WRN"fmmt [--raw_dir=|-rd]=<raw_directory> [--proc_dir=|-pd]=<proc_directory> [--prefix=|-p]=<prefix> [--check-only|-co] [--slow|-s]"$COL_DFT
	echo "Bye!"
	exit 1
}



#
#   Parses the input arguments
#
read_args()
{
    [ -z "$ARGS" ] && usage

    for ARG in $ARGS
    do
        case $ARG in
            -d|--debug)
            DEBUG="y"
            ;;
            
            -co|--check-only)
            CHECK_ONLY="y"
            ;;

            -s|--slow)
            SLOW="y"
            ;;

            -rd=*|--raw_dir=*)
            DIR_RAW="${ARG#*=}"
            [ -z "$DIR_RAW" ] && usage
            ;;
            
            -pd=*|--proc_dir=*)
            DIR_PROC="${ARG#*=}"
            [ -z "$DIR_PROC" ] && usage
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



#
#   Checks input parameters' combination validity
#
check_args()
{
    if [ $DEBUG ]; then
        echo "Arguments:"
        echo " - All: "$ARGS
        if [ -n "$DEBUG" ] && echo " - DEBUG: \"$DEBUG\""
        if [ -n "$CHECK_ONLY" ] && echo " - CHECK_ONLY: \"CHECK_ONLY\""
        if [ -n "$DIR_RAW" ] && echo " - DIR_RAW: \"$DIR_RAW\""
        if [ -n "$DIR_PROC" ] && echo " - DIR_PROC: \"$DIR_PROC\""
        if [ -n "$SLOW" ] && echo " - SLOW: \"$SLOW\""
    fi

    #
    #   Use case 01: only list the input files without performing any change 
    #   
    if [ -z $DIR_RAW ] && [ ! -z $CHECK_ONLY ] ; then
        echo "ERROR - "$COL_ERR"DIR_RAW"$COL_DFT" cannot be null!"
        usage
    fi
}


#
#   Checks if the file type is recognized/supported based on the file extension, and determines the new file extension
#
get_file_type()
{
    FILE_EXT=$(echo "${FILE##*.}" |  tr '[:upper:]' '[:lower:]' )
    FILE_EXT_NEW=

    case $FILE_EXT in
    "jpg")
        FILE_TYPE="jpeg"
        FILE_EXT_NEW="jpeg"
    ;;
    "jpeg")
        FILE_TYPE="jpeg"
    ;;
    "heic")
        FILE_TYPE="heic"
    ;;
    "mov")
        FILE_TYPE="qtff"
    ;;
    "mp4")
        FILE_TYPE="mp4"    
    ;;
    *)
        FILE_TYPE=
    ;;       
    esac

    if [ -z $FILE_EXT_NEW ] && FILE_EXT_NEW=$FILE_EXT
}



#
#   Retrieves the creation date from the file EXIF metadata
#
get_file_creationtime()
{
    FILE_CRTM=
    FILE_CRTM=$(exiftool $FILE | grep "Create Date" | head -n 1)
    FILE_CRTM=${FILE_CRTM/"Create Date"/}
    FILE_CRTM=${FILE_CRTM/":"/}
    FILE_CRTM=$(echo "${FILE_CRTM}" | sed -e 's/^[[:space:]]*//')

    if [ "$FILE_CRTM" = "0000:00:00 00:00:00" ]; then
        FILE_CRTM=
    fi
}



#
#   Retrieves the GPS coordinates from the file EXIF metadata
#
get_file_gps()
{
    FILE_GPS=
    FILE_GPS=$(exiftool $FILE | grep "GPS Position")
    FILE_GPS=${FILE_GPS/"GPS Position"/}
    FILE_GPS=${FILE_GPS/":"/}
    FILE_GPS=$(echo "${FILE_GPS}" | sed -e 's/^[[:space:]]*//')
}



#
#   Generates the new filename, based on the EXIF creation time
#
gen_file_name_new()
{
    FILE_NAME_NEW_PREFIX=
    [ "$PREFIX" ] && FILE_NAME_NEW_PREFIX=$PREFIX"_"
    
    if [ $FILE_CRTM ]; then
        FILE_NAME_NEW=$FILE_NAME_NEW_PREFIX$(echo "$FILE_CRTM" | tr -d ':' | tr ' ' '_')"."$FILE_EXT_NEW
    fi
}






main()
{  
    if [ -d "$DIR_RAW" ]
    then
        cd $DIR_RAW
    else
        echo $COL_ERR"The \""$DIR_RAW"\" directory does not exists."$COL_DFT" Bye!"
        exit 1
    fi


    echo "\n"
    for FILE in ./*
    do
        FILE_NAME=${FILE/".\/"/} 

        [ $SLOW ] && sleep $WAIT_LONG
        
        echo ""
        FILE_STATUS="- \""$FILE_NAME"\""
        echo -ne "$FILE_STATUS\r"
        FILE_STATUS_TMP=$FILE_STATUS
        

        #
        #   Checks the file type
        #
        get_file_type
        echo -ne "$FILE_STATUS\r"
        if [ -z $FILE_TYPE ]; then
            FILE_STATUS_TMP=$FILE_STATUS" "$COL_ERR"Unknown file type!"$COL_DFT$BLANK_LONG
            echo -ne "$FILE_STATUS_TMP\r"
            continue
        else
            FILE_STATUS_TMP=$FILE_STATUS" "$COL_OK"File type recognized"$COL_DFT$BLANK_LONG
            [ $DEBUG ] && echo -ne "$FILE_STATUS_TMP\r"
        fi
        [ $SLOW ] && sleep $WAIT_SHORT

        #
        #   Checks the file creation timestamp
        #
        get_file_creationtime
        FILE_STATUS_TMP=$FILE_STATUS
        echo -ne "$FILE_STATUS\r"
        if [ -z $FILE_CRTM ]; then
            FILE_STATUS_TMP=$FILE_STATUS" "$COL_ERR"Creation time not detected!"$COL_DFT$BLANK_LONG
            echo -ne "$FILE_STATUS_TMP\r"
            continue
        else
            FILE_STATUS_TMP=$FILE_STATUS" "$COL_OK"Creation time detected"$COL_DFT$BLANK_LONG
            echo -ne "$FILE_STATUS_TMP\r"
        fi
        [ $SLOW ] && sleep $WAIT_SHORT


        #
        #   Checks the file GPS coordinates
        #   
        get_file_gps
        FILE_STATUS_TMP=$FILE_STATUS
        echo -ne "$FILE_STATUS\r"
        if [ -z $FILE_GPS ]; then
            FILE_STATUS_TMP=$FILE_STATUS" "$COL_ERR"GPS not detected!"$COL_DFT$BLANK_LONG
            echo -ne "$FILE_STATUS_TMP\r"
            continue
        else
            FILE_STATUS_TMP=$FILE_STATUS" "$COL_OK"GPS detected"$COL_DFT$BLANK_LONG
            echo -ne "$FILE_STATUS_TMP\r"
        fi
        [ $SLOW ] && sleep $WAIT_SHORT


        #
        #   Generates the new filename
        #
        gen_file_name_new
        FILE_STATUS_TMP=$FILE_STATUS$BLANK_LONG
        [ "$FILE_NAME_NEW" ] && FILE_STATUS_TMP=$FILE_STATUS" ==> New filename: \""$FILE_NAME_NEW"\""; echo -ne "$FILE_STATUS_TMP\r"
        [ $SLOW ] && sleep $WAIT_SHORT

        #
        #   Performs the actual moving/copying of the files
        #
        [ -z "$DIR_PROC" ] && DIR_PROC=$DIR_RAW
        if [ -z $CHECK_ONLY ]; then
            cp -f $FILE $DIR_PROC$FILE_NAME_NEW
        fi


        #
        #   Changes the creation / last modified date file attributes
        #
        FILE_CRTM_FS=$(echo "${FILE_CRTM}" | sed -e 's/://' | sed -e 's/://' | sed -e 's/://' | sed -e 's/:/./' | sed -e 's/[[:space:]]//')
        if [ -z $CHECK_ONLY ]; then
            touch -a -m -t $FILE_CRTM_FS $DIR_PROC$FILE_NAME_NEW
        fi
    done
}




ARGS=($@)
read_args
check_args
main

