fs  = require 'fs'
url = require 'url'

# NOTE
# Some checks are clearly not as restrictive as the RFC
# but are probably enough for most quick validations

REGEX_IP = /^(\d{1,3}.){3}\d{1,3}$/
REGEX_HOST = /^([a-z0-9\-]+\.?)+$/i

matchType = (type) ->
  (path, val) ->
    if typeof val != type
      "#{path} should be a #{type}, but #{val} is a #{typeof val}"
    else
      null

matchIp = (path, val) ->
  if typeof val != 'string' then return "#{path} should be an IP, but #{val} is not a string"
  if not val.match(REGEX_IP) then return "#{path} should be an IP, but #{val} is not valid"

matchHost = (path, val) ->
  if typeof val != 'string' then return "#{path} should be a hostname, but #{val} is not a string"
  valid = val.match(REGEX_IP) or val.match(REGEX_HOST) or val == 'localhost'
  if not valid then return "#{path} should be an hostname, but #{val} is not valid"

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
  host: matchHost
  url: matchUrl
  file: matchFile
