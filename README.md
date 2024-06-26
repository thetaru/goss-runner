# goss-runner
A thin wrapper for goss. Directory structure is based on ansible best practices.
## Directory structure
goss-runner includes main.yaml under the scenario directory.
```
.
├── bin
│   └── goss                         // put goss binary (download from https://github.com/goss-org/goss)
├── goss-runner
├── playbooks                         // Write a list of test scenarios to run for each host
│   └── <hostname>.yaml
├── scenarios
│   └── ssh                          // describe test scenario name
│       ├── ssh.yaml                       // describe the test content
│       └── main.yaml                      // include the scenario you have created
└── vars                              // describe variables for scenario
    ├── all                                 // Describes variables for commonly loaded scenarios
    │   └── commonVariables.yaml
    └── <hostname>                          // Describes variables to be loaded scenarios by host
        └── hostVariables.yaml
```
## How to build
```sh
go build
```
## How to use goss-runner
```sh
./goss-runner
```
```
PLAY [SampleHost]
SCENARIO [service.yaml]
1..4
ok 1 - Command: temp-disk-dataloss-warning.service: exit-status: matches expectation: 0
ok 2 - Command: temp-disk-dataloss-warning.service: stdout: matches expectation: ["enabled"]
ok 3 - Command: polkit.service: exit-status: matches expectation: 0
ok 4 - Command: polkit.service: stdout: matches expectation: ["static"]
 
SCENARIO [ntp.yaml]
1..2
ok 1 - File: /etc/chrony.conf: exists: matches expectation: true
ok 2 - File: /etc/chrony.conf: filetype: matches expectation: "file"
```
## How to write scenario
Read [official documentations](https://github.com/goss-org/goss/blob/master/docs/gossfile.md).
 