_         = require 'underscore'
util      = require 'util'
matchers  = require './matchers'

validateField = (path, value, spec) ->
  if not value?
    return (if spec.optional then null else {path: path, error: 'required'})
  m = matchers[spec.match]
  if not m
    {path: path, error: "matcher <#{spec.match}> is not defined"}
  else
    error = m(value, spec)

    if error
      path:  path
      value: value
      error: spec.message or error
    else
      null

getChildSchema = (parent, obj, spec) ->
  if typeof spec.schema is 'function'
    spec.schema parent, obj
  else
    spec.schema


validateHierarchy = (path, obj, schema) ->
  # Testing primitives (no keys)
  if schema.match
    return validateField path, obj, schema

  # If the schema has object keys
  return _.map schema, (spec, key) ->
    fullPath = if path then "#{path}.#{key}" else key

    # Leaf specification
    if spec.match
      return validateField fullPath, obj[key], spec

    # Leaf schema match
    if spec.schema
      if not obj[key]
        return (if spec.optional then null else {path: fullPath, error: 'required'})
      else
        return validateHierarchy fullPath, obj[key], getChildSchema(obj, obj[key], spec)

    # Nested schema = array
    if util.isArray spec
      if not obj[key]
        optional = if (spec[0].match or spec[0].schema) then spec[0].optional else false
        return (if optional is true then null else {path: fullPath, error: 'required'})
      else if not util.isArray obj[key]
        return {path: fullPath, error: 'should be an array'}
      else if spec[0].schema and spec[0].min and spec[0].min > obj[key].length
        return {path: fullPath, error: "minimum length is #{spec[0].min}"}
      else if spec[0].schema and spec[0].max and spec[0].max < obj[key].length
        return {path: fullPath, error: "maximum length is #{spec[0].max}"}
      else
        return obj[key].map (val, i) ->
          if spec[0].schema
            childSchema = getChildSchema(obj, val, spec[0])
          validateHierarchy "#{fullPath}[#{i}]", val, (childSchema or spec[0])

    # Nested schema = missing
    if not obj[key]
      return {path: fullPath, error: 'required'}

    # Nested schema = object
    return validateHierarchy fullPath, obj[key], spec

module.exports = (obj, schema) ->
  errors = validateHierarchy '', obj, schema
  _.compact _.flatten errors
