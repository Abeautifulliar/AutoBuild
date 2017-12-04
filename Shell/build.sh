#!/bin/sh
# 使用方法
# chmod +x build.sh；
# 计时
SECONDS=0
# 是否编译工作空间 (例:若是用Cocopods管理的.xcworkspace项目,赋值true; 用Xcode默认创建的.xcodeproj, 赋值false)
is_workspace="true"
# 指定项目的scheme名称
scheme_name="DEMO"
# 设置导出IPA包的名称 如DEMO导出包名为DEMO.ipa
export_iap_name="DEMO"
# 工程中Target对应的配置plist文件名称, Xcode默认的配置文件为Info.plist
info_plist_name="Info"
# 指定要打包编译的方式 : Release,Debug...$1
build_configuration=$1

echo "\n\033[32;1m************************* 您选择了 $build_configuration 模式 ************************* \033[0m\n"

# 导出ipa所需要的plist文件路径 (默认为AdHocExportOptionsPlist.plist)
ExportOptionsPlistPath="./shell/AdHocExportOptionsPlist.plist"
# 返回上一级目录,进入项目工程目录
cd ..
# 获取项目名称
project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`
# 获取版本号,内部版本号,bundleID
info_plist_path="$project_name/$info_plist_name.plist"
bundle_version=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $info_plist_path`
bundle_build_version=`/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" $info_plist_path`
bundle_identifier=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $info_plist_path`

# 强制删除旧的文件夹
rm -rf ./$scheme_name-IPA
# 指定输出ipa路径
export_path=./$scheme_name-IPA
# 指定输出归档文件地址
export_archive_path="$export_path/$scheme_name.xcarchive"
# 指定输出ipa地址
export_ipa_path="$export_path"
# 指定输出ipa名称 : scheme_name + bundle_version
suffix=`date +"%m%d%H%M"`
ipa_name="$scheme_name-v$bundle_version_$suffix"
version="$bundle_version.$suffix"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $version" "$info_plist_path"
# certifcate
CODE_SIGN_DISTRIBUTION="iPhone Distribution: USERNAME (Q2J5575DBC)"
CODE_SIGN_DEVELOPMENT="iPhone Developer: USERNAME (YXP3A9ACE8)"

method = $2
if test -n "$method"
then
if test "$method" = "1" ; then
ExportOptionsPlistPath="./shell/AdHocExportOptionsPlist.plist"
elif [ "$method" = "2" ]; then
ExportOptionsPlistPath="./shell/AppStoreExportOptionsPlist.plist"
elif [ "$method" = "3" ]; then
ExportOptionsPlistPath="./shell/EnterpriseExportOptionsPlist.plist"
elif [ "$method" = "4" ]; then
ExportOptionsPlistPath="./shell/DevelopmentExportOptionsPlist.plist"
else
echo "\n\033[31;1m************************* 您输入的参数无效!!! *************************\033[0m\n"
exit 1
fi
else
UPLOADFIR=false
fi


echo "\033[32m************************* 开始构建项目 ************************* \033[0m\n"
# 指定输出文件目录不存在则创建
if test -d "$export_path" ; then
echo $export_path
else
mkdir -pv $export_path
fi

if $is_workspace ; then
echo "\n\033[32m************************* 开始pod ************************* \033[0m"
pod install --verbose --no-repo-update
echo "\033[32m************************* pod完成 ************************* \033[0m\n"

if test $build_configuration="Debug" ; then
echo "\n\033[32;1m************************* 您选择了以 xcworkspace-Debug 模式打包 *************************\033[0m"
# step 1. Clean
xcodebuild clean -workspace $project_name.xcworkspace -scheme $scheme_name -configuration $build_configuration -alltargets
# step 2. Build
xcodebuild -workspace $project_name.xcworkspace -scheme $scheme_name -sdk iphoneos -configuration $build_configuration -CODE_SIGN_IDENTITY=$CODE_SIGN_DEVELOPMENT
# step 3. Archive
xcodebuild archive -workspace $project_name.xcworkspace -scheme $scheme_name -configuration $build_configuration -archivePath $export_archive_path
elif [ $build_configuration="Release" ]; then
echo "\n\033[32;1m************************* 您选择了以 xcworkspace-Release 模式打包 *************************\033[0m"
# step 1. Clean
xcodebuild clean -workspace $project_name.xcworkspace -scheme $scheme_name -configuration $build_configuration -alltargets
# step 2. Build
xcodebuild -workspace $project_name.xcworkspace -scheme $scheme_name -sdk iphoneos -configuration $build_configuration -CODE_SIGN_IDENTITY=$CODE_SIGN_DISTRIBUTION
# step 3. Archive
xcodebuild archive -workspace $project_name.xcworkspace -scheme $scheme_name -configuration $build_configuration -archivePath $export_archive_path
else
echo "\n\033[31;1m************************* 您定义的打包方式的不正确 😢 😢 😢 *************************\033[0m\n"
echo "Usage:\n"
echo "sh build.sh Debug"
echo "sh build.sh Release"
exit 1
fi
else
if test $build_configuration="Debug" ; then
echo "\n\033[32;1m************************* 您选择了以 xcodeproj-Debug 模式打包 *************************\033[0m"
# step 1. Clean
xcodebuild clean -project $project_name.xcodeproj -scheme $scheme_name -configuration $build_configuration -alltargets
# step 2. Build
xcodebuild -project $project_name.xcodeproj -scheme $scheme_name -sdk iphoneos -configuration $build_configuration -CODE_SIGN_IDENTITY=$CODE_SIGN_DEVELOPMENT
# step 3. Archive
xcodebuild archive -project $project_name.xcodeproj -scheme $scheme_name -configuration $build_configuration -archivePath $export_archive_path
elif [ $build_configuration="Release" ]; then
echo "\n\033[32;1m************************* 您选择了以 xcodeproj-Release 模式打包 *************************\033[0m"
# step 1. Clean
xcodebuild clean -project $project_name.xcodeproj -scheme $scheme_name -configuration $build_configuration -alltargets
# step 2. Build
xcodebuild -project $project_name.xcodeproj -scheme $scheme_name -sdk iphoneos -configuration $build_configuration -CODE_SIGN_IDENTITY=$CODE_SIGN_DISTRIBUTION
# step 3. Archive
xcodebuild archive -project $project_name.xcodeproj -scheme $scheme_name -configuration $build_configuration -archivePath $export_archive_path
else
echo "\n\033[31;1m************************* 您定义的打包方式的不正确 😢 😢 😢 *************************\033[0m\n"
echo "Usage:\n"
echo "sh build.sh Debug"
echo "sh build.sh Release"
exit 1
fi
fi

# 检查是否构建成功
# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if test -d "$export_archive_path" ; then
echo "\n\033[32;1m************************* 项目构建成功 🚀 🚀 🚀 *************************\033[0m\n"
else
echo "\n\033[31;1m************************* 项目构建失败 😢 😢 😢 *************************\033[0m\n"
exit 1
fi

echo "\033[32m************************* 开始导出ipa文件 ************************* \033[0m"
xcodebuild -exportArchive -archivePath $export_archive_path -exportPath $export_ipa_path -exportOptionsPlist $ExportOptionsPlistPath
# 修改ipa文件名称
mv $export_ipa_path/$scheme_name.ipa $export_ipa_path/$export_iap_name.ipa

# 检查文件是否存在
if test -f "$export_ipa_path/$export_iap_name.ipa" ; then
echo "\n\033[32;1m************************* 导出 $ipa_name.ipa 包成功 🎉 🎉 🎉 *************************\033[0m\n"
fi

#SFTP配置信息
#用户名
USER="XXXXX"
#密码
PASSWORD="XXXXX"
#待上传文件根目录
SRCDIR="$export_ipa_path/$export_iap_name.ipa"
#IP
IP=133.33.33.33
#端口
PORT=21

#修改folderName为上传的FTP目录
curl -u $USER:$PASSWORD -T $SRCDIR ftp://$IP/FOLDERNAME/FOLDERNAME/

exit 0


