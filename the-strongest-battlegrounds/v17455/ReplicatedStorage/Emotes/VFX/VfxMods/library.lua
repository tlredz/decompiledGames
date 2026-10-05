local createVector = vector.create
local Library = {
	EFP = game.Workspace.Thrown
}
local BoatTween = require(script.BoatTween)
local TweenService = game:GetService("TweenService")

function Library.ProcessPart(data)
	local maid = data.Maid
	local FX = data.FX
	local part = data.Part
	local debri = data.Debri or 10
	local v = maid:give(FX:Clone())

	for _, child in pairs(v:GetChildren()) do
		maid:give(child)
		game.Debris:AddItem(child, debri)
		child.Parent = part
	end
end

function Library.PlayTween(p, p2, callback)
	local v = BoatTween:Create(p, p2)
	v:Play()
	local completedConnection = v.Completed:Once(function()
		if callback then
			callback()
		end

		v:Destroy()
	end)
	task.delay(p2.Time, function()
		completedConnection:Disconnect()
		v:Destroy()
	end)
end

Library.Maid = require(script.Maid)
Library.Bezier = require(script.Bezier)

function Library.Impact(instance)
	local clone = instance:Clone()
	clone.Parent = game.Lighting
	delay(0.1, function()
		clone:Destroy()
	end)
end

function Library.ChangeParticleColor(data)
	local particle = data.Particle
	local color = data.Color
	local position = data.Position or data.Pos
	local v = {}

	if particle:IsA("ParticleEmitter") then
		table.insert(v, particle)
	else
		for _, emitter in pairs(particle:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				table.insert(v, emitter)
			end
		end
	end

	for _, v2 in pairs(v) do
		if color then
			local v3 = { ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color) }
			v2.Color = ColorSequence.new(v3)
		else
			local ray = Ray.new(position, createVector(0, -100, 0))
			local part = game.Workspace:FindPartOnRayWithWhitelist(ray, { game.Workspace.World })

			if part then
				local v3 = { ColorSequenceKeypoint.new(0, part.Color), ColorSequenceKeypoint.new(1, part.Color) }
				v2.Color = ColorSequence.new(v3)
			end
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { game.Workspace.Built, game.Workspace.Map }

