local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local portal = FX:WaitForChild("PortalEffects").Portal
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local Trails = require(script:WaitForChild("Trails"))
return function(data)
	local player = data.player
	task.spawn(function()
		local origin = data.origin
		local lookDir = data.lookDir
		local upDir = data.upDir
		local lastsFor = data.lastsFor
		local emitLightShockwave = data.emitLightShockwave
		local emitDarkShockwave = data.emitDarkShockwave
		local chargeParticlesEnabled = data.chargeParticlesEnabled

		if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1e999 then
			return
		end

		local delayPortalSpawnBy = data.delayPortalSpawnBy

		if delayPortalSpawnBy then
			task.spawn(function()
				Trails(delayPortalSpawnBy, createVector(0, 1, 0), origin)
			end)
			task.wait(delayPortalSpawnBy)
		end

		local clone = portal:Clone()

		if upDir then
			clone.CFrame = CFrame.fromMatrix(origin, upDir:Cross(-lookDir).Unit, upDir, -lookDir) * CFrame.Angles(
				0.0001,
				0,
				0
			)
		else
			clone.CFrame = CFrame.lookAt(createVector(0, 0, 0), lookDir) * CFrame.Angles(0.0001, 0, 0) + origin
		end

		if lastsFor < 1 then
			for _, emitter in ipairs(clone:GetDescendants()) do
				if not (emitter:IsA("ParticleEmitter") and math.abs(0.5 - emitter.Lifetime.Min) < 0.01) then
					continue
				end

				emitter.Lifetime = NumberRange.new(lastsFor * 0.5)
			end
		end

		local v = nil

		if chargeParticlesEnabled == true then
			task.delay(0.15, function()
				for _, child in ipairs(clone.ChargeAttachment:GetChildren()) do
					child.Enabled = true
				end

				v = Util.Sound:Play("PortalLoop", clone.Position)
				v.Looped = true
			end)
		end

		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PortalFruitVFXColor")
		Util.Sound:Play("PortalOpening", clone.Position)

		if emitLightShockwave then
			Util.Sound:Play("PortalShockwave", clone.Position)
		elseif emitDarkShockwave then
			Util.Sound:Play("PortalShockwaveDark", clone.Position)
		end

		task.wait(0.05)
		destroyAfter(clone, lastsFor + 1)

		for i = 1, 3 do
			local init = clone["Attachment" .. tonumber(i)].Init
			init:Emit(init:GetAttribute("EmitCount"))
			local init2 = clone["Attachment" .. tonumber(i)].Init2
			init2:Emit(init2:GetAttribute("EmitCount"))
		end

		if emitDarkShockwave or emitLightShockwave then
			for _, child in ipairs(clone[emitDarkShockwave and "EmitDarkAttachment" or "EmitLightAttachment"]:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			if (clone.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 120 then
				local v2 = 1 - (clone.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude / 120
				local bloomEffect = Instance.new("BloomEffect")
				bloomEffect.Name = "PortalWaveBloom"
				bloomEffect.Intensity = 2
				bloomEffect.Threshold = 1
				bloomEffect.Size = 48
				Util.SetParentOverrideWithColor(bloomEffect, Lighting, player, "PortalFruitVFXColor")
				heartbeatLoopFor2(0.2, function(_, _, p)
					bloomEffect.Intensity = 2 - p
					bloomEffect.Threshold = 1 + p
					bloomEffect.Size = 48 - 24 * p
				end, function()
					bloomEffect:Destroy()
				end)
				Util.CameraShaker:ShakeOnce(6 * v2, 10 * v2, 0.01, 0.35)
			end
		end

		local lightAttachment = clone:FindFirstChild("LightAttachment")
		heartbeatLoopFor2(clone.Attachment1.Init.Lifetime.Min * 0.8, function(_, _, p)
			if lightAttachment:FindFirstChild("PointLight") then
				lightAttachment.PointLight.Brightness = p * 155
			end
		end, function()
			if lightAttachment:FindFirstChild("PointLight") then
				lightAttachment.PointLight.Brightness = 155
			end
		end)
		task.wait(clone.Attachment1.Init.Lifetime.Min * 0.8)
		local lastTime = tick()
		local now = 0

		while tick() - lastTime < lastsFor - clone.Attachment1.Init.Lifetime.Min - clone.Attachment1.End.Lifetime.Min do
			if tick() - now > 0.25 then
				now = tick()

				for i = 1, 3 do
					clone["Attachment" .. tonumber(i)].Loop:Emit(1)
					clone["Attachment" .. tonumber(i)].Loop2:Emit(1)
				end
			end

			task.wait(0.05)
		end

		Util.Sound:Play("PortalClosing", clone.Position)

		if v then
			v:Stop()
			v:Destroy()
		end

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(0.15)

		if clone.Parent == nil then
			return
		end

		for i = 1, 3 do
			local v2 = clone["Attachment" .. tonumber(i)].End
			v2:Emit(v2:GetAttribute("EmitCount"))
			local end2 = clone["Attachment" .. tonumber(i)].End2
			end2:Emit(end2:GetAttribute("EmitCount"))
		end

		heartbeatLoopFor2(clone.Attachment1.End.Lifetime.Min * 0.8, function(_, _, p)
			if clone:FindFirstChild("LightAttachment") then
				clone.LightAttachment.PointLight.Brightness = (1 - p) * 155
			end
		end, function()
			if clone:FindFirstChild("LightAttachment") then
				clone.LightAttachment.PointLight.Brightness = 0
				clone.LightAttachment.PointLight.Enabled = false
			end
		end)
	end)
end