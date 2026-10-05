local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
require3(script.Parent.Types)
local v = require3(ReplicatedStorage2.Shared.FastUtils)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Common.StudioLogger)
local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Explosions)
local v6 = require3(ReplicatedStorage2.Shared.CherubVariants)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local shake = localPlayer:WaitForChild("PlayerScripts"):WaitForChild("EffectScripts"):WaitForChild("ClientFX"):WaitForChild("Shake")
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.RespectCanCollide = false
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function createInstance(className: string, items, parent)
	local instance = Instance.new(className)

	if items then
		for k, item in items do
			instance[k] = item
		end
	end

	if parent then
		instance.Parent = parent
	end

	return instance
end

local function parseCFrame(cFrame)
	if cFrame == nil then
		return CFrame.identity
	end

	if typeof(cFrame) == "CFrame" then
		return cFrame
	end

	local v7, v8, v9 = string.match(cFrame, "([%d%.%-]*), ([%d%.%-]*), ([%d%.%-]*)")
	return CFrame.new(tonumber(v7) or 0, tonumber(v8) or 0, tonumber(v9) or 0)
end

local function parseVector(value)
	if value == nil then
		return createVector(0, 0, 0)
	end

	if typeof(value) == "Vector3" then
		return value
	end

	local v7, v8, v9 = string.match(value, "([%d%.%-]*), ([%d%.%-]*), ([%d%.%-]*)")
	return (Vector3.new(tonumber(v7) or 0, tonumber(v8) or 0, tonumber(v9) or 0))
end

