package com.groceryapp.backend;

// --- Step 1: Add the necessary new imports ---
import org.springframework.beans.factory.annotation.Autowired;
// You can remove these unused imports if you like:
// import java.util.Map;
// import java.util.concurrent.ConcurrentHashMap;

// --- Step 2: Keep your existing imports ---
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.HttpHeaders;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    // ADD the UserRepository. Spring will provide it automatically. ---
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private SessionRegistry sessionRegistry;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse> registerUser(@RequestBody RegistrationRequest request) {
        // Validation for password matching remains the same
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            ApiResponse response = new ApiResponse(HttpStatus.BAD_REQUEST.value(), "Error: Passwords do not match.");
            return ResponseEntity.badRequest().body(response);
        }

        if (userRepository.findByPhoneNumber(request.getPhoneNumber()).isPresent()) {
            ApiResponse response = new ApiResponse(HttpStatus.CONFLICT.value(),
                    "Error: Phone number already registered.");
            return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
        }

        User newUser = new User(request.getFullName(), request.getPhoneNumber(), request.getPassword());

        // CHANGE the logic to save to the database ---
        userRepository.save(newUser);

        // This line is good for debugging, you can keep it or remove it
        System.out.println("New User Registered to MySQL DB: " + newUser.getFullName());

        // The success response remains the same
        ApiResponse response = new ApiResponse(HttpStatus.CREATED.value(), "User registered successfully.");
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody LoginRequest loginRequest) {
        Optional<User> userOptional = userRepository.findByPhoneNumber(loginRequest.getPhoneNumber());

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            if (user.getPassword().equals(loginRequest.getPassword())) {
                String authId = UUID.randomUUID().toString();
                sessionRegistry.registerSession(authId, user.getId());

                HttpHeaders headers = new HttpHeaders();
                headers.add("Authorization", "Bearer " + authId);

                LoginResponse response = new LoginResponse(HttpStatus.OK.value(), "Login Successful", authId,
                        user.getFullName(), user.getPhoneNumber());
                return new ResponseEntity<>(response, headers, HttpStatus.OK);
            }
        }
        ApiResponse errorResponse = new ApiResponse(HttpStatus.UNAUTHORIZED.value(),
                "Invalid phone number or password");
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
    }

}