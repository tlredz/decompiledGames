local createVector = vector.create
local class = {}
class.__index = class
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Director"))
local HalloweenTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.HalloweenTransitionEffect)
local cframe = CFrame.new(0, -30, 0)
local localPlayer = Players.LocalPlayer

function class:Init()
	if self.Instance:GetAttribute("InitialSetUp") == nil then
		self.Instance:SetAttribute("InitialSetUp", true)
		self.Instance.PrimaryPart = self.Instance:WaitForChild("comm", 5)
		assert(self.Instance.PrimaryPart, "bad portal primaryPart")

		if not self.Instance.PrimaryPart then
			self.Instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
		end

		local primaryPart = self.Instance.PrimaryPart
		self.Instance:SetAttribute("InitialCFrame", primaryPart.CFrame)

		for _, part in self.Instance:GetDescendants() do
			if not (part:IsA("BasePart") and part ~= primaryPart) then
				continue
			end

			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = primaryPart
			weldConstraint.Part1 = part
			weldConstraint.Parent = part
			part.Anchored = false
		end
	end

	self:SetVisibility((self.Instance:GetAttribute("Enabled")))
	self.UpdateThread = task.spawn(function()
		while true do
			if self.Visible and ((localPlayer.Character and localPlayer.Character:GetPivot().Position or createVector(
				0,
				0,
				0
			)) - self.Instance:GetPivot().Position).Magnitude <= 9 then
				local GatewayController = require(game.Players.LocalPlayer.PlayerGui.Main.Gateway.GatewayController)
				local v = ReplicatedStorage.Remotes.HalloweenPortal:InvokeServer("a")
				local priceListAndAwaitSelection = GatewayController.LoadPriceListAndAwaitSelection(v, {}, "PORTAL")

				if priceListAndAwaitSelection then
					HalloweenTransitionEffect.Play()
					task.wait(1)
					ReplicatedStorage.Remotes.HalloweenPortal:InvokeServer("b", priceListAndAwaitSelection)
					task.wait(1)
					HalloweenTransitionEffect.StopEarly()
				end
			end

			task.wait(0.2)
		end
	end)
	self.ChangedConnection = self.Instance:GetAttributeChangedSignal("Enabled"):Connect(function()
		self:SetVisibility((self.Instance:GetAttribute("Enabled")))
	end)
end

function class:Destroy()
	if self.UpdateThread then
		task.cancel(self.UpdateThread)
		self.UpdateThread = nil
	end

	if self.ChangedConnection then
		self.ChangedConnection:Disconnect()
		self.ChangedConnection = nil
	end
end

function class:SetVisibility(visible: boolean)
	self.Visible = visible
	local initialCFrame = self.Instance:GetAttribute("InitialCFrame")

	if initialCFrame then
		local cFrame = initialCFrame * (visible and CFrame.identity or cframe)
		self.Instance.PrimaryPart = self.Instance:WaitForChild("comm", 5)
		assert(self.Instance.PrimaryPart, "bad portal primaryPart")
		local tween = TweenService:Create(
			self.Instance.PrimaryPart,
			TweenInfo.new(2, Enum.EasingStyle.Back, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In),
			{
				CFrame = cFrame
			}
		)
		tween:Play()
		task.delay(tween.TweenInfo.Time, tween.Destroy, tween)
	end
end

return {
	new = function(instance, _)
		return (setmetatable({
			Instance = instance,
			Visible = false
		}, class))
	end,
	ancestor = nil
}