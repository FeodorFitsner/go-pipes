read eventName eventTarget < test.events
echo "$eventName $eventTarget"

echo "key1=value2" | IFS='=' read key value
echo "$key = $value"

# while read eventName eventTarget < test.events
# do
#     if [[ "$eventName" == 'quit' ]]; then
#         break
#     fi
#     echo "$eventName $eventTarget"
# done