local function autoPlay(data)
	local explodePosition = data.ExplodePosition
	local instance = data.Instance
	Debris:AddItem(instance, 10)
	local enableTime = instance:GetAttribute("EnableTime")
	local v7 = {}

	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			local v8 = descendant
			task.delay(descendant:GetAttribute("EmitDelay") or 0, function()
				if not enableTime then
					v8:Emit(data.EmissionMultiplier * (v8:GetAttribute("EmitCount") or 0))
					return
				end

				v8.Enabled = true
				task.wait(enableTime)
				v8.Enabled = false
			end)
		elseif descendant:IsA("Beam") then
			local v8 = descendant
			task.spawn(function()
				local enableTime2 = v8:GetAttribute("EnableTime") or enableTime

				if not enableTime2 then
					v4.print()("Attempted to enable beam without EnableTime attribute")
					return
				end

				v8.Enabled = true

				if v8:GetAttribute("Width0") and v8:GetAttribute("Width1") and v8:GetAttribute("Duration") then
					local fadeInTime = v8:GetAttribute("FadeInTime") or 0.5
					local fadeOutTime = v8:GetAttribute("FadeOutTime") or 0.5
					local tweenInfo = TweenInfo.new(fadeInTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
					local tweenInfo2 = TweenInfo.new(fadeOutTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
					TweenService:Create(v8, tweenInfo, {
						Width0 = v8:GetAttribute("Width0") or 0,
						Width1 = v8:GetAttribute("Width1") or 0
					}):Play()
					task.delay(v8:GetAttribute("Duration"), function()
						TweenService:Create(v8, tweenInfo2, {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end

				task.wait(enableTime2)
				v8.Enabled = false
			end)
		elseif descendant:IsA("Sound") then
			descendant:Play()
		elseif descendant:IsA("BasePart") then
			if descendant.Name == "GROUND" then
				raycastParams.FilterDescendantsInstances = {
					instance,
					workspace.Dead,
					workspace.Alive,
					workspace.MapBounds,
					workspace.Runtime
				}
				local _ = descendant:FindFirstChild("Groundfx") == nil
				local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

				if raycastResult then
					descendant.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
				else
					descendant.Position = explodePosition
				end
			else
				v7[descendant] = instance.CFrame:ToObjectSpace(descendant.CFrame)
			end

			if enableTime and instance.Name == "Void Blast" then
				local v8 = descendant
				task.delay(enableTime, function()
					v8.Transparency = 1
				end)
			end
		elseif descendant:IsA("Light") and enableTime then
			local v8 = descendant
			task.delay(enableTime, function()
				v8.Enabled = false
			end)
		end
	end

	instance.Position = explodePosition

	for k, v8 in v7 do
		k.Position = instance.CFrame:ToWorldSpace(v8).Position
	end
end

local function stickToGround(p, data)
	local instance = p.Instance
	local explodePosition = p.ExplodePosition
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	instance.Position = explodePosition

	if data.autoPlay then
		autoPlay(p)
	else
		v3.Visual:PlayEffects(instance)
	end

	local v7 = nil

	for _, part in instance:GetDescendants() do
		if not (part:IsA("BasePart") and part.Name == "GROUND") then
			continue
		end

		local raycastResult = workspace:Raycast(explodePosition, createVector(0, 1, 0) * data.depth, raycastParams)

		if raycastResult then
			part.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
		else
			part.Position = explodePosition
		end

		v7 = part
	end

	local child = instance:FindFirstChild(data.child)

	if v7 and child then
		local pivot = child:GetPivot()
		local origin = data.origin or createVector(0, 0, 0)
		local position

		if data.useGroundXZ then
			position = v7.Position
		else
			position = pivot.Position
		end

		local vector2 = Vector3.new(
			position.X + (data.offsetX or 0) + origin.X,
			v7.Position.Y + data.offsetY + origin.Y,
			position.Z + origin.Z
		)
		local v8 = CFrame.new(vector2) * CFrame.Angles(pivot:ToEulerAnglesXYZ())
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = pivot
		cFrameValue.Changed:Connect(function(cframe)
			child:PivotTo(cframe)
		end)
		TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = v8
		}):Play()
		Debris:AddItem(child, data.swordDebris)
	end

	Debris:AddItem(instance, 8)
end

local Explosions = {
	Blackhole = function(p)
		local instance = p.Instance
		local emissionMultiplier = p.EmissionMultiplier
		Debris:AddItem(instance, 8)
		local ff = instance.Ff
		ff.Position = instance.Position
		local chargeATT = instance.ChargeATT
		local explodeATT = instance.ExplodeATT
		local pointLight = chargeATT.PointLight
		task.spawn(function()
			instance.Size = createVector(7.25, 7.25, 7.25)
			ff.Size = createVector(8.25, 8.25, 8.25)
			chargeATT.Sound:Play()
			chargeATT.Sound1:Play()
			TweenService:Create(
				pointLight,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Range = 15
				}
			):Play()
			local tweenInfo2 = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 3, true, 0)
			TweenService:Create(instance, tweenInfo2, {
				Size = createVector(6.5, 6.5, 6.5)
			}):Play()
			TweenService:Create(ff, tweenInfo2, {
				Size = createVector(7.5, 7.5, 7.5)
			}):Play()
			local clone = ff:Clone()
			clone.Size = createVector(0, 0, 0)
			clone.Parent = instance
			Debris:AddItem(clone, 1)
			TweenService:Create(
				clone,
				TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(20, 20, 20),
					Transparency = 1
				}
			):Play()
			task.wait(0.15)
			ff.Size = createVector(8, 8, 8)
			instance.Size = createVector(7, 7, 7)

			for _, emitter in pairs(chargeATT:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				TweenService:Create(
					emitter,
					TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
					{
						Rate = 0
					}
				):Play()
			end

			local tweenInfo4 = TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false, 0)
			TweenService:Create(instance, tweenInfo4, {
				Size = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(ff, tweenInfo4, {
				Size = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(
				pointLight,
				TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
				{
					Range = 0
				}
			):Play()
			local tweenInfo6 = TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false, 0)
			TweenService:Create(chargeATT.Sound, tweenInfo6, {
				Volume = 0
			}):Play()
			task.wait(3)

			for _, emitter in pairs(chargeATT:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local tweenInfo7 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
			TweenService:Create(explodeATT.PointLight, tweenInfo7, {
				Range = 15
			}):Play()
			shake:Fire(instance.Position)
			explodeATT.Flash:Emit(emissionMultiplier * 2)
			explodeATT.Flash2:Emit(emissionMultiplier * 1)
			explodeATT.d:Emit(emissionMultiplier * 3)
			explodeATT.smoke:Emit(emissionMultiplier * 40)
			explodeATT.zippies:Emit(emissionMultiplier * 60)
			explodeATT.zoippers1:Emit(emissionMultiplier * 50)
			explodeATT.Sound1:Play()
			explodeATT.Sound2:Play()
			task.wait(0.1)
			explodeATT.Sound3:Play()
		end)
	end,
	Explosion = function(p)
		local instance = p.Instance
		local emissionMultiplier = p.EmissionMultiplier
		Debris:AddItem(instance, 5)
		local sfx = instance.sfx
		sfx.PlaybackSpeed = math.random(75, 125) * 0.01
		sfx:Play()
		local att = instance.att
		local pointLight = att.PointLight
		att.fire:Emit(emissionMultiplier * 15)
		att.fireflies:Emit(emissionMultiplier * 25)
		att.smoke:Emit(emissionMultiplier * 10)
		TweenService:Create(
			pointLight,
			TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{
				Range = 15
			}
		):Play()
		shake:Fire(instance.Position)
		task.spawn(function()
			task.wait(0.05)
			local shockwave = att:FindFirstChild("shockwave")

			if shockwave then
				shockwave:Emit(emissionMultiplier * 10)
			end

			task.wait(0.05)
			local fireshockwave = att:FindFirstChild("fireshockwave")

			if fireshockwave then
				fireshockwave:Emit(emissionMultiplier * 10)
			end
		end)
	end,
	Lightning = function(p)
		local instance = p.Instance
		local emissionMultiplier = p.EmissionMultiplier
		Debris:AddItem(instance, 5)
		local sound = instance.Sound
		sound.PlaybackSpeed = math.random(75, 125) * 0.01
		sound:Play()
		local att = instance.att
		att.smoke:Emit(emissionMultiplier * 20)
		att.zapper:Emit(emissionMultiplier * 1)
		att.zippies:Emit(emissionMultiplier * 40)
		TweenService:Create(
			att.PointLight,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{
				Range = 15
			}
		):Play()
		shake:Fire(instance.Position)
		task.spawn(function()
			task.wait(0.1)
			att.d:Emit(emissionMultiplier * 3)
			task.wait(0.1)
			att.zoippers1:Emit(emissionMultiplier * 30)
		end)
	end,
	Waterblast = function(p)
		local instance = p.Instance
		local emissionMultiplier = p.EmissionMultiplier
		Debris:AddItem(instance, 5)
		instance.sfx:Play()
		local att = instance.att
		att.Water:Emit(emissionMultiplier * 50)
		att.bing:Emit(emissionMultiplier * 30)
		att.flip:Emit(emissionMultiplier * 1)
		att.drops:Emit(emissionMultiplier * 50)
		shake:Fire(instance.Position)
		local groundFx = instance:FindFirstChild("GroundFx")

		if groundFx then
			groundFx.Position = instance.Position
			local raycastParams2 = RaycastParams.new()
			raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams2.FilterDescendantsInstances = { workspace.Alive }
			local raycastResult = workspace:Raycast(groundFx.Position, (createVector(0, -1, 0)).Unit * 10)
			task.spawn(function()
				task.wait(0.05)
				att.shockwave:Emit(emissionMultiplier * 10)

				if raycastResult then
					groundFx.Position = raycastResult.Position
					task.wait(0.275)
					groundFx.splishies:Emit(emissionMultiplier * 10)
				end
			end)
		end
	end,
	Sakura = function(p)
		local emissionMultiplier = p.EmissionMultiplier
		local instance = p.Instance
		Debris:AddItem(instance, 9)
		local tree = instance.Tree
		local att = instance.att
		shake:Fire(instance.Position)
		att.pew:Emit(emissionMultiplier * 50)
		att.bing:Emit(emissionMultiplier * 30)
		att.drops:Emit(emissionMultiplier * 50)
		att.shockwave:Emit(emissionMultiplier * 10)
		instance.sfx:Play()
		task.spawn(function()
			att.Beam.Enabled = true
			task.wait(1.1)
			att.Beam.Enabled = false
		end)
		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams2.FilterDescendantsInstances = { instance, workspace.Alive }
		local raycastResult = workspace:Raycast(instance.Position, -Vector3.yAxis.Unit * 100, raycastParams2)

		if raycastResult then
			tree:MoveTo(raycastResult.Position + createVector(0, 10.5, 0))
			instance.Connection.Position = raycastResult.Position
			instance.Connection.magic:Play()
			instance.Connection.pigeon:Play()
			task.spawn(function()
				local WAIT_INTERVAL = 0.2

				local function wavezz()
					local clone = ReplicatedStorage2.Misc.Wave:Clone()
					clone.Parent = workspace.Runtime
					Debris:AddItem(clone, 1.5)
					clone.Transparency = 1
					clone.Size = createVector(50, 0.5, 50)
					local leaves = tree:FindFirstChild("Leaves")
					local vanity = leaves and leaves:FindFirstChild("Vanity")

					if vanity then
						clone.Color = vanity.Color
					end

					clone.CFrame = instance.Connection.CFrame
					game.TweenService:Create(
						clone,
						TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(0.01, 0.5, 0.01),
							Transparency = 0
						}
					):Play()
				end

				wavezz()
				task.wait(WAIT_INTERVAL)
				wavezz()
				task.wait(WAIT_INTERVAL)
				wavezz()
				task.wait(WAIT_INTERVAL)
				wavezz()
				task.wait(WAIT_INTERVAL)
				wavezz()
			end)

			for _, descendant in pairs(tree:GetDescendants()) do
				local part = descendant
				task.spawn(function()
					if part.Name == "Vanity" then
						local size = part.Size
						part.Transparency = 0
						part.Size = createVector(0, 0, 0)
						task.wait(0.9)
						local v7 = math.random(4, 6) * 0.1
						TweenService:Create(
							part,
							TweenInfo.new(v7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = size * 1.15
							}
						):Play()
						task.wait(v7)
						TweenService:Create(
							part,
							TweenInfo.new(v7 / 7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = size
							}
						):Play()
					elseif part.Name == "Upz" then
						part.Transparency = 0
						local size = part.Size
						local cFrame = part.CFrame
						part.CFrame *= CFrame.new(0, -size.Y / 2, 0)
						part.Size = createVector(0, 0, 0)
						task.wait(part.Value.Value * 0.3)
						part.Size = Vector3.new(size.X, 0, size.Z)
						TweenService:Create(
							part,
							TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = part.Size + Vector3.new(0, size.Y, 0),
								CFrame = cFrame
							}
						):Play()
						task.wait(0.5)
					elseif part.Name == "Fp" then
						part.Transparency = 0
						local size = part.Size
						part.Size = createVector(0, 0, 0)
						task.wait(1.5)
						local v7 = math.random(5, 15) * 0.1
						TweenService:Create(
							part,
							TweenInfo.new(v7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = size
							}
						):Play()
					elseif part.Name == "Downroots" then
						part.Transparency = 0
						local size = part.Size
						part.Size = createVector(0, 0, 0)
						task.wait(0.3)
						local v7 = math.random(4, 5) * 0.1
						TweenService:Create(
							part,
							TweenInfo.new(v7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = size * 1.15
							}
						):Play()
						task.wait(v7)
						TweenService:Create(
							part,
							TweenInfo.new(v7 / 7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = size
							}
						):Play()
					elseif part.Name == "Branches" then
						part.Transparency = 0
						local size = part.Size
						part.Size = createVector(0, 0, 0)
						task.wait(0.6)
						local v7 = math.random(4, 5) * 0.1
						TweenService:Create(
							part,
							TweenInfo.new(v7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = size * 1.15
							}
						):Play()
						task.wait(v7)
						TweenService:Create(
							part,
							TweenInfo.new(v7 / 7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = size
							}
						):Play()
					end

					task.wait(4)

					if part:IsA("BasePart") and part.Name ~= "Particlepart" then
						local position = part.Position
						local parent = part.Parent and part.Parent.Parent

						if parent then
							local particlepart = parent:FindFirstChild("Particlepart")

							if particlepart then
								position = particlepart.Position
							end
						end

						TweenService:Create(
							part,
							TweenInfo.new(
								math.random(6, 12) * 0.1,
								Enum.EasingStyle.Linear,
								Enum.EasingDirection.Out,
								0,
								false,
								0
							),
							{
								Transparency = 0.5,
								Size = createVector(0, 0, 0),
								Position = position - createVector(0, 12, 0)
							}
						):Play()
					end
				end)
			end

			task.spawn(function()
				local particlepart = tree:FindFirstChild("Particlepart")

				if not particlepart then
					return
				end

				local particleEmitter = particlepart:FindFirstChild("ParticleEmitter")

				if not particleEmitter then
					return
				end

				task.wait(1)

				if particleEmitter then
					particleEmitter.Enabled = true
				end

				task.wait(3)

				if particleEmitter then
					particleEmitter.Enabled = false
				end
			end)
		end
	end,
	Matrix = function(p)
		local instance = p.Instance
		local emissionMultiplier = p.EmissionMultiplier
		Debris:AddItem(instance, 5)
		local sound = instance.Sound
		sound.PlaybackSpeed = math.random(75, 125) * 0.01
		sound:Play()
		instance.glitch:Play()
		local att = instance.att
		local pointLight = att.PointLight
		att.Particle2:Emit(emissionMultiplier * 10)
		att.Particle1:Emit(emissionMultiplier * 20)
		att.Specs1:Emit(emissionMultiplier * 20)
		att.Specs2:Emit(emissionMultiplier * 20)
		TweenService:Create(
			pointLight,
			TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{
				Range = 15
			}
		):Play()
	end,
	Arctic = function(p)
		local instance = p.Instance
		local emissionMultiplier = p.EmissionMultiplier
		Debris:AddItem(instance, 5)
		local sfx = instance.sfx
		sfx.PlaybackSpeed = math.random(75, 125) * 0.01
		sfx:Play()
		instance.shatter:Play()
		instance.Wind:Play()
		local attachment = instance.Attachment
		instance["25"]:Emit(emissionMultiplier * 25)
		attachment.ParticleEmitter:Emit(emissionMultiplier * 5)
		attachment.du:Emit(emissionMultiplier * 10)
		attachment.duoso:Emit(emissionMultiplier * 1)
		attachment.un:Emit(emissionMultiplier * 4)
		attachment.shockwave:Emit(emissionMultiplier * 10)
		attachment.smoke:Emit(emissionMultiplier * 10)
		instance.mee:Emit(emissionMultiplier * 35)
		instance.colorme:Emit(emissionMultiplier * 30)
	end,
	Runic = function(p)
		local instance = p.Instance
		local emissionMultiplier = p.EmissionMultiplier
		Debris:AddItem(instance, 5)
		local sfx = instance.sfx
		sfx.PlaybackSpeed = math.random(75, 125) * 0.01
		sfx:Play()
		instance.shatter:Play()
		local attachment = instance.Attachment
		instance.ParticleEmitter:Emit(emissionMultiplier * 10)
		instance.boo:Emit(emissionMultiplier * 20)
		attachment.un:Emit(emissionMultiplier * 5)
		attachment.smoke:Emit(emissionMultiplier * 20)
		attachment.shockwave:Emit(emissionMultiplier * 10)
		attachment.boospecs:Emit(emissionMultiplier * 30)
		attachment.mee:Emit(emissionMultiplier * 35)
	end,
	Exorcist = function(p)
		local explodePosition = p.ExplodePosition
		local instance = p.Instance
		Debris:AddItem(instance, 10)

		for _, descendant in instance:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant:Emit(descendant:GetAttribute("EmitCount"))
			elseif descendant:IsA("Sound") then
				descendant:Play()
			end
		end

		raycastParams.FilterDescendantsInstances = {
			instance,
			workspace.Dead,
			workspace.Alive,
			workspace.MapBounds,
			workspace.Runtime
		}
		local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

		if raycastResult then
			instance.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
		else
			instance.Position = explodePosition
		end

		instance.Position = explodePosition
	end,
	["Viper’s"] = function(p)
		local explodePosition = p.ExplodePosition
		local instance = p.Instance
		Debris:AddItem(instance, 10)
		local v7 = {}

		for _, descendant in instance:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
				local v8 = descendant
				task.delay(0.75, function()
					v8.Enabled = false
				end)
			elseif descendant:IsA("Sound") then
				descendant:Play()
			elseif descendant:IsA("BasePart") then
				if descendant.Name == "GROUND" then
					raycastParams.FilterDescendantsInstances = {
						instance,
						workspace.Dead,
						workspace.Alive,
						workspace.MapBounds,
						workspace.Runtime
					}
					local _ = descendant:FindFirstChild("Groundfx") == nil
					local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

					if raycastResult then
						descendant.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
					else
						descendant.Position = explodePosition
					end
				elseif not originModelParts[descendant] then
					v7[descendant] = instance.CFrame:ToObjectSpace(descendant.CFrame)
				end
			end
		end

		instance.Position = explodePosition

		for k, v8 in v7 do
			k.Position = instance.CFrame:ToWorldSpace(v8).Position
		end
	end,
	Christmas = function(p)
		local explodePosition = p.ExplodePosition
		local instance = p.Instance
		instance.Parent = workspace
		Debris:AddItem(instance, 10)

		for _, descendant in instance:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant:Emit(descendant:GetAttribute("EmitCount") or 1)
			elseif descendant:IsA("BasePart") then
				if descendant.Name == "GROUND" then
					raycastParams.FilterDescendantsInstances = {
						instance,
						workspace.Dead,
						workspace.Alive,
						workspace.MapBounds,
						workspace.Runtime
					}
					local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

					if raycastResult then
						descendant.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
					else
						descendant.Position = explodePosition
					end
				else
					descendant.Position = explodePosition
				end
			end
		end
	end,
	Firework = function(data)
		local explodePosition = data.ExplodePosition
		local instance = data.Instance
		raycastParams.FilterDescendantsInstances = {
			instance,
			workspace.Dead,
			workspace.Alive,
			workspace.MapBounds,
			workspace.Runtime
		}
		local cframe = CFrame.fromOrientation(-1.5707963267948966, 0, 0)
		local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

		if raycastResult then
			instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
		else
			instance:PivotTo(CFrame.new(explodePosition) * cframe)
		end

		Debris:AddItem(instance, 10)

		for _, emitter in instance:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") or emitter:IsDescendantOf(instance.BodyExplosion) then
				continue
			end

			emitter.Enabled = true
			local v7 = emitter
			task.delay(3, function()
				v7.Enabled = false
			end)
		end

		for _, effect in instance.BodyExplosion:GetDescendants() do
			if effect:IsA("ParticleEmitter") then
				local v7 = effect
				task.delay(effect:GetAttribute("EmitDelay") or 0, function()
					v7:Emit(data.EmissionMultiplier * v7:GetAttribute("EmitCount") or 0)
				end)
			elseif effect:IsA("Beam") then
				effect.Enabled = true
				local v7 = effect
				task.delay(3, function()
					v7.Enabled = false
				end)
			end
		end
	end,
	RIP = function(p)
		local explodePosition = p.ExplodePosition
		local instance = p.Instance
		raycastParams.FilterDescendantsInstances = {
			instance,
			workspace.Dead,
			workspace.Alive,
			workspace.MapBounds,
			workspace.Runtime
		}
		local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
		local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

		if raycastResult then
			instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
		else
			instance:PivotTo(CFrame.new(explodePosition) * cframe)
		end

		local pivot = instance:GetPivot()
		v3.Visual:PlayEffects(instance)
		instance.Tombstone.Transparency = 1
		TweenService:Create(
			instance.Tombstone,
			TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Transparency = 0
			}
		):Play()
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = -instance.Tombstone.Size.Y * 0.5
		numberValue.Changed:Connect(function(p2: number)
			instance.Tombstone:PivotTo(pivot + createVector(0, 1, 0) * p2)
		end)
		TweenService:Create(numberValue, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Value = instance.Tombstone.Size.Y * 0.5
		}):Play()
		task.delay(3.5, function()
			if instance and instance:FindFirstChild("Tombstone") then
				TweenService:Create(
					instance.Tombstone,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				):Play()
			end
		end)
		Debris:AddItem(instance, 5)
		Debris:AddItem(numberValue, 5)
	end,
	Specific = {}
}

