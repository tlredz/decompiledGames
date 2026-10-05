local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)

local function listingNames()
	local result = {}

	for k, v in Shop.itemsforsale do
		if v ~= nil and v.Type ~= Menum.ShopItemType.Gamepass then
			table.insert(result, k)
		end
	end

	table.sort(result)
	return result
end

return {
	Clearance = 7,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Listing",
			Name = "Listing",
			Required = true,
			Suggester = function()
				return (listingNames())
			end,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				local lower = value:lower()

				for _, v in listingNames() do
					if v:lower() == lower then
						return v
					end
				end

				return nil
			end
		}
	},
	Server = function(p, list, p2: string)
		if #list == 0 then
			error("Grant: no players targeted (use `me`)")
		end

		local v = Shop.itemsforsale[p2]

		if v == nil then
			error((`Grant: no shop listing named "{p2}"`))
		end

		if v.Type == Menum.ShopItemType.Gamepass then
			error((`Grant: "{p2}" is a gamepass -- owning it on Roblox IS the grant, so it cannot be handed out here`))
		end

		local orderProcesser = Shop.OrderProcessers[v.Type]

		if orderProcesser == nil then
			error((`Grant: "{p2}" has no order processor for type "{tostring(v.Type)}"`))
		end

		local names = {}
		local v2 = {}

		for _, v3 in list do
			local data = Utility.GetData(v3)

			if data == nil then
				table.insert(v2, (`{v3.Name} (data not loaded)`))
			else
				local success, result, v4 = pcall(orderProcesser, v3, data, p2, 1, v)

				if success and result then
					table.insert(names, v3.Name)
				else
					local name = v3.Name

					if success then
						result = v4
					end

					table.insert(v2, (`{name} ({tostring(result)})`))
				end
			end
		end

		if #names == 0 then
			error((`Grant: nothing granted -- {table.concat(v2, ", ")}`))
		end

		warn((`[Grant] {p.Name} granted "{p2}" to {table.concat(names, ", ")}`))
		return {
			Content = `Granted "{p2}" to {table.concat(names, ", ")}` .. (not (#v2 > 0) and "" or ` (failed: {table.concat(v2, ", ")})`),
			BgColor = Color3.fromRGB(32, 143, 70),
			FgColor = Color3.new(1, 1, 1)
		}
	end
}