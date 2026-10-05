local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local Effect = require(ReplicatedStorage.Effect)
local Util = require(ReplicatedStorage.Util)
local Pool = require(ReplicatedStorage.Pool)
local misc = Util.Misc
local distributedLoop = Util.DistributedLoop
local loadTexture = misc.LoadTexture

local function darkenColor(p, p2)
	return (p2 or Color3.new(0.1, 0.1, 0.1)):Lerp(p or Color3.new(1, 1, 1), 0.5):Lerp(Color3.new(), 0.575)
end

local doughExplosionsDripScatter = Effect.new("Dough.Explosions.DripScatter")
local doughShockwaves2 = Effect.new("Dough.Shockwaves.2")
local doughMiscDebrisHeatMark = Effect.new("Dough.Misc.Debris.HeatMark")
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local models = dough:WaitForChild("Models")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local v = {
	{ "UpperArm", "Shoulder" },
	{ "LowerArm", "Elbow" },
	{ "Hand", "Wrist" }
}
local v2 = {
	"rbxassetid://8428219703",
	"rbxassetid://8428219616",
	"rbxassetid://8428219459",
	"rbxassetid://8428219307",
	"rbxassetid://8428219167",
	"rbxassetid://8428219050",
	"rbxassetid://8428218923",
	"rbxassetid://8428218803",
	"rbxassetid://8428218672",
	"rbxassetid://8428218491",
	"rbxassetid://8428218257",
	"rbxassetid://8428218109",
	"rbxassetid://8428217936",
	"rbxassetid://8428217814",
	"rbxassetid://8428217664",
	"rbxassetid://8428217541",
	"rbxassetid://8428217335",
	"rbxassetid://8428217113",
	""
}

local function joinParts(part, instance, p)
	local child = part:FindFirstChild(instance.Name .. "Attachment")
	local child2 = instance:FindFirstChild(instance.Name .. "Attachment")
	CFrame.new()
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = part
	motor6D.Part1 = instance
	local cFrame, v3

	if child then
		cFrame = child.CFrame
		v3 = child.CFrame:PointToObjectSpace(child2.Position)
	else
		cFrame = p.CFrame * child2.CFrame:inverse() * CFrame.new(child2:GetAttribute("Offset") or Vector3.new()):inverse()
		v3 = cFrame:VectorToObjectSpace(createVector(0, 1, 0))
	end

	motor6D.C0 = cFrame
	motor6D.Parent = instance
	return motor6D, cFrame, v3, child or p, child2
end

local function popShot(value, worldCFrame, value2)
	local magnitude = (currentCamera.CFrame.p - worldCFrame.p).Magnitude

	if 200 + 10 * value2 < magnitude then
		return
	end

	local v3 = value2 or 1
	local attachment = Instance.new("Attachment")
	attachment.WorldCFrame = worldCFrame
	local v4 = 0.5
	local v5 = {}
	local child = dough.Particles.Arm:FindFirstChild(value or "Shoot")

	if child then
		for _, child2 in pairs(child:GetChildren()) do
			local clone = child2:Clone()
			local enable = child2:GetAttribute("Enable") or 0
			v4 = math.max(v4, clone.Lifetime.Max + enable)
			misc.ScaleParticle(clone, v3)
			clone.Parent = attachment
			table.insert(v5, clone)
		end
	end

	attachment.Parent = workspace.Terrain

	for k, v6 in pairs(v5) do
		v6:Emit(v6:GetAttribute("Emit") or 1)
		local enable = v6:GetAttribute("Enable")

		if enable then
			v6.Enabled = true
			local v7 = v6
			task.delay(enable, function()
				v7.Enabled = false
			end)
		end

		v5[k] = nil
	end

	Util.Debris:AddItem(attachment, v4 + 0.1)
end

local v3 = {}
local v4 = {}
local v5 = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))

