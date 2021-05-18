<template>
    <div>
        <div class="modal" :class="{'is-active':showDebug}">
            <div class="modal-background" @click="showDebug=false"></div>
            <div class="modal-content">
                <nav class="panel">
                    <p class="panel-heading">
                        Debug Internals
                    </p>
                    <p class="panel-block">
                        <label class="label has-text-left">Contract</label> <span class="tag">{{contract.address}}</span>
                    </p>
                    <p class="panel-block">
                        <label class="label has-text-left">Player Count</label> <span class="tag">{{playerCount}}</span>
                    </p>
                    <p class="panel-block">
                        <label class="label has-text-left">Battle Round</label> <span class="tag">{{battleRound}}</span>
                    </p>
                    <p class="panel-block">
                        <label class="label has-text-left">Last Request ID</label> <span class="tag">{{requestId}}</span>
                    </p>
                    <p class="panel-block">
                        <label class="label has-text-left">End Request ID</label> <span class="tag">{{endRequestId}}</span>
                    </p>
                    <p class="panel-block">
                        <label class="label has-text-left">End Request Random</label> <span class="tag">{{endRandomness}}</span>
                    </p>
                    <p class="panel-block">
                        <label class="label has-text-left">Random Number</label>
                        <input v-model="randomness" class="input" type="text" placeholder="Random Number">
                    </p>
                    <p class="panel-block">
                        <label class="label has-text-left">Request ID</label>
                        <input v-model="fulfillId" class="input" type="text" placeholder="Request ID">
                    </p>
                    <p class="panel-block">
                        <a @click="fulfillRandom">Fulfill Randomness</a>
                    </p>
                    <p class="panel-block is-active">
                        <a @click="endGame">End Game</a>
                    </p>
                </nav>
            </div>
            <button  @click="showDebug=false" class="modal-close is-large" aria-label="close"></button>
        </div>
        <a @click="showDebug=true" class="is-small is-debug-link has-text-danger">
            <span class="icon">
              <i class="fas fa-bug"></i>
            </span>
        </a>

    </div>
</template>

<script>

  export default {
    name: 'Debug',
    data: () => {
      return {
        loaded: true,
        showDebug: false,
        requestId: 0,
        endRequestId: 0,
        endRandomness: 0,
        randomness: '',
        fulfillId: 0,
        battleRound: 0,
        playerCount: 0,
        ethMultiplier: 1000000000000000000,

      }
    },
    props: {
      contract: Object,
      account: String,
    },
    watch: {
      showDebug: function () {
        this.loadDebug();
      },
    },
    mounted: function() {
      this.loadDebug();
    },
    methods: {
      loadDebug: async function() {
        this.loaded = false;
        this.playerCount = parseInt(await this.contract.playerCount.call({from: this.account}));
        this.requestId = await this.contract.lastRequestId.call({from: this.account});
        this.endRequestId = await this.contract.endRequestId.call({from: this.account});
        this.endRandomness = await this.contract.endRandomness.call({from: this.account});
        this.battleRound = parseInt(await this.contract.battleRound.call({from: this.account}));

        this.fulfillId = this.requestId;
        this.randomness = Math.random() * this.ethMultiplier;
        this.loaded = true;
      },
      fulfillRandom: async function() {
        let response = await this.contract.fulfillRandomness(String(this.fulfillId), String(this.randomness), {from: this.account});
        console.log('fulfilling random', response);
        this.loadDebug();
      },
      endGame: async function() {
        let response = await this.contract.endGame({from: this.account});
        console.log('ending game', response);
        this.loadDebug();
      },
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
    .tickets {
        padding: 1.5em;
    }
    .label {
        font-weight: normal;
        display: block;
        padding-right: 20px;
        font-size: 0.8em;
        min-width: 160px;
    }
    .is-small {
        font-size: 1em;
    }
    .panel {
        background: white;
    }
    .modal-content {
        width: 800px;
    }
    .is-debug-link {
        position: fixed;
        bottom: 10px;
        right: 10px;
    }
</style>
