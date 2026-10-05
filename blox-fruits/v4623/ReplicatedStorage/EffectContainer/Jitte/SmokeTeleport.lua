game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map
local debris = Util.Debris

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local _ = { TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In) }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(p)
	local prevPos = p.PrevPos
	local newPos = p.NewPos

	if (workspace.CurrentCamera.CFrame.Position - newPos.Position).magnitude > 600 then
		return
	end

	local v = true

	for i = 1, 2 do
		local cFrame2 = i == 1 and newPos or prevPos
		Util.Sound:Play(i == 1 and "SmokeCharge" or "SmokeBallAppear", cFrame2, 10)
		local clone = script.Teleport:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin
		debris:AddItem(clone, 3)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone2 = script.SpinSmoke:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame2
		clone2.Parent = _WorldOrigin
		debris:AddItem(clone2, 5)
		task.spawn(function()
			local cFrame = clone2.CFrame
			local children = clone2:GetChildren()
			local v4 = #children
			local lastTime = tick()

			while tick() - lastTime < 0.8 and v do
				local v5 = (tick() - lastTime) / 0.8

				for k, v6 in pairs(children) do
					local v7 = k / v4 * 3.141592653589793 * 2
					v6.WorldCFrame = cFrame * CFrame.Angles(0, v7 + v5 * 3.141592653589793 * 2 * 0.8, 0) * CFrame.new(
						0,
						0,
						-v5 * 24
					)
				end

				task.wait()
			end
		end)
		local folder = clone2
		task.delay(0.8, function()
			v = false

			for i2, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end
end