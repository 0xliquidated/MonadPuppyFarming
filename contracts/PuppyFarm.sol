// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PuppyFarm {
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
    
    function claimBones() public {
        uint256 timePassed = block.timestamp - lastBonesClaim[msg.sender];
        uint256 bonesEarned = (stakedAmount[msg.sender] * STAKE_MULTIPLIER * timePassed) / (10 ether * 1 days);
        bonesBalance[msg.sender] += bonesEarned;
        lastBonesClaim[msg.sender] = block.timestamp;
        emit BonesClaimed(msg.sender, bonesEarned);
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
} 