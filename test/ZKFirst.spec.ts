import { expect } from "chai";
import hre, { ethers, network } from "hardhat";
import { Wallet, Provider } from "zksync-ethers";

describe("L2BaseToken Tests", function () {
  let wallet: Wallet;
  let provider: Provider;
  let baseTokenContract: ethers.Contract;
  const BOOTLOADER_ADDRESS = "0x0000000000000000000000000000000000008001";
  const BASE_TOKEN_ADDRESS = "0x000000000000000000000000000000000000800A"; // Confirm this is correct
  const PRIVATE_KEY = "0x59c6995e998f97a5a0044966f094538f9dcfed3a1080b0c88b8b8c705cd1b0f6";

  before(async () => {
    // Initialize zkSync provider
    const zkSyncRpcUrl = process.env.ZKSYNC_RPC_URL || "https://mainnet.era.zksync.io";
    provider = new Provider(zkSyncRpcUrl);

    // Initialize wallet with private key
    wallet = new Wallet(PRIVATE_KEY, provider);

    console.log("Wallet Address:", wallet.address);

    // Impersonate the bootloader address
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [BOOTLOADER_ADDRESS],
    });

    const bootloaderSigner = await ethers.provider.getSigner(BOOTLOADER_ADDRESS);

    console.log("Bootloader Signer Address:", await bootloaderSigner.getAddress());

    // Updated ABI of the L2BaseToken contract
    const baseTokenAbi = [
      "function mint(address _account, uint256 _amount) external",
      "function balanceOf(uint256 _account) view returns (uint256)",
    ];

    // Connect to the L2BaseToken contract
    baseTokenContract = new ethers.Contract(BASE_TOKEN_ADDRESS, baseTokenAbi, bootloaderSigner);

    console.log("BaseToken Contract Connected:", BASE_TOKEN_ADDRESS);
  });

  it("should fetch and log the wallet balance", async () => {
    try {
      const accountAsUint256 = ethers.BigNumber.from(wallet.address);
      const balance = await baseTokenContract.balanceOf(accountAsUint256);
      console.log(`Wallet Balance: ${ethers.utils.formatEther(balance)} ETH`);
    } catch (error) {
      console.error("Error fetching balance:", error);
    }
  });

  it("should mint 10 ETH to the wallet", async () => {
    try {
      const accountAsUint256 = ethers.BigNumber.from(wallet.address);  
      const mintAmount = ethers.utils.parseEther("10.0"); // 10 ETH
      console.log(`Minting ${ethers.utils.formatEther(mintAmount)} ETH to ${wallet.address}`);

      const tx = await baseTokenContract.mint(wallet.address, mintAmount);
      await tx.wait();

      const balance = await baseTokenContract.balanceOf(accountAsUint256);
      console.log(`Minted Balance: ${ethers.utils.formatEther(balance)} ETH`);
    } catch (error) {
      console.error("Error during minting:", error);
    }
  });
});
