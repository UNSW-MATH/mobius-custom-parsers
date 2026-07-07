#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
echo "Usage: $(basename "$0") <previewer-expected-outputs-file>" >&2
exit 1
fi

input_file=$1
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$script_dir"

if [[ "$input_file" != */* && -f "testing/$input_file" ]]; then
    input_file="testing/$input_file"
fi

maple_input_file=${input_file//\\/\\\\}
maple_input_file=${maple_input_file//\"/\\\"}

printf 'read("ComparePreviewerExpectedOutputs.mpl"):\nComparePreviewerExpectedOutputs("%s"):\n' "$maple_input_file" | maple -q
