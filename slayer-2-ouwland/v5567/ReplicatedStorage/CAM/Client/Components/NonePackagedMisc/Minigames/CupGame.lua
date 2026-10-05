local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
return function(_, options)
	local v = options or {}
	local _ = v.Stop
	local v2 = v.Thread and v.Thread:Extend() or faye.new()
	return function()
		v2:Destroy()
	end
end