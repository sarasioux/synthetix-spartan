<template>
    <div>
        <figure class="image is-64x64" @mouseover="showTooltip" @mouseleave="hideTooltip">
            <img :src="image" class="is-rounded" />
        </figure>
        <div class="popover" v-if="displayTooltip">
            <span class="tag is-danger">{{getTooltip()}}</span>
        </div>
    </div>
</template>

<script>
  export default {
  name: 'Fighter',
  data: () => {
    return {
      images: [],
      image: '',
      displayTooltip: false,
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
    },
    getTooltip: function() {
      return this.fighter.strength + ', ' + this.fighter.stamina + ', ' + this.fighter.speed;
    },
    showTooltip: function() {
      this.displayTooltip = true;
    },
    hideTooltip: function() {
      this.displayTooltip = false;
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
    .popover {
        position: absolute;
    }
</style>
