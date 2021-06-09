local radio = require('radio')

if #arg < 2 then
    io.stderr:write("Usage: " .. arg[0] .. " <left frequency> <right frequency> <left squelch in dBFS> <right squelch in dBFS>\n")
    os.exit(1)
end

if arg[4] == nil then
    arg[3] = -22
    arg[4] = -22
end

local frequencyL = tonumber(arg[1])
local frequencyR = tonumber(arg[2])
local centerFreq = (frequencyL+frequencyR)/2
local squelchValL = tonumber(arg[3])
local squelchValR = tonumber(arg[4])
local tune_offset = -100e3
local deviation = 5e3
local bandwidth = 12.5e3

--dual narrow-band FM receiver that outputs one frequency to the left channel and another to the right channel 

-- Blocks
local source = radio.RtlSdrSource(centerFreq, 2.4e6, {rf_gain = 40.0})


local tunerL = radio.TunerBlock(centerFreq-frequencyL, 2*(deviation+bandwidth), 50)
local fm_demodL = radio.FrequencyDiscriminatorBlock(deviation/bandwidth)
local af_filterL = radio.LowpassFilterBlock(128, bandwidth)
local squelchL = radio.PowerSquelchBlock(squelchValL)

local tunerR = radio.TunerBlock(centerFreq-frequencyR, 2*(deviation+bandwidth), 50)
local fm_demodR = radio.FrequencyDiscriminatorBlock(deviation/bandwidth)
local af_filterR = radio.LowpassFilterBlock(128, bandwidth)
local squelchR = radio.PowerSquelchBlock(squelchValR)


local sink = radio.PulseAudioSink(2)

-- Connections
local top = radio.CompositeBlock()
top:connect(source, tunerL, squelchL, fm_demodL, af_filterL)
top:connect(source, tunerR, squelchR, fm_demodR, af_filterR)
top:connect(af_filterL, 'out', sink, 'in1')
top:connect(af_filterR, 'out', sink, 'in2')

top:run()
