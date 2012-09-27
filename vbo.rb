#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'net/http'
require 'uri'
require 'json'

module Vince
  class Vbo
    URL_TYPE_API = 1;
    URL_TYPE_OAUTH = 2;

    URL_API = 'https://api.weibo.com/2/'
    URL_OAUTH = 'https://api.weibo.com/oauth2/'

    APP_KEY = ''
    APP_SECRET = ''
    CALLBACK_URI = 'http://127.0.0.1:3000/weibo/code'

    def initialize
      @app_key = ENV['WB_APP_KEY'] || APP_KEY
      @secret_key = ENV['WB_SECRET_KEY'] || APP_SECRET
      @callback_uri = ENV['WB_CALLBACK'] || CALLBACK_URI

      @access_code = '35379ca19600ad469306cdd3e2359c49'
    end

    private
    # =============== 私有方法 =================

    #url获取器
    def get_request_url(path, url_type=URL_TYPE_API)
      path = case url_type 
             when URL_TYPE_API then URL_API + path
             when URL_TYPE_OAUTH then URL_OAUTH + path
             end
    end

    #获取URL参数
    def get_url_params(hash_params)
      params = URI.escape hash_params.collect{|k, v| "#{k}=#{URI.encode(v)}"}.join('&')
    end

    #获取get格式的URL
    def get_url(url, data, type=URL_TYPE_API)
      url = get_request_url(url, type)
      url + "?" + get_url_params(data)
    end

    # GET方法封装
    def get(path, initheader={}, dest=nil)
      #请求并返回
      #Net::HTTP.get(path, initheader, dest)
      uri = URI(path)
      request = Net::HTTP::Get.new uri.request_uri
      res = Net::HTTP.start( uri.host, uri.port, :use_ssl=> uri.scheme == 'https') do |http|
        response = http.request request
      end
      res.body
    end
    # POST方法封装
    def post(path, data)
      #Net::HTTP.post_form URI(path), data
      uri = URI(path)
      request = Net::HTTP::Post.new uri.request_uri
      request.set_form_data data
      res = Net::HTTP.start( uri.host, uri.port, :use_ssl=> uri.scheme == 'https') do |http|
        response = http.request request
      end
      res.body
    end

    public
    # ============= public ===============
    
    #获取access_token地址
    def get_authorize_url
      data = {
        'client_id' => @app_key,
        'redirect_uri' => @callback_uri
      }
      get_url('authorize', data, URL_TYPE_OAUTH)
    end
    
    #设置access code
    def set_access_code(code)
      @access_code = code
    end

    #设置access token信息
    def set_access_token(token_hash)
      if token_hash['access_token'].nil? or token_hash['uid'].nil? or token_hash['expires_in'].nil?
        raise 'Access token error!'
      end
      @access_token = token_hash['access_token']
      @uid = token_hash['uid']
      @expires_in = token_hash['expires_in']
    end
    
    #获取access token
    def get_access_token
      data = {
        'client_id' => @app_key,
        'client_secret' => @secret_key,
        'grant_type' => 'authorization_code',
        'code' => @access_code,
        'redirect_uri' => @callback_uri
      }
      url = get_request_url('access_token', URL_TYPE_OAUTH)
      res_body = post url, data
      
      result = JSON.load res_body
      if result['access_token'].nil?
        raise 'Get access_token faild'
      else
        result
      end
    end

  end
  #end class
end
#end module
