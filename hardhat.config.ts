import "solidity-coverage";
import "hardhat-gas-reporter";
import "hardhat-abi-exporter";
import * as dotenv from "dotenv";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomicfoundation/hardhat-toolbox";
import { HardhatUserConfig } from "hardhat/config";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      accounts: [
        process.env.PRIVATE_KEY != undefined
          ? process.env.PRIVATE_KEY
          : "0x"
      ],
    },
  },
  gasReporter: {
    currency: 'USD',
    enabled: true,
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  abiExporter: {
    path: "./deployments/abis/",
    runOnCompile: true,
    clear: true,
    spacing: 2,
    flat: true,
    pretty: true
  }
};

export default config;
