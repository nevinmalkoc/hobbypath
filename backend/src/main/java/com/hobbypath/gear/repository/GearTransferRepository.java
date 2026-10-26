package com.hobbypath.gear.repository;

import com.hobbypath.gear.entity.GearTransfer;
import com.hobbypath.gear.entity.TransferStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GearTransferRepository extends JpaRepository<GearTransfer, Long> {
    List<GearTransfer> findByStatusOrderByCreatedAtDesc(TransferStatus status);
    List<GearTransfer> findByHobbyIdAndStatusOrderByCreatedAtDesc(Long hobbyId, TransferStatus status);
    List<GearTransfer> findByOwnerIdOrderByCreatedAtDesc(Long ownerId);
}
