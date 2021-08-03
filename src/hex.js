const chunk = require('lodash/chunk')

function hexByte(byte) {
  return byte.toString(16).padStart(2, '0')
}

function hexBytes(bytes) {
  let out = []
  bytes.forEach(b => {
    out.push(hexByte(b))
  })
  return out
}

function bytesToHex(bytes) {
  return '#' + hexBytes(bytes.map(b => 2*b)).join('')
}

function hexToBytes(hex) {
  let chunks = chunk(hex.substring(1), 2).map(c => c.join(''))
  return chunks.map(c => Math.floor(parseInt(c, 16) / 2))
}

module.exports = {
  hexByte,
  hexBytes,
  bytesToHex,
  hexToBytes,
}
