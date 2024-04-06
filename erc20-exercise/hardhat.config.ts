import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    "sepolia": {
      url: "https://sepolia.infura.io/v3/6d2ea14c1fa645b29c50c264b0590238",
      accounts: ["<Private Key>"]
    }
  }
};

export default config;
