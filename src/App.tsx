import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import './App.css';
import { PUPPY_FARM_ADDRESS, PUPPY_FARM_ABI } from './contracts/PuppyFarm';

interface Puppy {
  level: number;
  lastFed: number;
  mintTime: number;
}

function App() {
  const [account, setAccount] = useState<string>('');
  const [provider, setProvider] = useState<ethers.BrowserProvider | null>(null);
  const [contract, setContract] = useState<ethers.Contract | null>(null);
  const [puppies, setPuppies] = useState<Puppy[]>([]);
  const [stakedAmount, setStakedAmount] = useState<string>('0');
  const [bonesBalance, setBonesBalance] = useState<string>('0');
  const [pendingBones, setPendingBones] = useState<string>('0');
  const [stakeAmount, setStakeAmount] = useState<string>('');
  const [unstakeAmount, setUnstakeAmount] = useState<string>('');
  const [isOwner, setIsOwner] = useState<boolean>(false);

  useEffect(() => {
    const init = async () => {
      if (window.ethereum) {
        const provider = new ethers.BrowserProvider(window.ethereum);
        setProvider(provider);
        
        try {
          const accounts = await provider.send("eth_requestAccounts", []);
          setAccount(accounts[0]);
          
          const contract = new ethers.Contract(PUPPY_FARM_ADDRESS, PUPPY_FARM_ABI, provider);
          setContract(contract);
          
          // Check if user is owner
          const contractOwner = await contract.owner();
          setIsOwner(accounts[0].toLowerCase() === contractOwner.toLowerCase());
          
          // Load initial data
          await loadUserData(accounts[0], contract);
        } catch (err) {
          console.error("User denied account access");
        }
      }
    };

    init();
  }, []);

  // Update pending bones every 5 seconds
  useEffect(() => {
    if (!contract || !account) return;

    const updatePendingBones = async () => {
      try {
        const pending = await contract.getPendingBones(account);
        setPendingBones(pending.toString());
      } catch (error) {
        console.error("Error updating pending bones:", error);
      }
    };

    const interval = setInterval(updatePendingBones, 5000);
    updatePendingBones(); // Initial update

    return () => clearInterval(interval);
  }, [contract, account]);

  const loadUserData = async (userAddress: string, contract: ethers.Contract) => {
    try {
      const [puppies, stakedAmount, bonesBalance, pendingBones] = await Promise.all([
        contract.getPuppies(userAddress),
        contract.stakedAmount(userAddress),
        contract.bonesBalance(userAddress),
        contract.getPendingBones(userAddress)
      ]);

      setPuppies(puppies);
      setStakedAmount(stakedAmount.toString());
      setBonesBalance(bonesBalance.toString());
      setPendingBones(pendingBones.toString());
    } catch (error) {
      console.error("Error loading user data:", error);
    }
  };

  const mintPuppy = async () => {
    if (!provider || !account || !contract) return;
    
    try {
      const signer = await provider.getSigner();
      const contractWithSigner = contract.connect(signer);
      
      const tx = await contractWithSigner.mintPuppy({
        value: ethers.parseEther("1")
      });
      await tx.wait();
      
      await loadUserData(account, contract);
    } catch (error) {
      console.error("Error minting puppy:", error);
    }
  };

  const stake = async () => {
    if (!provider || !account || !stakeAmount || !contract) return;
    
    try {
      const signer = await provider.getSigner();
      const contractWithSigner = contract.connect(signer);
      
      const tx = await contractWithSigner.stake({
        value: ethers.parseEther(stakeAmount)
      });
      await tx.wait();
      
      setStakeAmount('');
      await loadUserData(account, contract);
    } catch (error) {
      console.error("Error staking:", error);
    }
  };

  const unstake = async () => {
    if (!provider || !account || !unstakeAmount || !contract) return;
    
    try {
      const signer = await provider.getSigner();
      const contractWithSigner = contract.connect(signer);
      
      const tx = await contractWithSigner.unstake(ethers.parseEther(unstakeAmount));
      await tx.wait();
      
      setUnstakeAmount('');
      await loadUserData(account, contract);
    } catch (error) {
      console.error("Error unstaking:", error);
    }
  };

  const emergencyWithdraw = async () => {
    if (!provider || !account || !contract || !isOwner) return;
    
    try {
      const signer = await provider.getSigner();
      const contractWithSigner = contract.connect(signer);
      
      const tx = await contractWithSigner.emergencyWithdraw();
      await tx.wait();
    } catch (error) {
      console.error("Error emergency withdrawing:", error);
    }
  };

  const feedPuppy = async (puppyId: number) => {
    if (!provider || !account || !contract) return;
    
    try {
      const signer = await provider.getSigner();
      const contractWithSigner = contract.connect(signer);
      
      const tx = await contractWithSigner.feedPuppy(puppyId);
      await tx.wait();
      
      await loadUserData(account, contract);
    } catch (error) {
      console.error("Error feeding puppy:", error);
    }
  };

  const formatTimeLeft = (timestamp: number) => {
    const now = Math.floor(Date.now() / 1000);
    const diff = timestamp - now;
    if (diff <= 0) return "Ready";
    const hours = Math.floor(diff / 3600);
    const minutes = Math.floor((diff % 3600) / 60);
    return `${hours}h ${minutes}m`;
  };

  return (
    <div className="app">
      <header>
        <h1>🐕 Monad Puppy Farm 🐕</h1>
        {account ? (
          <p>Connected: {account.slice(0, 6)}...{account.slice(-4)}</p>
        ) : (
          <button onClick={() => window.ethereum?.request({ method: 'eth_requestAccounts' })}>
            Connect Wallet
          </button>
        )}
      </header>

      <div className="stats">
        <div className="stat-box">
          <h3>Staked MONAD</h3>
          <p>{ethers.formatEther(stakedAmount)} MONAD</p>
          <div className="stake-input">
            <input
              type="number"
              placeholder="Amount to stake"
              value={stakeAmount}
              onChange={(e) => setStakeAmount(e.target.value)}
              min="0"
              step="0.1"
            />
            <button onClick={stake}>Stake</button>
          </div>
          <div className="stake-input">
            <input
              type="number"
              placeholder="Amount to unstake"
              value={unstakeAmount}
              onChange={(e) => setUnstakeAmount(e.target.value)}
              min="0"
              step="0.1"
            />
            <button onClick={unstake}>Unstake</button>
          </div>
        </div>

        <div className="stat-box">
          <h3>$BONES Balance</h3>
          <p>{bonesBalance} BONES</p>
          <p className="pending-bones">Pending: {pendingBones} BONES</p>
          <button onClick={() => contract?.claimBones()}>Claim Bones</button>
        </div>
      </div>

      <div className="actions">
        <button onClick={mintPuppy} className="mint-button">
          Mint Puppy (1 MONAD)
        </button>
        {isOwner && (
          <button onClick={emergencyWithdraw} className="emergency-button">
            Emergency Withdraw
          </button>
        )}
      </div>

      <div className="puppies">
        {puppies.map((puppy, index) => (
          <div key={index} className="puppy-card">
            <div className="puppy-emoji">🐕</div>
            <p>Level {puppy.level}</p>
            <p className="cooldown">
              Next Feed: {formatTimeLeft(Number(puppy.lastFed) + 24 * 60 * 60)}
            </p>
            <button 
              onClick={() => feedPuppy(index)}
              className="feed-button"
              disabled={Date.now() / 1000 < Number(puppy.lastFed) + 24 * 60 * 60}
            >
              Feed (20,000 BONES)
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App; 