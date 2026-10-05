local parent = script.Parent
local useClock = require(parent.useClock)
require(parent.useRelicsAssetInfo)
local parent2 = parent.Parent
local parent3 = parent2.Parent
local State = require(parent2.State)
local shared = parent3.Shared
local React = require(shared.React)
local random = Random.new()

local function useRelicsRotato(p)
	local v = React.useMemo(function()
		return random:NextNumber(0, 1000)
	end, {})
	local v2, v3 = React.useBinding(0)
	local v4 = React.useContext(State.Context)
	useClock(p and 30 or 1, function(p2)
		if p == "PerlinNoise" then
			v3(math.noise(v, os.clock() / 3) * 12)
		elseif p == "MusicAccented" then
			local spectrogram = v4.GetSpectrogram()
			local value = v2:getValue()

			if spectrogram then
				value += spectrogram.PeakLevel * 1000 * p2
			end

			v3(value % 360)
		end
	end, { p })
	return v2
end

return useRelicsRotato