package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"

	yaml "gopkg.in/yaml.v3"
)

type Playbook struct {
	Scenarios []map[string]string `yaml:"scenarios"`
}

func main() {
	// Goss execution hostname
	gossHostname, err := gossFetchHostname()
	if err != nil {
		log.Fatal(err)
	}

	// Goss binary path
	gossBinPath := "./bin/goss"

	// Goss scenarios path
	gossScenarioRootPath := "./scenarios"

	// Goss variables path
	gossVarRootPath := "./vars"
	gossVarHostPath := gossVarRootPath + "/" + gossHostname
	gossVarCommonPath := gossVarRootPath + "/all"
	gossVarMergeFile, err := os.CreateTemp(os.TempDir(), "goss-")
	if err != nil {
		log.Fatal(err)
	}
	defer os.Remove(gossVarMergeFile.Name())

	// Goss playbooks path
	gossPlaybookRootPath := "./playbooks"
	gossPlaybookFilePath := gossPlaybookRootPath + "/" + gossHostname + ".yaml"

	// Default output format
	// gossOutputFormat := "tap"

	// Merge variables
	gossMergeVarFiles(gossVarCommonPath, gossVarMergeFile)
	gossMergeVarFiles(gossVarHostPath, gossVarMergeFile)

	// Read scenarios from playbook
	gossFetchedScenarios := gossFetchScenarioFromPlaybook(gossPlaybookFilePath)

	// Exec
	gossRun(gossBinPath, gossVarMergeFile, gossScenarioRootPath, gossFetchedScenarios)
}

func gossFetchHostname() (string, error) {
	gossFQDN, err := os.Hostname()
	return strings.Split(gossFQDN, ".")[0], err
}

func gossMergeVarFiles(gossVarPath string, gossMergeFile *os.File) {
	// Check directory exists
	if _, err := os.Stat(gossVarPath); err != nil {
		if os.IsNotExist(err) {
			log.Fatal(err)
		}
	}

	gossVarFiles, err := os.ReadDir(gossVarPath)
	if err != nil {
		log.Fatal(err)
	}

	for _, gossVarFile := range gossVarFiles {
		gossVarFilePath := gossVarPath + "/" + gossVarFile.Name()
		gossOpenedMergeFile, err := os.OpenFile(gossMergeFile.Name(), os.O_WRONLY|os.O_APPEND, 0644)
		if err != nil {
			log.Fatal(err)
		}
		defer gossOpenedMergeFile.Close()

		contents, err := os.ReadFile(gossVarFilePath)
		if err != nil {
			log.Fatal(err)
		}
		gossOpenedMergeFile.Write(contents)
		gossOpenedMergeFile.WriteString("\n")
	}
}

func gossFetchScenarioFromPlaybook(gossPlaybookFilePath string) []string {
	playbookYamlFormat, err := os.ReadFile(gossPlaybookFilePath)
	if err != nil {
		log.Fatal(err)
	}

	playbook := Playbook{}
	err = yaml.Unmarshal(playbookYamlFormat, &playbook)
	if err != nil {
		log.Fatal(err)
	}

	var scenarioArr []string
	for _, v := range playbook.Scenarios {
		scenarioArr = append(scenarioArr, v["scenario"])
	}
	return scenarioArr
}

func gossRun(
	gossBinPath string,
	gossVarMergeFile *os.File,
	gossScenarioRootPath string,
	gossScenarioNames []string,
) {
	for _, gossScenarioName := range gossScenarioNames {
		fmt.Println("SCENARIO:", gossScenarioName)
		gossTestResult, _ := exec.Command(
			gossBinPath,
			"--gossfile",
			gossScenarioRootPath+"/"+gossScenarioName+"/"+"main.yaml",
			"--vars",
			gossVarMergeFile.Name(),
			"validate",
			"--format",
			"tap",
		).Output()
		fmt.Println(string(gossTestResult))
	}
}
