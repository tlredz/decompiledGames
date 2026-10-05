require(script.Parent.Profiles)
local class = {}
class.__index = class

function class:Apply(p2, flag: boolean)
	if self._IsDestroyed then
		return
	end

	local _Sound = self._Sound
	local soundId = p2.SoundId or ""

	if _Sound.SoundId ~= soundId then
		_Sound.SoundId = soundId
	end

	_Sound.RollOffMaxDistance = 100
	_Sound.Volume = p2.Volume or 0.5
	_Sound.Playing = flag and soundId ~= ""
end

function class:Destroy()
	if self._IsDestroyed then
		return
	end

	self._IsDestroyed = true
	self._Attachment:Destroy()
end

return {
	new = function(parent)
		local attachment = Instance.new("Attachment")
		attachment.Name = "AmbienceAttachment"
		local sound = Instance.new("Sound")
		sound.Name = "Ambience"
		sound.Looped = true
		sound.RollOffMode = Enum.RollOffMode.InverseTapered
		sound.RollOffMinDistance = 15
		sound.RollOffMaxDistance = 200
		sound.Volume = 0.5
		sound.Parent = attachment
		attachment.Parent = parent
		return (setmetatable({
			_Attachment = attachment,
			_Sound = sound,
			_IsDestroyed = false
		}, class))
	end
}