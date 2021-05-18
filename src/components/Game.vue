<template>
    <div class="columns" v-if="loaded">
        <div class="column is-7">
            <Countdown
                    :end="end"
            />
            <div v-if="end*1000 < Date.now() && requestId == 0 && endRandomness == 0" class="has-text-centered reset-box">
                <button class="button" @click="endGame" :disabled="inProgress">
                    <span class="icon">
                        <i class="fas fa-fire" v-if="!inProgress"></i>
                        <i class="fab fas fa-spinner fa-pulse" v-if="inProgress"></i>
                    </span>
                    <span>Start Final Battle</span>
                </button>
            </div>
            <div v-if="end*1000 < Date.now() && requestId > 0 && endRandomness > 0" class="has-text-centered reset-box">
                <button class="button" @click="fightWar" :disabled="inProgress">
                    <span class="icon">
                        <i class="fas fa-fire" v-if="!inProgress"></i>
                        <i class="fab fas fa-spinner fa-pulse" v-if="inProgress"></i>
                    </span>
                    <span>Finish Final Battle</span>
                </button>
            </div>

            <div class="box" v-if="fighters.length > 0">
                <div class="columns is-multiline">
                    <div class="column is-full">
                        <h2 class="title has-text-centered">{{fighters.length}} Warriors Joined</h2>
                    </div>
                    <div class="column is-2" v-for="theirFighter in fighters" :key="theirFighter.player">
                        <FighterThumb
                            :fighter="theirFighter"
                        />
                    </div>
                </div>
            </div>
        </div>
        <div class="column is-5 has-text-centered">
            <button class="button is-danger join-button" @click="joinGame" v-if="!myJoinStatus && !myPendingStatus && end*1000 > Date.now()" :disabled="joinInProgress">
                <span class="icon">
                    <i class="fas fa-fire" v-if="!joinInProgress"></i>
                    <i class="fab fas fa-spinner fa-pulse" v-if="joinInProgress"></i>
                </span>
                <span>Join the Game</span>
            </button>

            <div v-if="myPendingStatus" class="join-button box">
                <p>Your fighter is being randomly generated.</p>
                <progress class="progress is-large is-danger" max="100">60%</progress>
            </div>

            <Fighter
                v-if="myJoinStatus"
                :fighter="fighter"
            />
        </div>
    </div>
</template>

<script>

  import Countdown from './Countdown.vue';
  import Fighter from './Fighter.vue';
  import FighterThumb from './FighterThumb.vue';

  export default {
    name: 'Game',
    data: () => {
      return {
        loaded: false,
        end: 0,
        fighter: {},
        fighters: [],
        players: [],
        blankAddress: '0x0000000000000000000000000000000000000000',
        myJoinStatus: false,
        myPendingStatus: false,
        joinInProgress: false,
        inProgress: false,

        requestId: 0,
        endRandomness: 0
      }
    },
    props: {
      contract: Object,
      account: String,
      refresh: Number,
    },
    watch: {
      refresh: function () {
        this.loadData();
      }
    },
    components: {
      Countdown, Fighter, FighterThumb
    },
    mounted: function() {
        this.loadData();
    },
    methods: {
      joinGame: async function() {
        this.joinInProgress = true;
        this.requestId = await this.contract.joinGame({from: this.account});
        this.joinInProgress = false;
        this.loadData();
      },
      loadData: async function() {
        this.loaded = false;
        this.end = parseInt(await this.contract.end.call({from: this.account}));
        let fighter = await this.contract.fighterByPlayer.call(this.account, {from: this.account});
        this.fighter = {
          player: this.account,
          speed: parseInt(fighter.speed),
          stamina: parseInt(fighter.stamina),
          strength: parseInt(fighter.strength)
        };
        this.myJoinStatus = await this.contract.currentPlayers(this.account, {from: this.account});
        this.myPendingStatus = await this.contract.pendingPlayers(this.account, {from: this.account});
        let players = await this.contract.getPlayers({from: this.account});
        for(let i=0; i<players.length; i++) {
          if(players[i] !== this.blankAddress) {
            this.players[i] = players[i];
          }
        }
        this.requestId = parseInt(await this.contract.endRequestId.call({from: this.account}));
        this.endRandomness = parseInt(await this.contract.endRandomness.call({from: this.account}));
        this.loadFighters();
        this.loaded = true;

      },

      loadFighters: async function() {
        let fighters = [];
        for(let i=0; i<this.players.length; i++) {
          let fighterResponse = await this.contract.fighterByPlayer.call(this.players[i], {from: this.account});
          let fighter = {
            player: this.players[i],
            speed: parseInt(fighterResponse.speed),
            stamina: parseInt(fighterResponse.stamina),
            strength: parseInt(fighterResponse.strength)
          };
          fighters.push(fighter);
        }
        this.fighters = fighters;
      },

      endGame: async function() {
        this.inProgress = true;
        await this.contract.endGame({from: this.account});
        this.inProgress = false;
        this.loadData();
      },
      fightWar: async function() {
        this.inProgress = true;
        await this.contract.fightWar({from: this.account});
        this.inProgress = false;
        this.loadData();
      },

    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
    label {
        min-width: 200px;
    }
    .input {
        width: 400px;
        margin-right: 1em;
    }
    .join-button {
        margin-top: 1.5em;
    }
    .join-button p {
        margin-bottom: 1em;
    }
    .reset-box {
        padding-bottom: 1.5em;
    }
</style>
