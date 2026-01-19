package main

import (
	"context"
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type HealthCheckResponse struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	response := HealthCheckResponse{
		Status:  "healthy",
		Message: "Service is running normally",
	}

	body, err := json.Marshal(response)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       `{"status":"error","message":"Internal server error"}`,
			Headers: map[string]string{
				"Content-Type": "application/json",
			},
		}, err
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(body),
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
	}, nil
}

func main() {
	lambda.Start(handler)
}
