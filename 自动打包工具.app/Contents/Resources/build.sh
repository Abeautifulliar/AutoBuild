#!/bin/sh
currentShellPath=`pwd`
#.xcodeproj上级目录文件夹Name  如AAA.xcodeproj所在的文件夹为BBB 即BBB->AAA.xcodeproj 修改下面参数为BBB
projectFolderName="XXXXX"
#回到应用程序所在目录
cd ../../../
cd $projectFolderName/Shell

pwd

open -a Terminal.app
