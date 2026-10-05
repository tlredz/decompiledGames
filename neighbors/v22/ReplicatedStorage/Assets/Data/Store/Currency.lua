local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Money = require(ReplicatedStorage.Modules.Money)
local Server = require(ReplicatedStorage.Modules.Server)
local _ = {
	Default = "rbxassetid://78557486349455",
	Stack = "rbxassetid://96832480189393",
	MultiStack = "rbxassetid://89142057470653",
	Chest = "rbxassetid://116921089100160"
}
local Currency = {
	[25] = {
		Id = 1405161449,
		AdultId = 1658235908,
		Icon = "rbxassetid://78557486349455"
	},
	[100] = {
		Id = 1405159249,
		AdultId = 1658235787,
		Icon = "rbxassetid://78557486349455"
	},
	[350] = {
		Id = 1405159377,
		AdultId = 1658236215,
		Icon = "rbxassetid://78557486349455"
	},
	[700] = {
		Id = 1405159730,
		AdultId = 1658236499,
		Icon = "rbxassetid://96832480189393"
	},
	[1750] = {
		Id = 1405159919,
		AdultId = 1658236774,
		Icon = "rbxassetid://89142057470653"
	},
	[5000] = {
		Id = 1405160059,
		AdultId = 1658237032,
		Extra = "+15% MORE",
		Icon = "rbxassetid://116921089100160"
	}
}

if Server:IsAdultServer() then
	for _, v in Currency do
		v.Id = v.AdultId
	end
elseif Server:IsTestServer() then
	Currency[25].Id = 1550663943
end

for k, v in Currency do
	local amount = math.round(k * 1)
	v.Display = Money(amount, true) .. " Credits"
	v.Description = "Grants " .. amount .. " Credits."
	v.Amount = amount

	if not RunService:IsClient() then
		continue
	end

	local v3 = v
	task.spawn(function()
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfo(v3.Id, Enum.InfoType.Product)
		end)

		if success then
			v3.Price = result.PriceInRobux
		else
			v3.Price = "???"
		end

		v3.Ready = true
	end)
end

return Currency