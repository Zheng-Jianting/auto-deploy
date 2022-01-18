<template>
  <div class="login_container">
    <div class="login_box">
      <div class="text" style="border: 0"> 自动部署平台 </div>
      <!-- 登录表单区域 -->
      <el-form :model="ruleForm" :rules="rules" ref="ruleFormRef" class="demo-ruleForm">
        <el-form-item prop="username">
          <el-input placeholder="username" prefix-icon="iconfont icon-user" v-model="ruleForm.username"></el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input @keyup.enter.native="submitForm" placeholder="password" prefix-icon="iconfont icon-3702mima" type="password" v-model="ruleForm.password"></el-input>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="submitForm">登陆</el-button>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="register">去注册</el-button>
        </el-form-item>
      </el-form>
    </div>

    <vue-particles
        color="#fff"
        :particleOpacity="0.7"
        :particlesNumber="60"
        shapeType="circle"
        :particleSize="4"
        linesColor="#fff"
        :linesWidth="1"
        :lineLinked="true"
        :lineOpacity="0.4"
        :linesDistance="150"
        :moveSpeed="2"
        :hoverEffect="true"
        hoverMode="grab"
        :clickEffect="true"
        clickMode="push"
        class="lizi"
        style="height:100%"
    >
    </vue-particles>
  </div>
</template>

<script>
export default {
  data () {
    return {
      ruleForm: {
        username: '',
        password: ''
      },
      rules: {
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' },
          { min: 3, max: 8, message: '长度在 3 到 8 个字符', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'change' },
          { min: 6, message: '长度至少为6个字符', trigger: 'blur' }
        ]
      }
    }
  },
  methods: {
    submitForm () {
      this.$refs.ruleFormRef.validate((valid) => {
        if (valid) {
          const _this = this
          this.$http.post('/login', this.ruleForm).then(res => {
            const jwt = res.headers.authorization
            const userInfo = res.data.data
            // 把数据共享出去
            _this.$store.commit('SET_TOKEN', jwt)
            _this.$store.commit('SET_USERINFO', userInfo)
            // 获取
            // console.log(_this.$store.getters.getUser)
            this.$router.push('/home')
          })
        } else {
          console.log('error submit')
          return false
        }
      })
    },
    register () {
      this.$router.push('/register')
    }
  }
}
</script>

<style scoped>
  .login_container {
    background-image: linear-gradient(-180deg, #1a1454 0%, #0e81a5 100%);
    background-repeat: no-repeat;
    background-size: cover;
    height: 100%;
  }

  .login_box {
    width: 290px;
    height: 350px;
    background-color: #2e527bb3;
    border-radius: 5px;
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
  }

  .title {
    width: 290px;
    height: 50px;
    background-color: #2e527bb3;
    border-radius: 5px;
    position: absolute;
    left: 50%;
    top: 30%;
    transform: translate(-50%, -50%);
  }

  .text {
    background-color: #2e527bb3;
    border-radius: 5px;
    position: absolute;
    left: 50%;
    top: 10%;
    color: aqua;
    transform: translate(-50%, -50%);
    font-size: x-large;
  }

  .el-form {
    padding: 32px;
    position: absolute;
    bottom: 0;
    width: 100%;
    box-sizing: border-box;
  }

  .el-button {
    width: 100%;
  }
</style>
