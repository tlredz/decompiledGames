local function __ctr(p)
	return (table.clone(p))
end

local v = {
	DefeatEnemiesOfType = ({
		guid = "<invalid>",
		new = __ctr
	}):new()
}
return {
	new = function(self: string, guid: string?)
		if not guid then
			local HttpService = game:GetService("HttpService")
			guid = HttpService:GenerateGUID()
		end

		return (setmetatable({
			guid = guid
		}, {
			__index = v[self]
		}))
	end
}