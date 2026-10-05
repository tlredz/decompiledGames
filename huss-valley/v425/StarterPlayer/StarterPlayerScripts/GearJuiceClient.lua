local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local gearEvent = chickenOrHero.Gear:WaitForChild("GearEvent")
local GearPredictionClient = require(chickenOrHero.Gear:WaitForChild("GearPredictionClient"))
local AirhornCone = require(chickenOrHero.Gear:WaitForChild("AirhornCone"))
local GearCatalog = require(chickenOrHero.Gear:WaitForChild("GearCatalog"))
local folder = Instance.new("Folder")
folder.Name = "LocalGearEffects"
folder.Parent = workspace
local color = Color3.fromRGB(255, 204, 96)
local color2 = Color3.fromRGB(119, 229, 255)
local color3 = Color3.fromRGB(248, 135, 179)
local random = Random.new()
local v = {}
local v2 = {}
local v3 = {}
local v4 = {
	BigDagger = "rbxassetid://105270817990246",
	Cloak = "rbxassetid://96140144540712",
	Adrenaline = "rbxassetid://92981028036615",
	DoorSlam = "rbxassetid://140635119444127",
	Airhorn = "rbxassetid://77661182776010",
	Rescue = "rbxassetid://104414731133846",
	Rocket = "rbxassetid://140324602533286",
	DecoyInflate = "rbxassetid://128355574885118",
	DoorBreak = "rbxassetid://120873363783894",
	BowlingHit = "rbxassetid://4692687595",
	Impact = "rbxassetid://101387462540484",
	LeashThrow = "rbxassetid://74238153433253",
	BananaSlip = "rbxassetid://70557734865364"
}

local function part(position, color4, size)
	if #folder:GetChildren() >= 100 then
		return
	end

	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanTouch = false
	part2.CanQuery = false
	part2.CastShadow = false
	part2.Material = Enum.Material.Neon
	part2.Color = color4
	part2.Size = size
	part2.CFrame = CFrame.new(position)
	part2.Parent = folder
	Debris:AddItem(part2, 1.4)
	return part2
end

local function burst(p, color4, p2, p3)
	for _ = 1, p2 do
		local v5 = part(p, color4, createVector(0.16, 0.16, 0.65))

		if not v5 then
			continue
		end

		local unit = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(0.1, 1), random:NextNumber(-1, 1)).Unit
		v5.CFrame = CFrame.lookAt(p, p + unit)
		TweenService:Create(v5, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = v5.CFrame + unit * p3,
			Transparency = 1,
			Size = createVector(0.03, 0.03, 0.2)
		}):Play()
	end
end

local function pulse(p, color4, p2)
	local v5 = part(p, color4, createVector(1, 1, 1))

	if not v5 then
		return
	end

	v5.Shape = Enum.PartType.Ball
	v5.Transparency = 0.65
	TweenService:Create(v5, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(1, 1, 1) * p2,
		Transparency = 1
	}):Play()
end

local function airhornWave(position)
	local v5 = part(position, color, createVector(1, 0.6, 1))

	if not v5 then
		return
	end

	v5.Shape = Enum.PartType.Ball
	v5.Transparency = 0.65
	TweenService:Create(v5, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(AirhornCone.Range * 2, 1.2, AirhornCone.Range * 2),
		Transparency = 1
	}):Play()
end

local function sound(position, soundId, value, instance, p)
	if not soundId then
		return
	end

	local humanoidRootPart

	if typeof(instance) == "Instance" then
		humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	else
		humanoidRootPart = false
	end

	local part2

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		part2 = nil
	else
		part2 = Instance.new("Part")
		part2.Name = "GearSoundOrigin"
		part2.Size = createVector(0.05, 0.05, 0.05)
		part2.Transparency = 1
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanTouch = false
		part2.CanQuery = false
		part2.CFrame = CFrame.new(position)
		part2.Parent = folder
		humanoidRootPart = part2
	end

	local sound2 = Instance.new("Sound")
	sound2.Name = "GearActionSound"
	sound2.SoundId = soundId
	sound2.Volume = 0.35
	sound2.RollOffMaxDistance = 100
	sound2.RollOffMinDistance = 7
	sound2.RollOffMode = Enum.RollOffMode.InverseTapered
	sound2.PlaybackSpeed = value or 1
	sound2.Parent = humanoidRootPart

	local function cleanup()
		sound2:Destroy()

		if part2 then
			part2:Destroy()
		end
	end

	sound2.Ended:Once(cleanup)

	if p then
		sound2.Played:Once(function()
			task.delay(0.35, function()
				if sound2.Parent then
					TweenService:Create(sound2, TweenInfo.new(0.2), {
						Volume = 0
					}):Play()
					task.delay(0.2, cleanup)
				end
			end)
		end)
	end

	sound2:Play()
	Debris:AddItem(part2 or sound2, 12)
