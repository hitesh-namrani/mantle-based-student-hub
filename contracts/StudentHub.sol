// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

// 1. Interface (Rules)
interface ISemaphore {
    function createGroup(uint256 groupId, address admin) external;
    function addMember(uint256 groupId, uint256 identityCommitment) external;
    function verifyProof(
        uint256 groupId,
        uint256 merkleTreeRoot,
        uint256 signal,
        uint256 nullifierHash,
        uint256 externalNullifier,
        uint256[8] calldata proof
    ) external view;
}

// 2. The Main Contract (Deploy this SECOND)
contract StudentHub is Ownable {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    ISemaphore public semaphore;
    uint256 public groupId;
    address public backendSigner; 

    event NewGrievance(uint256 indexed groupId, uint256 merkleTreeRoot, string ipfsHash);
    event MemberJoined(uint256 identityCommitment);

    constructor(address _semaphoreAddress, address _backendSigner) Ownable(msg.sender) {
        semaphore = ISemaphore(_semaphoreAddress);
        backendSigner = _backendSigner;
    }

    function createGroup(uint256 _groupId) external onlyOwner {
        groupId = _groupId;
        // Try/Catch allows us to use the Mock without crashing
        try semaphore.createGroup(groupId, address(this)) {} catch {}
    }

    function joinGroup(uint256 identityCommitment, bytes calldata signature) external {
        bytes32 hash = keccak256(abi.encodePacked(identityCommitment));
        bytes32 ethSignedHash = hash.toEthSignedMessageHash();
        
        address recoveredSigner = ethSignedHash.recover(signature);
        require(recoveredSigner == backendSigner, "Invalid backend signature");

        semaphore.addMember(groupId, identityCommitment);
        emit MemberJoined(identityCommitment);
    }

    function postGrievance(
        uint256 merkleTreeRoot,
        uint256 nullifierHash,
        uint256[8] calldata proof,
        string calldata ipfsHash
    ) external {
        uint256 signal = uint256(keccak256(abi.encodePacked(ipfsHash))) >> 8;

        semaphore.verifyProof(
            groupId,
            merkleTreeRoot,
            signal,
            nullifierHash,
            groupId, 
            proof
        );

        emit NewGrievance(groupId, merkleTreeRoot, ipfsHash);
    }
}

// 3. Mock Semaphore (Deploy this FIRST)
contract MockSemaphore is ISemaphore {
    function createGroup(uint256 groupId, address admin) external {}
    function addMember(uint256 groupId, uint256 identityCommitment) external {}
    
    // Always returns true for testing
    function verifyProof(
        uint256 groupId,
        uint256 merkleTreeRoot,
        uint256 signal,
        uint256 nullifierHash,
        uint256 externalNullifier,
        uint256[8] calldata proof
    ) external pure {}
}