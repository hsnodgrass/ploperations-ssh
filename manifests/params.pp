# Class: ssh::params
#
# Sets varables for the SSH class
#
class ssh::params (
  Boolean $cygwin = lookup('cygwin::enable', Boolean, undef, false),
) {
  case $facts['os']['name'] {
    'CentOS', 'RedHat', 'Fedora': {
      $server_class      = 'ssh::server::linux'
      $client_package    = 'openssh-clients'
      $server_package    = 'openssh-server'
      $package_provider  = undef # Use default
      $ssh_service       = 'sshd'
      $has_restart       = true
      $config_dir        = '/etc/ssh'
      $config_owner      = 'root'
      $config_group      = '0'
      $config_mode       = '0644'
      $config_dir_mode   = '0755'
      $root_access_group = 'root'
      $manage_config_dir = true
      $syslog_facility   = 'AUTHPRIV'
      $sftp_subsystem    = 'internal-sftp'
      $authorized_keys   = '.ssh/authorized_keys'
      $strict_modes      = true
      $print_motd        = true
      $permit_root_login = false
      $dos_line_endings  = false
    }
    'SLES': {
      $server_class      = 'ssh::server::linux'
      $client_package    = 'openssh'
      $server_package    = 'openssh'
      $package_provider  = undef # Use default
      $ssh_service       = 'sshd'
      $has_restart       = true
      $config_dir        = '/etc/ssh'
      $config_owner      = 'root'
      $config_group      = '0'
      $config_mode       = '0644'
      $config_dir_mode   = '0755'
      $root_access_group = 'root'
      $manage_config_dir = true
      $syslog_facility   = 'AUTHPRIV'
      $sftp_subsystem    = 'internal-sftp'
      $authorized_keys   = '.ssh/authorized_keys'
      $strict_modes      = true
      $print_motd        = true
      $permit_root_login = false
      $dos_line_endings  = false
    }
    'CumulusLinux', 'Debian', 'Ubuntu': {
      $server_class      = 'ssh::server::linux'
      $client_package    = 'openssh-client'
      $server_package    = 'openssh-server'
      $package_provider  = undef # Use default
      $ssh_service       = 'ssh'
      $has_restart       = true
      $config_dir        = '/etc/ssh'
      $config_owner      = 'root'
      $config_group      = '0'
      $config_mode       = '0644'
      $config_dir_mode   = '0755'
      $root_access_group = 'root'
      $manage_config_dir = true
      $syslog_facility   = 'AUTHPRIV'
      $sftp_subsystem    = 'internal-sftp'
      $authorized_keys   = '.ssh/authorized_keys'
      $strict_modes      = true
      $print_motd        = false
      $permit_root_login = false
      $dos_line_endings  = false
    }
    'Darwin': {
      $server_class      = undef
      $client_package    = undef
      $server_package    = undef
      $package_provider  = undef # Use default
      $ssh_service       = 'com.openssh.sshd'
      $has_restart       = false
      $config_dir        = '/etc/ssh'
      $config_owner      = 'root'
      $config_group      = '0'
      $config_mode       = '0644'
      $config_dir_mode   = '0755'
      $root_access_group = 'wheel'
      $manage_config_dir = true
      $syslog_facility   = 'AUTHPRIV'
      $sftp_subsystem    = 'internal-sftp'
      $authorized_keys   = '.ssh/authorized_keys'
      $strict_modes      = true
      $print_motd        = true
      $permit_root_login = false
      $dos_line_endings  = false
    }
    'FreeBSD': {
      $server_class      = undef
      $package_provider  = undef # Use default
      $client_package    = 'openssh-portable'
      $server_package    = 'openssh-portable'
      $ssh_service       = 'sshd'
      $has_restart       = true
      $config_dir        = '/etc/ssh'
      $config_owner      = 'root'
      $config_group      = '0'
      $config_mode       = '0644'
      $config_dir_mode   = '0755'
      $root_access_group = 'wheel'
      $manage_config_dir = true
      $syslog_facility   = 'AUTHPRIV'
      $sftp_subsystem    = 'internal-sftp'
      $authorized_keys   = '.ssh/authorized_keys'
      $strict_modes      = true
      $print_motd        = true
      $permit_root_login = false
      $dos_line_endings  = false
    }
    'Solaris','SunOS': {
      case $facts['os']['release']['major'] {
        '10': {
          $client_package = 'openssh'
          $server_package = 'openssh'
          $ssh_service    = 'svc:/network/cswopenssh:default'
        }
        '11': {
          $client_package = 'network/ssh'
          $server_package = 'network/ssh'
          $ssh_service    = 'network/ssh'
        }
        default: {
          fail("module ssh does not support Solaris ${facts['kernelrelease']}")
        }
      }

      $server_class      = 'ssh::server::solaris'
      $package_provider  = undef # Use default
      $has_restart       = true
      $config_dir        = '/etc/ssh'
      $config_owner      = 'root'
      $config_group      = '0'
      $config_mode       = '0644'
      $config_dir_mode   = '0755'
      $root_access_group = 'root'
      $manage_config_dir = true
      $syslog_facility   = 'AUTH'
      $sftp_subsystem    = 'internal-sftp'
      $authorized_keys   = '.ssh/authorized_keys'
      $strict_modes      = true
      $print_motd        = false
      $permit_root_login = false
      $dos_line_endings  = false
    }
    'windows': {
      # This fact doesn't exist during testing, and occasionally it doesn't have
      # PROGRAMDATA (WTF).
      $_windows_env = pick($facts['windows_env'], {})
      $_programdata = pick($_windows_env['PROGRAMDATA'], 'C:\ProgramData')
      $_windir = pick($_windows_env['WINDIR'], 'C:\Windows')

      if $cygwin {
        # Use Cygwin openssh
        $server_class      = 'ssh::server::cygwin'
        $package_provider  = 'cygwin'
        $config_dir        = cygwin::windows_path('/etc')
        $manage_config_dir = false
        $sftp_subsystem    = '/usr/bin/sftp-server'
        $authorized_keys   = '.ssh/authorized_keys'
        $strict_modes      = false # I couldn't figure these out
        $dos_line_endings  = false
      } else {
        # Use native openssh
        $server_class        = 'ssh::server::chocolatey'
        $package_provider    = 'chocolatey'
        $config_dir          = "${_programdata}\\ssh"
        $manage_config_dir   = true
        $sftp_subsystem      = 'sftp-server.exe'
        $authorized_keys     = "${config_dir}\\user_authorized_keys\\%u"
        $strict_modes        = true
        $dos_line_endings    = true

        # Settings special to this platform
        $default_shell       = "${_windir}\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
        $authorized_keys_dir = "${config_dir}\\user_authorized_keys"
      }

      $client_package    = 'openssh'
      $server_package    = $client_package
      $ssh_service       = 'sshd'
      $has_restart       = false
      $config_owner      = 'Administrators'
      $config_group      = 'NT AUTHORITY\SYSTEM'
      $config_mode       = undef # Use ACLs
      $config_dir_mode   = undef
      $root_access_group = 'Administrators'
      $syslog_facility   = 'AUTH'
      $print_motd        = true
      $permit_root_login = true
    }
    default: {
      fail("module ssh does not support OS ${facts['os']['name']}")
    }
  }

  $sshd_config = "${config_dir}/sshd_config"
  $ssh_config  = "${config_dir}/ssh_config"
  $known_hosts = "${config_dir}/ssh_known_hosts"
}
