_         = require 'underscore'
should    = require 'should'
matchers  = require '../src/matchers'

describe 'matchers', ->

  m = matchers
  path = 'PATH'

  describe 'string', ->
    
    it 'valid type',            -> should.not.exist m.string(path, 'hi')
    it 'invalid type',          -> m.string(path, 3).should.match /should be a string/

  describe 'number', ->
    
    it 'valid integer',         -> should.not.exist m.number(path, 3)
    it 'valid float',           -> should.not.exist m.number(path, 3.2)
    it 'invalid',               -> m.number(path, 'foo').should.match /should be a number/

  describe 'boolean', ->
    
    it 'valid (true)',          -> should.not.exist m.boolean(path, true)
    it 'valid (false)',         -> should.not.exist m.boolean(path, false)
    it 'invalid bool',          -> m.boolean(path, 'foo').should.match /should be a boolean/

  describe 'ip', ->
    
    it 'valid (1 digit)',       -> should.not.exist m.ip(path, '0.0.0.0')
    it 'valid (3 digit2)',      -> should.not.exist m.ip(path, '255.255.255.255')
    it 'invalid (not string)',  -> m.ip(path, 10).should.match /string/
    it 'invalid (format)',      -> m.ip(path, '10.hello.3').should.match /not valid/

  describe 'host', ->
    
    it 'valid (ip)',            -> should.not.exist m.host(path, '10.0.13.6')
    it 'valid (hostname 1)',    -> should.not.exist m.host(path, 'my.long.host.name.local')
    it 'valid (hostname 2)',    -> should.not.exist m.host(path, 'with.valid987.digits-and-dashes')
    it 'invalid (not string)',  -> m.host(path, 10).should.match /string/
    it 'invalid (format 1)',    -> m.host(path, 'hey..cool..host').should.match /not valid/
    it 'invalid (format 2)',    -> m.host(path, 'funny!characters~').should.match /not valid/

  describe 'url', ->
    
    it 'valid (http)',          -> should.not.exist m.url(path, 'http://www.google.com')
    it 'valid (any schema)',    -> should.not.exist m.url(path, 'postgres://host/database')
    it 'valid (path+query)',    -> should.not.exist m.url(path, 'http://www.google.com/path/hello%20world?query+string')
    it 'valid (auth)',          -> should.not.exist m.url(path, 'http://user:pass@server')
    it 'invalid (not string)',  -> m.url(path, 3).should.match /string/
    it 'invalid (format)',      -> m.url(path, 'almost/a/url').should.match /not valid/

  describe 'file', ->
    
    it 'exists',                -> should.not.exist m.file(path, 'package.json')
    it 'doest not exist',       -> m.file(path, 'package.something').should.match /does not exist/

  describe 'money', ->
    
    it 'valid (2dp)',           -> should.not.exist m.money(path, '$12.00')
    it 'valid (1dp)',           -> should.not.exist m.money(path, '$12.5')
    it 'valid (0dp)',           -> should.not.exist m.money(path, '$12')
    it 'invalid (not string)',  -> m.money(path, 12).should.match /string/
    it 'invalid (3dp)',         -> m.money(path, '$12.500').should.match /not valid/



