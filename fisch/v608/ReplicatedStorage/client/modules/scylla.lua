local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.packages.Observers)
local Signal = require(ReplicatedStorage.packages.Signal)
require(ReplicatedStorage.packages.Timer)
local Trove = require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.client.ui.state)
local HydraAttack = require(script.vfx.Abilities.HydraAttack)
local attacks = ReplicatedStorage.resources.animations.attacks
local localPlayer = Players.LocalPlayer
local scyllaDamageEvent = ReplicatedStorage.events.scyllaDamageEvent
local scyllaSetTarget = ReplicatedStorage.events.scyllaSetTarget
local setFightState = ReplicatedStorage.events.setFightState
local scyllaAttack = ReplicatedStorage.events.scyllaAttack
local scylla = ReplicatedStorage.world.scylla
local playerGui = localPlayer:WaitForChild("PlayerGui", 1e999)
local scylla2 = ReplicatedStorage.resources.sounds.sfx.scylla
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://85225164238595"
sound.Looped = true
sound.Parent = playerGui
require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local maid = Trove.new()
local v = nil
local v2 = Signal.new()
local v3 = Signal.new()
local v4 = Signal.new()
local v5 = {
	Bow = "Crossbow Bow",
	Arrow = "Crossbow Arrow",
	Base = "Crossbow Base"
}
local v6 = {
	["Crossbow Base"] = scylla.scylla_firstPart,
	["Crossbow Bow"] = scylla.scylla_secondPart,
	["Crossbow Arrow"] = scylla.scylla_thirdPart
}
local parent = nil
local v7 = nil

