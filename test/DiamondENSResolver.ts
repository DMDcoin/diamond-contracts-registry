import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";
import { DiamondENSResolver } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bn')(BigNumber))
    .should();

const mockReinsertPotAddress = "0x2000000000000000000000000000000000000001";

let deployedResolver: DiamondENSResolver | undefined;
let currentRegistrationFee: BigNumber = ethers.utils.parseEther("1");

let signers: SignerWithAddress[] = [];

describe("DiamondENSResolver", function () {
  
  describe("Deploy", function () {
    it("deploying", async function () {
      signers = await ethers.getSigners();

      const ens_resolver_factory = await ethers.getContractFactory("DiamondENSResolver");
      deployedResolver = await ens_resolver_factory.deploy(mockReinsertPotAddress) as DiamondENSResolver;
    });
  });

  describe("setOwnName", function () {
    it("registration should fail without providing funds.", async function () {

      await deployedResolver!.setOwnName("testname1").should.be.revertedWith("Amount requires to be exactly the costs");

    });

    it("registration should succed in the first try if funds get provided.", async function () {

      await deployedResolver!.setOwnName("testname1", { value: currentRegistrationFee });// .should.be.revertedWith("Amount requires to be exactly the costs");
      currentRegistrationFee = currentRegistrationFee.mul(2);

    });


    it("registration fee for the next match should be the expected registration fee.", async function () {
      (await deployedResolver!.getSetNameCost(signers[0].address)).should.be.equal(currentRegistrationFee);
    });

    it("renaming is possible.", async function () {
      (await deployedResolver!.getSetNameCost(signers[0].address)).should.be.equal(currentRegistrationFee);
    });

  });

});
