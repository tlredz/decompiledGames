local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Server = require(ReplicatedStorage.Modules.Server)
local Items = require(ReplicatedStorage.Assets.Data.Store.Items)
local tiers = {
	T1 = {
		Id = 0,
		AdultId = 0,
		TestId = 0
	},
	T2 = {
		Id = 3602326872,
		AdultId = 0,
		TestId = 3603646263
	},
	T3 = {
		Id = 0,
		AdultId = 0,
		TestId = 0
	}
}
local toolProducts = {}

for _, v3 in next, tiers, nil do
	if Server:IsAdultServer() and v3.AdultId ~= 0 then
		v3.Id = v3.AdultId
	end

	if Server:IsTestServer() and v3.TestId and v3.TestId ~= 0 then
		v3.Id = v3.TestId
	end
end

local function getOwnershipAttribute(value: string)
	return "OwnsTool_" .. value:gsub("%W", "_")
end

for k, item in next, Items, nil do
	if not item.DevProductTool then
		continue
	end

	if item.Tier and tiers[item.Tier] then
		toolProducts[k] = {
			Display = item.Display,
			Tier = item.Tier,
			Icon = item.Icon,
			Description = item.Description
		}
	else
		warn((`[ToolProducts] "{k}" is a DevProductTool but has unknown Tier "{tostring(item.Tier)}"`))
	end
end

if RunService:IsClient() then
	task.spawn(function()
		for k, v3 in next, toolProducts, nil do
			local v4 = tiers[v3.Tier]
			local priceInRobux = nil

			if v4 then
				local v5 = v4
				local success, result = pcall(function()
					return MarketplaceService:GetProductInfo(v5.Id, Enum.InfoType.Product)
				end)

				if success then
					if result.PriceInRobux then
						priceInRobux = result.PriceInRobux
					else
						warn((`[ToolProducts] {k} (tier {v3.Tier}, id {v4.Id}) returned no PriceInRobux`))
					end
				else
					warn((`[ToolProducts] GetProductInfo failed for {k} (tier {v3.Tier}, id {v4.Id}): {tostring(result)}`))
				end
			end

			v3.Price = priceInRobux or "?"
			v3.Ready = true
		end
	end)
end

return {
	Tiers = tiers,
	ToolProducts = toolProducts,
	GetOwnershipAttribute = getOwnershipAttribute
}