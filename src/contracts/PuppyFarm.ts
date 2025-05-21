export const PUPPY_FARM_ADDRESS = "0xD56ddc88E1D8718371C089B77F32499604193E28";

export const PUPPY_FARM_ABI = [
  "function owner() view returns (address)",
  "function puppies(address, uint256) view returns (tuple(uint256 level, uint256 feedCost, uint256 mintTime))",
  "function stakedAmount(address) view returns (uint256)",
  "function lastBonesClaim(address) view returns (uint256)",
  "function bonesBalance(address) view returns (uint256)",
  "function calculatePuppyMultiplier(address) view returns (uint256)",
  "function getPendingBones(address) view returns (uint256)",
  "function mintPuppy() payable",
  "function stake() payable",
  "function unstake(uint256)",
  "function feedPuppy(uint256)",
  "function claimBones()",
  "function getPuppies(address) view returns (tuple(uint256 level, uint256 feedCost, uint256 mintTime)[])",
  "function emergencyWithdraw()",
  "event PuppyMinted(address owner, uint256 puppyId)",
  "event PuppyFed(address owner, uint256 puppyId, uint256 newLevel, uint256 newFeedCost)",
  "event Staked(address owner, uint256 amount)",
  "event Unstaked(address owner, uint256 amount)",
  "event BonesClaimed(address owner, uint256 amount)",
  "event EmergencyWithdraw(uint256 amount)"
]; 