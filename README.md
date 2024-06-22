# goss-runner
## How to use goss-runner.sh
```sh
./goss-runner.sh
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
 
## Directory structure
Minimum configuration
```
.
├── bin
│   └── goss                         // put goss binary (download from https://github.com/goss-org/goss)
├── goss-runner.sh
├── scenarios                         // describe test scenarios
│   ├── common                           // Describe commonly executed test scenarios
│   │   └── commonExamples01.yaml
│   └── <hostname>                       // Describes test scenarios to be executed by host
│       └── hostExamples01.yaml
└── vars                              // describe variables for scenario
    ├── common                            // Describes variables for commonly loaded scenarios
    │   └── commonVariables.yaml
    └── <hostname>                        // Describes variables to be loaded scenarios by host
        └── hostVariables.yaml
```