function v4.new(instance, value, p, data, instance2)
	if v3[instance] then
		v3[instance]:scale(value)
		return v3[instance]
	end

	local v6 = value or 1
	local clone = models:FindFirstChild("Arm"):Clone()
	local child = instance:FindFirstChild("Right" .. v[1][1])
	child:FindFirstChild("Right" .. v[1][2])
	child:FindFirstChild("Right" .. v[1][2] .. "RigAttachment")
	local child2 = instance:FindFirstChild("Right" .. v[2][1])
	child2:FindFirstChild("Right" .. v[2][2])
	local child3 = child2:FindFirstChild("Right" .. v[2][2] .. "RigAttachment")
	instance:FindFirstChild("Right" .. v[3][1]):FindFirstChild("Right" .. v[3][2])
	clone:SetPrimaryPartCFrame(child2.CFrame)
	local primaryPart = clone.PrimaryPart or clone:FindFirstChild("Forearm")
	local fist = clone:FindFirstChild("Fist")
	local fistLayer = clone:FindFirstChild("FistLayer")
	local color = Color3.new()

	if data then
		if instance2 and instance2:IsDescendantOf(workspace) then
			color = instance2.Color
		elseif math.floor(data.R * 255 + 0.5) == 1 and math.floor(data.G * 255 + 0.5) == 1 and math.floor(data.B * 255 + 0.5) == 1 then
			color = Color3.fromHSV(math.random(), 1, 1)
		else
			color = data
		end
	end

	local createLayer

	if p and data then
		fistLayer.Color = color
		createLayer = true
	else
		createLayer = false
		fistLayer = nil
	end

	local references = {}
	local attachments = {
		Haki = {},
		Default = {}
	}
	local particles = {
		Charge = {},
		Ignite = {},
		Travel = {
			Front = {
				Flames = {},
				Generic = {}
			},
			Back = {
				Flames = {},
				Generic = {}
			}
		}
	}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Name:find("Layer") then
			part.Transparency = data and createLayer and 0 or 1
		end

		local specialMesh = part:FindFirstChildOfClass("SpecialMesh")
		local attachedTo = part == primaryPart and child2 or primaryPart
		local frontAttachment = part:FindFirstChild("FrontAttachment")
		local backAttachment = part:FindFirstChild("BackAttachment")

		if frontAttachment and backAttachment then
			local v12 = part.Name == "Fist" and "Default" or "Haki"
			attachments[v12].Front = {
				Attachment = frontAttachment,
				Position = frontAttachment.Position
			}
			attachments[v12].Back = {
				Attachment = backAttachment,
				Position = backAttachment.Position
			}
		end

		local v13

		if attachedTo == child2 then
			v13 = child3
		else
			v13 = false
		end

		local weld, C0, offset, object2, object3 = joinParts(attachedTo, part, v13)
		references[part] = {
			AttachedTo = attachedTo,
			Size = part.Size,
			Scale = specialMesh and specialMesh.Scale,
			Weld = weld,
			C0 = C0,
			Offset = offset,
			Attachment0 = {
				Object = object2,
				CFrame = object2.CFrame
			},
			Attachment1 = {
				Object = object3,
				CFrame = object3.CFrame
			}
		}
		references[part].WeldC0 = references[part].Weld.C0
		part.Anchored = false
	end

	local maxParticleLifetime = 0

	for _, child4 in pairs(dough.Particles.Arm.Charge:GetChildren()) do
		maxParticleLifetime = math.max(maxParticleLifetime, child4.Lifetime.Max)
		local clone2 = child4:Clone()
		clone2.Enabled = false
		clone2.Parent = primaryPart
		local v12 = clone2.Name == "FloatingBlobs" and 4 or 1
		table.insert(particles.Charge, {
			Particle = clone2,
			Data = {
				Size = clone2.Size.Keypoints,
				Speed = clone2.Speed,
				Acceleration = clone2.Acceleration * v12,
				ZOffset = clone2.ZOffset
			}
		})
	end

	for _, child4 in pairs(dough.Particles.Arm.Ignite:GetChildren()) do
		maxParticleLifetime = math.max(maxParticleLifetime, child4.Lifetime.Max)
		local clone2 = child4:Clone()
		clone2.Enabled = false
		clone2.Parent = primaryPart
		table.insert(particles.Ignite, {
			Particle = clone2,
			Data = {
				Size = clone2.Size.Keypoints,
				Speed = clone2.Speed,
				Acceleration = clone2.Acceleration,
				ZOffset = clone2.ZOffset
			}
		})
	end

	for _, child4 in pairs(dough.Particles.Arm.Travel:GetChildren()) do
		for _, child5 in pairs(child4:GetChildren()) do
			for _, child6 in pairs(child5:GetChildren()) do
				maxParticleLifetime = math.max(maxParticleLifetime, child6.Lifetime.Max)
				local clone2 = child6:Clone()
				clone2.Enabled = false
				clone2.Parent = attachments[p and "Haki" or "Default"][child4.Name].Attachment
				table.insert(particles.Travel[child4.Name][child5.Name], {
					Particle = clone2,
					Data = {
						Size = clone2.Size.Keypoints,
						Speed = clone2.Speed,
						Acceleration = clone2.Acceleration,
						ZOffset = clone2.ZOffset
					}
				})
			end
		end
	end

	local object = setmetatable({
		ForearmAttachment = child3,
		CreateLayer = createLayer,
		FistLayer = fistLayer,
		LayerColor = color,
		DarkenedColor = darkenColor(color),
		Forearm = child2,
		Fist = fist,
		MaxParticleLifetime = maxParticleLifetime,
		LastDrip = 0,
		LastShockwave = 0,
		Holding = true,
		Character = instance,
		AnimatedScale = 0,
		OriginalScale = v6,
		Scale = v6,
		Model = clone,
		MainPart = primaryPart,
		MainJoint = primaryPart:FindFirstChildOfClass("Motor6D"),
		References = references,
		Attachments = attachments,
		Particles = particles
	}, {
		__index = v4
	})
	v3[instance] = object
	v5:add(object)
	return object:__setup()
