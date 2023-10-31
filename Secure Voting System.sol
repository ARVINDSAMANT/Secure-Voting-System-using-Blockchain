// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2;

contract ElectionFactory {
    // Struct to store details of an election
    struct ElectionDetails {
        address deployedAddress; 
        string electionName;
        string electionDescription;
    }

    // Mapping to store election details by email
    mapping(string => ElectionDetails) public elections;

    // Function to create a new election
    function createElection(string memory email, string memory electionName, string memory electionDescription) public {
        // Check if an election with the given email already exists
        require(elections[email].deployedAddress == address(0), "An election with this email already exists.");
        
        // Create a new instance of the Election contract
        address newElection = address(new Election(msg.sender, electionName, electionDescription));
        
        // Store the election details in the mapping
        elections[email] = ElectionDetails(newElection, electionName, electionDescription);
    }

    // Function to get the details of a deployed election
    function getDeployedElection(string memory email) public view returns (address, string memory, string memory) {
        ElectionDetails memory details = elections[email];
        // Check if the election exists
        require(details.deployedAddress != address(0), "No election found with this email.");
        return (details.deployedAddress, details.electionName, details.electionDescription);
    }
}

contract Election {
    // Election contract variables
    address public electionAuthority;
    string public electionName;
    string public electionDescription;
    bool public isActive;

    // Constructor to initialize the Election contract
    constructor(address authority, string memory name, string memory description) {
        electionAuthority = authority;
        electionName = name;
        electionDescription = description;
        isActive = true;
    }

    // Modifier to restrict access to certain functions to the election authority
    modifier onlyAuthority() {
        require(msg.sender == electionAuthority, "Only the election authority can call this function.");
        _;
    }

    // Struct to represent a candidate
    struct Candidate {
        string name;
        string description;
        string imgHash;
        uint256 voteCount;
    }

    // Array to store candidates
    Candidate[] public candidates;

    // Mapping to track whether an address has voted
    mapping(address => bool) public hasVoted;

    // Function to add a candidate to the election
    function addCandidate(string memory name, string memory description, string memory imgHash) public onlyAuthority {
        require(isActive, "Election is not active.");
        candidates.push(Candidate(name, description, imgHash, 0));
    }

    // Function for voters to cast their vote
    function vote(uint256 candidateIndex) public {
        require(isActive, "Election is not active.");
        require(!hasVoted[msg.sender], "You have already voted.");
        require(candidateIndex < candidates.length, "Invalid candidate index.");

        hasVoted[msg.sender] = true;
        candidates[candidateIndex].voteCount++;
    }

    // Function to end the election
    function endElection() public onlyAuthority {
        isActive = false;
    }

    // Function to get the number of candidates
    function getNumCandidates() public view returns (uint256) {
        return candidates.length;
    }

    // Function to get the details of a candidate
    function getCandidate(uint256 candidateIndex) public view returns (string memory, string memory, string memory, uint256) {
        require(candidateIndex < candidates.length, "Invalid candidate index.");
        Candidate memory candidate = candidates[candidateIndex];
        return (candidate.name, candidate.description, candidate.imgHash, candidate.voteCount);
    }

    // Function to get the winner of the election
    function getWinner() public view returns (string memory, uint256) {
        require(!isActive, "Election is still active.");
        uint256 winningVoteCount = 0;
        string memory winningCandidateName;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateName = candidates[i].name;
            }
        }

        return (winningCandidateName, winningVoteCount);
    }
}
