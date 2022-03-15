## Java 程序自动化部署和运行日志采集系统

### 背景

日志采集工具基于插桩技术，能动态地采集使用 Java 语言开发的软件系统的运行时日志。日志采集工具由 agent 和 server 两部分组成，分别对应于 agent-config.xml 和 config.xml 两个配置文件

在使用日志采集工具采集一个软件系统的运行日志时，首先需要部署该软件系统，然后人为修改 agent-config.xml 和 config.xml 两个配置文件，随后启动 server，设置 java agent 参数并运行测试用例，关闭 server 后获得该测试用例的运行时日志

一方面，日志采集工具的使用流程比较繁琐；另一方面，当采集的项目数量较多时，运行时日志是使用哪个配置文件采集的并不明确。因此，本系统希望能构建一个集项目管理、服务器管理、应用部署、日志采集于一体的日志采集工具自动部署系统。使用户无需了解日志采集工具的具体使用流程，便能简便地采集软件系统的运行时日志

### 采集工具使用流程

在开发本系统之前，采集一个测试用例的运行时日志有以下步骤：

1. 部署应用程序，确保测试用例能够正常运行

2. 修改配置文件

   在 agent-config.xml 配置文件中的 \<include>\</include> 标签中添加需要插桩的包名

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

   在 config.xml 配置文件中的 \<file>\</file> 标签中修改采集日志文件名

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

3. 启动 log_server.jar

   ```shell
   java -jar log_server.jar
   ```

4. 运行测试用例

   ```shell
   java -javaagent:./log_agent.jar=./agent-config.xml useCase
   ```

5. 杀死 log_server.jar 进程，得到采集日志

### 系统整体处理流程

本系统主要提供日志采集工具自动部署服务，简化日志采集流程，除此之外，本系统还提供服务器管理以及应用部署服务，这是正式启动日志采集的前置工作。于是从系统处理日志采集任务来看，要将本系统应用在实际的软件开发生产线上，主要由三个有序的处理流程，分别是服务器的管理流程、应用部署流程、日志采集流程

**服务器管理流程**

- 项目增添：在系统中进行项目增添，记录项目的基本信息
- 服务器增添：在系统中增添服务器信息，包括IP地址、端口、用户名、密码。系统根据以上信息可以测试服务器的连通状态，若服务器能够正常连通，系统将暂存的采集工具上传至该服务器

**应用部署流程**

- 包名解析：在系统中选择应用并上传。系统将暂存并解压应用，通过递归遍历项目的目录结构并结合正则表达式生成包名解析结构文件，其中记录了该应用能够插桩的包名
- 上传应用：在系统中提供部署节点、部署目录信息。系统将据此将暂存的应用上传至所选部署节点的部署目录上
- 执行部署脚本：在系统中选择部署脚本并编辑。系统将上传脚本至所选部署节点，并执行

**日志采集的流程**

- 采集任务增添：在系统中增添采集任务，需要提供采集任务名称、在该项目的应用列表中选择采集应用及其部署节点、勾选插桩包名、提供日志文件名称以及需要采集的测试用例类名
- 自动生成配置文件：系统将根据增添采集任务时的信息自动生成 agent 的配置文件 agent-config.xml，以及 server 的配置文件 config.xml
- 执行日志采集流程：将 start_server.sh 脚本上传至部署节点并执行，启动采集工具 server 端，搜索测试用例编译后的 .class 文件路径，并执行，最后将 stop_server.sh 脚本上传至部署节点并执行，关闭采集工具 server 端，保存生成的运行时日志

### 部署节点目录结构

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

