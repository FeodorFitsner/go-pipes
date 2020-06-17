eval "$(cat ./pglet.sh)"

function page1_connected() {
    # this is the app entry point
    echo "page1_connected()"
    echo "PGLET_CLIENT_ID: $PGLET_CLIENT_ID"
    echo "PGLET_CONTROLS_PIPE: $PGLET_CONTROLS_PIPE"
    echo "PGLET_EVENTS_PIPE: $PGLET_EVENTS_PIPE"

    local hint="this is a hint!"

    pglet_add header textbox hint="$hint" text="test \"aaa"
    sleep 2
    pglet_add footer a
    pglet_add footer '
      row
        col
          textbox firstName label="First name"
      row
        col
          textbox lastName label="Last name"
      row
        button OK
        button Cancel
    '
}

pglet_connect_page "/page1" "page1_connected"

wait