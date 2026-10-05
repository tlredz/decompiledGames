local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "GhostCharacterControls"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local GhostCharacter = require(ReplicatedStorage.Modules.Client.Components.CharacterEffects.GhostCharacter)
	local character = Players.LocalPlayer.Character

	if not character then
		self.Instance:Destroy()
		return
	end

	local expect = GhostCharacter:WaitForInstance(character):expect()
	self.ghostCharacter = expect
	print("Ghost character", expect)
	self.jumpscareButton = self.Instance:WaitForChild("Jumpscare")
	self.normalExitButton = self.Instance:WaitForChild("NormalExit")
end

function v:Start()
	self._Janitor:Add(self.jumpscareButton.Activated:Connect(function()
		print("Jumpscare sending")
		self.ghostCharacter:SendToServerJumpscareGhost()
	end))
	self._Janitor:Add(self.normalExitButton.Activated:Connect(function()
		print("Normal exit sending")
		self.ghostCharacter:SendToServerNormalExit()
	end))
end

function v:Stop()
	self.ghostCharacter = nil
	self._Janitor:Destroy()
end

return v