end

local function attached(character, item, part2, identity, duration)
	if not part2 or not part2:IsA("BasePart") or #folder:GetChildren() >= 100 then
		return
	end

	local instance = chickenOrHero.Gear.Assets:FindFirstChild(item)

	if not (instance and (instance:IsA("Model") or instance:IsA("BasePart"))) then
		return
	end

	local v5 = v2[character]

	if v5 then
		v5:Destroy()
	end

	local model = Instance.new("Model")
	local clone = instance:Clone()
	clone.Parent = model

	for _, descendant in model:GetDescendants() do
		if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("JointInstance") or descendant:IsA("Constraint")) then
			continue
		end

		descendant:Destroy()
	end

	local gripPoint = clone:FindFirstChild("GripPoint", true)
	local v6 = part2.Name == "RightHand"
	local attribute = instance:GetAttribute(v6 and "HandGripR15" or "HandGripR6")

	if typeof(attribute) ~= "CFrame" then
		attribute = CFrame.new(0, -part2.Size.Y * (v6 and 0.35 or 0.5), 0) * identity
	end

	local pivot = model:GetPivot()
	local cframe = gripPoint and gripPoint:IsA("Attachment") and pivot:ToObjectSpace(gripPoint.WorldCFrame) or CFrame.identity
	model:PivotTo(part2.CFrame * attribute * cframe:Inverse())

	for _, part3 in model:GetDescendants() do
		if not part3:IsA("BasePart") then
			continue
		end

		part3.Anchored = false
		part3.Massless = true
		part3.CanCollide = false
		part3.CanQuery = false
		part3.CanTouch = false
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part2
		weldConstraint.Part1 = part3
		weldConstraint.Parent = part3
	end

	model.Parent = folder
	v2[character] = model
	Debris:AddItem(model, duration)
	local parent = item == "RufusLeash" and (clone:IsA("BasePart") and clone or clone:FindFirstChildWhichIsA(
		"BasePart",
		true
	))

	if parent then
		local attachment = Instance.new("Attachment")
		attachment.Position = createVector(-0.12, 0, 0)
		attachment.Parent = parent
		local attachment2 = Instance.new("Attachment")
		attachment2.Position = createVector(0.12, 0, 0)
		attachment2.Parent = parent
		local trail = Instance.new("Trail")
		trail.Attachment0 = attachment
		trail.Attachment1 = attachment2
		trail.Color = ColorSequence.new(color2)
		trail.Transparency = NumberSequence.new(0.15, 1)
		trail.Lifetime = 0.16
		trail.LightEmission = 0.8
		trail.FaceCamera = true
		trail.Parent = parent
	end

	task.delay(duration, function()
		if v2[character] == model then
			v2[character] = nil
		end
	end)
end

local function shoes(character)
	if typeof(character) ~= "Instance" then
		return
	end

	for _, v5 in { "Left", "Right" } do
		local part2 = character:FindFirstChild(v5 .. "Foot") or character:FindFirstChild(v5 .. " Leg")

		if not (part2 and part2:IsA("BasePart")) then
			continue
		end

		local v6 = part(part2.Position, color, createVector(0.65, 0.65, 1.4))

		if not v6 then
			continue
		end

		v6.Anchored = false
		v6.Massless = true
		v6.Material = Enum.Material.Metal
		v6.CFrame = part2.CFrame * CFrame.new(0, -part2.Size.Y * 0.35, 0.25)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part2
		weldConstraint.Part1 = v6
		weldConstraint.Parent = v6
		local pointLight = Instance.new("PointLight")
		pointLight.Color = color
		pointLight.Brightness = 2
		pointLight.Range = 5
		pointLight.Parent = v6
		TweenService:Create(v6, TweenInfo.new(0.6), {
			Transparency = 1
		}):Play()
	end
end

