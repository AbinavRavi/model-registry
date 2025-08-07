# Model Registry Makefile

# Variables
BINARY_SERVER = bin/model-registry-server
BINARY_CLI = bin/model-registry-cli
SERVER_SOURCE = ./cmd/server
CLI_SOURCE = ./cmd/cli
BIN_DIR = bin

# Go variables
GOCMD = go
GOBUILD = $(GOCMD) build
GOCLEAN = $(GOCMD) clean
GOTEST = $(GOCMD) test
GOGET = $(GOCMD) get
GOMOD = $(GOCMD) mod
GOFMT = $(GOCMD) fmt

# Build flags
LDFLAGS = -ldflags "-s -w"
BUILD_FLAGS = -v

.PHONY: all build build-server build-cli clean test deps fmt vet lint pre-commit-install pre-commit-run pre-commit-check help

# Default target
all: build

# Build all binaries
build: build-server build-cli
	@echo "Build completed successfully!"
	@echo "Binaries are available in the ./$(BIN_DIR) directory:"
	@echo "  - $(BINARY_SERVER)"
	@echo "  - $(BINARY_CLI)"

# Build server binary
build-server: $(BIN_DIR)
	@echo "Building server..."
	$(GOBUILD) $(BUILD_FLAGS) $(LDFLAGS) -o $(BINARY_SERVER) $(SERVER_SOURCE)

# Build CLI binary
build-cli: $(BIN_DIR)
	@echo "Building CLI..."
	$(GOBUILD) $(BUILD_FLAGS) $(LDFLAGS) -o $(BINARY_CLI) $(CLI_SOURCE)

# Create bin directory if it doesn't exist
$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

# Clean build artifacts
clean:
	@echo "Cleaning..."
	$(GOCLEAN)
	@rm -rf $(BIN_DIR)
	@echo "Clean completed!"

# Run tests
test:
	@echo "Running tests..."
	$(GOTEST) -v ./...

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	$(GOTEST) -v -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Download dependencies
deps:
	@echo "Downloading dependencies..."
	$(GOMOD) download
	$(GOMOD) tidy

# Format code
fmt:
	@echo "Formatting code..."
	$(GOFMT) ./...

# Run go vet
vet:
	@echo "Running go vet..."
	$(GOCMD) vet ./...

# Run linter (requires golangci-lint)
lint:
	@echo "Running linter..."
	golangci-lint run

# Pre-commit hooks setup and management
pre-commit-install:
	@echo "Setting up pre-commit hooks..."
	@if ! command -v pre-commit >/dev/null 2>&1; then \
		echo "pre-commit is not installed. Installing via pip..."; \
		pip install pre-commit; \
	fi
	@echo "Installing pre-commit hooks..."
	pre-commit install
	@echo "Installing commit-msg hook..."
	pre-commit install --hook-type commit-msg
	@if ! command -v golangci-lint >/dev/null 2>&1; then \
		echo "golangci-lint is not installed. Installing..."; \
		curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $$(go env GOPATH)/bin v1.54.2; \
	fi
	@if ! command -v gofumpt >/dev/null 2>&1; then \
		echo "gofumpt is not installed. Installing..."; \
		go install mvdan.cc/gofumpt@latest; \
	fi
	@echo "Pre-commit setup completed!"
	@echo ""
	@echo "You can now:"
	@echo "  - Run 'make pre-commit-run' to check all files"
	@echo "  - Run 'make fmt' to format code"
	@echo "  - Run 'make lint' to run linter"
	@echo ""
	@echo "Pre-commit hooks will automatically run on git commit."

# Run pre-commit on all files
pre-commit-run:
	@echo "Running pre-commit on all files..."
	pre-commit run --all-files

# Check if pre-commit passes (useful for CI)
pre-commit-check:
	@echo "Checking pre-commit status..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files; \
	else \
		echo "pre-commit is not installed. Run 'make pre-commit-install' first."; \
		exit 1; \
	fi

# Initialize go module (run once)
init:
	@echo "Initializing Go module..."
	$(GOMOD) init github.com/AbinavRavi/model-registry

# Install binaries to GOPATH/bin
install: build
	@echo "Installing binaries..."
	$(GOCMD) install $(SERVER_SOURCE)
	$(GOCMD) install $(CLI_SOURCE)

# Build for multiple platforms
build-all: build-linux build-darwin build-windows

build-linux: $(BIN_DIR)
	@echo "Building for Linux..."
	GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_SERVER)-linux-amd64 $(SERVER_SOURCE)
	GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_CLI)-linux-amd64 $(CLI_SOURCE)

build-darwin: $(BIN_DIR)
	@echo "Building for macOS..."
	GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_SERVER)-darwin-amd64 $(SERVER_SOURCE)
	GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_CLI)-darwin-amd64 $(CLI_SOURCE)
	GOOS=darwin GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_SERVER)-darwin-arm64 $(SERVER_SOURCE)
	GOOS=darwin GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_CLI)-darwin-arm64 $(CLI_SOURCE)

build-windows: $(BIN_DIR)
	@echo "Building for Windows..."
	GOOS=windows GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_SERVER)-windows-amd64.exe $(SERVER_SOURCE)
	GOOS=windows GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_CLI)-windows-amd64.exe $(CLI_SOURCE)

# Development targets
dev-server: build-server
	@echo "Starting development server..."
	./$(BINARY_SERVER)

dev-cli: build-cli
	@echo "CLI binary ready for testing..."
	@echo "Usage: ./$(BINARY_CLI) --help"

# Docker targets (if you want to add Docker support later)
docker-build:
	@echo "Building Docker image..."
	docker build -t model-registry .

docker-run:
	@echo "Running Docker container..."
	docker run -p 8080:8080 model-registry

# Help target
help:
	@echo "Available targets:"
	@echo "  all                - Build all binaries (default)"
	@echo "  build              - Build all binaries"
	@echo "  build-server       - Build server binary only"
	@echo "  build-cli          - Build CLI binary only"
	@echo "  build-all          - Build for multiple platforms"
	@echo "  clean              - Clean build artifacts"
	@echo "  test               - Run tests"
	@echo "  test-coverage      - Run tests with coverage report"
	@echo "  deps               - Download and tidy dependencies"
	@echo "  fmt                - Format code"
	@echo "  vet                - Run go vet"
	@echo "  lint               - Run linter"
	@echo "  pre-commit-install - Install and setup pre-commit hooks"
	@echo "  pre-commit-run     - Run pre-commit on all files"
	@echo "  pre-commit-check   - Check pre-commit status (useful for CI)"
	@echo "  init               - Initialize Go module"
	@echo "  install            - Install binaries to GOPATH/bin"
	@echo "  dev-server         - Build and start development server"
	@echo "  dev-cli            - Build CLI for development"
	@echo "  docker-build       - Build Docker image"
	@echo "  docker-run         - Run Docker container"
	@echo "  help               - Show this help message"