end

function v4:__setup()
	local fist = self.Fist
	local mainPart = self.MainPart
	local fistLayer = self.FistLayer
	local model = self.Model
	local createLayer = self.CreateLayer
	local forearm = self.Forearm
	local forearmAttachment = self.ForearmAttachment
	local references = self.References
	fist.Material = mainPart.Material
	fist.Color = mainPart.Color

	if fistLayer then
		fistLayer.Material = mainPart.Material
		fistLayer.Color = mainPart.Color
	end

	local originalScale = self.OriginalScale
	model.Parent = self.Character
	Util.Sound:Play("Dough.DoughSpawn", self.Character.HumanoidRootPart.Position, nil, 2.51625)
	self:ignite(true, "Charge")
	local clone = fist:Clone()
	clone.Color = self.LayerColor
	clone:BreakJoints()
	clone.Transparency = 1
	clone.Material = "Neon"
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = references[fist].Weld.Part0
	motor6D.Part1 = clone
	motor6D.C0 = references[fist].C0
	motor6D.Parent = clone
	local clone2, motor6D2

	if createLayer then
		clone2 = fistLayer:Clone()
		clone2.Color = clone.Color
		clone2:BreakJoints()
		clone2.Transparency = 1
		clone2.Material = "Neon"
		motor6D2 = Instance.new("Motor6D")
		motor6D2.Part0 = references[fistLayer].Weld.Part0
		motor6D2.Part1 = clone2
		motor6D2.C0 = references[fistLayer].C0
		motor6D2.Parent = clone2
		clone2.Parent = model
	else
		clone2 = nil
		motor6D2 = nil
	end

	clone.Parent = model
	local v6 = math.max(0, (currentCamera.CFrame.p - mainPart.Position).Magnitude / (125 + 10 * originalScale))

	if v6 <= 1 then
		local power = 1 - v6
		Effect.new("ShakeCam"):replicate({
			Magnitude = 8,
			Roughness = 8,
			FadeIn = 0.2,
			FadeOut = 0.5,
			PosInfluence = createVector(0.25, 0.25, 0.25),
			RotInfluence = createVector(0.75, 0, 0.75),
			Power = power
		})
	end

	local v7 = 0.25

	if createLayer then
		local v8 = v7
		local v9 = 0

		for _, child in pairs(dough.Particles.Buso:GetChildren()) do
			local clone3 = child:Clone()
			Util.Misc.ScaleParticle(clone3, self.Scale / 2)
			clone3.Color = ColorSequence.new(self.LayerColor)
			clone3.Parent = fist
			clone3:Emit((clone3:GetAttribute("Emit") or 10) + self.Scale)
			clone3.Enabled = true
			v9 = math.max(v9 + v8 * 2, child.Lifetime.Max)
			task.delay(v8 * 2, function()
				clone3.Enabled = false
				Util.Debris:AddItem(clone3, clone3.Lifetime.Max + 0.1)
			end)
		end
	end

	local v8 = false
	tick()
	local now = nil
	distributedLoop:add(function(p, _)
		if not (self.Holding or now) then
			now = tick()
			v7 /= 2
		end

		local v9 = math.min(1, p / v7)
		local quad = Util.Tween.ease["in"].quad(v9, 0, 1, 1)
		local circ = Util.Tween.ease["in"].circ(v9, 0, 1, 1)
		local lerped = mainPart.Color:Lerp(self.DarkenedColor, circ)
		local color

		if createLayer then
			color = mainPart.Color:Lerp(self.DarkenedColor, circ)
		end

		fist.Color = lerped
		clone.Transparency = quad
		clone.Size = fist.Size * 1.125
		motor6D.C1 = CFrame.new(references[fist].Offset * (self.Scale * 1.125 - 1))

		if createLayer then
			fistLayer.Color = color
			clone2.Transparency = quad
			clone2.Size = fistLayer.Size * 1.125
			motor6D2.C1 = CFrame.new(references[fistLayer].Offset * (self.Scale * 1.125 - 1))
		end

		if not v8 then
			clone.Transparency = 0
			fist.Material = "Ice"

			if createLayer then
				clone2.Transparency = 0
				fistLayer.Material = "Neon"
			end

			v8 = true
		end

		if v9 ~= 1 then
			return
		end

		self.DoneGlowing = true
		clone:Destroy()

		if createLayer then
			clone2:Destroy()
		end

		return true
	end)

	for _, child in pairs(dough.Particles.Arm.Forearm:GetChildren()) do
		local enable = child:GetAttribute("Enable")
		local emit = child:GetAttribute("Emit") or child:GetAttribute("EmitCount")
		local emitDelay = child:GetAttribute("EmitDelay")
		local max = child.Lifetime.Max
		local clone3 = child:Clone()
		misc.ScaleParticle(clone3, forearm.Size.Magnitude / 1.68)
		clone3.Enabled = enable and true or false
		clone3.Parent = forearmAttachment

		if emitDelay then
			local v9 = clone3
			local v10 = emit
			task.delay(emitDelay, function()
				v9:Emit(v10)
			end)
		else
			clone3:Emit(emit)
		end

		if typeof(enable) ~= "number" then
			continue
		end

		local v9 = clone3
		local max2 = max
		task.delay(enable, function()
			v9.Enabled = false
			wait(max2 + 0.1)
			v9:Destroy()
		end)
	end

	Util.Sound:Play("Dough.DoughAmbienceLoop", model.PrimaryPart, nil, 2.6435)
	return self
