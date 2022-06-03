INDEX_URL="https://hub.fastgit.xyz/Amemei/Amemei.github.io/raw/master/index.md"

curl -sL "$INDEX_URL" | sed -En 's|^\* +\[([^.]+)\]\(.+github.io/([^/]+).+$|\1\t\2|p' | awk -F '\t' 'BEGIN {
    printf "<manifest>\n  <remote review=\"https://github.com/Amemei/\" />\n";
}

{
    printf "  <!-- %s -->\n  <project path=\"%s\" name=\"%s\" />\n", $1, $2, $2;
}

END {
    printf "</manifest>\n";
}'
