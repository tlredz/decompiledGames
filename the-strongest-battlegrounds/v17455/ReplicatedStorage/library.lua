local createVector = vector.create
local Library = {
	EFP = game.Workspace.Thrown
}
local BoatTween = require(script.BoatTween)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

function Library.ProcessPart(data)
	local maid = data.Maid
	local FX = data.FX
	local part = data.Part
	local debri = data.Debri or 10
	local children = maid:give(FX:Clone()):GetChildren()

	for i = 1, #children do
		local v = children[i]
		maid:give(v)
		Debris:AddItem(v, debri)
		v.Parent = part
	end
end

function Library.PlayTween(p, p2, callback)
	local v = BoatTween:Create(p, p2)
	v:Play()
	local completedConnection = nil
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanup()
		if flag then
			return
		end

		flag = true

		if completedConnection then
			completedConnection:Disconnect()
		end

		v:Destroy()
	end

	completedConnection = v.Completed:Once(function()
		if callback then
			callback()
		end

		cleanup() -- equivalent call inferred; original call site unknown
	end)
	task.delay(p2.Time + 0.05, cleanup)
	return v
end

Library.Maid = require(script.Maid)
Library.Bezier = require(script.Bezier)

function Library.Impact(instance)
	local clone = instance:Clone()
	clone.Parent = game.Lighting
	task.delay(0.1, function()
		clone:Destroy()
	end)
end

local function collectEmitters(emitter)
	local emitters = {}
	local count = 0

	if emitter:IsA("ParticleEmitter") then
		emitters[1] = emitter
		return emitters, 1
	end

	local descendants = emitter:GetDescendants()

	for i = 1, #descendants do
		local emitter2 = descendants[i]

		if not emitter2:IsA("ParticleEmitter") then
			continue
		end

		count += 1
		emitters[count] = emitter2
	end

	return emitters, count
end

function Library.ChangeParticleColor(data)
	local particle = data.Particle
	local color = data.Color
	local position = data.Position or data.Pos
	local v, v2 = collectEmitters(particle)

	if not color and position then
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Built, workspace.Map }
		local raycastResult = workspace:Raycast(position, createVector(0, -100, 0), raycastParams)

		if raycastResult then
			color = raycastResult.Instance.Color
		end
	end

	if not color then
		return
	end

	local colorSequence = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(
			1,
			color
		) })

	for i = 1, v2 do
		v[i].Color = colorSequence
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Built, workspace.Map }

function Library.SetSmoke(data)
	local FX = data.FX
	local dist = data.Dist or 20
	local anchor = data.Anchor
	local raycastResult = workspace:Raycast(anchor.Position, Vector3.new(0, -dist, 0), raycastParams)

	if not raycastResult then
		return
	end

	local color = raycastResult.Instance.Color
	local colorSequence = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(
			1,
			color
		) })
	local v, v2 = collectEmitters(FX)

	for i = 1, v2 do
		v[i].Color = colorSequence
	end

	return raycastResult
end

function Library.BindScale(data)
	local FX = data.FX
	local maid = data.Maid
	local init = data.Init or 1
	local v = maid:give(Instance.new("NumberValue"))
	v.Value = init
	v:giveTask(v.Changed:Connect(function()
		FX:ScaleTo(v.Value)
	end))
	return v
end

function Library.Able(data)
	local FX = data.FX
	local on = data.On
	local name = data.name
	local descendants = FX:GetDescendants()

	if on then
		if name then
			for i = 1, #descendants do
				local emitter = descendants[i]

				if not emitter:IsA("ParticleEmitter") or emitter:GetAttribute("Cosmetic") or not emitter:GetAttribute(name) then
					continue
				end

				emitter.Enabled = true
			end
		else
			for i = 1, #descendants do
				local emitter = descendants[i]

				if not emitter:IsA("ParticleEmitter") or emitter:GetAttribute("Cosmetic") then
					continue
				end

				emitter.Enabled = true
			end
		end
	elseif name then
		for i = 1, #descendants do
			local emitter = descendants[i]

			if not emitter:IsA("ParticleEmitter") or emitter:GetAttribute("Cosmetic") or not emitter:GetAttribute(name) then
				continue
			end

			emitter.Enabled = false
		end
	else
		for i = 1, #descendants do
			local emitter = descendants[i]

			if not emitter:IsA("ParticleEmitter") or emitter:GetAttribute("Cosmetic") then
				continue
			end

			emitter.Enabled = false
		end
	end
