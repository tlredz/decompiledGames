game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Icon = require(ReplicatedStorage.Modules.Icon)
local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))
local localPlayer = game.Players.LocalPlayer
local success, result = pcall(function()
	return localPlayer:GetRankInGroup(15109848)
end)

if not success or result ~= 35 and result < 100 then
	return
end

local v = Icon.new()
v:setLabel("Admin")
v:setLeft()
v:setOrder(10000)
v:oneClick()
v:bindEvent("deselected", function()
	CmdrClient:Show()
end)