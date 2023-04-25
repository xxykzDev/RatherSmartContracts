// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./CustomERC20.sol";

contract DAO {
    CustomERC20 public customERC20Token;
    mapping(address => bool) public isMember;
    uint256 public initialTokenAmount = 10 * 1e18;
    uint256 public constant MAX_MEMBERS = 1000;

    struct Proposal {
        uint256 id;
        string title;
        string description;
        string optionAText;
        string optionBText;
        uint256 deadline;
        uint256 minimumVotes;
        uint256 optionA;
        uint256 optionB;
        bool executed;
        uint8 winningOption;
        mapping(address => bool) hasVoted;
    }

    uint256 public nextProposalId;
    mapping(uint256 => Proposal) public proposals;

    address public owner;

    constructor(address _customERC20Token, address _owner) {
        customERC20Token = CustomERC20(_customERC20Token);
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function setCustomERC20TokenAddress(address tokenAddress) external onlyOwner {
        require(address(customERC20Token) == address(0), "CustomERC20 token address is already set");
        customERC20Token = CustomERC20(tokenAddress);
    }

    function joinDAO() external {
        require(!isMember[msg.sender], "User is already a member");
        isMember[msg.sender] = true;
        
        // Mint tokens to the new member
        customERC20Token.mintTo(msg.sender, initialTokenAmount);

        // Approve the DAO to spend the new member's tokens
        customERC20Token.internalApprove(msg.sender, address(this), initialTokenAmount);
    }

    function createProposal (
        string calldata title,
        string calldata description,
        uint256 duration,
        uint256 minimumVotes,
        string calldata optionAText,
        string calldata optionBText
    ) external onlyOwner {
        require(isMember[msg.sender], "Only members can create proposals");

        Proposal storage newProposal = proposals[nextProposalId++];
        newProposal.id = nextProposalId - 1;
        newProposal.title = title;
        newProposal.description = description;
        newProposal.optionAText = optionAText; // Agregamos las opciones A y B
        newProposal.optionBText = optionBText;
        newProposal.deadline = block.timestamp + duration;
        newProposal.minimumVotes = minimumVotes;
        newProposal.executed = false;
    }

    function vote(uint256 proposalId, bool supportsOptionA) external {        
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting period has ended");
        require(isMember[msg.sender], "Only members can vote");
        require(!proposal.hasVoted[msg.sender], "User has already voted");

        customERC20Token.burnFrom(msg.sender, 1 * 1e18);

        if (supportsOptionA) {
            proposal.optionA += 1;
        } else {
            proposal.optionB += 1;
        }
        proposal.hasVoted[msg.sender] = true;
    }

    function finalizeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period is still ongoing");
        require(!proposal.executed, "Proposal has already been executed");
        require(proposal.optionA + proposal.optionB >= proposal.minimumVotes, "Minimum votes not reached");

        proposal.executed = true;

        // Determina la opción ganadora automáticamente
        if (proposal.optionA > proposal.optionB) {
            proposal.winningOption = 1; // Opción A ganó
        } else if (proposal.optionB > proposal.optionA) {
            proposal.winningOption = 2; // Opción B ganó
        } else {
            // Empate: ninguna opción ganó, puede agregar lógica adicional si es necesario
            proposal.winningOption = 0;
        }
    }


}