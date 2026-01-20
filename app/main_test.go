package main

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/aws/aws-lambda-go/events"
)

func TestHandler(t *testing.T) {
	ctx := context.Background()

	request := events.APIGatewayProxyRequest{
		HTTPMethod: "GET",
		Path:       "/health",
	}

	response, err := handler(ctx, request)
	if err != nil {
		t.Fatalf("Handler returned an error: %v", err)
	}

	if response.StatusCode != 200 {
		t.Errorf("Expected status code 200, got %d", response.StatusCode)
	}

	var healthResponse HealthCheckResponse
	if err := json.Unmarshal([]byte(response.Body), &healthResponse); err != nil {
		t.Fatalf("Failed to unmarshal response: %v", err)
	}

	if healthResponse.Status != "Healthy" {
		t.Errorf("Expected status 'Healthy', got '%s'", healthResponse.Status)
	}

	if healthResponse.Message != "Service is running normally" {
		t.Errorf("Expected message 'Service is running normally', got '%s'", healthResponse.Message)
	}

	contentType := response.Headers["Content-Type"]
	if contentType != "application/json" {
		t.Errorf("Expected Content-Type 'application/json', got '%s'", contentType)
	}
}
