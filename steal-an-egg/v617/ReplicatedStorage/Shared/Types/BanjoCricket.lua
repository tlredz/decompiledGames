local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local v = {
	State = t.strictInterface({
		Solved = t.boolean,
		Claimed = t.boolean
	}),
	Blank = function()
		return {
			Solved = false,
			Claimed = false
		}
	end
}
return table.freeze(v)