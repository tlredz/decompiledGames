game:GetService("RunService")
game:GetService("ReplicatedStorage")
local v = {}
local animation = Instance.new("Animation")
animation.AnimationId = "http://www.roblox.com/asset/?id=16808417364"
animation.Parent = script
local DroneController = {}

function DroneController.Start(_)
	workspace.Drones.ChildAdded:Connect(function(child)
		DroneController:DroneCreated(child)
	end)

	for _, child in ipairs(workspace.Drones:GetChildren()) do
		DroneController:DroneCreated(child)
	end
end

function DroneController:DroneCreated(instance)
	DroneController:RegisterAnimation(instance, animation, function(object)
		object.Priority = Enum.AnimationPriority.Action4
		object.Looped = true
		object:Play()
	end)
	instance.Destroying:Once(function()
		local v2 = v[instance]

		if not v2 then
			return
		end

		for _, v3 in ipairs(v2) do
			v3:Destroy()
		end

		table.clear(v2)
		v[instance] = nil
	end)
end

function DroneController:RegisterAnimation(instance, _, callback)
	local animationController = instance:WaitForChild("AnimationController")
	local tracks = v[instance]

	if tracks == nil then
		v[instance] = {}
		tracks = v[instance]
	end

	local track = animationController:LoadAnimation(animation)

	if callback then
		task.spawn(callback, track)
	end

	table.insert(tracks, track)
	return track
end

return DroneController