local function gesture(model, p)
	if typeof(model) ~= "Instance" or not (model:IsA("Model") and model.Parent) then
		return
	end

	local v5 = v[model]

	if v5 then
		v5.restore()
	end

	local v6 = {}
	v[model] = v6
	local v7 = {}

	for _, motor6D in model:GetDescendants() do
		if not motor6D:IsA("Motor6D") then
			continue
		end

		if not (motor6D.Name == "Right Shoulder" or motor6D.Name == "RightShoulder" or motor6D.Name == "Left Shoulder" or motor6D.Name == "LeftShoulder" or motor6D.Name == "RightElbow" or motor6D.Name == "LeftElbow" or motor6D.Name == "RightWrist") then
			continue
		end

		v7[motor6D] = {
			base = motor6D.C0,
			right = string.find(motor6D.Name, "Right") ~= nil
		}
	end

	function v6.restore()
		for k, v8 in v7 do
			if v8.tween then
				v8.tween:Cancel()
			end

			if k.Parent then
				k.C0 = v8.base
			end
		end

		if v[model] == v6 then
			v[model] = nil
		end
	end

	local function phase(duration, p2, p3, p4)
		if v[model] ~= v6 or not model.Parent then
			return false
		end

		for k, v8 in v7 do
			if not k.Parent then
				continue
			end

			local v9 = v8.right and p2 or p3
			local cframe = CFrame.Angles(math.rad(v9.X), math.rad(v9.Y), (math.rad(v9.Z)))

			if string.find(k.Name, "Elbow") then
				cframe = CFrame.Angles(math.rad(v9.X * 0.22), 0, 0)
			elseif string.find(k.Name, "Wrist") then
				cframe = CFrame.Angles(0, 0, (math.rad(v9.Z * 0.35)))
			end

			local C0 = v8.base * cframe

			if (p == "EmergencyAirhorn" or p == "RufusLeash" or p == "BananaPeel") and string.find(k.Name, "Shoulder") then
				local cframe2 = CFrame.Angles(math.rad(-v9.X), math.rad(v9.Y), (math.rad(v9.Z)))
				C0 = CFrame.new(v8.base.Position) * cframe2 * v8.base.Rotation
			end

			if v8.tween then
				v8.tween:Cancel()
			end

			v8.tween = TweenService:Create(
				k,
				TweenInfo.new(duration, p4 or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					C0 = C0
				}
			)
			v8.tween:Play()
		end

		task.wait(duration)
		return v[model] == v6
	end

	task.spawn(function()
		if p == "EmergencyAirhorn" then
			if not (phase(0.1, createVector(-92, -12, 16), createVector(-45, 12, -18), Enum.EasingStyle.Back) and phase(
				0.065,
				createVector(-77, -7, 24),
				createVector(-40, 9, -20)
			) and phase(0.075, createVector(-96, -12, 12), createVector(-46, 10, -16))) then
				return
			end
		elseif p == "RufusLeash" or p == "BananaPeel" then
			if not (phase(0.12, createVector(-125, 28, 32), createVector(-20, -12, -25), Enum.EasingStyle.Back) and phase(
				0.09,
				createVector(-78, -35, -16),
				createVector(15, 10, -20),
				Enum.EasingStyle.Quart
			)) then
				return
			end

			if not phase(0.14, createVector(-32, -22, -25), createVector(8, 5, -14)) then
				return
			end
		elseif phase(
			0.13,
			Vector3.new(p == "RocketShoes" and -35 or p == "BowlingBall" and 55 or -75, 0, 12),
			createVector(-20, 0, -12),
			Enum.EasingStyle.Back
		) then
			task.wait(0.1)
		else
			return
		end

		if phase(0.25, createVector(0, 0, 0), createVector(0, 0, 0), Enum.EasingStyle.Sine) then
			v6.restore()
		end
	end)
end

local function trail(character, color4, duration)
	if typeof(character) ~= "Instance" then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	for _, v5 in { -1, 1 } do
		local attachment = Instance.new("Attachment")
		attachment.Position = Vector3.new(v5 * 0.7, -1, 0)
		attachment.Parent = humanoidRootPart
		local attachment2 = Instance.new("Attachment")
		attachment2.Position = Vector3.new(v5 * 0.7, -0.5, 0)
		attachment2.Parent = humanoidRootPart
		local trail2 = Instance.new("Trail")
		trail2.Attachment0 = attachment
		trail2.Attachment1 = attachment2
		trail2.Color = ColorSequence.new(color4)
		trail2.Transparency = NumberSequence.new(0, 1)
		trail2.Lifetime = 0.25
		trail2.LightEmission = 1
		trail2.FaceCamera = true
		trail2.Parent = humanoidRootPart
		task.delay(duration, function()
			if trail2.Parent then
				trail2.Enabled = false
			end
		end)
		Debris:AddItem(attachment, duration + 0.3)
		Debris:AddItem(attachment2, duration + 0.3)
		Debris:AddItem(trail2, duration + 0.3)
	end
end

