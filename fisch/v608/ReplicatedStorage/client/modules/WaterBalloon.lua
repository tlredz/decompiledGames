local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local localPlayer = Players.LocalPlayer
local waterBalloonThrow = ReplicatedStorage.events.WaterBalloonThrow
local _ = {
	THROW_POWER = 100,
	LIFETIME = 5,
	HIT_SOUND = "rbxassetid://9117940939",
	THROW_SOUND = "rbxassetid://80281677741848",
	COOLDOWN = 1.3,
	MIN_THROW_ANGLE = 0
}
local WaterBalloon = {}
local v = nil
local activatedConnection = nil
local v2 = {}
local v3 = {
	hit = Instance.new("Sound"),
	throw = Instance.new("Sound")
}
v3.hit.SoundId = "rbxassetid://9117940939"
v3.throw.SoundId = "rbxassetid://80281677741848"
task.spawn(function()
	local ContentProvider = game:GetService("ContentProvider")
	ContentProvider:PreloadAsync({ v3.hit, v3.throw })
end)
local v4 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanup()
	if activatedConnection then
		activatedConnection:Disconnect()
		activatedConnection = nil
	end

	v = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupCharacterConnections()
	for _, connection in v2 do
		connection:Disconnect()
	end

	table.clear(v2)
end

local function isValidHit(part, folder)
	if not (part and part:IsA("BasePart")) or part:IsDescendantOf(folder) or part.Transparency >= 1 then
		return false
	end

	if part.CanCollide == false then
		return false
	end

	local zones = workspace:FindFirstChild("zones")
	return not (zones and part:IsDescendantOf(zones))
end

local function createSplashEffect(position: Vector3)
	local part = Instance.new("Part")
	part.Name = "WaterSplash"
	part.Size = createVector(1.5, 1.5, 1.5)
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(100, 200, 255)
	part.Transparency = 0.4
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://15057892718"
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(99, 174, 255))
	particleEmitter.Size = NumberSequence.new(0.8, 0.3)
	particleEmitter.Rate = 150
	particleEmitter.Lifetime = NumberRange.new(0.4)
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.VelocityInheritance = 0
	particleEmitter.Speed = NumberRange.new(8, 18)
	particleEmitter.Drag = 1.5
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
	particleEmitter.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	particleEmitter.FlipbookBlendFrames = true
	particleEmitter.Transparency = NumberSequence.new(0.6, 0.5)
	particleEmitter.Enabled = true
	particleEmitter.Parent = part
	task.delay(0.01, function()
		part.Transparency = 1
	end)
	task.delay(0.1, function()
		particleEmitter.Enabled = false
	end)
	Debris:AddItem(part, 1)
end

local function createWaterBalloon(position: Vector3, unit: Vector3, folder)
	local part = Instance.new("Part")
	part.Name = "ClientWaterBalloon"
	part.Size = createVector(1, 1, 1)
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(30, 144, 255)
	part.CanCollide = true
	part.CastShadow = true
	part.Anchored = false
	part.Massless = true
	part.CFrame = CFrame.new(position)
	part.Parent = workspace

	for _, part2 in folder:GetDescendants() do
		if not part2:IsA("BasePart") then
			continue
		end

		local noCollisionConstraint = Instance.new("NoCollisionConstraint")
		noCollisionConstraint.Part0 = part
		noCollisionConstraint.Part1 = part2
		noCollisionConstraint.Parent = part
	end

	part.AssemblyLinearVelocity = unit * 100
	local flag = false
	local touchedConnection = nil
	touchedConnection = part.Touched:Connect(function(otherPart)
		if flag or not isValidHit(otherPart, folder) then
			return
		end

		flag = true
		touchedConnection:Disconnect()
		local position2 = part.Position
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { part, folder }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local raycastResult = workspace:Raycast(part.Position, unit * 2, raycastParams)

		if raycastResult then
			position2 = raycastResult.Position
		end

		createSplashEffect(position2)
		local clone = v3.hit:Clone()
		clone.Volume = 0.5
		SoundService:PlayLocalSound(clone)
		Debris:AddItem(clone, 2)
		part:Destroy()
	end)
	task.delay(5, function()
		if touchedConnection and touchedConnection.Connected then
			touchedConnection:Disconnect()
		end

		if part and part.Parent then
			part:Destroy()
		end
	end)
end

local function onActivated()
	if not (v and v.Parent) then
		return
	end

	local now = tick()

	if now - v4 < 1.3 then
		return
	end

	local character = localPlayer.Character

	if not character or v.Parent ~= character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
	local position = localPlayer:GetMouse().Hit.Position
	local v5 = (rightArm or humanoidRootPart).Position + createVector(0, 1, 0)
	local unit = (position - v5).Unit

	if unit.Y < 0 then
		unit = Vector3.new(unit.X, 0, unit.Z).Unit
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local raycastResult = workspace:Raycast(v5, createVector(0, -3, 0), raycastParams)

	if raycastResult then
		v5 = raycastResult.Position + createVector(0, 1, 0)
	end

	v4 = now
	local clone = v3.throw:Clone()
	clone.Volume = 0.5
	SoundService:PlayLocalSound(clone)
	Debris:AddItem(clone, 2)
	createWaterBalloon(v5, unit, character)
	waterBalloonThrow:FireServer(position)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onToolEquipped(p)
	if p.Name ~= "Water Balloon" then
		return
	end

	cleanup() -- equivalent call inferred; original call site unknown
	v = p
	activatedConnection = p.Activated:Connect(onActivated)
end

local function onToolUnequipped(p)
	if p.Name ~= "Water Balloon" then
		return
	end

	cleanup() -- equivalent call inferred; original call site unknown
end

local function setupToolListeners(tool)
	if tool.Name ~= "Water Balloon" then
		return
	end

	local equippedConnection = tool.Equipped:Connect(function()
		onToolEquipped(tool) -- equivalent call inferred; original call site unknown
	end)
	local unequippedConnection = tool.Unequipped:Connect(function()
		if tool.Name ~= "Water Balloon" then
			return
		end

		cleanup() -- equivalent call inferred; original call site unknown
	end)
	table.insert(v2, equippedConnection)
	table.insert(v2, unequippedConnection)

	if tool.Parent and tool.Parent:FindFirstChildOfClass("Humanoid") then
		onToolEquipped(tool) -- equivalent call inferred; original call site unknown
	end
end

local function onCharacterAdded(character)
	cleanupCharacterConnections() -- equivalent call inferred; original call site unknown
	cleanup() -- equivalent call inferred; original call site unknown
	local childAddedConnection = character.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			setupToolListeners(tool)
		end
	end)
	local childRemovedConnection = character.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") and tool.Name == "Water Balloon" then
			cleanup() -- equivalent call inferred; original call site unknown
		end
	end)
	table.insert(v2, childAddedConnection)
	table.insert(v2, childRemovedConnection)

	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") then
			setupToolListeners(tool)
		end
	end
end

local function setupBackpackListener()
	local backpack = localPlayer:WaitForChild("Backpack")
	backpack.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			setupToolListeners(tool)
		end
	end)

	for _, tool in backpack:GetChildren() do
		if tool:IsA("Tool") then
			setupToolListeners(tool)
		end
	end
end

function WaterBalloon.init()
	setupBackpackListener()

	if localPlayer.Character then
		onCharacterAdded(localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(onCharacterAdded)
end

return WaterBalloon