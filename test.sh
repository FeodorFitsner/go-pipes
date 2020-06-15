bash -c 'echo "1"; sleep 2; echo "2"; sleep 2; echo "3"; sleep 2; echo "4"; sleep 2; echo "5";' > test.ui
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