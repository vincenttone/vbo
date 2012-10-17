# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/lib_test.rb'

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