end

function v4:attach(instance, travelData)
	if self.Destroyed then
		return
	end

	self.Holding = false

	if self.MainJoint then
		self.MainJoint:Destroy()
	end

	for _, child in pairs(self.Model:GetChildren()) do
		child.Anchored = true
	end

	if instance then
		self.Model:SetPrimaryPartCFrame(instance.CFrame)
	end

	self:ignite(false, "Charge")
	self:ignite(true, "Travel", "Front", "Generic")

	if not self.Model.PrimaryPart then
		self.Model:FindFirstChild("Forearm")
	end

	self.MainJoint = nil
	self.Model.Parent = instance
	Util.Sound:Play("Dough.DoughJabFire", self.Character.HumanoidRootPart.Position)
	v3[self.Character] = nil
	self.Character = instance

	if self.Character then
		if travelData then
			self.Model:SetPrimaryPartCFrame(travelData.Origin)
			travelData.StartTime = tick()
			travelData.CFrame = self.Character.CFrame
			travelData.TimeDifference = math.max(0, (travelData.StartTime - travelData.Timestamp) / 2 - 0.1)
			travelData.DistanceTravelled = travelData.Speeds[travelData.TimeDifference > travelData.SlowTravelTime and 2 or 1] * travelData.TimeDifference
			travelData.LastDistanceTravelled = travelData.DistanceTravelled
			self.TravelData = travelData
		end

		v3[self.Character] = self

		if (currentCamera.CFrame.p - instance.CFrame.p).Magnitude < 500 + self.Scale * 5 then
			local cFrame = self.Model.PrimaryPart.CFrame
			local v6 = math.floor(2 * self.Scale + 2.5) + 5

			for i = 1, 2 do
				local v7 = i % 2 == 0 and 1 or -1
				local vector2 = Vector3.new(v7 * self.Scale * 1.125, 0, -self.Scale * 1.25)
				local cframe = CFrame.Angles(0, v7 * 3.141592653589793 / 8, 0)
				local _ = (cFrame.p - createVector(0, 1, 0) * v6).Magnitude
				local rayCastWhitelist, v8, v9 = Util.RayCastWhitelist(
					cFrame * cframe * vector2,
					-Vector3.new(0, v6 + self.Scale * 2.1),
					{ workspace:FindFirstChild("Map") }
				)
				local v10 = math.max(0, (cFrame.p - v8).Magnitude - self.Scale * 2)
				local _ = 1 - v10 / v6

				if not (rayCastWhitelist and v10 < v6) then
					continue
				end

				local v11 = v10 / v6
				local point = Util.Tween.point(self.Scale * 1, self.Scale * 0.25, v11)
				local point2 = Util.Tween.point(self.Scale * 4.25, self.Scale * 5, v11)
				doughMiscDebrisHeatMark:replicate({
					Hit = rayCastWhitelist,
					CFrame = (misc.AlignCFrame(CFrame.new(Vector3.new(), cFrame.LookVector) + v8, v9) * cframe + v9) * CFrame.new(
						-v7 * self.Scale * 0.5 * v11,
						0,
						0
					) * CFrame.Angles(0, -v7 * 3.141592653589793 / 12 * v11, 0),
					Scale = Vector2.new(point, point2),
					FadeIn = 0.3 - 0.15 * v11,
					Lifetime = 1 - 0.15 * v11,
					FadeOut = 0.75
				})
			end

			doughExplosionsDripScatter:replicate({
				CFrame = instance.CFrame * CFrame.new(0, 0, instance.Size.Z / 4) * CFrame.Angles(
					3.141592653589793,
					0,
					0
				),
				Spread = Vector2.new(90, 90),
				Scale = self.Scale / 2.25,
				Drag = 1,
				Distance = 10 + self.Scale * 3,
				Rate = 10,
				Gravity = 1,
				Time = 0.45,
				Influence = { 0.5, 1.5 }
			})
			popShot("Shoot3", cFrame * CFrame.new(0, 0, instance.Size.Z / 2), self.Scale * 0.55)
			popShot("Shoot2", cFrame * CFrame.new(0, 0, -instance.Size.Z / 1.5 * 2), self.Scale * 0.55)
			popShot("Shoot", cFrame * CFrame.new(0, 0, -instance.Size.Z / 1.25 * 2), self.Scale * 0.55)

			for i = 1, 3 do
				local magnitude = (instance.Position - currentCamera.CFrame.p).Magnitude
				local v7 = 50 + self.Scale * 2

				if i < 3 and magnitude < v7 then
					math.min(1, magnitude / v7)
					Effect.new("ShakeCam"):replicate({
						Preset = "Bump",
						Power = 1 - magnitude / v7 * 0.5
					})
				end

				local scale = (2.5 + self.Scale * 3) * ((4 - i) / 3 + 0.8)
				doughShockwaves2:replicate({
					CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0) + cFrame.LookVector * scale / 1.5 * i - cFrame.LookVector * instance.Size.Z / 1.25,
					VectorOffset = -cFrame.LookVector * scale / 2.5 * (i / 3 + 0.8),
					Scale = scale,
					Speed = -1.5,
					Duration = (4 - i) * 0.25 / 3 + 0.2,
					Color = Color3.fromRGB(500, 500, 500)
				})
				task.wait(0.016666666666666666)
			end
		end
	else
		self:Destroy()
	end
