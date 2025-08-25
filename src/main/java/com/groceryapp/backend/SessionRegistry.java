// File: src/main/java/com/groceryapp/backend/SessionRegistry.java

package com.groceryapp.backend;

import org.springframework.stereotype.Component;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * A simple in-memory session store.
 * This class keeps track of all active user sessions.
 * It maps a unique session token (authId) to a user's ID.
 * The @Component annotation tells Spring to create a single instance (a "bean")
 * of this class when the application starts, so it can be injected into other
 * classes like AuthController.
 */
@Component
public class SessionRegistry {

    // We use a Map to store our sessions.
    // The key is the String authId (the token).
    // The value is the Long userId.
    // ConcurrentHashMap is used because it's safe for multi-threaded environments (multiple API requests at once).
    private static final Map<String, Long> SESSIONS = new ConcurrentHashMap<>();

    /**
     * Registers a new session when a user successfully logs in.
     * @param authId The unique token generated for this session.
     * @param userId The ID of the user who logged in.
     */
    public void registerSession(String authId, Long userId) {
        SESSIONS.put(authId, userId);
        System.out.println("Session Registered: Token " + authId + " for User ID " + userId);
        System.out.println("Total active sessions: " + SESSIONS.size());
    }

    /**
     * Retrieves the user ID associated with a given session token.
     * This is used to verify if a token is valid.
     * @param authId The session token from the Authorization header.
     * @return The user's ID if the session is valid, otherwise null.
     */
    public Long getUserIdForSession(String authId) {
        return SESSIONS.get(authId);
    }

    /**
     * Removes a session, effectively logging the user out.
     * @param authId The session token to remove.
     */
    public void removeSession(String authId) {
        SESSIONS.remove(authId);
        System.out.println("Session Removed: Token " + authId);
    }
}