#!/usr/bin/env ruby
require 'yaml'
require File.dirname(__FILE__)+'/weibo'

class VboTest
  def initialize
    @save_file = '/tmp/vbo-test.yml'
    @vbo = Vbo::Weibo.new
    @vbo.set_app_config :app_key, :app_screct, :callback_url
    if File.exists?(@save_file)
      access_token = YAML.load_file(@save_file)
      time_now = Time.now.to_i
      if access_token['expires_when'].to_i < time_now
        access_token = get_token
      end
    else
      access_token = get_token
    end
    @vbo.set_access_token access_token
  end

  def get_token
    puts 'Goto this page, get the access code: ' + @vbo.get_authorize_url
    puts 'Please input the code you get:'
    access_code = gets.chomp
    @vbo.set_access_code access_code.to_s
    access_token = @vbo.get_access_token
    time_now = Time.now.to_i
    access_token['expires_when'] = time_now + access_token['expires_in'].to_i
    File.open @save_file, 'w' do |f|
      f.write access_token.to_yaml
    end
    access_token
  end

  def get_public_timeline
    @vbo.get__statuses__public_timeline
  end

end

v = VboTest.new
p v.get_public_timeline
