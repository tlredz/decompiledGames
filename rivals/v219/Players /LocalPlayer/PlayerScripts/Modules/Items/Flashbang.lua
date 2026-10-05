local Players = game:GetService("Players")
local FlashbangEffect = require(Players.LocalPlayer.PlayerScripts.Modules.Functions.FlashbangEffect)
local Throwable = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Throwable)
local object = setmetatable({}, Throwable)
object.__index = object

function object.new(...)
	local self = setmetatable(Throwable.new(...), object)
	self._play_flash_sound_callback = nil
	self._play_ringing_sound_callback = nil
	self:_Init()
	return self
end

function object:ReplicateFromServer(p, ...)
	if p ~= "BlindEffect" then
		Throwable.ReplicateFromServer(self, p, ...)
		return
	end

	if not self:IsRendered() then
		return
	end

	local v, v2 = ...
	FlashbangEffect(
		{ v2 },
		v,
		self.Info.BlindDuration,
		self:Get("ObjectID"),
		self.ViewModel.Name,
		self._play_flash_sound_callback,
		self._play_ringing_sound_callback
	)
end

function object:_Setup()
	function self._play_flash_sound_callback(p2)
		return self.ViewModel:PlayFlashSound(p2)
	end

	function self._play_ringing_sound_callback(p2)
		return self.ViewModel:PlayRingingSound(p2)
	end
end

function object:_Init()
	self:_Setup()
end

return object