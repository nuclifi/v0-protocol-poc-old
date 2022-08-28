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

  const MockERC20 = await ethers.getContractFactory('MockERC20');
  const MockStaking = await ethers.getContractFactory('MockStaking');
  const MockStakingStrategy = await ethers.getContractFactory('MockStakingStrategy');
  const MockStakingStrategyFactory = await ethers.getContractFactory('MockStakingStrategyFactory');

  const NuclifiController = await ethers.getContractFactory('NuclifiController');
  const NuclifiCertificate = await ethers.getContractFactory('NuclifiCertificate');
  const NuclifiConfiguration = await ethers.getContractFactory('NuclifiConfiguration');

  console.log(`Deploying mock tokens...`);
  const usdc = await MockERC20.deploy('USDC Coin', 'USDC', 6, { gasPrice });
  const usdt = await MockERC20.deploy('Tether USDC', 'USDT', 6, { gasPrice });
  await usdc.deployed();
  await usdt.deployed();
  output['USDC'] = { abi: 'IERC20', address: usdc.address };
  output['USDT'] = { abi: 'IERC20', address: usdt.address };

  console.log(`Deploying mock staking programs...`);
  const usdcStaking = await MockStaking.deploy(
    deployer.address,
    usdc.address,
    usdc.address,
    30 * 86400,
    { gasPrice }
  );
  const usdtStaking = await MockStaking.deploy(
    deployer.address,
    usdt.address,
    usdc.address,
    30 * 86400,
    { gasPrice }
  );
  await usdcStaking.deployed();
  await usdtStaking.deployed();
  output['USDCRewardStaking'] = { abi: 'MockStaking', address: usdc.address };
  output['USDTRewardStaking'] = { abi: 'MockStaking', address: usdt.address };

  let tx = await usdc.transfer(usdcStaking.address, '10000000000', { gasPrice });
  await tx.wait();
  await usdcStaking.notifyRewardAmount('10000000000', { gasPrice });
  tx = await usdt.transfer(usdtStaking.address, '10000000000', { gasPrice });
  await tx.wait();
  await usdtStaking.notifyRewardAmount('10000000000', { gasPrice });

  console.log(`Deploying mock startegies...`);
  const usdcRewardStakingStrategyFactory = await MockStakingStrategyFactory.deploy({ gasPrice });
  const usdtRewardStakingStrategyFactory = await MockStakingStrategyFactory.deploy({ gasPrice });
  await usdcRewardStakingStrategyFactory.deployed();
  await usdtRewardStakingStrategyFactory.deployed();
  output['USDCRewardStakingStrategyFactory'] = {
    abi: 'MockStakingStrategyFactory',
    address: usdcRewardStakingStrategyFactory.address,
  };
  output['USDTRewardStakingStrategyFactory'] = {
    abi: 'MockStakingStrategyFactory',
    address: usdtRewardStakingStrategyFactory.address,
  };

  console.log(`Deploying Nuclifi core contracts...`);
  const nuclifiController = await NuclifiController.deploy({ gasPrice });
  await nuclifiController.deployed();
  output['NuclifiController'] = { abi: 'NuclifiController', address: nuclifiController.address };

  const nuclifiConfiguration = await NuclifiConfiguration.deploy({ gasPrice });
  await nuclifiConfiguration.deployed();
  output['NuclifiConfiguration'] = {
    abi: 'NuclifiConfiguration',
    address: nuclifiConfiguration.address,
  };

  const nuclifiCertificate = await NuclifiCertificate.deploy(nuclifiController.address, {
    gasPrice,
  });
  await nuclifiCertificate.deployed();
  output['NuclifiCertificate'] = { abi: 'NuclifiCertificate', address: nuclifiCertificate.address };

  fs.writeFileSync(`./deployments/${network.name}.json`, JSON.stringify(output, null, 2));

  await verifyContract(hre, usdc.address, ['USDC Coin', 'USDC', 6]);
  await verifyContract(hre, usdt.address, ['Tether USDC', 'USDT', 6]);
  await verifyContract(hre, usdcRewardStakingStrategyFactory.address, []);
  await verifyContract(hre, usdtRewardStakingStrategyFactory.address, []);
  await verifyContract(hre, nuclifiController.address, []);
  await verifyContract(hre, nuclifiConfiguration.address, []);
  await verifyContract(hre, nuclifiCertificate.address, [nuclifiController.address]);
  await verifyContract(hre, usdcStaking.address, [
    deployer.address,
    usdc.address,
    usdc.address,
    30 * 86400,
  ]);
  await verifyContract(hre, usdtStaking.address, [
    deployer.address,
    usdt.address,
    usdc.address,
    30 * 86400,
  ]);

  await nuclifiConfiguration.setStrategyFactoryAddress(
    1,
    usdcRewardStakingStrategyFactory.address,
    { gasPrice }
  );
  await nuclifiConfiguration.setStrategyFactoryAddress(
    2,
    usdtRewardStakingStrategyFactory.address,
    { gasPrice }
  );
  await usdcRewardStakingStrategyFactory.setAddresses(
    usdcStaking.address,
    nuclifiController.address,
    nuclifiCertificate.address,
    { gasPrice }
  );
  await usdtRewardStakingStrategyFactory.setAddresses(
    usdtStaking.address,
    nuclifiController.address,
    nuclifiCertificate.address,
    { gasPrice }
  );
  await nuclifiController.setAddresses(
    usdc.address,
    nuclifiCertificate.address,
    nuclifiConfiguration.address,
    { gasPrice }
  );

  console.log(`Deployment on ${network.name} complete.`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
