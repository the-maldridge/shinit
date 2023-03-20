#!/bin/sh

log() {
    printf >&2 '%s\n' "$1"
}

die() {
    log "$1"
    touch -- "$SHINIT_HOME/done"
    exit 1
}

configure_hostname() {
    if [ -z "$NAME" ]; then
        log "Could not set hostname"
        return
    fi

    log "Configuring Hostname"
    printf >/etc/hostname '%s\n' "$NAME"
    hostname -- "$NAME"
    printf >>/etc/hosts '\n127.0.0.1\t%s\n' "$NAME"
}

configure_keys() {
    if [ -z "$KEYS" ]; then
        log "No keys to set!"
        return
    fi
    if [ -z "$SHINIT_USER" ]; then
        log "SHINIT_USER is not set; cannot configure keys"
        return
    fi
    log "Configuring SSH keys"

    # This patten is heavily inspired by mcrute's tiny-ec2-bootstrap
    # for Alpine Linux.
    _user="$SHINIT_USER"
    _group="$(getent passwd "$_user" | cut -d: -f4)"
    _ssh_dir="$(getent passwd "$_user" | cut -d: -f6)/.ssh"
    _keys_file="$_ssh_dir/authorized_keys"

    if [ ! -d "$_ssh_dir" ]; then
        mkdir -p "$_ssh_dir"
    fi
    chmod 755 "$_ssh_dir"

    [ -f "$_keys_file" ] && rm "$_keys_file"

    touch "$_keys_file"
    chmod 600 "$_keys_file"
    chown -R "$_user:$_group" "$_ssh_dir"

    printf >"$_keys_file" '%s\n' "$KEYS"
}

process_user_data() {
    if [ -z "$DATA" ]; then
        log "No user-data was provided"
        return
    fi

    printf >"$SHINIT_HOME"/user-data '%s\n' "$DATA"

    if [ "${DATA%"${DATA#???}"}" = "#!/" ]; then
        chmod +x -- "$SHINIT_HOME"/user-data
        log "user-data appears to be a script, executing..."
        "$SHINIT_HOME"/user-data
    fi
}

fetch_url() {
    curl -sf -- "$1"
    return $?
}