end

function Library.WeldObject(...)
	local v, v2, v3, v4, v5, v6 = ...
	local clone = v:Clone()
	local weld = Instance.new("Weld")
	weld.Parent = v2
	weld.Part1 = clone.PrimaryPart
	weld.Part0 = v2
	clone.Parent = v2.Parent
	clone.Name = "ModuleWelded"

	if v3 then
		local descendants = clone:GetDescendants()

		for i = 1, #descendants do
			local effect = descendants[i]

			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
				continue
			end

			local v7 = effect
			task.delay(v3, function()
				v7.Enabled = false
				task.wait(2)
				clone:Destroy()
			end)
		end
	elseif v6 then
		task.delay(v5, function()
			local descendants = clone:GetDescendants()
			local count = 0
			local v7 = {}

			for i = 1, #descendants do
				local part = descendants[i]

				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			for i = 1, #descendants do
				local instance = descendants[i]

				if not (instance:IsA("ParticleEmitter") and instance.Enabled or instance:IsA("Beam") or instance:IsA("Texture") or instance:IsA("Decal")) then
					continue
				end

				if instance:IsA("ParticleEmitter") then
					count += 1
					v7[count] = {
						emitter = instance,
						count = instance:GetAttribute("EmitCount")
					}
				end

				instance:Destroy()
			end

			for i = 1, count do
				local v8 = v7[i]

				if v8.emitter and v8.count then
					shared.smartEmit(v8.emitter, v8.count)
				end
			end

			task.wait(3)
			clone:Destroy()
		end)
	elseif v5 then
		task.delay(v5, function()
			clone:Destroy()
		end)
	elseif v4 then
		task.delay(v4, function()
			weld:Destroy()
			clone.Parent = workspace.Thrown
			task.wait(0.08)
			local descendants = clone:GetDescendants()

			for i = 1, #descendants do
				local instance = descendants[i]

				if instance:IsA("BasePart") then
					instance.CanCollide = true
				elseif instance:IsA("ParticleEmitter") then
					instance.Enabled = false
				end
			end

			task.wait(1.5)
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			local descendants2 = clone:GetDescendants()

			for i = 1, #descendants2 do
				local part = descendants2[i]

				if part:IsA("BasePart") then
					TweenService:Create(part, tweenInfo, {
						Transparency = 1
					}):Play()
				end
			end

			task.wait(0.5)
			clone:Destroy()
		end)
	end
end

