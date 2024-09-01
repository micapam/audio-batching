#!/usr/bin/env bash

usage() {
  cat << EOF
Convert FLACs to other formats.
Usage: $0 [options]

-d    Directory containing FLAC files. 
      Will recurse into subdirectories.
      If absent, defaults to current directory.

-f    Format into which to convert FLACS. Valid values:
        aiff  - Audio Interchange File Format
        mp3   - MPEG Audio Layer III (320 kbit/s)
        wav   - Waveform audio
      If absent, defaults to mp3.

-h    Display help text.

-v    Verbose mode: show names of source files before convering them.

Example: $0 -d ~/Downloads -f wav -v
EOF
  exit 0
}

[ $# -eq 0 ] && usage

DIR=`pwd`
FORMAT=mp3
VERBOSE=0

while getopts "d:f:hv" arg; do
  case "${arg}" in
    d)
      DIR=$OPTARG
      ;;
    f)
      if [[ "$OPTARG" =~ ^(aiff|mp3|wav)$ ]]; then
        FORMAT=$OPTARG
      else
        echo "Invalid format: $OPTARG (must be one of aiff, mp3 or wav)"
        exit 1
      fi
      ;;
    h)
      usage
      ;;
    v)
      VERBOSE=1
      ;;
  esac
done
shift $((OPTIND-1))

find -E $DIR -type f -iregex '.*\.flac$' -print0 | while read -d $'\0' INPUT
do
  if [ $VERBOSE == 1 ]
  then
    echo "Processing: $INPUT"
  fi

  OUTPUT=${INPUT%.*}.$FORMAT
  
  if [ $FORMAT == "mp3" ]
  then
    sox "$INPUT" -C 320 "$OUTPUT"
  else
    sox "$INPUT" "$OUTPUT"
  fi

  echo "Processed:  $OUTPUT"
done
