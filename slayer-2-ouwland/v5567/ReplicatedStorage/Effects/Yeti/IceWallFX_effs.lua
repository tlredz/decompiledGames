local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local debree = workspace.Debree
local sounds = script:FindFirstChild("Sounds")
local wall_Assets = script.Assets:WaitForChild("Wall_Assets")
local wall = wall_Assets:WaitForChild("Wall")
local v = {
	[2] = true,
	[5] = true,
	[8] = true
}

local function segmentVoices(p: string)
	return v[tonumber(p) or 0] == true
end

local function soundAnchor(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") then
		return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopWallSound(parent, childName: string)
	local primaryPart = parent.PrimaryPart
	local sound = primaryPart and primaryPart:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		sound:Stop()
	end
end

local function getFxPart(wall_Assets2, p: string)
	for _, part in wall_Assets2:GetChildren() do
		if part.Name == p and part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

local function prepFxClone(p: string)
	local fxPart = getFxPart(wall_Assets, p)

	if fxPart == nil then
		return nil
	end

	local clone = fxPart:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
		end
	end

	clone.Anchored = true
	clone.CanCollide = false
	return clone
end

local function placeFxClone(folder, cFrame: CFrame)
	local v2 = cFrame * folder.CFrame:Inverse()

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.CFrame = v2 * part.CFrame
		end
	end

	folder.CFrame = cFrame
end

local function emitWallFx(instance, p: string, p2)
	local v2 = prepFxClone(p)

	if v2 == nil then
		return nil
	end

	local fxPart = getFxPart(wall_Assets, p)
	local cFrameOffset = fxPart and fxPart:FindFirstChild("CFrameOffset")
	local identity

	if cFrameOffset == nil or not cFrameOffset:IsA("CFrameValue") then
		identity = CFrame.identity
	else
		identity = cFrameOffset.Value
	end

	local v3 = instance.Size.Y / wall.Size.Y
	placeFxClone(v2, instance.CFrame * CFrame.new(identity.Position * v3) * identity.Rotation)
	v2.Parent = debree
	DebrisModule:AddItem(v2, 5)
	vfxUtility.EmitAll(v2, p2)
	return v2
end

local function segmentStagger(p: string, p2: number, p3: number, flag: boolean)
	local v2 = math.min(math.abs((tonumber(p) or 1) - 5), 4) / 4

	if not flag then
		v2 = 1 - v2
	end

	return p2 + v2 * p3
end

return function(p, parent: CFrame, model, p2, p3)
	local DISTANCE_THRESHOLD = 250

	if not (p ~= nil and parent ~= nil) then
		return
	end

	if p == "break" then
		if (parent.PrimaryPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		stopWallSound(parent, "PS2yetiICEWALLslide") -- equivalent call inferred; original call site unknown

		for _, part in parent:GetChildren() do
			if not (part ~= parent.PrimaryPart and part:IsA("BasePart")) then
				continue
			end

			part:SetAttribute("Broken", true)
			local rootWeld = part:FindFirstChild("RootWeld")

			if rootWeld then
				rootWeld.Enabled = false
			end

			part.Anchored = true
			part.Velocity = Vector3.new()
			task.wait()
			part.Anchored = false
			part.CanCollide = false
			local parent2 = part
			task.spawn(function()
				local mass = parent2:GetMass()
				local random = Random.new()
				local v3

				if p3 then
					v3 = Vector3.new(random:NextNumber(-200, 200), 0, random:NextNumber(-200, 200))
				else
					v3 = Vector3.new(random:NextNumber(-350, 350), 0, random:NextNumber(-350, 350))
				end

				parent2:ApplyImpulse(Vector3.new(0, mass * (random:NextNumber(3000, 4500) / 82), 0) + (p2.Position - model.Position).Unit * (p3 and 120 or 200) + v3)
				local v5 = mass * workspace.Gravity
				local bodyForce = Instance.new("BodyForce")
				bodyForce.Force = Vector3.new(0, v5 * 0.14, 0)
				bodyForce.Parent = parent2
				TweenService:Create(bodyForce, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Force = Vector3.new(0, v5 * -0.15, 0)
				}):Play()
				local range = parent2.Size.Magnitude * 0.4
				local v7 = emitWallFx(parent2, "Explosion")

				if v7 == nil then
					return
				end

				local name = parent2.Name

				if v[tonumber(name) or 0] == true then
					vfxUtility.PlaySound(sounds, "PS2yetiICEWALLexplode", v7, true)
				end

				local attachment = v7:FindFirstChild("Attachment")
				local pointLight = attachment and attachment:FindFirstChild("PointLight")

				if pointLight == nil then
					return
				end

				pointLight.Range = range
				TweenService:Create(pointLight, TweenInfo.new(0.09, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Brightness = 15
				}):Play()
				task.delay(0.09, function()
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Brightness = 0
						}
					):Play()
					task.delay(0.2, function()
						pointLight:Destroy()
					end)
				end)
			end)

			for _, emitter in part:GetChildren() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			part.CollisionGroup = "NoCollisions"
		end
	elseif p == "Explosion" then
		if (parent - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		local v2 = prepFxClone("Explosion")

		if v2 == nil then
			return
		end

		placeFxClone(v2, CFrame.new(parent) * v2.CFrame.Rotation)
		v2.Parent = debree
		DebrisModule:AddItem(v2, 3)
		vfxUtility.EmitAll(v2)
		local attachment = v2:FindFirstChild("Attachment")
		local pointLight = attachment and attachment:FindFirstChild("PointLight")

		if pointLight ~= nil then
			TweenService:Create(pointLight, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Brightness = 30
			}):Play()
			task.delay(0.1, function()
				TweenService:Create(
					pointLight,
					TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Brightness = 0
					}
				):Play()
				task.delay(0.25, function()
					pointLight:Destroy()
				end)
			end)
		end
	elseif p == "Push" then
		if typeof(parent) ~= "CFrame" or (parent.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		Cam_Shaker(parent.Position, {
			FadeInTime = 0,
			Frequency = 0.25,
			Amplitude = 0.6,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.3, 0.3, 0.3),
			PositionInfluence = createVector(1, 1, 1)
		})
		local clone = script.Assets.IceForward:Clone()
		clone:PivotTo(parent)
		clone.Parent = debree
		Ouwmit.Emit(clone)
		DebrisModule:AddItem(clone, 3)

		if not clone:IsA("BasePart") then
			if clone:IsA("Model") then
				clone = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
			else
				clone = nil
			end
		end

		if clone then
			vfxUtility.PlaySound(sounds, "PS2yetiICEWALLslap", clone, true)
		end

		if typeof(model) == "Instance" and model:IsA("Model") and model.PrimaryPart then
			vfxUtility.PlaySound(sounds, "PS2yetiICEWALLslide", model.PrimaryPart, true)
		end
	elseif p == "Appear" then
		if not parent then
			return
		end

		parent:WaitForChild("Root", 3)

		if parent:FindFirstChild("Root") == nil then
			return
		end

		if model ~= nil then
			Cam_Shaker(model.Position, {
				FadeInTime = 0,
				Frequency = 0.25,
				Amplitude = 0.75,
				SustainTime = 0.25,
				FadeOutTime = 0.8,
				RotationInfluence = createVector(0.3, 0.3, 0.3),
				PositionInfluence = createVector(1, 1, 1)
			})
			local clone = script.Assets.IceWallGroundSlam:Clone()
			clone:PivotTo(model)
			clone.Parent = debree
			local raycastResult = workspace:Raycast(model.Position, createVector(0, -20, 0), RaycastHelper.Crater)
			Ouwmit.Emit(clone, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
			DebrisModule:AddItem(clone, 3)

			if not clone:IsA("BasePart") then
				if clone:IsA("Model") then
					clone = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
				else
					clone = nil
				end
			end

			if clone then
				vfxUtility.PlaySound(sounds, "PS2yetiICEWALLstomp", clone, true)
			end
		end

		if (parent.PrimaryPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		local v2 = 0

		for i = 1, #parent.Name do
			v2 = (v2 * 31 + string.byte(parent.Name, i)) % 2147483647
		end

		local random = Random.new(v2)
		local primaryPart = parent.PrimaryPart
		local v3 = primaryPart.Size.X / 9
		local v4 = wall.Size.Y * 1.5

		for i = 1, 9 do
			local v5 = (i - 5) * v3
			local v8 = i
			local v9 = 1.5 * random:NextNumber(0.88, 1.12)
			local v10 = random:NextNumber(-0.4, 0.4)
			local v12 = random:NextNumber(-0.6, 0.6)
			local v13 = CFrame.Angles(
				math.rad((random:NextNumber(-4, 4))),
				math.rad((random:NextNumber(-10, 10))),
				(math.rad((random:NextNumber(-5, 5))))
			)
			local v14 = math.min(math.abs((tonumber((tostring(i))) or 1) - 5), 4) / 4 * 0.22 + 0.125
			task.spawn(function()
				local clone = wall:Clone()
				clone.Name = tostring(v8)
				clone.Size *= v9
				local v15 = -3 + (clone.Size.Y - v4) / 2 + v10
				local weld = Instance.new("Weld")
				weld.Name = "RootWeld"
				weld.Part0 = primaryPart
				weld.Part1 = clone
				weld.C0 = CFrame.new(v5, v15, v12) * v13
				weld.Enabled = false
				weld.Parent = clone
				clone.Anchored = true
				clone.CFrame = primaryPart.CFrame * weld.C0
				local Y = clone.Size.Y
				local position = clone.Position
				clone.Position = position - Vector3.new(0, Y * 1.2, 0)
				clone.Parent = parent
				task.delay(v14, function()
					TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
						Position = position
					}):Play()
					task.delay(0.4, function()
						if parent:GetAttribute("Retiring") or clone:GetAttribute("Broken") then
							return
						end

						clone.Anchored = false
						clone.Massless = true
						weld.C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame)
						weld.Enabled = true
					end)

					for i2, emitter in clone:GetChildren() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					local v16 = emitWallFx(clone, "Main")

					if v16 == nil then
						return
					end

					local name = clone.Name

					if v[tonumber(name) or 0] == true then
						vfxUtility.PlaySound(sounds, "PS2yetiICEWALLspawn", v16, true)
					end

					local attachment = v16:FindFirstChildOfClass("Attachment")

					if attachment == nil then
						return
					end

					local range = clone.Size.Magnitude * 0.45
					local pointLight = Instance.new("PointLight")
					pointLight.Range = range
					pointLight.Brightness = 0
					pointLight.Color = Color3.fromRGB(92, 198, 255)
					pointLight.Parent = attachment
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Brightness = 50
						}
					):Play()
					task.delay(0.1, function()
						TweenService:Create(
							pointLight,
							TweenInfo.new(0.23, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Brightness = 0
							}
						):Play()
						task.delay(0.23, function()
							pointLight:Destroy()
						end)
					end)
				end)
			end)
		end
	elseif p == "Retract" then
		if not parent or (parent.PrimaryPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		parent:SetAttribute("Retiring", true)
		stopWallSound(parent, "PS2yetiICEWALLslide") -- equivalent call inferred; original call site unknown
		Cam_Shaker(parent.PrimaryPart.Position, {
			FadeInTime = 0,
			Frequency = 0.25,
			Amplitude = 0.5,
			SustainTime = 0.2,
			FadeOutTime = 0.4,
			RotationInfluence = createVector(0.4, 0.4, 0.4),
			PositionInfluence = createVector(0.75, 0.75, 0.75)
		})

		for _, part in parent:GetChildren() do
			if part == parent.PrimaryPart or not part:IsA("BasePart") or part:GetAttribute("Broken") then
				continue
			end

			local rootWeld = part:FindFirstChild("RootWeld")

			if rootWeld then
				rootWeld.Enabled = false
			end

			part.Anchored = true
			local v2 = (1 - math.min(math.abs((tonumber(part.Name) or 1) - 5), 4) / 4) * 0.19 + 0.01
			local position = part.Position
			local Y = part.Size.Y
			local size = part.Size + Vector3.new(0, Y * 0.15, 0)
			local size2 = part.Size * createVector(1, 0, 1)
			local v7 = part
			local position2 = position + Vector3.new(0, Y * 0.15, 0)
			local position3 = position - Vector3.new(0, Y / 2 + 1, 0)
			task.delay(v2, function()
				local parent2 = emitWallFx(v7, "Explosion")

				if parent2 ~= nil then
					local name = v7.Name

					if v[tonumber(name) or 0] == true then
						vfxUtility.PlaySound(sounds, "PS2yetiICEWALLexplode", parent2, true)
					end

					local pointLight = Instance.new("PointLight")
					pointLight.Range = v7.Size.Magnitude * 0.45
					pointLight.Brightness = 0
					pointLight.Color = Color3.fromRGB(92, 198, 255)
					pointLight.Parent = parent2
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Brightness = 45
						}
					):Play()
					task.delay(0.1, function()
						TweenService:Create(
							pointLight,
							TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Brightness = 0
							}
						):Play()
						task.delay(0.25, function()
							pointLight:Destroy()
						end)
					end)
				end

				TweenService:Create(v7, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Position = position2,
					Size = size
				}):Play()

				for i, emitter in v7:GetChildren() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.delay(0.2, function()
					TweenService:Create(v7, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Position = position3,
						Size = size2
					}):Play()
				end)
			end)
		end
	end
end