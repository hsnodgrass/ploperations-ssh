# @summary Platform independent way to specify an SSH authorized key
define ssh::authorized_key (
  String[1]                  $user    = $title,
  Enum[present, absent]      $ensure  = 'present',
  Optional[Ssh::Key::String] $key     = undef,
  Ssh::Key::Type             $type    = 'ssh-rsa',
  Array[Ssh::Key::Option]    $options = [],
) {
  include ssh::params

  $use_file = $ssh::params::server_class ? {
    'ssh::server::chocolatey' => true,
    'ssh::server::cygwin'     => true,
    default                   => false,
  }

  if $use_file {
    if $ensure == present and $key {
      if $options.length() > 0 {
        $options_string = $options.join(',')
        $prefix = "${options_string} "
      } else {
        $prefix = ''
      }

      $line = "${prefix}${type} ${key} ${title}"
      concat::fragment { "ssh::authorized_key::file ${title} ${line}":
        order   => '10', # then ordered by title
        target  => "ssh::authorized_key::file ${user}",
        content => ssh::fix_eol("${line}\n"),
      }
    }
  } else {
    # ssh_authorized_key works on this platform
    ssh_authorized_key { $title:
      ensure  => $ensure,
      key     => $key,
      type    => $type,
      user    => $user,
      options => $options,
    }
  }
}
