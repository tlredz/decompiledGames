local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Replion)
local v = {
	Refreshes = {
		{
			Price = 24,
			ProductId = 1931179670,
			GiftProductId = 1931641291
		},
		{
			Price = 99,
			ProductId = 1931179669,
			GiftProductId = 1931641294
		},
		{
			Price = 149,
			ProductId = 1931179665,
			GiftProductId = 1931641292
		},
		{
			Price = 399,
			ProductId = 1931179667,
			GiftProductId = 1931641293
		},
		{
			Price = 599,
			ProductId = 1931179666,
			GiftProductId = 1931641295
		},
		{
			Price = 999,
			ProductId = 1931179668,
			GiftProductId = 1931641290
		}
	}
}

function v.getRefreshFor(object)
	local v2 = math.max(1, (math.min(object:Get("SpecialTrainingEventMisc.DailyRefreshes") or 1, #v.Refreshes)))
	return v.Refreshes[v2]
end

return table.freeze(v)