Explosions.Specific["Slime Egg"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = -instance.Egg:GetExtentsSize().Y * 0.5
	numberValue.Changed:Connect(function(p2: number)
		instance.Egg:PivotTo(pivot + createVector(0, 1, 0) * p2)
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = instance.Egg:GetExtentsSize().Y * 0.5
	}):Play()
	Debris:AddItem(instance.Egg, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

Explosions.Specific["Chocolate Egg"] = Explosions.Specific["Slime Egg"]

Explosions.Specific["Cherry Blossom Tree"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = -instance.Tree:GetExtentsSize().Y * 0.5
	numberValue.Changed:Connect(function(p2: number)
		instance.Tree:PivotTo(pivot + createVector(0, 1, 0) * p2)
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = 0
	}):Play()
	Debris:AddItem(instance.Tree, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

Explosions.Specific["T-Rex Explosion"] = function(p)
	stickToGround(p, {
		autoPlay = false,
		child = "Tree",
		depth = -50,
		offsetY = 20,
		useGroundXZ = false,
		swordDebris = 3.8
	})
end

Explosions.Specific["Vampire Light"] = Explosions.Specific["T-Rex Explosion"]
Explosions.Specific["Bridal Revival"] = Explosions.Specific["T-Rex Explosion"]

Explosions.Specific["Eggsplosive Exit"] = function(player)
	local explodePosition = player.ExplodePosition
	local instance = player.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local egg = instance.Egg
	local player2 = instance.Player
	local clone = player2:Clone()
	clone.Parent = instance
	player2:Destroy()
	local v7 = false
	task.spawn(function()
		pcall(function()
			local character = player.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

			if humanoid then
				clone.Humanoid:ApplyDescription(humanoid:GetAppliedDescription())

				for _, accessory in clone:GetChildren() do
					if accessory:IsA("Accessory") then
						v3.Physics.ResizePart(accessory, 0.605)
					end
				end
			end
		end)
		v7 = true
	end)
	local track = egg.AnimationController.Animator:LoadAnimation(egg.Animation)
	local track2 = clone.Humanoid.Animator:LoadAnimation(clone.Animation)

	for _, v8 in clone:QueryDescendants("[Anchored=true]") do
		if v8.Name == "HumanoidRootPart" then
			continue
		end

		v8.Anchored = false
		v8.CanCollide = false
	end

	local total = 0

	while track2.Length <= 0 and track.Length <= 0 and not v7 and total < 5 do
		total += task.wait()
	end

	for _, child in instance.GROUND:GetChildren() do
		if child.Name == "Enable" then
			local folder = child
			task.delay((child:GetAttribute("Enable") or 0) / 60, function()
				for i, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end)
			local folder2 = child
			task.delay((child:GetAttribute("Disable") or 0) / 60, function()
				for i, emitter in folder2:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		else
			v3.Visual:PlayEffects(child)
		end
	end

	track2:Play()
	track:Play()
	print(clone, clone.Humanoid.Animator:GetPlayingAnimationTracks(), track2, track2.IsPlaying)
	print(clone:QueryDescendants("[Anchored=true]"))
	local threads = {}
	table.insert(threads, task.delay(0.9666666666666667, function()
		v3.Visual:PlayEffects(clone.Torso.Frame58)
	end))
	table.insert(threads, task.delay(5.6, function()
		v3.Visual:PlayEffects(clone.Torso.Frame336)
	end))
	track.Stopped:Once(function()
		instance:Destroy()

		for _, v8 in threads do
			v3.Thread.SafeCancel(v8)
		end
	end)
end

Explosions.Specific["Kitty Katana Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = instance.Sword:GetExtentsSize().Y
	local _ = numberValue.Value
	instance.Sword:PivotTo(pivot * CFrame.new(0, instance.Sword:GetExtentsSize().Y, 0) * CFrame.Angles(
		3.141592653589793,
		0,
		0
	))
	numberValue.Changed:Connect(function(p2: number)
		instance.Sword:PivotTo(pivot * CFrame.new(0, p2, 0) * CFrame.Angles(3.141592653589793, 0, 0))
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = 11.8
	}):Play()
	Debris:AddItem(instance.Sword, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

Explosions.Specific.Judgement = Explosions.Specific["Kitty Katana Explosion"]
Explosions.Specific["Fox Katana Explosion"] = Explosions.Specific["Kitty Katana Explosion"]
Explosions.Specific["Poisoned Bunny Explosion"] = Explosions.Specific["Kitty Katana Explosion"]

Explosions.Specific["Devil's Curse"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = instance.Sword:GetExtentsSize().Y
	local _ = numberValue.Value
	instance.Sword:PivotTo(pivot * CFrame.new(0, instance.Sword:GetExtentsSize().Y, 0) * CFrame.Angles(
		3.141592653589793,
		0,
		0
	))
	numberValue.Changed:Connect(function(p2: number)
		instance.Sword:PivotTo(pivot * CFrame.new(0, p2, 0) * CFrame.Angles(3.141592653589793, 0, 0))
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = 5
	}):Play()
	Debris:AddItem(instance.Sword, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

function Explosions.Specific.Eternal(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local pivot = instance.Sword1:GetPivot()
	cFrameValue.Changed:Connect(function(cframe2: CFrame)
		instance.Sword1:PivotTo(pivot * cframe2)
	end)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = instance.Sword1.Blade:GetAttribute("CFrame")
	}):Play()
	local cFrameValue2 = Instance.new("CFrameValue")
	cFrameValue2.Value = CFrame.identity
	local pivot2 = instance.Sword2:GetPivot()
	cFrameValue2.Changed:Connect(function(cframe2: CFrame)
		instance.Sword2:PivotTo(pivot2 * cframe2)
	end)
	TweenService:Create(cFrameValue2, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = instance.Sword2.Blade:GetAttribute("CFrame")
	}):Play()
	task.delay(3.9, function()
		v3.Visual:TurnOffVisuals(instance)
		local descendants = {}

		for _, descendant in instance.Sword1:GetDescendants() do
			table.insert(descendants, descendant)
		end

		for _, descendant in instance.Sword2:GetDescendants() do
			table.insert(descendants, descendant)
		end

		for _, instance2 in descendants do
			if instance2:IsA("BasePart") or instance2:IsA("Decal") then
				TweenService:Create(
					instance2,
					TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				):Play()
			elseif instance2:IsA("ParticleEmitter") or instance2:IsA("Beam") or instance2:IsA("Trail") then
				instance2.Enabled = false
			end
		end
	end)
	Debris:AddItem(instance.Sword1, 4)
	Debris:AddItem(instance.Sword2, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(cFrameValue2, 8)
end

Explosions.Specific["UFO Abduction"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = -instance.UFO:GetExtentsSize().Y * 0.5
	numberValue.Changed:Connect(function(p2: number)
		instance.UFO:PivotTo(pivot + createVector(0, 1, 0) * p2)
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = 20
	}):Play()
	Debris:AddItem(instance.UFO, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

Explosions.Specific["Pyramid Scheme"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = -instance.Pyramid:GetExtentsSize().Y * 0.5
	numberValue.Changed:Connect(function(p2: number)
		instance.Pyramid:PivotTo(pivot + createVector(0, 1, 0) * p2)
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = 10
	}):Play()
	Debris:AddItem(instance.Pyramid, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

Explosions.Specific["Zeus' Punishment"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = instance.Lightning:GetExtentsSize().Y
	local _ = numberValue.Value
	instance.Lightning:PivotTo(pivot * CFrame.new(0, instance.Lightning:GetExtentsSize().Y, 0) * CFrame.Angles(
		3.141592653589793,
		0,
		0
	))
	numberValue.Changed:Connect(function(p2: number)
		instance.Lightning:PivotTo(pivot * CFrame.new(0, p2, 0) * CFrame.Angles(3.141592653589793, 0, 0))
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = 5
	}):Play()
	Debris:AddItem(instance.Lightning, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

Explosions.Specific["Chroma Blade Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = instance.Blade:GetExtentsSize().Y
	local _ = numberValue.Value
	instance.Blade:PivotTo(pivot * CFrame.new(0, instance.Blade:GetExtentsSize().Y, 0) * CFrame.Angles(
		3.141592653589793,
		0,
		0
	))
	numberValue.Changed:Connect(function(p2: number)
		instance.Blade:PivotTo(pivot * CFrame.new(0, p2, 0) * CFrame.Angles(3.141592653589793, 0, 0))
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = 5
	}):Play()
	Debris:AddItem(instance.Blade, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

Explosions.Specific["Chroma Scythe Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local pivot = instance.Scythe:GetPivot()
	cFrameValue.Changed:Connect(function(cframe2: CFrame)
		instance.Scythe:PivotTo(pivot * cframe2)
	end)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = instance.Scythe["1"]:GetAttribute("CFrame")
	}):Play()
	Debris:AddItem(instance.Scythe, 4.5)
	Debris:AddItem(instance, 8)
end

Explosions.Specific["Dual Chroma Set Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local pivot = instance.Sword1:GetPivot()
	cFrameValue.Changed:Connect(function(cframe2: CFrame)
		instance.Sword1:PivotTo(pivot * cframe2)
	end)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = instance.Sword1["1"]:GetAttribute("CFrame")
	}):Play()
	local cFrameValue2 = Instance.new("CFrameValue")
	cFrameValue2.Value = CFrame.identity
	local pivot2 = instance.Sword2:GetPivot()
	cFrameValue2.Changed:Connect(function(cframe2: CFrame)
		instance.Sword2:PivotTo(pivot2 * cframe2)
	end)
	TweenService:Create(cFrameValue2, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = instance.Sword2["Meshes/907_Prince Blade.016"]:GetAttribute("CFrame")
	}):Play()
	task.delay(3.9, function()
		v3.Visual:TurnOffVisuals(instance)
		local descendants = {}

		for _, descendant in instance.Sword1:GetDescendants() do
			table.insert(descendants, descendant)
		end

		for _, descendant in instance.Sword2:GetDescendants() do
			table.insert(descendants, descendant)
		end

		for _, instance2 in descendants do
			if instance2:IsA("BasePart") or instance2:IsA("Decal") then
				TweenService:Create(
					instance2,
					TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				):Play()
			elseif instance2:IsA("ParticleEmitter") or instance2:IsA("Beam") or instance2:IsA("Trail") then
				instance2.Enabled = false
			end
		end
	end)
	Debris:AddItem(instance.Sword1, 4)
	Debris:AddItem(instance.Sword2, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(cFrameValue2, 8)
end

Explosions.Specific["Yin Yang Parasol Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	task.spawn(function()
		local pivot = instance.Parasol:GetPivot()
		instance.Parasol:PivotTo(CFrame.new(0, 1000000000, 0))
		local track = instance.Parasol.AnimationController.Animator:LoadAnimation(instance.Parasol.Animation)

		while track.Length == 0 and instance.Parent do
			task.wait()
		end

		if not instance.Parent then
			return
		end

		instance.Parasol:PivotTo(pivot)
		track:Play(0)
		v3.Visual:PlayEffects(instance)
		task.delay(3.95, function()
			instance.Parasol:Destroy()
			track:Stop(0)
			track:Destroy()
		end)
	end)
	Debris:AddItem(instance, 10)
end

Explosions.Specific["Jellyfish Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	task.spawn(function()
		local pivot = instance.Parasol:GetPivot()
		instance.Parasol:PivotTo(CFrame.new(0, 1000000000, 0))
		local track = instance.Parasol.AnimationController.Animator:LoadAnimation(instance.Parasol.Animation)

		while track.Length == 0 and instance.Parent do
			task.wait()
		end

		if not instance.Parent then
			return
		end

		instance.Parasol:PivotTo(pivot)
		track:Play(0)
		v3.Visual:PlayEffects(instance)
		task.delay(4.1, function()
			instance.Parasol:Destroy()
			track:Stop(0)
			track:Destroy()
		end)
	end)
	Debris:AddItem(instance, 10)
end

Explosions.Specific["Cosmic Accuracy"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)

	for _, child in instance.NebulaSniper:GetChildren() do
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = CFrame.identity
		local v7 = child
		local v8 = child:GetPivot()
		cFrameValue.Changed:Connect(function(cframe2: CFrame)
			v7:PivotTo(v8 * cframe2)
		end)
		TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = child:GetAttribute("CFrame")
		}):Play()
	end

	task.delay(4.1, function()
		instance.NebulaSniper:Destroy()
	end)
	Debris:AddItem(instance, 10)
end

Explosions.Specific["Dual Yin Yang Greatsword Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local pivot = instance.Sword1:GetPivot()
	cFrameValue.Changed:Connect(function(cframe2: CFrame)
		instance.Sword1:PivotTo(pivot * cframe2)
	end)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = instance.Sword1["1"]:GetAttribute("CFrame")
	}):Play()
	local cFrameValue2 = Instance.new("CFrameValue")
	cFrameValue2.Value = CFrame.identity
	local pivot2 = instance.Sword2:GetPivot()
	cFrameValue2.Changed:Connect(function(cframe2: CFrame)
		instance.Sword2:PivotTo(pivot2 * cframe2)
	end)
	TweenService:Create(cFrameValue2, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = instance.Sword2["1"]:GetAttribute("CFrame")
	}):Play()
	task.delay(3.9, function()
		v3.Visual:TurnOffVisuals(instance)
		local descendants = {}

		for _, descendant in instance.Sword1:GetDescendants() do
			table.insert(descendants, descendant)
		end

		for _, descendant in instance.Sword2:GetDescendants() do
			table.insert(descendants, descendant)
		end

		for _, instance2 in descendants do
			if instance2:IsA("BasePart") or instance2:IsA("Decal") then
				TweenService:Create(
					instance2,
					TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				):Play()
			elseif instance2:IsA("ParticleEmitter") or instance2:IsA("Beam") or instance2:IsA("Trail") then
				instance2.Enabled = false
			end
		end
	end)
	Debris:AddItem(instance.Sword1, 4)
	Debris:AddItem(instance.Sword2, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(cFrameValue2, 8)
end

Explosions.Specific["Yin Yang Greatsword Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local pivot = instance.Sword1:GetPivot()
	cFrameValue.Changed:Connect(function(cframe2: CFrame)
		instance.Sword1:PivotTo(pivot * cframe2)
	end)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = instance.Sword1["1"]:GetAttribute("CFrame")
	}):Play()
	task.delay(3.9, function()
		v3.Visual:TurnOffVisuals(instance)
		local descendants = {}

		for _, descendant in instance.Sword1:GetDescendants() do
			table.insert(descendants, descendant)
		end

		for _, instance2 in descendants do
			if instance2:IsA("BasePart") or instance2:IsA("Decal") then
				TweenService:Create(
					instance2,
					TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				):Play()
			elseif instance2:IsA("ParticleEmitter") or instance2:IsA("Beam") or instance2:IsA("Trail") then
				instance2.Enabled = false
			end
		end
	end)
	Debris:AddItem(instance.Sword1, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
end

Explosions.Specific["Beach Party"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = -instance.Umbrella:GetExtentsSize().Y * 0.5
	numberValue.Changed:Connect(function(p2: number)
		instance.Umbrella:PivotTo(pivot + createVector(0, 1, 0) * p2)
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = 7.5
	}):Play()
	Debris:AddItem(instance.Umbrella, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

Explosions.Specific["Ghostly Revenge"] = Explosions.Specific["Chroma Scythe Explosion"]
Explosions.Specific["Tropical Splash"] = Explosions.Specific["Chroma Scythe Explosion"]
Explosions.Specific["Shark Feast"] = Explosions.Specific["Cherry Blossom Tree"]

Explosions.Specific["Champion's Triumph"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	local pivot = instance:GetPivot()
	v3.Visual:PlayEffects(instance)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = -instance.Umbrella:GetExtentsSize().Y * 0.5
	numberValue.Changed:Connect(function(p2: number)
		instance.Umbrella:PivotTo(pivot + createVector(0, 1, 0) * p2)
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = 13.25
	}):Play()
	Debris:AddItem(instance.Umbrella, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(numberValue, 8)
end

Explosions.Specific["Katana Black Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local pivot = instance.Katana:GetPivot()
	cFrameValue.Changed:Connect(function(cframe2: CFrame)
		instance.Katana:PivotTo(pivot * cframe2)
	end)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = instance.Katana["1"]:GetAttribute("CFrame")
	}):Play()
	Debris:AddItem(instance.Katana, 4.5)
	Debris:AddItem(instance, 8)
end

Explosions.Specific["Katana Red Explosion"] = Explosions.Specific["Katana Black Explosion"]
Explosions.Specific["Katana Blue Explosion"] = Explosions.Specific["Katana Black Explosion"]
Explosions.Specific["Katana Green Explosion"] = Explosions.Specific["Katana Black Explosion"]
Explosions.Specific["Katana Pink Explosion"] = Explosions.Specific["Katana Black Explosion"]
Explosions.Specific["Katana Chroma Explosion"] = Explosions.Specific["Katana Black Explosion"]

Explosions.Specific["Black Ninja Star Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = createVector(0, 0, 0)
	local pivot = instance.Star:GetPivot()

	local function update()
		local value = vector3Value.Value
		instance.Star:PivotTo(pivot * cFrameValue.Value * CFrame.fromOrientation(value.X, value.Y, value.Z))
	end

	vector3Value.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	local tweenInfo = TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(cFrameValue, tweenInfo, {
		Value = parseCFrame(instance.Star["1"]:GetAttribute("CFrame"))
	}):Play()
	local rotation = instance.Star["1"]:GetAttribute("Rotation")

	if rotation == nil then
		rotation = createVector(0, 0, 0)
	elseif typeof(rotation) ~= "Vector3" then
		local v9, v10, v11 = string.match(rotation, "([%d%.%-]*), ([%d%.%-]*), ([%d%.%-]*)")
		rotation = Vector3.new(tonumber(v9) or 0, tonumber(v10) or 0, tonumber(v11) or 0)
	end

	TweenService:Create(vector3Value, tweenInfo, {
		Value = rotation
	}):Play()
	Debris:AddItem(instance.Star, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(vector3Value, 8)
end

Explosions.Specific["Blue Ninja Star Explosion"] = Explosions.Specific["Black Ninja Star Explosion"]
Explosions.Specific["Green Ninja Star Explosion"] = Explosions.Specific["Black Ninja Star Explosion"]
Explosions.Specific["Pink Ninja Star Explosion"] = Explosions.Specific["Black Ninja Star Explosion"]
Explosions.Specific["Red Ninja Star Explosion"] = Explosions.Specific["Black Ninja Star Explosion"]
Explosions.Specific["Chroma Ninja Star Explosion"] = Explosions.Specific["Black Ninja Star Explosion"]

Explosions.Specific["Chroma Oni Katana Explosion"] = function(p)
	stickToGround(p, {
		autoPlay = false,
		child = "Sword",
		depth = -50,
		offsetY = 6,
		useGroundXZ = false,
		swordDebris = 3.8
	})
end

Explosions.Specific["Stormbane Explosion"] = Explosions.Specific["Chroma Oni Katana Explosion"]
Explosions.Specific["Red Oni Katana Explosion"] = Explosions.Specific["Chroma Oni Katana Explosion"]
Explosions.Specific["Blue Oni Katana Explosion"] = Explosions.Specific["Chroma Oni Katana Explosion"]
Explosions.Specific["Pink Oni Katana Explosion"] = Explosions.Specific["Chroma Oni Katana Explosion"]
Explosions.Specific["Purple Oni Katana Explosion"] = Explosions.Specific["Chroma Oni Katana Explosion"]
Explosions.Specific["Black Oni Katana Explosion"] = Explosions.Specific["Chroma Oni Katana Explosion"]

function Explosions.Specific.Ghostwisp(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = createVector(0, 0, 0)
	local pivot = instance.Sword:GetPivot()

	local function update()
		local value = vector3Value.Value
		instance.Sword:PivotTo(pivot * cFrameValue.Value * CFrame.fromOrientation(value.X, value.Y, value.Z))
	end

	vector3Value.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	local tweenInfo = TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(cFrameValue, tweenInfo, {
		Value = parseCFrame(instance.Sword["1"]:GetAttribute("CFrame"))
	}):Play()
	local rotation = instance.Sword["1"]:GetAttribute("Rotation")

	if rotation == nil then
		rotation = createVector(0, 0, 0)
	elseif typeof(rotation) ~= "Vector3" then
		local v9, v10, v11 = string.match(rotation, "([%d%.%-]*), ([%d%.%-]*), ([%d%.%-]*)")
		rotation = Vector3.new(tonumber(v9) or 0, tonumber(v10) or 0, tonumber(v11) or 0)
	end

	TweenService:Create(vector3Value, tweenInfo, {
		Value = rotation
	}):Play()
	Debris:AddItem(instance.Sword, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(vector3Value, 8)
end

Explosions.Specific["Dual Ghostwisp"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = createVector(0, 0, 0)
	local pivot = instance.Sword:GetPivot()

	local function update()
		local value = vector3Value.Value
		instance.Sword:PivotTo(pivot * cFrameValue.Value * CFrame.fromOrientation(value.X, value.Y, value.Z))
	end

	vector3Value.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	local tweenInfo = TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(cFrameValue, tweenInfo, {
		Value = parseCFrame(instance.Sword["1"]:GetAttribute("CFrame"))
	}):Play()
	local rotation = instance.Sword["1"]:GetAttribute("Rotation")

	if rotation == nil then
		rotation = createVector(0, 0, 0)
	elseif typeof(rotation) ~= "Vector3" then
		local v9, v10, v11 = string.match(rotation, "([%d%.%-]*), ([%d%.%-]*), ([%d%.%-]*)")
		rotation = Vector3.new(tonumber(v9) or 0, tonumber(v10) or 0, tonumber(v11) or 0)
	end

	TweenService:Create(vector3Value, tweenInfo, {
		Value = rotation
	}):Play()
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(vector3Value, 8)
	local cFrameValue2 = Instance.new("CFrameValue")
	cFrameValue2.Value = CFrame.identity
	local vector3Value2 = Instance.new("Vector3Value")
	vector3Value2.Value = createVector(0, 0, 0)
	local pivot2 = instance.Sword1:GetPivot()

	local function update2()
		local value = vector3Value2.Value
		instance.Sword1:PivotTo(pivot2 * cFrameValue2.Value * CFrame.fromOrientation(value.X, value.Y, value.Z))
	end

	vector3Value2.Changed:Connect(update2)
	cFrameValue2.Changed:Connect(update2)
	local tweenInfo2 = TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(cFrameValue2, tweenInfo2, {
		Value = parseCFrame(instance.Sword1["1"]:GetAttribute("CFrame"))
	}):Play()
	local rotation2 = instance.Sword1["1"]:GetAttribute("Rotation")

	if rotation2 == nil then
		rotation2 = createVector(0, 0, 0)
	elseif typeof(rotation2) ~= "Vector3" then
		local v11, v12, v13 = string.match(rotation2, "([%d%.%-]*), ([%d%.%-]*), ([%d%.%-]*)")
		rotation2 = Vector3.new(tonumber(v11) or 0, tonumber(v12) or 0, tonumber(v13) or 0)
	end

	TweenService:Create(vector3Value2, tweenInfo2, {
		Value = rotation2
	}):Play()
	Debris:AddItem(cFrameValue2, 8)
	Debris:AddItem(vector3Value2, 8)
	Debris:AddItem(instance.Sword1, 4)
	Debris:AddItem(instance.Sword, 4)
	Debris:AddItem(instance, 8)
end

Explosions.Specific["Soul Lantern"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = createVector(0, 0, 0)
	local pivot = instance.Lantern:GetPivot()

	local function update()
		local value = vector3Value.Value
		instance.Lantern:PivotTo(pivot * cFrameValue.Value * CFrame.fromOrientation(value.X, value.Y, value.Z))
	end

	vector3Value.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(instance.Lantern["lantern 1"]:GetAttribute("CFrame"))
	}):Play()
	local total = -0.25
	local postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
		local cframe2 = CFrame.lookAt(instance.Lantern:GetPivot().Position, currentCamera.CFrame.Position)
		total += dt
		vector3Value.Value = Vector3.new(
			0,
			select(2, cframe2:ToOrientation()) + 1.5707963267948966,
			math.sin(not (total > 0) and 0 or total * 2) * 0.35
		)
	end)
	task.delay(3.75, function()
		for _, descendant in instance.Lantern:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") and descendant.Parent.Name ~= "VanishTransition" then
				descendant.Enabled = false
			end
		end
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(vector3Value, 8)
	instance.Lantern.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
end

Explosions.Specific["Frostbound Enlightenment"] = Explosions.Specific["Soul Lantern"]

Explosions.Specific["Kitty Rocket"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local heartRocket = instance.HeartRocket
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local pivot = heartRocket:GetPivot()

	local function update()
		heartRocket:PivotTo(pivot * cFrameValue.Value)
	end

	cFrameValue.Changed:Connect(update)
	local tween = TweenService:Create(
		cFrameValue,
		TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Value = parseCFrame(heartRocket:GetAttribute("CFrame"))
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		Debris:AddItem(heartRocket, 0)
	end)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
end

Explosions.Specific["Seraphim Gate"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = createVector(0, 0, 0)
	local pivot = instance.Sword:GetPivot()

	local function update()
		local value = vector3Value.Value
		instance.Sword:PivotTo(pivot * cFrameValue.Value * CFrame.fromOrientation(value.X, value.Y, value.Z))
	end

	vector3Value.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(instance.Sword.Main:GetAttribute("CFrame"))
	}):Play()
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local cframe2 = CFrame.lookAt(instance.Sword:GetPivot().Position, currentCamera.CFrame.Position)
		vector3Value.Value = Vector3.new(0, -select(2, cframe2:ToOrientation()) + 1.5707963267948966, 0)
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	Debris:AddItem(instance.Sword, 4)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(vector3Value, 8)
	instance.Sword.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
end

Explosions.Specific["Coffin Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local coffin = instance.Coffin
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local pivot = coffin:GetPivot()

	local function update()
		coffin:PivotTo(pivot * cFrameValue.Value)
	end

	cFrameValue.Changed:Connect(update)
	local tween = TweenService:Create(
		cFrameValue,
		TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Value = parseCFrame(coffin:GetAttribute("CFrame"))
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		Debris:AddItem(coffin, 4)
	end)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
end

Explosions.Specific["Moon Discovery"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local katana = instance.Katana
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = createVector(0, 0, 0)
	local pivot = katana:GetPivot()

	local function update()
		local value = vector3Value.Value
		katana:PivotTo(pivot * cFrameValue.Value * CFrame.fromOrientation(value.X, value.Y, value.Z))
	end

	vector3Value.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(katana.Main:GetAttribute("CFrame"))
	}):Play()
	Debris:AddItem(katana, 3.8)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local cframe2 = CFrame.lookAt(katana:GetPivot().Position, currentCamera.CFrame.Position)
		vector3Value.Value = Vector3.new(0, -select(2, cframe2:ToOrientation()) + 1.5707963267948966, 0)
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	katana.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
end

Explosions.Specific["Great Moon Landing"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local moonFlower = instance.MoonFlower
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = createVector(0, 0, 0)
	local pivot = moonFlower:GetPivot()

	local function update()
		local value = vector3Value.Value
		moonFlower:PivotTo(pivot * cFrameValue.Value * CFrame.fromOrientation(value.X, value.Y, value.Z))
	end

	vector3Value.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(moonFlower.Main:GetAttribute("CFrame"))
	}):Play()
	Debris:AddItem(moonFlower, 3.75)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local cframe2 = CFrame.lookAt(moonFlower:GetPivot().Position, currentCamera.CFrame.Position)
		vector3Value.Value = Vector3.new(0, -select(2, cframe2:ToOrientation()) + 1.5707963267948966, 0)
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	moonFlower.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
end

Explosions.Specific["Serpent Anchor"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local anchor = instance.Anchor
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local pivot = anchor:GetPivot()

	local function update()
		local value = numberValue.Value
		local cframe2 = pivot * cFrameValue.Value
		local orientation, _, v7 = cframe2:ToOrientation()
		anchor:PivotTo(CFrame.new(cframe2.Position) * CFrame.fromOrientation(orientation, value, v7))
	end

	numberValue.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(anchor["1"]:GetAttribute("CFrame"))
	}):Play()
	Debris:AddItem(anchor, 3.8)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local _, v7 = (CFrame.lookAt(anchor:GetPivot().Position, currentCamera.CFrame.Position) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)):ToOrientation()
		numberValue.Value = v7
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	anchor.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
end

Explosions.Specific["Astraea Guidance"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local book = instance.Book
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.new(0, -40, 0)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local pivot = book:GetPivot()

	local function update()
		local value = numberValue.Value
		local cframe2 = pivot * cFrameValue.Value
		local orientation, _, v7 = cframe2:ToOrientation()
		book:PivotTo(CFrame.new(cframe2.Position) * CFrame.fromOrientation(orientation, value, v7))
	end

	numberValue.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = CFrame.identity
	}):Play()
	task.spawn(function()
		local track = book.AnimationController.Animator:LoadAnimation(book.Animation)
		track.Looped = true
		track:Play()
		task.delay(3.85, function()
			track:Stop()
			track:Destroy()
		end)
	end)
	Debris:AddItem(book, 3.85)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(numberValue, 8)
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local _, v7 = (CFrame.lookAt(book:GetPivot().Position, currentCamera.CFrame.Position) * CFrame.Angles(
			0,
			4.71238898038469,
			0
		)):ToOrientation()
		numberValue.Value = v7
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	book.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
end

Explosions.Specific["Soulforge Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local book = instance.Book
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.new(0, -40, 0)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local pivot = book:GetPivot()

	local function update()
		local value = numberValue.Value
		local cframe2 = pivot * cFrameValue.Value
		local orientation, _, v7 = cframe2:ToOrientation()
		book:PivotTo(CFrame.new(cframe2.Position) * CFrame.fromOrientation(orientation, value, v7))
	end

	numberValue.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = CFrame.new(0, 6, 0)
	}):Play()
	task.spawn(function()
		local track = book.AnimationController.Animator:LoadAnimation(book.Animation)
		track.Looped = true
		track:Play()
		task.delay(3.9, function()
			track:Stop()
			track:Destroy()
		end)
	end)
	Debris:AddItem(book, 3.85)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(numberValue, 8)
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local _, v7 = (CFrame.lookAt(book:GetPivot().Position, currentCamera.CFrame.Position) * CFrame.Angles(
			0,
			4.71238898038469,
			0
		)):ToOrientation()
		numberValue.Value = v7
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	book.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
end

Explosions.Specific["Medic Waveform"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local tree = instance.Tree
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local pivot = tree:GetPivot()

	local function update()
		tree:PivotTo(pivot * cFrameValue.Value)
	end

	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(tree["1"]:GetAttribute("CFrame"))
	}):Play()
	Debris:AddItem(tree, 3.8)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
end

Explosions.Specific["Holiday Treeburst"] = Explosions.Specific["Medic Waveform"]

Explosions.Specific["Santa's Greatplosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local sword = instance.Sword
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local pivot = sword:GetPivot()

	local function update()
		local value = numberValue.Value
		local cframe2 = pivot * cFrameValue.Value
		local orientation, _, v7 = cframe2:ToOrientation()
		sword:PivotTo(CFrame.new(cframe2.Position) * CFrame.fromOrientation(orientation, value, v7))
	end

	numberValue.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(sword["1"]:GetAttribute("CFrame"))
	}):Play()
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local _, v7 = (CFrame.lookAt(sword:GetPivot().Position, currentCamera.CFrame.Position) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)):ToOrientation()
		numberValue.Value = v7
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	sword.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
	Debris:AddItem(sword, 3.8)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
