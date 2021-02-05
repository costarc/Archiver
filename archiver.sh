#/usr/bin/sh
# ==========================================================================
# archiver.sh                                                               #
# Version: 0.1 - 05/02/2021                                              #
#  - Copy all files every time (no check if file contents is the same)     #
# ==========================================================================

Version="0.1"
MyFileExt="dat ldb log json txt exe md"

if [[ $# != 2 ]];then
    echo "syntax:"
    echo "archive <source path> <destinatin path>"
    exit 1
fi

fileList="/tmp/fileList.tmp"
srcpath=$1
destpath=$2

echo ""
echo "Archiver version $Version"
echo "Preparing archive data"
echo "Will copy: $srcpath --> $destpath"
echo ""

find $srcpath | sort > $fileList
#IFS=$'\n' read -d '' -r -a files < $fileList

echo "Creating backup directory structure..."
while read -r file
do
  thisExt=$(echo $file|cut -f2 -d".")
  if [[ $MyFileExt != *"$thisExt"* ]];then
    if [[ -d "$file" ]];then
      mkdir -p "$destpath/$file"
      echo "Created:$destpath/$file"
    fi
  fi
done<$fileList

echo "Creating compressed copies of the files in $destpath..."
while read -r file
do
  if [[ -f "$file" && -d "$destpath/$file" ]];then
  	echo "Error: A directory exists in destination path with same name as file: $file"
  	exit 1
  elif [[ -f "$file" ]];then
    tar -cvf - "$file" | gzip -9 -c > $"$destpath/$file.tgz"
  # This is a workaround for a bug on Mac OS X
  # Some files are detected as directory, and the script created the destination directory
  else
  	thisExt=$(echo $file|cut -f2 -d".")
    if [[ *"$thisExt"* == "$MyFileExt" ]];then
      tar -cvf - "$file" | gzip -9 -c > $"$destpath/$file.tgz"
    fi
  fi
done<$fileList

rm $fileList
