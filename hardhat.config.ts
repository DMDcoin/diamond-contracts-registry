import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import fs from "fs";
import { NetworkUserConfig } from "hardhat/types";

// Ensure that we have all the environment variables we need.
// const mnemonic: string = process.env.MNEMONIC ? process.env.MNEMONIC : utils.entropyToMnemonic(utils.randomBytes(32));


let mnemonic = 'inspire school random normal account steel strike shove close album produce cube bounce memory before';
if (fs.existsSync(".mnemonic")) {
    mnemonic = fs.readFileSync(".mnemonic").toString().trim();
}


const chainIds = {
    hardhat: 31337,
    DMDv4: 777012
};

function getChainConfig(chain: keyof typeof chainIds): NetworkUserConfig {
    let jsonRpcUrl: string = "";
    switch (chain) {
        case "DMDv4":
            jsonRpcUrl = "http://rpc.uniq.diamonds:8540";
            break;
    }

    return {
        accounts: {
            count: 10,
            mnemonic,
            path: "m/44'/60'/0'/0",
        },
        chainId: chainIds[chain],
        gas: 21_000_000_000,
        gasPrice: 1_000_000_000,
        allowUnlimitedContractSize: true,
        blockGasLimit: 100000000429720,
        url: jsonRpcUrl,
    };
}


const config: {} = {
    defaultNetwork: "hardhat",
    etherscan: {
        apiKey: {
            DMDv4: "http://explorer.uniq.diamonds/api",
        },
    },
    contractSizer: {
        alphaSort: true,
        runOnCompile: true,
        disambiguatePaths: false,
    },
    gasReporter: {
        currency: "USD",
        enabled: process.env.REPORT_GAS ? true : false,
        excludeContracts: [],
        src: "./contracts",
    },
    networks: {
        hardhat: {
            accounts: {
                count: 100,
                mnemonic,
                accountsBalance: "1000000000000000000000000000"
            },
            chainId: chainIds.hardhat,
            allowUnlimitedContractSize: true,
            hardfork: "istanbul",
            minGasPrice: 0
        },

        DMDv4: getChainConfig("DMDv4"),
    },
    paths: {
        artifacts: "./artifacts",
        cache: "./cache",
        sources: "./contracts",
        tests: "./test",
    },
    solidity: {
        version: "0.8.18",
        settings: {
            // metadata: {
            //     // Not including the metadata hash
            //     // https://github.com/paulrberg/hardhat-template/issues/31
            //     bytecodeHash: "none",
            // },
            // Disable the optimizer when debugging
            // https://hardhat.org/hardhat-network/#solidity-optimizer-support
            optimizer: {
                enabled: true,
                runs: 200,
                details: {
                    yul: true,
                },
            },
            evmVersion: "istanbul"
        },
    },
    typechain: {
        outDir: "typechain-types/",
        target: "ethers-v5",
    },
    mocha: {
        timeout: 100000000
    },
};


export default config;
