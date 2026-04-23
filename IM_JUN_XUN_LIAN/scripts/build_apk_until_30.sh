#!/usr/bin/env bash
set -euo pipefail

TARGET_COUNT="${TARGET_COUNT:-30}"
BUILD_NUMBER_BASE="${BUILD_NUMBER_BASE:-100000}"
FLUTTER_CMD="${FLUTTER_CMD:-flutter}"
OUTPUT_DIR="${OUTPUT_DIR:-build/batch-apk}"

if ! [[ "$TARGET_COUNT" =~ ^[0-9]+$ ]]; then
  echo "TARGET_COUNT must be a non-negative integer" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
mkdir -p build/symbols

CHECKSUM_FILE="$OUTPUT_DIR/checksums.txt"
if [ ! -f "$CHECKSUM_FILE" ]; then
  cat > "$CHECKSUM_FILE" <<'EOF'
file,bytes,md5,sha256
EOF
fi

count_apk() {
  find "$OUTPUT_DIR" -maxdepth 1 -type f -name '*.apk' | wc -l | tr -d ' '
}

current_count="$(count_apk)"
echo "Current APK count: $current_count, target: $TARGET_COUNT"

if [ "$current_count" -ge "$TARGET_COUNT" ]; then
  echo "Already reached target count, nothing to build."
  exit 0
fi

"$FLUTTER_CMD" pub get

while [ "$current_count" -lt "$TARGET_COUNT" ]; do
  index=$((current_count + 1))
  build_number=$((BUILD_NUMBER_BASE + index))

  echo "[${index}/${TARGET_COUNT}] Building release APK with build-number=${build_number}"
  "$FLUTTER_CMD" build apk --release \
    --build-number "$build_number" \
    --obfuscate \
    --split-debug-info="build/symbols/${build_number}"

  latest_apk="$(ls -t build/app/outputs/flutter-apk/*.apk | head -n 1)"
  if [ -z "${latest_apk:-}" ] || [ ! -f "$latest_apk" ]; then
    echo "No APK produced in build/app/outputs/flutter-apk" >&2
    exit 1
  fi

  target_apk="$OUTPUT_DIR/batch_${build_number}.apk"
  cp "$latest_apk" "$target_apk"
  echo "Saved: $target_apk"

  apk_bytes="$(wc -c < "$target_apk" | tr -d ' ')"
  apk_md5="$(md5 -q "$target_apk")"
  apk_sha256="$(shasum -a 256 "$target_apk" | awk '{print $1}')"
  echo "$(basename "$target_apk"),$apk_bytes,$apk_md5,$apk_sha256" >> "$CHECKSUM_FILE"

  current_count="$(count_apk)"
  echo "Current APK count: $current_count"
done

echo "Done. Final APK count: $current_count"
echo "Checksum summary: $CHECKSUM_FILE"
