local createVector = vector.create
game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Bezier = require(script.Bezier)
local Vfxmodule = {}

function Vfxmodule.worldpreload()
	local folder = Instance.new("Folder")
	folder.Name = "worldpreload"
	folder.Parent = game.Workspace
	local part = Instance.new("Part", folder)
	part.Position = createVector(0, -200, 0)
	part.Anchored = true
	local descendants = game.Workspace:GetDescendants()

	for _, emitter in descendants do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local decal = Instance.new("Decal", part)
		decal.Texture = emitter.Texture
	end
end

function Vfxmodule.Closebeam(folder, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local descendants = folder:GetDescendants()

	for _, beam in descendants do
		if beam:IsA("Beam") then
			TweenService:Create(beam, tweenInfo, {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end

	task.wait(duration + 0.1)
end

function Vfxmodule.CloseAndMovebeam(folder, duration: number, p: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local descendants = folder:GetDescendants()

	for _, beam in descendants do
		if beam:IsA("Beam") then
			TweenService:Create(beam, tweenInfo, {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end

	TweenService:Create(folder, tweenInfo, {
		CFrame = folder.CFrame * CFrame.new(0, p, 0)
	}):Play()
	task.wait(duration + 0.1)
	Debris:AddItem(folder, 0.01)
end

function Vfxmodule.tweenbeamtransparency(instance, p, p2)
	local keypoints = instance.Transparency.Keypoints
	local v = {}

	for _, keypoint in ipairs(keypoints) do
		table.insert(v, {
			Time = keypoint.Time,
			Value = keypoint.Value
		})
	end

	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if not (instance and instance.Parent) then
			heartbeatConnection:Disconnect()
			return
		end

		total += dt
		local numberSequenceKeypoints = {}

		for _, v2 in ipairs(v) do
			local value = v2.Value
			local v3 = p2
			local v4 = math.abs(v3 - value)
			local v5 = v4 == 0 and 0 or 1 / v4
			local v6 = math.clamp(total / p * v5 * v4, 0, 1)
			local v7 = value + (v3 - value) * v6
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v2.Time, v7))
		end

		instance.Transparency = NumberSequence.new(numberSequenceKeypoints)

		if p <= total then
			local numberSequenceKeypoints2 = {}

			for _, v2 in ipairs(v) do
				table.insert(numberSequenceKeypoints2, NumberSequenceKeypoint.new(v2.Time, p2))
			end

			instance.Transparency = NumberSequence.new(numberSequenceKeypoints2)
			heartbeatConnection:Disconnect()
		end
	end)
end

function Vfxmodule.TweenTrailLifetime(state, p, lifetime)
	local min

	if typeof(state.Lifetime) == "NumberRange" then
		min = state.Lifetime.Min
	else
		min = state.Lifetime
	end

	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if not (state and state.Parent) then
			heartbeatConnection:Disconnect()
			return
		end

		total += dt
		local v = math.clamp(total / p, 0, 1)
		state.Lifetime = min + (lifetime - min) * v

		if p <= total then
			state.Lifetime = lifetime
			heartbeatConnection:Disconnect()
		end
	end)
end

function Vfxmodule.EmitAttributes(folder)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount")) then
			continue
		end

		local emitDelay = emitter:GetAttribute("EmitDelay")
		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDuration = emitter:GetAttribute("EmitDuration")

		if emitDuration and emitDuration > 0 then
			if emitDelay and emitDelay > 0 then
				local v = emitter
				local v2 = emitDuration
				task.delay(emitDelay, function()
					v.Enabled = true
					task.delay(v2, function()
						v.Enabled = false
					end)
				end)
			else
				emitter.Enabled = true
				local v = emitter
				task.delay(emitDuration, function()
					v.Enabled = false
				end)
			end
		elseif emitDelay and emitDelay > 0 then
			local v = emitter
			local v2 = emitCount
			task.delay(emitDelay, function()
				v:Emit(v2)
			end)
		else
			emitter:Emit(emitCount)
		end
	end
end

function Vfxmodule.Crater(p, p2, p3, size, _, p4)
	local v = math.random(0, 360)
	local v2 = 360 / p2
	local total = 0

	for _ = 1, p2 do
		local part = Instance.new("Part")
		local v3 = math.random(900, 1100) * 0.001
		local tweenInfo = TweenInfo.new(1 * v3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
		part.Size = size
		part.Anchored = true
		part.Parent = workspace.Thrown
		part.Material = p4.Material
		part.Color = p4.Color
		part.CFrame = p * CFrame.Angles(0, math.rad(v), 0) * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, p3) * CFrame.Angles(
			0.7853981633974483,
			0,
			0
		)
		total += v2
		part.CFrame *= CFrame.new(0, -2, 0)
		local tween = TweenService:Create(part, tweenInfo, {
			CFrame = part.CFrame * CFrame.new(0, 1.7, 0)
		})
		tween:Play()
		local completedConnection = nil
		completedConnection = tween.Completed:Connect(function()
			completedConnection:Disconnect()
			local v6 = math.random(2700, 3300) * 0.001
			task.spawn(function()
				task.wait(v6)

				if not (part and part.Parent) then
					return
				end

				local v7 = math.random(750, 1250) * 0.001
				TweenService:Create(part, TweenInfo.new(4 * v7, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
					CFrame = part.CFrame * CFrame.new(0, 0, -5)
				}):Play()
				Debris:AddItem(part, 5)
			end)
		end)
	end
end

function Vfxmodule.textureflipbook(instance, list, p: number, callback)
	if not (instance and (instance:IsA("Decal") or instance:IsA("Beam") or instance:IsA("ParticleEmitter"))) then
		warn("Flipbook only works with instances that have a 'Texture' property")
		return
	end

	if type(list) ~= "table" or #list == 0 then
		warn("Flipbook requires a non-empty texture table")
		return
	end

	if p <= 0 then
		warn("Flipbook requires duration > 0")
		return
	end

	local lastTime = os.clock()
	local count = #list
	local v = p / count
	task.spawn(function()
		while instance and instance.Parent do
			local v2 = os.clock() - lastTime

			if p <= v2 then
				if callback then
					pcall(callback)
				else
					instance.Texture = list[count]
				end

				break
			else
				instance.Texture = list[math.floor(v2 / v) + 1]
				task.wait(0.01)
			end
		end
	end)
end

function Vfxmodule.textureflipbookLoop(instance, list, p: number)
	if not (instance and (instance:IsA("Decal") or instance:IsA("Beam") or instance:IsA("ParticleEmitter"))) then
		warn("Flipbook only works with instances that have a 'Texture' property")
		return
	end

	if type(list) ~= "table" or #list == 0 then
		warn("Flipbook requires a non-empty texture table")
		return
	end

	if p <= 0 then
		warn("Flipbook requires duration > 0")
		return
	end

	local count = #list
	local v = count / p
	local result = {
		_running = true,
		Stop = function(p2)
			p2._running = false
		end
	}
	task.spawn(function()
		local v2 = 0
		local v3 = 1

		while result._running do
			if not (instance and instance.Parent) then
				result._running = false
				break
			end

			v2 += RunService.Heartbeat:Wait()
			local v4 = math.floor(v2 * v)

			if not (v4 > 0) then
				continue
			end

			v3 += v4
			v2 -= v4 / v

			if count < v3 then
				v3 = (v3 - 1) % count + 1
			end

			instance.Texture = list[v3]
		end
	end)
	return result
end

function Vfxmodule.TexturePreload(list)
	local Workspace = game:GetService("Workspace")
	local folder = Instance.new("Folder")
	folder.Name = "TextureParts"
	folder.Parent = Workspace

	local function createPartWithDecal(texture, _)
		local part = Instance.new("Part")
		part.Name = "TexturePart_" .. tostring(texture):gsub("rbxassetid://", ""):gsub("rbxasset://textures/", "")
		part.Size = createVector(4, 4, 0.2)
		part.Position = createVector(0, -300, 0)
		part.Anchored = true
		part.BrickColor = BrickColor.new("Medium stone grey")
		part.Material = Enum.Material.SmoothPlastic
		part.Parent = folder
		local decal = Instance.new("Decal")
		decal.Name = "TextureDecal"
		decal.Texture = texture
		decal.Face = Enum.NormalId.Front
		decal.Parent = part
		return part
	end

	print("Generating " .. #list .. " texture parts...")

	for i, v in ipairs(list) do
		local v2 = math.floor((i - 1) / 5)
		createPartWithDecal(v, Vector3.new((i - 1) % 5 * 1, 5, -v2 * 1))
	end

	print("Finished creating all texture parts!")
	print("Parts are organized in the '" .. folder.Name .. "' folder in Workspace")
end

function Vfxmodule.RandomCFrame()
	local v = math.rad((math.random(-360, 360)))
	local v2 = math.rad((math.random(-360, 360)))
	local v3 = math.rad((math.random(-360, 360)))
	return (CFrame.Angles(v, v2, v3))
end

function Vfxmodule.beziertrailpart(instance, position: Vector3, p: number, p2: number)
	local v = math.rad((math.random(-75, 75)))
	local v2 = math.rad((math.random(-360, 360)))
	local v3 = math.rad((math.random(-75, 75)))
	local v4 = math.rad((math.random(-70, 70)))
	local v5 = math.rad((math.random(-70, 70)))
	local v6 = math.rad((math.random(-70, 70)))
	local v7 = math.random(600, 800) / 1000
	local clone = instance:Clone()
	CFrame.new(position)
	clone.CFrame = CFrame.new(position) * CFrame.Angles(v, v2, v3) * CFrame.new(0, p2, 0)
	clone.CFrame = CFrame.lookAt(clone.Position, position)
	local v8 = clone.CFrame * CFrame.Angles(v4, v5, v6) * CFrame.new(
		math.random(-10, 10),
		math.random(-10, 10),
		p2 * -1 / v7
	)
	local v9 = Bezier.new(clone.Position, v8.Position, position)
	local v10 = p * (math.random(800, 1200) / 1000)
	local cFrameTween = v9:CreateCFrameTween(
		clone,
		{ "CFrame" },
		(TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0))
	)
	clone.Parent = workspace.Thrown
	task.delay(v10 + 0.4, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	cFrameTween:Play()
end

function Vfxmodule.TimeScaleTween(p, duration: number, duration2: number, duration3: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local tweenInfo2 = TweenInfo.new(duration3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local tween = TweenService:Create(p, tweenInfo, {
		TimeScale = 0
	})
	local tween2 = TweenService:Create(p, tweenInfo2, {
		TimeScale = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		task.wait(duration2)
		tween2:Play()
	end)
end

function Vfxmodule.WindringPreset(p, duration, size, p3)
	TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0), {
		Transparency = 1,
		Size = size,
		CFrame = p.CFrame * p3
	}):Play()
end

function Vfxmodule.MakeFlyingDebrispart(instance, cFrame: CFrame, p: number, parent, p2: number)
	local clone = instance:Clone()
	clone.CFrame = cFrame
	clone.Parent = parent
	local v = math.random(p2 * -1, p2)
	local v2 = (cFrame * CFrame.Angles(math.rad(v), math.rad((math.random(-360, 360))), (math.rad(v)))).UpVector * 100
	clone.Anchored = false
	clone.AssemblyLinearVelocity = v2 * p
	Debris:AddItem(clone, 5)
end

return Vfxmodule