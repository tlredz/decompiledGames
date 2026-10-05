local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterBackpack = require(script:WaitForChild("CharacterBackpack"))
local NexusVRBackpack = {}
NexusVRBackpack.Enabled = true

function NexusVRBackpack:CreateBackpack()
	if self.CurrentBackpack then
		self.CurrentBackpack:Destroy()
		self.CurrentBackpack = nil
	end

	if not Players.LocalPlayer.Character then
		return
	end

	local currentBackpack = CharacterBackpack.new(Players.LocalPlayer.Character)
	currentBackpack.Enabled = self.Enabled

	if self.OverrideKeyCode then
		currentBackpack:SetKeyCode(self.OverrideKeyCode)
	end

	if self.OverrideUserCFrame then
		currentBackpack:SetUserCFrame(self.OverrideUserCFrame)
	end

	self.CurrentBackpack = currentBackpack
end

function NexusVRBackpack:Load()
	Players.LocalPlayer.CharacterAdded:Connect(function()
		self:CreateBackpack()
	end)
	self:CreateBackpack()
	task.spawn(function()
		local NexusVRCharacterModel = require(ReplicatedStorage:WaitForChild("NexusVRCharacterModel", 1e99))

		if not NexusVRCharacterModel.Api then
			warn("Nexus VR Character Model is loaded by no API is found. This was added in V.2.4.0. Inputs on the right controller won't be disabled when interacting with the backpack.")
			return
		end

		CharacterBackpack.NexusVRCharacterModelControllerApi = NexusVRCharacterModel.Api:WaitFor("Controller")
		NexusVRCharacterModel.Api:Register("Backpack", {
			GetBackpackEnabled = function(_)
				return self:GetBackpackEnabled()
			end,
			SetBackpackEnabled = function(_, flag: boolean)
				self:SetBackpackEnabled(flag)
			end,
			SetKeyCode = function(_, p)
				self:SetKeyCode(p)
			end,
			SetUserCFrame = function(_, p)
				self:SetUserCFrame(p)
			end
		})
	end)
end

function NexusVRBackpack:GetBackpackEnabled()
	return self.Enabled
end

function NexusVRBackpack:SetBackpackEnabled(flag: boolean)
	self.Enabled = flag ~= false

	if self.CurrentBackpack then
		self.CurrentBackpack.Enabled = self.Enabled

		if not self.Enabled then
			self.CurrentBackpack:Close()
		end
	end
end

function NexusVRBackpack:SetKeyCode(overrideKeyCode)
	self.OverrideKeyCode = overrideKeyCode

	if self.CurrentBackpack then
		self.CurrentBackpack:SetKeyCode(overrideKeyCode or Enum.KeyCode.ButtonR3)
	end
end

function NexusVRBackpack:SetUserCFrame(overrideUserCFrame)
	self.OverrideUserCFrame = overrideUserCFrame

	if self.CurrentBackpack then
		self.CurrentBackpack:SetUserCFrame(overrideUserCFrame or Enum.UserCFrame.RightHand)
	end
end

return NexusVRBackpack