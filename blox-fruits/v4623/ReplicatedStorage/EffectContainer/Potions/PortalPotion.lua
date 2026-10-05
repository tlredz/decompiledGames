local createVector = vector.create
local assets = script.Assets
local Util = require(game.ReplicatedStorage.Util)
local RunService = game:GetService("RunService")
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function EmitParticle(emitter)
	if not emitter:IsA("ParticleEmitter") then
		return
	end

	task.delay(emitter:GetAttribute("EmitDelay") or 0, function()
		local emitDuration = emitter:GetAttribute("EmitDuration")
		local emitCount = emitter:GetAttribute("EmitCount")

		if not emitDuration then
			emitter:Emit(emitCount or 1)
			return
		end

		emitter:Emit(emitCount or 0)
		local _ = emitter.Enabled
		emitter.Enabled = true
		task.wait(emitDuration)
		emitter.Enabled = false
	end)
end

local function ToggleParticle(folder, enabled: boolean)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
			continue
		end

		effect.Enabled = enabled
	end
end

local function LerpColorSequence(sequence, sequence2, p)
	local colorSequenceKeypoints = {}

	for i, keypoint in ipairs(sequence.Keypoints) do
		local keypoint2 = sequence2.Keypoints[i]
		local time = keypoint.Time
		local lerped = keypoint.Value:Lerp(keypoint2.Value, p)
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(time, lerped))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function TweenColorSequence(p, p2, p3, p4, p5)
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v = math.clamp(total / p5, 0, 1)
		p[p2] = LerpColorSequence(p3, p4, v)

		if v >= 1 then
			heartbeatConnection:Disconnect()
		end
	end)
end

local RunService2 = game:GetService("RunService")
local v = RunService2:IsStudio() and false

local function log(...)
	if v then
		task.spawn(warn, "[PortalPotion]", ...)
	end
end

