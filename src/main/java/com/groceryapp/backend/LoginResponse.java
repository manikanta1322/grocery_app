package com.groceryapp.backend;

public class LoginResponse {
    private int status;
    private String message;
    private String authId;
    private String fullName;
    private String phoneNumber;

    public LoginResponse(int status, String message, String authId, String fullName, String phoneNumber) {
        this.status = status;
        this.message = message;
        this.authId = authId;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
    }

    public int getStatus() {
        return status;
    }

    public String getMessage() {
        return message;
    }

    public String getAuthId() {
        return authId;
    }

    public String getFullName() {
        return fullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

}
