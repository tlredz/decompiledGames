require(script.Parent.Callbacks)
local Server = require(game.ReplicatedStorage.Modules.Server)
local Product = {
	CustomServer = {
		Name = "Custom Server",
		Id = 2661670116,
		AdultId = 3599813311,
		TestId = 2969604796,
		Callback = function(_)
			print("custom server!")
		end
	},
	RestoreStreak = {
		Name = "Restore Streak",
		Id = 3599812349,
		TestId = 1939831099,
		AdultId = 3599812582
	}
}
local isTestServer = Server:IsTestServer()
local isAdultServer = Server:IsAdultServer()

for _, v in pairs(Product) do
	if isTestServer then
		if v.TestId then
			v.Id = v.TestId
		end
	elseif isAdultServer then
		v.Id = v.AdultId
	end
end

local RunService = game:GetService("RunService")

if RunService:IsClient() then
	local MarketplaceService = game:GetService("MarketplaceService")
	task.spawn(function()
		for _, v in next, Product, nil do
			local v2 = v
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfo(v2.Id, Enum.InfoType.Product)
			end)

			if success then
				v.Price = result.PriceInRobux
				v.Description = result.Description
				v.Icon = result.IconImageAssetId
			end

			v.Ready = true
		end
	end)
end

return Product