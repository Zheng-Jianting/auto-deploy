<template>
  <el-container class="home-container" id="container">
    <!-- header -->
    <el-header :span="24" class="header">
      <el-col :span="4" v-bind:class="[isFolded ? 'hidden' :'logo']">
        <div class="logoImage">
        </div>
      </el-col>
      <el-col :span="1">
        <div class="tools" id="fold" @click.prevent="isFolded=!isFolded">
          <i :class="[isFolded? 'fa fa-align-right':'fa fa-align-left']"></i>
        </div>
      </el-col>
      <el-col :span="2" style="margin-left: 30px">
        <div class="headerText"><router-link to="/serverManage" style="text-decoration: none">服务器配置</router-link></div>
      </el-col>
      <el-col :span="2">
        <div class="headerText" style="margin-left: 7px"><router-link to="/collectCenter" style="text-decoration: none">采集中心</router-link> </div>
      </el-col>
      <el-col :span="2">
        <div class="headerText">日志管理</div>
      </el-col>
      <div class="userInfo">
        <el-dropdown  trigger="hover" >
          <div class="el-dropdown-link userinfo-inner">
            <i class="fa fa-user fa-fw "></i>
          </div>
          <el-dropdown-menu slot="dropdown">
            <el-dropdown-item><i class="fa fa-user fa-fw"></i>&nbsp;{{userName}}</el-dropdown-item>
            <el-dropdown-item :divided="true" @click.native = "showConfig()">
                  <span>
                    <i class="fa fa-cog fa-fw"></i>&nbsp;设置
                  </span>
            </el-dropdown-item>
            <el-dropdown-item :divided="true" @click.native = "logOut()"><span><i class="fa fa-power-off fa-fw"></i>&nbsp;注销</span></el-dropdown-item>
          </el-dropdown-menu>
        </el-dropdown>
      </div>
    </el-header>
    <!-- aside & main -->
    <el-container style="background-color: #E9EEF3">
      <!-- aside -->
      <el-aside width="300px"  v-bind:class="[isFolded ? 'hidden' :'projectManager']">
        <el-row :class="{SearchInput: searchInputVisible}">
          <el-col class="projectFunction bg-purple-dark">
            <el-input @keyup.enter.native="searchProject" style="width: 90%" placeholder="请输入查询内容" v-model="queryText">
              <el-button slot="append" icon="el-icon-search" @click="searchProject"></el-button>
            </el-input>
          </el-col>
        </el-row>
        <el-menu style="border: 0" background-color="#545c64" text-color="#fff" active-text-color="#409EFF" ref="sideBar">
          <el-submenu index="0">
            <template slot="title">
              <div align="left">
                <i class="el-icon-folder-opened" style="margin-left: 5px"></i>
                <span style="margin-left: 10px; display: inline-block; width: 110px">项目</span>
                <i class="el-icon-folder-add" style="margin-left: 15px" @click.stop="addProjectDialogVisible = true"></i>
                <i class="el-icon-search" style="margin-left: 5px" @click.stop="searchInputVisible = !searchInputVisible"></i>
              </div>
            </template>
            <el-submenu :index="projectDetail.project.id + ''" v-for="(projectDetail, index) in projectList" :key="projectDetail.project.id">
              <template slot="title">
                <div @click.exact="submenuClick(projectDetail.project.id, index)" :class="{activeProject: isProjectActive(projectDetail.project.id)}" align="left">
                  <i :class="{activeProject: isProjectActive(projectDetail.project.id)}" class="el-icon-folder" style="margin-left: 10px"></i>
                  <span style="text-align: left; margin-left: 10px; display: inline-block; width: 90px">{{projectDetail.project.name}}</span>
                  <i :class="{activeProject: isProjectActive(projectDetail.project.id)}" class="el-icon-delete" style="margin-left: 45px" @click.stop="openDeleteProjectBox(projectDetail.project.id)"></i>
                </div>
              </template>
              <el-menu-item @click="menuItemClick(projectDetail.project.id, collect.id)" :index="collect.id + ''" v-for="collect in projectDetail.collects" :key="collect.id">
                <template slot="title">
                  <div>
                    <i class="el-icon-document" style="margin-left: 15px"></i>
                    <span style="text-align: left; margin-left: 10px; display: inline-block; width: 130px">{{collect.name}}</span>
                    <i class="el-icon-delete" style="margin-left: 18px" @click.stop="openDeleteCollectBox(collect.id)"></i>
                  </div>
                </template>
              </el-menu-item>
            </el-submenu>
          </el-submenu>
        </el-menu>
      </el-aside>
      <!-- main -->
      <!-- class v-bind:class="[isFolded ? 'contentFolded' :'content']" -->
      <el-scrollbar style="height: 96%; width: 100%; background-color: #E9EEF3">
        <el-main>
          <router-view></router-view>
        </el-main>
      </el-scrollbar>
    </el-container>

    <!-- addProject dialog -->
    <el-dialog title="创建项目" :visible.sync="addProjectDialogVisible">
      <el-form :model="projectInfo" :rules="addProjectRules" ref="addProjectFormRef">
        <el-form-item label="项目名称" prop="name" :label-width="formLabelWidth">
          <el-input v-model="projectInfo.name" autocomplete="off" style="width: 90%"></el-input>
        </el-form-item>
        <el-form-item label="项目描述" prop="description" :label-width="formLabelWidth">
          <el-input v-model="projectInfo.description" autocomplete="off" style="width: 90%"></el-input>
        </el-form-item>
      </el-form>
      <template slot="footer">
        <span slot="footer" class="dialog-footer">
          <el-button type="primary" @click="addProject">创 建</el-button>
          <el-button @click="cancelAddProjectForm">取 消</el-button>
          <el-button @click="resetAddProjectForm">重 置</el-button>
        </span>
      </template>
    </el-dialog>
  </el-container>
