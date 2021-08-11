chunk = require 'lodash/chunk'

hexByte = (byte) ->
  byte.toString(16).padStart 2, '0'

hexBytes = (bytes) ->
  out = []
  bytes.forEach (b) -> out.push hexByte b
  out

bytesToHex = (bytes) ->
  '#' + hexBytes(bytes.map (b) -> 2 * b).join ''

hexToBytes = (hex) ->
  chunk hex.substring(1), 2
    .map (c) -> c.join ''
    .map (c) -> Math.floor(parseInt(c, 16) / 2)

module.exports = { hexByte, hexBytes, bytesToHex, hexToBytes }
