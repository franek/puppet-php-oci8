class oci8 {
	file {
        "/tmp/oracle-instantclient11.2-basic-11.2.0.3.0-1.i386.rpm":
            source => "puppet:///modules/oci8/oracle-instantclient11.2-basic-11.2.0.3.0-1.i386.rpm";
		"/tmp/oracle-instantclient11.2-devel-11.2.0.3.0-1.i386.rpm":
            source => "puppet:///modules/oci8/oracle-instantclient11.2-devel-11.2.0.3.0-1.i386.rpm";
		"/tmp/anwser-install-oci8.txt":
            source => "puppet:///modules/oci8/answer-pecl-oci8.txt";
    }

   package {
    "oracle-instantclient-basic" :
        provider => "rpm",
        name => "oracle-instantclient11.2-basic-11.2.0.3.0-1.i386.rpm",
        source => "/tmp/oracle-instantclient11.2-basic-11.2.0.3.0-1.i386.rpm",
        ensure => installed,
        install_options => "--force",
        require => File["/tmp/oracle-instantclient11.2-basic-11.2.0.3.0-1.i386.rpm"];
    "oracle-instantclient-devel" :
        provider => "rpm",
        name => "oracle-instantclient11.2-devel-11.2.0.3.0-1.i386.rpm",
        source => "/tmp/oracle-instantclient11.2-devel-11.2.0.3.0-1.i386.rpm",
        ensure => installed,
        install_options => "--force",
        require => [ File["/tmp/oracle-instantclient11.2-basic-11.2.0.3.0-1.i386.rpm"], Package["oracle-instantclient-basic"]];
	"php-devel":
		ensure => "installed",
		require => Class["php"];
   }

  exec {
	  "pecl-install-oci8":
		command => "pecl install oci8 </tmp/anwser-install-oci8.txt",
        user => root,
		timeout => 0,
        tries   => 5,
		unless => "/usr/bin/php -m | grep -c oci8",
        require => [ Package["oracle-instantclient-basic"], Package["oracle-instantclient-devel"], Package["php-devel"], File["/tmp/anwser-install-oci8.txt"]],
	}

  line { "add-oci8-php" :
    file => "/etc/php.ini",
    line => "extension=oci8.so",
    require => Exec["pecl-install-oci8"];
	}

  line { "env-oracle" :
    file => "/etc/environment",
	line => "\nexport ORACLE_HOME=/usr/lib/oracle/11.2/client/lib\nexport NLS_DATE_FORMAT=\"DD/MM/YYYY HH24:MI\"",
	notify => Service['apache'],
    require => Line["add-oci8-php"];
  }
}