function Library.SetSmoke(data)
	local FX = data.FX
	local dist = data.Dist or 20
	local anchor = data.Anchor
	local raycastResult = game.Workspace:Raycast(anchor.Position, Vector3.new(0, -dist, 0), raycastParams)

	if not raycastResult then
		return
	end

	local v = {
		ColorSequenceKeypoint.new(0, raycastResult.Instance.Color),
		ColorSequenceKeypoint.new(1, raycastResult.Instance.Color)
	}

	for _, emitter in pairs(FX:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Color = ColorSequence.new(v)
		end
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

function Library.Able(p)
	local FX = p.FX

	if p.On then
		for _, emitter in pairs(FX:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	else
		for _, emitter in pairs(FX:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
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
		for _, effect in pairs(clone:GetDescendants()) do
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
			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			for _, descendant in pairs(clone:GetDescendants()) do
				if not (descendant:IsA("ParticleEmitter") and descendant.Enabled == true or descendant:IsA("Beam") or descendant:IsA("Texture") or descendant:IsA("Decal")) then
					continue
				end

				descendant:Destroy()
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
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

			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(1.5)

			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
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
	local weld = Instance.new("Weld")

	if clone:IsA("Model") then
		weld.Part0 = clone.PrimaryPart
	else
		weld.Part0 = clone
	end

	weld.Part1 = P
	weld.C0 = C0
	weld.Parent = clone
	clone.Parent = Library.EFP
	maid:give(clone)
	return clone, weld
end

function Library.QuickFX(data)
	local FX = data.FX
	local anchor = data.Anchor
	local maid = data.Maid

	if data.Ray then
		local raycastResult = game.Workspace:Raycast(anchor.Position, createVector(0, -10, 0), raycastParams)

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

	for _, emitter in pairs(FX:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * scale, emitter.Lifetime.Max * scale)
		end
	end
end

function Library.dtwait(p)
	local total = 0

	while total < p do
		local RunService = game:GetService("RunService")
		total += RunService.Heartbeat:Wait()
	end

	return total
end

function Library.RaiseZIndex(p)
	local FX = p.FX
	local count = p.Count

	for _, emitter in pairs(FX:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.ZOffset += count
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
		for _, effect in pairs(clone:GetDescendants()) do
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
			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			for _, descendant in pairs(clone:GetDescendants()) do
				if not (descendant:IsA("ParticleEmitter") and descendant.Enabled == true or descendant:IsA("Beam") or descendant:IsA("Texture") or descendant:IsA("Decal")) then
					continue
				end

				descendant:Destroy()
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
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

			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(1.5)

			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Transparency = 1
					}):Play()
				end
			end

			task.wait(0.5)
			clone:Destroy()
		end)
	end
end

function Library.PlayAttachment(folder, time, p2)
	local primaryPart

	if not (folder:IsA("Part") or not folder:IsA("Model")) then
		primaryPart = folder.PrimaryPart
	end

	if primaryPart then
		game.Workspace:Raycast(primaryPart.Position, createVector(0, -10, 0), raycastParams)
	end

	local position = nil

	if folder:IsA("Attachment") then
		position = folder.WorldCFrame.Position
	elseif folder:IsA("BasePart") then
		position = folder.Position
	elseif folder:IsA("Model") then
		position = folder:GetPivot().Position
	end

	local raycastResult = game.Workspace:Raycast(position, createVector(0, -10, 0), raycastParams)

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			local attributes = descendant:GetAttributes()
			local emitDelay = attributes.EmitDelay
			local repeatCount = attributes.RepeatCount or 1
			local repeatDelay = attributes.RepeatDelay

			if raycastResult and (string.match(string.lower(descendant.Name), "smoke") or string.match(
				string.lower(descendant.Name),
				"dust"
			)) then
				descendant.Color = ColorSequence.new(raycastResult.Instance.Color)
			end

			local v3 = descendant
			task.spawn(function()
				for i = 1, repeatCount do
					if emitDelay then
						task.delay(emitDelay, function()
							v3:Emit(attributes.EmitCount)
						end)
					else
						v3:Emit(attributes.EmitCount)
					end

					if attributes.EmitDuration then
						v3.Enabled = true
						task.delay(attributes.EmitDuration, function()
							v3.Enabled = false
						end)
					end

					if repeatDelay then
						task.wait(repeatDelay)
					end
				end
			end)
		end

		if descendant:IsA("PointLight") and time then
			Library.PlayTween(descendant, {
				EasingStyle = "Sine",
				Time = time,
				Goal = {
					Brightness = 0
				}
			})
		end

		if not descendant:IsA("Beam") then
			continue
		end

		local attributes = descendant:GetAttributes()
		local duration = attributes.Duration
		local v = not (p2 and p2.TweenTime) and 0.5 or p2.TweenTime
		local v2 = descendant

		local function Shut_OFF()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(v2, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Width1 = 0,
				Width0 = 0
			}):Play()
		end

		local v3 = descendant

		local function Turn_ON()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(v3, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Width1 = attributes.Width1,
				Width0 = attributes.Width0
			}):Play()
		end

		Turn_ON()

		if not duration then
			continue
		end

		local Shut_OFF2 = Shut_OFF
		task.delay(duration, function()
			Shut_OFF2()
		end)
	end

	if time then
		game.Debris:AddItem(folder, time)
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

Library.FastSpawn = require(script.FastSpawn)

function Library.RandomRot()
	return CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
end

