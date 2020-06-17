function build_pglet_add() {
    for i in "$@"
    do
        echo "$i"
    done
}

function pglet() {
    build_pglet_add "$@" > test.ui
}

pglet "ADD right
row header
  alert message
row form
  column
    textbox firstName label='First name'
  column
    textbox lastName label='Last name'
row footer
  column
    button ok text=OK
    button cancel text=Cancel"

#pglet 'GET firstName value'

#bash -c 'echo "1"; sleep 2; echo "2"; sleep 2; echo "3"; sleep 2; echo "4"; sleep 2; echo "5";' > test.ui
# pglet_add textbox id=2 message="enter the 'date'" fragment 'aaa
#   bbb
#      ccc'

echo "before read line"
sleep 3

while read line < test.ui
do
    if [[ "$line" == 'quit' ]]; then
        break
    fi
    echo $line
done

echo "before ls"
sleep 3
ls -al | sed -e 's/^/prefix1 /' > test.ui