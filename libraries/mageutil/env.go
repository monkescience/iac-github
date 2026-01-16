package mageutil

import (
	"fmt"
	"os"
)

func GetEnvValueOrWaitForInput(key string, defaultValue string) string {
	value, ok := os.LookupEnv(key)
	if !ok {
		fmt.Printf("%s [%s]: ", key, defaultValue)

		var inputValue string
		_, err := fmt.Scanln(&inputValue)
		if err != nil {
			inputValue = defaultValue
		}

		err = os.Setenv(key, inputValue)
		if err != nil {
			panic(fmt.Errorf("failed to set env var %s: %w", key, err))
		}

		return inputValue
	}
	return value
}