</template>

<script>
import Vue from 'vue'

export default {
  created () {
    this.getProjectList()
  },
  data () {
    return {
      userName: 'test',
      isFolded: false,
      navList: [
        { name: '/deploy', navItem: '日志采集' }
      ],
      activeIndex: '1',
      projectList: [],
      // addProject dialog
      addProjectDialogVisible: false,
      formLabelWidth: '120px',
      projectInfo: {
        name: '',
        description: '',
        user_id: ''
      },
      addProjectRules: {
        name: [
          { required: true, message: '请输入项目名称', trigger: 'blur' },
          { min: 1, max: 30, message: '长度在 1 到 30 个字符', trigger: 'blur' }
        ],
        description: [
          { required: true, message: '请输入项目描述', trigger: 'blur' },
          { min: 1, max: 50, message: '长度在 1 到 50 个字符', trigger: 'blur' }
        ]
      },
      // searchInput
      searchInputVisible: true,
      queryText: ''
    }
  },
  methods: {
    async getProjectList () {
      const { data: res } = await this.$http.get(
        'project/getAllProject',
        { params: { user_id: this.$store.getters.getUser.id }, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.projectList = res.data

      // init this.$store.state.currentProjectId
      this.$store.state.currentProjectId = this.projectList[0].project.id
    },
    addProject () {
      this.$refs.addProjectFormRef.validate(async (valid) => {
        if (!valid) return false
        this.projectInfo.user_id = this.$store.getters.getUser.id
        await this.$http.post(
          'project/addProject',
          this.projectInfo,
          { headers: { Authorization: this.$store.getters.getToken } }
        )
        this.addProjectDialogVisible = false
        await this.getProjectList()
      })
      this.resetAddProjectForm()
    },
    cancelAddProjectForm () {
      this.resetAddProjectForm()
      this.addProjectDialogVisible = false
    },
    resetAddProjectForm () {
      this.projectInfo = {
        name: '',
        description: '',
        user_id: ''
      }
      this.$refs.addProjectFormRef.resetFields()
    },
    async deleteProject (id) {
      await this.$http.get(
        'project/deleteProject',
        { params: { id: id }, headers: { Authorization: this.$store.getters.getToken } }
      )
      await this.getProjectList()
    },
    async deleteCollect (id) {
      await this.$http.get(
        'project/deleteCollect',
        { params: { id: id }, headers: { Authorization: this.$store.getters.getToken } }
      )
      await this.getProjectList()
    },
    openDeleteProjectBox (id) {
      Vue.prototype.$confirm('此操作将删除该项目, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.deleteProject(id)
      }).catch(() => {
        Vue.prototype.$message({
          type: 'info',
          message: '已取消删除'
        })
      })
    },
    openDeleteCollectBox (id) {
      Vue.prototype.$confirm('此操作将删除该采集任务, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.deleteCollect(id)
      }).catch(() => {
        Vue.prototype.$message({
          type: 'info',
          message: '已取消删除'
        })
      })
    },
    async searchProject () {
      // Authorization: _this.$store.state.token || _this.$store.getters.getUser.username
      // console.log(localStorage.getItem('token'))
      const { data: res } = await this.$http.get(
        'project/searchProjectAndCollect',
        { params: { user_id: this.$store.getters.getUser.id, queryText: this.queryText }, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.projectList = res.data.data
      for (const resStateKey in res.data.state) {
        if (res.data.state[resStateKey] === 'open') {
          this.openSubMenu(resStateKey.toString())
        } else {
          this.closeSubMenu(resStateKey.toString())
        }
      }
    },
    openSubMenu (id) {
      this.$refs.sideBar.open(id)
    },
    closeSubMenu (id) {
      this.$refs.sideBar.close(id)
    },
    isProjectActive (id) {
      return id === this.$store.state.currentProjectId
    },
    setCurrentProjectId (id) {
      this.$store.state.currentProjectId = id
    },
    submenuClick (id, index) {
      this.setCurrentProjectId(id)
      if (this.projectList[index].collects.length !== 0) {
        this.$refs.sideBar.activeIndex = this.projectList[index].collects[0].id + ''
      } else {
        this.$refs.sideBar.activeIndex = '0'
      }
    },
    menuItemClick (id, collectId) {
      this.setCurrentProjectId(id)
    }
  }
}
</script>

<style scoped>
  .home-container {
    position: absolute;
    top: 0;
    bottom: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
    box-sizing: border-box;
  }
  .header{
    background-color: rgb(46, 54, 63);
    height: 60px;
  }
  .logo {
    font-family:gotham, helvetica, arial, sans-serif;
    width:280px;
    height:60px;
    font-size: 22px;
    text-align: center;
    border-color: rgba(238,241,146,0.3);
    border-right-width: 1px;
    border-right-style: solid;
    line-height: 60px;
    color: #EBEEF5;
  }
  .logoImage{
    cursor: pointer;
    width: 48px;
    height: 48px;
    margin:0 auto;
    line-height: 48px;
    margin-top: 6px;
    background-image:url('../assets/logo.png');
    background-size:100% 100%;
    background-repeat:no-repeat;
    transition: all 0.5s;
  }
  .tools{
    padding: 0 23px;
    width:14px;
    height: 60px;
    line-height: 60px;
    cursor: pointer;
    color:#EBEEF5;
  }

  .el-aside {
    /*background-color: #C0C4CC;*/
    background-color: #545C64;
    color: #333;
    text-align: center;
    line-height: 200px;
  }

  .el-main {
    background-color: #E9EEF3;
    color: #333;
    text-align: center;
    /*line-height: 160px;*/
    line-height: 20px !important;
  }

  .userInfo{
    float: right;
    margin-right: 10px;
    margin-top: -5px;
    cursor: pointer;
    height: 60px;
    color: #EBEEF5;
  }
  .userinfo-inner {
    cursor: pointer;
    color: #EBEEF5;
    margin-top: 20px;
    width: 40px;
    height: 40px;
    font-size: 30px;
    line-height: 30px;
  }
  .hidden {
    display: none;
  }
  .contentFolded{
    background: none repeat scroll 0 0 #E9EEF3;
    position: absolute;
    left: 0;
    right: 0;
    top: 60px;
    bottom: 0;
    width: auto;
    padding: 40px;
    box-sizing: border-box;
    overflow-y: auto;
  }
  /* add & sort & search */
  .bg-purple-dark {
    background: #545C64;
  }
  .projectFunction {
    border: 0 solid #C0C4CC;
    line-height: 50px;
  }
  /* searchInput */
  .SearchInput {
    display: none;
  }
  .headerText {
    height: 60px;
    line-height: 60px;
    cursor: pointer;
    color:#EBEEF5;
    align-content: center;
  }
  .activeProject {
    color: #409EFF;
  }
  a {
    text-decoraction: none;
    color: white;
  }
  .router-link-active {
    text-decoration: none;
    color: #409EFF;
  }
</style>

<style>
  .el-scrollbar .el-scrollbar__wrap {
    overflow-x: hidden;
  }

  .el-select-dropdown .el-scrollbar {
    padding-bottom: 17px;
  }

  .el-scrollbar__wrap {
    /*overflow-x: hidden;*/

    /*overflow: auto;*/
    /*width: 100%;*/
    /*height: 100%;*/
  }

  .el-upload-list__item {
    width: 85% !important;
  }
</style>
