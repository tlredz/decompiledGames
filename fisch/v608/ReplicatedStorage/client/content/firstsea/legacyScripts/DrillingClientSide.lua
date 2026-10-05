local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local events = ReplicatedStorage:WaitForChild("events")
workspace.world.map:WaitForChild("Forsaken Shores"):WaitForChild("Actives")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local _ = Players.LocalPlayer
legacyLocalPlayerData.fetch():WaitForChild("AtlantisQuest")
local cFramesByInstance = {}
events.DamageRock.OnClientEvent:Connect(function(instance)
	if not (instance and instance.Parent) then
		return
	end

	if not cFramesByInstance[instance] then
		cFramesByInstance[instance] = instance.CFrame
	end

	if instance.Parent:GetAttribute("Health") <= 0 then
		return
	end

	local highlight = Instance.new("Highlight", instance.Parent)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(85, 0, 0)
	highlight.FillTransparency = 0
	highlight.OutlineTransparency = 0
	Random.new():NextNumber(-0.5, 0.5)
	Random.new():NextNumber(-0.5, 0.5)
	instance.CFrame = cFramesByInstance[instance] * CFrame.new(0.5, 0, 0.5)
	local v = {
		CFrame = cFramesByInstance[instance]
	}
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
	local tween = TweenService:Create(highlight, tweenInfo, {
		FillTransparency = 1,
		OutlineTransparency = 1
	})
	local tween2 = TweenService:Create(instance, tweenInfo2, v)
	tween:Play()
	tween2:Play()
	task.spawn(function()
		wait(tweenInfo2.Time)

		if highlight and highlight.Parent then
			highlight.Enabled = false
			highlight:Destroy()
		end

		if instance and instance.Parent then
			if instance.Parent:GetAttribute("Health") <= 0 then
				return
			else
				instance.CFrame = cFramesByInstance[instance]
			end
		end
	end)
end)