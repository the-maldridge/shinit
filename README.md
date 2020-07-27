# shinit

`shinit` is a simplified replacement for cloud-init that does much
less and for fewer clouds.

## Why?

Its dramatically simpler and works without Python.  Adding a new
provider is as simple as writing a short shell script.

## Limitations?

Probably many, mostly that it is incompatible with the cloud-init
format for user-data.  The user-data must be a file that starts with
`#!` and must be interpretable by something on the system.

