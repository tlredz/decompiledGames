local Currency = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.FastSignal)

function Currency.Robux(p: number)
	return (math.max(5, math.round(p * 200 / 100 / 5) * 5))
end

function Currency.Generator(p: number)
	return function(p2: number)
		return (math.round(Currency.Robux(p2) * p * 1))
	end
end

return Currency