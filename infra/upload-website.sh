#!/bin/bash
upload() {
  curl -H "Authorization: Bearer $NEOCITIES_KEY" \
    -F "${1#*/}=@$1" "https://neocities.org/api/upload"
}
delete() {
  eval curl -H "\"Authorization: Bearer $NEOCITIES_KEY\"" \
    $1 \
    "\"https://neocities.org/api/delete\""
}
getFiles() {
  files=$(curl -H "Authorization: Bearer $NEOCITIES_KEY" "https://neocities.org/api/list")
  paths=$(echo "$files" | jq -r '.files[].path') # jq to extract paths

  string=""
  while IFS= read -r file; do
    if [[ "$file" == "index.html" ]]; then
      continue
    fi
    string="$string -d \"filenames[]=$file\""
  done <<<"$paths"
  echo "$string"
}

clearProject() {
  echo "fetching files..."
  files=$(getFiles)
  echo "deleting files..."
  delete "$files"
}

run_files() {
  echo "uploading new files..."
  for file in "$1"/*; do
    if [ -d "$file" ]; then
      run_files $file
    else
      echo $file
      upload $file
    fi
  done
}

clearProject
run_files dist
