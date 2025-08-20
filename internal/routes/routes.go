package routes

import (
	"fmt"
	"net/http"
)

func RegisterRoutes() {
	http.HandleFunc("/health", HealthCheckHandler)
}

func HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "status: ok")
}
