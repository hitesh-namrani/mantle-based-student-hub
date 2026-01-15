// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DCHToken is ERC20 {
    address public admin;

    constructor() ERC20("Student Hub Token", "SHT") {
        admin = msg.sender;
        // Mint initial supply to admin
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    // FAUCET: Allow anyone to claim 100 tokens for testing
    function claimTokens() external {
        _mint(msg.sender, 100 * 10 ** decimals());
    }

    // ADMIN MINT: Manually give tokens to a student
    function mint(address to, uint256 amount) external {
        require(msg.sender == admin, "Only admin can mint");
        _mint(to, amount * 10 ** decimals());
    }
}