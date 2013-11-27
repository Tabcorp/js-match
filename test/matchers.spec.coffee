_         = require 'underscore'
should    = require 'should'
matchers  = require '../src/matchers'

describe 'matchers', ->

  m = matchers
  key = 'name'

  describe 'string', ->
    
    it 'valid',   -> should.not.exist m.string(key, 'hi')
    it 'invalid', -> m.string(key, 3).should.match /should be a string/

  describe 'number', ->
    
    it 'valid integer', -> should.not.exist m.number(key, 3)
    it 'valid float',   -> should.not.exist m.number(key, 3.2)
    it 'invalid',       -> m.number(key, 'foo').should.match /should be a number/

  describe 'boolean', ->
    
    it 'valid (true)',    -> should.not.exist m.boolean(key, true)
    it 'valid (false)',   -> should.not.exist m.boolean(key, false)
    it 'invalid bool',    -> m.boolean(key, 'foo').should.match /should be a boolean/

  describe 'ip', ->
    
    it 'valid (1 digit)',       -> should.not.exist m.ip(key, '0.0.0.0')
    it 'valid (3 digit2)',      -> should.not.exist m.ip(key, '255.255.255.255')
    it 'invalid (not string)',  -> m.ip(key, 10).should.match /string/
    it 'invalid (format)',      -> m.ip(key, '10.hello.3').should.match /not valid/

  describe 'url', ->
    
    it 'valid (http)',         -> should.not.exist m.url(key, 'http://www.google.com')
    it 'valid (any schema)',   -> should.not.exist m.url(key, 'postgres://host/database')
    it 'valid (path+query)',   -> should.not.exist m.url(key, 'http://www.google.com/path/hello%20world?query+string')
    it 'valid (auth)',         -> should.not.exist m.url(key, 'http://user:pass@server')
    it 'valid (not string)',   -> m.url(key, 3).should.match /string/
    it 'valid (format)',       -> m.url(key, 'almost/a/url').should.match /not valid/
