# Bash based webserver v0.01

## Source

https://github.com/emasaka/httpd.bash

## Description

The bash based webserver v0.01 renders ``GET`` and ``HEAD`` request. The standard http status code used in this server are ``200 OK`` and ``404 Not Found``. 

## Requirements

``bash``

``socat``

``file``

``wc``

``cat``

## Functions

``webdir``

Creates document root directory if it does not exists.

``webindex``

Creates ``index.html`` file if it does not exists.

``content_type``

Content type of the file, usually text/html with charset

``content_length``

Bytes of the rendered file.

``GET_200``

HTTP status code 200 OK for GET request.

``GET_404``

HTTP status code 404 NOT FOUND for GET request.

``HEAD_200``

HTTP status code 200 OK for HEAD request.

``HEAD_404``

HTTP status code 404 NOT FOUND for HEAD request.

``dispatch``

To track and validate the path of the requested file.

``run``

Read the response and render accordingly.


# Usage

Default port 3000

``sh webserver.sh``

Any specific port

``sh webserver.sh 2222``
