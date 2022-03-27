#!/bin/zsh

#	requires exif in order to work




COL_ERR="\033[0;31m" # error output 
COL_WRN="\033[0;33m" # warning output
COL_DFT="\033[0m" # default output
WAIT_SHORT=1
WAIT_LONG=1.5




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
#   Performs various checks on the file defined by the $FILE variable - e.g. if the file type is recognized/supported or not
#
get_file_type()
{
    FILE_EXT=$(echo "${FILE##*.}" |  tr '[:upper:]' '[:lower:]' )

    #
    #   Checks the file type based on the file extensions
    #
    case $FILE_EXT in
    "jpg")
        FILE_TYPE="jpeg"
    ;;
    "jpeg")
        FILE_TYPE="jpeg"
    ;;
    "heic")
        FILE_TYPE="jpeg"
    ;;
    esac


}



get_file_metadata()
{
    #
    #   Retrieves the GPS coordinates from the EXIF metadata
    #
    FILE_EXIF_GPS=$(exiftool $FILE | grep "GPS Position")
    FILE_EXIF_GPS=${FILE_EXIF_GPS/"GPS Position"/}
    FILE_EXIF_GPS=${FILE_EXIF_GPS/":"/}
    FILE_EXIF_GPS=$(echo "${FILE_EXIF_GPS}" | sed -e 's/^[[:space:]]*//')

    FILE_EXIF_CREATETIME=$(exiftool $FILE | grep "Create Date" | head -n 1)
    FILE_EXIF_CREATETIME=${FILE_EXIF_CREATETIME/"Create Date"/}
    FILE_EXIF_CREATETIME=${FILE_EXIF_CREATETIME/":"/}
    FILE_EXIF_CREATETIME=$(echo "${FILE_EXIF_CREATETIME}" | sed -e 's/^[[:space:]]*//')
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

    echo "FAST_OUTPUT:"$FAST_OUTPUT
    echo "DEBUG:"$DEBUG

    #
    #   TEMPORARY, to be moved into check_file()
    #
    for FILE in ./*
    do
        [ -z "$FAST_OUTPUT" ] && sleep $WAIT_LONG
        echo "\n- File: \""$FILE"\""
        get_file_type
        get_file_metadata


        if [ -z $FILE_TYPE ]; then
            echo "  -> "$COL_ERR"file type not recognized!"$COL_DFT
        else
            echo "  -> Type: "$FILE_TYPE
        fi
        [ -z "$FAST_OUTPUT" ] && sleep $WAIT_SHORT

        
        if [ -z $FILE_EXIF_GPS ]; then
            echo "  -> "$COL_ERR"No GPS Coordinates detected in the file metadata!"$COL_DFT
        else
            echo "  -> EXIF GPS: "$FILE_EXIF_GPS
        fi
        [ -z "$FAST_OUTPUT" ] && sleep $WAIT_SHORT


        if [ -z $FILE_EXIF_CREATETIME ]; then
            echo "  -> "$COL_ERR"No creation date detected in the file metadata!"$COL_DFT
        else
            echo "  -> EXIF Create Time: "$FILE_EXIF_CREATETIME
        fi
        [ -z "$FAST_OUTPUT" ] && sleep $WAIT_SHORT
    done


    echo $COL_WRN"test WRN"$COL_DFT
}




ARGS=($@)
read_args
check_args
main

