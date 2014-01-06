fs  = require 'fs'
url = require 'url'

# NOTE
# Some checks are clearly not as restrictive as the RFC
# but are probably enough for most quick validations

REGEX_IP      = /^(\d{1,3}.){3}\d{1,3}$/
REGEX_HOST    = /^([a-z0-9\-]+\.?)+$/i
REGEX_DOLLARS = /^\$?[\d]+(\.\d{1,2})?$/
REGEX_UUID_V4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

matchType = (type) ->
  (val) ->
    if typeof val != type then "should be a #{type}"
    else null

matchIp = (val) ->
  if (typeof val != 'string') or (not val.match REGEX_IP)
    "should be an IP"

matchHost = (val) ->
  if typeof val != 'string' then return "should be a host"
  valid = val.match(REGEX_IP) or val.match(REGEX_HOST) or val == 'localhost'
  if not valid then return "should be a host"

matchUrl = (val) ->
  if typeof val != 'string' then return  "should be a URL"
  u = url.parse val
  valid = u.protocol and u.host and u.path
  if not valid then return "should be a URL"

matchFile = (val) ->
  if not fs.existsSync(val)
    "should be an existing file path"

matchDollars = (val) ->
  if (typeof val != 'string') or (not val.match REGEX_DOLLARS )
    #TODO have a way of giving examples of valid values (e.g. $10.00)
    'should be a dollar amount'

uuidV4 = (val) ->
  message = 'should be a UUID Version 4 (xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx)'
  return message unless (typeof val is 'string')
  return message unless val.match REGEX_UUID_V4


module.exports =
  
  # basic JS types
  'string':  matchType('string')
  'boolean': matchType('boolean')
  'number':  matchType('number')
  
  # advanced validations
  'ip':      matchIp
  'host':    matchHost
  'url':     matchUrl
  'file':    matchFile
  'dollars': matchDollars
  'uuid-v4': uuidV4