local function fLerp(p, p2, p3: number, p4: number)
	return p2 + (p - p2) * math.exp(-p3 * p4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasItem(p: string)
	return DataController.HasItem(p, nil, true)
end

local function getHitCallback(p: string)
	return function(position: Vector3)
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		assert(humanoidRootPart:IsA("BasePart"), "Luau")
		local part = Instance.new("Part")
		part.Name = "Part"
		part.Anchored = true
		part.CFrame = CFrame.new(position)
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Color = Color3.fromRGB(255, 0, 0)
		part.Massless = true
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(46, 46, 46)
		part.Transparency = 1

		if p == "allAttack" then
			local clone = scylla2.lightning_impact:Clone()
			local clone2 = scylla2.ice_impact:Clone()
			local clone3 = scylla2.plasma_impact:Clone()
			local clone4 = scylla2.fireball_impact:Clone()
			clone.Parent = part
			clone2.Parent = part
			clone3.Parent = part
			clone4.Parent = part
			clone:Play()
			clone2:Play()
			clone3:Play()
			clone4:Play()
		else
			local clone = nil

			if p == "thunderAttack" then
				clone = scylla2.lightning_impact:Clone()
			elseif p == "iceAttack" then
				clone = scylla2.ice_impact:Clone()
			elseif p == "plasmaAttack" then
				clone = scylla2.plasma_impact:Clone()
			elseif p == "fireAttack" then
				clone = scylla2.fireball_impact:Clone()
			end

			clone.Parent = part
			clone:Play()
		end

		part.Parent = workspace.VFXDebris
		task.delay(6, function()
			part:Destroy()
		end)

		if vector.magnitude(position - humanoidRootPart.Position) <= 23 then
			scyllaDamageEvent:FireServer(p == "All" and 12.5 or nil)
		end
	end
end

local function getCharacterToAttackPlacement(instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function getPlayerPosition()
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return instance:GetPivot().Position
		end

		assert(humanoidRootPart:IsA("BasePart"), "Luau")
		return humanoidRootPart.Position
	end

	return function()
		local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { instance }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local raycastResult = workspace:Raycast(playerPosition, createVector(-0, -15, -0), raycastParams)

		if raycastResult then
			return raycastResult.Position
		end

		return playerPosition
	end
end

local v8 = {
	iceAttack = function(p: number, instance)
		if v7 then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function getPlayerPosition()
				local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return instance:GetPivot().Position
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				return humanoidRootPart.Position
			end

			local v9 = "iceAttack"
			v7.vfx:playIceBall(p, function()
				local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { instance }
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(playerPosition, createVector(-0, -15, -0), raycastParams)

				if raycastResult then
					return raycastResult.Position
				end

				return playerPosition
			end, v7.animations.blue, function(position: Vector3)
				local character = localPlayer.Character

				if not character then
					return
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				local part = Instance.new("Part")
				part.Name = "Part"
				part.Anchored = true
				part.CFrame = CFrame.new(position)
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				part.Color = Color3.fromRGB(255, 0, 0)
				part.Massless = true
				part.Shape = Enum.PartType.Ball
				part.Size = createVector(46, 46, 46)
				part.Transparency = 1

				if v9 == "allAttack" then
					local clone = scylla2.lightning_impact:Clone()
					local clone2 = scylla2.ice_impact:Clone()
					local clone3 = scylla2.plasma_impact:Clone()
					local clone4 = scylla2.fireball_impact:Clone()
					clone.Parent = part
					clone2.Parent = part
					clone3.Parent = part
					clone4.Parent = part
					clone:Play()
					clone2:Play()
					clone3:Play()
					clone4:Play()
				else
					local clone = nil

					if v9 == "thunderAttack" then
						clone = scylla2.lightning_impact:Clone()
					elseif v9 == "iceAttack" then
						clone = scylla2.ice_impact:Clone()
					elseif v9 == "plasmaAttack" then
						clone = scylla2.plasma_impact:Clone()
					elseif v9 == "fireAttack" then
						clone = scylla2.fireball_impact:Clone()
					end

					clone.Parent = part
					clone:Play()
				end

				part.Parent = workspace.VFXDebris
				task.delay(6, function()
					part:Destroy()
				end)

				if vector.magnitude(position - humanoidRootPart.Position) <= 23 then
					scyllaDamageEvent:FireServer(v9 == "All" and 12.5 or nil)
				end
			end)
		end
	end,
	fireAttack = function(p: number, instance)
		if v7 then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function getPlayerPosition()
				local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return instance:GetPivot().Position
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				return humanoidRootPart.Position
			end

			local v9 = "fireAttack"
			v7.vfx:playFireBall(p, function()
				local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { instance }
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(playerPosition, createVector(-0, -15, -0), raycastParams)

				if raycastResult then
					return raycastResult.Position
				end

				return playerPosition
			end, v7.animations.red, function(position: Vector3)
				local character = localPlayer.Character

				if not character then
					return
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				local part = Instance.new("Part")
				part.Name = "Part"
				part.Anchored = true
				part.CFrame = CFrame.new(position)
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				part.Color = Color3.fromRGB(255, 0, 0)
				part.Massless = true
				part.Shape = Enum.PartType.Ball
				part.Size = createVector(46, 46, 46)
				part.Transparency = 1

				if v9 == "allAttack" then
					local clone = scylla2.lightning_impact:Clone()
					local clone2 = scylla2.ice_impact:Clone()
					local clone3 = scylla2.plasma_impact:Clone()
					local clone4 = scylla2.fireball_impact:Clone()
					clone.Parent = part
					clone2.Parent = part
					clone3.Parent = part
					clone4.Parent = part
					clone:Play()
					clone2:Play()
					clone3:Play()
					clone4:Play()
				else
					local clone = nil

					if v9 == "thunderAttack" then
						clone = scylla2.lightning_impact:Clone()
					elseif v9 == "iceAttack" then
						clone = scylla2.ice_impact:Clone()
					elseif v9 == "plasmaAttack" then
						clone = scylla2.plasma_impact:Clone()
					elseif v9 == "fireAttack" then
						clone = scylla2.fireball_impact:Clone()
					end

					clone.Parent = part
					clone:Play()
				end

				part.Parent = workspace.VFXDebris
				task.delay(6, function()
					part:Destroy()
				end)

				if vector.magnitude(position - humanoidRootPart.Position) <= 23 then
					scyllaDamageEvent:FireServer(v9 == "All" and 12.5 or nil)
				end
			end)
		end
	end,
	thunderAttack = function(p: number, instance)
		if v7 then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function getPlayerPosition()
				local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return instance:GetPivot().Position
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				return humanoidRootPart.Position
			end

			local v9 = "thunderAttack"
			v7.vfx:playThunderBall(p, function()
				local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { instance }
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(playerPosition, createVector(-0, -15, -0), raycastParams)

				if raycastResult then
					return raycastResult.Position
				end

				return playerPosition
			end, v7.animations.yellow, function(position: Vector3)
				local character = localPlayer.Character

				if not character then
					return
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				local part = Instance.new("Part")
				part.Name = "Part"
				part.Anchored = true
				part.CFrame = CFrame.new(position)
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				part.Color = Color3.fromRGB(255, 0, 0)
				part.Massless = true
				part.Shape = Enum.PartType.Ball
				part.Size = createVector(46, 46, 46)
				part.Transparency = 1

				if v9 == "allAttack" then
					local clone = scylla2.lightning_impact:Clone()
					local clone2 = scylla2.ice_impact:Clone()
					local clone3 = scylla2.plasma_impact:Clone()
					local clone4 = scylla2.fireball_impact:Clone()
					clone.Parent = part
					clone2.Parent = part
					clone3.Parent = part
					clone4.Parent = part
					clone:Play()
					clone2:Play()
					clone3:Play()
					clone4:Play()
				else
					local clone = nil

					if v9 == "thunderAttack" then
						clone = scylla2.lightning_impact:Clone()
					elseif v9 == "iceAttack" then
						clone = scylla2.ice_impact:Clone()
					elseif v9 == "plasmaAttack" then
						clone = scylla2.plasma_impact:Clone()
					elseif v9 == "fireAttack" then
						clone = scylla2.fireball_impact:Clone()
					end

					clone.Parent = part
					clone:Play()
				end

				part.Parent = workspace.VFXDebris
				task.delay(6, function()
					part:Destroy()
				end)

				if vector.magnitude(position - humanoidRootPart.Position) <= 23 then
					scyllaDamageEvent:FireServer(v9 == "All" and 12.5 or nil)
				end
			end)
		end
	end,
	plasmaAttack = function(p: number, instance)
		if v7 then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function getPlayerPosition()
				local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return instance:GetPivot().Position
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				return humanoidRootPart.Position
			end

			local v9 = "plasmaAttack"
			v7.vfx:playPlasmaBall(p, function()
				local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { instance }
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(playerPosition, createVector(-0, -15, -0), raycastParams)

				if raycastResult then
					return raycastResult.Position
				end

				return playerPosition
			end, v7.animations.purple, function(position: Vector3)
				local character = localPlayer.Character

				if not character then
					return
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				local part = Instance.new("Part")
				part.Name = "Part"
				part.Anchored = true
				part.CFrame = CFrame.new(position)
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				part.Color = Color3.fromRGB(255, 0, 0)
				part.Massless = true
				part.Shape = Enum.PartType.Ball
				part.Size = createVector(46, 46, 46)
				part.Transparency = 1

				if v9 == "allAttack" then
					local clone = scylla2.lightning_impact:Clone()
					local clone2 = scylla2.ice_impact:Clone()
					local clone3 = scylla2.plasma_impact:Clone()
					local clone4 = scylla2.fireball_impact:Clone()
					clone.Parent = part
					clone2.Parent = part
					clone3.Parent = part
					clone4.Parent = part
					clone:Play()
					clone2:Play()
					clone3:Play()
					clone4:Play()
				else
					local clone = nil

					if v9 == "thunderAttack" then
						clone = scylla2.lightning_impact:Clone()
					elseif v9 == "iceAttack" then
						clone = scylla2.ice_impact:Clone()
					elseif v9 == "plasmaAttack" then
						clone = scylla2.plasma_impact:Clone()
					elseif v9 == "fireAttack" then
						clone = scylla2.fireball_impact:Clone()
					end

					clone.Parent = part
					clone:Play()
				end

				part.Parent = workspace.VFXDebris
				task.delay(6, function()
					part:Destroy()
				end)

				if vector.magnitude(position - humanoidRootPart.Position) <= 23 then
					scyllaDamageEvent:FireServer(v9 == "All" and 12.5 or nil)
				end
			end)
		end
	end,
	allAttack = function(p: number, instance)
		if v7 then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function getPlayerPosition()
				local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return instance:GetPivot().Position
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				return humanoidRootPart.Position
			end

			local v9 = "allAttack"
			v7.vfx:playAll(p, function()
				local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { instance }
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(playerPosition, createVector(-0, -15, -0), raycastParams)

				if raycastResult then
					return raycastResult.Position
				end

				return playerPosition
			end, v7.animations.all, function(position: Vector3)
				local character = localPlayer.Character

				if not character then
					return
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				assert(humanoidRootPart:IsA("BasePart"), "Luau")
				local part = Instance.new("Part")
				part.Name = "Part"
				part.Anchored = true
				part.CFrame = CFrame.new(position)
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				part.Color = Color3.fromRGB(255, 0, 0)
				part.Massless = true
				part.Shape = Enum.PartType.Ball
				part.Size = createVector(46, 46, 46)
				part.Transparency = 1

				if v9 == "allAttack" then
					local clone = scylla2.lightning_impact:Clone()
					local clone2 = scylla2.ice_impact:Clone()
					local clone3 = scylla2.plasma_impact:Clone()
					local clone4 = scylla2.fireball_impact:Clone()
					clone.Parent = part
					clone2.Parent = part
					clone3.Parent = part
					clone4.Parent = part
					clone:Play()
					clone2:Play()
					clone3:Play()
					clone4:Play()
				else
					local clone = nil

					if v9 == "thunderAttack" then
						clone = scylla2.lightning_impact:Clone()
					elseif v9 == "iceAttack" then
						clone = scylla2.ice_impact:Clone()
					elseif v9 == "plasmaAttack" then
						clone = scylla2.plasma_impact:Clone()
					elseif v9 == "fireAttack" then
						clone = scylla2.fireball_impact:Clone()
					end

					clone.Parent = part
					clone:Play()
				end

				part.Parent = workspace.VFXDebris
				task.delay(6, function()
					part:Destroy()
				end)

				if vector.magnitude(position - humanoidRootPart.Position) <= 23 then
					scyllaDamageEvent:FireServer(v9 == "All" and 12.5 or nil)
				end
			end)
		end
	end
}

local function findBossFightUI()
	local hud = playerGui:FindFirstChild("hud")

	if not hud then
		return
	end

	local safezone = hud:FindFirstChild("safezone")

	if not safezone then
		return
	end

	local boss = safezone:FindFirstChild("Boss")

	if boss then
		return boss
	end
end

local function setCheckmarkVisibility(childName: string, visible: boolean)
	local hud = playerGui:FindFirstChild("hud")
	local boss

	if hud then
		local safezone = hud:FindFirstChild("safezone")

		if safezone then
			boss = safezone:FindFirstChild("Boss") or nil
		end
	end

	local itemsList

	if boss then
		itemsList = boss:FindFirstChild("ItemsList")
	end

	local child

	if itemsList then
		child = itemsList:FindFirstChild(childName)
	end

	local checkmark

	if child then
		checkmark = child:FindFirstChild("Checkmark")
	end

	if checkmark then
		assert(checkmark:IsA("ImageLabel"), "Luau")
		checkmark.Visible = visible
	end

	local folder = parent and parent:FindFirstChild(childName)

	if folder then
		assert(folder:IsA("Folder"), "Luau")

		for _, part in folder:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			local defaultMaterial = part:GetAttribute("DefaultMaterial")

			if not defaultMaterial then
				defaultMaterial = part.Material
				part:SetAttribute("DefaultMaterial", defaultMaterial)
			end

			local defaultColor = part:GetAttribute("DefaultColor")

			if not defaultColor then
				defaultColor = part.Color
				part:SetAttribute("DefaultColor", defaultColor)
			end

			if visible then
				part.Transparency = 0
				part.Color = defaultColor
				part.Material = defaultMaterial
			else
				part.Transparency = 0.5
				part.Color = Color3.fromRGB(91, 93, 105)
				part.Material = Enum.Material.SmoothPlastic
			end
		end
	end

	local resources

	if parent then
		resources = parent:FindFirstChild("Resources")
	end

	local main

	if resources then
		main = resources:FindFirstChild("Main")
	end

	local list

	if main then
		list = main:FindFirstChild("List")
	end

	local child2

	if list then
		child2 = list:FindFirstChild(childName)
	end

	local checkmark2

	if child2 then
		checkmark2 = child2:FindFirstChild("Checkmark")
	end

	if checkmark2 then
		assert(checkmark2:IsA("ImageLabel"), "Luau")
		checkmark2.Visible = visible
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCount()
	local v9 = scylla.scylla_firstPart.Value and 1 or 0
	local v10 = scylla.scylla_secondPart.Value and 1 or 0
	local v11 = scylla.scylla_thirdPart.Value and 1 or 0
	return v9 + v10 + v11
end

local function updateCount()
	local count = getCount() -- equivalent call inferred; original call site unknown
	local hud = playerGui:FindFirstChild("hud")
	local boss

	if hud then
		local safezone = hud:FindFirstChild("safezone")

		if safezone then
			boss = safezone:FindFirstChild("Boss") or nil
		end
	end

	local textLabel

	if boss then
		textLabel = boss:FindFirstChildOfClass("TextLabel")
	end

	if textLabel then
		textLabel.Text = `Ancient Weapon Parts: {count}/3`
	end

	local resources

	if parent then
		resources = parent:FindFirstChild("Resources")
	end

	local main

	if resources then
		main = resources:FindFirstChild("Main")
	end

	local amount

	if main then
		amount = main:FindFirstChild("Amount")
	end

	if amount then
		amount.Text = `{count}/3`

		if count >= 3 then
			resources.Enabled = false
		end
	end
end

local function createCheckmarkCallback(p: string)
	return function(visible: boolean)
		updateCount()
		setCheckmarkVisibility(p, visible)
	end
end

local Scylla = {
	inFight = false,
	currentFightState = false
}

function Scylla.init()
	setFightState.OnClientEvent:Connect(function(inFight)
		Scylla.inFight = inFight

		if inFight then
			Scylla.onFightEntered()
		else
			Scylla.onFightCompleted()
		end
	end)
end

function Scylla._valueChanged(p, onChanged)
	local maid2 = Trove.new()
	maid2:Add(v3:Connect(function()
		onChanged(p.Value)
	end))
	maid2:Add(v4:Connect(function()
		onChanged(p.Value)
	end))
	maid2:Add(p.Changed:Connect(onChanged))
	maid2:Add(task.spawn(onChanged, p.Value))
	return maid2
end

function Scylla.onFightEntered()
	if Scylla.currentFightState then
		return
	end

	Scylla.currentFightState = true
	local v9 = "Base"
	maid:Add(Scylla._valueChanged(scylla.scylla_firstPart, function(visible: boolean)
		updateCount()
		setCheckmarkVisibility(v9, visible)
	end))
	local v10 = "Bow"
	maid:Add(Scylla._valueChanged(scylla.scylla_secondPart, function(visible: boolean)
		updateCount()
		setCheckmarkVisibility(v10, visible)
	end))
	local v11 = "Arrow"
	maid:Add(Scylla._valueChanged(scylla.scylla_thirdPart, function(visible: boolean)
		updateCount()
		setCheckmarkVisibility(v11, visible)
	end))
	maid:Add(scyllaAttack.OnClientEvent:Connect(function(p, ...)
		local v12 = v8[p]

		if v12 then
			v12(...)
		end
	end))
	maid:Add(scyllaSetTarget.OnClientEvent:Connect(function(p)
		if v7 then
			v7.setTargetCharacter(p)
		end
	end))
	maid:Add(task.spawn(function()
		while true do
			task.wait(1)
			local hud = playerGui:FindFirstChild("hud")
			local boss

			if hud then
				local safezone = hud:FindFirstChild("safezone")

				if safezone then
					boss = safezone:FindFirstChild("Boss") or nil
				end
			end

			if not boss then
				continue
			end

			local timer = boss:FindFirstChild("Timer")
			local textLabel = timer and timer:FindFirstChildOfClass("TextLabel")

			if not textLabel then
				continue
			end

			local v12 = 600 - (workspace:GetServerTimeNow() - scylla.scylla_startedAt.Value)
			textLabel.Text = string.format("%.02d:%.02d", v12 // 60, v12 % 60)
		end
	end))
	maid:Add(Observers.observeTag("ActiveScyllaBoss", function(p)
		if not Scylla.inFight then
			return nil
		end

		local maid2 = Trove.new()
		local parent2 = p.Parent

		local function loadAnimation(animation)
			local track = parent2.AnimationController:LoadAnimation(animation)
			return track, maid2:Add(function()
				track:Stop(0)
				track:Destroy()
			end)
		end

		local vfx = HydraAttack.new(parent2)
		maid2:Add(function()
			v7 = nil
			vfx:Clean()
		end)
		local pivot = parent2:GetPivot()
		maid2:Add(function()
			parent2:PivotTo(pivot)
		end)
		local v13 = nil
		maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
			if not v13 then
				return
			end

			local pivot2 = parent2:GetPivot()
			local orientation, v14, v15 = pivot2:ToOrientation()
			local _, v16 = CFrame.lookAt(pivot2.Position, v13:GetPivot().Position):ToOrientation()
			local v17 = v16 + (v14 - v16) * math.exp(dt * -16)
			parent2:PivotTo(CFrame.new(pivot2.Position) * CFrame.fromOrientation(orientation, v17, v15))
		end))
		local v14 = {
			setTargetCharacter = function(p2)
				v13 = p2
			end,
			vfx = vfx,
			animations = 0
		}
		local idle = attacks.Idle
		local track = parent2.AnimationController:LoadAnimation(idle)
		maid2:Add(function()
			track:Stop(0)
			track:Destroy()
		end)
		local animations = {
			idle = track,
			blue = 0,
			red = 0,
			yellow = 0,
			purple = 0,
			all = 0
		}
		local blue = attacks.Blue
		local track2 = parent2.AnimationController:LoadAnimation(blue)
		maid2:Add(function()
			track2:Stop(0)
			track2:Destroy()
		end)
		animations.blue = track2
		local red = attacks.Red
		local track3 = parent2.AnimationController:LoadAnimation(red)
		maid2:Add(function()
			track3:Stop(0)
			track3:Destroy()
		end)
		animations.red = track3
		local yellow = attacks.Yellow
		local track4 = parent2.AnimationController:LoadAnimation(yellow)
		maid2:Add(function()
			track4:Stop(0)
			track4:Destroy()
		end)
		animations.yellow = track4
		local purple = attacks.Purple
		local track5 = parent2.AnimationController:LoadAnimation(purple)
		maid2:Add(function()
			track5:Stop(0)
			track5:Destroy()
		end)
		animations.purple = track5
		local all = attacks.All
		local track6 = parent2.AnimationController:LoadAnimation(all)
		maid2:Add(function()
			track6:Stop(0)
			track6:Destroy()
		end)
		animations.all = track6
		v14.animations = animations
		v14.animations.idle:Play()
		v7 = v14
		return maid2:WrapClean()
	end))
	maid:Add(Observers.observeTag("ScyllaHarpoon", function(p)
		local maid2 = Trove.new()
		parent = p.Parent
		parent.Resources.Enabled = true
		task.spawn(updateCount)
		maid2:Add(function()
			parent.Resources.Enabled = false
			parent = nil
			updateCount()
		end)
		local v12 = nil

		local function updateHighlight()
			if v and v6[v.Name] and Scylla.inFight then
				if not v12 then
					local highlight = Instance.new("Highlight")
					highlight.FillColor = Color3.fromRGB(100, 255, 100)
					highlight.FillTransparency = 0.6
					highlight.Parent = p.Parent
					v12 = maid2:Add(highlight)
				end
			elseif v12 then
				maid2:Remove(v12)
				v12 = nil
			end
		end

		maid2:Add(v2:Connect(updateHighlight))
		task.spawn(updateHighlight)
		return maid2:WrapClean()
	end))
	maid:Add(Observers.observeTag("ScyllaWeaponPart", function(p)
		local v12 = v5[p.Parent.Name]

		if not v12 then
			return nil
		end

		local maid2 = Trove.new()
		local v13 = v6[v12]
		local v14 = nil
		local v15 = nil

		local function requestUpdate()
			if v14 then
				maid2:Remove(v14)
			end

			if Scylla.inFight and v13 and not v13.Value and not (v and v6[v.Name]) then
				if not v15 then
					local highlight = Instance.new("Highlight")
					highlight.FillColor = Color3.fromRGB(152, 194, 219)
					highlight.FillTransparency = 0.6
					highlight.Parent = p.Parent
					v15 = maid2:Add(highlight)
				end
			elseif v15 then
				maid2:Remove(v15)
				v15 = nil
			end

			v14 = maid2:Add(task.spawn(function()
				local item = hasItem(v12) -- equivalent call inferred; original call site unknown
				p.ProximityPrompt.Enabled = not item
				local transparency = item and 0.65 or 0

				for _, part in p.Parent:GetChildren() do
					if part:IsA("BasePart") and part.Name ~= "Proximity" then
						part.Transparency = transparency
					end
				end

				if v14 then
					maid2:Remove(v14)
					v14 = nil
				end
			end))
		end

		maid2:Add(v2:Connect(requestUpdate))
		maid2:Add(v13.Changed:Connect(requestUpdate))
		maid2:Add(DataController.InventoryReplicator:Listen({ "Inventory" }, requestUpdate))
		maid2:Add(task.spawn(requestUpdate))
		return maid2:WrapClean()
	end))
	maid:Add(Observers.observeCharacter(localPlayer, function(_, instance)
		return Observers.observeChildren(instance, function(instance2)
			if instance2:IsA("Tool") and v6[instance2.Name] then
				v = instance2
				v2:Fire(instance2)
				return function()
					v = nil
					v2:Fire(v)
				end
			else
				if not instance2:IsA("Humanoid") then
					return nil
				end

				instance:SetAttribute("ScyllaBoss", 24)
				return function()
					instance:SetAttribute("ScyllaBoss", nil)
				end
			end
		end)
	end))
	task.delay(5, function()
		sound:Play()
	end)
	local hud = playerGui:FindFirstChild("hud")
	local boss

	if hud then
		local safezone = hud:FindFirstChild("safezone")

		if safezone then
			boss = safezone:FindFirstChild("Boss") or nil
		end
	end

	if boss then
		boss.Visible = true
	end

	v3:Fire()
end

function Scylla.onFightCompleted()
	if not Scylla.currentFightState then
		return
	end

	Scylla.currentFightState = false
	maid:Destroy()
	sound:Stop()
	local hud = playerGui:FindFirstChild("hud")
	local boss

	if hud then
		local safezone = hud:FindFirstChild("safezone")

		if safezone then
			boss = safezone:FindFirstChild("Boss") or nil
		end
	end

	if boss then
		boss.Visible = false
	end

	v4:Fire()
end

return Scylla