#!/bin/sh

log() {
    printf >&2 "%s\n" "$1"
}

die() {
    log "$1"
    touch "$SHINIT_HOME/done"
    exit 1
}
