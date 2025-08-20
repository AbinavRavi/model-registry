package main

// import (
// 	"github.com/AbinavRavi/model-registry/internal/models"
// )

import (
	"fmt"
	"model-registry/internal/routes"
	"net/http"
)

func main() {
	fmt.Println("Hello, Welcome to Model registry please register your models")
	routes.RegisterRoutes()
	http.ListenAndServe(":8080", nil)
}
