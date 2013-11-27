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
      errors[0].should.match /message should be a string/

    it 'considers properties to be required', ->
      object = message: undefined
      schema = message: { match: 'string' }
      errors = validate object, schema
      errors[0].should.match /message is required/

  describe 'optional fields', ->
  
    it 'when missing', ->
      object = message: undefined
      schema = message: { match: 'string', optional: true }
      errors = validate object, schema
      errors.should.eql []

    it 'still validate if present', ->
      object = message: 42
      schema = message: { match: 'string', optional: true }
      errors = validate object, schema
      errors[0].should.match /message should be a string/


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
      errors[0].should.match /message should be a string/
      errors[1].should.match /value should be a number/


  describe 'custom matchers', ->

    matchers['bigNumber'] = (key, val) -> if val < 1000 then "#{val} is not very big"

    it 'valid with custom matcher', ->
      schema = num: { match: 'bigNumber' }
      errors = validate {num: 1000}, schema
      errors.should.eql []

    it 'invalid with custom matcher', ->
      schema = num: { match: 'bigNumber' }
      errors = validate {num: 999}, schema
      errors[0].should.match /999 is not very big/

    it 'fails if a custom matcher does not exist', ->
      schema = num: { match: 'something' }
      errors = validate {num: 999}, schema
      errors[0].should.match /matcher something is not defined/


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
      errors[0].should.match /person\.age should be a number/
      errors[1].should.match /person\.address\.city should be a string/

    it 'missing parts in the hierarchy', ->
      object =
        person:
          age: 30
      errors = validate object, schema
      errors[0].should.match /person\.address is required/


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
      errors[0].should.match /items should be an array/

    it 'invalid array items', ->
      object =
        items: [
          { name: 'pen',    price: 1     }
          { name: 10000,    price: 'foo' }
        ]
      errors = validate object, schema
      errors[0].should.match /items\.name should be a string/
      errors[1].should.match /items\.price should be a number/
 
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
      errors[0].should.match /items should be a number, but foo is a string/
