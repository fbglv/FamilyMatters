#!/bin/zsh

#	requires exif in order to work




COL_ERR="\033[0;31m"
COL_WRN="\033[0;33m"
COL_DFT="\033[0m"



#
#   Informs the user about how to call the script
#
usage()
{
	# [ ! -z "$ARG" ] && echo "Unknown option: "$COL_ERR"${ARG%%=*}"$COL_DFT
	echo "Usage: "$COL_WRN"fmmt [--src_dir=|-sd]=<source_directory> [--tgt_dir=|-td]=<target_directory> [--prefix=|-p]=<prefix> [--check-only|-co]"$COL_DFT
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
#   Once the input arguments have been parsed, their combination validity is checked
#
check_args()
{
    if [ ! -z $DEBUG ]; then
        echo "Arguments:"
        echo " - DEBUG: \"$DEBUG\""
        echo " - CHECK_ONLY: \"$CHECK_ONLY\""
        echo " - DIR_SRC: \"$DIR_SRC\""
        echo " - All: "$ARGS
    fi

    #
    #   Use case 01: only list the input files without performing any change 
    #   
    if [ -z $DIR_SRC ] && [ ! -z $CHECK_ONLY ] ; then
        echo "ERROR - "$COL_ERR"DIR_SRC"$COL_DFT" cannot be null!"
        usage
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

    for FILE in ./*
    do
        echo "file: "$FILE
    done
}




ARGS=($@)
read_args
check_args
main

