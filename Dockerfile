# 基础镜像
FROM hollisho/centos:latest

# 维护者
MAINTAINER Hollis Ho "he_wenzhi@126.com"

# 安装wget下载工具
RUN yum install -y wget 

# 切换到usr/lcoal/src/目录，相当于cd，并可以用cd 代替， 但docker官方不建议用cd
WORKDIR /usr/local/src

# 添加远程文件到当前文件夹， 注意：后面有个点(.) 代表当前目录。ADD可以添加远程文件到镜像，但COPY仅可以添加本地文件到镜像中。
ADD https://openresty.org/download/openresty-1.15.8.2.tar.gz .

# RUN，在镜像内运行解压命令
RUN tar zxvf openresty-1.15.8.2.tar.gz

# 切换目录
WORKDIR /usr/local/src/openresty-1.15.8.2

# 更新yum，可不执行
#RUN yum -y update 

# 安装必要的软件和添加nginx用户
RUN yum install -y readline-devel pcre-devel openssl-devel gcc-c++ make autoconf automake perl postgresql-devel
RUN  useradd -M -s /sbin/nologin nginx

# 挂载卷，测试用例（这里的挂载卷，不可以指定本机的目录，不够灵活，一般会在 启动容器时通过 -v 参数指定挂载卷，或在docker-compose.yaml文件中指定，都可以指定本地目录）
VOLUME ["/data"]

# 编译安装nginx
RUN ./configure\
 --user=nginx\
 --group=nginx\
 --prefix=/usr/local/openresty\
 --with-luajit\
 --without-http_redis2_module\
 --with-http_iconv_module\
 --with-http_postgres_module &&\
 make && make install


# 切换到Nginx的配置目录
WORKDIR /usr/local/openresty/nginx/conf

# 建立子配置文件夹，个人爱好，可以不建，或者叫其它名称都可以，但最好不要带特殊符号,
RUN mkdir conf.d

COPY conf/conf.d ./conf.d
COPY conf/nginx.conf ./nginx.conf

# 设置变量，执行命令时，就可以省略前缀目录了 
ENV PATH /usr/local/openresty/nginx/sbin:$PATH


# 暴露端口
EXPOSE 80 443

# 执行命令，数组形式， "-g daemon off;" 使我们运行容器时，容器可以前台运行，不会退出
CMD ["nginx", "-g", "daemon off;"]

