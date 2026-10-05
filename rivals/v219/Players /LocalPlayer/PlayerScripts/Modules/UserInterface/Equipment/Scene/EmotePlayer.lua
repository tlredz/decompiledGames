local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local emotes = ReplicatedStorage.Modules.Emotes
local EmotePlayer = {}
EmotePlayer.__index = EmotePlayer

function EmotePlayer.new(scene)
	local self = setmetatable({}, EmotePlayer)
	self.Scene = scene
	self._playing_hash = 0
	self._last_rig = nil
	self._last_emote = nil
	self:_Init()
	return self
end

function EmotePlayer:OnCustomizingStateChanged()
	task.defer(self._StartPlaying, self)
end

function EmotePlayer:OnStateChanged()
	task.defer(self._StartPlaying, self)
end

function EmotePlayer:_StartPlaying()
	self._playing_hash += 1
	local _playing_hash = self._playing_hash

	if self._last_rig then
		self._last_rig:Destroy()
		self._last_rig = nil
	end

	if self._last_emote then
		self._last_emote:Destroy()
		self._last_emote = nil
	end

	local selectedCosmetic = self.Scene.Equipment:GetSelectedCosmetic()
	local customizingType = self.Scene.Equipment:GetCustomizingType()
	local cosmetic = CosmeticLibrary.Cosmetics[selectedCosmetic]

	if customizingType ~= "Emote" or not cosmetic then
		return
	end

	while true do
		self._last_rig = FighterController:GenerateCharacterModel(Players.LocalPlayer.UserId).Template:Clone()
		self._last_rig:PivotTo(self.Scene:GetHumanoidCFrame() * cosmetic.ViewportCFrameOffset)
		self._last_rig.HumanoidRootPart.Anchored = true
		self._last_rig.Humanoid:SetAttribute("SimulateMoving", true)
		self._last_rig.Parent = self.Scene.Model
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://507766388"
		local success, result = pcall(self._last_rig.Humanoid.LoadAnimation, self._last_rig.Humanoid, animation)

		if success then
			result:Play(0)
		end

		local module = require(emotes[selectedCosmetic])
		self._last_emote = module.new(self._last_rig.Humanoid)
		task.defer(self._last_emote.Simulate, self._last_emote)
		self._last_emote.Destroying:Wait()

		if self._playing_hash ~= _playing_hash then
			break
		end

		if self._last_rig then
			self._last_rig:Destroy()
			self._last_rig = nil
		end

		if not self._last_emote then
			continue
		end

		self._last_emote:Destroy()
		self._last_emote = nil
	end
end

function EmotePlayer:_Init() end

return EmotePlayer