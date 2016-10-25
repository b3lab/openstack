#!/usr/bin/expect

spawn passwd
expect "password:"
send "<password>\r"

expect "password:"
send "<password>\r"
interact
