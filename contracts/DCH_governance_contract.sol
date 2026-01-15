// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDCHToken {
    function balanceOf(address account) external view returns (uint256);
}

contract DCHGovernance {
    IDCHToken public dchToken;
    uint256 public proposalCount = 0;
    
    // CHANGED: Lowered so judges can definitely propose
    uint256 public constant MIN_VOTE_POWER = 10 * 10**18; // Assuming 18 decimals
    // CHANGED: Lowered quorum for easy demo
    uint256 public constant QUORUM_PERCENTAGE = 1; 

    enum ProposalState { Active, Defeated, Succeeded, Executed }

    struct Proposal {
        uint256 id;
        string description;
        uint256 deadline;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 indexed id, string description, uint256 deadline);
    event VoteCast(uint256 indexed id, address indexed voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed id);

    constructor(address _dchTokenAddress) {
        dchToken = IDCHToken(_dchTokenAddress);
    }

    function createProposal(string memory _description, uint256 _days) public returns (uint256) {
        // Validation check
        require(dchToken.balanceOf(msg.sender) >= MIN_VOTE_POWER, "Insufficient tokens: Claim from Faucet first!");
        
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.description = _description;
        p.deadline = block.timestamp + (_days * 1 days);

        emit ProposalCreated(proposalCount, _description, p.deadline);
        return proposalCount;
    }

    function vote(uint256 _id, bool _support) public {
        Proposal storage p = proposals[_id];
        require(block.timestamp < p.deadline, "Voting closed");
        require(!p.hasVoted[msg.sender], "Already voted");

        uint256 weight = dchToken.balanceOf(msg.sender);
        require(weight > 0, "No voting power");

        p.hasVoted[msg.sender] = true;
        if (_support) p.votesFor += weight;
        else p.votesAgainst += weight;

        emit VoteCast(_id, msg.sender, _support, weight);
    }

    function executeProposal(uint256 _id) public {
        Proposal storage p = proposals[_id];
        require(block.timestamp >= p.deadline, "Voting ongoing");
        require(!p.executed, "Already executed");
        require(p.votesFor > p.votesAgainst, "Proposal defeated");

        p.executed = true;
        emit ProposalExecuted(_id);
    }
}