#!/bin/zsh

#	requires exif in order to work




COL_ERR="\033[0;31m" # error output
COL_OK="\033[0;32m" # ok output 
COL_WRN="\033[0;33m" # warning output
COL_DFT="\033[0m" # default output
WAIT_SHORT=0.5
WAIT_LONG=0.75




#
#   Informs the user about how to call the script
#
usage()
{
	echo "Usage: "$COL_WRN"fmmt [--src_dir=|-sd]=<source_directory> [--tgt_dir=|-td]=<target_directory> [--prefix=|-p]=<prefix> [--check-only|-co [--fast-output|-fo]"$COL_DFT
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

            -fo|--fast-output)
            FAST_OUTPUT="y"
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



#
#   Checks input parameters' combination validity
#
check_args()
{
    if [ ! -z $DEBUG ]; then
        echo "Arguments:"
        echo " - All: "$ARGS
        if [ -n "$DEBUG" ] && echo " - DEBUG: \"$DEBUG\""
        if [ -n "$CHECK_ONLY" ] && echo " - CHECK_ONLY: \"CHECK_ONLY\""
        if [ -n "$DIR_SRC" ] && echo " - DIR_SRC: \"$DIR_SRC\""
        if [ -n "$FAST_OUTPUT" ] && echo " - FAST_OUTPUT: \"$FAST_OUTPUT\""
    fi

    #
    #   Use case 01: only list the input files without performing any change 
    #   
    if [ -z $DIR_SRC ] && [ ! -z $CHECK_ONLY ] ; then
        echo "ERROR - "$COL_ERR"DIR_SRC"$COL_DFT" cannot be null!"
        usage
    fi
}


#
#   Checks if the file type is recognized/supported based on the file extension, and determines the new file extension
#
get_file_type()
{
    FILE_EXT=$(echo "${FILE##*.}" |  tr '[:upper:]' '[:lower:]' )

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
    [ ! -z "$PREFIX" ] && FILE_NAME_NEW_PREFIX=$PREFIX"_"
    
    if [ ! -z $FILE_CRTM ]; then
        FILE_NAME_NEW=$FILE_NAME_NEW_PREFIX$(echo "$FILE_CRTM" | tr -d ':' | tr ' ' '_')"."$FILE_EXT_NEW
    fi
}






main()
{  
    if [ -d "$DIR_SRC" ]
    then
        cd $DIR_SRC
    else
        echo $COL_ERR"The \""$DIR_SRC"\" directory does not exists."$COL_DFT" Bye!"
        exit 1
    fi


    #
    #   TEMPORARY, to be moved into check_file()
    #
    for FILE in ./*
    do
        FILE_NAME=${FILE/".\/"/} 

        [ -z "$FAST_OUTPUT" ] && sleep $WAIT_LONG
        echo "\n- File: \""$FILE_NAME"\""
        get_file_type
        get_file_creationtime
        get_file_gps
        


        if [ -z $FILE_TYPE ]; then
            echo "  -> "$COL_ERR"file type not recognized!"$COL_DFT 
            continue
        else
            echo "  -> Type: "$FILE_TYPE
        fi
        [ -z "$FAST_OUTPUT" ] && sleep $WAIT_SHORT

        
        if [ -z $FILE_CRTM ]; then
            echo "  -> "$COL_ERR"No creation date detected within the file metadata!"$COL_DFT
            continue
        else
            echo "  -> EXIF creation time: "$COL_OK$FILE_CRTM$COL_DFT
        fi
        [ -z "$FAST_OUTPUT" ] && sleep $WAIT_SHORT


        if [ -z $FILE_GPS ]; then
            echo "  -> "$COL_WRN"No GPS coordinates detected within the file metadata!"$COL_DFT
        else
            echo "  -> EXIF GPS: "$COL_OK$FILE_GPS$COL_DFT
        fi
        [ -z "$FAST_OUTPUT" ] && sleep $WAIT_SHORT


        gen_file_name_new
        [ ! -z "$FILE_NAME_NEW" ] && echo "  => New filename: "$FILE_NAME_NEW
        [ -z "$FAST_OUTPUT" ] && sleep $WAIT_SHORT
    done
}




ARGS=($@)
read_args
check_args
main

