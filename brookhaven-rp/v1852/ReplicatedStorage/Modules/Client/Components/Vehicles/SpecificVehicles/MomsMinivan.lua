local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "MomsMinivan"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local vehicleAnimations = p.Instance:WaitForChild("VehicleAnimations", 10)

	if vehicleAnimations == nil then
		return
	end

	local animations = {}

	for _, animation in vehicleAnimations:GetChildren() do
		if animation:IsA("Animation") then
			table.insert(animations, animation)
		end
	end

	if #animations == 0 then
		return
	end

	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(animations)
		end)
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v