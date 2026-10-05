game:GetService("ReplicatedStorage")
local Timer = require(script.Parent.Timer)
local v = Timer.new(0.05)
local v2 = {}
v.Tick:Connect(function()
	local now = os.clock()

	for k, v3 in v2 do
		if v3 ~= true and v3 <= now then
			v2[k] = nil
		end
	end
end)
v:Start()
return function(p, p2)
	if v2[p] and (v2[p] == true or v2[p] > os.clock()) then
		if v2[p] == true and p2 ~= true then
			v2[p] = os.clock() + p2
		end

		return true
	elseif p2 == true then
		v2[p] = true
	else
		v2[p] = os.clock() + p2
	end
end