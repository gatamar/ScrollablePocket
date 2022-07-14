BUILD_FOLDER="build-xcframework"
BUILD_VERSION="0.1.0"

mkdir "${BUILD_FOLDER}"

# "archive" for simulator
xcodebuild archive \
-scheme scrollable-pocket \
-archivePath "${BUILD_FOLDER}"/scrollable-pocket-iphonesimulator.xcarchive \
-sdk iphonesimulator \
SKIP_INSTALL=NO

# "archive" for real device
xcodebuild archive \
-scheme scrollable-pocket \
-archivePath "${BUILD_FOLDER}"/scrollable-pocket-iphoneos.xcarchive \
-sdk iphoneos \
SKIP_INSTALL=NO

# "glue" both archives into "xcframework"; NOTE that "scrollable-pocket" target name transforms into "scrollable_pocket" framework name and it sucks. 
xcodebuild -create-xcframework \
-framework "${BUILD_FOLDER}"/scrollable-pocket-iphoneos.xcarchive/Products/Library/Frameworks/scrollable_pocket.framework \
-framework "${BUILD_FOLDER}"/scrollable-pocket-iphonesimulator.xcarchive/Products/Library/Frameworks/scrollable_pocket.framework \
-output "${BUILD_FOLDER}"/scrollable_pocket.xcframework

# copy a generated framework from build folder to src folder
cp -R "${BUILD_FOLDER}"/scrollable_pocket.xcframework scrollable_pocket.xcframework

# remove build folder
rm -rf "${BUILD_FOLDER}"

# compress a generated framework for the Github release
# zip -r -X "scrollable_pocket.xcframework-${BUILD_VERSION}.zip" "scrollable_pocket.xcframework"
