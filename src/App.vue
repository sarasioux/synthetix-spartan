<template>
    <div id="app">
        <SiteNav
            v-on:connect="connectWeb3"
            v-on:changePage="changePage"
            :contract="contract"
            :isConnected="isConnected"
            :account="account"
            :balance="balance"
        />
        <section class="background-section section is-medium">
            <div class="container">
                <div class="columns">
                    <div class="column is-3">
                        <div class="box">
                            <h1 class="title is-4">Compete in a Last Man Standing Battle Royale to win NFTs and SNX.</h1>
                            <ul>
                                <li>
                                    - Join the game (free plus gas)
                                </li>
                                <li>
                                    - Receive a random fighter
                                </li>
                                <li>
                                    - Get boosted when new players join
                                </li>
                                <li>
                                    - Participate in the final battle
                                </li>
                                <li>
                                    - Last man standing wins!
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        <div class="container" v-if="ready && activePage === 'game'">
            <div class="columns">
                <div class="column">
                    <Game
                            :contract="contract"
                            :account="account"
                            :refresh="refreshGame"
                    />
                </div>
                <div class="column is-4">
                    <Events
                            v-on:fighter="newFighter"
                            :contract="contract"
                            :account="account"
                    />
                </div>
            </div>
        </div>
        <div class="container" v-if="ready && activePage === 'nft'">
            <NFT
                :contract="contract"
                :account="account"
            />
        </div>
        <div class="container" v-if="activePage === 'about'">
            <h1 class="title">About the Game</h1>
        </div>
        <Debug
                v-if="ready"
                :contract="contract"
                :account="account"
        />
    </div>
</template>

<script>
  import SiteNav from './components/SiteNav.vue'
  import Game from './components/Game.vue'
  import NFT from './components/NFT.vue'
  import Events from './components/Events.vue'
  import Debug from './components/Debug.vue'
  import GameContract from './assets/contracts/Game.json'
  import TruffleContract from '@truffle/contract'

  export default {
    name: 'App',
    data: () => {
      return {
        ready: false,
        web3: false,
        isConnected: false,
        connectionInProgress: false,
        account: '',
        balance: '',
        contract: {},
        networkId: 0,
        activePage: 'game',
        refreshGame: 0,
      }
    },
    components: {
      SiteNav, Game, Events, NFT, Debug
    },
    methods: {
      connectWeb3: async function() {
        this.connectionInProgress = true;
        try {
          // Request account access
          const accounts = await this.$web3.currentProvider.send('eth_requestAccounts');
          this.isConnected = true;
          this.account = accounts.result[0];
          this.getWeb3Values();
          this.initContracts();
          this.connectionInProgress = false;

        } catch (error) {
          // User denied account access
          console.log('did not receive accts', error);
        }
      },
      getWeb3Values: async function() {
        this.networkId = await this.$web3.eth.net.getId();
        this.balance = await this.$web3.eth.getBalance(this.account);
        this.$web3.eth.defaultAccount = this.account;
        this.networkId = await this.$web3.eth.net.getId();
      },
      initContracts: async function() {
        let contract = TruffleContract(GameContract);
        contract.setProvider(this.$web3.currentProvider);
        contract.defaults({
          from: this.account,
          gasPrice: 1000000000
        });
        this.contract = await contract.deployed();
        this.ready = true;
      },
      changePage: function(page) {
        this.activePage = page;
        console.log('change page', page);
      },
      newFighter: function() {
        this.refreshGame = Date.now();
        console.log('new fighter', this.refreshGame);
      }
    }
  }
</script>

<style>
    @import "https://cdn.jsdelivr.net/npm/bulma@0.9.2/css/bulma.min.css";
    #app {
        margin-top: 2em;
    }
    .background-section {
        background: url('./assets/dead-bg.jpg');
        margin-bottom: 2em;
    }

</style>
