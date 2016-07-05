# == Class: ec2tagfacts
#
# EC2 tags are turned into puppet facts. AWS cli automatically installed.
#
# === Parameters
#
# [*manage_awscli*]
#   If true, external awscli module will be included
#
# [*aws_access_key_id*]
#   This is an aws_access_key_id with policy rights to read tags.
#
# [*aws_secret_access_key*]
#   This is the secret_access_key to the above key id.
#
# === Examples
#
#  class { 'ec2tagfacts':
#    aws_access_key_id => 'ASFJIJ3IGJ5JSKAJ',
#    aws_secret_access_key => 'svbasJAB254FHU6hsH5ujxfjdSs',
#  }
#
# === Authors
#
# Reuben Avery <ravery@bitswarm.io>
#
# === Copyright
#
# Copyrgiht 2016 Bitswarm Labs Inc, Portions Copyright 2015 Bryan Andrews
#
class ec2tagfacts (
  $manage_awscli          = $ec2tagfacts::params::manage_awscli,
  $aws_access_key_id      = undef,  # if undef we assume they are setup correctly already
  $aws_secret_access_key  = undef,
) inherits ec2tagfacts::params {
  include '::python'

  if str2bool($manage_awscli) {
    include '::awscli'
    if $aws_access_key_id or $aws_secret_access_key {
      awscli::profile { 'default':
        aws_access_key_id     => $aws_access_key_id,
        aws_secret_access_key => $aws_secret_access_key
      }
    }
  }
}
