local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartCache = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.PartCache)
local DebrisModule = require(game.ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
require(ReplicatedStorage.CAM.DebrisModule)
local TokenKit = {
	EmitAll = function(folder)
		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.delay(emitter:GetAttribute("EmitDelay") or 0, function()
				v:Emit(v:GetAttribute("EmitCount") or 30)
			end)
		end
	end,
	RayEmitAll = function(folder)
		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { game.Workspace.World }
			local raycastResult = workspace:Raycast(
				folder.Position + createVector(0, 2, 0),
				createVector(0, -10, 0),
				raycastParams
			)

			if not raycastResult.Color then
				continue
			end

			emitter.Color = ColorSequence.new(raycastResult.Color, raycastResult.Color)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end,
	Toggle = function(folder, p, enabled)
		local descendants = folder:GetDescendants()

		if p == "VFX" then
			for _, emitter in ipairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = enabled
				end
			end
		end

		if p == "Light" then
			for _, light in ipairs(descendants) do
				if light:IsA("PointLight") or light:IsA("SurfaceLight") then
					light.Enabled = enabled
				end
			end
		end

		if p == "Beam" then
			for _, beam in ipairs(descendants) do
				if beam:IsA("Beam") then
					beam.Enabled = enabled
				end
			end
		end
	end,
	Cam = function(duration, fieldOfView)
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				FieldOfView = fieldOfView
			}
		):Play()
	end,
	ParticlePull = function(instance, parent, duration)
		local children = instance:GetChildren()

		for _, v in ipairs(children) do
			v.Parent = parent
			v.Enabled = true
			local v2 = v
			task.delay(duration, function()
				v2.Enabled = false
				DebrisModule:AddItem(v2, duration)
			end)
		end
	end
}

local function scaleNS(size, p)
	local keypoints = size.Keypoints

	for i = 1, #keypoints do
		keypoints[i] = NumberSequenceKeypoint.new(keypoints[i].Time, keypoints[i].Value * p, keypoints[i].Envelope * p)
	end

	return NumberSequence.new(keypoints)
end