end

Explosions.Specific["Sweet Headshot"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local sword = instance.Sword
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local pivot = sword:GetPivot()

	local function update()
		local value = numberValue.Value
		local cframe2 = pivot * cFrameValue.Value
		local orientation, _, v7 = cframe2:ToOrientation()
		sword:PivotTo(CFrame.new(cframe2.Position) * CFrame.fromOrientation(orientation, value, v7))
	end

	numberValue.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(sword.Main:GetAttribute("CFrame"))
	}):Play()
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local _, v7 = (CFrame.lookAt(sword:GetPivot().Position, currentCamera.CFrame.Position) * CFrame.Angles(
			0,
			4.71238898038469,
			0
		)):ToOrientation()
		numberValue.Value = v7
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	sword.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
	Debris:AddItem(sword, 3.8)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
end

Explosions.Specific["Bell Light"] = Explosions.Specific["Soul Lantern"]

Explosions.Specific["Soul Counter"] = function(p)
	autoPlay(p)
	local kill = p.Kill
	local clone = ReplicatedStorage2.Assets.R6:Clone()
	clone:PivotTo(CFrame.new(p.ExplodePosition))
	clone.Parent = workspace.Runtime

	if kill then
		local attachment = Instance.new("Attachment")
		attachment.Name = "Billboard"
		attachment.CFrame = CFrame.new(0, 9.61242294, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "InfoBillboard"
		billboardGui.Active = true
		billboardGui.ExtentsOffsetWorldSpace = createVector(0, 1.5, 0)
		billboardGui.MaxDistance = 100
		billboardGui.Size = UDim2.new(25, 5, 5, 5)
		billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "TextLabel"
		textLabel.AnchorPoint = Vector2.new(0.5, 0)
		textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.BackgroundTransparency = 1
		textLabel.BorderColor3 = Color3.fromRGB(27, 42, 53)
		textLabel.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
		textLabel.Position = UDim2.fromScale(0.5, 0.4)
		textLabel.Size = UDim2.fromScale(1.2, 1.5)
		textLabel.Text = v3.ValueConvertor:AddCommas(kill)
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextScaled = true
		textLabel.TextSize = 14
		textLabel.TextStrokeColor3 = Color3.fromRGB(30, 30, 30)
		textLabel.TextWrapped = true
		textLabel.ZIndex = 2
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Name = "UIStroke"
		uIStroke.Color = Color3.fromRGB(140, 140, 140)
		uIStroke.Thickness = 2
		uIStroke.Parent = textLabel
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Name = "UIGradient"
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 231, 97)),
			ColorSequenceKeypoint.new(0.463, Color3.fromRGB(255, 252, 121)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(118, 103, 47))
		})
		uIGradient.Rotation = 90
		uIGradient.Parent = textLabel
		textLabel.Parent = billboardGui
		billboardGui.Parent = attachment
		attachment.Parent = clone.Head
	end

	local instances = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addTransparencyObject(descendant)
		if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("Highlight") then
			table.insert(instances, descendant)
		end
	end

	for _, descendant in clone:GetDescendants() do
		addTransparencyObject(descendant) -- equivalent call inferred; original call site unknown
	end

	clone.DescendantAdded:Connect(addTransparencyObject)
	clone.PrimaryPart.Anchored = true
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local pivot = clone:GetPivot()

	local function update()
		clone:PivotTo(pivot * cFrameValue.Value)

		for _, v7 in instances do
			if v7.ClassName == "Highlight" then
				v7.OutlineTransparency = numberValue.Value
				v7.FillTransparency = numberValue.Value
			else
				v7.Transparency = numberValue.Value
			end
		end
	end

	cFrameValue.Changed:Connect(update)
	numberValue.Changed:Connect(update)
	v.fastTween(cFrameValue, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = CFrame.new(0, 15, 0)
	})
	v.fastTween(numberValue, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 2.5), {
		Value = 1
	})
	local highlight = Instance.new("Highlight")
	highlight.Name = "Highlight"
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = Color3.fromRGB(253, 253, 253)
	highlight.FillTransparency = 0
	highlight.OutlineColor = Color3.fromRGB(255, 238, 71)
	highlight.Parent = clone
	local attachment = Instance.new("Attachment")
	attachment.Name = "Attachment"
	attachment.WorldCFrame = CFrame.new(-865.173523, 3.06599927, 808.420959, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "reachifyring"
	particleEmitter.Brightness = 5
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(118, 118, 118)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(118, 118, 118))
	})
	particleEmitter.EmissionDirection = Enum.NormalId.Back
	particleEmitter.Enabled = false
	particleEmitter.FlipbookFramerate = NumberRange.new(14)
	particleEmitter.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
	particleEmitter.Lifetime = NumberRange.new(2.5)
	particleEmitter.LightEmission = 0.4
	particleEmitter.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
	particleEmitter.Rate = 1.1
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 11.4),
		NumberSequenceKeypoint.new(0.1, 17),
		NumberSequenceKeypoint.new(0.2, 19.6),
		NumberSequenceKeypoint.new(0.3, 21),
		NumberSequenceKeypoint.new(0.4, 21.8),
		NumberSequenceKeypoint.new(0.5, 22.3),
		NumberSequenceKeypoint.new(0.6, 20.7),
		NumberSequenceKeypoint.new(0.702, 22.2),
		NumberSequenceKeypoint.new(0.798, 24.8),
		NumberSequenceKeypoint.new(0.9, 22.7),
		NumberSequenceKeypoint.new(1, 22.8),
		NumberSequenceKeypoint.new(1, 22.8)
	})
	particleEmitter.Speed = NumberRange.new(0.35)
	particleEmitter.Texture = "http://www.roblox.com/asset/?id=119787067018418"
	particleEmitter.TimeScale = 0.8
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.0688, 0),
		NumberSequenceKeypoint.new(0.847, 0.102),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.ZOffset = 0.2
	particleEmitter.Parent = attachment
	attachment.Parent = clone.Torso
	Debris:AddItem(clone, 5)
	Debris:AddItem(cFrameValue, 5)
