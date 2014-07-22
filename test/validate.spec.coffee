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


  describe 'schema match', ->

    beforeEach ->
      @object =
        name: 'test'

      @auth =
        id:
          match: 'number'
        pw:
          match: 'string'

      @schema =
        auth:
          schema: @auth

    describe 'required', ->

      it 'has required schema object', ->
        @object.auth =
          id:  111
          pw: 'xxx'

        errors = validate @object, @schema
        errors.should.eql []

      it 'misses required schema object', ->
        errors = validate @object, @schema
        errors.should.eql [{path: 'auth', error: 'required'}]

    describe 'optional', ->

      beforeEach ->
        @schema.auth.optional = true

      it 'has optinal schema object', ->
        @object.auth =
          id:  111
          pw: 'xxx'

        errors = validate @object, @schema
        errors.should.eql []

      it 'misses optional schema object', ->
        errors = validate @object, @schema
        errors.should.eql []

      it 'has optional schema object which is invalid', ->
        @object.auth =
           id:  111
        @schema.auth.optional = true

        errors = validate @object, @schema
        errors.should.eql [{path: 'auth.pw', error: 'required'}]

      it 'has nested optional schema object which is invalid', ->
        object =
          name:     'test'
          auth:
            id:     111
            pw:     'pw'
            auth2:
              id:   112

        auth2 =
          id:
            match: 'number'
          pw:
            match: 'string'

        auth =
          id:
            match: 'number'
          pw:
            match: 'string'
          auth2:
            schema: auth2
            optional: true

        schema =
          auth:
            schema: auth

        errors = validate object, schema
        errors.should.eql [{path: 'auth.auth2.pw', error: 'required'}]

    describe 'custom message', ->

      it 'should return custom message', ->
        object = message: 42
        schema = message: { match: 'string', message: 'this is custom' }
        errors = validate object, schema
        errors[0].should.eql
          path: 'message'
          value: 42
          error: 'this is custom'

      it 'should not return custom message if field is not present', ->
        object = {}
        schema = message: { match: 'string', message: 'this is custom' }
        errors = validate object, schema
        errors[0].should.eql
          path: 'message'
          error: 'required'