local function scaleNR(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

function TokenKit:ScaleParticle(p)
	self.Size = scaleNS(self.Size, p)
	self.Acceleration *= p
	local speed = self.Speed
	self.Speed = NumberRange.new(speed.Min * p, speed.Max * p)
end

function TokenKit.ScaleDescendants(folder, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			TokenKit.ScaleParticle(emitter, p)
		end
	end
end

function TokenKit.DisableAll(folder)
	local descendants = folder:GetDescendants()

	for _, effect in ipairs(descendants) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end

		for _, light in ipairs(descendants) do
			if light:IsA("PointLight") or light:IsA("SurfaceLight") then
				TweenService:Create(light, TweenInfo.new(0.5), {
					Brightness = 0
				}):Play()
			end
		end
	end
end

function TokenKit.RockLane(_, p, p2)
	local assets = script.Assets
	local random = Random.new()
	local v = TweenService
	task.spawn(function()
		for i = 1, p2 do
			local clone = assets.Rock:Clone()
			clone.Parent = workspace.DebrisFolder
			clone.CFrame = p.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(2, 0, -i * 3.5)
			local raycastResult = workspace:Raycast(clone.Position, createVector(0, -5, 0), vfxUtility.RayParams.Map)
			clone.Position = raycastResult.Position
			clone.Size = createVector(0, 0, 0)
			clone.Color = raycastResult.Instance.Color
			clone.Material = raycastResult.Material
			local number = random:NextNumber(0.7, 1.2)
			local v2

			if random:NextNumber(1, 3) == 3 then
				v2 = v:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
					Size = createVector(1, 1, 1) * number,
					CFrame = clone.CFrame * CFrame.new(0, 0, random:NextNumber(-1, -0.5)) * CFrame.Angles(
						random:NextNumber(-180, 180),
						random:NextNumber(-180, 180),
						random:NextNumber(-180, 180)
					)
				})
			else
				v2 = v:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
					Size = createVector(1, 1, 1) * number,
					CFrame = clone.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
						random:NextNumber(-180, 180),
						random:NextNumber(-180, 180),
						random:NextNumber(-180, 180)
					)
				})
			end

			v2:Play()
			local v3 = i
			task.spawn(function()
				v2.Completed:Wait()
				task.wait(4)
				task.wait(v3 / 5)
				v2:Destroy()
				local v5 = v:Create(
					clone,
					TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
					{
						Size = createVector(0, 0, 0),
						Position = clone.Position + createVector(0, -2, 0),
						Orientation = createVector(0, 0, 0)
					}
				)
				v5:Play()
				v5.Completed:Wait()
				v5:Destroy()
				clone:Destroy()
			end)
			task.wait(0.05)
		end
	end)
	task.spawn(function()
		for i = 1, p2 do
			local clone = assets.Rock:Clone()
			clone.Parent = workspace.DebrisFolder
			clone.CFrame = p.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(-2, 0, -i * 3.5)
			local raycastResult = workspace:Raycast(clone.Position, createVector(0, -5, 0), vfxUtility.RayParams.Map)
			clone.Position = raycastResult.Position
			clone.Size = createVector(0, 0, 0)
			clone.Color = raycastResult.Instance.Color
			clone.Material = raycastResult.Material
			local number = random:NextNumber(0.7, 1.2)
			local v2

			if random:NextNumber(1, 3) == 3 then
				v2 = v:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
					Size = createVector(1, 1, 1) * number,
					CFrame = clone.CFrame * CFrame.new(0, 0, random:NextNumber(-1, -0.5)) * CFrame.Angles(
						random:NextNumber(-180, 180),
						random:NextNumber(-180, 180),
						random:NextNumber(-180, 180)
					)
				})
			else
				v2 = v:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
					Size = createVector(1, 1, 1) * number,
					CFrame = clone.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
						random:NextNumber(-180, 180),
						random:NextNumber(-180, 180),
						random:NextNumber(-180, 180)
					)
				})
			end

			v2:Play()
			local v3 = i
			task.spawn(function()
				v2.Completed:Wait()
				task.wait(4)
				task.wait(v3 / 5)
				v2:Destroy()
				local v5 = v:Create(
					clone,
					TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
					{
						Size = createVector(0, 0, 0),
						Position = clone.Position + createVector(0, -2, 0),
						Orientation = createVector(0, 0, 0)
					}
				)
				v5:Play()
				v5.Completed:Wait()
				v5:Destroy()
				clone:Destroy()
			end)
			task.wait(0.05)
		end
	end)
end

function TokenKit.Cascade(p)
	local raycastResult = workspace:Raycast(p.Position, createVector(0, -10, 0), vfxUtility.RayParams.Map)
	task.spawn(function()
		for i = 1, 16 do
			local v = i
			task.spawn(function()
				for i2 = 1, 3 do
					task.wait(math.random() / 6)
					local clone = script.Assets.Rock:Clone()
					clone.Name = "Crater"
					clone.CanCollide = false
					clone.Anchored = true
					clone.Color = raycastResult.Instance.Color
					clone.Material = raycastResult.Material
					clone.CastShadow = false
					clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						math.rad(v * 30),
						0
					) * CFrame.new(0, -18, math.random(-5, -4) * i2)
					clone.Size = Vector3.new(math.random(4, 7), math.random(0.5, 1.5), math.random(1, 2))
					clone.Parent = workspace.DebrisFolder
					TweenService:Create(
						clone,
						TweenInfo.new(
							math.random() / 10,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.InOut,
							0,
							false,
							0
						),
						{
							CFrame = clone.CFrame * CFrame.new(0, math.random(18, 21), 0) * CFrame.Angles(
								math.rad((math.random(20, 35))),
								0,
								(math.rad((math.random(-15, 15))))
							)
						}
					):Play()
					task.delay(3.5, function()
						TweenService:Create(
							clone,
							TweenInfo.new(math.random() + 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = clone.CFrame * CFrame.new(0, -20, 0)
							}
						):Play()
					end)
				end
			end)
		end
	end)
end

