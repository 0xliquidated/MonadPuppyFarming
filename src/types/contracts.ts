import { BaseContract, ContractTransactionResponse } from 'ethers';

export interface PuppyStruct {
  level: bigint;
  feedCost: bigint;
  mintTime: bigint;
}

export interface PuppyFarmContract extends BaseContract {
  owner(): Promise<string>;
  puppies(address: string, index: number): Promise<[bigint, bigint, bigint]>;
  stakedAmount(address: string): Promise<bigint>;
  lastBonesClaim(address: string): Promise<bigint>;
  bonesBalance(address: string): Promise<bigint>;
  calculatePuppyMultiplier(address: string): Promise<bigint>;
  getPendingBones(address: string): Promise<bigint>;
  mintPuppy(options?: { value: bigint }): Promise<ContractTransactionResponse>;
  stake(options?: { value: bigint }): Promise<ContractTransactionResponse>;
  unstake(amount: bigint): Promise<ContractTransactionResponse>;
  feedPuppy(puppyId: number): Promise<ContractTransactionResponse>;
  claimBones(): Promise<ContractTransactionResponse>;
  getPuppies(address: string): Promise<[bigint, bigint, bigint][]>;
  emergencyWithdraw(): Promise<ContractTransactionResponse>;
} 