#!/bin/sh

remove_control_file_by_path() {
    awk -v FILE_PATH="$1" 'BEGIN {
        path = FILE_PATH
        gsub(/[\\\/]+/, "/", path)
        for (pos = length(FILE_PATH); pos > 0;) {
            temp = sprintf("%s.aria2", path)
            gsub(/\x22/, "\\\x22", temp)
            cmd = sprintf("test -f \x22%s\x22", temp)
            # print(cmd)
            if (system(cmd) == 0) {
                cmd = sprintf("rm \x22%s\x22", temp)
                # print(cmd)
                system(cmd)
                break
            }
            while (substr(path, pos, 1) != "/" && pos > 0) pos--
            if (pos > 0) {
                pos-- # '/'
                path = substr(path, 1, pos)
            }
        }
                
    }'
}

# $1 - GID
# $2 - Number of files
# $3 - First file path
remove_control_file_by_path "$3"
