vagrant-spark-hadoop-cluster
================================

# Introduction

Vagrant project to spin up a cluster of 4 virtual machines with Hadoop v2.6 and Spark v1.6.0. 
Based on this [GutHub repo](https://github.com/vangj/vagrant-hadoop-2.4.1-spark-1.0.1).

1. node1 : HDFS NameNode + Spark Master
2. node2 : YARN ResourceManager + JobHistoryServer + ProxyServer
3. node3 : HDFS DataNode + YARN NodeManager + Spark Slave
4. node4 : HDFS DataNode + YARN NodeManager + Spark Slave

# Getting Started

1. [Download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. [Download and install Vagrant](http://www.vagrantup.com/downloads.html).
3. Run ```vagrant box add centos65 http://files.brianbirkinbine.com/vagrant-centos-65-i386-minimal.box```
4. Git clone this project, and change directory (cd) into this project (directory).
5. Download [hadoop-2.6.3.tar.gz](http://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-2.6.3/hadoop-2.6.3.tar.gz) into the /resources directory
6. Download [spark-1.6.0-bin-hadoop2.6.tgz](http://spark.apache.org/downloads.html) into the /resources directory
7. Download [jdk-8u65-linux-i586.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) into the /resources directory
8. Run ```vagrant up``` to create the VM.
9. Run ```vagrant status``` to check the status of your VM.
10. Use ```vagrant suspend``` to suspend your VM and free resources. Use ```vagrant up``` to start it again.
11. Run ```vagrant destroy``` when you want to destroy and get rid of the VM.


# Modifying scripts for new Spark/Hadoop versions and adapting to your needs

1. You could use a different vagrant box. Here is the [list of available Vagrant boxes](http://www.vagrantbox.es).

2. ./Vagrantfile
    * To add/remove slaves, change the number of nodes:   
    ```line 5: numNodes = 4```
    * To modify VM memory change the following line:   
    ```line 13: v.customize ["modifyvm", :id, "--memory", "2048"]```

3. /scripts/common.sh
    * To use a different version of Java, change the following line depending on the version you downloaded to /resources directory.   
    ```line 4: JAVA_ARCHIVE=jdk-8u25-linux-i586.tar.gz```
    * To use a different version of Hadoop you've already downloaded to /resources directory, change the following line:   
    ```line 8: HADOOP_VERSION=hadoop-2.6.3```
    * To use a different version of Hadoop to be downloaded, change the remote URL in the following line:   
    ```line 10: HADOOP_MIRROR_DOWNLOAD=http://apache.crihan.fr/dist/hadoop/common/stable/hadoop-2.6.3.tar.gz```
    * To use a different version of Spark, change the following lines:   
    ```line 13: SPARK_VERSION=spark-1.6.0```   
    ```line 14: SPARK_ARCHIVE=$SPARK_VERSION-bin-hadoop2.6.tgz```   
    ```line 15: SPARK_MIRROR_DOWNLOAD=../resources/spark-1.6.0-bin-hadoop2.6.tgz```   

4. /scripts/setup-java.sh
    * To install from Java downloaded locally in /resources directory, if different from default version (1.8.0_65), change the version in the following  line:   
    ```line 18: ln -s /usr/local/jdk1.8.0_65 /usr/local/java```
    * To modify version of Java to be installed from remote location on the web, change the version in the following line:   
    ```line 12: yum install java-1.8.0-openjdk -y```

5. /scripts/setup-centos-ssh.sh
    * To modify the version of sshpass to use, change the following lines within the function installSSHPass():    
    ```line 23: wget http://pkgs.repoforge.org/sshpass/sshpass-1.05-1.el6.rf.i686.rpm```    
    ```line 24: rpm -ivh sshpass-1.05-1.el6.rf.i686.rpm```   

6. /scripts/setup-spark.sh
    * To modify the version of Spark to be used, if different from default version (built for Hadoop2.6), change the version suffix in the following  line:   
    ```line 32: ln -s /usr/local/$SPARK_VERSION-bin-hadoop2.6 /usr/local/spark```


# Make the VMs setup faster
You can make the VM setup MUCH faster if you pre-download the Hadoop, Spark, and Oracle JDK into the /resources directory.

1. [/resources/hadoop-2.6.3.tar.gz](http://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-2.6.3/hadoop-2.6.3.tar.gz)
2. [/resources/spark-1.6.0-bin-hadoop2.6.tgz](http://spark.apache.org/downloads.html)
3. [/resources/jdk-8u65-linux-i586.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

The setup script will automatically detect if these files (with precisely the same names) exist and use them instead. If you are using slightly different versions, you will have to modify the script accordingly.

# Testing the configuration
Make sure you run these tests with root privileges: type in "su" and the password is "vagrant".

### Test YARN
Run the following command to make sure you can run a MapReduce job. 

```
yarn jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.3.jar pi 2 100
```

### Test Spark on YARN
You can test if Spark can run on YARN by issuing the following command. Try NOT to run this command on the slave nodes.

```
$SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --num-executors 3 \
    --executor-cores 2 \
    $SPARK_HOME/lib/spark-examples*.jar \
    100
```

### Test code directly on Spark	
```
$SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master spark://node1:7077 \
    --num-executors 3 \
    --executor-cores 2 \
    $SPARK_HOME/lib/spark-examples*.jar \
    100
```
	
### Test Spark using Shell

1. Start the Spark shell using the following command. Try NOT to run this command on the slave nodes.   
    * ```
    $SPARK_HOME/bin/spark-shell --master spark://node1:7077
    ```
2. Prepare small test file lorem.txt with the following content:   
    * ```
    Lorem Ipsum is simply dummy text of the printing and typesetting industry.    
    Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.     
    It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.     
    It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.    
    ```
3. Load the file in HDFS and check if it's there   
    * ```
    hadoop fs -put ./lorem.txt ./   
    hadoop fs -ls
    ```
4. Test Spark in the scala shell   
    * 
    ```val textFile = sc.textFile("lorem.txt")```      
    ```textFile.count() # Should get the result: res0: Long = 4```        
    ```textFile.first() # Should get the result: res1: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "```       

# Web UI
You can check the following URLs to monitor the Hadoop daemons.

1. [NameNode](http://10.211.55.101:50070/dfshealth.html)
2. [ResourceManager](http://10.211.55.102:8088/cluster)
3. [JobHistory](http://10.211.55.102:19888/jobhistory)
4. [Spark](http://10.211.55.101:8080)

# Vagrant boxes
A list of available Vagrant boxes is shown at http://www.vagrantbox.es. 

# References
The project is a fork of [Jee Vang's vagrant project](https://github.com/vangj/vagrant-hadoop-2.4.1-spark-1.0.1). 
A similar project which only sets up a cluster of 4 nodes without Spark/Hadoop is [this Binh Nguyen's project](https://github.com/ngbinh/spark-vagrant).
A basic tutorial for setting up Vagrant on a single VM can be found [here](http://thegrimmscientist.com/2014/12/01/vagrant-tutorial-spark-in-a-vm/).

