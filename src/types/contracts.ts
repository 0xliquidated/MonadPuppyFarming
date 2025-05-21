import { BaseContract, BigNumberish } from "ethers";

export interface ContractTransaction {
  wait(): Promise<any>;
}

export interface PuppyFarmContract extends BaseContract {
  mintPuppy(overrides?: { value: BigNumberish }): Promise<ContractTransaction>;
  stake(overrides?: { value: BigNumberish }): Promise<ContractTransaction>;
  unstake(amount: BigNumberish): Promise<ContractTransaction>;
  emergencyWithdraw(): Promise<ContractTransaction>;
  feedPuppy(puppyId: BigNumberish): Promise<ContractTransaction>;
  getPuppies(owner: string): Promise<Array<[BigNumberish, BigNumberish, BigNumberish]>>;
  stakedAmount(owner: string): Promise<BigNumberish>;
  bonesBalance(owner: string): Promise<BigNumberish>;
  getPendingBones(user: string): Promise<BigNumberish>;
  owner(): Promise<string>;
  claimBones(): Promise<ContractTransaction>;
} 