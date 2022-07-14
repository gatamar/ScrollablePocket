BUILD_FOLDER="build-xcframework"
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

cp -R "${BUILD_FOLDER}"/scrollable_pocket.xcframework scrollable_pocket.xcframework
rm -rf "${BUILD_FOLDER}"
