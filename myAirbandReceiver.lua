local radio = require('radio')

if #arg < 1 then
    io.stderr:write("Usage: " .. arg[0] .. " <frequency> <squelch in dBFS>\n")
    os.exit(1)
end

local squelchVal

if arg[2] == nil then
    squelchVal = -80
else
    squelchVal = tonumber(arg[2])
end

local frequency = tonumber(arg[1])
local ifreq = 50e3
local bandwidth = 8.33e3

-- Blocks
local source = radio.RtlSdrSource(frequency - ifreq, 1102500, {rf_gain = 47.5})
local squelch = radio.PowerSquelchBlock(squelchVal)
local rf_decimator = radio.DecimatorBlock(5)
local if_filter = radio.ComplexBandpassFilterBlock(129, {ifreq - bandwidth, ifreq + bandwidth})
local pll = radio.PLLBlock(1000, ifreq - 100, ifreq + 100)
local mixer = radio.MultiplyConjugateBlock()
local am_demod = radio.ComplexToRealBlock()
local dcr_filter = radio.SinglepoleHighpassFilterBlock(100)
local af_filter = radio.LowpassFilterBlock(128, bandwidth)
local af_downsampler = radio.DownsamplerBlock(10)
local af_gain = radio.AGCBlock('custom', -30, -80, {gain_tau = 4.0})
local sink = radio.PulseAudioSink(1) or radio.WAVFileSink('am_synchronous.wav', 1)

-- Connections
local top = radio.CompositeBlock()
top:connect(source, rf_decimator, if_filter)
top:connect(if_filter, pll)
top:connect(if_filter, 'out', mixer, 'in1')
top:connect(pll, 'out', mixer, 'in2')
top:connect(mixer, squelch, am_demod, dcr_filter, af_filter, af_downsampler, af_gain, sink)

top:run()
