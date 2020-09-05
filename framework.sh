# Prints given blocks of text side by side
# $1 - left column
# $2 - right column
print_columns() {
    paste <(echo -e "${CA}$1${1:+:}${CN}") <(echo -e "$2")
}

# Prints given text n times
# $1 - text to print
# $2 - how many times to print
print_n() {
    local out=""
    for ((i=0; i<$2; i++)); do
        out+="$1"
    done
    echo "$out"
}

# Prints bar divided in two parts by given percentage
# $1 - bar width
# $2 - percentage
# $3 - label
print_bar() {
    local bar_width=$(($1 - 2 - ${#3}))
    local used_width=$(($2 * $bar_width / 100))
    local free_width=$(($bar_width - $used_width))
    local out=""
    out+="$3["
    out+="${CE}"
    out+=$(print_n "=" $used_width)
    out+="${CO}"
    out+=$(print_n "=" $free_width)
    out+="${CN}"
    out+="]"
    echo "$out"
}

# Prints text with color according to given value and two thresholds
# $1 - text to print
# $2 - current value
# $3 - warning threshold
# $4 - error threshold
print_color() {
    local out=""
    if (( $(bc -l <<< "$2 < $3") )); then
        out+="${CO}"
    elif (( $(bc -l <<< "$2 >= $3 && $2 < $4") )); then
        out+="${CW}"
    else
        out+="${CE}"
    fi
    out+="$1${CN}"
    echo "$out"
}

# Prints text as either acitve or inactive
# $1 - text to print
# $2 - literal "active" or "inactive"
print_status() {
    local out=""
    if [ "$2" == "active" ]; then
        out+="${CO}▲${CN}"
    else
        out+="${CE}▼${CN}"
    fi
    out+=" $1${CN}"
    echo "$out"
}

# Prints comma-separated arguments wrapped to the given width
# $1 - width to wrap to
# $2, $3, ... - values to print
print_wrap() {
    local width=$1
    shift
    local out=""
    local line_length=0
    for element in "$@"; do
        element="$element,"
        local visible_elelement="$(strip_ansi "$element")"
        local future_length=$(($line_length + ${#visible_elelement}))
        if [ $line_length -ne 0 ] && [ $future_length -gt $width ]; then
            out+="\n"
            line_length=0
        fi
        out+="$element "
        line_length=$(($line_length + ${#visible_elelement}))
    done
    echo "${out::-2}"
}

# Strips ANSI color codes from given string
# $1 - text to strip
strip_ansi() {
    echo "$(echo -e "$1" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")"
}
