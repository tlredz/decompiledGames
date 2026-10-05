local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local rankInGroup

if not RunService:IsStudio() then
	rankInGroup = Players.LocalPlayer:GetRankInGroup(15109848)
end

if RunService:IsStudio() or rankInGroup and rankInGroup > 1 then
	local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))
	CmdrClient:SetActivationKeys({ Enum.KeyCode.Semicolon })
	TextChatService.SendingMessage:Connect(function(p)
		if p.Text == "!cmdr" then
			CmdrClient:Toggle()
		end
	end)
end