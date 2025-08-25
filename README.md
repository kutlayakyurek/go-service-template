# Go Service Template

## Sample Project Structure

```text
project/
├── cmd/[api](api)
│   └── app/
│       └── main.go      # Main application logic
├── internal/
│   ├── user/            # Feature: User
│   │   ├── handler/      # User-specific HTTP Handlers
│   │   ├── service/      # User-specific Business Logic
│   │   ├── repository/   # User-specific Data Access
│   │   ├── model/        # User Models
│   │   └── gen/          # OpenApi Generated Models and Interfaces
│   ├── product/         # Feature: Product
│   │   ├── handler/      # Product-specific HTTP Handlers
│   │   ├── service/      # Product-specific Business Logic
│   │   ├── repository/   # Product-specific Data Access
│   │   ├── model/        # Product Models
│   │   └── gen/          # OpenApi Generated Models and Interfaces
├── pkg/                 # Shared utilities or helpers
│   └── logger.go        # Logging utilities
├── configs/             # Configuration files
├── go.mod               # Go module definition
└── go.sum               # Go module checksum file