### 采集工具自动部署系统



#### 1. 系统简介

##### 	本系统旨在简化使用 log_agent.jar 和 log_server.jar 等日志采集工具采集应用运行时日志的流程

##### 	采集一个测试用例的流程有以下步骤：

##### 	(1) 部署应用，确保应用能够正常运行

##### 	(2) 修改配置文件

##### 		  在 agent-config.xml 配置文件中的 \<include>\</include> 标签中添加需要插装的包名

```xml
<?xml version="1.0" encoding="ISO-8859-1" ?>
<config>
	<!-- Target server to steam log events to -->
	<logserver>
		<host>localhost</host>
		<port>9123</port>
        <type>tcp</type>
	</logserver>

	<!-- Application node identification -->
	<nodeid>
		<application>Log4j</application>
		<tier>Log4j</tier>
		<node>Node</node>
	</nodeid>

	<!-- Code transformation rules configuration -->
	<transformation-rules>
		<!-- Add logging to custom pointcuts -->
		<method-pointcut>
			<enabled>true</enabled>
			<include>org.apache.log4j.config.*</include>
			<include>org.apache.log4j.helpers.*</include>
			<include>org.apache.log4j.jdbc.*</include>
			<include>org.apache.log4j.jmx.*</include>
			<include>org.apache.log4j.net.*</include>
			<trace-constructor>true</trace-constructor>
			<trace-params>true</trace-params>
		</method-pointcut>

		<thread-call-pointcut>
			<enabled>true</enabled>
			<include>org.apache.log4j.config.*</include>
			<include>org.apache.log4j.helpers.*</include>
			<include>org.apache.log4j.jdbc.*</include>
			<include>org.apache.log4j.jmx.*</include>
			<include>org.apache.log4j.net.*</include>
			<call-pattern>java.lang.Thread.start()</call-pattern>
			<trace-catch>false</trace-catch>
		</thread-call-pointcut> 

		<!-- Add logging to Socket connect and close -->
		<socket>
			<enabled>true</enabled>
		</socket>

		<!-- Add logging to SocketChannel connect -->
		<socket-channel>
			<enabled>false</enabled> <!-- Not properly investigated -->
		</socket-channel>

		<!-- Add logging to javax Servlet joinpoints -->
		<servlet>
			<enabled>true</enabled>
			<includes>
				<include>javax.servlet.*</include>
			</includes>
		</servlet>
	</transformation-rules>
</config>
```



##### 		  在 config.xml 配置文件中的 \<file>\</file> 标签中修改采集日志文件名

```xml
<?xml version="1.0" encoding="ISO-8859-1" ?>
<config>
	<server>
		<port>9123</port>
		<type>tcp</type>
	</server>
	<output>
	    <logfile>
	        <enabled>true</enabled>
			<file>log.txt</file>
	    </logfile>
	</output>
	<internal>
		<capacity>
			<comm-buffer>100</comm-buffer>
			<case-track>100</case-track>
			<trace-events>10024</trace-events>
		</capacity>
	</internal>
</config>
```

##### 	(3) 启动 log_server.jar

```java
java -jar log_server.jar
```

##### 	(4) 运行测试用例

```java
java -javaagent:./log_agent.jar=./agent-config.xml useCase
```

##### 	(5) 杀死 log_server.jar 进程，得到采集日志



#### 2. 项目管理模块

##### 用户新建一个项目仅需提供项目名和描述信息，项目之间相互独立，每个项目都有与之对应的服务器管理模块、应用部署模块、日志采集模块



#### 3. 服务器管理模块

##### 	在该模块中，有以下功能：

##### 	(1) 添加服务器

##### 	记录服务器的以下信息：IP、端口、用户名、密码、采集工具、连通状态、创建时间

##### 	(2) 测试连通状态

##### 	(3) 上传采集工具 log_agent，log_server

##### 	(4) 删除服务器



#### 4. 应用部署模块

##### 	在该模块中，用户操作如下：

##### 	(1) 首先选择需要上传的应用 ( .zip 格式，其它格式类似，正在实现 )

##### 	(2) 然后从该项目的服务器列表中选择部署节点

##### 	(3) 填写部署目录

##### 	(4) 编写部署脚本 (可选)



##### 	自动部署系统在这个过程中完成的工作：

##### 	(1) 将用户上传的应用上传至部署节点的部署目录上，并解压

##### 	(2) 解压用户上传的应用，并递归遍历生成该应用可以插装的包名文件，从而在日志采集模块中，用户可以通过勾选需要插装的包名自动生成 agent-config.xml 配置文件

##### 	(3) 将部署脚本上传至部署节点，并执行



#### 5. 日志采集模块

##### 	在该模块中，用户操作如下：

##### 	(1) 填写采集任务名称

##### 	(2) 选择需要采集的应用 ( 通过应用名_部署节点唯一标识 )

##### 	(3) 勾选需要插装的包名 ( 默认全部勾选 )

##### (4) 填写采集日志文件名 ( 默认为 采集任务名称.txt )

##### 	(5) 填写采集的测试用例类名

##### (6) 点击采集按钮，启动采集

##### (7) 下载日志



##### 	自动部署系统在这个过程中完成的工作：

##### (1) 依据用户勾选的需要插装的包名以及日志文件名，自动生成 agent-config.xml 和 config.xml 配置文件，且用户可以预览

##### (2) 上传 agent-config.xml 和 config.xml 至部署节点

##### (3) 执行 start_server.sh 脚本，启动 log_server

```shell
#!/bin/bash
screen_name=$"collect-task"
screen -dmS $screen_name
cmd=$"cd /home/$1/autodeploy/tool/; setsid java -jar log_server-0.0.4-SNAPSHOT.jar >nohup.txt 2>&1 &";
screen -x -S $screen_name -p 0 -X stuff "$cmd"
screen -x -S $screen_name -p 0 -X stuff $'\n'
```

##### (4) 运行测试用例

```shell
java -javaagent:/home/root/autodeploy/tool/log_agent.jar
			   =/home/root/autodeploy/config/useCase/agent-config.xml useCase
```

##### (5) 执行 stop_server.sh 脚本，杀死 log_server 进程

```shell
#!/bin/bash
screen_name=$"collect-task"
screen -X -S $screen_name quit
```

##### (6) 保存日志，以供用户下载



#### 6. 部署节点目录结构

```
采集工具存储目录：
/home/server.username/autodeploy/tool/
```

```
应用存储目录：用户可在应用部署时自定义目录
推荐存储目录：
/home/server.username/autodeploy/application/
```

```
配置文件 ( agent-config.xml config.xml ) 存放目录：
/home/server.username/autodeploy/config/collect.name/
```

```
启动和杀死 log_server 的脚本 ( start_server.sh stop_server.sh ) 存放目录：
/home/server.username/autodeploy/shell/
```

```
部署脚本存放目录：
/home/server.username/autodeploy/script/deploy.application_name/
```

