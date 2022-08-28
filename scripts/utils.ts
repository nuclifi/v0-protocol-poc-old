import { HardhatRuntimeEnvironment } from 'hardhat/types';

export type OutputType = {
  [name: string]: {
    abi: string;
    address: string;
  };
};

export const wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export async function verifyContract(
  hre: HardhatRuntimeEnvironment,
  address: string,
  constructorArguments: any[]
) {
  try {
    // await wait(20 * 1000); // wait for 20s
    await hre.run('verify:verify', {
      address,
      constructorArguments,
    });
  } catch (error: any) {
    console.error(`- Error verifying: ${error.name}`);
  }
}
