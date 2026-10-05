local parent = script.Parent.Parent
local RunContext = require(parent.RunContext)
local v = script:FindFirstChildOfClass("RemoteEvent")
local v2 = script:FindFirstChildOfClass("UnreliableRemoteEvent")

if not (v and v2) then
	if RunContext.IsServer or RunContext.IsEdit then
		if not v then
			v = Instance.new("RemoteEvent")
			v.Name = "Reliable"
			v.Parent = script
		end

		if not v2 then
			v2 = Instance.new("UnreliableRemoteEvent")
			v2.Name = "Unreliable"
			v2.Parent = script
		end
	else
		v = script:WaitForChild("Reliable")
		assert(v and v:IsA("RemoteEvent"), "RemoteEvent not found!")
		v2 = script:WaitForChild("Unreliable")
		assert(v2 and v2:IsA("UnreliableRemoteEvent"), "UnreliableRemoteEvent not found!")
	end
end

return table.freeze({
	Reliable = assert(v),
	Unreliable = assert(v2)
})