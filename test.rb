#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/weibo'
vbo = Vbo::Weibo.new
p vbo.get_authorize_url
#vbo.set_access_code '6eb296e1a2a3e5a54a80ffd94bcd9ef5'
#p vbo.get_access_token
# :access token is {"access_token"=>"2.00XXXXXXXXXXXXXXXXXX", "remind_in"=>"114302", "expires_in"=>114302, "uid"=>"xxxxxxxxx"}
access_token = :access_token
vbo.set_access_token access_token

p vbo.get__statuses__public_timeline( {:count=>10}).body
p vbo.get__statuses__public_timeline_ids( {:count=>10}).body
