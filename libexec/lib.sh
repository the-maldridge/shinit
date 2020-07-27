#!/bin/sh

log() {
    printf >&2 "%s\n" "$1"
}

die() {
    log "$1"
    touch "$SHINIT_HOME/done"
    exit 1
}

confirm_base_info() {
    if [ -n "$NAME" ] && [ -n "$DATA" ] && [ -n "$KEYS" ]; then
        return 1
    else
        return 0
    fi
}

configure_hostname() {
    log "Configuring Hostname"
    printf >/etc/hostname "%s" "$NAME"
    hostname "$NAME"
    printf >>/etc/hosts "\n127.0.0.1\t%s\n" "$NAME"
}

configure_keys() {
    log "Configuring SSH keys"
    if [ -z "$SHINIT_USER" ] ; then
        log "SHINIT_USER is not set, cannot configure keys"
        return
    fi


    # This patten is heavily inspired by mcrute's tiny-ec2-bootstrap
    # for Alpine Linux.
    _user="$SHINIT_USER"
    _group="$(getent passwd "$_user" | cut -d: -f4)"
    _ssh_dir="$(getent passwd "$_user" | cut -d: -f6)/.ssh"
    _keys_file="$_ssh_dir/authorized_keys"

    if [ ! -d "$_ssh_dir" ]; then
        mkdir -p "$_ssh_dir"
        chmod 755 "$_ssh_dir"
    fi

    [ -f "$_keys_file" ] && rm "$_keys_file"

    touch "$_keys_file"
    chmod 600 "$_keys_file"
    chown -R "$_user:$_group" "$_ssh_dir"

    printf >"$_keys_file" "%s\n" "$KEYS"
}
