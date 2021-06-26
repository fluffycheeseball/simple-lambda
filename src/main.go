package main

import ( "fmt"
"go.uber.org/zap"

)
func main() {
    fmt.Println("Hey Jude!")
    zap.L().Info("some log message")
}