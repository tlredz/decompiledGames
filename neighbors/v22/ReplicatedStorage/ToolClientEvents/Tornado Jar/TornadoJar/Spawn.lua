local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Tool = require(ReplicatedStorage.Modules.Tool)
local tornadoJar = ReplicatedStorage.Assets.Tools.TornadoJar
return Tool.Event(function(_, instance)
	if not instance then
		return
	end

	local clone = tornadoJar.Tornado:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Rate = math.min(descendant.Rate, 60)
		end
	end

	local v = 0.1
	local v2 = 0
	pcall(function()
		clone:ScaleTo(v)
	end)
	clone:PivotTo(instance.CFrame)
	clone.Parent = workspace
	local lastTime = os.clock()
	local heartbeatConnection = nil

	local function shrinkAndDestroy()
		for i = 1, 3 do
			task.wait(0.1)
			local v3 = i
			pcall(function()
				clone:ScaleTo((math.max(v * (1 - v3 / 3), 0.05)))
			end)
		end

		clone:Destroy()
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if instance.Parent then
			local v3 = os.clock() - lastTime

			if v < 1 and v2 <= v3 then
				v2 = v3 + 0.15
				v = math.min(0.1 + 0.9 * (v3 / 2), 1)
				pcall(function()
					clone:ScaleTo(v)
				end)
			end

			clone:PivotTo(instance.CFrame)
		else
			heartbeatConnection:Disconnect()
			task.spawn(shrinkAndDestroy)
		end
	end)
end)