end

function v4:deflate(value, p)
	self:ignite(true, "Ignite")
	local decal = self.Model.PrimaryPart:FindFirstChildOfClass("Decal")
	local color = self.Model.PrimaryPart.Color
	local color2 = Color3.fromRGB(225, 125, 0)
	local clone = nil

	if decal then
		color2 = Color3.fromRGB(2555, 500, 205)
	else
		clone = self.Model.PrimaryPart:Clone()
		clone.Color = color2
		clone.Material = "Neon"
		clone.Size *= 0
		clone:ClearAllChildren()
		local motor6D = Instance.new("Motor6D")
		motor6D.Part0 = self.Model.PrimaryPart
		motor6D.Part1 = clone
		motor6D.Parent = clone
		clone.Parent = self.Model
	end

	local folder = Instance.new("Folder")
	folder:SetAttribute("Power", false)
	folder.Parent = self.Model.PrimaryPart
	Effect.new("Dough.Misc.Debris.Trail"):replicate({
		Root = self.Model.PrimaryPart,
		Indicator = folder
	})
	local bindableEvent = Instance.new("BindableEvent", clone)
	bindableEvent.Event:Connect(function()
		if self.Character and not self.Destroyed then
			folder:SetAttribute("Power", true)
			local cFrame = self.Model.PrimaryPart.CFrame
			task.spawn(function()
				Util.Sound:Play("Dough.DoughFireStart", self.Model.PrimaryPart, nil, 1)
				task.wait(0.75)
				self.LoopedSound = Util.Sound:Play("Dough.DoughFireLoop", self.Model.PrimaryPart, nil, 1)
			end)

			for i = 1, 2 do
				local magnitude = (self.Character.Position - currentCamera.CFrame.p).Magnitude
				local v6 = 50 + self.Scale * 3

				if magnitude < v6 then
					math.min(1, magnitude / v6)
					Effect.new("ShakeCam"):replicate({
						Preset = "Bump",
						Power = 1 - magnitude / v6 * 0.5
					})
				end

				local v7 = 7 + self.Scale * 5
				local scale = v7 * ((3 - i / 2) / 2 + 1)
				doughShockwaves2:replicate({
					CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0) + cFrame.LookVector * scale / 6 * (i - 1),
					VectorOffset = cFrame.LookVector * v7 * (i / 2),
					Scale = scale,
					Speed = (i - 1) * 0.5 + 1,
					Duration = (i / 2 * 0.3 + 0.3) / 2,
					Color = { Color3.fromRGB(2555, 500, 205), Color3.fromRGB(2555, 200, 20) }
				})
				task.wait(0.03333333333333333)
			end
		end
	end)
	local pointLight = Instance.new("PointLight")
	pointLight.Range = 0
	pointLight.Brightness = 0
	pointLight.Color = Color3.fromRGB(255, 85, 0)
	pointLight.Parent = self.Model.PrimaryPart
	self.PointLight = pointLight
	local v6 = value or 0.3
	distributedLoop:add(function(p2, _)
		local v7 = math.min(1, p2 / v6)
		local circ = Util.Tween.ease["in"].circ(v7, 0, 1, 1)
		local sine = Util.Tween.ease["in"].sine(v7, 0, 1, 1)
		Util.Tween.ease.out.sine(v7, 1, -1, 1)
		local quad = Util.Tween.ease.out.quad(v7, 0, 1, 1)
		local lerped = color:Lerp(color2, circ)
		pointLight.Range = self.Scale * 1.5 * sine
		pointLight.Brightness = 20 * sine

		if decal then
			decal.Color3 = lerped
		else
			clone.Size = self.Model.PrimaryPart.Size * 1.05 * quad
		end

		if v7 ~= 1 then
			return
		end

		self.Model.PrimaryPart.Transparency = 1
		self:ignite(false, "Ignite")
		local v8 = p or v6 / 2
		distributedLoop:add(function(p3, _)
			local v9 = math.min(1, p3 / v8)
			local sine2 = Util.Tween.ease.out.sine(v9, 0, 1, 1)

			if clone then
				clone.Transparency = sine2
			end

			if v9 ~= 1 then
				return
			end

			bindableEvent:Fire()
			clone:Destroy()
			return true
		end)
		return true
	end)

	if decal then
		self.Model.PrimaryPart.Transparency = 1
		loadTexture(self.Model.PrimaryPart, v2, 0.016666666666666666)
	end
