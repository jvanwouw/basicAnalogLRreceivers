local radio = require('radio')

if #arg < 2 then
    io.stderr:write("Usage: " .. arg[0] .. " <left frequency> <right frequency>\n")
    os.exit(1)
end

local frequencyL = tonumber(arg[1])
local frequencyR = tonumber(arg[2])
local centerFreq = (frequencyL+frequencyR)/2
local tune_offset = -100e3
local deviation = 5e3
local bandwidth = 12.5e3

--dual narrow-band FM receiver that outputs one frequency to the left channel and another to the right channel 

-- Blocks
local source = radio.RtlSdrSource(centerFreq, 2.4e6, {autogain = true})

local tunerL = radio.TunerBlock(centerFreq-frequencyL, 2*(deviation+bandwidth), 50)
local fm_demodL = radio.FrequencyDiscriminatorBlock(deviation/bandwidth)
local af_filterL = radio.LowpassFilterBlock(128, bandwidth)

local tunerR = radio.TunerBlock(centerFreq-frequencyR, 2*(deviation+bandwidth), 50)
local fm_demodR = radio.FrequencyDiscriminatorBlock(deviation/bandwidth)
local af_filterR = radio.LowpassFilterBlock(128, bandwidth)

local sink = radio.PulseAudioSink(2)

-- Connections
local top = radio.CompositeBlock()
top:connect(source, tunerL, fm_demodL, af_filterL)
top:connect(source, tunerR, fm_demodR, af_filterR)
top:connect(af_filterL, 'out', sink, 'in1')
top:connect(af_filterR, 'out', sink, 'in2')

top:run()
