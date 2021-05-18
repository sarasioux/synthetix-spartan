<template>
    <div class="card" v-if="fighter.strength > 0 || fighter.stamina > 0 || fighter.speed > 0">
        <div class="card-image">
            <figure class="image is-square">
                <img :src="image" alt="Spartan Fighters">
            </figure>
            <div class="id-tag tags has-addons" v-if="fighter.id">
                <span class="tag">Token ID</span>
                <span class="tag is-danger">{{fighter.id}}</span>
            </div>
        </div>
        <div class="card-content">
            <div class="media">
                <p class="title is-4">My Fighter</p>
            </div>

            <div class="content">
                <div class="columns is-gapless">
                    <div class="column">
                        <div class="tags has-addons">
                            <span class="tag">Strength</span>
                            <span class="tag is-danger">{{fighter.strength}}</span>
                        </div>
                    </div>
                    <div class="column">
                        <div class="tags has-addons">
                            <span class="tag">Stamina</span>
                            <span class="tag is-success">{{fighter.stamina}}</span>
                        </div>
                    </div>
                    <div class="column has-text-right">
                        <div class="tags last has-addons">
                            <span class="tag">Speed</span>
                            <span class="tag is-link">{{fighter.speed}}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
  export default {
  name: 'Fighter',
  data: () => {
    return {
      images: [],
      image: ''
    }
  },
  props: {
    fighter: Object,
  },
  mounted: function() {
    this.getImages();
    this.image = this.getImage();
    console.log('fighter', this.fighter);
  },
  methods: {
    getImages: function() {
      let ranges = [0, 50, 90];
      for(var i=0; i<ranges.length; i++) {
        for(var j=0; j<ranges.length; j++) {
          for(var k=0; k<ranges.length; k++) {
            this.images.push('fighter-' + ranges[i] + '-' + ranges[j] + '-' + ranges[k] + '.png');
          }
        }
      }
    },
    getImage: function() {
      let strength;
      let stamina;
      let speed;
      if(this.fighter.strength >= 90) {
        strength = 90;
      } else if(this.fighter.strength >= 50) {
        strength = 50;
      } else {
        strength = 0;
      }
      if(this.fighter.stamina >= 90) {
        stamina = 90;
      } else if(this.fighter.stamina >= 50) {
        stamina = 50;
      } else {
        stamina = 0;
      }
      if(this.fighter.speed >= 90) {
        speed = 90;
      } else if(this.fighter.speed >= 50) {
        speed = 50;
      } else {
        speed = 0;
      }

      return '/fighters/fighter-' + strength + '-' + stamina + '-' + speed + '.png'
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
    .id-tag {
        font-weight: bold;
        position: absolute;
        top: 1.5em;
        right: 1.5em;
    }
    .id-tag .tag {
        font-size: 1em;
    }
</style>