end

function v4:ignite(enabled, value, value2, value3)
	local v6 = value or "Charge"
	local v7 = value2 or "All"
	local v8 = value3 or "All"
	local particle = self.Particles[v6]

	if v6 == "Charge" or v6 == "Ignite" then
		for _, v9 in pairs(particle) do
			local enable = v9.Particle:GetAttribute("Enable")
			local emit = v9.Particle:GetAttribute("Emit")

			if typeof(enable) == "number" then
				if enabled then
					v9.Particle.Enabled = true
					local v10 = v9
					task.delay(enable, function()
						v10.Particle.Enabled = false
					end)
				end
			elseif enable == true then
				v9.Particle.Enabled = enabled
			end

			if not (emit and enabled) then
				continue
			end

			local emitDelay = v9.Particle:GetAttribute("EmitDelay")
			-- equivalent calls inferred from this helper; original call sites unknown
			local v10 = v9
			local v11 = emit

			local function f()
				v10.Particle:Emit(v11)
			end

			if emitDelay then
				task.delay(emitDelay, f)
			else
				f() -- equivalent call inferred; original call site unknown
			end
		end
	elseif v7 == "All" then
		for _, v9 in pairs(particle) do
			if v8 == "All" then
				for _, v10 in pairs(v9) do
					for _, v11 in pairs(v10) do
						v11.Particle.Enabled = enabled
					end
				end
			else
				for k, v10 in pairs(v9) do
					if k ~= v8 then
						continue
					end

					for _, v11 in pairs(v10) do
						v11.Particle.Enabled = enabled
					end
				end
			end
		end
	else
		local v9 = particle[v7]

		for k, v10 in pairs(v9) do
			if v8 == "All" then
				for _, v11 in pairs(v10) do
					v11.Particle.Enabled = enabled
				end
			elseif k == v8 then
				for _, v11 in pairs(v10) do
					v11.Particle.Enabled = enabled
				end
			end
		end
	end
