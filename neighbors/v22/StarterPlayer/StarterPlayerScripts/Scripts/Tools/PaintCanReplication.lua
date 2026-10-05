local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local Server = require(ReplicatedStorage.Modules.Server)
local Painter = require(ReplicatedStorage.Modules.Painter)
local v = Painter.new()
local localPlayer = Players.LocalPlayer
Network:listen("DrawSprayPaint", function(p)
	if localPlayer:GetAttribute("HideGraffiti") and Server:GetServerType() ~= Server.Servers.Neighborhood and Server:GetServerType() ~= Server.Servers.Night then
		return
	end

	v:DrawFromData(p)
end)
Network:listen("EraseSprayPaint", function(data)
	local result = data.Result
	v:Erase(CFrame.new(result.Position, result.Position + result.Normal), data.Size, data.Layer, data.PersonErasing)
end)
Players.PlayerRemoving:Connect(function(player)
	v:EraseAllOfPlayer(player)
end)

if Server:GetRealServerType() == Server.Servers.Neighborhood or Server:GetRealServerType() == Server.Servers.Night then
	Network:listen("ClearGraffiti", function()
		v:EraseAll()
	end)
	return
end

local v2 = Network:invoke("GetOldSprayPaint")

for _, v3 in pairs(v2) do
	for _, v4 in v3 do
		v:DrawFromData(v4)
	end
end

Players.LocalPlayer:GetAttributeChangedSignal("HideGraffiti"):Connect(function()
	if localPlayer:GetAttribute("HideGraffiti") then
		v:EraseAllBut(localPlayer)
		return
	end

	local v3 = Network:invoke("GetOldSprayPaint")

	for _, v4 in pairs(v3) do
		for _, v5 in v4 do
			if v5.Owner ~= localPlayer.UserId then
				v:DrawFromData(v5)
			end
		end
	end
end)