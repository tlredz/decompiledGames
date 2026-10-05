require(game.ReplicatedStorage.UserGenerated.Randoms.Base)
local Xorshift128 = require(game.ReplicatedStorage.UserGenerated.Randoms.Xorshift128)
local v = {
	DefaultXorshift128 = Xorshift128.R,
	Xorshift128 = function(p)
		return Xorshift128.new(p)
	end,
	UniqueXorshift128 = function(p: number?)
		return Xorshift128.Unique(p)
	end
}
return table.freeze(v)