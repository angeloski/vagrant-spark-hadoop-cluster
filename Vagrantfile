Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

HOST_SYNCED_FOLDER = "~/DH/dhbd_spark_scripts/"
NODE1_SYNCED_FOLDER = "/code/dhbd_spark_scripts/"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	numNodes = 4
	r = numNodes..1
	(r.first).downto(r.last).each do |i|
		config.vm.define "node#{i}" do |node|
			node.vm.box = "centos65"
			node.vm.box_url = "http://files.brianbirkinbine.com/vagrant-centos-65-i386-minimal.box"
			node.vm.provider "virtualbox" do |v|
			  v.name = "node#{i}"
			  v.customize ["modifyvm", :id, "--memory", "2048"]
			end
			if i < 10
				node.vm.network :private_network, ip: "10.211.55.10#{i}"
			else
				node.vm.network :private_network, ip: "10.211.55.1#{i}"
			end
			node.vm.hostname = "node#{i}"
			node.vm.provision "shell", path: "scripts/setup-centos.sh"
			node.vm.provision "shell" do |s|
				s.path = "scripts/setup-centos-hosts.sh"
				s.args = "-t #{numNodes}"
			end
			if i == 2
				node.vm.provision "shell" do |s|
					s.path = "scripts/setup-centos-ssh.sh"
					s.args = "-s 3 -t #{numNodes}"
				end
			end
			if i == 1
				node.vm.provision "shell" do |s|
					s.path = "scripts/setup-centos-ssh.sh"
					s.args = "-s 2 -t #{numNodes}"
				end
			end
			node.vm.provision "shell", path: "scripts/setup-java.sh"
			node.vm.provision "shell", path: "scripts/setup-hadoop.sh"
			node.vm.provision "shell" do |s|
				s.path = "scripts/setup-hadoop-slaves.sh"
				s.args = "-s 3 -t #{numNodes}"
			end
			node.vm.provision "shell", path: "scripts/setup-spark.sh"
			node.vm.provision "shell" do |s|
				s.path = "scripts/setup-spark-slaves.sh"
				s.args = "-s 3 -t #{numNodes}"
			end

			# Copy the .boto file (AWS credentials)
			node.vm.provision "shell", inline: "cp /vagrant/.boto /home/vagrant/"
			node.vm.provision "shell", inline: "cp /vagrant/.boto /root/"

			# Initialize the Hadoop cluster, start Hadoop daemons
			if i == 1
				node.vm.provision "shell", 
					inline: "$HADOOP_PREFIX/bin/hdfs namenode -format myhadoop", 
					privileged: true
				node.vm.provision "shell", 
					inline: "$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode",
					privileged: true
				node.vm.provision "shell", 
					inline: "$HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode",
					privileged: true
				# Start Spark in Standalone Mode
				node.vm.provision "shell", 
					inline: "$SPARK_HOME/sbin/start-all.sh",
					privileged: true
				# Create a synced folder with the host machine
				node.vm.synced_folder HOST_SYNCED_FOLDER, NODE1_SYNCED_FOLDER,
					create: true
			end
			# Start YARN
			if i == 2
				node.vm.provision "shell",
					inline: "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager",
					privileged: true
				node.vm.provision "shell", 
					inline: "$HADOOP_YARN_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager", 
					privileged: true
				node.vm.provision "shell", 
					inline: "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh start proxyserver --config $HADOOP_CONF_DIR", 
					privileged: true
				node.vm.provision "shell", 
					inline: "$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver --config $HADOOP_CONF_DIR", 
					privileged: true
			end
		end
	end
end