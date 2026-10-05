local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { workspace.Map }
local _WorldOrigin = workspace._WorldOrigin
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local Effect = require(game.ReplicatedStorage.Effect)
return function(data)
	local weak = data.Weak
	local position = data.Position
	local v = {
		Position = position
	}

	if (workspace.CurrentCamera.CFrame.p - position).Magnitude > 900 then
		return
	end

	if v then
		local v2 = math.random() * 3.141592653589793 * 2
		local clone = script.Metoerin:Clone()
		clone.Position = v.Position + createVector(0, 333, 0) + Vector3.new(math.sin(v2), 0, (math.cos(v2))) * math.random(
			200,
			400
		)
		clone.Parent = _WorldOrigin
		local cFrame = clone.CFrame
		Util.Sound:Play("SetFireLoud", cFrame)
		coroutine.wrap(function()
			for _ = 1, weak and 1 or 3 do
				local clone2 = script.ring1:Clone()
				clone2.Position = position
				clone2.Parent = _WorldOrigin
				TweenService:Create(clone2, tweenInfo, {
					Position = clone2.Position + createVector(0, 10, 0),
					Size = clone2.Size * 3.3,
					Transparency = 1
				}):Play()
				Debris:AddItem(clone2, 0.6)
				wait(0.2)
			end
		end)()
		local v3 = math.max(0.1, 1 - (workspace:GetServerTimeNow() - data.Timestamp))
		local lastTime = tick()

		while tick() - lastTime < v3 do
			clone.CFrame = CFrame.new(cFrame.Position:Lerp(v.Position, (tick() - lastTime) / v3), v.Position) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			task.wait()
		end

		local position2 = v.Position + createVector(0, 1, 0)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end

		clone:Destroy()
		local folder = Instance.new("Folder", _WorldOrigin)
		Debris:AddItem(folder, 6)
		local clone2 = script.Explosion:Clone()
		clone2.Position = position2
		local raycastResult = workspace:Raycast(
			clone2.Position + createVector(0, 1, 0),
			createVector(0, -15, 0),
			raycastParams
		)

		if raycastResult then
			local instance = raycastResult.Instance
			local _ = raycastResult.Position

			if instance then
				clone2.Attachment1.sm2.Color = ColorSequence.new(instance.Color)
				clone2.Attachment1.Rocks.Color = ColorSequence.new(instance.Color)
			end
		end

		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit((math.ceil((emitter:GetAttribute("EmitCount") or 1) * 0.7)))
			end
		end

		if weak then
			Util.Sound:Play("GenericExplosion2", position2, 100, nil, 0.2)
			return
		end

		Util.Sound:Play("ExplosionHeavyFast", position2)

		if (position2 - workspace.CurrentCamera.CFrame.p).Magnitude < 80 then
			Effect.new("ShakeCam"):replicate({
				10,
				20,
				0.1,
				1.5
			})
		end

		Util.MeteorRocks({
			origin = CFrame.new(clone2.Position + createVector(0, 1.5, 0)),
			amount = 15,
			size = { 13.5, 4.5, 4.5 },
			offset = 28,
			tweenTime = 0.2,
			waitTime = 2.5
		})
	end
end