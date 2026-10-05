local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local assets = require(ReplicatedStorage.shared.utils.assets)
local localPlayer = Players.LocalPlayer
local snowballThrow = ReplicatedStorage.events.SnowballThrow
local _ = {
	THROW_POWER = 100,
	LIFETIME = 5,
	HIT_SOUND = "rbxassetid://9119310655",
	THROW_SOUND = "rbxassetid://80281677741848",
	SHINY_HIT_SOUND = "rbxassetid://130409200540693",
	SHINY_THROW_SOUND = "rbxassetid://118560571946803",
	COOLDOWN = 2,
	MIN_THROW_ANGLE = 0
}
local Snowball = {}
local v = nil
local activatedConnection = nil
local v2 = {}
local v3 = {
	hit = Instance.new("Sound"),
	throw = Instance.new("Sound"),
	shinyHit = Instance.new("Sound"),
	shinyThrow = Instance.new("Sound")
}
v3.hit.SoundId = "rbxassetid://9119310655"
v3.throw.SoundId = "rbxassetid://80281677741848"
v3.shinyHit.SoundId = "rbxassetid://130409200540693"
v3.shinyThrow.SoundId = "rbxassetid://118560571946803"
task.spawn(function()
	ContentProvider:PreloadAsync({
		v3.hit,
		v3.throw,
		v3.shinyHit,
		v3.shinyThrow
	})
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

-- equivalent calls inferred from this helper; original call sites unknown
local function getSnowballTemplate(flag: boolean)
	local async = assets.getAsync("fish", flag and "Shiny_Snowball" or "Snowball")

	if not async then
		return nil
	end

	if flag then
		return (async:FindFirstChild("Cube"))
	end

	local fish = async:FindFirstChild("Fish")

	if fish then
		return (fish:FindFirstChild("Sphere"))
	end

	return nil
end

local function createSnowball(position: Vector3, unit: Vector3, folder, isShiny: boolean)
	local v5 = nil
	local clone = nil

	if isShiny then
		local async = assets.getAsync("fish", "Shiny_Snowball")

		if async then
			local fish = async:FindFirstChild("Fish")
			local cube = fish and fish:FindFirstChild("Cube")
			local frozenpart = fish and fish:FindFirstChild("frozenpart")

			if cube then
				local v6

				if frozenpart then
					v6 = cube.CFrame:ToObjectSpace(frozenpart.CFrame) or nil
				end

				v5 = cube:Clone()
				v5.Name = "ClientSnowball"
				v5.CanCollide = false
				v5.CastShadow = true
				v5.Anchored = false
				v5.Massless = true

				if frozenpart and v6 then
					clone = frozenpart:Clone()
					clone.Name = "FrozenPart"
					clone.CanCollide = false
					clone.CastShadow = true
					clone.Anchored = false
					clone.Massless = true
					clone.CFrame = CFrame.new(position) * v6
					clone.Parent = workspace
					local weldConstraint = Instance.new("WeldConstraint")
					weldConstraint.Part0 = v5
					weldConstraint.Part1 = clone
					weldConstraint.Parent = v5
				end
			end
		end

		if not v5 then
			v5 = Instance.new("Part")
			v5.Name = "ClientSnowball"
			v5.Size = createVector(0.8, 0.8, 0.8)
			v5.Material = Enum.Material.Concrete
			v5.Color = Color3.fromRGB(138, 70, 70)
			v5.CanCollide = false
			v5.CastShadow = true
			v5.Anchored = false
			v5.Massless = true
		end
	else
		local snowballTemplate = getSnowballTemplate(false) -- equivalent call inferred; original call site unknown

		if snowballTemplate then
			v5 = snowballTemplate:Clone()
			v5.Name = "ClientSnowball"
		else
			v5 = Instance.new("Part")
			v5.Name = "ClientSnowball"
			v5.Size = createVector(1, 1, 1)
			v5.Shape = Enum.PartType.Ball
			v5.Material = Enum.Material.SmoothPlastic
			v5.Color = Color3.fromRGB(255, 255, 255)
		end

		v5.CanCollide = false
		v5.CastShadow = true
		v5.Anchored = false
		v5.Massless = true
	end

	v5.CFrame = CFrame.new(position)
	v5.Parent = workspace

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local noCollisionConstraint = Instance.new("NoCollisionConstraint")
		noCollisionConstraint.Part0 = v5
		noCollisionConstraint.Part1 = part
		noCollisionConstraint.Parent = v5

		if not clone then
			continue
		end

		local noCollisionConstraint2 = Instance.new("NoCollisionConstraint")
		noCollisionConstraint2.Part0 = clone
		noCollisionConstraint2.Part1 = part
		noCollisionConstraint2.Parent = clone
	end

	v5.AssemblyLinearVelocity = unit * 100
	task.delay(0.05, function()
		if v5 and v5.Parent then
			v5.CanCollide = true
		end
	end)
	local flag = false
	local touchedConnection = nil
	touchedConnection = v5.Touched:Connect(function(otherPart)
		if flag or not isValidHit(otherPart, folder) then
			return
		end

		flag = true
		touchedConnection:Disconnect()
		local humanoid = otherPart.Parent:FindFirstChildOfClass("Humanoid") or otherPart.Parent.Parent and otherPart.Parent.Parent:FindFirstChildOfClass("Humanoid")
		local position2 = v5.Position
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { v5, folder }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local raycastResult = workspace:Raycast(v5.Position, unit * 2, raycastParams)

		if raycastResult then
			position2 = raycastResult.Position
		end

		v5.Anchored = true
		v5.Transparency = 1

		if clone then
			clone.Anchored = true
			clone.Transparency = 1
		end

		local clone2 = v3[isShiny and "shinyHit" or "hit"]:Clone()
		clone2.Volume = 0.5
		SoundService:PlayLocalSound(clone2)
		Debris:AddItem(clone2, 3)

		if not humanoid then
			if isShiny then
				for _ = 1, 5 do
					local part = Instance.new("Part")
					part.Name = "IceShard"
					part.Size = Vector3.new(math.random(2, 4) / 10, math.random(3, 6) / 10, math.random(2, 4) / 10)
					part.Material = Enum.Material.Ice
					part.Color = Color3.fromRGB(180, 220, 240)
					part.Transparency = 0.3
					part.Anchored = false
					part.CanCollide = true
					part.CFrame = CFrame.new(position2) * CFrame.Angles(
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2
					)
					part.Parent = workspace
					part.AssemblyLinearVelocity = Vector3.new(
						math.random() - 0.5,
						math.random() * 0.5 + 0.2,
						math.random() - 0.5
					).Unit * math.random(10, 25)
					Debris:AddItem(part, 1.5)
				end
			else
				local part = Instance.new("Part")
				part.Name = "SnowImpact"
				part.Size = createVector(1.5, 0.1, 1.5)
				part.Material = Enum.Material.SmoothPlastic
				part.Color = Color3.fromRGB(255, 255, 255)
				part.Transparency = 0.3
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = CFrame.new(position2)
				part.Parent = workspace
				Debris:AddItem(part, 1)
			end
		end

		if clone then
			Debris:AddItem(clone, 0.5)
		end

		Debris:AddItem(v5, 0.5)
	end)

	if clone then
		Debris:AddItem(clone, 5)
	end

	Debris:AddItem(v5, 5)
	task.delay(5, function()
		if touchedConnection and touchedConnection.Connected then
			touchedConnection:Disconnect()
		end
	end)
end

local function onActivated()
	if not (v and v.Parent) then
		return
	end

	local now = tick()

	if now - v4 < 2 then
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

	local isShiny = v:GetAttribute("isShiny") or false
	v4 = now
	local clone = v3[isShiny and "shinyThrow" or "throw"]:Clone()
	clone.Volume = 0.5
	SoundService:PlayLocalSound(clone)
	Debris:AddItem(clone, 2)
	createSnowball(v5, unit, character, isShiny)
	snowballThrow:FireServer(position)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onToolEquipped(p)
	if p.Name ~= "Snowball" then
		return
	end

	cleanup() -- equivalent call inferred; original call site unknown
	v = p
	activatedConnection = p.Activated:Connect(onActivated)
end

local function onToolUnequipped(p)
	if p.Name ~= "Snowball" then
		return
	end

	cleanup() -- equivalent call inferred; original call site unknown
end

local function setupToolListeners(tool)
	if tool.Name ~= "Snowball" then
		return
	end

	local equippedConnection = tool.Equipped:Connect(function()
		onToolEquipped(tool) -- equivalent call inferred; original call site unknown
	end)
	local unequippedConnection = tool.Unequipped:Connect(function()
		if tool.Name ~= "Snowball" then
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
		if tool:IsA("Tool") and tool.Name == "Snowball" then
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

function Snowball.init()
	setupBackpackListener()

	if localPlayer.Character then
		onCharacterAdded(localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(onCharacterAdded)
end

return Snowball