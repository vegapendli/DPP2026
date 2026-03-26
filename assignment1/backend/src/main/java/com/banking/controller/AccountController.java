package com.banking.controller;

import com.banking.dto.AccountRequest;
import com.banking.model.Account;
import com.banking.repository.AccountRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
public class AccountController {

    private final AccountRepository repo;

    public AccountController(AccountRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "healthy", "service", "backend");
    }

    @GetMapping("/api/accounts")
    public List<Account> listAccounts() {
        return repo.findAll();
    }

    @GetMapping("/api/accounts/{id}")
    public Account getAccount(@PathVariable Long id) {
        return repo.findById(id)
            .orElseThrow(() -> new ResponseStatusException(
                HttpStatus.NOT_FOUND, "Account not found"));
    }

    @PostMapping("/api/accounts")
    public ResponseEntity<Account> createAccount(
            @Valid @RequestBody AccountRequest request) {
        if (repo.existsByEmail(request.getEmail())) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST, "Email already exists");
        }
        Account account = new Account(
            request.getName(),
            request.getEmail(),
            request.getBalance()
        );
        Account saved = repo.save(account);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }
}