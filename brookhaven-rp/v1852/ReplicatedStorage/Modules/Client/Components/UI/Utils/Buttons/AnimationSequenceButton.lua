local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local AnimationSequenceable = require(ReplicatedStorage.Modules.Client.Components.Tools.Animation.AnimationSequenceable)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local DontRunUnderStarterGear = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.DontRunUnderStarterGear)
local v = Component.new({
	Tag = "AnimationSequenceButton",
	Extensions = { DontRunUnderStarterGear }
})
v.__index = v
local Interface = require(ReplicatedStorage.Modules.Shared.Utils.Interface)

function v:CycleNextAnimation()
	if self.animationSequence then
		self.animationSequence:CycleNextAnimation()
	end
end

function v:UpdateSequenceNumber()
	if self.animationSequence then
		local currentAnimation = self.animationSequence:GetCurrentAnimation()
		self.sequenceNumber.Text = tostring(currentAnimation or 1)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	local toolReference = self.Instance:FindFirstAncestorOfClass("ScreenGui"):WaitForChild("ToolReference")

	if toolReference:GetAttribute("Component") == nil then
		toolReference:SetAttribute("Component", "LinearAnimationSequence")
	end

	self.animationSequence = Interface.GetImplementation(toolReference, AnimationSequenceable)
end

function v:Start()
	local button = self.Instance:WaitForChild("MainOpen"):WaitForChild("Button")
	self.sequenceNumber = button:WaitForChild("SequenceNumber")

	if self.animationSequence then
		self._Janitor:Add(self.animationSequence.OnAnimationNumberUpdated:Connect(function()
			self:UpdateSequenceNumber()
		end))
	end

	self._Janitor:Add(button.Activated:Connect(function()
		self:CycleNextAnimation()
	end))
	self._Janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonX then
			self:CycleNextAnimation()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v