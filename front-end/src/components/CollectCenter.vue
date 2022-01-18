<template>
  <div>
    <el-breadcrumb separator-class="el-icon-arrow-right">
      <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
      <el-breadcrumb-item>采集中心</el-breadcrumb-item>
    </el-breadcrumb>

    <el-card class="box-card">
      <el-row>
        <el-col :span="9" style="line-height: 40px">
          <el-input v-model="queryDeployParams.queryInfo" @keyup.enter.native="queryDeploy" placeholder="Please input" class="input-with-select">
            <template slot="prepend">
              <el-select v-model="queryDeployParams.selectLabel" placeholder="Select" style="width: 110px">
                <el-option label="应用名" value="应用名" style="text-align: center"></el-option>
                <el-option label="部署服务器" value="部署服务器" style="text-align: center"></el-option>
                <el-option label="部署集群" value="部署集群" style="text-align: center"></el-option>
                <el-option label="部署目录" value="部署目录" style="text-align: center"></el-option>
                <el-option label="部署时间" value="部署时间" style="text-align: center"></el-option>
              </el-select>
            </template>
            <el-button @click="queryDeploy" icon="el-icon-search" slot="append"></el-button>
          </el-input>
        </el-col>
        <el-col :span="3" style="line-height: 40px;" :offset="10">
          <el-button type="primary" size="medium" plain @click="addDeployButtonClick">应用部署</el-button>
        </el-col>
        <el-col :span="2" style="line-height: 40px">
          <el-button type="primary" size="medium" plain @click="deleteDeployBatch">批量删除</el-button>
        </el-col>
      </el-row>

      <el-table :data="deployList" style="width: 100%; margin-top: 20px" :header-row-style="{'height': '60px'}" @selection-change="handleSelectionChange" border stripe>
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="应用名" width="190" align="center">
          <template #default="scope">{{ scope.row.deploy.application_name }}</template>
        </el-table-column>
        <el-table-column label="部署服务器/集群" width="230" align="center">
          <template #default="scope">{{ scope.row.node }}</template>
        </el-table-column>
        <el-table-column label="部署目录" width="280" align="center">
          <template #default="scope">{{ scope.row.deploy.directory }}</template>
        </el-table-column>
        <el-table-column label="部署时间" width="230" align="center">
          <template #default="scope">
            <i class="el-icon-time"></i>
            <!-- <span style="margin-left: 10px">{{ scope.row.deploy.created }}</span> -->
            <span style="margin-left: 10px">{{ deployCreatedList[scope.$index] }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center">
          <template #default="scope">
            <el-button type="primary" icon="el-icon-delete" size="mini" plain @click="openDeleteDeployBox(scope.$index)"></el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:currentPage="getDeployParams.currentPage"
        :page-sizes="[1, 3, 5, 10]"
        :page-size="getDeployParams.pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="deployAmount"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px"
      >
      </el-pagination>
    </el-card>

    <el-dialog title="应用部署" style="text-align: left" :visible.sync="addDeployDialogVisible">
      <el-form ref="addDeployFormRef" :model="addDeployForm" :rules="addDeployFormRules" label-width="150px">
        <el-form-item label="应用部署">
          <el-upload ref="uploadRef"
                     :data="uploadData"
                     :action="uploadUrl"
                     :limit="1"
                     :auto-upload="false"
                     :on-change="uploadFileChange"
                     :on-success="uploadSuccess"
                     :before-remove="beforeRemove">
            <el-button slot="trigger" type="primary" size="small" plain>选取</el-button>
            <div slot="tip">只能上传一个应用，大小不能超过600MB！</div>
          </el-upload>
        </el-form-item>
        <el-form-item label="部署节点">
          <el-select v-model="addDeployForm.type" placeholder="Select" style="width: 110px" @change="deployFormTypeChange">
            <el-option label="服务器" value="服务器" style="text-align: center"></el-option>
            <el-option label="集群" value="集群" style="text-align: center"></el-option>
          </el-select>
          <el-select v-model="addDeployForm.nodeId" placeholder="Select" :style="addDeployForm.type === '服务器' ? 'margin-left: 18px; width: 62.5%' : 'margin-left: 18px; width: 42.5%'">
            <el-option v-for="node in nodes" :key="node.id" :label="node.value" :value="node.id" style="text-align: center"></el-option>
          </el-select>
          <el-button
            v-if="addDeployForm.type === '集群'"
            type="primary" size="medium" plain style="margin-left: 18px"
            @click="addClusterButtonClick">新建集群</el-button>
        </el-form-item>
        <el-form-item v-if="addDeployForm.type === '服务器'" label="部署目录" prop="directory">
          <el-input v-model="addDeployForm.directory" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="是否需要执行脚本">
          <el-switch v-model="addDeployForm.is_execute" />
        </el-form-item>
        <el-form-item v-if="addDeployForm.is_execute" label="执行脚本">
          <el-upload ref="scriptServerRef"
                     :limit="1"
                     :data="scriptServerComputedData"
                     :action="scriptServerUrl"
                     :on-success="scriptServerSuccess"
                     :on-change="scriptServerChange">
            <el-button slot="trigger" type="primary" size="small" plain>选取</el-button>
          </el-upload>
          <codemirror v-if="addDeployForm.is_execute & scriptVisible" ref="codemirrorScriptServerRef"
                      style="width: 85%; margin-top: 20px; line-height: 150%; font-size: 14px"
                      :value="scriptServerCode"
                      :options="scriptOptions"
                      @changes="updateMirrorCode">
          </codemirror>
        </el-form-item>
      </el-form>
      <template slot="footer">
        <span class="dialog-footer">
          <el-button type="primary" @click="addDeploy">部署</el-button>
          <el-button @click="cancelAddDeployForm">取消</el-button>
          <el-button @click="resetAddDeployForm">重置</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 新建集群 -->
    <el-dialog title="新建集群" style="text-align: left" :visible.sync="addClusterDialogVisible">
      <el-form ref="addClusterFormRef" :model="addClusterForm" :rules="addClusterFormRules" label-width="150px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="addClusterForm.name" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="addClusterForm.description" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="服务器列表">
          <el-table ref="addClusterTableRef" :data="serverList" style="width: 85%; margin-top: 15px" :header-row-style="{'height': '60px'}" @selection-change="selectServerChange" border stripe>
            <el-table-column type="selection" width="55" align="center" />
            <el-table-column label="IP" width="240" align="center">
              <template #default="scope">{{ scope.row.ip }}</template>
            </el-table-column>
            <el-table-column label="用户名" align="center">
              <template #default="scope">{{ scope.row.username }}</template>
            </el-table-column>
          </el-table>
        </el-form-item>
      </el-form>
      <template slot="footer">
        <span class="dialog-footer">
          <el-button type="primary" @click="addCluster">创建</el-button>
          <el-button @click="cancelAddClusterForm">取消</el-button>
          <el-button @click="resetAddClusterForm">重置</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 采集模块 -->
    <el-card class="box-card" style="margin-top: 20px">
      <el-row>
        <el-col :span="9" style="line-height: 40px">
          <el-input v-model="queryCollectParams.queryInfo" @keyup.enter.native="queryCollect" placeholder="Please input" class="input-with-select">
            <template slot="prepend">
              <el-select v-model="queryCollectParams.selectLabel" placeholder="Select" style="width: 110px">
                <el-option label="采集任务" value="采集任务" style="text-align: center"></el-option>
                <el-option label="应用名" value="应用名" style="text-align: center"></el-option>
                <el-option label="部署服务器" value="部署服务器" style="text-align: center"></el-option>
                <el-option label="部署集群" value="部署集群" style="text-align: center"></el-option>
                <el-option label="配置信息" value="配置信息" style="text-align: center"></el-option>
                <el-option label="用例类名" value="用例类名" style="text-align: center"></el-option>
                <el-option label="创建时间" value="创建时间" style="text-align: center"></el-option>
              </el-select>
            </template>
            <el-button @click="queryCollect" icon="el-icon-search" slot="append"></el-button>
          </el-input>
        </el-col>
        <el-col :span="3" style="line-height: 40px;" :offset="10">
          <el-button type="primary" size="medium" plain @click="addCollectDialogVisible = true;">新建采集任务</el-button>
        </el-col>
        <el-col :span="2" style="line-height: 40px">
          <el-button type="primary" size="medium" plain @click="deleteCollectBatch">批量删除</el-button>
        </el-col>
      </el-row>

      <el-table :data="collectList" style="width: 100%; margin-top: 20px" :header-row-style="{'height': '60px'}" @selection-change="handleCollectSelectionChange" border stripe>
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="采集任务" width="120" align="center">
          <template #default="scope">{{ scope.row.collect.name }}</template>
        </el-table-column>
        <el-table-column label="应用名" width="120" align="center">
          <template #default="scope">{{ scope.row.application_name }}</template>
        </el-table-column>
        <el-table-column label="部署服务器/集群" width="150" align="center">
          <template #default="scope">{{ scope.row.node }}</template>
        </el-table-column>
        <el-table-column label="配置信息" width="140" align="center">
          <template #default="scope">
            <el-link @click="previewAgentConfig(scope.row.collect.id)" type="primary">agent-config.xml</el-link>
            <el-link @click="previewConfig(scope.row.collect.id)" type="primary">config.xml</el-link>
          </template>
        </el-table-column>
        <el-table-column label="用例类名" width="120" align="center">
          <template #default="scope">{{ scope.row.collect.use_case_name }}</template>
        </el-table-column>
        <el-table-column label="创建时间" width="130" align="center">
          <template #default="scope">
            <i class="el-icon-time"></i>
            <span style="margin-left: 10px">{{ collectCreatedList[scope.$index] }}</span>
          </template>
        </el-table-column>
        <el-table-column label="日志下载" width="120" align="center">
          <template #default="scope">
            <div v-if="scope.row.collect.is_build">
              <el-link @click="downloadLog(scope.row.collect.id)" type="primary">{{ scope.row.collect.log_name }}</el-link>
            </div>
            <div v-else>待采集</div>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center">
          <template #default="scope">
            <el-button type="primary" icon="el-icon-moon-night" size="mini" plain @click="buildCollect(scope.row.collect.id)"></el-button>
            <el-button type="primary" icon="el-icon-edit" size="mini" plain @click="editCollect(scope.$index, scope.row)"></el-button>
            <el-button type="primary" icon="el-icon-delete" size="mini" plain @click="openDeleteCollectBox(scope.$index)"></el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:currentPage="getCollectParams.currentPage"
        :page-sizes="[1, 3, 5, 10]"
        :page-size="getCollectParams.pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="collectAmount"
        @size-change="collectSizeChange"
        @current-change="collectCurrentChange"
        style="margin-top: 20px"
      >
      </el-pagination>
    </el-card>

    <el-dialog title="新建采集任务" style="text-align: left" :visible.sync="addCollectDialogVisible">
      <el-form ref="addCollectFormRef" :model="addCollectForm" :rules="addCollectFormRules" label-width="150px">
        <el-form-item label="采集任务名称" prop="name">
          <el-input v-model="addCollectForm.name" style="width: 85%"></el-input>
        </el-form-item>
        <!--
        <el-form-item label="部署应用id" prop="deploy_id">
          <el-select v-model="addCollectForm.deploy_id" placeholder="Select" @change="getCollectFormDetail(addCollectForm.deploy_id)">
            <el-option v-for="deployMap in deployList" :key="deployMap.deploy.id" :label="deployMap.deploy.id" :value="deployMap.deploy.id" style="text-align: center"></el-option>
          </el-select>
        </el-form-item>
        -->
        <el-form-item label="应用名_部署节点" prop="deploy_id">
          <el-select v-model="addCollectForm.deploy_id" placeholder="Select" @change="getCollectFormDetail(addCollectForm.deploy_id)" style="display: block; width: 85%">
            <el-option v-for="deployMap in deployList" :key="deployMap.deploy.id" :label="deployMap.deploy.application_name + '_' + deployMap.node" :value="deployMap.deploy.id" style="text-align: center"></el-option>
          </el-select>
        </el-form-item>
        <!--
        <el-form-item label="应用名">
          <el-input disabled v-model="selectApplicationDetail.application_name" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="部署服务器/集群">
          <el-input disabled v-model="selectApplicationDetail.node" style="width: 85%"></el-input>
        </el-form-item>
        -->
        <el-form-item label="部署目录">
          <el-input disabled v-model="selectApplicationDetail.directory" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="部署时间">
          <el-input disabled v-model="selectApplicationDetail.created" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="是否使用默认配置">
          <el-switch v-model="addCollectForm.is_default" />
        </el-form-item>
        <div v-if="!addCollectForm.is_default">
          <el-form-item :label="(index === 0) ? '选择采集包名' : ''" v-for="(collectPackage, index) in addCollectForm.collectPackageList" :key="collectPackage.id">
            <el-input disabled :placeholder="collectPackage.name" style="width: 78%" />
            <el-checkbox v-model="collectPackage.is_collect" style="zoom: 150%; margin-left: 12px"></el-checkbox>
          </el-form-item>
        </div>
        <el-form-item v-if="!addCollectForm.is_default" label="日志文件名称">
          <el-input v-model="addCollectForm.log_name" style="width: 85%"></el-input>
        </el-form-item>
        <el-form-item label="用例类名">
          <el-input v-model="addCollectForm.use_case_name" style="width: 85%"></el-input>
        </el-form-item>
      </el-form>
      <template slot="footer">
        <span class="dialog-footer">
          <el-button type="primary" @click="addCollect">创建</el-button>
          <el-button @click="cancelAddCollectForm">取消</el-button>
          <el-button @click="resetAddCollectForm">重置</el-button>
        </span>
      </template>
    </el-dialog>

    <el-dialog title="agent-config.xml" style="text-align: left" :visible.sync="agentConfigDialogVisible">
      <codemirror v-if="agentConfigCodeVisible" ref="agentConfigCodeRef"
                  style="width: 100%; line-height: 150%; font-size: 14px"
                  :value="agentConfigCode"
                  :options="configOptions">
      </codemirror>
    </el-dialog>

    <el-dialog title="config.xml" style="text-align: left" :visible.sync="configDialogVisible">
      <codemirror v-if="configCodeVisible" ref="configCodeRef"
                  style="width: 100%; line-height: 150%; font-size: 14px"
                  :value="configCode"
                  :options="configOptions">
      </codemirror>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios'
import Vue from 'vue'
import { codemirror } from 'vue-codemirror'
import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/ayu-mirage.css'
import 'codemirror/mode/shell/shell'
import 'codemirror/mode/xml/xml'

export default {
  name: 'CollectCenter',
  created () {
    setTimeout(() => {
      this.addDeployForm.project_id = this.$store.state.currentProjectId
      this.getNodes()
      this.getDeploy()
      this.getCollect()
    }, 100)
  },
  components: {
    codemirror
  },
  data () {
    return {
      // codemirror (edit server script)
      scriptServerCode: '',
      scriptOptions: {
        tabSize: 4,
        mode: 'application/x-sh',
        // mode: 'application/xml',
        theme: 'ayu-mirage',
        lineNumbers: true,
        line: true,
        cursorHeight: 0.90
      },
      scriptVisible: false,
      // 部署模块
      nodes: [],
      addDeployDialogVisible: false,
      addDeployForm: {
        type: '服务器',
        nodeId: '请选择',
        directory: '',
        project_id: 0,
        is_execute: false,
        script: '',
        code: ''
      },
      addDeployFormRules: {
        directory: [
          {
            required: true,
            message: '请输入应用部署目录',
            trigger: 'blur'
          }
        ]
      },
      uploadUrl: axios.defaults.baseURL + '/collect/addDeploy',
      uploadFile: [],
      getDeployParams: {
        currentPage: 1,
        pageSize: 5,
        project_id: 0
      },
      deployList: [],
      deployCreatedList: [],
      deployAmount: 0,
      deploySelected: [],
      queryDeployParams: {
        selectLabel: '应用名',
        queryInfo: '',
        currentPage: 1,
        pageSize: 5,
        project_id: 0
      },
      scriptServerUrl: axios.defaults.baseURL + '/collect/uploadServerScript',
      scriptServerData: {
        project_id: 0,
        applicationName: ''
      },
      // 集群模块
      addClusterDialogVisible: false,
      addClusterForm: {
        name: '',
        description: '',
        project_id: 0,
        serverList: []
      },
      addClusterFormRules: {
        name: [
          { required: true, message: '请输入项目名称', trigger: 'blur' },
          { min: 1, max: 30, message: '长度在 1 到 30 个字符', trigger: 'blur' }
        ],
        description: [
          { required: true, message: '请输入项目描述', trigger: 'blur' },
          { min: 1, max: 50, message: '长度在 1 到 50 个字符', trigger: 'blur' }
        ]
      },
      serverList: [],
      // 采集模块
      addCollectDialogVisible: false,
      addCollectForm: {
        name: '',
        deploy_id: '请选择',
        is_default: true,
        log_name: '',
        use_case_name: '',
        project_id: 0,
        collectPackageList: []
      },
      addCollectFormRules: {
        name: [
          {
            required: true,
            message: '请输入采集任务名称',
            trigger: 'blur'
          }
        ],
        deploy_id: [
          {
            required: true,
            message: '请选择部署应用id',
            trigger: 'blur'
          }
        ]
      },
      selectApplicationDetail: {},
      getCollectParams: {
        currentPage: 1,
        pageSize: 5,
        project_id: 0
      },
      collectList: [],
      collectCreatedList: [],
      collectAmount: 0,
      collectSelected: [],
      queryCollectParams: {
        selectLabel: '采集任务',
        queryInfo: '',
        currentPage: 1,
        pageSize: 5,
        project_id: 0
      },
      // CodeMirror agentConfig.xml & config.xml
      configOptions: {
        tabSize: 4,
        mode: 'application/xml',
        theme: 'ayu-mirage',
        lineNumbers: true,
        line: true,
        cursorHeight: 0.90,
        readOnly: true
      },
      agentConfigDialogVisible: false,
      agentConfigCodeVisible: false,
      agentConfigCode: '',
      configDialogVisible: false,
      configCodeVisible: false,
      configCode: ''
    }
  },
  methods: {
    // 部署模块
    addDeployButtonClick () {
      this.addDeployDialogVisible = true
      this.scriptServerData.project_id = this.$store.state.currentProjectId
    },
    async getNodes () {
      const { data: res } = await this.$http.get(
        'collect/getNodes',
        { params: { project_id: this.$store.state.currentProjectId, type: this.addDeployForm.type }, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.nodes = res.data
    },
    deployFormTypeChange () {
      this.getNodes()
      this.addDeployForm.nodeId = '请选择'
      this.addDeployForm.is_execute = false
      this.scriptVisible = false
    },
    cancelAddDeployForm () {
      this.resetAddDeployForm()
      this.addDeployDialogVisible = false
    },
    resetAddDeployForm () {
      console.log('xxx')
      this.addDeployForm = {
        type: '服务器',
        nodeId: '请选择',
        directory: '',
        project_id: 0,
        is_execute: false,
        script: '',
        code: ''
      }
      this.scriptServerCode = ''
      this.scriptVisible = false
      this.$refs.addDeployFormRef.resetFields()
      // this.$refs.uploadRef.clearFiles()
      // this.$refs.scriptServerRef.clearFiles()
    },
    async addDeploy () {
      this.addDeployForm.project_id = this.$store.state.currentProjectId
      this.addDeployForm.code = this.scriptServerCode
      await this.$refs.addDeployFormRef.validate(async (valid) => {
        if (!valid) return false
        this.$nextTick(async () => {
          await this.$refs.uploadRef.submit()
          this.cancelAddDeployForm()
        })
      })
    },
    uploadFileChange (file, fileList) {
      this.uploadFile = fileList
      this.scriptServerData.applicationName = this.uploadFile[0].name
    },
    uploadSuccess () {
      this.getDeploy()
    },
    beforeRemove (file, fileList) {
      return Vue.prototype.$confirm(`确定取消上传 ${file.name} 吗?`)
    },
    async getDeploy () {
      this.getDeployParams.project_id = this.$store.state.currentProjectId
      const { data: res } = await this.$http.get(
        'collect/getDeploy',
        { params: this.getDeployParams, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.deployList = res.data
      if (this.deployList !== undefined && this.deployList !== null && this.deployList.length > 0) {
        this.deployAmount = this.deployList[0].deployAmount
      } else {
        this.deployAmount = 0
      }
      for (const item of this.deployList) {
        let created = item.deploy.created
        created = created.substring(0, 10) + ' ' + created.substring(11)
        this.deployCreatedList.push(created)
      }
    },
    handleSizeChange (newPageSize) {
      this.getDeployParams.currentPage = 1
      this.getDeployParams.pageSize = newPageSize
      this.getDeploy()
    },
    handleCurrentChange (newCurrentPage) {
      this.getDeployParams.currentPage = newCurrentPage
      this.getDeploy()
    },
    async deleteDeploy (index) {
      await this.$http.post(
        'collect/deleteDeploy',
        this.deployList[index].deploy,
        { headers: { Authorization: this.$store.getters.getToken } }
      )
      await this.getDeploy()
    },
    openDeleteDeployBox (index) {
      Vue.prototype.$confirm('此操作将撤销该应用部署, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.deleteDeploy(index)
      }).catch(() => {
        Vue.prototype.$message({
          type: 'info',
          message: '已取消删除'
        })
      })
    },
    handleSelectionChange (selection) {
      console.log('selection: ' + JSON.stringify(selection))
      this.deploySelected = selection
    },
    async deleteDeployBatch () {
      await this.$http.post(
        'collect/deleteDeployBatch',
        this.deploySelected,
        { headers: { Authorization: this.$store.getters.getToken } }
      )
      await this.getDeploy()
    },
    async queryDeploy () {
      this.queryDeployParams.currentPage = this.getDeployParams.currentPage
      this.queryDeployParams.pageSize = this.getDeployParams.pageSize
      this.queryDeployParams.project_id = this.$store.state.currentProjectId
      const { data: res } = await this.$http.get(
        'collect/queryDeploy',
        { params: this.queryDeployParams, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.deployList = res.data
      if (this.deployList !== undefined && this.deployList !== null && this.deployList.length > 0) {
        this.deployAmount = this.deployList[0].deployAmount
      } else {
        this.deployAmount = 0
      }
    },
    scriptServerChange (file, fileList) {
      if (fileList.length > 0) {
        this.addDeployForm.script = fileList[0].name
      }
    },
    async scriptServerSuccess () {
      const id = this.$store.state.currentProjectId
      const { data: res } = await this.$http.get(
        'collect/getServerScript',
        { params: { project_id: id, applicationName: this.scriptServerData.applicationName, script: this.addDeployForm.script }, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.scriptServerCode = res.data
      this.scriptVisible = true
    },
    updateMirrorCode () {
      this.scriptServerCode = this.$refs.codemirrorScriptServerRef.codemirror.getValue()
    },
    // 集群模块
    selectServerChange (selection) {
      this.addClusterForm.serverList = selection
    },
    addClusterButtonClick () {
      this.getServer()
      this.addClusterDialogVisible = true
    },
    async getServer () {
      const id = this.$store.state.currentProjectId
      const { data: res } = await this.$http.get(
        'collect/getServer',
        { params: { project_id: id }, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.serverList = res.data
    },
    async addCluster () {
      this.addClusterForm.project_id = this.$store.state.currentProjectId
      await this.$http.post(
        'collect/addCluster',
        this.addClusterForm,
        { headers: { Authorization: this.$store.getters.getToken } }
      )
      this.cancelAddClusterForm()
      await this.getNodes()
    },
    cancelAddClusterForm () {
      this.resetAddClusterForm()
      this.addClusterDialogVisible = false
    },
    resetAddClusterForm () {
      this.addClusterForm = {
        name: '',
        description: '',
        project_id: 0,
        serverList: []
      }
      this.$refs.addClusterFormRef.resetFields()
      this.$refs.addClusterTableRef.clearSelection()
    },
    // 采集模块
    async getCollectFormDetail (id) {
      const { data: res } = await this.$http.get(
        'collect/getCollectFormDetail',
        { params: { id: id }, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.selectApplicationDetail = res.data.selectApplicationDetail
      this.addCollectForm.collectPackageList = res.data.collectPackageList
    },
    cancelAddCollectForm () {
      this.resetAddCollectForm()
      this.addCollectDialogVisible = false
    },
    resetAddCollectForm () {
      this.addCollectForm = {
        name: '',
        deploy_id: '请选择',
        is_default: true,
        log_name: '',
        use_case_name: '',
        project_id: 0,
        collectPackageList: []
      }
      this.$refs.addCollectFormRef.resetFields()
    },
    async addCollect () {
      this.addCollectForm.project_id = this.$store.state.currentProjectId
      await this.$http.post(
        'collect/addCollect',
        this.addCollectForm,
        { headers: { Authorization: this.$store.getters.getToken } }
      )
      this.cancelAddCollectForm()
      await this.getCollect()
    },
    async getCollect () {
      this.getCollectParams.project_id = this.$store.state.currentProjectId
      const { data: res } = await this.$http.get(
        'collect/getCollect',
        { params: this.getCollectParams, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.collectList = res.data
      if (this.collectList !== undefined && this.collectList !== null && this.collectList.length > 0) {
        this.collectAmount = this.collectList[0].collectAmount
      } else {
        this.collectAmount = 0
      }
      for (const item of this.collectList) {
        let created = item.collect.created
        created = created.substring(0, 10) + ' ' + created.substring(11)
        this.collectCreatedList.push(created)
      }
    },
    collectSizeChange (newPageSize) {
      this.getCollectParams.currentPage = 1
      this.getCollectParams.pageSize = newPageSize
      this.getCollect()
    },
    collectCurrentChange (newCurrentPage) {
      this.getCollectParams.currentPage = newCurrentPage
      this.getCollect()
    },
    async buildCollect (id) {
      await this.$http.post(
        'collect/buildCollect',
        { id: id },
        { headers: { Authorization: this.$store.getters.getToken } }
      )
      await this.getCollect()
    },
    async deleteCollect (index) {
    },
    openDeleteCollectBox (index) {
      Vue.prototype.$confirm('此操作将删除该采集任务, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.deleteCollect(index)
      }).catch(() => {
        Vue.prototype.$message({
          type: 'info',
          message: '已取消删除'
        })
      })
    },
    handleCollectSelectionChange (selection) {
      this.collectSelected = selection
    },
    async deleteCollectBatch () {
    },
    async queryCollect () {
    },
    async downloadLog (id) {
      window.open(axios.defaults.baseURL + '/collect/downloadLog?id=' + id, '_blank')
    },
    async previewAgentConfig (id) {
      const { data: res } = await this.$http.get(
        'collect/previewAgentConfig',
        { params: { collect_id: id }, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.agentConfigDialogVisible = true
      this.agentConfigCode = res.data
      this.agentConfigCodeVisible = true
    },
    async previewConfig (id) {
      const { data: res } = await this.$http.get(
        'collect/previewConfig',
        { params: { collect_id: id }, headers: { Authorization: this.$store.getters.getToken } }
      )
      this.configDialogVisible = true
      this.configCode = res.data
      this.configCodeVisible = true
    }
  },
  computed: {
    // 部署模块
    uploadData: function () {
      return this.addDeployForm
    },
    scriptServerComputedData: function () {
      return this.scriptServerData
    }
  },
  watch: {
    '$store.state.currentProjectId': function () {
      this.getNodes()
      this.getDeploy()
      this.getCollect()
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
