import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../components/Home'
import Login from '../components/Login'
import Register from '../components/Register'
import ServerManage from '../components/ServerManage'
import CollectCenter from '../components/CollectCenter'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/home',
    component: Home,
    redirect: '/serverManage',
    children: [
      { path: '/serverManage', component: ServerManage },
      { path: '/collectCenter', component: CollectCenter }
    ]
  },
  {
    path: '/login',
    component: Login
  },
  {
    path: '/register',
    component: Register
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
