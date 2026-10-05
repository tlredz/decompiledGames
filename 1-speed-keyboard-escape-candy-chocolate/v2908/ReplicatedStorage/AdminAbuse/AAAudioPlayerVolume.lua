local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local AAAudioPlayerVolume = {
	GetFraction = function()
		local aAMusicVolume = localPlayer:GetAttribute("AAMusicVolume")

		if type(aAMusicVolume) == "number" then
			return aAMusicVolume
		end

		return 1
	end
}

function AAAudioPlayerVolume:ApplyFrame()
	local fraction = AAAudioPlayerVolume.GetFraction()
	local _AAVolumeApplied = self:GetAttribute("_AAVolumeApplied")
	local _AAVolumeRaw = self:GetAttribute("_AAVolumeRaw")

	if _AAVolumeApplied == nil or math.abs(self.Volume - _AAVolumeApplied) > 0.001 then
		_AAVolumeRaw = self.Volume
		self:SetAttribute("_AAVolumeRaw", _AAVolumeRaw)
	elseif _AAVolumeRaw == nil then
		_AAVolumeRaw = self.Volume
	end

	local volume = _AAVolumeRaw * fraction

	if math.abs(self.Volume - volume) > 0.001 then
		self.Volume = volume
		self:SetAttribute("_AAVolumeApplied", volume)
	end
end

return AAAudioPlayerVolume