local function renderFX(data)
	if type(data) ~= "table" or typeof(data.position) ~= "Vector3" then
		return
	end

	if type(data.requestId) == "string" and (data.kind == "Airhorn" or data.kind == "Use") then
		local v5 = tostring(data.ownerId) .. ":" .. data.requestId .. ":" .. tostring(data.kind)

		if v3[v5] then
			return
		end

		v3[v5] = true
		task.delay(4, function()
			v3[v5] = nil
		end)
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera or (currentCamera.CFrame.Position - data.position).Magnitude > 120 then
		return
	end

	local position = data.position
	local kind = data.kind
	local sound2 = chickenOrHero.Gear.Assets:FindFirstChild(kind .. "Sound")
	local v7

	if kind == "Use" then
		v7 = data.item or "Use"
	else
		v7 = kind
	end

	local soundId = v4[v7] or sound2 and sound2:IsA("Sound") and sound2.SoundId
	local v10

	if kind == "Use" then
		v10 = data.item or "Use"
	else
		v10 = kind
	end

	sound(
		position,
		soundId,
		v4[v10] and 1 or sound2 and sound2:IsA("Sound") and sound2.PlaybackSpeed or 1,
		data.character,
		kind == "Airhorn"
	)

	if kind == "Use" then
		if data.item ~= "BigDagger" and data.item ~= "Cloak" then
			gesture(data.character, data.item)
		end

		if (data.item == "EmergencyAirhorn" or data.item == "RufusLeash") and typeof(data.character) == "Instance" then
			local rightHand = data.character:FindFirstChild("RightHand") or data.character:FindFirstChild("Right Arm")
			attached(data.character, data.item, rightHand, CFrame.identity, data.item == "RufusLeash" and 0.23 or 0.72)
		end
	elseif kind == "Airhorn" then
		airhornWave(position)
		burst(position, color, 16, 5)
	elseif kind == "Rocket" then
		shoes(data.character)
		trail(data.character, color, 0.55)
		burst(position - createVector(0, 1, 0), color, 16, 4)
	elseif kind == "DecoyInflate" then
		pulse(position, color3, 7)
		burst(position, color3, 12, 4)
	elseif kind == "DecoyPop" then
		burst(position, color3, 20, 6)
		pulse(position, color3, 5)
	elseif kind == "DoorSlam" or kind == "DoorHit" then
		burst(position - createVector(0, 2, 0), color, kind == "DoorSlam" and 16 or 8, 4)
	elseif kind == "DoorBreak" then
		burst(position, color, 22, 6)
		pulse(position, color, 6)
	elseif kind == "DoorFade" then
		burst(position, color2, 8, 3)
	elseif kind == "BowlingHit" or kind == "Impact" then
		pulse(position, color, 5)
		burst(position, color, 14, 4)
	elseif kind == "LeashHit" then
		pulse(position, color2, GearCatalog.Items.RufusLeash.HitRadius * 2)
		burst(position, color2, 10, 3)
		trail(data.character, color2, 0.3)
	elseif kind == "LeashThrow" then
		burst(position, color2, 6, 2)
	elseif kind == "BananaThrow" then
		gesture(data.character, "BananaPeel")
		burst(position, color, 7, 2)
	elseif kind == "BananaSlip" then
		pulse(position - createVector(0, 2, 0), color, 4)
		burst(position - createVector(0, 1, 0), color, 12, 3)
		trail(data.character, color, 0.65)

		for i = 1, 6 do
			local v11 = i * 3.141592653589793 / 3
			local v12 = part(
				position + Vector3.new(math.cos(v11), 1.4, (math.sin(v11))),
				color,
				createVector(0.2, 0.2, 0.2)
			)

			if not v12 then
				continue
			end

			v12.Shape = Enum.PartType.Ball
			TweenService:Create(v12, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
				Position = position + Vector3.new(math.cos(v11 + 1.7) * 1.8, 2.3, math.sin(v11 + 1.7) * 1.8),
				Transparency = 1,
				Size = createVector(0.04, 0.04, 0.04)
			}):Play()
		end
	elseif kind == "Rescue" then
		pulse(position, Color3.fromRGB(122, 255, 169), 7)
		burst(position, color2, 16, 4)
	elseif kind == "Adrenaline" then
		pulse(position, color2, 6)
		trail(data.character, color2, 1)
	end
end

local onClientEventConnection = gearEvent.OnClientEvent:Connect(function(p, p2)
	if p == "FX" and not GearPredictionClient.consumeFX(p2) then
		renderFX(p2)
	end
end)
local eventConnection = GearPredictionClient.FX.Event:Connect(renderFX)
local eventConnection2 = GearPredictionClient.Cancel.Event:Connect(function(p)
	local character = p.character
	local v5 = character and v[character]

	if v5 then
		v5.restore()
	end

	local v6 = character and v2[character]

	if v6 then
		v6:Destroy()
		v2[character] = nil
	end
end)
script.Destroying:Connect(function()
	onClientEventConnection:Disconnect()
	eventConnection:Disconnect()
	eventConnection2:Disconnect()

	for _, v5 in v do
		v5.restore()
	end

	folder:Destroy()
end)