#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'yaml'
require 'time'
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
    @uid = access_token['uid']
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

  def get_uid
    @uid
  end

  def get_public_timeline
    @vbo.get__statuses__public_timeline
  end

  def user_timeline(uid, screen_name=nil, count=30, page=1, base_app=0, feature=0)
    data = {'count'=>count, 'page'=>page, 'base_app'=>base_app, 'feature'=>feature}
    if uid.nil? && (not screen_name.nil?)
      odata = {'screen_name'=>screen_name}
    else
      odata = {'uid'=>uid}
    end
    data.merge! odata
    @vbo.get__statuses__user_timeline data
  end

  def home_timeline(count=30, page=1, base_app=0, feature=0)
    data = {'count'=>count, 'page'=>page, 'base_app'=>base_app, 'feature'=>feature}
    @vbo.get__statuses__home_timeline data
  end

end

#微博数据处理方法
def output_line(timeline)
  output = []
  raise 'get weibo data faild..' if timeline['statuses'].nil?
  timeline['statuses'].each do |t|
    text = t['user']['screen_name'] + '(' +t['user']['gender'] +'):' 
    text += t['text']
    if not t['retweeted_status'].nil?
      text += ' || '
      ru_name = '' 
      ru_gender = ''
      if not t['retweeted_status']['user'].nil? 
        ru_name = t['retweeted_status']['user']['screen_name']
        ru_gender = t['retweeted_status']['user']['gender']
      end
      text +=  ru_name + '(' + ru_gender +'):' 
      text +=  t['retweeted_status']['text'] || ''
    end
    text += Time.parse(t['created_at']).strftime(' 发布于%Y年%m月%d日 %k:%M %p')
    output.push text
  end
  output
end

v = VboTest.new
if ARGV.length > 0
  timeline = case ARGV[0]
             when 'user'
               if ARGV[1].nil?
                 v.user_timeline v.get_uid, nil, 10
               else
                 count = 10
                 count = ARGV[2] if not ARGV[2].nil?
                 arg = ARGV[1]
                 if arg.is_a? Numeric
                   v.user_timeline arg, nil, count
                 else
                   v.user_timeline nil, arg, count
                 end
               end
             when 'home'
               count = 10
               count = ARGV[1] if not ARGV[1].nil?
               v.home_timeline count
             end
else
  count = 10
  timeline = v.home_timeline count
end

ol = output_line timeline
ol.each do |l|
  puts l
  puts '- - - '
end

