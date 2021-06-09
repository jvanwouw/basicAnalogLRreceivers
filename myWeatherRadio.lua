local radio = require('radio')

local frequency = 162.425e6
local tune_offset = -100e3
local deviation = 5e3
local bandwidth = 16e3

-- Blocks
local source = radio.RtlSdrSource(frequency + tune_offset, 1102500, {rf_gain = 45.0})
local tuner = radio.TunerBlock(tune_offset, 2*(deviation+bandwidth), 50)
local fm_demod = radio.FrequencyDiscriminatorBlock(deviation/bandwidth)
local af_filter = radio.LowpassFilterBlock(128, bandwidth)
local sink = radio.PulseAudioSink(1) or radio.WAVFileSink('nbfm.wav', 1)

-- Connections
local top = radio.CompositeBlock()
top:connect(source, tuner, fm_demod, af_filter, sink)

top:run()
