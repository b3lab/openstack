#!/usr/bin/expect

spawn ssh-keygen
expect ".ssh/id_rsa)"
send "\r"
expect "passphrase)"
send "\r"
expect "again:"
send "\r"

interact