end

function v4:scale(p)
	if typeof(self) ~= "table" then
		return warn("Please make sure you're calling the function properly (with a reference)")
	end

	self.Scale = p or self.Scale
	local scale = self.Scale

	for k, reference in pairs(self.References) do
		local specialMesh = k:FindFirstChildOfClass("SpecialMesh")
		local scale2 = k:GetAttribute("Scale") or 1

		if specialMesh then
			specialMesh.Scale = reference.Scale * scale
		else
			k.Size = reference.Size * scale * scale2
		end

		if k == self.MainPart then
			local C0 = reference.Attachment0.CFrame * (reference.Attachment1.CFrame + reference.Attachment1.CFrame.p * (scale - 1)):inverse() * CFrame.new(reference.Attachment1.Object:GetAttribute("Offset") or Vector3.new()):inverse()
			reference.Weld.C0 = C0
			reference.Weld.C1 = CFrame.Angles(0, 0, 1.5707963267948966)
		else
			reference.Weld.C1 = CFrame.new(reference.Offset * (scale - 1))
		end
	end

	for _, attachment in pairs(self.Attachments) do
		for _, v6 in pairs(attachment) do
			v6.Attachment.Position = v6.Position * scale
		end
	end

	for _, v6 in pairs(self.Particles.Charge) do
		misc.ScaleParticle(v6.Particle, 0.25 * scale, v6.Data)
	end

	for _, v6 in pairs(self.Particles.Ignite) do
		misc.ScaleParticle(v6.Particle, 0.25 * scale, v6.Data)
	end

	for _, v6 in pairs(self.Particles.Travel) do
		for _, v7 in pairs(v6) do
			for _, v8 in pairs(v7) do
				misc.ScaleParticle(v8.Particle, 0.25 * scale, v8.Data)
			end
		end
	end
