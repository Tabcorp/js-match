_         = require 'underscore'
should    = require 'should'
matchers  = require '../src/matchers'

describe 'matchers', ->

  m = matchers
  path = 'PATH'

  describe 'string', ->
    
    it 'valid type',            -> should.not.exist m.string('hi')
    it 'invalid type',          -> m.string(3).should.eql 'should be a string'

  describe 'number', ->
    
    it 'valid integer',         -> should.not.exist m.number(3)
    it 'valid float',           -> should.not.exist m.number(3.2)
    it 'invalid',               -> m.number('foo').should.eql 'should be a number'

  describe 'boolean', ->
    
    it 'valid (true)',          -> should.not.exist m.boolean(true)
    it 'valid (false)',         -> should.not.exist m.boolean(false)
    it 'invalid bool',          -> m.boolean('foo').should.eql 'should be a boolean'

  describe 'ip', ->
    
    it 'valid (1 digit)',       -> should.not.exist m.ip('0.0.0.0')
    it 'valid (3 digit2)',      -> should.not.exist m.ip('255.255.255.255')
    it 'invalid (not string)',  -> m.ip(10).should.eql 'should be an IP'
    it 'invalid (format)',      -> m.ip('10.hello.3').should.eql 'should be an IP'

  describe 'host', ->
    
    it 'valid (ip)',            -> should.not.exist m.host('10.0.13.6')
    it 'valid (hostname 1)',    -> should.not.exist m.host('my.long.host.name.local')
    it 'valid (hostname 2)',    -> should.not.exist m.host('with.valid987.digits-and-dashes')
    it 'invalid (not string)',  -> m.host(10).should.eql 'should be a host'
    it 'invalid (format 1)',    -> m.host('hey..cool..host').should.eql 'should be a host'
    it 'invalid (format 2)',    -> m.host('funny!characters~').should.eql 'should be a host'

  describe 'url', ->
    
    it 'valid (scheme + host)',    -> should.not.exist m.url('http://www.google.com')
    it 'valid (optional port)',    -> should.not.exist m.url('http://localhost:1234')
    it 'valid (path + query)',     -> should.not.exist m.url('http://www.google.com/path/hello%20world?query+string')
    it 'valid (auth)',             -> should.not.exist m.url('http://user:pass@server')
    it 'valid (any scheme)',       -> should.not.exist m.url('postgres://host/database')    
    it 'invalid (not string)',     -> m.url(3).should.eql 'should be a URL'
    it 'invalid (format)',         -> m.url('almost/a/url').should.eql 'should be a URL'
    it 'invalid (no host)',        -> m.url('http://').should.eql 'should be a URL'
    it 'invalid (no path)',        -> m.url('redis://localhost').should.eql 'should be a URL'

  describe 'uri', ->

    it 'valid (scheme + anything)', -> should.not.exist m.uri('redis://localhost:6379')    
    it 'valid (no host name)'    , -> should.not.exist m.uri('pg:///')
    it 'invalid (not string)',     -> m.uri(3).should.eql 'should be a URI'
    it 'invalid (format)',         -> m.uri('almost/a/uri').should.eql 'should be a URI'  

  describe 'file', ->
    
    it 'exists',                -> should.not.exist m.file('package.json')
    it 'doest not exist',       -> m.file('package.something').should.eql 'should be an existing file path'

  describe 'dollars', ->
    
    it 'valid (2dp)',           -> should.not.exist m.dollars('$12.00')
    it 'valid (1dp)',           -> should.not.exist m.dollars('$12.5')
    it 'valid (0dp)',           -> should.not.exist m.dollars('$12')
    it 'invalid (not string)',  -> m.dollars(12).should.eql 'should be a dollar amount'
    it 'invalid (3dp)',         -> m.dollars('$12.500').should.eql 'should be a dollar amount'

  describe 'UUID version 4', ->
    it 'valid (test 1)',             -> should.not.exist m['uuid-v4']('3c8a90dd-11b8-47c3-a88e-67e92b097c7a')
    it 'valid (test 2)',             -> should.not.exist m['uuid-v4']('89c34fa1-0be5-45f6-80a3-84b962f0c699')
    it 'invalid (not string)',       -> m['uuid-v4'](123).should.include 'should be a UUID Version 4'
    it 'invalid (wrong format)',     -> m['uuid-v4']('89c34fa10be545f680a384b962f0c699').should.include 'should be a UUID Version 4'
    it 'invalid (version number)',   -> m['uuid-v4']('89c34fa1-0be5-15f6-80a3-84b962f0c699').should.include 'should be a UUID Version 4'
    it 'invalid (reserved bits)',    -> m['uuid-v4']('89c34fa1-0be5-45f6-70a3-84b962f0c699').should.include 'should be a UUID Version 4'

