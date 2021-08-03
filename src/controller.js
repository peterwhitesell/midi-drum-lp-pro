const {
  WebMidi
} = require('webmidi')
const { hexBytes } = require('./hex')
const { Device } = require('./device')

const colorSysx = [0x02, 0x0E, 0x03]

const devices = [
  new Device({
    name: 'controller',
    id: 'Launchpad Pro MK3 LPProMK3 MIDI',
    manufacturer: [0x00, 0x20, 0x29],
    channel: 1,
  }),
  new Device({
    name: 'virtual',
    id: 'WebMidi drum',
    manufacturer: null,
    channel: 1,
  }),
]

exports.Controller = class Controller {
  constructor({ padLayout, kitLayout, kit }) {
    this.kit = kit
    kit.init({ padLayout, kitLayout })
    this.devices = devices.reduce((acc, d) => {
      acc[d.name] = d
      return acc
    }, {})
    this.refreshInterval = null
  }
  async init() {
    await WebMidi.enable({
      sysex: true
    })
    Object.keys(devices).forEach(name => {
      let device = devices[name]
      let input = WebMidi.getInputByName(device.id)
      let output = WebMidi.getOutputByName(device.id)
      device.init({ input, output })
    })
    this.devices.controller.inchan.addListener(
      "midimessage",
      this.handleMidi.bind(this)
    )
    this.devices.controller.inchan.addListener(
      "noteon",
      this.handleNoteOn.bind(this)
    )
    this.devices.controller.inchan.addListener(
      "noteoff",
      this.handleNoteOff.bind(this)
    )
    this.sessionMode()
    this.startPoll()
  }
  startPoll() {
    this.refreshInterval = setInterval(() => {
      this.programmerMode()
      this.initColors()
    }, 1000)
  }
  stopPoll() {
    clearInterval(this.refreshInterval)
  }
  close() {
    this.stopPoll()
    Webmidi.disable()
  }
  handleMidi(e) {
    try {
      const msg = e.rawData
      const hexMsg = hexBytes(msg)
      const status = msg[0]
      const pad = hexMsg[1]
      const piece = this.kit.getByPad(pad)
      const data = [].slice.call(msg, 1)
      if (piece) {
        data[0] = piece.note
        this.devices.virtual.output.send(status, data)
      }
      console.log('-->', hexMsg, piece.id, hexBytes([status, ...data]), '-->')
    } catch (e) {
      console.error(e)
    }
  }
  handleNoteOn(e) {
    const pad = e.note.number
    const piece = this.kit.getByPad(pad)
    this.setColor(piece, .1)
  }
  handleNoteOff(e) {
    const pad = e.note.number
    const piece = this.kit.getByPad(pad)
    this.setColor(piece)
  }
  setColor(piece, brightness=1.0) {
    const ctrl = this.devices.controller
    const pads = this.kit.getPads(piece)
    if (!pads) return
    const color = piece.color.darken(brightness)
    const specs = pads.map(p => [0x03, p, ...color.value])
    const msg = colorSysx.concat(...specs)
    ctrl.output.sendSysex(ctrl.manufacturer, msg)
  }
  initColors() {
    this.kit.pieces.forEach(piece => this.setColor(piece))
  }
  sessionMode() {
    const ctrl = this.devices.controller
    const msg = [0x02, 0x0E, 0x0E, 0x00]
    ctrl.output.sendSysex(ctrl.manufacturer, msg)
  }
  programmerMode() {
    const ctrl = this.devices.controller
    const msg = [0x02, 0x0E, 0x0E, 0x01]
    ctrl.output.sendSysex(ctrl.manufacturer, msg)
  }
}
