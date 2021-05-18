<template>
  <div class="title has-text-centered">
      <span class="subtitle">Final Battle</span><br />
      <span class="has-text-danger" v-if="end*1000 > Date.now()">{{formattedDate}}</span>
      <span class="has-text-danger" v-if="end*1000 < Date.now()">Pending</span>
  </div>
</template>

<script>
  import moment from 'moment';

  export default {
  name: 'Countdown',
  data: () => {
    return {
      formattedDate: '',
    }
  },
  props: {
    end: Number
  },
  mounted: function() {
    this.formatDate();
  },
  methods: {
    formatDate: function() {
      let d = new Date(this.end*1000);
      this.formattedDate = moment(d).fromNow();
      setTimeout(() => this.formatDate(), 5000);
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
