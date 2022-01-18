<template>
  <div>
    <el-breadcrumb separator-class="el-icon-arrow-right">
      <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
      <el-breadcrumb-item>服务器配置</el-breadcrumb-item>
    </el-breadcrumb>

    <el-card class="box-card">
      <el-row>
        <el-col :span="9" style="line-height: 40px">
          <el-input v-model="queryServerParams.queryInfo" @keyup.enter.native="queryServer" placeholder="Please input" class="input-with-select">
            <template slot="prepend">
              <el-select v-model="queryServerParams.selectLabel" placeholder="Select" style="width: 110px">
                <el-option label="IP" value="IP" style="text-align: center"></el-option>
                <el-option label="端口" value="端口" style="text-align: center"></el-option>
                <el-option label="用户名" value="用户名" style="text-align: center"></el-option>
                <el-option label="采集工具" value="采集工具" style="text-align: center"></el-option>
                <el-option label="状态" value="状态" style="text-align: center"></el-option>
                <el-option label="创建时间" value="创建时间" style="text-align: center"></el-option>
              </el-select>
            </template>
            <el-button @click="queryServer" icon="el-icon-search" slot="append"></el-button>
          </el-input>
        </el-col>
        <el-col :span="3" style="line-height: 40px;" :offset="10">
          <el-button type="primary" size="medium" plain @click="addServerDialogVisible = true">添加服务器</el-button>
        </el-col>
        <el-col :span="2" style="line-height: 40px">
          <el-button type="primary" size="medium" plain @click="deleteServerBatch">批量删除</el-button>
        </el-col>
      </el-row>

      <el-table :data="serverList" style="width: 100%; margin-top: 20px" :header-row-style="{'height': '60px'}" @selection-change="handleSelectionChange" border stripe>
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="IP" width="150" align="center">
          <template #default="scope">{{ scope.row.server.ip }}</template>
        </el-table-column>
        <el-table-column label="端口" width="90" align="center">
          <template #default="scope">{{ scope.row.server.port }}</template>
        </el-table-column>
        <el-table-column label="用户名" width="120" align="center">
          <template #default="scope">{{ scope.row.server.username }}</template>
        </el-table-column>
        <el-table-column label="采集工具" width="150" align="center">
          <template #default="scope">{{ scope.row.collectToolName }}</template>
        </el-table-column>
        <el-table-column label="状态" width="150" align="center">
          <template #default="scope">{{ scope.row.server.status }}</template>
        </el-table-column>
        <el-table-column label="创建时间" width="210" align="center">
          <template #default="scope">
            <i class="el-icon-time"></i>
            <span style="margin-left: 10px">{{ serverCreatedList[scope.$index] }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center">
          <template #default="scope">
            <el-button type="primary" icon="el-icon-s-promotion" size="mini" plain @click="testServer(scope.$index)"></el-button>
            <el-button type="primary" icon="el-icon-edit" size="mini" plain @click="handleEdit(scope.$index, scope.row)"></el-button>
            <el-button type="primary" icon="el-icon-delete" size="mini" plain @click="openDeleteServerBox(scope.$index)"></el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:currentPage="getServerParams.currentPage"
        :page-sizes="[1, 3, 5, 10]"
        :page-size="getServerParams.pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="serverAmount"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px"
      >
      </el-pagination>
    </el-card>

    <el-dialog title="添加服务器" style="text-align: left" :visible.sync="addServerDialogVisible">
      <el-form ref="addServerFormRef" :model="addServerForm" :rules="addServerFormRules" label-width="150px">
        <el-form-item label="IP 地址" prop="ip">
          <el-input v-model="addServerForm.ip" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="端口" prop="port">
          <el-input v-model="addServerForm.port" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="用户名" prop="username">
          <el-input v-model="addServerForm.username" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="addServerForm.password" style="width: 85%" show-password></el-input>
        </el-form-item>
        <el-form-item label="测试连接">
          <el-button type="primary" icon="el-icon-s-promotion" size="mini" plain @click="testWhenAddServer"></el-button>
        </el-form-item>
        <el-form-item label="使用默认采集工具">
          <el-switch v-model="addServerForm.is_default"></el-switch>
        </el-form-item>
        <el-form-item v-if="!addServerForm.is_default" label="采集工具上传">
          <el-upload ref="uploadRef"
                     :data="uploadData"
                     :action="uploadUrl"
                     :limit="1"
                     :auto-upload="false"
                     :on-success="uploadSuccess"
                     :before-remove="beforeRemove">
            <el-button slot="trigger" type="primary" size="small" plain>选取</el-button>
            <div slot="tip">只能上传一个采集工具，大小不能超过100MB！</div>
          </el-upload>
        </el-form-item>
      </el-form>
      <!-- <el-progress v-if="addServerProgress" :percentage="0" :format="addServerFormat" :indeterminate="true" /> -->
      <template slot="footer">
        <span class="dialog-footer">
          <el-button type="primary" @click="addServer">创建</el-button>
          <el-button @click="cancelAddServerForm">取消</el-button>
          <el-button @click="resetAddServerForm">重置</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios'
import Vue from 'vue'

export default {
  name: 'ServerManage',
  created () {
    // this.getProjectList()
    setTimeout(() => {
      this.getServerParams.project_id = this.$store.state.currentProjectId
      this.getServer()
    }, 100)
  },
  data () {
    return {
      addServerDialogVisible: false,
      addServerForm: {
        ip: '',
        port: '',
        username: '',
        password: '',
        status: 'DISCONNECTED',
        is_default: false,
        project_id: 0
      },
      addServerFormRules: {
        ip: [
          {
            required: true,
            message: '请输入服务器IP地址',
            trigger: 'blur'
          }
        ],
        port: [
          {
            required: true,
            message: '请输入服务器端口号',
            trigger: 'blur'
          }
        ],
        username: [
          {
            required: true,
            message: '请输入用户名',
            trigger: 'blur'
          }
        ],
        password: [
          {
            required: true,
            message: '请输入密码',
            trigger: 'blur'
          }
        ]
      },
      uploadUrl: axios.defaults.baseURL + '/server/addServer',
      getServerParams: {
        currentPage: 1,
        pageSize: 5,
        project_id: 0
      },
      serverList: [],
      serverCreatedList: [],
      serverAmount: 0,
      tableSelection: [],
      queryServerParams: {
        selectLabel: 'IP',
        queryInfo: '',
        currentPage: 1,
        pageSize: 5,
        project_id: 0
      },
      addServerProgress: false,
      addServerFormat: '服务器添加中'
    }
  },
  methods: {
    async addServer () {
      // this.addServerProgress = true
      if (this.addServerForm.is_default === true) {
        this.addServerForm.project_id = this.$store.state.currentProjectId
        await this.$http.post(
          'server/addServerWithoutFile',
          this.addServerForm,
          { headers: { Authorization: this.$store.getters.getToken } }
        )
        this.cancelAddServerForm()
        await this.getServer()
      } else {
        this.addServerForm.project_id = this.$store.state.currentProjectId
        await this.$refs.addServerFormRef.validate(async (valid) => {
          if (!valid) return false
          this.$nextTick(async () => {
            await this.$refs.uploadRef.submit()
            this.cancelAddServerForm()
          })
        })
      }
    },
    cancelAddServerForm () {
      this.resetAddServerForm()
      this.addServerDialogVisible = false
      // this.addServerProgress = false
    },
    resetAddServerForm () {
      this.addServerForm = {
        ip: '',
        port: '',
        username: '',
        password: '',
        status: 'DISCONNECTED',
        is_default: false,
        project_id: ''
      }
      this.$refs.addServerFormRef.resetFields()
      // this.$refs.uploadRef.clearFiles()
    },
    uploadSuccess () {
      this.getServer()
    },
    beforeRemove (file, fileList) {
      return Vue.prototype.$confirm(`确定取消上传 ${file.name} 吗?`)
    },
    async deleteServer (index) {
      await this.$http.post(
        'server/deleteServer',
        this.serverList[index].server,
        { headers: { Authorization: this.$store.getters.getToken } }
      )
      await this.getServer()
    },
    openDeleteServerBox (index) {
      Vue.prototype.$confirm('此操作将删除该服务器, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.deleteServer(index)
      }).catch(() => {
        Vue.prototype.$message({
          type: 'info',
          message: '已取消删除'
        })
      })
    },
    handleSizeChange (newPageSize) {
      this.getServerParams.currentPage = 1
      this.getServerParams.pageSize = newPageSize
      this.getServer()
    },
    handleCurrentChange (newCurrentPage) {
      this.getServerParams.currentPage = newCurrentPage
      this.getServer()
    },
    async getServer () {
      this.getServerParams.project_id = this.$store.state.currentProjectId
      const { data: res } = await this.$http.get(
        'server/getServer',
        { params: this.getServerParams, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.serverList = res.data
      if (this.serverList !== undefined && this.serverList !== null && this.serverList.length > 0) {
        this.serverAmount = this.serverList[0].serverAmount
      } else {
        this.serverAmount = 0
      }
      for (const item of this.serverList) {
        let created = item.server.created
        created = created.substring(0, 10) + ' ' + created.substring(11)
        this.serverCreatedList.push(created)
      }
    },
    async testServer (index) {
      const { data: res } = await this.$http.post(
        'server/testServer',
        this.serverList[index].server,
        { headers: { Authorization: this.$store.getters.getToken } }
      )
      if (res.data === 'CONNECTED') {
        Vue.prototype.$message({
          type: 'success',
          message: '连接测试成功'
        })
      } else {
        Vue.prototype.$message({
          type: 'error',
          message: '连接测试失败'
        })
      }
      this.serverList[index].server.status = res.data
      await this.getServer()
    },
    async testWhenAddServer () {
      this.addServerForm.project_id = this.$store.state.currentProjectId
      const { data: res } = await this.$http.post(
        'server/testServer',
        this.addServerForm,
        { headers: { Authorization: this.$store.getters.getToken } }
      )
      if (res.data === 'CONNECTED') {
        Vue.prototype.$message({
          type: 'success',
          message: '连接测试成功'
        })
      } else {
        Vue.prototype.$message({
          type: 'error',
          message: '连接测试失败'
        })
      }
      this.addServerForm.status = res.data
    },
    handleSelectionChange (selection) {
      console.log('selection: ' + JSON.stringify(selection))
      this.tableSelection = selection
    },
    async deleteServerBatch () {
      await this.$http.post(
        'server/deleteServerBatch',
        this.tableSelection,
        { headers: { Authorization: this.$store.getters.getToken } }
      )
      await this.getServer()
    },
    async queryServer () {
      this.queryServerParams.currentPage = this.getServerParams.currentPage
      this.queryServerParams.pageSize = this.getServerParams.pageSize
      this.queryServerParams.project_id = this.$store.state.currentProjectId
      const { data: res } = await this.$http.get(
        'server/queryServer',
        { params: this.queryServerParams, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.serverList = res.data
      if (this.serverList !== undefined && this.serverList !== null && this.serverList.length > 0) {
        this.serverAmount = this.serverList[0].serverAmount
      } else {
        this.serverAmount = 0
      }
    }
  },
  computed: {
    uploadData: function () {
      return this.addServerForm
    }
  },
  watch: {
    '$store.state.currentProjectId': function (afterModifyId) {
      this.getServer()
    }
  }
}
</script>

<style scoped>
  .el-breadcrumb {
    margin-bottom: 15px;
  }

  .el-card {
    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.15) !important;
  }
</style>
