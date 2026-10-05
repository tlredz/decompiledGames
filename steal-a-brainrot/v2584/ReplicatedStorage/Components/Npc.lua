local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local DialogController = require(controllers.DialogController)
local utils = ReplicatedStorage:WaitForChild("Utils")
local StringUtils = require(utils.StringUtils)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "Npc"
})

function v:Construct()
	self.Collector = Trove.new()
	self.Hightlight = Instance.new("Highlight")
	self.Hightlight.FillTransparency = 1
	self.Hightlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	self.Hightlight.OutlineTransparency = 1
	self.Hightlight.DepthMode = Enum.HighlightDepthMode.Occluded
	self.Hightlight.Parent = self.Instance
	self.ProximityPrompt = Instance.new("ProximityPrompt", self.Instance)
	self.ProximityPrompt.ActionText = "Talk"
	self.ProximityPrompt.ObjectText = self.Instance:GetAttribute("PromptObjectText") or ""
	self.ShownTween = TweenService:Create(self.Hightlight, tweenInfo, {
		OutlineTransparency = 0
	})
	self.HiddenTween = TweenService:Create(self.Hightlight, tweenInfo, {
		OutlineTransparency = 1
	})
	self.DialogText = DialogController:GetDialogText()
	self.DialogText.Parent = self.Instance.PrimaryPart

	if self.Instance:GetAttribute("IdlePath") then
		local path = StringUtils:ReadPath(ReplicatedStorage, self.Instance:GetAttribute("IdlePath"))
		local track = self.Instance:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(path)
		track.Looped = true
		track:Play()
	end
end

function v.Start(data)
	data.Collector:Add(data.ProximityPrompt.Triggered:Connect(function()
		DialogController:StartDialog(
			data.Instance:GetAttribute("Dialog"),
			data.Instance:GetAttribute("Index"),
			data.DialogText
		)
	end))
	data.Collector:Add(data.ProximityPrompt.PromptShown:Connect(function()
		data.ShownTween:Play()
	end))
	data.Collector:Add(data.ProximityPrompt.PromptHidden:Connect(function()
		data.HiddenTween:Play()
	end))
end

function v.Stop(p)
	p.Collector:Destroy()
end

return v