local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
return function()
	local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
	local parent = _WorldOrigin:FindFirstChild("Fireflies")

	if not (parent and parent:IsA("Model")) then
		parent = Instance.new("Model")
		parent.Name = "Fireflies"
		parent.Parent = _WorldOrigin
	end

	task.spawn(function()
		while task.wait(6) do
			if not (game.Lighting.ClockTime > 17.8 or game.Lighting.ClockTime < 5) then
				continue
			end

			local Global = require(game.ReplicatedStorage.Global)

			if Global.CurrentLocation == "Tiki Outpost" then
				continue
			end

			local Global2 = require(game.ReplicatedStorage.Global)

			if Global2.CurrentLocation == "Frozen Dimension" then
				continue
			end

			local v2 = workspace.CurrentCamera.CFrame.p + Vector3.new(math.random(-200, 200), 0, math.random(-200, 200))
			local ray = Util.Ray
			local v3 = { workspace.Enemies, workspace.Characters }
			local v4, v5, _ = ray(v2, createVector(0, -100, 0), v3)

			if not v4 then
				continue
			end

			local clone = script.Fireflies:Clone()
			clone.CFrame = CFrame.new(v5 + Vector3.new(0, math.random(1, 15), 0)) * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			clone.Size = Vector3.new(0.5 + math.random(), 0.5 + math.random(), 0.5 + math.random()) * math.random(
				30,
				75
			)
			clone.Particle.Rate = clone.Size.Y / math.random(20, 50)
			clone.Parent = parent
			task.delay(math.random(20, 40), function()
				clone.Particle.Enabled = false
				task.wait(15)
				clone:Destroy()
			end)
		end
	end)
end