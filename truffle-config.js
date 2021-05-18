/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    rinkeby: {
      network_id: 4, // Official ropsten network id
      provider: function () {
        return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/8f868fcca6aa44febce5b6a085aa23f2");
      },
      chainlink: {
        coordinator: '0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B',
        link: '0x01BE23585060835E02B77ef475b0Cc51aA1e0709',
        keyHash: '0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311',
      },
      synthetix: {
        resolver: '0x06868d70c75148327281Cb434624294c946DA1FC'
      }
    },
    kovan: {
      network_id: 42, // Official kovan network id
      provider: function () {
        return new HDWalletProvider(mnemonic, "https://kovan.infura.io/v3/8f868fcca6aa44febce5b6a085aa23f2");
      },
      chainlink: {
        coordinator: '0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9',
        link: '0xa36085f69e2889c224210f603d836748e7dc0088',
        keyHash: '0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4',
      },
      synthetix: {
        resolver: '0x84f87E3636Aa9cC1080c07E6C61aDfDCc23c0db6'
      }
    },
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
      chainlink: {
        coordinator: '0x8e6dCd9F25eC9be4Eae83fD4baD59784913F76CB',
        link: '0x8e6dCd9F25eC9be4Eae83fD4baD59784913F76CB',
        keyHash: '0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311',
      },
      synthetix: {
        resolver: '0x8e6dCd9F25eC9be4Eae83fD4baD59784913F76CB'
      }
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.4",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  },

  // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
  //
  // Note: if you migrated your contracts prior to enabling this field in your Truffle project and want
  // those previously migrated contracts available in the .db directory, you will need to run the following:
  // $ truffle migrate --reset --compile-all

  db: {
    enabled: false
  }
};
