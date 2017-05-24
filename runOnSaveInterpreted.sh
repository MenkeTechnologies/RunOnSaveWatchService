#!/usr/bin/env bash
#created by JAKOBMENKE --> Sat Jan 14 18:12:20 EST 2017 

#example usage = bash "$SCRIPTS/watchServiceFSWatchRustCompile.sh" . "untitled.rs"
DIR_WATCHING="$1"
file_to_watch="$2"
command="$3"

usage(){
#here doc for printing multiline
	cat <<\Endofmessage
usage:
	script $1=dir_to_watch $2=file_to_watch $3=command_to_run
Endofmessage
	printf "\E[0m"
}

if [[ $# < 3 ]]; then
	usage
	exit
fi


if [[ ${DIR_WATCHING:0:1} != '/' ]]; then
	#relative path
	CONVERTPATH="$(pwd $DIR_WATCHING)/$(basename $DIR_WATCHING)"
else
	#absolute path
	CONVERTPATH="$DIR_WATCHING"
fi

ABSOLUTE_PATH=$(cd ${CONVERTPATH} && pwd)

if [[ ! -d $ABSOLUTE_PATH ]]; then
	echo "Path doesn't exist."
	exit 1
fi

absoluteFilePath=$ABSOLUTE_PATH/`basename $file_to_watch`

if [[ ! -f "$absoluteFilePath" ]]; then
	echo "File doesn't exist."
	exit 1
fi

which "$command" >/dev/null
if [[ $? != 0 ]]; then
	echo "Command to run doesn't exist."
	exit 1
fi


echo -e "Watching for changes of file \e[1m'`basename $absoluteFilePath`'\e[0m in \e[1m'$ABSOLUTE_PATH'\e[0m"
echo -e "Executing with \e[1m'`which $command`'\e[0m"

while read -d "" event; do
	
	fileName=`basename $event`
	watchingFile=`basename $file_to_watch`

	#ignored the intermediate files that are changing
	if [[ $fileName == $watchingFile ]]; then
		clear
		eval "$command $file_to_watch"
			
		# echo "match @ $fileName"
	else
		:
		# echo "no match @ $fileName"
	fi

	

done < <(fswatch -r -0 -E "$DIR_WATCHING" -e "/\.." )
