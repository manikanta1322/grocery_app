package com.groceryapp.backend;

// This is a generic "Data Transfer Object" (DTO) for our API responses.
public class ApiResponse {

    private int status;
    private String message;
    // You could add more fields here later, like 'data' or 'errorDetails'

    public ApiResponse(int status, String message) {
        this.status = status;
        this.message = message;
    }

    // --- IMPORTANT ---
    // Getters are required for the Jackson JSON library to be able to "see"
    // these fields and convert them into a JSON response. Without them,
    // you would get an empty JSON object: {}
    public int getStatus() {
        return status;
    }

    public String getMessage() {
        return message;
    }
}