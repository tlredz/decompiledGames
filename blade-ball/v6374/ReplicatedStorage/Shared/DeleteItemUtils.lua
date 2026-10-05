local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v = require3(ReplicatedStorage2.Shared.Inventory.Internal.DefaultItems)
local v2 = require3(ReplicatedStorage2.ServerInfo)
return {
	IsDeleteable = function(_, p, p2)
		if p ~= "Explosion" and p ~= "Sword" and p ~= "Emote" then
			return false, (`You can't delete items from {p} Inventory!`)
		end

		if v2.isDuelMatchServer() then
			return false, "You can't delete items while in a duel"
		end

		local name = p2.Name
		local v3 = v[p]
		local v4

		if type(v3) == "string" then
			v4 = v3 == name
		else
			v4 = table.find(v3, name)
		end

		if v4 then
			return false, "You can't delete base items!"
		end

		if p2.TradeLock and p2.TradeLock.Type == "Listing" then
			return false, "You can't delete items listed in booths!"
		end

		if p2.TradeLock and p2.TradeLock.Type == "Date" and p2.TradeLock.IsTradeHold then
			return false, "You can't delete items that are on trade hold!"
		end

		return true
	end
}