end

Explosions.Specific["Lily Strike"] = Explosions.Specific["Santa's Greatplosion"]
Explosions.Specific["Serpent's Judgment"] = Explosions.Specific["Santa's Greatplosion"]

Explosions.Specific["Lunar Lantern"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = createVector(0, 0, 0)
	local pivot = instance.Lantern:GetPivot()

	local function update()
		local value = vector3Value.Value
		instance.Lantern:PivotTo(pivot * cFrameValue.Value * CFrame.fromOrientation(value.X, value.Y, value.Z))
	end

	vector3Value.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(instance.Lantern["lantern 1"]:GetAttribute("CFrame"))
	}):Play()
	local total = -0.25
	local postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
		local cframe2 = CFrame.lookAt(instance.Lantern:GetPivot().Position, currentCamera.CFrame.Position)
		total += dt
		vector3Value.Value = Vector3.new(
			0,
			select(2, cframe2:ToOrientation()) + 1.5707963267948966,
			math.sin(not (total > 0) and 0 or total * 2) * 0.35
		)
	end)
	task.delay(3.85, function()
		for _, descendant in instance.Lantern:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") and descendant.Parent.Name ~= "VanishTransition" then
				descendant.Enabled = false
			end
		end
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
	Debris:AddItem(vector3Value, 8)
	instance.Lantern.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
end

Explosions.Specific["The Curse Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local mask = instance.Mask
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local pivot = mask:GetPivot()

	local function update()
		local value = numberValue.Value
		local cframe2 = pivot * cFrameValue.Value
		local orientation, _, v7 = cframe2:ToOrientation()
		mask:PivotTo(CFrame.new(cframe2.Position) * CFrame.fromOrientation(orientation, value, v7))
	end

	numberValue.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(mask["1"]:GetAttribute("CFrame"))
	}):Play()
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local _, v7 = CFrame.lookAt(mask:GetPivot().Position, currentCamera.CFrame.Position):ToOrientation()
		numberValue.Value = v7
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	mask.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
	Debris:AddItem(mask, 3.8)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
