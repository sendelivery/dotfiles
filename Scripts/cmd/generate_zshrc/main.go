package main

import (
	"bytes"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"gopkg.in/yaml.v2"
)

type zshrcConfig struct {
	ExistingZshrc string
	Options       []*struct {
		Key   string
		Value string
		Add   bool
	}
}

func (z *zshrcConfig) Bytes() []byte {
	var buf bytes.Buffer

	if len(z.ExistingZshrc) > 0 {
		_, err := buf.WriteString(z.ExistingZshrc)
		if err != nil {
			panic(err)
		}
	}

	if !(strings.HasSuffix(z.ExistingZshrc, "\n\r") || strings.HasSuffix(z.ExistingZshrc, "\n")) {
		_, err := buf.WriteString("\n")
		if err != nil {
			panic(err)
		}
	}

	for _, opt := range z.Options {
		if opt.Add {
			fmt.Fprintf(&buf, "%s\n", opt.Value)
		}
	}

	return buf.Bytes()
}

var (
	homeDir       string
	_templatesDir string
	debugFlag     *bool
)

func main() {
	var appendToExisting = flag.Bool("append", false, "set this flag if you wish to append to your existing zshrc file instead of overwriting it completely")
	debugFlag = flag.Bool("d", false, "used for debugging")
	flag.Parse()

	h, ok := os.LookupEnv("HOME")
	homeDir = h
	if !ok {
		homeDir = "~"
	}

	// Grab .zshrc file
	zshrcFile := getOrCreateZshrc()

	// Build config
	var cfg zshrcConfig
	readConfig(&cfg)

	if *appendToExisting {
		b, err := os.ReadFile(zshrcFile.Name())
		if err != nil {
			panic(err)
		}
		cfg.ExistingZshrc = string(b)
	} else {
		zshrcFile.Truncate(0)
		zshrcFile.Seek(0, 0)
	}

	toggleOptions(&cfg)

	_, err := zshrcFile.Write(cfg.Bytes())
	if err != nil {
		panic(err)
	}
}

func getOrCreateZshrc() *os.File {
	p, ok := os.LookupEnv("ZDOTDIR")
	if !ok || p == "" {
		p = homeDir
	}
	p = fmt.Sprintf("%s%s", p, "/.zshrc")

	f, err := os.OpenFile(p, os.O_CREATE|os.O_RDWR, 0644) // 0644 - read & write for owner, read for other users
	if err != nil {
		panic(err)
	}
	return f
}

func readConfig(cfg *zshrcConfig) {
	yamlConfig, err := os.ReadFile(fmt.Sprintf("%s%s", templatesDir(), "/zshrc_config.yml"))
	if err != nil {
		log.Fatalf("error reading .zshrc_config.yml: %v", err)
	}

	err = yaml.Unmarshal(yamlConfig, cfg)
	if err != nil {
		log.Fatalf("error: %v", err)
	}
}

func toggleOptions(cfg *zshrcConfig) {
	for _, opt := range cfg.Options {
		// On an empty .zshrc, populate it with all the options
		if len(cfg.ExistingZshrc) == 0 {
			opt.Add = true
			continue
		}

		// Otherwise, check each option to avoid duplicates
		if !strings.Contains(cfg.ExistingZshrc, opt.Value) {
			opt.Add = true
		}
	}
}

func templatesDir() string {
	if _templatesDir != "" {
		return _templatesDir
	}

	_templatesDir = ".."

	if !*debugFlag {
		_templatesDir = homeDir
	}

	_templatesDir += "/Templates"
	return _templatesDir
}