local function SkillUse(data)
	local root = data.Root

	if not (root and root.Parent) then
		log("no humanoid root part")
		return
	end

	local fn = TweenColorSequence
	local fn2 = EmitParticle
	local fn3 = ToggleParticle

	if data.Hacker then
		local function fn4(sequence)
			local HSV = Color3.new(0, 1, 0):ToHSV()
			local colorSequenceKeypoints = {}

			for _, keypoint in ipairs(sequence.Keypoints) do
				local _, v2, v3 = keypoint.Value:ToHSV()
				local time = keypoint.Time
				local color = Color3.fromHSV(HSV, v2, v3)
				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(time, color))
			end

			return ColorSequence.new(colorSequenceKeypoints)
		end

		fn2 = function(emitter)
			if not emitter:IsA("ParticleEmitter") then
				return
			end

			emitter.Color = fn4(emitter.Color)
			return fn2(emitter)
		end

		fn3 = function(folder, enabled: boolean)
			for _, effect in pairs(folder:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Color = fn4(effect.Color)
				effect.Enabled = enabled
			end
		end

		fn = function(p, p2, p3, p4, p5: number)
			local v2 = fn4(p3)
			local v3 = fn4(p4)
			return fn(p, p2, v2, v3, p5 * 0.5)
		end
	elseif data.DogHouse then
		local function fn4(sequence)
			local HSV = Color3.new(1, 0, 0):ToHSV()
			local colorSequenceKeypoints = {}

			for _, keypoint in ipairs(sequence.Keypoints) do
				local _, v2, v3 = keypoint.Value:ToHSV()
				local time = keypoint.Time
				local color = Color3.fromHSV(HSV, v2, v3)
				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(time, color))
			end

			return ColorSequence.new(colorSequenceKeypoints)
		end

		fn2 = function(emitter)
			if not emitter:IsA("ParticleEmitter") then
				return
			end

			emitter.Color = fn4(emitter.Color)
			return fn2(emitter)
		end

		fn3 = function(folder, enabled: boolean)
			for _, effect in pairs(folder:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Color = fn4(effect.Color)
				effect.Enabled = enabled
			end
		end

		fn = function(p, p2, p3, p4, p5: number)
			local v2 = fn4(p3)
			local v3 = fn4(p4)
			return fn(p, p2, v2, v3, p5 * 0.5)
		end
	end

	local v2 = assert(data.UserId, "userid is nil")
	local v3 = assert(data.Stage, "stage is nil")
	local formatted = `{v2}_PortalPotionVFXStage_{v3}`
	local proxy = data.Proxy

	if not (proxy and proxy.Parent) then
		log("Proxy is missing in Portal Potion")
		return
	end

	local v4 = v2 == game.Players.LocalPlayer.UserId
	local v5 = assert(data.Proxy)

	if v3 == 1 then
		if not v4 then
			local currentCamera = workspace.CurrentCamera

			if (root.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
				log("too far 1")
				return
			end
		end

		local folder = Instance.new("Folder", workspace._WorldOrigin)
		folder.Name = formatted
		local clone = assets.Choosing:Clone()
		clone.CFrame = root.CFrame
		clone.Parent = folder
		fn3(clone, true)
		local v6 = Sound:Play("GatePotionLoop", root.Position, 4, nil, 0.2, 1)

		repeat
			log("waiting 1")
			task.wait()
			clone.CFrame = root.CFrame
		until (v5 and v5.Parent and true or false) == false or not root:IsDescendantOf(workspace) or v5:GetAttribute("Action") == "Finish"

		fn3(clone, false)
		Util.Debris:AddItem(folder, 2)
		Sound:FadeOut(v6, 1)
	elseif v3 == 2 or v3 == 3 then
		local v6 = assert(data.StartPoint)
		local v7 = assert(data.EndPoint)
		local v8 = nil

		if v3 == 2 then
			local ray = Util.Ray
			local v9 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			local v10
			v10, v8 = ray(v6, createVector(0, -20, 0), v9)
		elseif v3 == 3 then
			local ray = Util.Ray
			local v9 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			local v10
			v10, v8 = ray(v7, createVector(0, -20, 0), v9)
		end

		if not v4 and (v8 - workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
			log("too far 2")
			return
		end

		local folder = Instance.new("Folder", workspace._WorldOrigin)
		folder.Name = formatted
		Util.Debris:AddItem(folder, v3 == 2 and 20 or 10)
		local clone = assets.Portal:Clone()
		clone.Name = `Portal{v3 - 1}`
		clone:PivotTo(CFrame.new(v8) * CFrame.new(0, 0.5, 0))
		clone.Parent = folder
		Sound:Play("GatePotionOpen", clone:GetPivot().Position, 4, nil, 1, 0)
		local clone2 = assets.PortalOpen:Clone()
		clone2.CFrame = clone:GetPivot()
		clone2.Parent = folder

		for _, child in pairs(clone2:GetChildren()) do
			if child.Name ~= "Portal Open Emit" then
				continue
			end

			if child:IsA("ParticleEmitter") then
				fn2(child)
			elseif child:IsA("Attachment") then
				for _, child2 in child:GetChildren() do
					fn2(child2)
				end
			end
		end

		fn3(clone, true)

		repeat
			task.wait()
			log((`waiting {v3}`))
		until (v5 and v5.Parent and true or false) == false or v5:GetAttribute("Action") == "Finish" or folder.Parent == nil

		if not folder.Parent then
			return
		end

		for _, child in pairs(folder:GetChildren()) do
			if child.Name ~= "PortalOpen" then
				continue
			end

			for _, child2 in pairs(child.travelEmit:GetChildren()) do
				fn2(child2)
			end
		end

		for _, child in pairs(folder:GetChildren()) do
			if child.Name ~= "PortalOpen" then
				continue
			end

			for _, child2 in pairs(child:GetChildren()) do
				if child2.Name ~= "Portal Close Emit" then
					continue
				end

				if child2:IsA("ParticleEmitter") then
					fn2(child2)
				elseif child2:IsA("Attachment") then
					for _, child3 in child2:GetChildren() do
						fn2(child3)
					end
				end
			end
		end

		task.wait(0.1)
		task.spawn(function()
			for _, emitter in pairs(clone.PortalVFX.Portal:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local color = emitter.Color
				emitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
				fn(emitter, "Color", emitter.Color, color, 0.25)
			end
		end)
		Sound:Play("GatePotionClose", clone:GetPivot().Position, 10, nil, 1, 0)
		local scale = clone:GetScale()

		for i = 1, 12 do
			clone:ScaleTo(scale + 0.001 - scale / 12 * i)
			task.wait(0.016666666666666666)
		end

		fn3(clone, false)
	end
end

return SkillUse