function Library.QuickWeld(data)
	local FX = data.FX
	local C0 = data.C0 or CFrame.new(0, 0, 0)
	local P = data.P
	local maid = data.Maid
	local clone = FX:Clone()
	task.delay(35, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	local weld = Instance.new("Weld")

	if clone:IsA("Model") then
		weld.Part0 = clone.PrimaryPart
	else
		weld.Part0 = clone
		clone.CanCollide = false
		clone.Massless = true
		clone.Anchored = false
	end

	weld.Part1 = P
	weld.C0 = C0
	weld.Parent = clone
	clone.Parent = Library.EFP
	maid:give(clone)
	weld.Name = "FXWELD"
	return clone, weld
end

function Library.QuickFX(data)
	local FX = data.FX
	local anchor = data.Anchor
	local maid = data.Maid

	if data.Ray then
		local raycastResult = workspace:Raycast(anchor.Position, createVector(0, -10, 0), raycastParams)

		if not raycastResult then
			return
		end

		local orientation, v, v2 = anchor:ToOrientation()
		anchor = CFrame.new(raycastResult.Position) * CFrame.Angles(orientation, v, v2)
	end

	local clone = FX:Clone()

	if clone:IsA("Model") then
		clone:PivotTo(anchor)
	elseif clone:IsA("BasePart") then
		clone.CFrame = anchor
	end

	if clone:IsA("Attachment") then
		clone.Parent = anchor
	else
		clone.Parent = Library.EFP
	end

	maid:give(clone)
	return clone
end

function Library.LifeScale(p)
	local FX = p.FX
	local scale = p.Scale
	local v, v2 = collectEmitters(FX)

	for i = 1, v2 do
		local v3 = v[i]
		local lifetime = v3.Lifetime
		v3.Lifetime = NumberRange.new(lifetime.Min * scale, lifetime.Max * scale)
	end
end

function Library.dtwait(p)
	local total = 0

	while total < p do
		total += RunService.Heartbeat:Wait()
	end

	return total
end

function Library.RaiseZIndex(p)
	local FX = p.FX
	local count = p.Count
	local v, v2 = collectEmitters(FX)

	for i = 1, v2 do
		v[i].ZOffset += count
	end
end

function Library.Yield(data)
	local time = data.Time or 5
	local char = data.Char
	local event = data.Event
	local lastTime = tick()

	while tick() - lastTime < time do
		local child = char:FindFirstChild(event)

		if child then
			return child
		else
			Library.dtwait(0.01)
		end
	end
end

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

function Library.PlayAttachment(folder, time, p2)
	local position = nil

	if folder:IsA("Attachment") then
		position = folder.WorldCFrame.Position
	elseif folder:IsA("BasePart") then
		position = folder.Position
	elseif folder:IsA("Model") then
		position = folder:GetPivot().Position
	end

	local descendants = folder:GetDescendants()
	local v = false

	for i = 1, #descendants do
		local emitter = descendants[i]

		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local name = string.lower(emitter.Name)

		if not (string.match(name, "smoke") or string.match(name, "dust")) then
			continue
		end

		v = true
		break
	end

	local colorSequence = nil

	if v and position then
		local raycastResult = workspace:Raycast(
			position + createVector(0, 1, 0),
			createVector(0, -10, 0),
			raycastParams
		)

		if raycastResult then
			colorSequence = ColorSequence.new(raycastResult.Instance.Color)
		end
	end

	local decrease = p2 and p2.Decrease
	local tweenTime = p2 and p2.TweenTime or 0.5
	local v2 = tweenTime == 0.5 and tweenInfo or TweenInfo.new(
		tweenTime,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out
	)

	for i = 1, #descendants do
		local instance = descendants[i]

		if instance:IsA("ParticleEmitter") then
			if colorSequence then
				local name = string.lower(instance.Name)

				if string.match(name, "smoke") or string.match(name, "dust") then
					instance.Color = colorSequence
				end
			end

			local attributes = instance:GetAttributes()
			local emitDelay = attributes.EmitDelay
			local emitCount = attributes.EmitCount
			local emitDuration = attributes.EmitDuration
			local v3 = decrease or 1

			if emitDelay then
				local emitCount2 = emitCount
				local v5 = instance
				local v6 = v3
				local emitDuration2 = emitDuration
				task.delay(emitDelay, function()
					if emitCount2 then
						shared.smartEmit(v5, emitCount2 / v6)
					end

					if emitDuration2 then
						v5.Enabled = true
						task.delay(emitDuration2, function()
							v5.Enabled = false
						end)
					end
				end)
			else
				if emitCount then
					shared.smartEmit(instance, emitCount / v3)
				end

				if emitDuration then
					instance.Enabled = true
					local v4 = instance
					task.delay(emitDuration, function()
						v4.Enabled = false
					end)
				end
			end
		elseif instance:IsA("PointLight") then
			if time then
				Library.PlayTween(instance, {
					EasingStyle = "Sine",
					Time = time,
					Goal = {
						Brightness = 0
					}
				})
			end
		elseif instance:IsA("Beam") then
			local attributes = instance:GetAttributes()
			local duration = attributes.Duration
			TweenService:Create(instance, v2, {
				Width0 = attributes.Width0,
				Width1 = attributes.Width1
			}):Play()

			if duration then
				local v3 = instance
				task.delay(duration, function()
					TweenService:Create(v3, v2, {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end
	end

	if time then
		Debris:AddItem(folder, time)
	end
end

Library.FastSpawn = require(script.FastSpawn)

function Library.RandomRot()
	return CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
end

function Library.PlayMesh(data)
	task.spawn(function()
		local model = data.Model
		local start = model:FindFirstChild("Start")
		local firstChild = model:FindFirstChild("End")

		if not (start and firstChild) then
			warn("NO START OR END")
			return
		end

		local info = data.Info or TweenInfo.new(1, Enum.EasingStyle.Sine)
		local stay = data.Stay
		local anchor = data.Anchor
		local endT = data.EndT or 1
		local del = data.Del
		local skip = data.Skip
		model.PrimaryPart = start

		if not skip then
			local children = model:GetChildren()

			for i = 1, #children do
				local part = children[i]

				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.Anchored = true
			end
		end

		if anchor then
			model:PivotTo(anchor)
		end

		if data.T then
			start.Transparency = data.T
		end

		firstChild.Transparency = 1
		model.Parent = Library.EFP
		local specialMesh = start:FindFirstChildOfClass("SpecialMesh")
		local specialMesh2 = firstChild:FindFirstChildOfClass("SpecialMesh")
		local decal = start:FindFirstChildOfClass("Decal")
		local decal2 = firstChild:FindFirstChildOfClass("Decal")

		if decal2 and not skip then
			decal2.Transparency = 1
		end

		local count = 0
		local decals

		if decal then
			local children = start:GetChildren()
			decals = {}

			for i = 1, #children do
				local decal3 = children[i]

				if not decal3:IsA("Decal") then
					continue
				end

				count += 1
				decals[count] = decal3
			end
		else
			decals = nil
		end

		local size = firstChild.Size
		local cFrame = firstChild.CFrame
		local scale = specialMesh2 and specialMesh2.Scale
		local v = nil

		if del then
			TweenService:Create(start, info, {
				Size = size,
				CFrame = cFrame
			}):Play()
			task.delay(del, function()
				v = TweenService:Create(start, info, {
					Transparency = endT
				})
				v:Play()

				if decals then
					for i = 1, count do
						TweenService:Create(decals[i], info, {
							Transparency = endT
						}):Play()
					end
				end

				if specialMesh and scale then
					TweenService:Create(specialMesh, info, {
						Scale = scale
					}):Play()
				end
			end)
		else
			if specialMesh and scale then
				TweenService:Create(specialMesh, info, {
					Scale = scale
				}):Play()
			end

			if decals then
				for i = 1, count do
					TweenService:Create(decals[i], info, {
						Transparency = endT
					}):Play()
				end

				v = TweenService:Create(start, info, {
					Size = size,
					CFrame = cFrame
				})
			else
				v = TweenService:Create(start, info, {
					Size = size,
					Transparency = endT,
					CFrame = cFrame
				})
			end

			v:Play()
		end

		if not stay then
			if del then
				task.wait(del + 0.1)
			end

			if v then
				v.Completed:Connect(function()
					model:Destroy()
				end)
			else
				model:Destroy()
			end
		end
	end)
end

function Library.PlayFlipBook(data)
	local mesh = data.Mesh
	local delta = data.Delta or 0.02
	local DWC = data.DWC
	local v = data.Repeat or 1
	local FPS = data.FPS or 1
	local _ = data.Loop
	local folder = mesh:FindFirstChild("Folder")
	local decal = mesh:FindFirstChild("Decal")
	local v2 = DWC == nil or DWC

	if folder and decal then
		Library.FastSpawn(function()
			local children = folder:GetChildren()
			local count = #children
			local v3 = children[count]
			local v4 = {}

			for i = 1, count do
				v4[children[i].Name] = children[i]
			end

			for _ = 1, v do
				if not mesh:IsDescendantOf(workspace) then
					break
				end

				for i = 1, count, FPS do
					local v5 = v4[tostring(i)] or v3

					if v5 then
						decal.Texture = v5.Texture
					end

					if delta == "Step" then
						RunService.RenderStepped:Wait()
					else
						Library.dtwait(delta)
					end
				end
			end

			if v2 then
				mesh:Destroy()
			end
		end)
	end
end

local CameraShaker = require(script.CameraShaker)
local camera = workspace.Camera

local function ShakeCamera(p)
	camera.CFrame *= p
end

local v = Enum.RenderPriority.Camera.Value + 1
local v2 = CameraShaker.new(v, ShakeCamera)

function Library.CamShake(p, p2, p3)
	if RunService:IsClient() and _G.ServerRunning then
		if p == "Stop" then
			CameraShaker:Stop()
			return
		end

		CameraShaker:Stop()

		if not (p3 and p3 < (workspace.CurrentCamera.CFrame.Position - p2).Magnitude) then
			v2:Start()
			v2:Shake(CameraShaker.Presets[p])
			return true
		end
	end
end

function Library.GlassLight(parent)
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Parent = parent
end

return Library