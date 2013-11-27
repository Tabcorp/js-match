should      = require 'should'
jsm         = require '../src/index'

describe 'main exports', ->

  it 'exposes the validate function', ->
    schema = price: { match: 'number' }
    errors = jsm.validate { price: 'foo' }, schema
    errors[0].should.match /price should be a number/
  
  it 'exposes the matchers', ->
    jsm.matchers['even'] = (path, val) -> if val % 2 then "#{path} should be even, but was #{val}"
    schema = price: { match: 'even' }
    errors = jsm.validate { price: 3 }, schema
    errors[0].should.match /price should be even/

