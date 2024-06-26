# How to run this
```sh
root@test:~/goss-runner# ./goss-runner
```
```
SCENARIO: ssh
1..15
not ok 1 - Group: sshd: exists: Expected false to equal true
ok 2 - # SKIP Group: sshd: gid: skipped
ok 3 - User: sshd: exists: matches expectation: true
not ok 4 - User: sshd: uid: Expected 106 to be numerically eq 74
not ok 5 - User: sshd: gid: Expected 65534 to be numerically eq 74
not ok 6 - User: sshd: home: Expected "/run/sshd" to equal "/var/empty/sshd"
not ok 7 - User: sshd: groups: Expected ["nogroup"] to contain elements matching ["sshd"] the missing elements were ["sshd"]
not ok 8 - User: sshd: shell: Expected "/usr/sbin/nologin" to equal "/sbin/nologin"
ok 9 - Port: tcp:22: listening: matches expectation: true
ok 10 - Port: tcp:22: ip: matches expectation: ["0.0.0.0"]
ok 11 - Port: tcp6:22: listening: matches expectation: true
ok 12 - Port: tcp6:22: ip: matches expectation: ["::"]
ok 13 - Process: sshd: running: matches expectation: true
ok 14 - Service: sshd: enabled: matches expectation: true
ok 15 - Service: sshd: running: matches expectation: true
```
