import * as fs from 'fs';
import hre, { ethers, network } from 'hardhat';

import { verifyContract, wait, OutputType } from '../utils';

async function main() {
  console.log(`Deploying Nucli.fi Protocol V0 POC to ${network.name}`);

  const [deployer] = await ethers.getSigners();
  console.log(`Deployer address is ${deployer.address}`);

  const { provider } = ethers;
  const estimateGasPrice = await provider.getGasPrice();
  const gasPrice = estimateGasPrice.mul(3).div(2);
  console.log(`Using Gas Price: ${ethers.utils.formatUnits(gasPrice, `gwei`)} gwei`);

  const output: OutputType = {};

  const MockStakingStrategyFactory = await ethers.getContractFactory('MockStakingStrategyFactory');

  console.log(`Deploying mock startegies...`);
  const usdcRewardStakingStrategyFactory = await MockStakingStrategyFactory.deploy({ gasPrice });
  const usdtRewardStakingStrategyFactory = await MockStakingStrategyFactory.deploy({ gasPrice });
  await usdcRewardStakingStrategyFactory.deployed();
  await usdtRewardStakingStrategyFactory.deployed();

  console.log(
    `USDCRewardStakingStrategyFactory deployed at: ${usdcRewardStakingStrategyFactory.address}`
  );
  console.log(
    `USDTRewardStakingStrategyFactory deployed at: ${usdtRewardStakingStrategyFactory.address}`
  );

  await verifyContract(hre, usdcRewardStakingStrategyFactory.address, []);
  await verifyContract(hre, usdtRewardStakingStrategyFactory.address, []);

  await wait(20 * 1000);

  console.log(`Deployment on ${network.name} complete.`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
