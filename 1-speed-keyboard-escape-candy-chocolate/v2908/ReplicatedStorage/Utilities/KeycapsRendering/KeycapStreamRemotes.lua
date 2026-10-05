local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)

local function isBuffer(p)
	return typeof(p) == "buffer"
end

return remo.createRemotes({
	RequestStream = remo.remote(),
	Reset = remo.remote(),
	Batch = remo.remote(isBuffer),
	Done = remo.remote(),
	DeltaAdd = remo.remote(isBuffer),
	DeltaRemove = remo.remote(isBuffer)
})