#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

BASE=${1}

LIST=""

while read workspace;
do
  yarn workspace ${workspace} build --base "/${BASE}/${workspace}/" -o "${SCRIPT_DIR}/dist/${workspace}"

  title=`awk -F ': ' '/^title:/ {print $2; exit}' "src/${workspace}/slides.md"`

  LIST="${LIST}<li><a href=\""/${BASE}/${workspace}/"\">${title}</a></li>"
done < <(find src -maxdepth 1 -type d -name "[0-9]*" | sed 's/src\///')

cp "${SCRIPT_DIR}/template.html" "${SCRIPT_DIR}/dist/index.html"

sed -i "s+##REPLACE_ME##+${LIST}+" "${SCRIPT_DIR}/dist/index.html"