end

Explosions.Specific["Floppy Chicken Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	task.spawn(function()
		local pivot = instance.Chicken:GetPivot()
		instance.Chicken:PivotTo(CFrame.new(0, 1000000000, 0))
		local track = instance.Chicken.AnimationController.Animator:LoadAnimation(instance.Chicken.Animation)

		while track.Length == 0 and instance.Parent do
			task.wait()
		end

		if not instance.Parent then
			return
		end

		instance.Chicken:PivotTo(pivot)
		track:Play(0)
		v3.Visual:PlayEffects(instance)
		local enableME = instance.Chicken:FindFirstChild("EnableME", true)

		if enableME then
			for _, emitter in enableME:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end

		task.delay(3.9, function()
			instance.Chicken:Destroy()
			track:Stop(0)
			track:Destroy()
		end)
	end)
	Debris:AddItem(instance, 10)
end

Explosions.Specific["Blossom Katana Explosion"] = Explosions.Specific["Santa's Greatplosion"]

Explosions.Specific["Master Builder"] = function(p)
	local maid = v2.new()
	local dragon = p.Instance.Dragon
	local cframe = CFrame.new(p.ExplodePosition)
	raycastParams.FilterDescendantsInstances = {
		p.Instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local raycastResult = workspace:Raycast(cframe.Position, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		cframe = CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1)
	end

	local cFrame = cframe * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	dragon:PivotTo(cFrame)
	local built = dragon.Built
	local broken = dragon.Broken
	local v8 = {}

	for _, part in broken:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local child = built:FindFirstChild(part.Name)

		if child then
			local random = Random.new()
			part.CFrame = cFrame
			part.Anchored = false
			local v10 = part
			task.delay(0, function()
				local unit = random:NextUnitVector().Unit
				local v11 = unit ~= unit and createVector(0, 0, 0) or unit
				v10:ApplyImpulse(Vector3.new(0, 100 * v10.Mass, 0) + v11 * v10.Mass * 15)
				task.wait(0.1)
				v10.CanCollide = true
			end)
			table.insert(v8, {
				Part = part,
				CFrame = child.CFrame
			})
		else
			part:Destroy()
		end
	end

	local lerped = built.foot_L.Position:Lerp(built.foot_R.Position, 0.5)
	built:Destroy()
	dragon.Parent = workspace.Runtime
	maid:AttachToInstance(dragon)
	table.sort(v8, function(a, b)
		return (a.CFrame.Position - Vector3.new(0, a.Part.Size.Y / 2) - lerped).Magnitude < (b.CFrame.Position - Vector3.new(
			0,
			b.Part.Size.Y / 2,
			0
		) - lerped).Magnitude
	end)
	task.wait(0.75)

	for k, v9 in v8 do
		v9.Part.Anchored = true
		v9.Part.CanCollide = false
		local v10 = math.clamp((v9.Part.Position - v9.CFrame.Position).Magnitude / 45 / (k * 0.2 + 1), 0.2, 1)
		maid:Add(TweenService:Create(v9.Part, TweenInfo.new(v10, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = v9.CFrame
		})):Play()
		task.wait(v10)
	end

	for _, v9 in v8 do
		maid:Add(TweenService:Create(
			v9.Part,
			TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true),
			{
				CFrame = v9.CFrame + createVector(0, 3.5, 0)
			}
		)):Play()
	end

	task.wait(0.5)
	local highlight = Instance.new("Highlight")
	highlight.Name = "Highlight"
	highlight.FillColor = Color3.fromRGB(255, 225, 0)
	highlight.FillTransparency = 0.3
	highlight.Parent = broken
	maid:Add(TweenService:Create(
		highlight,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0.15),
		{
			FillTransparency = 1,
			OutlineTransparency = 1
		}
	)):Play()

	for _, v9 in v8 do
		maid:Add(TweenService:Create(v9.Part, TweenInfo.new(0.15), {
			Transparency = 0.999
		})):Play()
	end

	task.wait(2)
	maid:Destroy()
