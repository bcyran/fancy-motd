print_columns() {
    paste <(printf "${CA}$1${1:+:}${CN}") <(printf "$2")
}
