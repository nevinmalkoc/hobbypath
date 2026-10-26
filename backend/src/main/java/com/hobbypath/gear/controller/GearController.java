package com.hobbypath.gear.controller;

import com.hobbypath.gear.dto.CreateGearTransferRequest;
import com.hobbypath.gear.dto.GearTransferResponse;
import com.hobbypath.gear.dto.StarterGearResponse;
import com.hobbypath.gear.entity.TransferStatus;
import com.hobbypath.gear.entity.TransferType;
import com.hobbypath.gear.service.GearService;
import com.hobbypath.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/gear")
@RequiredArgsConstructor
public class GearController {

    private final GearService gearService;

    @GetMapping("/guide")
    public ResponseEntity<List<StarterGearResponse>> getStarterGears(
            @RequestParam(required = false) Long hobbyId
    ) {
        return ResponseEntity.ok(gearService.getStarterGears(hobbyId));
    }

    @GetMapping("/transfers")
    public ResponseEntity<List<GearTransferResponse>> getTransfers(
            @RequestParam(required = false) Long hobbyId,
            @RequestParam(required = false) TransferType type
    ) {
        return ResponseEntity.ok(gearService.getTransfers(hobbyId, type));
    }

    @PostMapping("/transfers")
    public ResponseEntity<GearTransferResponse> createTransfer(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CreateGearTransferRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED).body(gearService.createTransfer(user, request));
    }

    @PatchMapping("/transfers/{id}/status")
    public ResponseEntity<GearTransferResponse> updateStatus(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestParam TransferStatus status
    ) {
        return ResponseEntity.ok(gearService.updateTransferStatus(user, id, status));
    }

    @DeleteMapping("/transfers/{id}")
    public ResponseEntity<Void> deleteTransfer(
            @AuthenticationPrincipal User user,
            @PathVariable Long id
    ) {
        gearService.deleteTransfer(user, id);
        return ResponseEntity.noContent().build();
    }
}