end

Explosions.Specific["Paw Punch"] = Explosions.Specific["Santa's Greatplosion"]

Explosions.Specific["Shatterflight Bird Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	task.spawn(function()
		local pivot = instance.Bird:GetPivot()
		instance.Bird:PivotTo(CFrame.new(0, 1000000000, 0))
		local track = instance.Bird.AnimationController.Animator:LoadAnimation(instance.Bird.Animation)

		while track.Length == 0 and instance.Parent do
			task.wait()
		end

		if not instance.Parent then
			return
		end

		instance.Bird:PivotTo(pivot)
		track:Play(0)
		v3.Visual:PlayEffects(instance)
		task.delay(3.95, function()
			instance.Bird:Destroy()
			track:Stop(0)
			track:Destroy()
		end)
	end)
	Debris:AddItem(instance, 10)
end

Explosions.Specific["Prismatic Odachi Explosion"] = function(p)
	local instance = p.Instance
	local explodePosition = p.ExplodePosition
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + Vector3.new(0, instance.Size.Y * 0.5, 0) + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition + Vector3.new(0, instance.Size.Y * 0.5, 0)) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local sword = instance.Sword
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local pivot = sword:GetPivot()

	local function update()
		local value = numberValue.Value
		local cframe2 = pivot * cFrameValue.Value
		local orientation, _, v7 = cframe2:ToOrientation()
		sword:PivotTo(CFrame.new(cframe2.Position) * CFrame.fromOrientation(orientation, value, v7))
	end

	numberValue.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(sword["1"]:GetAttribute("CFrame"))
	}):Play()
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		local _, v7 = (CFrame.lookAt(sword:GetPivot().Position, currentCamera.CFrame.Position) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)):ToOrientation()
		numberValue.Value = v7
	end)
	task.delay(4, function()
		postSimulationConnection:Disconnect()
	end)
	sword.Destroying:Connect(function()
		postSimulationConnection:Disconnect()
	end)
	Debris:AddItem(sword, 3.8)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
end

Explosions.Specific["Sakura's Requiem Explosion"] = Explosions.Specific["Prismatic Odachi Explosion"]

Explosions.Specific["Fallen Angel Explosion"] = function(p)
	local instance = p.Instance
	local explodePosition = p.ExplodePosition
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		local Y = raycastResult.Position.Y
		local v7 = Vector3.new(explodePosition.X, Y, explodePosition.Z) + Vector3.new(0, instance.Size.Y * 0.5 + 0.1, 0)
		instance:PivotTo(CFrame.new(v7) * cframe)
	else
		local v7 = explodePosition + Vector3.new(0, instance.Size.Y * 0.5, 0)
		instance:PivotTo(CFrame.new(v7) * cframe)
	end

	v3.Visual:PlayEffects(instance)
	local sword = instance.Sword
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = CFrame.identity
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local pivot = sword:GetPivot()

	local function update()
		local value = numberValue.Value
		local cframe2 = pivot * cFrameValue.Value
		local orientation, _, v7 = cframe2:ToOrientation()
		sword:PivotTo(CFrame.new(cframe2.Position) * CFrame.fromOrientation(orientation, value, v7))
	end

	numberValue.Changed:Connect(update)
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = parseCFrame(sword["1"]:GetAttribute("CFrame"))
	}):Play()
	Debris:AddItem(sword, 3.8)
	Debris:AddItem(instance, 8)
	Debris:AddItem(cFrameValue, 8)
end

Explosions.Specific["Hollow Oath Explosion"] = Explosions.Specific["Prismatic Odachi Explosion"]
Explosions.Specific["Calamity Guardian Explosion"] = Explosions.Specific["Prismatic Odachi Explosion"]

Explosions.Specific["Spinalis Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	local cframe = CFrame.fromOrientation(0, 1.5707963267948966, 0)
	local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -50, -0), raycastParams)

	if raycastResult then
		instance:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal.Unit * 0.1) * cframe)
	else
		instance:PivotTo(CFrame.new(explodePosition) * cframe)
	end

	task.spawn(function()
		local pivot = instance.Chicken:GetPivot()
		instance.Chicken:PivotTo(CFrame.new(0, 1000000000, 0))
		local track = instance.Chicken.AnimationController.Animator:LoadAnimation(instance.Chicken.Animation)

		while track.Length == 0 and instance.Parent do
			task.wait()
		end

		if not instance.Parent then
			return
		end

		instance.Chicken:PivotTo(pivot)
		track:Play(0)
		v3.Visual:PlayEffects(instance)
		local enableME = instance.Chicken:FindFirstChild("EnableME", true)

		if enableME then
			for _, emitter in enableME:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end

		task.delay(5, function()
			instance.Chicken:Destroy()
			track:Stop(0)
			track:Destroy()
		end)
	end)
	Debris:AddItem(instance, 10)
end

Explosions.Specific["Star Wand Explosion"] = function(p)
	stickToGround(p, {
		autoPlay = false,
		child = "Chicken",
		depth = -50,
		offsetY = 20,
		useGroundXZ = false,
		swordDebris = 3.8
	})
end

Explosions.Specific["Oni Ghost Explosion"] = Explosions.Specific["Star Wand Explosion"]

Explosions.Specific["Ethereal Bombardment Explosion"] = function(p)
	stickToGround(p, {
		autoPlay = true,
		child = "Sword",
		depth = -50,
		offsetX = -5,
		offsetY = 40,
		useGroundXZ = true,
		swordDebris = 4
	})
end

Explosions.Specific["Riftflare Katana Explosion"] = function(p)
	stickToGround(p, {
		autoPlay = true,
		child = "Sword",
		depth = -50,
		offsetY = 7,
		useGroundXZ = true,
		swordDebris = 4
	})
end

Explosions.Specific["Phantom Pact"] = function(p)
	stickToGround(p, {
		autoPlay = true,
		child = "Sword",
		depth = -50,
		offsetY = 5,
		useGroundXZ = true,
		swordDebris = 4
	})
end

Explosions.Specific["Night Raver"] = function(p)
	stickToGround(p, {
		autoPlay = true,
		child = "Sword",
		depth = -50,
		offsetY = 25,
		useGroundXZ = true,
		swordDebris = 4
	})
end

Explosions.Specific["Cross Admiration"] = Explosions.Specific["Night Raver"]

Explosions.Specific["Gyaru's Selfie"] = function(p)
	stickToGround(p, {
		autoPlay = true,
		child = "Sword",
		depth = -40,
		offsetX = 3,
		offsetY = 45,
		useGroundXZ = true,
		swordDebris = 4
	})
end

Explosions.Specific["Higanbana Explosion"] = function(p)
	stickToGround(p, {
		autoPlay = true,
		child = "Sword",
		depth = -40,
		offsetY = 7,
		useGroundXZ = true,
		swordDebris = 4
	})
end

Explosions.Specific["Wolf Greatsword Explosion"] = Explosions.Specific["Higanbana Explosion"]

Explosions.Specific["Regret Blades Explosion"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	instance.Position = explodePosition
	autoPlay(p)
	local v7 = nil

	for _, part in instance:GetDescendants() do
		if not (part:IsA("BasePart") and part.Name == "GROUND") then
			continue
		end

		local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -40, -0), raycastParams)

		if raycastResult then
			part.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
		else
			part.Position = explodePosition
		end

		v7 = part
	end

	local v8 = {
		[instance:FindFirstChild("Sword")] = 1,
		[instance:FindFirstChild("Sword1")] = 1,
		[instance:FindFirstChild("Sword2")] = 7
	}

	if v7 then
		for k, v9 in v8 do
			if not (k and k.Parent) then
				continue
			end

			local pivot = k:GetPivot()
			local vector2 = Vector3.new(pivot.Position.X, v7.Position.Y + v9, pivot.Position.Z)
			local v10 = CFrame.new(vector2) * CFrame.Angles(pivot:ToEulerAnglesXYZ())
			local cFrameValue = Instance.new("CFrameValue")
			cFrameValue.Value = pivot
			local v11 = k
			cFrameValue.Changed:Connect(function(cframe)
				v11:PivotTo(cframe)
			end)
			TweenService:Create(cFrameValue, TweenInfo.new(0.225, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Value = v10
			}):Play()
			Debris:AddItem(k, 4)
		end
	end

	Debris:AddItem(instance, 8)
end

Explosions.Specific["Pearl Angel Katana Explosion"] = function(p)
	stickToGround(p, {
		autoPlay = true,
		child = "Sword",
		depth = -40,
		offsetY = 8,
		useGroundXZ = true,
		swordDebris = 4
	})
end

Explosions.Specific["Prismatic Cloud Rain"] = function(p)
	local explodePosition = p.ExplodePosition
	local instance = p.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	instance.Position = explodePosition + createVector(0, 30, 0)
	autoPlay(p)

	for _, part in instance:GetDescendants() do
		if not (part:IsA("BasePart") and part.Name == "GROUND") then
			continue
		end

		local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -40, -0), raycastParams)

		if raycastResult then
			part.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
		else
			part.Position = explodePosition
		end

		instance.Position = part.Position + createVector(0, 30, 0)
	end

	Debris:AddItem(instance, 8)
end

Explosions.Specific["Tiger Katana Explosion"] = Explosions.Specific["Pearl Angel Katana Explosion"]
Explosions.Specific["Red Moon Katana Explosion"] = Explosions.Specific["Pearl Angel Katana Explosion"]
Explosions.Specific["Proyection Sorcery Explosion"] = Explosions.Specific["Pearl Angel Katana Explosion"]

