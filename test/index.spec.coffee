should      = require 'should'
jsm         = require '../src/index'

describe 'main exports', ->

  it 'exposes the validate function', ->
    schema = price: { match: 'number' }
    errors = jsm.validate { price: 'foo' }, schema
    errors[0].should.eql {path: 'price', value: 'foo', error: 'should be a number'}
  
  it 'exposes the matchers', ->
    jsm.matchers['even'] = (val) -> if val % 2 then "should be even"
    schema = price: { match: 'even' }
    errors = jsm.validate { price: 3 }, schema
    errors[0].should.eql {path: 'price', value: 3, error: 'should be even'}
