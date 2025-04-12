// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract FactChecker {
    enum Verdict { Pending, TrueFact, FalseFact }
    
    struct Submission {
        address submitter;
        string content; // hash or link
        uint trueVotes;
        uint falseVotes;
        Verdict finalVerdict;
        mapping(address => bool) voters; // to prevent double-voting
    }
    
    uint public submissionCount;
    mapping(uint => Submission) private submissions;
    
    event SubmissionCreated(uint id, address submitter, string content);
    event Voted(uint id, address voter, bool vote);
    event VerdictDecided(uint id, Verdict result);
    
    uint public voteThreshold = 2;
    
    // Checks if submission ID exists
    modifier validSubmission(uint _id) {
        require(_id > 0 && _id <= submissionCount, "Invalid submission ID");
        _;
    }
    
    function submitContent(string memory _content) external {
        submissionCount++;
        Submission storage s = submissions[submissionCount];
        s.submitter = msg.sender;
        s.content = _content;
        s.finalVerdict = Verdict.Pending;
        emit SubmissionCreated(submissionCount, msg.sender, _content);
    }
    
    function vote(uint _id, bool _isTrue) external validSubmission(_id) {
        Submission storage s = submissions[_id];
        require(s.finalVerdict == Verdict.Pending, "Voting closed");
        require(!s.voters[msg.sender], "Already voted");
        require(s.submitter != msg.sender, "Cannot vote on own submission");
        
        s.voters[msg.sender] = true;
        if (_isTrue) {
            s.trueVotes++;
        } else {
            s.falseVotes++;
        }
        
        emit Voted(_id, msg.sender, _isTrue);
        
        // Check if threshold reached
        if ((s.trueVotes + s.falseVotes) >= voteThreshold) {
            if (s.trueVotes > s.falseVotes) {
                s.finalVerdict = Verdict.TrueFact;
            } else {
                s.finalVerdict = Verdict.FalseFact;
            }
            emit VerdictDecided(_id, s.finalVerdict);
        }
    }
    
    // Get a single submission by ID
    function getSubmissionById(uint _id) external view validSubmission(_id) returns (
        address submitter,
        string memory content,
        uint trueVotes,
        uint falseVotes,
        Verdict finalVerdict
    ) {
        Submission storage s = submissions[_id];
        return (s.submitter, s.content, s.trueVotes, s.falseVotes, s.finalVerdict);
    }
    
    // Get all submissions (with pagination)
    function getSubmissions(uint _startIndex, uint _count) external view returns (
        uint[] memory ids,
        address[] memory submitters,
        string[] memory contents,
        uint[] memory trueVotes,
        uint[] memory falseVotes,
        Verdict[] memory finalVerdicts
    ) {
        // Ensure we don't exceed the array bounds
        uint endIndex = _startIndex + _count;
        if (endIndex > submissionCount) {
            endIndex = submissionCount;
        }
        
        // Calculate actual count of submissions to return
        uint actualCount = endIndex >= _startIndex ? endIndex - _startIndex + 1 : 0;
        
        // Initialize arrays with the correct size
        ids = new uint[](actualCount);
        submitters = new address[](actualCount);
        contents = new string[](actualCount);
        trueVotes = new uint[](actualCount);
        falseVotes = new uint[](actualCount);
        finalVerdicts = new Verdict[](actualCount);
        
        // Populate arrays with submission data
        for (uint i = 0; i < actualCount; i++) {
            uint currentId = _startIndex + i;
            if (currentId <= submissionCount) {
                Submission storage s = submissions[currentId];
                ids[i] = currentId;
                submitters[i] = s.submitter;
                contents[i] = s.content;
                trueVotes[i] = s.trueVotes;
                falseVotes[i] = s.falseVotes;
                finalVerdicts[i] = s.finalVerdict;
            }
        }
        
        return (ids, submitters, contents, trueVotes, falseVotes, finalVerdicts);
    }
    
    // Get all submissions by a specific user
    function getSubmissionsByUser(address _user) external view returns (
        uint[] memory ids,
        string[] memory contents,
        uint[] memory trueVotes,
        uint[] memory falseVotes,
        Verdict[] memory finalVerdicts
    ) {
        // First count how many submissions belong to this user
        uint userSubmissionCount = 0;
        for (uint i = 1; i <= submissionCount; i++) {
            if (submissions[i].submitter == _user) {
                userSubmissionCount++;
            }
        }
        
        // Initialize arrays with the correct size
        ids = new uint[](userSubmissionCount);
        contents = new string[](userSubmissionCount);
        trueVotes = new uint[](userSubmissionCount);
        falseVotes = new uint[](userSubmissionCount);
        finalVerdicts = new Verdict[](userSubmissionCount);
        
        // Populate arrays with the user's submission data
        uint currentIndex = 0;
        for (uint i = 1; i <= submissionCount; i++) {
            if (submissions[i].submitter == _user) {
                Submission storage s = submissions[i];
                ids[currentIndex] = i;
                contents[currentIndex] = s.content;
                trueVotes[currentIndex] = s.trueVotes;
                falseVotes[currentIndex] = s.falseVotes;
                finalVerdicts[currentIndex] = s.finalVerdict;
                currentIndex++;
            }
        }
        
        return (ids, contents, trueVotes, falseVotes, finalVerdicts);
    }
    
    // Get total number of submissions
    function getTotalSubmissions() external view returns (uint) {
        return submissionCount;
    }
    
    // Check if a user has already voted on a submission
    function hasVoted(uint _id, address _voter) external view validSubmission(_id) returns (bool) {
        return submissions[_id].voters[_voter];
    }
}