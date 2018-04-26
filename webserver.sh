#!/bin/bash

if [ $# -eq 0 ]; then
    echo "requires: bash, socat, file, wc, cat"
    echo ""
    echo "Usage: sh webserver.sh"
    echo "(port is default to 3000)"
    echo "Usage: sh webserver.sh 2222"
    echo "(port can be specified)"
    echo "";
fi

readonly CRLF=$'\r\n'
readonly SERVERNAME='bash.webserver/0.01'
###############
function webdir() {
	WEB_ROOT_DIR='/tmp/webdir'
    if [ ! -d "$WEB_ROOT_DIR" ];then
        echo "Webserver document root directory does not exists creating it....."
        mkdir -p $WEB_ROOT_DIR
    fi
    return 0
}

function webindex() {
	WEB_INDEX='index.html'
    if [ ! -f "$WEB_ROOT_DIR/$WEB_INDEX" ]; then
        echo "Web index file does not exists creating it....."
        echo "<!doctype html><p>Bash Webserver <b>v0.01</b></p></html>" > $WEB_ROOT_DIR/$WEB_INDEX
    fi
    return 0
}
webdir; webindex

function content_type() {
    local file=$1
    local mtype=$(file -b --mime "$file")
    [[ $mtype != *\;* ]] && mtype=${mtype/ /\; } # for file < 5.0
    [[ $mtype != unknown ]] && echo -n "Content-Type: $mtype$CRLF"
}

function content_length() {
    local file=$1
    echo -n "Content-Length: $(wc -c "$file")$CRLF"
}

function GET_200() {
    local file=$1
    echo -n "HTTP/1.0 200 OK$CRLF"
    echo -n "Server: $SERVERNAME$CRLF"
    content_type "$file"
    # content_length "$file"
    echo -n "$CRLF"
}

function GET_404() {
    echo -n "HTTP/1.0 404 Not Found$CRLF"
    echo -n "Server: $SERVERNAME$CRLF"
    echo -n "$CRLF"
    echo "404 Not Found"
}

function HEAD_200() {
    local file=$1
    echo -n "HTTP/1.0 200 OK$CRLF"
    echo -n "Server: $SERVERNAME$CRLF"
    content_type "$file"
    echo -n date: `date`$CRLF
    echo -n "$CRLF"
}

function HEAD_404() {
    local file=$1
    echo -n "HTTP/1.0 404 NOT FOUND$CRLF"
    echo -n "Server: $SERVERNAME$CRLF"
    echo -n date: `date`$CRLF
    echo -n "$CRLF"
}

function dispatch() {
    local method=$1 path=$2
    webdir WEB_ROOT_DIR
    if [[ $method == GET ]]; then
        if [[ $path == /*.html ]]  && path="$WEB_ROOT_DIR$path";then
            path=${path#../}
            path=${path//\/..\//}
            [ -d "$path" ] && path="$path/index.html"
            if [ -f "$path" ]; then
                GET_200 "$path"
                cat "$path"
            else
                GET_404
            fi
        elif [[ $path == /*.php ]] && path="$WEB_ROOT_DIR$path";then
            path=${path#../}
            path=${path//\/..\//}
            [ -d "$path" ]
            if [ -f "$path" ]; then
                GET_200 "$path"
                php "$path"
            else
                GET_404
            fi
        fi
    elif [[ $method == HEAD ]]; then
        [[ $path == /* ]]  && path="$WEB_ROOT_DIR$path"
        path=${path#../}
        path=${path//\/..\//}
        [ -d "$path" ] && path="$path/index.html"
        if [ -f "$path" ]; then
            HEAD_200 "$path"
        else
            HEAD_404 "$path"
        fi
    fi
}

function run() {
    local method path ver
    read method path ver
    path=${path%$'\r'}
    dispatch "$method" "$path"
}

export -f content_type content_length \
          GET_200 GET_404 HEAD_200 HEAD_404 \
          dispatch run \
		  webdir webindex
export CRLF SERVERNAME

trap 'echo shutdown.; exit' INT
echo 'Ctrl-C to shutdown server'
while :; do
    socat -v -x exec:'bash -c run', TCP-LISTEN:${1:-3000},reuseaddr
done
