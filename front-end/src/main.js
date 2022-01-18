import Vue from 'vue'
import App from './App.vue'
import store from './store'
import router from './router'
import VueParticles from 'vue-particles'
import './plugins/element.js'
import '../static/font-awesome/css/font-awesome.min.css'
import 'element-ui/lib/theme-chalk/index.css'
import './assets/fonts/iconfont.css'

import axios from 'axios'
import './axios/axios'
Vue.prototype.$http = axios
axios.defaults.baseURL = 'http://localhost:9000'
// axios.defaults.baseURL = 'http://119.29.189.254:9000'
axios.defaults.withCredentials = false

Vue.config.productionTip = false
Vue.use(VueParticles)

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