Explosions.Specific["Phantom Ops Explosion"] = function(p)
	local instance = p.Instance
	local explodePosition = p.ExplodePosition
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	autoPlay(p)
	local v7 = nil

	for _, v8 in instance:QueryDescendants("BasePart[Name=\"GROUND\"]"), nil, nil do
		local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -40, -0), raycastParams)

		if raycastResult then
			v8.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
		else
			v8.Position = explodePosition
		end

		v7 = v8
	end

	local model = instance:FindFirstChildWhichIsA("Model")

	if model then
		local animationController = model:FindFirstChild("AnimationController")
		local animation = model:FindFirstChild("Animation")
		local animator = animationController and animationController:FindFirstChild("Animator")
		local track

		if animator and animation then
			track = animator:LoadAnimation(animation)
		end

		if v7 then
			local cFrame = v7.CFrame
			local vector2 = Vector3.new(cFrame.Position.X, v7.Position.Y + 30, cFrame.Position.Z)
			model:PivotTo((CFrame.new(vector2, v7.Position)))
		end

		if track then
			local v8 = os.clock() + 2

			while track.Length == 0 and model.Parent and os.clock() < v8 do
				task.wait()
			end

			if model.Parent and track.Length > 0 then
				track:Play()
			end

			Debris:AddItem(animation, 4)
			Debris:AddItem(track, 4)
		end

		Debris:AddItem(model, 4)
	end

	Debris:AddItem(instance, 8)
end

Explosions.Specific["Sea Turtle Explosion"] = function(player)
	local explodePosition = player.ExplodePosition
	local instance = player.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	autoPlay(player)
	local v7 = nil

	for _, v8 in instance:QueryDescendants("BasePart[Name=\"GROUND\"]"), nil, nil do
		local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -40, -0), raycastParams)

		if raycastResult then
			v8.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
		else
			v8.Position = explodePosition
		end

		v7 = v8
	end

	local model = instance:FindFirstChildWhichIsA("Model")

	if model then
		local animationController = model:FindFirstChild("AnimationController")
		local animation = model:FindFirstChild("Animation")
		local animator = animationController and animationController:FindFirstChild("Animator")

		if animator and animation then
			local track = animator:LoadAnimation(animation)
			track:Play()
			Debris:AddItem(animation, 4)
			Debris:AddItem(track, 4)
		end

		if v7 then
			local pivot = model:GetPivot()
			local vector2 = Vector3.new(pivot.Position.X, v7.Position.Y + 9.5, pivot.Position.Z)
			local v8

			if player.Character then
				v8 = CFrame.new(vector2, vector2 + player.Character:GetPivot().LookVector)
			else
				v8 = CFrame.new(vector2, vector2 + instance.CFrame.LookVector)
			end

			model:PivotTo(v8)
		end

		Debris:AddItem(model, 4)
	end

	Debris:AddItem(instance, 8)
end

Explosions.Specific["Swan of Love Explosion"] = function(player)
	local explodePosition = player.ExplodePosition
	local instance = player.Instance
	raycastParams.FilterDescendantsInstances = {
		instance,
		workspace.Dead,
		workspace.Alive,
		workspace.MapBounds,
		workspace.Runtime
	}
	autoPlay(player)
	local v7 = nil

	for _, v8 in instance:QueryDescendants("BasePart[Name=\"GROUND\"]"), nil, nil do
		local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -40, -0), raycastParams)

		if raycastResult then
			v8.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
		else
			v8.Position = explodePosition
		end

		v7 = v8
	end

	local model = instance:FindFirstChildWhichIsA("Model")

	if model then
		local animationController = model:FindFirstChild("AnimationController")
		local animation = model:FindFirstChild("Animation")
		local animator = animationController and animationController:FindFirstChild("Animator")
		local track

		if animator and animation then
			track = animator:LoadAnimation(animation)
		end

		if v7 then
			local pivot = model:GetPivot()
			local vector2 = Vector3.new(pivot.Position.X, v7.Position.Y + 3, pivot.Position.Z)
			local v8

			if player.Character then
				v8 = CFrame.new(vector2, vector2 + player.Character:GetPivot().LookVector)
			else
				v8 = CFrame.new(vector2, vector2 + instance.CFrame.LookVector)
			end

			model:PivotTo(v8)
		end

		if track then
			local v8 = os.clock() + 2

			while track.Length == 0 and model.Parent and os.clock() < v8 do
				task.wait()
			end

			if model.Parent and track.Length > 0 then
				track:Play()
			end

			Debris:AddItem(animation, 4)
			Debris:AddItem(track, 4)
		end

		Debris:AddItem(model, 4)
	end

	Debris:AddItem(instance, 8)
end

Explosions.Specific["Ryuzakura Katana Explosion"] = function(p)
	local instance = p.Instance
	local katana = instance:FindFirstChild("Katana")
	local origin

	if katana and katana:IsA("Model") then
		origin = katana:GetAttribute("Origin")
	end

	if (typeof(origin) == "Vector3" or typeof(origin) == "string") and origin ~= nil then
		if typeof(origin) ~= "Vector3" then
			local v7, v8, v9 = string.match(origin, "([%d%.%-]*), ([%d%.%-]*), ([%d%.%-]*)")
			origin = Vector3.new(tonumber(v7) or 0, tonumber(v8) or 0, tonumber(v9) or 0)
		end
	else
		origin = createVector(0, 0, 0)
	end

	local offsetY = 0

	if katana and katana:IsA("Model") then
		katana:PivotTo(CFrame.new(p.ExplodePosition + origin) * katana:GetPivot().Rotation)
		local v8 = 1e999

		for _, v9 in katana:QueryDescendants("BasePart"), nil, nil do
			local halfSize = v9.Size / 2

			for _, v11 in {
				createVector(1, 1, 1),
				createVector(1, 1, -1),
				createVector(1, -1, 1),
				createVector(1, -1, -1),
				createVector(-1, 1, 1),
				createVector(-1, 1, -1),
				createVector(-1, -1, 1),
				createVector(-1, -1, -1)
			} do
				v8 = math.min(v8, (v9.CFrame * (halfSize * v11)).Y)
			end
		end

		if v8 < 1e999 then
			offsetY = katana:GetPivot().Position.Y - v8 - 3
		end
	end

	stickToGround(p, {
		autoPlay = true,
		child = "Katana",
		depth = -50,
		offsetY = offsetY,
		useGroundXZ = true,
		origin = Vector3.new(origin.X, 0, origin.Z),
		swordDebris = 3.8
	})
	local dragon = instance:FindFirstChild("Dragon")

	if dragon and dragon:IsA("Model") then
		local origin2 = dragon:GetAttribute("Origin") or Vector3.new()
		local pivot = dragon:GetPivot()
		local rotation = instance.CFrame:ToObjectSpace(pivot).Rotation
		local cFrame = instance.CFrame

		if origin2 == nil then
			origin2 = createVector(0, 0, 0)
		elseif typeof(origin2) ~= "Vector3" then
			local v8, v9, v10 = string.match(origin2, "([%d%.%-]*), ([%d%.%-]*), ([%d%.%-]*)")
			origin2 = Vector3.new(tonumber(v8) or 0, tonumber(v9) or 0, tonumber(v10) or 0)
		end

		dragon:PivotTo(cFrame * CFrame.new(origin2) * rotation)
		local animationController = dragon:FindFirstChildWhichIsA("AnimationController", true)
		local animation = dragon:FindFirstChildWhichIsA("Animation", true)

		if animationController and animation then
			local track = animationController:FindFirstChildOfClass("Animator"):LoadAnimation(animation)
			local flag = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function stopAnimation()
				if flag then
					return
				end

				flag = true
				track:Stop(0)
				track:Destroy()
			end

			Debris:AddItem(animation, 4)
			Debris:AddItem(track, 4)
			dragon.Destroying:Once(stopAnimation)
			task.spawn(function()
				while track.Length == 0 and dragon.Parent and not flag do
					task.wait()
				end

				if dragon.Parent and not flag then
					track:Play(0)
					return
				end

				stopAnimation() -- equivalent call inferred; original call site unknown
			end)
		end

		Debris:AddItem(dragon, 4)
	end

	Debris:AddItem(instance, 8)
end

local function getCherubExplosionModels(instance, attributionCharacter)
	local v7 = v6.GetAccessoryVariant(attributionCharacter) == "EvilCherub"
	local v8 = v7 and { "RedVersion", "ExplosionKitty2" } or { "PinkVersion", "ExplosionKitty1" }
	local v9 = v7 and { "PinkVersion", "ExplosionKitty1" } or { "RedVersion", "ExplosionKitty2" }
	local v10 = false

	for _, childName in v8 do
		if not instance:FindFirstChild(childName, true) then
			continue
		end

		v10 = true
		break
	end

	if not v10 then
		v8, v9 = v9, v8
	end

	for _, childName in v9 do
		local child = instance:FindFirstChild(childName, true)

		if child then
			child:Destroy()
		end
	end

	local models = {}

	for _, childName in v8 do
		local model = instance:FindFirstChild(childName, true)

		if model and model:IsA("Model") then
			table.insert(models, model)
		end
	end

	return models
end

Explosions.Specific["Kitty's Big Hug"] = function(player)
	local cherubExplosionModels = getCherubExplosionModels(player.Instance, player.AttributionCharacter)

	if cherubExplosionModels then
		local v7 = cherubExplosionModels[1]:FindFirstChildWhichIsA("AnimationController") and 1 or 2
		local cherubExplosionModel = cherubExplosionModels[v7]
		local parent = select(1, next(cherubExplosionModels, v7)) or cherubExplosionModels[1]
		cherubExplosionModel.Parent = parent
		player.Instance = parent:FindFirstChildWhichIsA("BasePart")
		autoPlay(player)
		local instance = player.Instance
		local explodePosition = player.ExplodePosition
		raycastParams.FilterDescendantsInstances = {
			instance,
			cherubExplosionModel,
			workspace.Dead,
			workspace.Alive,
			workspace.MapBounds,
			workspace.Runtime
		}
		local v9 = nil

		for _, v10 in instance:QueryDescendants("BasePart[Name=\"GROUND\"]"), nil, nil do
			local raycastResult = workspace:Raycast(explodePosition, createVector(-0, -40, -0), raycastParams)

			if raycastResult then
				v10.Position = raycastResult.Position + raycastResult.Normal.Unit * 0.1
			else
				v10.Position = explodePosition
			end

			v9 = v10
		end

		local animationController = cherubExplosionModel:FindFirstChild("AnimationController")
		local animation = cherubExplosionModel:FindFirstChild("Animation")
		local track = (animationController and animationController:FindFirstChild("Animator")):LoadAnimation(animation)

		if v9 then
			local vector2 = Vector3.new(player.ExplodePosition.X, v9.Position.Y + 12.5, player.ExplodePosition.Z)
			local v10

			if player.Character then
				v10 = CFrame.new(vector2, vector2 + player.Character:GetPivot().LookVector)
			else
				v10 = CFrame.new(vector2, vector2 + instance.CFrame.LookVector)
			end

			cherubExplosionModel:PivotTo(v10)
		end

		if track then
			local v10 = os.clock() + 2

			while track.Length == 0 and cherubExplosionModel.Parent and os.clock() < v10 do
				task.wait()
			end

			if cherubExplosionModel.Parent and track.Length > 0 then
				track:Play()
				print("Playing", track.Length)
			end

			Debris:AddItem(animation, 4)
			Debris:AddItem(track, 4)
		end

		Debris:AddItem(cherubExplosionModel, 4)
	end

	Debris:AddItem(player.Instance, 8)
end

for _, v7 in v5:GetCollection() do
	local name = v7.Name

	if not (Explosions.Specific[name] or Explosions[name]) then
		Explosions.Specific[name] = autoPlay
	end
end

return Explosions