function pglet_start_session() {
    echo "Client connected"
    # global variables
    local handler_function=$1
    PGLET_CLIENT_ID=$2
    PGLET_CONTROLS_PIPE=$3
    PGLET_EVENTS_PIPE=$4

    # call custom handler
    eval "$handler_function"
}

function pglet_connect_page() {
    local page_name=$1
    local handler_function=$2

    # here goes the loop waiting for new connections
    eval "pglet_start_session $handler_function 1 "pipe1.controls" "pipe1.events" &"
    eval "pglet_start_session $handler_function 2 "pipe2.controls" "pipe2.events" &"
}

function pglet_add() {
    echo "pglet_add to $PGLET_CONTROLS_PIPE"
    for i in "$@"
    do
        echo ">>> $i <<<"
    done
}