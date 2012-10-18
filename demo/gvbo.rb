#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'gtk2'
require 'uri'
require 'cgi'
require File.dirname(__FILE__) + '/lib.rb'

class GVbo
  def initialize
    @v = VboTest.new './token.yml'
    @page = 1

    Gtk.init
    @window = Gtk::Window.new Gtk::Window::TOPLEVEL
    @window.set_title "某个弱爆了的客户端"
    @window.set_size_request 500, 500

    @window.signal_connect 'delete_event' do
      Gtk::main_quit
    end
    
    if check_auth
      show_main_frame
    end

    @window.show_all

  end

  def check_auth
    check_result = false
    if not @v.set_access_token
      auth_fix = Gtk::Fixed.new

      auth_box = Gtk::VBox.new true, 0
      auth_label_alert = Gtk::Label.new
      auth_label_alert.width_chars = 40
      auth_label_alert.markup = '<span weight="bold" font_desc="13">请访问以下地址获取您的授权码</span>'

      auth_url = Gtk::LinkButton.new  @v.get_auth_url, "点击我获取授权码"

      auth_label_tips = Gtk::Label.new 
      auth_label_tips.markup = '<span font_desc="13">填入下面的输入框中</span>'
      auth_input = Gtk::Entry.new
      auth_button = Gtk::Button.new "验证"

      auth_box.pack_start auth_label_alert, false
      auth_box.pack_start auth_url, false
      auth_box.pack_start auth_label_tips, false

      auth_box.pack_start auth_input, false
      auth_box.pack_start auth_button, false

      auth_fix.put auth_box, 100, 100
      @window.add auth_fix
      auth_button.signal_connect 'clicked' do
        token = auth_input.text
        if token == ''
          auth_input.text = '请输入授权码'
        else
          @v.get_access_token token
          if @v.set_access_token
            @window.remove auth_fix
            check_result = true
            show_main_frame
          end
        end
      end
    else
      check_result = true
    end
    check_result
  end

  def show_main_frame
    draw_frame
    load_home_timeline
    #load_user_timeline :vincenttone

    @weibo_send_button.signal_connect 'clicked' do
      @weibo_send_button.label = '发送中...'
      input_text = @weibo_input_field.buffer.text
      if @v.statuses_update input_text
        @weibo_send_button.label = '发布'
        refresh_line
        @weibo_input_field.buffer.text = ''
      end
    end
  end

  def refresh_line(type="home", user=nil)
    @page = 1
    @refresh_button.label = '加载中...'

    @vcbox.remove @vbox
    @vbox = Gtk::VBox.new false, 2
    @vcbox.pack_start @vbox, false
    @vbox.show
        
    @scrolled_window.vadjustment.value = @scrolled_window.vadjustment.lower
    case type.to_s
    when "home"
      load_home_timeline
    when "user"
      losd_user_timeline user
    end
    @refresh_button.label = '刷新'
  end

  def draw_frame
    @main_box = Gtk::VBox.new false, 0
    @window.add @main_box

    #发微博区
    @send_frame = Gtk::Frame.new "发个微博吧～"
    @main_box.pack_start @send_frame, false

    @send_box = Gtk::HBox.new false, 0
    @send_frame.add @send_box

    #发微博区的设施
    @weibo_input_field = Gtk::TextView.new
    @weibo_input_field.set_size_request 350, 50
    @weibo_input_fixed = Gtk::Fixed.new
    @weibo_input_fixed.put @weibo_input_field, 10, 0
    @weibo_input_box = Gtk::VBox.new
    @weibo_input_box.pack_start @weibo_input_fixed, false

    @weibo_send_button = Gtk::Button.new "发布"
    @weibo_send_button.set_size_request 80, 50
    @weibo_send_fixed = Gtk::Fixed.new
    @weibo_send_fixed.put @weibo_send_button, 30, 0
    @weibo_send_box = Gtk::VBox.new
    @weibo_send_box.pack_start @weibo_send_fixed, false
    @weibo_send_box.set_size_request 50, 50
    

    @send_box.pack_start @weibo_input_box, false
    @send_box.pack_start @weibo_send_box, false

    #看微博区
    @show_weibo_frame = Gtk::Frame.new '最新微博'
    @main_box.pack_start @show_weibo_frame, false

    @show_box = Gtk::VBox.new false, 2

    #小工具区
    @tools_box = Gtk::HBox.new false,10
    @refresh_button = Gtk::Button.new '刷新'
    @tools_box.pack_start @refresh_button

    @scrolled_window = Gtk::ScrolledWindow.new nil, nil
    @scrolled_window.set_policy Gtk::POLICY_NEVER, Gtk::POLICY_AUTOMATIC

    @view_frame = Gtk::Frame.new
    @view_frame.add @scrolled_window
    @view_box = Gtk::VBox.new false, 2
    @view_box.pack_start @view_frame, false

    @vcbox = Gtk::VBox.new false, 2
    @vbox = Gtk::VBox.new false, 2
    @scrolled_window.add_with_viewport @vcbox
    @vcbox.pack_start @vbox, false

    @show_box.pack_start @tools_box, false
    @show_box.pack_start @view_box, false

    @show_weibo_frame.add @show_box
    @view_frame.set_size_request 500, 350

    @main_box.show_all
  end

  def load_home_timeline
    timeline = @v.home_timeline 30, @page
    display timeline
    #加载按钮
    @load_new_button = Gtk::Button.new '继续浏览'
    @vbox.pack_start @load_new_button, false
    @load_new_button.show
    @load_new_button.signal_connect 'clicked' do |w, e|
      @vbox.remove @load_new_button
      @page += 1
      load_home_timeline
    end
    @refresh_button.signal_connect 'clicked' do
      refresh_line
    end
  end

  def load_user_timeline(user)
    if user.is_a? Numeric
      timeline = @v.user_timeline user, nil, 30, @page
    else
      timeline = @v.user_timeline nil, user, 30, @page
    end
    display timeline
    #加载按钮
    @load_new_button = Gtk::Button.new '继续浏览'
    @vbox.pack_start @load_new_button, false
    @load_new_button.show
    load_new_button.signal_connect 'clicked' do |w, e|
      @vbox.remove @load_new_button
      @page += 1
      load_user_timeline user
    end

    @refresh_button.signal_connect 'clicked' do
      refresh_line :user
    end

  end

  def display(timeline)
    #填充内容
    data = timeline_unpack timeline

    data.each do |t|
      label = Gtk::Label.new ''
      label.set_alignment 0, 0
      label.wrap=true
      label.selectable = true
      label.width_chars = 70
      
      weibo_detail_url = 'http://api.t.sina.com.cn/' + t['uid'] + '/statuses/' + t['id']
      
      line = ''
      line += '<span weight="bold" foreground="white" background="#1982d1" font_desc="13">'
      line += t['name'] 
      if t['remark'] != '' &&  (not t['remark'].nil?)
        line += '('+t['remark']+')'
      end
      line += '</span>'
      line += ': '
      line += '<span foreground="#333333" font_desc="12">'+ CGI::escapeHTML(t['text']) + '</span>'
      if not t['r'].nil?
        line += ' // '
        if not t['r']['name'].nil?
          line += '<span foreground="#111111" weight="bold" font_desc="12">'+ t['r']['name']+':' + '</span>'
        end
        line += '<span foreground="#333333" font_desc="12">' + CGI::escapeHTML(t['r']['text']) + '</span>'
      end

      more_table = Gtk::Table.new 1, 6
      des_box = Gtk::HBox.new
      
      more_label = Gtk::LinkButton.new weibo_detail_url, '进入详情'

      time_label = Gtk::Label.new
      time_label.markup = '<span foreground="#333333">'+t['time']+'</span>'
      time_label.show

      comment_button = Gtk::Button.new '评论'
      retweet_button = Gtk::Button.new '转发'
      reit_button = Gtk::Button.new '直接转发'
    
      more_table.attach time_label, 0, 2, 0, 1
      more_table.attach comment_button, 2, 3, 0, 1
      more_table.attach retweet_button, 3, 4, 0, 1
      more_table.attach reit_button, 4, 5, 0, 1
      more_table.attach more_label, 5, 6, 0, 1

      more_table.show_all

      label.markup = line

      @vbox.pack_start label, false
      @vbox.pack_start more_table, false
      #横线
      sep = Gtk::HSeparator.new
      @vbox.pack_start sep, false
      label.show
      sep.show
    end
    
  end

  def timeline_unpack(timeline)
    output = []
    raise 'get weibo data faild..' if timeline['statuses'].nil?
    timeline['statuses'].each do |t|
      data = {}
      data['id'] = t['id'].to_s
      data['uid'] = t['user']['id'].to_s
      data['avatar'] = t['user']['profile_image_url']
      data['name'] = t['user']['screen_name'] 
      data['gender'] = t['user']['gender']
      data['remark'] = t['user']['remark']
      data['text'] = t['text']
      data['udes'] = t['user']['description']
      
      if not t['thumbnail_pic'].nil?
        data['thumbnail_pic'] = t['thumbnail_pic']
      end
      if not t['retweeted_status'].nil?
        data['r'] = {}
        if not t['retweeted_status']['user'].nil? 
          data['r']['name'] = t['retweeted_status']['user']['screen_name']
          data['r']['gender'] = t['retweeted_status']['user']['gender']
        end
        data['r']['text'] = t['retweeted_status']['text'] || ''
      end
      data['time'] = Time.parse(t['created_at']).strftime(' 发布于%Y年%m月%d日 %k:%M %p')
      output.push data
    end
    output
  end

  def run
    Gtk.main
  end
end

g = GVbo.new
g.run
