game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerData = require(ReplicatedStorage.Datas.ServerData)

if RunService:IsStudio() then
	return
end

local parent = script.Parent
local localPlayer = Players.LocalPlayer

if not localPlayer:GetAttribute("Role") then
	localPlayer:GetAttributeChangedSignal("Role"):Wait()
end

local role = localPlayer:GetAttribute("Role")

if not table.find({ "Lead", "Tester", "Dev" }, role) then
	return
end

parent.Visible = ServerData.IsDevGame()
parent.Text = `VERSION: {game.PlaceVersion}`
local v = false
parent.Activated:Connect(function()
	v = not v
	parent.TextTransparency = v and 0 or 1
	parent.UIStroke.Transparency = v and 0 or 1
end)