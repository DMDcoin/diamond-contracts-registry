import { ethers } from "hardhat";

async function main() {
 
  const DiamondENSResolver = await ethers.getContractFactory("DiamondENSResolver");
  const resinsertPotAddress = "0x2000000000000000000000000000000000000001";
  const diamondENSResolver = await DiamondENSResolver.deploy(resinsertPotAddress);

  await diamondENSResolver.deployed();

  console.log(
    `diamondENSResolver deployed to ${diamondENSResolver.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
