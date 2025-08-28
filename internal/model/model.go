package model

import (
	"errors"
	"regexp"
	"time"
)

type RegisterModelMetadata struct {
	Name              string     `json:"name"`
	Version           string     `json:"version"`
	CreatedAt         *time.Time `json:"created_at,omitempty"`
	ModelPath         string     `json:"model_path"`
	ContainerLocation string     `json:"container_location"`
	MetricName        string     `json:"metric_name"`
	MetricValue       float64    `json:"metric_value"`
	DatasetSource     string     `json:"dataset_source"`
}

type HealthCheckResponse struct {
	Status string `json:"status"`
}

// IsValidSemver checks if the Version field is a valid semver string.
func (r *RegisterModelMetadata) IsValidSemver() error {
	semverRegex := `^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[\da-z\-]+(?:\.[\da-z\-]+)*)?(?:\+[\da-z\-]+(?:\.[\da-z\-]+)*)?$`
	matched, err := regexp.MatchString(semverRegex, r.Version)
	if err != nil {
		return err
	}
	if !matched {
		return errors.New("version must be a valid semver string")
	}
	return nil
}
