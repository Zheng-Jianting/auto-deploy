import Vue from 'vue'
import Vuex from 'vuex'
// import axios from 'axios'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    token: '',
    userInfo: JSON.parse(sessionStorage.getItem('userInfo')),
    currentProjectId: 0
  },
  mutations: {
    // set
    SET_TOKEN: (state, token) => {
      state.token = token
      localStorage.setItem('token', token)

      // 解决异步请求从 localStorage 中获取不到 token 的问题
      // axios.defaults.headers = { Authorization: token }
    },
    SET_USERINFO: (state, userInfo) => {
      state.userInfo = userInfo
      sessionStorage.setItem('userInfo', JSON.stringify(userInfo))
    },
    REMOVE_INFO: (state) => {
      state.token = ''
      state.userInfo = {}
      localStorage.setItem('token', '')
      sessionStorage.setItem('userInfo', JSON.stringify(''))
    },
    SET_CURRENTPROJECTID: (state, currentProjectId) => {
      state.currentProjectId = currentProjectId
      localStorage.setItem('currentProjectId', JSON.stringify(currentProjectId))
    }
  },
  getters: {
    // get
    getUser: state => {
      return state.userInfo
    },
    getToken: state => {
      return state.token
    },
    getCurrentProjectId: state => {
      return state.currentProjectId
    }
  },
  actions: {
  },
  modules: {
  }
})
