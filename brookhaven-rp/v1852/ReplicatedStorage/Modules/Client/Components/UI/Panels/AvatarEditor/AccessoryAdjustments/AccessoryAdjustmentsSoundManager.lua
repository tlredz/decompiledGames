local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AccessoryAdjustmentsSoundManager"
})
v.SOUNDS = {}
v.SOUNDS.MOVE_OR_RESIZE = "MoveOrResize"
v.SOUNDS.ROTATE = "Rotate"
v.SOUNDS.COLOR_PICKER = "Color"

function v:PlaySound(p: string, _: number)
	self._soundPlaybackGeneration = (self._soundPlaybackGeneration or 0) + 1
	local _sound = self._sounds[p]

	if _sound == nil then
		warn("AccessoryAdjustmentsSoundManager: Sound not found")
		return
	end

	local _soundBaseVolume = self._soundBaseVolumes[p]

	if _soundBaseVolume ~= nil then
		_sound.Volume = _soundBaseVolume
	end

	_sound:Stop()
	_sound.TimePosition = 0
	_sound:Play()
end

function v:PlaySoundDragPreview(p: string, _: number)
	self._soundPlaybackGeneration = (self._soundPlaybackGeneration or 0) + 1
	local _soundPlaybackGeneration = self._soundPlaybackGeneration
	local _sound = self._sounds[p]

	if _sound == nil then
		warn("AccessoryAdjustmentsSoundManager: Sound not found")
		return
	end

	_sound.Volume = (self._soundBaseVolumes[p] or _sound.Volume) * 8
	_sound:Stop()
	_sound.TimePosition = 0
	_sound:Play()
	task.delay(0.04, function()
		if self._soundPlaybackGeneration == _soundPlaybackGeneration then
			_sound:Stop()
		end
	end)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._soundPlaybackGeneration = 0
	self._sounds = {}
	self._soundBaseVolumes = {}

	for _, sound in self.Instance:GetChildren() do
		if not sound:IsA("Sound") then
			continue
		end

		self._sounds[sound.Name] = sound
		self._soundBaseVolumes[sound.Name] = sound.Volume
	end
end

function v.Start(_) end

function v:Stop()
	self._soundPlaybackGeneration = (self._soundPlaybackGeneration or 0) + 1
	self._Janitor:Destroy()
end

return v