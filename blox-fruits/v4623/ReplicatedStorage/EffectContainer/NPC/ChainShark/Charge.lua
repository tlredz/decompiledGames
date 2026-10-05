local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.BoatTween
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local scaleParticle2 = Util.ScaleParticle2
return function(player)
	local ID = player.ID

	if ID == 1 then
		local character = player.Character
		local duration = player.Duration
		local timestamp = player.Timestamp
		local scale = player.Scale or 1
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 1500 then
				return
			end

			Util.Sound:Play("CRoar", humanoidRootPart, nil, math.random(110, 130) / 100, 1.54)
			local clone = script.ChargeModel:Clone()
			debris:AddItem(clone, duration + 2)
			local descendants = clone:GetDescendants()

			for _, emitter in descendants do
				if emitter:IsA("ParticleEmitter") then
					scaleParticle2(emitter, scale, true)
				end
			end

			clone:PivotTo(humanoidRootPart.CFrame)
			clone.WaterLeft.CFrame = clone.Core.CFrame * CFrame.new(-6 * scale, 5, 0)
			clone.WaterRight.CFrame = clone.Core.CFrame * CFrame.new(6 * scale, 5, 0)
			clone.Parent = _WorldOrigin
			local v = math.max(0.1, duration - (masterClock:GetTime() - timestamp))
			local lastTime = tick()

			while tick() - lastTime < v and humanoidRootPart and humanoidRootPart.Parent do
				clone:PivotTo(humanoidRootPart.CFrame)
				RunService.Heartbeat:Wait()
			end

			for _, emitter in descendants do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.delay(1, function()
				if clone then
					clone:Destroy()
				end
			end)
		end
	elseif ID == 2 then
		local cFrame = player.CFrame
		local scale = player.Scale or 1

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 1000 then
			return
		end

		Util.Sound:Play("FlameProExplosion", cFrame, nil, 2, 1)
		Util.Sound:Play("SharkmanExplosion", cFrame, nil, 0.5, 1.5)
		Util.Sound:Play("BeastWaterSplash3", cFrame, nil, 0.8, 2)
		local clone = script.ExplosionImpact:Clone()
		debris:AddItem(clone, 3)
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		local descendants = clone:GetDescendants()

		for _, emitter in pairs(descendants) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			scaleParticle2(emitter, scale, true)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end