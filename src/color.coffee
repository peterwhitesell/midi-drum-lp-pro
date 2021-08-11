{ bytesToHex, hexToBytes } = require './hex'
color = require 'color'


exports.Color = class Color
  constructor: (@hex) ->
    @raw = hexToBytes @hex
    @
  get: -> @raw
  darken: (brightness=1.0) ->
    clr = (new color(@hex)).darken(1-brightness)
    new Color clr.hex()
  desaturate: (value=1.0) ->
    clr = (new color(@hex)).desaturate(1-value)
    new Color clr.hex()
