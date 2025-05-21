// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PuppyFarm {
    address public owner;
    
    struct Puppy {
        uint256 level;
        uint256 lastFed;
        uint256 mintTime;
    }
    
    mapping(address => Puppy[]) public puppies;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public lastBonesClaim;
    mapping(address => uint256) public bonesBalance;
    
    uint256 constant STAKE_MULTIPLIER = 100000; // Bones per 10 MONAD per day
    uint256 constant FEED_COST = 20000; // Bones needed to feed a puppy
    uint256 constant MINT_COST = 1 ether; // 1 MONAD
    uint256 constant MINT_COOLDOWN = 1 days;
    
    event PuppyMinted(address owner, uint256 puppyId);
    event PuppyFed(address owner, uint256 puppyId, uint256 newLevel);
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
        require(puppies[msg.sender].length == 0 || 
                block.timestamp >= puppies[msg.sender][puppies[msg.sender].length - 1].mintTime + MINT_COOLDOWN,
                "Can only mint one puppy per day");
                
        puppies[msg.sender].push(Puppy({
            level: 1,
            lastFed: block.timestamp,
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

    function getPendingBones(address user) public view returns (uint256) {
        if (stakedAmount[user] == 0) return 0;
        uint256 timePassed = block.timestamp - lastBonesClaim[user];
        return (stakedAmount[user] * STAKE_MULTIPLIER * timePassed) / (10 ether * 1 days);
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
        require(bonesBalance[msg.sender] >= FEED_COST, "Not enough bones");
        require(block.timestamp >= puppies[msg.sender][puppyId].lastFed + 1 days, "Can only feed once per day");
        
        bonesBalance[msg.sender] -= FEED_COST;
        puppies[msg.sender][puppyId].level += 1;
        puppies[msg.sender][puppyId].lastFed = block.timestamp;
        
        emit PuppyFed(msg.sender, puppyId, puppies[msg.sender][puppyId].level);
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