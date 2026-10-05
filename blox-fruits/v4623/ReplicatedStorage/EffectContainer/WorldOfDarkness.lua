local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = game.ReplicatedStorage.Util
local sound = Util.Sound
local masterClock = Util.MasterClock
local FX = require(game.ReplicatedStorage.FX)
local LightningBolt = require(ReplicatedStorage:WaitForChild("Util").LightningBolt)
local LightningSparks = require(ReplicatedStorage:WaitForChild("Util").LightningBolt.LightningSparks)
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(state)
	local cFrame = state.HRP.CFrame
	local cframe = CFrame.new(state.HRP.Size.X, 1 + state.HRP.Size.Y * 1.5 + state.Scale * 0.33, 0)

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local scale = state.Scale
	local v = scale * 0.1
	local _ = state.Data
	local clone = FX:WaitForChild("Attachments").DarkVortex:Clone()
	clone.ParticleEmitter.Size = NumberSequence.new(v, 0)
	clone.Hole.Size = NumberSequence.new(v * 0.4, 0)
	clone.Parent = workspace.Terrain
	clone.CFrame = cFrame * cframe
	sound:Play("DarknessLayer", clone)
	spawn(function()
		for i = 0.1, 1, 0.1 do
			v = scale * i
			clone.ParticleEmitter.Size = NumberSequence.new(v, 0)
			clone.Hole.Size = NumberSequence.new(v * 0.4, 0)
			wait(0.085)
		end
	end)
	local clone2 = script.Charging2:Clone()
	clone2.CFrame = cFrame * CFrame.new(0, -state.HRP.Size.Y * 2, 0)
	clone2.Parent = _WorldOrigin
	local v2 = false
	local v3 = false
	local v4 = false
	local v5 = false
	tick()
	local lastTime = tick()
	local lastTime2 = tick()
	spawn(function()
		while v2 == false and v5 == false do
			if not state.HRP or not state.HRP:IsDescendantOf(workspace) or state.Data == nil or state.Data.Parent == nil then
				v5 = true
				break
			end

			if state.HRP and not v3 then
				clone.CFrame = state.HRP.CFrame * cframe
			end

			if tick() - lastTime > 0.12 then
				clone.ParticleEmitter:Emit(1)
				lastTime = tick()
			end

			if tick() - lastTime2 > 0.06 then
				clone.Hole:Emit(1)
				lastTime2 = tick()
			end

			for _ = 1, v4 and math.random(3, 4) or math.random(2, 3) do
				local cframe2 = CFrame.new(0, 0, -v * 0.4 - math.random() * v * 0.4)
				local cFrame2 = clone.CFrame * CFrame.Angles(
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2
				)
				local attachment = Instance.new("Attachment")
				attachment.CFrame = cFrame2 * cframe2
				attachment.Parent = workspace.Terrain
				local clone3 = clone.Beam:Clone()
				clone3.Width0 = 0
				clone3.Attachment0 = clone
				clone3.Attachment1 = attachment
				clone3.Parent = _WorldOrigin
				local tweenInfo = TweenInfo.new(0.25)
				TweenService:Create(attachment, tweenInfo, {
					CFrame = cFrame2
				}):Play()
				local tween = TweenService:Create(clone3, tweenInfo, {
					Width0 = v * 0.35
				})
				tween.Completed:Connect(function()
					attachment:Destroy()
					clone3:Destroy()
				end)
				tween:Play()
			end

			wait()
		end
	end)

	repeat
		wait()
	until v5 or state.Data:FindFirstChild("Timestamp") and state.Data:FindFirstChild("Target")

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.delay(1.5, function()
		clone2:Destroy()
	end)

	if not v5 then
		sound:Play("DarknessFormation", clone)
		v3 = true
		state.Timestamp = state.Data.Timestamp.Value
		state.Target = state.Data.Target.Value
		local magnitude = (state.Target.p - cFrame.p).Magnitude
		local v6 = masterClock:GetTime() - state.Timestamp
		local v7 = math.max(magnitude / 200 - v6, 0) * 0.85
		local lastTime3 = tick()

		while tick() - lastTime3 < v7 do
			local _ = tick() - lastTime3
			local v8 = math.min(1, (tick() - lastTime3) / v7)
			clone.CFrame = (cFrame * cframe):Lerp(state.Target, v8)
			RunService.RenderStepped:Wait()
		end

		v4 = true
		clone.CFrame = state.Target

		for _ = 1, 20 do
			v += 7
			clone.ParticleEmitter.Size = NumberSequence.new(v, 0)
			clone.Hole.Size = NumberSequence.new(v * 0.4, 0)
			wait()
		end

		v2 = true
		wait(0.1)
		clone.Hole.Enabled = false
		clone.ParticleEmitter.Enabled = false
		wait(0.15)
		sound:Play("DarknessExplosion2", clone.CFrame)
		local v8 = v * 1.25
		local clone3 = clone.ParticleEmitter:Clone()
		clone3.Size = NumberSequence.new(0, v8)
		clone3.Transparency = NumberSequence.new(0, 1)
		clone3.Lifetime = NumberRange.new(0.7)
		clone3.Parent = clone
		clone.Hole:Emit(3)
		clone3:Emit(1)

		for _ = 1, 28 do
			local cframe2 = CFrame.new(0, 0, -v8 * 0.5 - math.random() * v8 * 0.5)
			local cFrame2 = clone.CFrame * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			local attachment = Instance.new("Attachment")
			attachment.CFrame = cFrame2
			attachment.Parent = workspace.Terrain
			local clone4 = clone.Beam:Clone()
			clone4.Width0 = v8 * 0.4
			clone4.Attachment0 = clone
			clone4.Attachment1 = attachment
			clone4.Parent = _WorldOrigin
			local tweenInfo = TweenInfo.new(0.3 + math.random() * 0.1)
			TweenService:Create(attachment, tweenInfo, {
				CFrame = cFrame2 * cframe2
			}):Play()
			local tween = TweenService:Create(clone4, tweenInfo, {
				Width0 = 0
			})
			tween.Completed:Connect(function()
				attachment:Destroy()
				clone4:Destroy()
			end)
			tween:Play()
		end

		local target = state.Target

		for _ = 1, 10 do
			local cFrame2 = target * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			local cframe2 = CFrame.new(0, 0, v8 * 0.4)
			local attachment = Instance.new("Attachment")
			attachment.CFrame = cFrame2
			attachment.Parent = workspace.Terrain
			local attachment2 = Instance.new("Attachment")
			attachment2.CFrame = cFrame2 * cframe2
			attachment2.Parent = workspace.Terrain
			local v10 = -v8 / 2
			local v11 = -v8 / 2
			local v12 = LightningBolt.new(attachment, attachment2, v10, v11, 5, Color3.new(0.21, 0, 0.21))
			v12.PulseLength = 0.4
			v12.FadeLength = 0.1
			v12.PulseSpeed = 2.5
			v12.MinThicknessMultiplier = 0.5
			v12.MaxThicknessMultiplier = 1
			v12.AnimationSpeed = 6
			v12.Thickness = 4.5
			v12.AddTransparency = 0
			local v13 = LightningSparks.new(v12, 5)
			v13.MinDistance = v8 / 4
			v13.MaxDistance = v8 / 2
			v13.MinSpeed = v8 / 4
			v13.MaxSpeed = v8 / 2
			local tween = TweenService:Create(attachment, TweenInfo.new(0.04000000000000001), {
				CFrame = cFrame2
			})
			tween.Completed:Connect(function()
				wait(0.8)
				attachment:Destroy()
			end)
			tween:Play()
			local tween2 = TweenService:Create(attachment2, TweenInfo.new(0.04000000000000001), {
				CFrame = cFrame2 * cframe2 * cframe2
			})
			tween2.Completed:Connect(function()
				wait(0.8)
				attachment2:Destroy()
			end)
			tween2:Play()
		end

		local ray = Util.Ray
		local v9 = clone.Position + createVector(0, 5, 0)
		local v10 = { workspace.Characters, workspace.Enemies, workspace.Boats }
		local v11, v12, v13 = ray(v9, createVector(0, -20, 0), v10)

		if v11 then
			local v14 = CFrame.new(v12, v12 + v13) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local clone4 = script.Scar:Clone()
			clone4.CFrame = v14 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
			clone4.Parent = workspace._WorldOrigin
			TweenService:Create(clone4.Decal, TweenInfo.new(3), {
				Transparency = 1
			}):Play()
			Util.Debris:AddItem(clone4, 3.25)
		end

		if (workspace.CurrentCamera.CFrame.p - clone.CFrame.p).Magnitude < 300 then
			Effect.new("Dark.Gradient"):replicate({
				Transparency = 0.175,
				Toggle = true,
				Duration = 0.5
			})
			task.delay(0.9, function()
				Effect.new("Dark.Gradient"):replicate({
					Toggle = false,
					Duration = 0.3
				})
			end)
			local magnitude2 = (workspace.CurrentCamera.CFrame.p - clone.CFrame.p).Magnitude
			Effect.new("ShakeCam"):replicate({
				Preset = "Explosion",
				Power = math.clamp(1 - magnitude2 / 300, 0, 1)
			})
		end

		local ground = Util.RocksModule.Ground
		local v14 = clone.Position + createVector(0, 3, 0)
		local v15 = { workspace.Map }
		ground(v14, 90, createVector(12, 14, 12), v15, 12, false, 2.25)
	end

	clone.Hole.Enabled = false
	clone.ParticleEmitter.Enabled = false
	wait(1)
	clone:Destroy()
end