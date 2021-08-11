{ WebMidi } = require 'webmidi'
midi = require 'midi'
{ Device } = require './device'
{ Printer } = require './printer'
forEach = require 'lodash/forEach'

colorSysx = [0x02, 0x0e, 0x03]
modeSysx = [0x02, 0x0e, 0x0e]
sessionMode = 0x00
programmerMode = 0x01
selectLayout = 0x00
programmerLayout = 0x11
ccStatus = 0xb0
rgbColor = 0x03
outputPortName = 'drum-middleware'
novation = [0x00, 0x20, 0x29]

devices = [
  new Device
    name: 'controller'
    id: 'Launchpad Pro MK3 LPProMK3 MIDI'
    manufacturer: novation
    channel: 1
  new Device
    name: 'controllerDaw'
    id: 'Launchpad Pro MK3 LPProMK3 DAW'
    manufacturer: novation
    channel: 1
]

exports.Controller = class Controller
  constructor: ({ padLayout, kitLayout, @kit, @printer }) ->
    @printer ?= new Printer()
    @kit.init { padLayout, kitLayout }
    @devices = devices.reduce (acc, d) ->
      acc[d.name] = d
      acc
    , {}
  init: ->
    @output = new midi.Output()
    @output.openVirtualPort(outputPortName)
    await WebMidi.enable sysex: true
    forEach @devices, (device) ->
      input = WebMidi.getInputByName device.id
      output = WebMidi.getOutputByName device.id
      device.init { input, output }
    @devices.controllerDaw.input.addListener 'sysex', @handleSysex
    @devices.controller.inchan.addListener 'keyaftertouch', @handleAftertouch
    @devices.controller.inchan.addListener 'noteon', @handleNoteOn
    @devices.controller.inchan.addListener 'noteoff', @handleNoteOff
    @initController()
  initController: ->
    @setMode programmerMode
    @initColors()
  close: ->
    WebMidi.disable()
  handleSysex: (e) =>
    head = e.rawData[0...6]
    body = e.rawData[6...-1]
    if body[0] is selectLayout and body[1] isnt programmerLayout
      @initController()
  handleAftertouch: (e) =>
    try
      chan = e.target.number - 1
      [_, note, pressure] = e.rawData
      status = ccStatus + chan
      pad = @kit.getByPad note
      @output.send [status, pad.getNote(), pressure] if pad?.aftertouch
    catch e
      console.error 'aftertouch error', e
  handleNoteOn: (e) =>
    try
      [status, note, velocity] = e.rawData
      pad = @kit.getByPad note
      @output.send [status, pad.getNote(), velocity] if pad
      @setColor { pad, brightness: 0.5, allPieces: true }
      @printer.setPad { pad }
    catch e
      console.error 'noteon error', e
  handleNoteOff: (e) =>
    try
      [status, note, velocity] = e.rawData
      pad = @kit.getByPad note
      @output.send [status, pad.getNote(), velocity] if pad
      @setColor { pad, allPieces: true }
      @printer.unsetPad { pad }
    catch
      console.error 'noteoff error', e
  setColor: ({ pad, brightness, allPieces }) ->
    brightness ?= 1.0
    ctrl = @devices.controller
    pads = @kit.getPads pad
    pads = @kit.getPiecePads pad if allPieces
    return unless pads
    specs = pads.map (p) =>
      pad = @kit.getByPad p
      color = pad.color.darken brightness
      [rgbColor, p, ...color.get()]
    msg = colorSysx.concat ...specs
    ctrl.output.sendSysex ctrl.manufacturer, msg
  initColors: ->
    @kit.eachPad (pad) => @setColor { pad }
  setMode: (mode) ->
    ctrl = @devices.controller
    msg = [modeSysx..., mode]
    ctrl.output.sendSysex ctrl.manufacturer, msg
