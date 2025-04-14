import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();


const config: HardhatUserConfig = {
  solidity: "0.8.26",
  networks: {
    baseSepolia: {
      url: process.env.QUICK_NODE_BASE_SEPOLIA_URL,
      accounts: [process.env.PRIVATE_KEY!]
    }
  }
};

export default config;