function TokenKit.FloatingRocks(instance)
	local raycastResult = workspace:Raycast(instance.Position, createVector(0, -10, 0), vfxUtility.RayParams.Map)
	task.spawn(function()
		for _ = 1, 16 do
			local clone = script.Assets.Rock:Clone()
			clone.Name = "Crater"
			clone.CanCollide = false
			clone.Anchored = true
			clone.Color = raycastResult.Instance.Color
			clone.Material = raycastResult.Material
			clone.CFrame = instance.CFrame * CFrame.new(math.random(10, 15), -5, math.random(10, 15))
			clone.Parent = workspace.DebrisFolder
			TweenService:Create(
				clone,
				TweenInfo.new(math.random(0.5, 1), Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.new(0, math.random(5, 15), 0)
				}
			):Destroy()
			task.wait()
		end
	end)
end

function TokenKit.Crater(p, p2, p3, p4, p5)
	local CraterExtension = require(script.CraterExtension)
	CraterExtension.Ground(p, p2, p3, nil, p4, false, p5)
end

local random = math.random
local v = {
	InnerRadius = 10,
	OuterRadius = 15,
	Lifetime = 1.5,
	Amount = 12,
	Size = 0.5,
	GroundAllowance = -20,
	Velocity = {
		Min = 20,
		Max = 40
	}
}

function TokenKit:GroundRocks()
	local CF = self.CF
	self.InnerRadius = self.InnerRadius or v.InnerRadius
	self.OuterRadius = self.OuterRadius or v.OuterRadius
	self.Lifetime = self.Lifetime or v.Lifetime
	self.Amount = self.Amount or v.Amount
	self.Size = self.Size or v.Size
	self.GroundAllowance = self.GroundAllowance or v.GroundAllowance
	self.Velocity = self.Velocity or v.Velocity
	local parts = {}

	for i = 1, 360, 360 / self.Amount do
		local v2 = math.random(self.InnerRadius, self.OuterRadius) * math.cos((math.rad(i)))
		local v3 = math.random(self.InnerRadius, self.OuterRadius) * math.sin((math.rad(i)))
		local raycastResult = workspace:Raycast(
			(CF * CFrame.new(v2, 10, v3)).Position,
			Vector3.new(0, self.GroundAllowance, 0),
			self.RayParams or vfxUtility.RayParams.Map
		)

		if not raycastResult then
			continue
		end

		local v4 = typeof(self.Size) == "table" and math.random(self.Size.Min * 10, self.Size.Max * 10) / 10 or self.Size
		local part = PartCache.GetPart()
		part.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
			math.rad((math.random(-180, 180))),
			math.rad((math.random(-180, 180))),
			(math.rad((math.random(-180, 180))))
		)
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Material = raycastResult.Material
		part.MaterialVariant = raycastResult.Instance.MaterialVariant
		part.Size = createVector(0, 0, 0)
		part.Color = raycastResult.Instance.Color
		part.CanQuery = false
		part.CanTouch = false
		part.CanCollide = false
		part.Anchored = false
		local tween = TweenService:Create(part, TweenInfo.new(0.25), {
			Size = createVector(1, 1, 1) * v4
		})
		tween:Play()
		tween:Destroy()
		parts[#parts + 1] = part
		part.AssemblyLinearVelocity = Vector3.new(0, random(self.Velocity.Min, self.Velocity.Max), 0)
	end

	task.wait(self.Lifetime)

	for _, v2 in pairs(parts) do
		local tween = TweenService:Create(v2, TweenInfo.new(0.5), {
			Size = createVector(0, 0, 0)
		})
		tween:Play()
		tween:Destroy()
		task.delay(0.5, PartCache.DeletePart, v2)
		task.wait(0.1)
	end
end

function TokenKit.FindPointOnCircumferenceRandom(p, p2, p3, p4)
	local v2 = 6.283185307179586 / p3 * p2
	return (Vector3.new(p * math.cos(v2), p4, p * math.sin(v2)))
end

function TokenKit.AlignCFrame(data, p)
	local p2 = data.p
	local v2 = p or createVector(0, 1, 0)
	local rightVector = data.LookVector:Cross(v2)

	if rightVector.Magnitude < 0.1 then
		rightVector = data.RightVector
	end

	local cross = rightVector:Cross(v2)
	return CFrame.fromMatrix(p2, rightVector, v2, cross)
end

return TokenKit