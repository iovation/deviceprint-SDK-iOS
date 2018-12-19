
# Set script to exit immediately if any commands fail.
set -e

echo "Creating slim frameworks for VALID_ARCHS: $VALID_ARCHS"

INPUT_FRAMEWORKS_DIR="${PROJECT_DIR}/Frameworks-universal"
OUTPUT_FRAMEWORKS_DIR="${PROJECT_DIR}/Frameworks-build"

if [ ! -d "$INPUT_FRAMEWORKS_DIR" ]; then
	echo "Script input directory (${INPUT_FRAMEWORKS_DIR}) does not exist. Exiting" 
	exit 0
fi

# Loop over the input-dir and examine any item that is a directory whose name ends in ".framework".
for UNIVERSAL_FRAMEWORK in "$(find "${INPUT_FRAMEWORKS_DIR}" -name '*.framework' -type d)"; do
	# This name (FRAMEWORK_NAME) includes the ".framework" extension.
	FRAMEWORK_NAME=$(basename "${UNIVERSAL_FRAMEWORK}")
	OUTPUT_FRAMEWORK_PATH="${OUTPUT_FRAMEWORKS_DIR}/${FRAMEWORK_NAME}"
	# Prepare the output location for the universal framework being processed.
	if [ -d "$OUTPUT_FRAMEWORK_PATH" ]; then
		echo "Removing preexisting slim/build framework: ${OUTPUT_FRAMEWORK_PATH}"
		rm -rf "${OUTPUT_FRAMEWORK_DIR}"
	elif [ ! -d "$OUTPUT_FRAMEWORKS_DIR" ]; then
		echo "Making framework build dir: ${OUTPUT_FRAMEWORKS_DIR}"
		mkdir "${OUTPUT_FRAMEWORKS_DIR}"
	fi
	
	# Start by simply copying the framework from the input/universal location. It is possible that no
	# slimming of the framework is needed (if the framework is, unexpectedly, not universal), which will
	# not adversely affect this script.
	echo "Copying universal framework (${UNIVERSAL_FRAMEWORK}) into build directory (${OUTPUT_FRAMEWORKS_DIR})"
	cp -a "${UNIVERSAL_FRAMEWORK}" "${OUTPUT_FRAMEWORKS_DIR}/."	
	
	# Determine the architectures of the executable file within the framework bundle.
	FRAMEWORK_EXECUTABLE_NAME=$(defaults read "${OUTPUT_FRAMEWORK_PATH}/Info.plist" CFBundleExecutable)
	FRAMEWORK_EXECUTABLE_PATH="${OUTPUT_FRAMEWORK_PATH}/${FRAMEWORK_EXECUTABLE_NAME}"
	EXECUTABLE_ARCHS="$(lipo -info "${FRAMEWORK_EXECUTABLE_PATH}" | rev | cut -d ':' -f1 | rev)"
	echo "Framework (${FRAMEWORK_NAME}) executable (${FRAMEWORK_EXECUTABLE_NAME}) contains archs: ${EXECUTABLE_ARCHS}"
	
	for ONE_ARCH in $EXECUTABLE_ARCHS; do
		if ! [[ "${VALID_ARCHS}" == *"$ONE_ARCH"* ]]; then
			# Strip non-valid architecture in-place (from the framework copied into the output directory).
			lipo -remove "$ONE_ARCH" -output "$FRAMEWORK_EXECUTABLE_PATH" "$FRAMEWORK_EXECUTABLE_PATH" || exit 1
			echo "Stripped arch ${ONE_ARCH} from slim/build version of ${FRAMEWORK_NAME}"
		fi
	done
done
