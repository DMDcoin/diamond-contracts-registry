import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { BigNumber } from "ethers";
import { DiamondRegistry, MockEtherReceiver } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bn')(BigNumber))
  .should();

const mockReinsertPotAddress = "0x2000000000000000000000000000000000000001";

let deployedResolver: DiamondRegistry | undefined;
let etherReceiverMock: MockEtherReceiver;
let currentRegistrationFee: BigNumber = ethers.utils.parseEther("1");

let signers: SignerWithAddress[] = [];

describe("DiamondRegistry", function () {
  const InvalidNames = [
    '!123',
    '★★★',
    'a',
    'aa',
    'a'.repeat(33),
    'abc~',
    'abc,abc',
    'abcabc,',
    ',abcabc',
    'abc abc',
    'abc_abc',
    '-adasdasd',
    'asdadas-',
    'a-b-c--d',
  ];

  describe("Deploy", function () {
    it("deploying", async function () {
      signers = await ethers.getSigners();

      const ens_resolver_factory = await ethers.getContractFactory("DiamondRegistry");
      deployedResolver = await upgrades.deployProxy(
        ens_resolver_factory,
        [mockReinsertPotAddress],
        { initializer: 'initialize' }
      ) as DiamondRegistry;

      expect(await deployedResolver.deployed());

      const mockContractFactory = await ethers.getContractFactory("MockEtherReceiver");
      etherReceiverMock = await mockContractFactory.deploy() as MockEtherReceiver;

      expect(await etherReceiverMock.deployed());
    });

    it("should not deploy with reinsert pot address = address(0)", async function () {
      const contractFactory = await ethers.getContractFactory("DiamondRegistry");

      await expect(
        upgrades.deployProxy(
          contractFactory,
          [ethers.constants.AddressZero],
          { initializer: 'initialize' }
        )
      ).to.be.revertedWith("ReinsertPotAddress must not be 0");
    });

    it("should not allow initialization of initialized contract", async function () {
      const contractFactory = await ethers.getContractFactory("DiamondRegistry");

      const contract = await upgrades.deployProxy(
        contractFactory,
        [mockReinsertPotAddress],
        { initializer: 'initialize' }
      ) as DiamondRegistry;

      await expect(
        contract.initialize(contract.address)
      ).to.be.revertedWith("Initializable: contract is already initialized");
    });
  });

  describe("setOwnName", function () {
    it("registration should fail without providing funds.", async function () {

      await deployedResolver!.setOwnName("testname1").should.be.revertedWith("Amount requires to be exactly the costs");

    });

    it("registration should succeed in the first try if funds get provided.", async function () {
      const user = signers[0];

      await expect(() =>
        deployedResolver!.connect(user).setOwnName("testname1", { value: currentRegistrationFee })
      ).to.changeEtherBalances(
        [user.address, mockReinsertPotAddress],
        [currentRegistrationFee.mul(-1), currentRegistrationFee]
      );

      currentRegistrationFee = currentRegistrationFee.mul(2);
    });

    it("registration fee for the next match should be the expected registration fee.", async function () {
      (await deployedResolver!.getSetNameCost(signers[0].address)).should.be.equal(currentRegistrationFee);
    });

    it("renaming is possible.", async function () {
      await deployedResolver!.setOwnName("testname2", { value: currentRegistrationFee });// .should.be.revertedWith("Amount requires to be exactly the costs");
      // currentRegistrationFee = currentRegistrationFee.mul(2);
    });

    it("renaming is not possible, without doubling registration fee.", async function () {
      await deployedResolver!.setOwnName("testname3", { value: currentRegistrationFee }).should.be.revertedWith("Amount requires to be exactly the costs");
    });

    it("renaming is possible, without expected registration fee.", async function () {
      currentRegistrationFee = currentRegistrationFee.mul(2);
      await deployedResolver!.setOwnName("testname1", { value: currentRegistrationFee }); // .should.be.revertedWith("Amount requires to be exactly the costs");
      // currentRegistrationFee = currentRegistrationFee.mul(2);
    });

    it("renaming costs stop growing after reaching max price.", async function () {
      // for this test we are using signers 2 account to have a fresh account.

      const expectedMaximumCosts = ethers.utils.parseEther("256");
      const expectedMaximumCostsBN = ethers.BigNumber.from(expectedMaximumCosts);
      let signer = signers[1];
      deployedResolver!.connect(signer);
      let costsWasAtMaxCounter = 0;

      for (let i = 0; i < 12; i++) {

        let costs = await deployedResolver!.getSetNameCost(signer.address);
        let costsBN = ethers.BigNumber.from(costs);
        console.log("costs:", costs);
        if (costsBN.eq(expectedMaximumCostsBN)) {
          costsWasAtMaxCounter++;
        }

        await deployedResolver!.connect(signer).setOwnName(`account2testname${i}`, { value: costs }); // .should.be.revertedWith("Amount requires to be exactly the costs");
      }

      expect(costsWasAtMaxCounter).to.be.eq(4, "expected the costs to stay at maximum of 256 DMD");
    });

    it("should mark registered name as unavailable", async function () {
      const alice = signers[4];
      const name = 'alicex1';

      let cost = await deployedResolver!.getSetNameCost(alice.address);
      await deployedResolver!.connect(alice).setOwnName(name, { value: cost });

      expect(await deployedResolver!.name(alice.address)).to.equal(name);
      expect(await deployedResolver!.available(name)).to.be.false;
    });

    it("should not allow to set already taken name", async function () {
      const alice = signers[5];
      const bob = signers[6];

      let cost = await deployedResolver!.getSetNameCost(alice.address);
      await deployedResolver!.connect(alice).setOwnName('alice', { value: cost });

      cost = await deployedResolver!.getSetNameCost(bob.address);
      await expect(deployedResolver!.connect(bob).setOwnName('alice', { value: cost }))
        .to.be.revertedWith("Name not available");
    });

    it("should revert transaction if transfer failed", async function () {
      const contractFactory = await ethers.getContractFactory("DiamondRegistry");
      const contract = await upgrades.deployProxy(
        contractFactory,
        [etherReceiverMock.address],
        { initializer: 'initialize' }
      ) as DiamondRegistry;

      await contract.deployed();

      const alice = signers[5];
      const registrationFee = await contract.getSetNameCost(alice.address);

      await expect(
        contract.connect(alice).setOwnName('somename', { value: registrationFee })
      ).to.be.revertedWithCustomError(contract, "TransferFailed")
        .withArgs(etherReceiverMock.address, registrationFee);
    });
  });

  async function registerName(signerIndex: number, name: string) {
    let signer = signers[signerIndex];
    let registrationFee = await deployedResolver!.getSetNameCost(signer.address);

    await deployedResolver!.connect(signer).setOwnName(name, { value: registrationFee });

    return signer;
  }

  describe("namesReverse", function () {
    it("should get address by name", async function () {
      const nameToRegister = "just-Another-Name"
      const owner = await registerName(0, nameToRegister);

      expect(await deployedResolver!.getAddressOfName(nameToRegister)).to.equal(owner.address);
    });

    it("should get address by name hash", async function () {
      const nameToRegister = "myAwesomeName"
      const owner = await registerName(7, nameToRegister);

      const nameHash = await deployedResolver!.getHashOfName(nameToRegister);
      expect(await deployedResolver!.addr(nameHash)).to.equal(owner.address);
    });
  });

  describe("name validation", function () {
    InvalidNames.forEach((userName, index) => {
      it(`should not allow to set invalid name, test#${index + 1}`, async function () {
        const alice = signers[11];

        const cost = await deployedResolver!.getSetNameCost(alice.address);
        await expect(deployedResolver!.connect(alice).setOwnName(userName, { value: cost }))
          .to.be.revertedWith("Name not valid");
        });
    });
  });
});
