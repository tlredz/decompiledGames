local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Timer = require(ReplicatedStorage.Packages.Timer)
local v = {}
Timer.Simple(0.05, function()
	local now = os.clock()

	for k, v2 in v do
		if v2 <= now then
			v[k] = nil
		end
	end
end)
return function(p, p2: number?, flag: boolean?)
	if flag and p2 and v[p] then
		v[p] = os.clock() + p2
		return
	end

	if v[p] then
		return true
	end

	if not p2 then
		return
	end

	v[p] = os.clock() + p2
end