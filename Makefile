SHELL := bash
.SHELLFLAGS := -euo pipefail -c

# Directories
API_DIR := api
INTERNAL_DIR := internal

# Scripts
SCRIPTS_DIR := scripts
GENERATE_SCRIPT := $(SCRIPTS_DIR)/api/generate.sh
MERGE_SCRIPT := $(SCRIPTS_DIR)/api/merge.sh
CLEAN_SCRIPT := $(SCRIPTS_DIR)/api/clean.sh

# Outputs
OPENAPI_BUNDLE := $(API_DIR)/openapi.yaml

# Common find for spec files (excluding shared/common and output bundle)
SPEC_FILES := $(shell find "$(API_DIR)" -name '*.yaml' ! -name 'common.yaml' ! -name 'openapi.yaml')

.DEFAULT_GOAL := apis

.PHONY: help apis generate merge clean
help:
	@echo "Targets:"
	@echo "  apis     - generate code from specs and merge into a single OpenAPI bundle"
	@echo "  generate - run code generation for each API spec"
	@echo "  merge    - merge all API specs into $(OPENAPI_BUNDLE)"
	@echo "  clean    - remove generated code and the merged bundle"

apis: generate merge

generate:
	@printf '%s\0' $(SPEC_FILES) | xargs -0 -I{} "$(GENERATE_SCRIPT)" "{}" $(API_DIR) $(INTERNAL_DIR)

merge:
	"$(MERGE_SCRIPT)" "$(SPEC_FILES)" "$(OPENAPI_BUNDLE)"

clean:
	@printf '%s\0' $(SPEC_FILES) | xargs -0 -I{} "$(CLEAN_SCRIPT)" "{}" $(API_DIR) $(INTERNAL_DIR)
	@rm -f "$(BUNDLE_OUT)"