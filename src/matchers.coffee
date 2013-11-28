fs  = require 'fs'
url = require 'url'

matchType = (type) ->
  (path, val) ->
    if typeof val != type
      "#{path} should be a #{type}, but #{val} is a #{typeof val}"
    else
      null

matchIp = (path, val) ->
  regex = /^(\d{1,3}.){3}\d{1,3}$/
  if typeof val != 'string' then return "#{path} should be an IP, but #{val} is not a string"
  if not val.match regex then return "#{path} should be an IP, but #{val} is not valid"

matchUrl = (path, val) ->
  if typeof val != 'string' then return  "#{path} should be a URL, but #{val} is not a string"
  u = url.parse val
  valid = u.protocol and u.host and u.path
  if not valid then return "#{path} should be an IP, but #{val} is not valid"

matchFile = (path, val) ->
  exists = fs.existsSync val
  if not exists then return "#{path} should be a valid file, but #{val} does not exist"


module.exports =
  
  # basic JS types
  string: matchType('string')
  boolean: matchType('boolean')
  number: matchType('number')
  
  # advanced validations
  ip: matchIp
  url: matchUrl
  file: matchFile
