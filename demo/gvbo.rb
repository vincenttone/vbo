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
        refresh_homeline
        @weibo_input_field.buffer.text = ''
      end
    end
  end

  def refresh_homeline
    @page = 1

    @show_box.remove @vbox

    @vbox = Gtk::VBox.new false, 2
    @show_box.pack_start @vbox, false
    @vbox.show
        
    @scrolled_window.vadjustment.value = @scrolled_window.vadjustment.lower
    load_home_timeline
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

    @scrolled_window = Gtk::ScrolledWindow.new nil, nil
    @scrolled_window.set_policy Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS
    @scrolled_window.add_with_viewport @show_box

    @show_weibo_frame.add @scrolled_window
    @show_weibo_frame.set_size_request 500, 400

    @vbox = Gtk::VBox.new false, 2
    @show_box.pack_start @vbox, false

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
      load_home_timeline user
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
      
      line = ''
      line += '<span weight="bold" foreground="white" background="#1982d1" font_desc="13">'+ t['name'] + '</span>'
      line += ': '
      line += '<span foreground="#333333" font_desc="12">'+ CGI::escapeHTML(t['text']) + '</span>'
      if not t['r'].nil?
        line += ' // '
        if not t['r']['name'].nil?
          line += '<span foreground="#111111" weight="bold" font_desc="12">'+ t['r']['name']+':' + '</span>'
        end
        line += '<span foreground="#333333" font_desc="12">' + CGI::escapeHTML(t['r']['text']) + '</span>'
      end
      line += '<span foreground="#555555" background="#bbbbbb" font_desc="10">' + t['time'] + '</span>'
      label.markup = line

      @vbox.pack_start label, false
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
      data['name'] = t['user']['screen_name'] 
      data['gender'] = t['user']['gender']
      data['text'] = t['text']
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
