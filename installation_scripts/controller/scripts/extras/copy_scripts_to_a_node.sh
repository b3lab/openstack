#!/usr/bin/expect

set ip <ip-addr>

spawn bash -c "scp -r ../* root@$ip:/root"
expect {
  -re ".yes.no.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "<password>\r"
  }
}
interact

