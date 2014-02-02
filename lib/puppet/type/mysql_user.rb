# -*- tab-width: 4; ruby-indent-level: 4; indent-tabs-mode: t -*-
# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_user) do
  @doc = "Manage a database user."
  ensurable
  newparam(:name) do
    desc "The name of the user. This uses the 'username@hostname' form."
  end

  newproperty(:password_hash) do
    desc "The password hash of the user. Use mysql_password() for creating such a hash."
  end

	autorequire(:service) do
		["mysql"]
	end
	autorequire(:exec) do
		["Initialize MySQL server root password"]
	end
	autorequire(:file) do
		["/root/.my.cnf"]
	end
end

