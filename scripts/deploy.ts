import { ethers } from "hardhat";

async function main() {
 
  const DiamondRegistry = await ethers.getContractFactory("DiamondRegistry");
  const resinsertPotAddress = "0x2000000000000000000000000000000000000001";
  const DiamondRegistry = await DiamondRegistry.deploy(resinsertPotAddress);

  await DiamondRegistry.deployed();

  console.log(
    `DiamondRegistry deployed to ${DiamondRegistry.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
