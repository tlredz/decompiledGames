local createVector = vector.create
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local v = {
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftLowerArm",
	"RightLowerArm"
}
local tweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local v2 = {
	LowerTorso = 0,
	UpperTorso = 0,
	LeftUpperArm = 1,
	RightUpperArm = 1,
	LeftLowerArm = 2,
	RightLowerArm = 2
}

local function randomBetween(p: number, p2: number)
	return p + math.random() * (p2 - p)
end

local function isJunk(descendant)
	return descendant:IsA("BaseScript") or descendant:IsA("Sound") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Light") or descendant:IsA("Accessory") or descendant:IsA("Tool") or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui")
end

local function hide(folder)
	folder.Transparency = 1

	for _, decal in ipairs(folder:GetDescendants()) do
		if decal:IsA("Decal") then
			decal.Transparency = 1
		end
	end
end

local function burstMuscle(instance)
	local powerUpMuscle = instance:WaitForChild("PowerUpMuscle", 2)

	if not powerUpMuscle then
		return
	end

	for _, part in ipairs(powerUpMuscle:GetChildren()) do
		local fullSize = part:GetAttribute("FullSize")

		if not (part:IsA("BasePart") and typeof(fullSize) == "Vector3") then
			continue
		end

		local v3 = part
		local size = fullSize
		task.delay((v2[part.Name] or 0) * 0.04, function()
			if v3.Parent then
				TweenService:Create(v3, tweenInfo, {
					Size = size
				}):Play()
			end
		end)
	end
end

return function(player)
	local character = player.Character

	if not (character and character:IsA("Model")) then
		return
	end

	Effect.new("Spring.SpringCannon"):replicate({
		Character = character
	})
	task.spawn(burstMuscle, character)
	local clone = character:Clone()
	clone.Name = "ShirtRip"
	local powerUpMuscle = clone:FindFirstChild("PowerUpMuscle")

	if powerUpMuscle then
		powerUpMuscle:Destroy()
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if isJunk(descendant) then
			descendant:Destroy()
		end
	end

	for _, child in ipairs(clone:GetChildren()) do
		if child:IsA("Shirt") or child:IsA("ShirtGraphic") then
			child:Destroy()
		end
	end

	if player.ShirtTemplate and player.ShirtTemplate ~= "" then
		local shirt = Instance.new("Shirt")
		shirt.ShirtTemplate = player.ShirtTemplate
		shirt.Parent = clone
	end

	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.EvaluateStateMachine = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	local v3 = {}

	for _, v4 in ipairs(v) do
		v3[v4] = true
	end

	local parts = {}

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		table.insert(parts, part)

		if not v3[part.Name] then
			hide(part)
		end
	end

	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("UpperTorso")
	local position

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		position = humanoidRootPart.Position
	end

	local v4 = {}

	for i, childName in ipairs(v) do
		local part = clone:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		local v5 = part.Position - (position or part.Position)
		local vector2 = Vector3.new(v5.X, 0, v5.Z)
		local vector3

		if vector2.Magnitude < 0.1 then
			local v6 = math.random() * 3.141592653589793 * 2
			vector3 = Vector3.new(math.cos(v6), 0, (math.sin(v6)))
		else
			vector3 = vector2.Unit
		end

		local unit = (vector3 + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * 0.4).Unit
		local vector4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
		local axis = vector4.Magnitude < 0.01 and createVector(1, 0, 0) or vector4.Unit
		table.insert(v4, {
			part = part,
			size = part.Size,
			pos = part.Position,
			rot = part.CFrame.Rotation,
			vel = unit * (8 + math.random() * 6) + Vector3.new(0, 26 + math.random() * 8, 0),
			axis = axis,
			spin = 7 + math.random() * 8,
			startAt = (i - 1) * 0.03 + math.random() * 0.02,
			done = false
		})
	end

	if #v4 == 0 then
		clone:Destroy()
		return
	end

	clone.Parent = Workspace
	local total = 0
	local count = #v4
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if clone.Parent == nil then
			heartbeatConnection:Disconnect()
			return
		end

		total += dt

		for _, v5 in ipairs(parts) do
			if v5.CanCollide then
				v5.CanCollide = false
			end
		end

		for _, v5 in ipairs(v4) do
			if v5.done then
				continue
			end

			local v6 = total - v5.startAt

			if v6 <= 0 then
				continue
			end

			if v6 >= 1.3 then
				v5.done = true
				count -= 1
				hide(v5.part)
			else
				v5.vel += createVector(0, -60, 0) * dt
				v5.vel *= math.max(0, 1 - 1.2 * dt)
				v5.pos += v5.vel * dt
				v5.rot = CFrame.fromAxisAngle(v5.axis, v5.spin * dt) * v5.rot
				local v7 = math.clamp((v6 - 0.8) / 0.5, 0, 1)

				if v7 > 0 then
					v5.part.Size = v5.size:Lerp(v5.size * 0.05, v7)
					v5.part.Transparency = math.clamp((v7 - 0.75) / 0.25, 0, 1)
				end

				v5.part.CFrame = CFrame.new(v5.pos) * v5.rot
			end
		end

		if count <= 0 then
			heartbeatConnection:Disconnect()
			clone:Destroy()
		end
	end)
	Debris:AddItem(clone, #v * 0.03 + 1.3 + 0.5)
end