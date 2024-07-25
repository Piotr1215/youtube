package aicmd

import (
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"runtime"
	"strings"

	"github.com/atotto/clipboard"
	"github.com/piotr1215/aicmdtools/internal/config"
	"github.com/piotr1215/aicmdtools/internal/nlp"
	"github.com/piotr1215/aicmdtools/internal/utils"
)

type Executor interface {
	Execute(command string) error
}

type (
	DefaultExecutor struct{}
	CommandDecision int
)

const (
	CmdExecute CommandDecision = iota
	CmdCopy
	CmdDoNothing
)

func (e *DefaultExecutor) Execute(command string) error {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("cmd", "/C", command)
	} else {
		cmd = exec.Command("sh", "-c", command)
	}
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// Inject the executor as a global variable
var executor Executor = &DefaultExecutor{}

func shouldExecuteCommand(config *config.Config, reader io.Reader) CommandDecision {
	if !config.Safety {
		return CmdExecute
	}

	fmt.Print("Execute the command? [Enter/n/c(opy)] ==> ")
	var answer string
	_, _ = fmt.Fscanln(reader, &answer)

	switch strings.ToUpper(answer) {
	case "N":
		return CmdDoNothing
	case "C":
		return CmdCopy
	default:
		return CmdExecute
	}
}

func copyCommandToClipboard(command string) error {
	return clipboard.WriteAll(command)
}

func appendCommandToHistory(command string) {
	historyFile := "command_history.txt"

	f, err := os.OpenFile(historyFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Printf("Error opening command history file: %v\n", err)
		return
	}
	defer f.Close()

	if _, err := f.WriteString(command + "\n"); err != nil {
		log.Printf("Error writing command to history file: %v\n", err)
	}
}

func Execute(prompt_file string) error {
	conf, prompt, err := config.ReadAndParseConfig("config.yaml", prompt_file)
	if err != nil {
		fmt.Printf("Error reading and parsing configuration: %v\n", err)
		os.Exit(-1)
	}
	operating_system, shell := utils.DetectOSAndShell()
	prompt = utils.ReplacePlaceholders(prompt, operating_system, shell)

	client := nlp.CreateOpenAIClient(*conf)

	aiClient := nlp.GoaiClient{
		Client: client,
		Prompt: prompt,
	}

	if len(os.Args) < 2 {
		fmt.Println("No user prompt specified.")
		os.Exit(-1)
	}

	userPrompt := strings.Join(os.Args[1:], " ")

	response, err := aiClient.ProcessCommand(userPrompt)
	if err != nil {
		fmt.Printf("Error processing command: %v\n", err)
		return err
	}

	command := response.Choices[0].Message.Content
	fmt.Printf("Command: %s\n", command)

	decision := shouldExecuteCommand(conf, os.Stdin)

	if decision == CmdExecute || decision == CmdCopy {
		err = copyCommandToClipboard(command)
		if err != nil {
			log.Printf("Error copying command to clipboard: %v\n", err)
		}
	}

	switch decision {
	case CmdExecute:
		err = executor.Execute(command)
		if err != nil {
			log.Fatal(err)
		}
		appendCommandToHistory(command)
	case CmdCopy:
		fmt.Println("Command copied to clipboard.")
	case CmdDoNothing:
		fmt.Println("Command not executed.")
	default:
		fmt.Println("Invalid decision.")
	}
	return nil
}
