local PingUtil = {}
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local Client = not isServer and require(game.Players.LocalPlayer.PlayerScripts.Client)
local Server = isServer and require(game.ServerScriptService.Server)
local v = Client or Server

function PingUtil.GetPingMessage(data, p)
	local pingTree = data.PingTree or PingUtil.GetPingTree(data.Model)
	local pingNumber = data.PingNumber or 1
	local v2 = string.split(pingTree, ":")
	local v3 = nil

	for i = #v2, 1, -1 do
		local v4 = v2[1]

		if i >= 2 then
			for i2 = 2, i do
				v4 ..= ":" .. v2[i2]
			end
		end

		if not v.Databases.PingDatabase[v4] then
			continue
		end

		v3 = v.Databases.PingDatabase[v4][pingNumber]
		break
	end

	if type(v3) == "function" then
		v3 = v3(data.Model, p, data)
	end

	return v3, pingTree
end

local v2 = {
	Item = true,
	Tool = true,
	Armour = true,
	Currency = true,
	TNT = true
}

function PingUtil.GetPingTree(instance)
	if instance == nil then
		return "Ground"
	end

	local interaction = instance:GetAttribute("Interaction")

	if interaction and v2[interaction] then
		return "Item:" .. instance.Name
	end

	if instance:GetAttribute("Interaction") == "ItemChest" then
		return "Chest:" .. instance.Name
	end

	if instance:GetAttribute("PingId") then
		return instance:GetAttribute("PingId")
	end

	if instance:HasTag("NPC") then
		return "NPC:" .. instance.Name
	end
end

return PingUtil