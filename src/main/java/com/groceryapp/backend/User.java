package com.groceryapp.backend;

import jakarta.persistence.Entity;
import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false)
    private String fullName;
    @Column(nullable = false, unique = true) 
    private String phoneNumber;
    @Column(nullable = false)
    private String password;

     public User() {}


    public User(String fullName, String phoneNumber, String password) {
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.password = password;
    }

    public Long getId() { return id; }
    public String getFullName() {return fullName;}
    public String getPhoneNumber() {return phoneNumber;}
    public String getPassword() {return password;}
    
}
