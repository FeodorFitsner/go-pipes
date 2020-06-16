read eventName eventTarget < test.events
echo "$eventName $eventTarget"

# while read eventName eventTarget < test.events
# do
#     if [[ "$eventName" == 'quit' ]]; then
#         break
#     fi
#     echo "$eventName $eventTarget"
# done