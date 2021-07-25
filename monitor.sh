#!/usr/bin/env bash

# logging to stdout/err and file:
exec 3>&1 1>> /auto_transcode/logs/auto_transcode.log 2>&1


get_date () {
    date '+%Y-%m-%d.%T.%Z'
}


convert_mov () {
    local input_mov="${1}"
    local output_mov="${2}"
    #
    ffmpeg \
        -i "${input_mov}" \
        -c:v libx264 \
        -preset slow \
        -crf 22 \
        -c:a copy \
        "${filename}__transcoded.mkv" && \
    ffmpeg-normalize \
        "${filename}__transcoded.mkv" \
        -lrt 5 \
        -c:a mp3 \
        -b:a 192 \
        -o "${output_mov}" && \
    rm "${filename}__transcoded.mkv"
}


echo "$(get_date): Starting auto_transcode." | tee /dev/fd/3
echo "$(get_date): Waiting for input..." | tee /dev/fd/3


while true; do
    inotifywait --monitor /auto_transcode/input -e create -e moved_to | 
        while read path action file; do
            echo "$(get_date): Found ${file}." | tee /dev/fd/3
            if [[ "${file}" =~ \.(mov|MOV)$ ]]; then
                echo "$(get_date): Starting processing of: ${file}." | tee /dev/fd/3
                # determine output file name:
                filename=$(basename -- "$file")
                filename="${filename%.*}"
                output_file="${filename}.mkv"
                # transcode:
                nice -n 15 convert_mov "/auto_transcode/input/${file}" "${output_file}"
                # copy timestamp from original file:
                touch -r "/auto_transcode/input/${file}" "${output_file}"
                # move output:
                if [[ -f "/auto_transcode/output/${output_file}" ]]; then
                    echo "$(get_date): File ${output_file} already exists at output destination. Not moving." | tee /dev/fd/3
                else
                    echo "$(get_date): Moving ${output_file} to output." | tee /dev/fd/3
                    mv "${output_file}" /auto_transcode/output/
                fi
                # move original to archive:
                if [[ -f "/auto_transcode/archive/${file}" ]]; then
                    echo "$(get_date): File ${file} already exists at archive destination. Not moving." | tee /dev/fd/3
                else
                    echo "$(get_date): Archiving ${output_file}." | tee /dev/fd/3
                    mv "/auto_transcode/input/${file}" /auto_transcode/archive/
                fi
                echo "$(get_date): Done!" | tee /dev/fd/3
            fi
    done
done

