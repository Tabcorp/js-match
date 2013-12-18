_         = require 'underscore'
should    = require 'should'
validate  = require '../src/validate'
matchers  = require '../src/matchers'

describe 'validate', ->


  describe 'single field validation', ->
    
    it 'valid property', ->
      object = message: 'hello'
      schema = message: { match: 'string' }
      errors = validate object, schema
      errors.should.eql []

    it 'invalid property', ->
      object = message: 42
      schema = message: { match: 'string' }
      errors = validate object, schema
      errors[0].should.eql {path: 'message', value: 42, error: 'should be a string'}

    it 'considers properties to be required', ->
      object = message: undefined
      schema = message: { match: 'string' }
      errors = validate object, schema
      errors[0].should.eql {path: 'message', error: 'required'}

  describe 'optional fields', ->
  
    it 'when missing', ->
      object = message: undefined
      schema = message: { match: 'string', optional: true }
      errors = validate object, schema
      errors.should.eql []

    it 'when null', ->
      object = message: null
      schema = message: { match: 'string', optional: true }
      errors = validate object, schema
      errors.should.eql []

    it 'still validate if present', ->
      object = message: 42
      schema = message: { match: 'string', optional: true }
      errors = validate object, schema
      errors[0].should.eql {path: 'message', value: 42, error: 'should be a string'}


  describe 'multiple fields in a flat structure', ->

    schema =
      message: { match: 'string' }
      value:   { match: 'number' }
    
    it 'multiple valid properties', ->
      object =
        message: 'hello'
        value: 3
      errors = validate object, schema
      errors.should.eql []
  
    it 'multiple invalid properties', ->
      object =
        message: 42
        value: 'hello'
      errors = validate object, schema
      errors[0].should.eql {path: 'message', value: 42, error: 'should be a string'}
      errors[1].should.eql {path: 'value', value: 'hello', error: 'should be a number'}


  describe 'custom matchers', ->

    matchers['bigNumber'] = (val) -> if val < 1000 then "not big enough"

    it 'valid with custom matcher', ->
      schema = num: { match: 'bigNumber' }
      errors = validate {num: 1000}, schema
      errors.should.eql []

    it 'invalid with custom matcher', ->
      schema = num: { match: 'bigNumber' }
      errors = validate {num: 999}, schema
      errors[0].should.eql {path: 'num', value: 999, error: 'not big enough'}

    it 'fails if a custom matcher does not exist', ->
      schema = num: { match: 'something' }
      errors = validate {num: 999}, schema
      errors[0].should.eql {path: 'num', error: 'matcher <something> is not defined'}

    it 'can pass extra options to a matcher', ->
      matchers['score'] = (val, opts) ->
        if val < opts.min
          "should be a score >= #{opts.min}"
      schema = num: { match: 'score', min: 5 }
      validate({num: 3}, schema).should.eql [{path: 'num', value: 3, error: 'should be a score >= 5'}]
      validate({num: 7}, schema).should.eql []

  describe 'hierarchies', ->
    
    schema =
      person:
        age:         { match: 'number' }
        address:
          city:      { match: 'string' }
          postcode:  { match: 'number' }
    
    it 'all valid fields', ->
      object =
        person:
          age: 30
          address:
            city: 'Sydney'
            postcode: 2000
      errors = validate object, schema
      errors.should.eql []

    it 'some invalid fields', ->
      object =
        person:
          age: 'hello'
          address:
            city: false
            postcode: 2000
      errors = validate object, schema
      errors[0].should.eql {path: 'person.age', value: 'hello', error:  'should be a number'}
      errors[1].should.eql {path: 'person.address.city', value: false, error: 'should be a string'}

    it 'missing parts in the hierarchy', ->
      object =
        person:
          age: 30
      errors = validate object, schema
      errors[0].should.eql {path: 'person.address', error: 'required'}


  describe 'arrays of objects', ->

    schema =
      items: [
        name:  { match: 'string' }
        price: { match: 'number' }
      ]
  
    it 'valid items (objects)', ->
      object =
        items: [
          { name: 'pen',    price: 1 }
          { name: 'bottle', price: 2 }
        ]
      errors = validate object, schema
      errors.should.eql []
  
    it 'invalid array object', ->
      object =
        items: { hello: 'world' }
      errors = validate object, schema
      errors[0].should.eql {path: 'items', error: 'should be an array'}

    it 'invalid array items', ->
      object =
        items: [
          { name: 'pen',    price: 1     }
          { name: 10000,    price: 'foo' }
        ]
      errors = validate object, schema
      errors[0].should.eql {path: 'items[1].name',  value: 10000, error: 'should be a string'}
      errors[1].should.eql {path: 'items[1].price', value: 'foo', error: 'should be a number'}
 
  describe 'arrays of primitives', ->

    schema =
      items: [{ match: 'number' }]
  
    it 'valid items', ->
      object =
        items: [1, 2, 3]
      errors = validate object, schema
      errors.should.eql []

    it 'invalid items', ->
      object =
        items: [1, 'foo', 3]
      errors = validate object, schema
      errors[0].should.eql {path :'items[1]', value: 'foo', error: 'should be a number'}
