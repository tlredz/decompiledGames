local SaneDebris = {}
local v = {}
local RunService = game:GetService("RunService")
local v2 = {}
RunService.Heartbeat:Connect(function()
	debug.profilebegin("SaneDebris::Heartbeat")
	local now = tick()

	for k, v3 in v do
		if v3 <= now then
			table.insert(v2, k)
		end
	end

	for _, v3 in ipairs(v2) do
		v3:Destroy()
		v[v3] = nil
	end

	table.clear(v2)
	debug.profileend()
end)

function SaneDebris.AddItem(_, instance, value: number)
	assert(typeof(instance) == "Instance", "Argument #1 must be an Instance")
	assert(typeof(value) == "number", "Argument #2 must be a number")
	v[instance] = tick() + value
end

function SaneDebris.RemoveItem(_, instance)
	assert(typeof(instance) == "Instance", "Argument #1 must be an Instance")
	v[instance] = nil
end

return SaneDebris