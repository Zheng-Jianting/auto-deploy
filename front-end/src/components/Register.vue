<template>
  <div class="login_container">
    <div class="login_box">
      <!-- 登录表单区域 -->
      <el-form :model="ruleForm" :rules="rules" ref="ruleFormRef" class="demo-ruleForm">
        <el-form-item prop="username">
          <el-input placeholder="username" prefix-icon="el-icon-user" v-model.number="ruleForm.username"></el-input>
        </el-form-item>
        <el-form-item prop="email">
          <el-input placeholder="email" prefix-icon="el-icon-message" v-model="ruleForm.email"></el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input placeholder="password" prefix-icon="el-icon-key" type="password" v-model="ruleForm.password" autocomplete="off"></el-input>
        </el-form-item>
        <el-form-item prop="checkPass">
          <el-input placeholder="check password" prefix-icon="el-icon-key" type="password" v-model="ruleForm.checkPass" autocomplete="off"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="register" @click="submitForm">注册</el-button>
        </el-form-item>
        <el-form-item>
          <el-button type="text" class="function-button" @click="resetForm">重置</el-button>
          <el-button type="text" class="function-button" @click="login">返回</el-button>
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
    const checkUsername = (rule, value, callback) => {
      if (!value) {
        return callback(new Error('用户名不能为空'))
      }
      callback()
    }
    const checkEmail = (rule, value, callback) => {
      if (!value) {
        return callback(new Error('邮箱不能为空'))
      }
      callback()
    }
    const validatePass = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请输入密码'))
      } else {
        if (this.ruleForm.checkPass !== '') {
          this.$refs.ruleFormRef.validateField('checkPass')
        }
        callback()
      }
    }
    const validatePass2 = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请再次输入密码'))
      } else if (value !== this.ruleForm.password) {
        callback(new Error('两次输入密码不一致!'))
      } else {
        callback()
      }
    }
    return {
      ruleForm: {
        username: '',
        email: '',
        password: '',
        checkPass: '',
        status: '0'
      },
      rules: {
        username: [
          { validator: checkUsername, trigger: 'blur' },
          { min: 3, max: 8, message: '长度在 3 到 8个字符', trigger: 'blur' }
        ],
        email: [
          { validator: checkEmail, trigger: 'blur' }
        ],
        password: [
          { validator: validatePass, trigger: 'blur' },
          { min: 6, message: '长度至少为6个字符', trigger: 'blur' }
        ],
        checkPass: [
          { validator: validatePass2, trigger: 'blur' },
          { min: 6, message: '长度至少为6个字符', trigger: 'blur' }
        ]
      }
    }
  },
  methods: {
    submitForm () {
      this.$refs.ruleFormRef.validate((valid) => {
        if (valid) {
          this.$http.post('/register', this.ruleForm).then(res => {
            this.$router.push('/login')
          })
        } else {
          console.log('error submit!')
          return false
        }
      })
    },
    resetForm () {
      this.$refs.ruleFormRef.resetFields()
    },
    login () {
      this.$router.push('/login')
    }

  }
}
</script>

<style scoped>
  .login_container {
    background-image: linear-gradient(-180deg, #1a1454 0%, #0e81a5 100%);
    /*background-image: url("../images/bg_login.png");*/
    background-repeat: no-repeat;
    background-size: cover;
    height: 100%;
  }
  .login_box {
    width: 400px;
    height: 500px;
    /* background-color: #fff; */
    background-color: #2e527bb3;
    border-radius: 5px;

    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
  }
  .el-form {
    padding: 32px;
    position: absolute;
    bottom: 0;
    width: 100%;
    box-sizing: border-box;
  }

  .register{
    width: 100%;
  }

  .function-button{
    width: 45%;
  }
</style>
