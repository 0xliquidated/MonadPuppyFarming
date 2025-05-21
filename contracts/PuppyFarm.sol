// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PuppyFarm {
    address public owner;
    
    struct Puppy {
        uint256 level;
        uint256 feedCost;
        uint256 mintTime;
    }
    
    mapping(address => Puppy[]) public puppies;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public lastBonesClaim;
    mapping(address => uint256) public bonesBalance;
    
    uint256 constant BASE_STAKE_MULTIPLIER = 100000; // Base bones per 10 MONAD per day
    uint256 constant INITIAL_FEED_COST = 20000; // Initial bones needed to feed a puppy
    uint256 constant MINT_COST = 1 ether; // 1 MONAD
    uint256 constant FEED_COST_INCREASE = 150; // 1.5x increase per feed (in basis points)
    uint256 constant BASIS_POINTS = 100;
    
    event PuppyMinted(address owner, uint256 puppyId);
    event PuppyFed(address owner, uint256 puppyId, uint256 newLevel, uint256 newFeedCost);
    event Staked(address owner, uint256 amount);
    event Unstaked(address owner, uint256 amount);
    event BonesClaimed(address owner, uint256 amount);
    event EmergencyWithdraw(uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
    
    function mintPuppy() external payable {
        require(msg.value == MINT_COST, "Must send 1 MONAD");
                
        puppies[msg.sender].push(Puppy({
            level: 1,
            feedCost: INITIAL_FEED_COST,
            mintTime: block.timestamp
        }));
        
        emit PuppyMinted(msg.sender, puppies[msg.sender].length - 1);
    }
    
    function stake() external payable {
        require(msg.value > 0, "Must stake more than 0");
        stakedAmount[msg.sender] += msg.value;
        lastBonesClaim[msg.sender] = block.timestamp;
        emit Staked(msg.sender, msg.value);
    }
    
    function unstake(uint256 amount) external {
        require(amount <= stakedAmount[msg.sender], "Cannot unstake more than staked");
        claimBones();
        stakedAmount[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Unstaked(msg.sender, amount);
    }

    function calculatePuppyMultiplier(address user) public view returns (uint256) {
        uint256 totalMultiplier = 100; // Start at 1x (100%)
        Puppy[] memory userPuppies = puppies[user];
        
        for(uint256 i = 0; i < userPuppies.length; i++) {
            // Each level adds 1x to the multiplier (level 1 = 1x, level 2 = 2x, etc.)
            totalMultiplier += (userPuppies[i].level - 1) * 100;
        }
        
        return totalMultiplier;
    }

    function getPendingBones(address user) public view returns (uint256) {
        if (stakedAmount[user] == 0) return 0;
        uint256 timePassed = block.timestamp - lastBonesClaim[user];
        uint256 multiplier = calculatePuppyMultiplier(user);
        return (stakedAmount[user] * BASE_STAKE_MULTIPLIER * timePassed * multiplier) / (10 ether * 1 days * 100);
    }
    
    function claimBones() public {
        uint256 pendingBones = getPendingBones(msg.sender);
        if (pendingBones > 0) {
            bonesBalance[msg.sender] += pendingBones;
            lastBonesClaim[msg.sender] = block.timestamp;
            emit BonesClaimed(msg.sender, pendingBones);
        }
    }
    
    function feedPuppy(uint256 puppyId) external {
        require(puppyId < puppies[msg.sender].length, "Invalid puppy ID");
        require(bonesBalance[msg.sender] >= puppies[msg.sender][puppyId].feedCost, "Not enough bones");
        
        uint256 currentFeedCost = puppies[msg.sender][puppyId].feedCost;
        bonesBalance[msg.sender] -= currentFeedCost;
        
        // Increase level
        puppies[msg.sender][puppyId].level += 1;
        
        // Calculate new feed cost (1.5x increase)
        uint256 newFeedCost = (currentFeedCost * FEED_COST_INCREASE) / BASIS_POINTS;
        puppies[msg.sender][puppyId].feedCost = newFeedCost;
        
        emit PuppyFed(msg.sender, puppyId, puppies[msg.sender][puppyId].level, newFeedCost);
    }
    
    function getPuppies(address owner) external view returns (Puppy[] memory) {
        return puppies[owner];
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(owner).transfer(balance);
        emit EmergencyWithdraw(balance);
    }
} 