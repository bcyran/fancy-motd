# shellcheck shell=bash

# Source the config
# shellcheck source=config.sh.example
source "${CONFIG_PATH}"

# Provide default values for obligatory settings
# Colors
CA="${CA:-\e[34m}" # Accent
CO="${CO:-\e[32m}" # Ok
CW="${CW:-\e[33m}" # Warning
CE="${CE:-\e[31m}" # Error
CN="${CN:-\e[0m}"  # None

# Max width used for components in second column
WIDTH="${WIDTH:-50}"

# Prints given blocks of text side by side
# $1 - left column
# $2 - right column
print_columns() {
    [[ -z $2 ]] && return
    paste <(echo -e "${CA}$1${1:+:}${CN}") <(echo -e "$2")
}

# Prints given text n times
# $1 - text to print
# $2 - how many times to print
print_n() {
    local out=""
    for ((i = 0; i < $2; i++)); do
        out+="$1"
    done
    echo "${out}"
}

# Prints bar divided in two parts by given percentage
# $1 - bar width
# $2 - percentage
print_bar() {
    local bar_width=$(($1 - 2))
    local used_width=$(($2 * bar_width / 100))
    local free_width=$((bar_width - used_width))
    local out=""
    out+="["
    out+="${CE}"
    out+=$(print_n "=" ${used_width})
    out+="${CO}"
    out+=$(print_n "=" ${free_width})
    out+="${CN}"
    out+="]"
    echo "${out}"
}

# Prints text with color according to given value and two thresholds
# $1 - text to print
# $2 - current value
# $3 - warning threshold
# $4 - error threshold
print_color() {
    local out=""
    if (($(bc -l <<< "$2 < $3"))); then
        out+="${CO}"
    elif (($(bc -l <<< "$2 >= $3 && $2 < $4"))); then
        out+="${CW}"
    else
        out+="${CE}"
    fi
    out+="$1${CN}"
    echo "${out}"
}

# Prints text as either acitve or inactive
# $1 - text to print
# $2 - literal "active" or "inactive"
print_status() {
    local out=""
    if [[ $2 == "active" ]]; then
        out+="${CO}▲${CN}"
    else
        out+="${CE}▼${CN}"
    fi
    out+=" $1${CN}"
    echo "${out}"
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
        element="${element},"
        local visible_elelement future_length
        visible_elelement=$(strip_ansi "${element}")
        future_length=$((line_length + ${#visible_elelement}))
        if [[ ${line_length} -ne 0 && ${future_length} -gt ${width} ]]; then
            out+="\n"
            line_length=0
        fi
        out+="${element} "
        line_length=$((line_length + ${#visible_elelement}))
    done
    [[ -n "${out}" ]] && echo "${out::-2}"
}

# Prints some text justified to left and some justified to right
# $1 - total width
# $2 - left text
# $3 - right text
print_split() {
    local visible_first visible_second invisible_first_width invisible_second_width total_width \
        first_half_width second_half_width format_string

    visible_first=$(strip_ansi "$2")
    visible_second=$(strip_ansi "$3")
    invisible_first_width=$((${#2} - ${#visible_first}))
    invisible_second_width=$((${#3} - ${#visible_second}))
    total_width=$(($1 + invisible_first_width + invisible_second_width))

    if ((${#visible_first} + ${#visible_second} < $1)); then
        first_half_width=${#2}
    else
        first_half_width=$(($1 / 2))
    fi
    second_half_width=$((total_width - first_half_width))

    format_string="%-${first_half_width}s%${second_half_width}s"
    # shellcheck disable=SC2059
    printf ${format_string} "${2:0:${first_half_width}}" "${3:0:${second_half_width}}"
}

# Prints one line of text, truncates it at specified width and add ellipsis.
# Truncation can occur either at the start or at the end of the string.
# $1 - line to print
# $2 - width limit
# $3 - "start" or "end", default "end"
print_truncate() {
    local out
    local new_length=$(($2 - 1))
    # Just echo the string if it's shorter than the limit
    if [[ ${#1} -le "$2" ]]; then
        out="$1"
    elif [[ -z "$3" || "$3" == "end" ]]; then
        out="${1::${new_length}}…"
    else
        out="…${1: -${new_length}}"
    fi
    echo "${out}"
}

# Strips ANSI color codes from given string
# $1 - text to strip
strip_ansi() {
    echo -e "$1" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}

# Following is basically simple `column` reimplementation because it doesn't work consistently.
# I fucked way too long with this.
# $1 - text to columnize
# $2 - column separator
# $3 - row separator
columnize() {
    local left_lines left_widths right_lines max_left_width left right visible_left \
        padding_width padding
    left_lines=()    # Lines in left column
    left_widths=()   # Numbers of visible chars in left lines
    right_lines=()   # Lines in right column
    max_left_width=0 # Max width of left column line
    # Iterate over lines and populate above variables
    while IFS="$3" read -r line; do
        left="$(echo -e "${line}" | cut -d "$2" -f 1)"
        right="$(echo -e "${line}" | cut -d "$2" -f 2)"
        left_lines+=("${left}")
        right_lines+=("${right}")
        visible_left=$(strip_ansi "${left}")
        left_widths+=(${#visible_left})
        [[ ${#visible_left} -gt ${max_left_width} ]] && max_left_width=${#visible_left}
    done <<< "$1"

    # Iterate over lines and print them while padding left column with spaces
    for ((i = 0; i < ${#left_lines[@]} - 1; i++)); do
        padding_width=$((max_left_width - left_widths[i]))
        padding=$(print_n " " ${padding_width})
        echo -e "${left_lines[${i}]}${padding}  ${right_lines[${i}]}"
    done
}
