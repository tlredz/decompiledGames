local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local v = {}
Observers.observeTag("ScrollingTexture", function(instance)
	local v2 = {
		texture = instance,
		initial = instance.OffsetStudsV,
		speed = instance:GetAttribute("ScrollSpeed") or 10,
		direction = instance:GetAttribute("Direction") or 1,
		start = time()
	}
	table.insert(v, v2)
	local scrollSpeedChangedConnection = instance:GetAttributeChangedSignal("ScrollSpeed"):Connect(function()
		v2.speed = instance:GetAttribute("ScrollSpeed")
	end)
	local directionChangedConnection = instance:GetAttributeChangedSignal("Direction"):Connect(function()
		v2.direction = instance:GetAttribute("Direction")
	end)
	return function()
		scrollSpeedChangedConnection:Disconnect()
		directionChangedConnection:Disconnect()
		local index = table.find(v, v2)

		if index then
			table.remove(v, index)
		end
	end
end)
RunService.RenderStepped:Connect(function()
	local v2 = time()

	for _, v3 in v do
		local offsetStudsV = v3.initial + (v2 - v3.start) * v3.speed * v3.direction
		v3.texture.OffsetStudsV = offsetStudsV
	end
end)