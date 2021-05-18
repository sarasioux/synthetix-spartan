import { createApp } from 'vue'
import App from './App.vue'
import VueWeb3 from "./plugins/vue-web3";
import VTooltip from "v-tooltip";

const app = createApp(App);
app.use(VueWeb3)
   .use(VTooltip)
   .mount('#app');
