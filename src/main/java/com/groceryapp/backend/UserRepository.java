package com.groceryapp.backend;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository // Tells Spring that this is a Repository bean
public interface UserRepository extends JpaRepository<User, Long> {

    // This is the magic method!
    // Spring Data JPA will automatically write the SQL query for:
    // "SELECT * FROM users WHERE phone_number = ?"
    // just based on this method's name.
    Optional<User> findByPhoneNumber(String phoneNumber);
}