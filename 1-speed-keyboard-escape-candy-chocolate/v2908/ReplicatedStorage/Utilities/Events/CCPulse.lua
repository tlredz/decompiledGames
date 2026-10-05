local Lighting = game:GetService("Lighting")
local CCPulse = {}
CCPulse.__index = CCPulse

function CCPulse.new(options)
	local v = options or {}
	local self = setmetatable({}, CCPulse)
	self._name = v.name or "CCPulse"
	self._colorSpeed = v.colorSpeed or 0.23
	self._contrast = v.contrast or 0.06
	self._satCenter = v.satCenter or 0.12
	self._satAmp = v.satAmp or 0.08
	self._satFreq = v.satFreq or 1.1
	self._tintSatMin = v.tintSatMin or 0.18
	self._tintSatAmp = v.tintSatAmp or 0.1
	self._tintSatFreq = v.tintSatFreq or 2.3
	self._brightBase = v.brightBase or 0.01
	self._brightAmp = v.brightAmp or 0.02
	self._brightFreq = v.brightFreq or 3.8
	self._bloomIntensity = v.bloomIntensity or 0.45
	self._bloomSize = v.bloomSize or 18
	self._bloomThreshold = v.bloomThreshold or 0.9
	self._colors = v.colors
	self._tintStrength = v.tintStrength or 0.65
	self._cc = nil
	return self
end

function CCPulse:setup(maid)
	local cc = maid:Add(Instance.new("ColorCorrectionEffect"))
	cc.Name = self._name .. "CC"
	cc.Brightness = self._brightBase
	cc.Contrast = self._contrast
	cc.Saturation = self._satCenter
	cc.TintColor = Color3.fromRGB(255, 200, 255)
	cc.Parent = Lighting
	self._cc = cc
	local v2 = maid:Add(Instance.new("BloomEffect"))
	v2.Name = self._name .. "Bloom"
	v2.Intensity = self._bloomIntensity
	v2.Size = self._bloomSize
	v2.Threshold = self._bloomThreshold
	v2.Parent = Lighting
end

function CCPulse:update(p)
	local _cc = self._cc

	if not (_cc and _cc.Parent) then
		return
	end

	local _colors = self._colors

	if _colors and #_colors > 0 then
		local v = p * self._colorSpeed % #_colors
		local v2 = math.floor(v) + 1
		local v3 = v2 % #_colors + 1
		local lerped = _colors[v2]:Lerp(_colors[v3], v % 1)
		_cc.TintColor = Color3.new(1, 1, 1):Lerp(lerped, self._tintStrength)
	else
		local v = p * self._colorSpeed % 1
		local v2 = self._tintSatMin + math.abs((math.sin(p * self._tintSatFreq))) * self._tintSatAmp
		_cc.TintColor = Color3.fromHSV(v, v2, 1)
	end

	_cc.Saturation = self._satCenter + math.sin(p * self._satFreq) * self._satAmp
	_cc.Brightness = self._brightBase + math.abs((math.sin(p * self._brightFreq))) * self._brightAmp
end

return CCPulse