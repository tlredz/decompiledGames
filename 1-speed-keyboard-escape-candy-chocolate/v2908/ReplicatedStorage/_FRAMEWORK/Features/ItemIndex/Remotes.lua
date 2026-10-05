local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)

local function isEverOwnedTiers(items)
	if type(items) ~= "table" then
		return false
	end

	for k, item in pairs(items) do
		if type(k) ~= "string" or type(item) ~= "number" then
			return false
		end
	end

	return true
end

return remo.createRemotes({
	itemIndex = remo.namespace({
		requestState = remo.remote().middleware(remo.throttleMiddleware(0.5)),
		stateUpdate = remo.remote(isEverOwnedTiers)
	})
}).itemIndex