# -*- tab-width: 4; ruby-indent-level: 4; indent-tabs-mode: t -*-
Puppet::Type.type(:mysql_database).provide :mysql, :parent => Puppet::Provider::Package do
	desc "Provide MySQL interactions via /usr/bin/mysql"

	# this is a bit of a hack.
	# Since puppet evaluates what provider to use at start time rather than run time
	# we can't specify that commands will exist. Instead we call manually.
	# I would make these call execute directly, but execpipe needs the path
	def self.mysqladmin
		'/usr/bin/mysqladmin'
	end
	def self.mysql
		'/usr/bin/mysql'
	end
	def mysqladmin
		self.class.mysqladmin
	end
	def mysql
		self.class.mysql
	end

	def execute_home(command, options = {})
		default_options = {
			:custom_environment => {}
		}
		options = default_options.merge(options)
		options[:custom_environment][:HOME] = '/root'
		execute(command, options)
	end

	# retrieve the current set of mysql users
	def self.instances
		dbs = []

		cmd = "HOME='/root' #{mysql} mysql -NBe 'show databases'"
		execpipe(cmd) do |process|
			process.each do |line|
				dbs << new( { :ensure => :present, :name => line.chomp } )
			end
		end
		return dbs
	end

	def query
		result = {
			:name => @resource[:name],
			:ensure => :absent
		}

		cmd = "HOME='/root' #{mysql} mysql -NBe 'show databases'"
		execpipe(cmd) do |process|
			process.each do |line|
				if line.chomp.eql?(@resource[:name])
					result[:ensure] = :present
				end
			end
		end
		result
	end

	def create
		execute_home [mysqladmin, "create", @resource[:name]]
	end
	def destroy
		execute_home [mysqladmin, "-f", "drop", @resource[:name]]
	end

	def exists?
		if execute_home([mysql, "mysql", "-NBe", "show databases"]).match(/^#{@resource[:name]}$/)
			true
		else
			false
		end
	end
end

