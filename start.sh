#!/bin/sh -e

(sleep 5; ./moto.sh) &

exec moto_server -H 0.0.0.0 $1
