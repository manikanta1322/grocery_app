package com.groceryapp.backend;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GreetingController {
    @GetMapping("/hello")
    public String sayHello() {
        return "Hello from your Java Backend! (via VS Code)";
    }
}