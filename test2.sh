PGLET_CONTROL_TYPES=("ROW" "COL" "TEXTBOX" "CONTROLS")

function contains_newline() {
    local nl='
'
    case "$1" in
        *$nl*)  echo 'true' ;;
        *)      echo 'false'  ;;
    esac
}

function contains_whitespace() {
    local var=$1
    if [[ ${var//[^[:blank:]]} ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function contains_equal() {
    local var=$1
    if [[ ${var//[^=]} ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function strings_are_equal_case_ins() {
    local orig_nocasematch=$(shopt -p nocasematch)
    shopt -s nocasematch
    local result='false'
    if [[ "$1" == "$2" ]]; then
        result='true'
    fi
    $orig_nocasematch
    echo "$result"
}

function is_pglet_control() {
    local result='false'
    for ctrl_type in ${PGLET_CONTROL_TYPES[@]}; do
        if [[ "$(strings_are_equal_case_ins "$ctrl_type" "$1")" == 'true' ]]; then
            result='true'
            break
        fi
    done
    echo "$result"
}

function is_pglet_identifier() {
    local var=$1
    if [[ "$(contains_whitespace "$var")" == "false" ]] && [[ "$(contains_equal "$var")" == "false" ]] && [[ "$(contains_newline "$var")" == "false" ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function escape_quotes() {
    echo "$1" | while IFS='' read line; do
        echo "${line//\"/\\\"}"
    done
}

function quote_string() {
    echo "\"$(escape_quotes "$1")\""
}

quote_string "aa\"a
  bbb
    c\"cc"

# is_pglet_control "textbox"
# is_pglet_identifier "aaabbb"

trim_and_quote() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    var=${var//\"/\\\"}
    printf '%s' "$var"
}

echo "key1 =   valu\"e2 = 2" | while IFS='=' read key value; do
    printf '%s="%s"\n' "$(trim_and_quote "$key")" "$(trim_and_quote "$value")"
done

function pglet_add() {
    local args="$*"
    local i=1
    local totalArgs=$#
    local parentControlId=''
    local controlType=''
    local controlId=''
    declare props=()
    local controlsSnippet=''

    if [[ $totalArgs -lt 1 ]]; then
        echo "pglet_add() should have at least one parameter"
        return 1
    fi

    # parse command arguments
    for arg in "$@"
    do
        echo "$i: >>> $arg <<<"
        # echo "is_pglet_identifier: $(is_pglet_identifier "$arg")"
        # echo "is_pglet_control: $(is_pglet_control "$arg")"

        if [[ $i -eq 1 ]] && [[ "$(is_pglet_identifier "$arg")" == "true" ]] && [[ "$(is_pglet_control "$arg")" == "false" ]]; then
            # 1 - parent control ID
            parentControlId="$arg"
        elif [[ $i -eq 1 ]] && [[ "$(is_pglet_control "$arg")" == "true" ]]; then
            # 1 - control type
            controlType="$arg"
        elif [[ $i -eq 2 ]] && [[ "$(is_pglet_control "$arg")" == "true" ]]; then
            # 2 - control type
            if [[ "$parentControlId" == "" ]]; then
                echo "Control type could be the 1st or 2nd argument only"
                return 1
            fi
            controlType="$arg"
        elif [[ $i -eq 2 ]] && [[ "$(is_pglet_identifier "$arg")" == "true" ]]; then
            # 2 - control ID
            if [[ "$controlType" == "" ]]; then
                echo "Control ID could be the 2nd or 3rd argument only"
                return 1
            fi
            controlId="$arg"
        elif [[ $i -eq 3 ]] && [[ "$(is_pglet_identifier "$arg")" == "true" ]]; then
            # 3 - control ID
            controlId="$arg"
        elif [[ $i -eq $totalArgs ]] && [[ "$(strings_are_equal_case_ins "$controlType" "CONTROLS")" == 'true' ]]; then
            controlsSnippet="$arg"
        else
            # property
            props+=("$arg")
        fi
        i=$[i + 1]
    done

    echo "pglet_add() parentControlId=$parentControlId controlType=$controlType controlId=$controlId props: $props controlsSnippet=$(quote_string "$controlsSnippet")"
}

function pglet_set() {
    echo 'pglet_set'
}

function pglet_get() {
    echo 'pglet_get'
}

function pglet_remove() {
    echo 'pglet_remove'
}

function pglet_clean() {
    echo 'pglet_clean'
}

pglet_add

pglet_add "dddd"

pglet_add footer textbox

pglet_add row a1 width=50%

pglet_add footer controls 'aa"a
b"bb
   ccc'

# pattern='s/\(=[[:blank:]]*\)\(.*\)/\1"\2"/'
# echo "a=b" | sed $pattern
# echo "a=b c 
# d
# e f" | sed $pattern



var='a b
c'

var2='sssccc='
var3='aa ccc ddd'

contains_newline "$var"
contains_newline "$var2"

contains_whitespace "$var"
contains_whitespace "$var2"
contains_whitespace "$var3"

contains_equal "$var"
contains_equal "$var2"