<template>
    <div>
        <h1 class="title">My Wins</h1>
        <div class="columns" v-if="loaded">
            <div class="column is-10">
                <p v-if="fighters.length === 0">
                    You have not won any battles yet.  Once you do, your victory NFTs will show up here.
                </p>
                <div class="columns is-multiline" v-if="fighters.length > 0">
                    <div class="column is-4" v-for="fighter in fighters" :key="fighter">
                        <Fighter
                            :fighter="fighter"
                        />
                    </div>
                </div>
            </div>
            <div class="column is-2">
            </div>
        </div>
    </div>
</template>

<script>

  import Fighter from './Fighter.vue';

  export default {
    name: 'NFT',
    data: () => {
      return {
        loaded: false,
        fighter: {},
        fighters: [],
      }
    },
    props: {
      contract: Object,
      account: String,
    },
    components: {
      Fighter
    },
    mounted: function() {
        this.loadData();
    },
    methods: {
      loadData: async function() {
        this.loaded = false;
        let nfts = await this.contract.getMyTokens.call({from: this.account});
        let nftId, fighterResponse, fighter;
        if(nfts.length > 0) {
          for(let i=0; i<nfts.length; i++) {
            nftId = parseInt(nfts[i]);
            fighterResponse = await this.contract.fighterByPlayer.call(this.account, {from: this.account});
            fighter = {
              player: this.account,
              id: nftId,
              speed: parseInt(fighterResponse.speed),
              stamina: parseInt(fighterResponse.stamina),
              strength: parseInt(fighterResponse.strength)
            };
            this.fighters.push(fighter);
          }
        }
        this.loaded = true;
      }
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
    .tags .tag {
        font-size: 0.65em;
        margin: 0;
    }
</style>
