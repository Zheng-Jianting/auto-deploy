import Vue from 'vue'
import store from '../store'
import axios from 'axios'
import router from '../router'

// 前置拦截
axios.interceptors.request.use(config => {
  return config
})

axios.interceptors.response.use(response => {
  const res = response.data
  if (res.code === 200) {
    // Vue.prototype.$message.success({ message: res.msg, duration: 1500 })
    return response
  } else {
    Vue.prototype.$message.error({ message: res.msg, duration: 1500 })
    return Promise.reject(response.data.msg)
  }
},
error => {
  if (error.response.data) {
    error.message = error.response.data.msg
  }

  if (error.response.status === 401) {
    store.commit('REMOVE_INFO')
    router.push('/login')
  }

  Vue.prototype.$message.error({ message: error.message, duration: 1 * 1000 })
  return Promise.reject(error)
})
