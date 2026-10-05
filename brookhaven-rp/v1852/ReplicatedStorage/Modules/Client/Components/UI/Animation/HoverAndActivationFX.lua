local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local ActivationFX = require(ReplicatedStorage.Modules.Client.Components.UI.Animation.ActivationFX)
local HoverFX = require(ReplicatedStorage.Modules.Client.Components.UI.Animation.HoverFX)
local RunService = game:GetService("RunService")
local v = Component.new({
	Tag = "HoverAndActivationFX"
})

function v.Construct(_) end

function v:Start()
	assert(
		self.Instance:IsA("GuiButton"),
		"HoverAndActivationFX must be used on a GuiButton - got " .. self.Instance.ClassName .. " - Full name of instance: " .. self.Instance:GetFullName()
	)

	if self.Instance:HasTag("HoverFX") or self.Instance:HasTag("ActivationFX") then
		warn("HoverAndActivationFX should not be used alongside HoverFX or ActivationFX due to redundancy. Instance with issue:" .. self.Instance)
		self.Instance:RemoveTag("HoverFX")
		self.Instance:RemoveTag("ActivationFX")
		RunService.RenderStepped:Wait()
	end

	local tweenDescriptions, hoverEnd = HoverFX.GetTweenDescriptions(self.Instance)
	local tweenDescriptions2, _ = ActivationFX.GetTweenDescriptions(self.Instance)
	self.connections = UIAnimationEffects.ConnectButtonHoverAndActivationFX(self.Instance, self.Instance, {
		Hover = tweenDescriptions,
		HoverEnd = hoverEnd,
		Activate = tweenDescriptions2
	})
end

function v:Stop()
	if self.connections then
		for _, connection in self.connections do
			connection:Disconnect()
		end

		self.connections = nil
	end
end

return v