#!/bin/bash

cd "$(dirname "$0")"
cd ..

update_syukujitu_swift() {
    local filename='Sources/JapanHolidays/syukujitsu.swift'

    curl -o $filename -L https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv

    iconv -f Shift_JIS -t UTF-8 $filename | tr -d '\r' > $filename.tmp
    mv $filename.tmp $filename

    sed -i'.bak' '1d' $filename

    sed -i'.bak' 's/^/"/' $filename
    sed -i'.bak' 's/,/": "/' $filename
    sed -i'.bak' 's/$/",/' $filename

    sed -i'.bak' '1i\
let holidays = [
' $filename
    sed -i'.bak' '$a\
]
' $filename

    rm $filename.bak
}

update_readme() {
    local old_year=$1
    local new_year=$2
    local filename="README.md"

    sed -i'.bak' "s/初期状態で $old_year 年/初期状態で $new_year 年/" $filename

    rm $filename.bak
}

filename='Sources/JapanHolidays/syukujitsu.swift'

old_year=$(grep '": "' $filename | tail -n 1 | awk '{print $1}' | sed 's/"//g' | cut -d '/' -f 1)

update_syukujitu_swift

new_year=$(grep '": "' $filename | tail -n 1 | awk '{print $1}' | sed 's/"//g' | cut -d '/' -f 1)

update_readme $old_year $new_year
