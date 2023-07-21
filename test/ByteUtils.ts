import { ethers } from "hardhat";
import { expect } from "chai";

import { MockByteUtils } from "../typechain-types";

describe("Byte utils library", function () {
    let mockUtils: MockByteUtils;

    const TestCases = generateTests();

    function generateTests() {
        let result = new Array<any>();

        for (let charCode = 0; charCode < 128; ++charCode) {
            let isAlpha = (charCode >= 65 && charCode <= 90)
                || (charCode >= 97 && charCode <= 122);

            let isDigit = charCode >= 48 && charCode <= 57;

            result.push(
                {
                    char: ethers.utils.hexlify(charCode),
                    isAlpha: isAlpha,
                    isDigit: isDigit,
                    isAlphaNum: isAlpha || isDigit,
                    isHyphen: charCode == 45
                }
            );
        }

        return result;
    }

    before(async function () {
        const contractFactory = await ethers.getContractFactory("MockByteUtils");

        mockUtils = await contractFactory.deploy();
        await mockUtils.deployed();
    });

    it('isAlpha should return true for alphabet characters', async function () {
        for (const testCase of TestCases) {
            expect(await mockUtils.isAlpha(testCase.char)).to.eq(testCase.isAlpha);
        }
    });

    it('isDigit should return true for number characters', async function () {
        for (const testCase of TestCases) {
            expect(await mockUtils.isDigit(testCase.char)).to.eq(testCase.isDigit);
        }
    });

    it('isAlphaNum should return true for alphabet and number characters', async function () {
        for (const testCase of TestCases) {
            expect(await mockUtils.isAlphaNum(testCase.char)).to.eq(testCase.isAlphaNum);
        }
    });

    it('isHyphen should return true for hyphen symbol only', async function () {
        for (const testCase of TestCases) {
            expect(await mockUtils.isHyphen(testCase.char)).to.eq(testCase.isHyphen);
        }
    });
});
