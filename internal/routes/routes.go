package routes

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log/slog"
	"model-registry/internal/model"
	"net/http"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

func RegisterRoutes() {
	http.HandleFunc("/health", HealthCheckHandler)
	http.HandleFunc("/register", RegisterModel)
}

func HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "okay"})
}

func ptrTime(t time.Time) *time.Time { return &t }

func RegisterModel(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var metadata model.RegisterModelMetadata
	err := json.NewDecoder(r.Body).Decode(&metadata)
	if err != nil {
		fmt.Println(err)
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	err = metadata.IsValidSemver()
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Here you would typically save the metadata to a database or file system
	// I am currently using SQlite will need to replace connection string etc for an actual DB

	db, err := sql.Open("sqlite3", "./test.db")
	if err != nil {
		slog.Error("failed to open database", "err", err)
	}
	defer db.Close()

	// Create table if it doesn’t exist
	// createTable := `
	// CREATE TABLE IF NOT EXISTS model_metadata (
	// 	id INTEGER PRIMARY KEY AUTOINCREMENT,
	// 	name TEXT NOT NULL,
	// 	version TEXT NOT NULL,
	// 	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	// 	model_path TEXT NOT NULL,
	// 	model_path_location TEXT NOT NULL,
	// 	metric_name TEXT NOT NULL,
	// 	dataset_source TEXT NOT NULL
	// );`

	// _, err = db.Exec(createTable)
	// if err != nil {
	// 	slog.Error("failed to create table", "err", err)
	// }

	m := model.RegisterModelMetadata{
		Name:              metadata.Name,
		Version:           metadata.Version,
		CreatedAt:         ptrTime(time.Now()),
		ModelPath:         metadata.ModelPath,
		ContainerLocation: metadata.ContainerLocation,
		MetricName:        metadata.MetricName,
		MetricValue:       metadata.MetricValue,
		DatasetSource:     metadata.DatasetSource,
	}

	_, err = db.Exec("INSERT INTO model_metadata (name, version, created_at, model_path, container_location, metric_name, metric_value, dataset_source) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
		m.Name, m.Version, m.CreatedAt, m.ModelPath, m.ContainerLocation, m.MetricName, m.MetricValue, m.DatasetSource)
	if err != nil {
		slog.Error("failed to insert data", "err", err)
	}

	w.WriteHeader(http.StatusCreated)
	slog.Info("Model registered successfully")
	json.NewEncoder(w).Encode(map[string]string{"status": "Model registered successfully"})
}
