#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/vbo'
vbo = Vince::Vbo.new
p vbo.get_authorize_url
vbo.set_access_code '5e51c3c7d5a9ec732c1f9a973967c978'
p vbo.get_access_token
