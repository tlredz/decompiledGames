local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Common.RewardInfo)
return {
	Items = {},
	SpinTable = function(items, p)
		local total = 0

		for _, item in items do
			total += item.Probability
		end

		local v = Random.new(p):NextNumber() * total
		local total2 = 0

		for k, item in items do
			total2 += item.Probability

			if v <= total2 then
				return k, item
			end
		end

		return nil
	end
}