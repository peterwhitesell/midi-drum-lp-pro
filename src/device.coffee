exports.Device = class Device
  constructor: ({ @name, @id, @manufacturer, @channel }) ->
    @input = null
    @inchan = null
    @outchan = null
    @output = null
  init: ({ @input, @output }) ->
    @inchan = @input.channels[@channel]
    @outchan = @output.channels[@channel]
