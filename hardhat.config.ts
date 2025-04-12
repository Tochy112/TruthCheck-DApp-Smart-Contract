import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();


const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: "https://wild-wild-asphalt.ethereum-sepolia.quiknode.pro/4d49c2ad72fe7b0c3fa2334c49dd40121ed1a520/",
      accounts: [process.env.PRIVATE_KEY!]
    }
  }
};

export default config;
