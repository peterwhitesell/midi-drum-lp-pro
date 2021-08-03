exports.Device = class Device {
  constructor({ name, id, manufacturer, channel }) {
    this.name = name
    this.channel = channel
    this.id = id
    this.manufacturer = manufacturer
    this.inchan = null
    this.outchan = null
    this.output = null
  }
  init({ input, output }) {
    this.inchan = input.channels[this.channel]
    this.outchan = output.channels[this.channel]
    this.output = output
  }
}
