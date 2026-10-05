local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local ProximityPromptShared = require(ReplicatedStorage.Modules.Client.Interactables.ProximityPromptShared)
local v = Component.new({
	Tag = "PetTriceratopsPrompt"
})
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
	self._interactionPrompt = nil
	self._animationPlaying = nil
	self._client2ClientAccept = nil
end

function v:_CanLocalPlayerPet()
	if self.Instance:GetAttribute("InteractionDisabled") == true then
		return false
	end

	local character = localPlayer.Character

	if not (character ~= nil and character:GetAttribute("DinosaurPetting") ~= true) then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid == nil or humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return false
	end

	local _animationPlaying = self._animationPlaying
	local _client2ClientAccept = self._client2ClientAccept

	if _animationPlaying == nil or _client2ClientAccept == nil or ProximityPromptShared.canSelectPrompt({
		character = character,
		humanoid = humanoid,
		humanoidRootPart = humanoidRootPart,
		instance = self.Instance,
		client2ClientAccept = _client2ClientAccept,
		animationPlaying = _animationPlaying,
		localPlayer = localPlayer
	}) == false then
		return false
	end

	return not EmotesController.IsPlayingEmote() and not EmotesController.HasExternalCancelHandler()
end

function v:_UpdateLocalAvailability()
	local _interactionPrompt = self._interactionPrompt

	if _interactionPrompt == nil then
		return
	end

	_interactionPrompt:SetEnabled(self:_CanLocalPlayerPet())
end

function v:_BindCharacter(object2)
	local maid = Janitor.new()
	self._Janitor:Add(maid, "Destroy", "Character")
	maid:Add(object2:GetAttributeChangedSignal("DinosaurPetting"):Connect(function()
		self:_UpdateLocalAvailability()
	end))
	self:_UpdateLocalAvailability()
end

function v:Start()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	self._client2ClientAccept = playerGui:WaitForChild("MainGUIHandler"):WaitForChild("Client2Client"):WaitForChild("Client2ClientAccept")
	self._animationPlaying = playerGui:WaitForChild("Player8Handler"):WaitForChild("AnimationPlaying")
	self._Janitor:AddPromise(InteractionPrompt:WaitForInstance(self.Instance):andThen(function(interactionPrompt)
		self._interactionPrompt = interactionPrompt
		self:_UpdateLocalAvailability()
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("InteractionDisabled"):Connect(function()
		self:_UpdateLocalAvailability()
	end))
	self._Janitor:Add(self._animationPlaying:GetPropertyChangedSignal("Value"):Connect(function()
		self:_UpdateLocalAvailability()
	end))
	self._Janitor:Add(ProximityPromptShared.connectUpdate(function()
		self:_UpdateLocalAvailability()
	end))

	if localPlayer.Character ~= nil then
		self:_BindCharacter(localPlayer.Character)
	end

	self._Janitor:Add(localPlayer.CharacterAdded:Connect(function(character)
		self:_BindCharacter(character)
	end))
end

function v:Stop()
	if self._interactionPrompt ~= nil then
		self._interactionPrompt:SetEnabled(true)
	end

	self._Janitor:Destroy()
end

return v