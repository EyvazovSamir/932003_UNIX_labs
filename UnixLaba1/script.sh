#!/bin/bash
source=$1

if [ -z "$source" ]; then
  echo Please provide a filename as an argument. Example: $0 main.cpp
  exit 1
fi

output_file="$(grep -i "Output:" "$source" | cut -d ':' -f2- | tr -d '[:space:]/')"

if [ -z "$output_file" ]; then
  echo Output file name is empty or not provided.
  exit 1
fi

temp_direct=$(mktemp -d)

cleanup(){
	echo Delete temp direct: $temp_direct
	rm -rf $temp_direct
}

trap cleanup EXIT SIGINT SIGTERM


cp "$source" "$temp_direct"/

current_direct=$(pwd)

cd "$temp_direct"
extension="${source##*.}"

if [ "$extension" = "c" ]
then
	gcc "$source" -o "$output_file"
elif [ "$extension" = "cpp" ]
then
	g++ "$source" -o "$output_file"  
else
	echo "File type not supported"
	exit 1
fi

if [ $? -ne 0 ]; then
  echo Error moving output file
  cd "$current_direct"
  exit 1
fi

mv "$output_file" "$current_direct"
cd "$current_direct"
echo Building success: "$output_file"

exit 0

