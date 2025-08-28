CREATE TABLE model_metadata (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(100) NOT NULL,
    created_at TIMESTAMP,
    model_path TEXT NOT NULL,
    container_location TEXT NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DOUBLE PRECISION NOT NULL,
    dataset_source TEXT NOT NULL
);
