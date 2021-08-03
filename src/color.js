const {
  bytesToHex,
  hexToBytes
} = require('./hex')


exports.Color = class Color {
  constructor(hex) {
    this.hex = hex
    this.raw = hexToBytes(hex)
    return this
  }
  get value() {
    return this.raw
  }
  darken(brightness=1.0) {
    let softRaw = this.raw.map(s => Math.floor(s * brightness))
    let softHex = bytesToHex(softRaw)
    return new Color(softHex)
  }
}
