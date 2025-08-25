package com.groceryapp.backend;


// This class is a "Data Transfer Object" (DTO). Its only job is to
// carry data from the client's request to our controller.  

public class RegistrationRequest {
    private String fullName;
    private String phoneNumber;
    private String password;
    private String confirmPassword;

    public String getFullName() {
        return fullName;
    }
    public String getPhoneNumber() {
        return phoneNumber;
    }
    public String getPassword() {
        return password;
    }
    public String getConfirmPassword() {
        return confirmPassword;
    }
}
