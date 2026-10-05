local RunService = game:GetService("RunService")
return {
	PRODUCTS = {
		{
			ProductId = RunService:IsStudio() and 3596338661 or 3596237547,
			Time = 600,
			Rewardable = true
		},
		{
			ProductId = 3596237820,
			Time = 1800,
			Rewardable = false
		},
		{
			ProductId = 3596238092,
			Time = 3600,
			Rewardable = false
		}
	},
	GetRewardableProducts = function(p)
		local result = {}

		for _, v in ipairs(p.PRODUCTS) do
			if v.Rewardable then
				table.insert(result, v)
			end
		end

		return result
	end
}