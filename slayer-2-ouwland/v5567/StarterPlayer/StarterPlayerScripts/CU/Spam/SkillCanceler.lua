local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)

if not RunService:IsStudio() then
	return
end

local playerGui = Players.LocalPlayer.PlayerGui
local cancelSkillIndicator = script.CancelSkillIndicator
cancelSkillIndicator.Parent = playerGui
cancelSkillIndicator.ResetOnSpawn = false
cancelSkillIndicator.TextLabel.TextTransparency = 1
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local v = nil
local thread = nil
ContextActionService:BindActionAtPriority("CancelSkill", function(p, p2, _)
	if p ~= "CancelSkill" or p2 ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	SignalEvent.ToServer("CancelSkill")

	if v then
		v:Pause()
		v:Destroy()
	end

	cancelSkillIndicator.TextLabel.TextTransparency = 0

	if thread then
		task.cancel(thread)
	end

	thread = task.delay(0.1, function()
		v = TweenService:Create(cancelSkillIndicator.TextLabel, tweenInfo, {
			TextTransparency = 1
		})
		v:Play()
	end)
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.T)