end

function v4:Destroy(cframe)
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self.Model.Parent = _WorldOrigin
	self.Model.PrimaryPart.Anchored = true
	self.Model.PrimaryPart:SetAttribute("Destroyed", true)

	if self.LoopedSound then
		Util.Sound:FadeOut(self.LoopedSound, 0.25)
		self.LoopedSound = nil
	end

	if cframe then
		self.Model:SetPrimaryPartCFrame(cframe)
	end

	for _, part in pairs(self.Model:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local decal = part:FindFirstChildOfClass("Decal")

		if decal then
			decal.Transparency = 1
		end

		part.Transparency = 1
	end

	if self.PointLight then
		local TweenService = game:GetService("TweenService")
		TweenService:Create(
			self.PointLight,
			TweenInfo.new(self.MaxParticleLifetime * 0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Range = 0,
				Brightness = 0
			}
		):Play()
	end

	self:ignite(false, "Charge")
	self:ignite(false, "Travel", "All", "All")
	task.delay(self.MaxParticleLifetime + 0.1, function()
		self.Model:Destroy()
	end)

	if self.Character then
		v3[self.Character] = nil
	end
end

v5:setAction(function(object, p)
	local now = tick()

	for _, v6 in pairs(object.Pool) do
		if v6.Model and v6.Model:IsDescendantOf(workspace) and not v6.Destroyed then
			if v6.Holding then
				local layerColor = v6.LayerColor
				local transparency = false

				for _, part in pairs(v6.Character:GetDescendants()) do
					if not (part:IsA("BasePart") and part.Name:find("BusoLayer2") and part.Transparency < 0.99) then
						continue
					end

					if not (part:GetAttribute("Rainbow") or part:GetAttribute("Colored") or part.Color == layerColor) then
						continue
					end

					layerColor = part.Color or part.Color:Lerp(Color3.new(), part.Transparency)
					transparency = part.Transparency
					part:GetAttribute("Rainbow")
					break
				end

				if not transparency then
					layerColor = Color3.new()
					v6.DidParticles = false
				end

				v6.LayerColor = layerColor
				v6.DarkenedColor = darkenColor(v6.LayerColor)

				if v6.DoneGlowing then
					if v6.FistLayer then
						v6.FistLayer.Color = v6.LayerColor
					end

					v6.Fist.Color = v6.DarkenedColor
				end

				if now - v6.LastDrip >= 0.14285714285714285 then
					Effect.new("Dough.Misc.Drip.Generic"):replicate({
						Type = "Generic",
						Root = v6.Model.PrimaryPart
					})
					v6.LastDrip = now
				end
			elseif v6.TravelData then
				local v7 = now - (v6.TravelData.StartTime - v6.TravelData.TimeDifference)

				if v6.TravelData.TotalTravelTime < v7 then
					v6.TravelData.DistanceTravelled = v6.TravelData.TotalDistance
				elseif v6.TravelData.SlowTravelTime < v7 then
					v6.TravelData.DistanceTravelled += v6.TravelData.Speeds[2] * p
				else
					v6.TravelData.DistanceTravelled += v6.TravelData.Speeds[1] * p
				end

				local point = Util.Tween.point(
					v6.TravelData.LastDistanceTravelled,
					v6.TravelData.DistanceTravelled,
					0.25
				)
				v6.TravelData.LastDistanceTravelled = point
				v6.Model:SetPrimaryPartCFrame(CFrame.new(Vector3.new(), v6.TravelData.CFrame.LookVector) + v6.TravelData.CFrame.p + v6.TravelData.CFrame.LookVector * point)
			end
		else
			if not v6.Destroyed then
				v6:Destroy()
			end

			object:remove(v6)
		end
	end
end)
return (setmetatable({}, {
	__index = function(_, value)
		if value:lower() == "get" then
			return function(...)
				local v6 = { ... }
				local v7 = v6[1]

				if typeof(v7) == "table" then
					v7 = v6[2]
				end

				return v3[v7]
			end
		end

		if v4[value] then
			return v4[value]
		end
	end
}))