while read line < test.events
do
    if [[ "$line" == 'quit' ]]; then
        break
    fi
    echo $line
done