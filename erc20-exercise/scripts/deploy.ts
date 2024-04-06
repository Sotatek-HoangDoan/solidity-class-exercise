import hre from 'hardhat';

async function main() {
  try {
    const [deployer] = await hre.ethers.getSigners();
  
    const tokenContract = await hre.ethers.getContractFactory("SotatekStandardToken");
  
    const contract = await tokenContract.deploy("Pho Token", "DTHH", "1000000000000000000000000000", deployer.address, deployer.address);
  
    // await contract.deploymentTransaction()
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

main();