function Library.PlayMesh(data)
	task.spawn(function()
		local model = data.Model
		local info = data.Info or TweenInfo.new(1, Enum.EasingStyle.Sine)
		local start = model:FindFirstChild("Start")
		local firstChild = model:FindFirstChild("End")
		local stay = data.Stay
		local anchor = data.Anchor
		local endT = data.EndT or 1
		local del = data.Del
		local skip = data.Skip

		if not (start and firstChild) then
			warn("NO START OR END")
			return
		end

		model.PrimaryPart = start

		if not skip then
			for _, part in pairs(model:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.Anchored = true
			end
		end

		if anchor then
			model:SetPrimaryPartCFrame(anchor)
		end

		if data.T then
			start.Transparency = data.T
		end

		firstChild.Transparency = 1
		model.Parent = Library.EFP
		local decal = start:FindFirstChildOfClass("Decal")
		local specialMesh = start:FindFirstChildOfClass("SpecialMesh")
		local specialMesh2 = firstChild:FindFirstChildOfClass("SpecialMesh")
		local decal2 = firstChild:FindFirstChildOfClass("Decal")

		if decal2 and not skip then
			decal2.Transparency = 1
		end

		local v = nil

		if del then
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(start, info, {
				Size = firstChild.Size,
				CFrame = firstChild.CFrame
			}):Play()
			task.delay(del, function()
				local TweenService3 = game:GetService("TweenService")
				v = TweenService3:Create(start, info, {
					Transparency = endT
				})
				v:Play()

				if decal then
					for _, decal3 in pairs(start:GetChildren()) do
						if not decal3:IsA("Decal") then
							continue
						end

						local TweenService4 = game:GetService("TweenService")
						TweenService4:Create(decal3, info, {
							Transparency = endT
						}):Play()
					end
				end

				if specialMesh then
					local TweenService4 = game:GetService("TweenService")
					v = TweenService4:Create(specialMesh, info, {
						Scale = specialMesh2.Scale
					}):Play()
				end
			end)
		else
			if specialMesh then
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(specialMesh, info, {
					Scale = specialMesh2.Scale
				}):Play()
			end

			if decal then
				for _, decal3 in pairs(start:GetChildren()) do
					if not decal3:IsA("Decal") then
						continue
					end

					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(decal3, info, {
						Transparency = endT
					}):Play()
				end

				local TweenService2 = game:GetService("TweenService")
				v = TweenService2:Create(start, info, {
					Size = firstChild.Size,
					CFrame = firstChild.CFrame
				})
				v:Play()
			else
				local TweenService2 = game:GetService("TweenService")
				v = TweenService2:Create(start, info, {
					Size = firstChild.Size,
					Transparency = endT,
					CFrame = firstChild.CFrame
				})
				v:Play()
			end
		end

		if not stay then
			if del then
				task.wait(del + 0.1)
			end

			v.Completed:Connect(function()
				model:Destroy()
			end)
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
			for _ = 1, v do
				if not mesh:IsDescendantOf(game.Workspace) then
					break
				end

				for i = 1, #folder:GetChildren(), FPS do
					local v3 = folder:FindFirstChild((tostring(i))) or folder:GetChildren()[#folder:GetChildren()]

					if v3 then
						decal.Texture = v3.Texture
					end

					if delta == "Step" then
						local RunService = game:GetService("RunService")
						RunService.RenderStepped:Wait()
					else
						Library.dtwait(delta)
					end
				end
			end

			if v2 and v2 ~= false then
				mesh:Destroy()
			end
		end)
	end
end

local CameraShaker = require(script.CameraShaker)
local camera = game.Workspace.Camera

local function ShakeCamera(p)
	camera.CFrame *= p
end

local v = Enum.RenderPriority.Camera.Value + 1
local v2 = CameraShaker.new(v, ShakeCamera)
game:GetService("RunService")

function Library.CamShake(p, p2, p3)
	local RunService = game:GetService("RunService")

	if RunService:IsClient() and _G.ServerRunning then
		if p == "Stop" then
			CameraShaker:Stop()
			return
		end

		CameraShaker:Stop()

		if not (p3 and p3 < (game.Workspace.CurrentCamera.CFrame.Position - p2).Magnitude) then
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