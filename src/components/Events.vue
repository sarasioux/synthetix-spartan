<template>
    <nav class="panel">
        <p class="panel-heading">
            Battle Activity
        </p>
        <p class="panel-block" v-for="event in events" :key="event">
            <span v-if="event.type === 'playerJoined'">
                A new player has joined the game. ({{event.args.player}})
            </span>
            <span v-if="event.type === 'fighterJoined'">
                A new fighter has been created for player {{event.args.player}}
                with strength <strong>{{event.args.hero.strength}}</strong>,
                stamina <strong>{{event.args.hero.stamina}}</strong>,
                and speed <strong>{{event.args.hero.speed}}</strong>.
            </span>
            <span v-if="event.type === 'roundFought'">
                A round was fought with Hero({{event.args.hero.strength}}, {{event.args.hero.stamina}}, {{event.args.hero.speed}})
                and Opponent({{event.args.opponent.strength}}, {{event.args.opponent.stamina}}, {{event.args.opponent.speed}}).
            </span>
            <span v-if="event.type === 'playerWon'">
                A player won the battle!  ({{event.args.player}}) Hero({{event.args.hero.strength}}, {{event.args.hero.stamina}}, {{event.args.hero.speed}}).
            </span>
            <span v-if="event.type === 'fighterBoosted'">
                A fighter was boosted!  ({{event.args.player}}) Hero({{event.args.hero.strength}}, {{event.args.hero.stamina}}, {{event.args.hero.speed}}).
            </span>
            <span v-if="event.type === 'battleContinued'">
                No players were victorious after {{event.args.battleRound}} battle rounds. The war will start again shortly.
            </span>
        </p>
    </nav>
</template>

<script>

  export default {
    name: 'Events',
    data: () => {
      return {
        events: {}
      }
    },
    props: {
      contract: Object,
      account: String,
    },
    mounted: function() {
      this.loadEvents();
    },
    methods: {
      loadEvents: async function() {
        this.contract.PlayerJoined(this.playerJoined);
        this.contract.FighterJoined(this.fighterJoined);
        this.contract.RoundFought(this.roundFought);
        this.contract.PlayerWon(this.playerWon);
        this.contract.FighterBoosted(this.fighterBoosted);
        this.contract.BattleContinued(this.battleContinued);
      },
      playerJoined: function(err, res) {
        this.events[res.id] = {type: 'playerJoined', args: res.args};
        console.log('playerJoined', res);
      },
      fighterJoined: function(err, res) {
        this.events[res.id] = {type: 'fighterJoined', args: res.args};
        console.log('fighterJoined', res);
        this.$emit('fighter');
      },
      roundFought: function(err, res) {
        this.events[res.id] = {type: 'roundFought', args: res.args};
        console.log('roundFought', res);
      },
      playerWon: function(err, res) {
        this.events[res.id] = {type: 'playerWon', args: res.args};
        console.log('playerWon', res);
      },
      fighterBoosted: function(err, res) {
        this.events[res.id] = {type: 'fighterBoosted', args: res.args};
        console.log('fighterBoosted', res);
      },
      battleContinued: function(err, res) {
        this.events[res.id] = {type: 'battleContinued', args: res.args};
        console.log('battleContinued', res);
      }

      //     event FighterBoosted(address indexed player, Fighter hero);

    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
