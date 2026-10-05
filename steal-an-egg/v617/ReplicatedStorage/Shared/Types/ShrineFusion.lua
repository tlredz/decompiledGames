local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local strictInterface = t.strictInterface({
	TransactionId = t.string,
	EggUid = t.string,
	CompletedAt = t.number
})
local v = {
	State = t.strictInterface({
		Divine = t.union(t.literal(false), strictInterface),
		Eternal = t.union(t.literal(false), strictInterface)
	}),
	Blank = function()
		return {
			Divine = false,
			Eternal = false
		}
	end
}
return table.freeze(v)