#
# Sandbox - Hosts file tool for remote & local development
#
# Copyright Justin Shreve 2011
#
# Based on https://github.com/markjaquith/Localdev Copyright Mark Jaquith 2011
# Adds additional options for pointing hosts entries to other IP address
# and setting a default IP address to sandbox to
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'digest/md5'



class Sandbox
  VERSION = '0.1.2'
  def initialize
    @debug = false
    @sandbox = '/etc/hosts-sandbox'
    @destination_storage = '/etc/hosts-sandbox-destination'
    @hosts = '/etc/hosts'
    @default_destination = '127.0.0.1'
    @start = '#==SANDBOX==#'
    @end = '#/==SANDBOX==#'
    if !ARGV.first.nil? && [:on, :off, :add, :remove, :destination].include?( ARGV.first.to_sym )
      require_sudo
      ensure_sandbox_exists
    end
    command = ARGV.shift
    command = command.to_sym unless command.nil?
    object = ARGV.shift
    ip = ARGV.shift
    case command
    when :"--v", :"--version"
      info
    when :on, :off, :status
      send command
    when :add
      require_sudo
      object.nil? && exit_error_message("'sandbox add' requires you to provide a domain. optionally you can provide an IP/destination.")
      ensure_sandbox_exists
      if ip.nil?
        ip = get_destination
      end
      send command, object, ip
    when :remove
      require_sudo
      object.nil? && exit_error_message("'sandbox remove' requires you to provide a domain.")
      ensure_sandbox_exists
      send command, object
    when :destination
      require_sudo
      object.nil? && exit_error_message("'sandbox setdefault' requires you to provide an IP/destination.")
      ensure_sandbox_exists
      send command, object
    when nil, '--help', '-h'
      exit_message "Usage: sandbox [on|off|status]\n       sandbox [destination] newdefault\n       sandbox [add|remove] domain destination"
    else
    exit_error_message "Invalid command"
    end
  end

  def require_sudo
    if ENV["USER"] != "root"
      exec("sudo #{ENV['_']} #{ARGV.join(' ')}")
    end
  end

  def info
    puts "Sandbox #{self.class::VERSION}"
  end

  def debug message
    puts message if @debug
  end

  def exit_message message
    puts message
    exit
  end

  def exit_error_message message
    exit_message '[ERROR] ' + message
  end

  def flush_dns
    %x{dscacheutil -flushcache}
  end

  def ensure_sandbox_exists
    File.open( @sandbox, 'w' ) {|file| file.write('') } unless File.exists?( @sandbox )
    File.open( @destination_storage, 'w' ) {|file| file.write('') } unless File.exists?( @destination_storage )
  end

  def enable
    disable
    entries = []
    File.open( @sandbox, 'r' ) do |file|
      entries = file.read.split("\n").uniq
    end
    File.open( @hosts, 'a' ) do |file|
      file.puts "\n"
      file.puts @start
      file.puts "# The md5 dummy entries are here so that things like MAMP Pro don't"
      file.puts "# discourtiously remove our entries"
      entries.each do |entry|
        pieces = entry.split( ' ' )
        domain = pieces[0]
        ip = pieces[1]
        file.puts "#{ip} #{Digest::MD5.hexdigest(domain)}.#{domain} #{domain}"
      end
      file.puts @end
    end
  end

  def on
    enable
    flush_dns
    puts "Turning sandbox on"
  end

  def disable
    hosts_content = []
    File.open( @hosts, 'r' ) do |file|
      started = false
      while line = file.gets
        started = true if line.include? @start
        hosts_content << line unless started
        started = false if line.include? @end
      end
    end
    while "\n" == hosts_content.last
      hosts_content.pop
    end
    File.open( @hosts, 'w' ) do |file|
      file.puts hosts_content
    end
  end

  def off
    disable
    flush_dns
    puts "Turning Sandbox off"
  end

  def update_sandbox
    entries = []
    File.open( @sandbox, 'r' ) do |file|
      entries = file.read.split( "\n" )
      debug entries.inspect
      yield entries
      debug entries.inspect
    end
    File.open( @sandbox, 'w' ) do |file|
      file.puts entries
    end
  end

  def destination ip
    File.open( @destination_storage, 'w' ) do |file|
      file.puts ip
    end
    puts "Sandbox default destination set to #{ip}"
  end

  def add (domain, ip)
    entry = ''
    update_sandbox { |entries|
      if entries.find { |entry| /^#{domain}/ =~ entry }
      entries = entries.delete entry
      end
    }
    update_sandbox { | entries | entries << "#{domain} #{ip}" }
    enable if :on == get_status
    puts "Added '#{domain} #{ip}'"
  end

  def remove domain
    entry = ''
    update_sandbox { |entries|
      if entries.find { |entry| /^#{domain}/ =~ entry }
      entries = entries.delete entry
      end
    }
    enable if :on == get_status
    puts "Removed '#{domain}'"
  end

  def get_destination
    current_destination = @default_destination
    File.open( @destination_storage, 'r' ) do |file|
      dest = file.read.strip
      current_destination = dest unless dest.empty? or dest.nil?
    end
    return current_destination
  end

  def get_status
    # do magic
    status = :off
    return status unless File.readable? @hosts
    File.open( @hosts, 'r' ) do |file|
      while line = file.gets
        if line.include? @start
          status = :on
        break
        end
      end
    end
    return status
  end

  def status
    puts "Sandbox is #{get_status}"
    puts "Current default sandbox destination is #{get_destination}"
  end

end
