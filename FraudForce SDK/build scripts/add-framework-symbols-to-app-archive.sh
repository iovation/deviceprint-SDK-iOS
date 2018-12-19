
# Set script to exit immediately if any commands fail.
set -e

# Redirect stdout and stderr to a (unique) log file, since Xcode does not handle or display output 
# from scheme-based scripts.
LOG_FILE_PATH="/var/tmp/add-framework-symbols-to-app-archive_`date +%s`.log"
exec > "${LOG_FILE_PATH}" 2>&1

echo "Adding framework bcsymbolmap files to the Xcode archive for target ${TARGET_NAME}."

BUILD_FRAMEWORKS_DIR="${PROJECT_DIR}/Frameworks-build"
INPUT_BCSYMBOLMAP_DIR="${PROJECT_DIR}/Frameworks-bcsymbolmap"
OUTPUT_BCSYMBOLMAP_DIR="${ARCHIVE_PATH}/BCSymbolMaps"

if [ ! -d "$INPUT_BCSYMBOLMAP_DIR" ]; then
	echo "Script input directory (${INPUT_BCSYMBOLMAP_DIR}) does not exist. Exiting"
	exit 0
fi
if [ ! -d "$OUTPUT_BCSYMBOLMAP_DIR" ]; then
	echo "Archive output directory (${OUTPUT_BCSYMBOLMAP_DIR}) does not exist. Exiting"
	exit 0
fi

# Loop over the build-frameworks directory to discover the UUID's of the architecture slices of every 
# framework included in the app, and then process (copy into archive) the matching bcsymbolmap files.
for BUILD_FRAMEWORK_PATH in "$(find "${BUILD_FRAMEWORKS_DIR}" -name '*.framework' -type d)"; do
	# This name (FRAMEWORK_NAME) includes the ".framework" extension.
	FRAMEWORK_NAME=$(basename "${BUILD_FRAMEWORK_PATH}")
	
	# Determine the uuids of the architectures of the executable file within the framework bundle.
	FRAMEWORK_EXECUTABLE_NAME=$(defaults read "${BUILD_FRAMEWORK_PATH}/Info.plist" CFBundleExecutable)
	FRAMEWORK_EXECUTABLE_PATH="${BUILD_FRAMEWORK_PATH}/${FRAMEWORK_EXECUTABLE_NAME}"
	EXECUTABLE_ARCHS="$(lipo -info "${FRAMEWORK_EXECUTABLE_PATH}" | rev | cut -d ':' -f1 | rev)"
	FRAMEWORK_SLICE_UUIDS="$(xcrun dwarfdump --uuid "${FRAMEWORK_EXECUTABLE_PATH}" | awk '{ print $2 }' | tr '\n' ' ')"
	echo "${FRAMEWORK_NAME} executable (${FRAMEWORK_EXECUTABLE_NAME}) contains arch slices (${EXECUTABLE_ARCHS}) with uuids (${FRAMEWORK_SLICE_UUIDS})"
	
	for ONE_ARCH_SLICE in $FRAMEWORK_SLICE_UUIDS; do
		SOURCE_BCSYMBOLMAP_PATH="${INPUT_BCSYMBOLMAP_DIR}/${ONE_ARCH_SLICE}.bcsymbolmap"
		if [ -f "$SOURCE_BCSYMBOLMAP_PATH" ]; then
			echo "Copying ${FRAMEWORK_NAME} slice (${ONE_ARCH_SLICE}) into app archive (${OUTPUT_BCSYMBOLMAP_DIR})"
			cp -a "${SOURCE_BCSYMBOLMAP_PATH}" "${OUTPUT_BCSYMBOLMAP_DIR}/."
		else
			echo "${FRAMEWORK_NAME} slice (${ONE_ARCH_SLICE}) missing from source dir (${INPUT_BCSYMBOLMAP_DIR})"
		fi
	done
done
