local Finally = require(game.ReplicatedStorage.UserGenerated.Lang.Finally)
local frozen = table.freeze({
	__index = table.freeze({
		Call = function(p, callback, ...)
			assert(type(callback) == "function")

			while p.Count > 0 do
				task.wait()
			end

			p.Count += 1
			return Finally(callback, function()
				p.Count -= 1
			end, ...)
		end,
		Try = function(p, callback, ...)
			assert(type(callback) == "function")

			if p.Count > 0 then
				return false
			end

			p.Count += 1
			return true, Finally(callback, function()
				p.Count -= 1
			end, ...)
		end,
		IsLocked = function(p)
			return p.Count > 0
		end
	})
})
return table.freeze({
	new = function()
		return (setmetatable({
			Count = 0
		}, frozen))
	end
})