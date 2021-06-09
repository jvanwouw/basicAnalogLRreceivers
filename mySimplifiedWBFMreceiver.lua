local radio = require('radio')

if #arg < 1 then
    io.stderr:write("Usage: " .. arg[0] .. " <FM radio frequency>\n")
    os.exit(1)
end

local frequency = tonumber(arg[1])
local tune_offset = -250e3

-- Blocks
local source = radio.RtlSdrSource(frequency + tune_offset, 1102500, {autogain = true})
local tuner = radio.TunerBlock(tune_offset, 200e3, 5)
local fm_demod = radio.WBFMMonoDemodulator()
local af_downsampler = radio.DownsamplerBlock(5)
local sink = radio.PulseAudioSink(1) or radio.WAVFileSink('wbfm_mono.wav', 1)

-- Connections
local top = radio.CompositeBlock()
top:connect(source, tuner, fm_demod, af_downsampler, sink)

top:run()
