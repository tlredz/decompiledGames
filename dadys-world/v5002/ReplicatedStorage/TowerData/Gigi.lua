local Gigi = {
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 3,
	Stealth = 10,
	Stamina = 100,
	BoundarySize = 250,
	Name = "Gigi",
	Icon = "rbxassetid://91815485180492",
	VoteIcon = "rbxassetid://115287358262111",
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 1,
	StealthRank = 3,
	SkillCheckRank = 5,
	Ability1Name = "Surprise!",
	Ability1Type = "Active",
	Ability1Description = "This Toon can grant herself a random item from any Tier (Dandy's Shop items included). Has a Cooldown of 80."
}
game:GetService("TweenService")
game:GetService("Debris")

local function setFaceTexture(instance, texture)
	instance:WaitForChild("Config")
	local blinkingParts = instance:FindFirstChild("BlinkingParts")
	local v = {}

	if blinkingParts and #blinkingParts:GetChildren() > 0 then
		for _, objectValue in ipairs(blinkingParts:GetChildren()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			table.insert(v, objectValue.Value)

			if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
				table.insert(v, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
			end
		end
	else
		local head = instance:FindFirstChild("Head")

		if not head then
			warn("No Head found in character and no BlinkingParts folder.")
			return
		end

		table.insert(v, head)

		if head:FindFirstChild("Head") then
			table.insert(v, head.Head)
		end
	end

	for _, part in ipairs(v) do
		if part:IsA("BasePart") then
			part.TextureID = texture
		end
	end
end

function Gigi.HurtAnimation(instance)
	local config = instance:FindFirstChild("Config")
	local hurtTexture = config and config:FindFirstChild("HurtTexture")
	local normalTexture = config and config:FindFirstChild("NormalTexture")

	if hurtTexture and normalTexture then
		setFaceTexture(instance, hurtTexture.Texture)
		task.wait(2)
		setFaceTexture(instance, normalTexture.Texture)
	end
end

Gigi.ActiveAbility = true
Gigi.AbilityIcon = "rbxassetid://17702363394"
Gigi.AbilityCooldown = 80
Gigi.CustomAbilitySound = script.Sound
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local _ = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
local FloorItemPool = require(ReplicatedStorage.Modules.FloorItemPool)
local v = FloorItemPool.Build(function(p, p2)
	return p ~= "Tape" and p ~= "Ornament" and not p2.AbilityOnlyItem
end)

local function getnumberofitemsintier(p, _)
	local v2 = {}

	for _, v3 in pairs(v[p]) do
		table.insert(v2, v3)
	end

	return #v2
end

function RandomItem(_)
	local v2

	if workspace.Info.CardModifiers:FindFirstChild("ItemRarity") and workspace.Info.CardModifiers:FindFirstChild("ItemRarity2") then
		v2 = {
			Common = 50,
			Uncommon = 35,
			Rare = 19,
			VeryRare = 7,
			UltraRare = 3
		}
	elseif workspace.Info.CardModifiers:FindFirstChild("ItemRarity") then
		v2 = {
			Common = 50,
			Uncommon = 35,
			Rare = 17,
			VeryRare = 6,
			UltraRare = 2
		}
	elseif workspace.Info.CardModifiers:FindFirstChild("ItemRarity2") then
		v2 = {
			Common = 50,
			Uncommon = 35,
			Rare = 17,
			VeryRare = 6,
			UltraRare = 2
		}
	else
		v2 = {
			Common = 50,
			Uncommon = 35,
			Rare = 15,
			VeryRare = 5,
			UltraRare = 1
		}
	end

	local v3 = {}

	for k, v4 in pairs(v2) do
		local count = 0

		repeat
			table.insert(v3, k)
			count += 1
		until count == v4
	end

	local v4 = v3[math.random(1, #v3)]
	local v5 = v[v4]
	local v6 = {}

	for _, v8 in pairs(v[v4]) do
		table.insert(v6, v8)
	end

	return v5[math.random(1, #v6)]
end

local function canseetarget(folder, ancestor, p, p2, p3)
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local folders = {}
	local filterDescendantsInstances = {}
	local position = p.Position
	local v3 = (p2.Position - p.Position).Unit * p3
	local raycastParams = RaycastParams.new()

	if model then
		model:WaitForChild("Monsters")

		for _, folder2 in pairs(model.Monsters:GetChildren()) do
			if table.find(folders, folder2) then
				continue
			end

			for _, part in pairs(folder2:GetDescendants()) do
				if part:IsA("BasePart") then
					table.insert(filterDescendantsInstances, part)
				end
			end

			table.insert(folders, folder2)
		end
	end

	for _, folder2 in pairs(workspace.Elevators:GetChildren()) do
		if table.find(folders, folder2) then
			continue
		end

		for _, part in pairs(folder2:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(filterDescendantsInstances, part)
			end
		end

		table.insert(folders, folder2)
	end

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(filterDescendantsInstances, part)
		end
	end

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		if child ~= ancestor then
			table.insert(filterDescendantsInstances, child)
		end
	end

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = game.Workspace:Raycast(position, v3, raycastParams)

	if raycastResult and raycastResult.Instance and raycastResult.Instance:IsDescendantOf(ancestor) then
		return true
	end

	return false
end

function Gigi.UseActiveAbility(_, instance, _, _)
	instance:WaitForChild("Config")
	local decoding = instance:WaitForChild("Decoding")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	instance:WaitForChild("Humanoid")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if not (workspace.CurrentRoom:FindFirstChildOfClass("Model") and workspace.Info.FloorActive.Value == true) then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	if decoding.Value ~= nil then
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
		}
	end

	if instance:FindFirstChild("Humanoid") and instance.Humanoid.Health > 0 then
		local inventory = instance:WaitForChild("Inventory")
		local slot1 = inventory:WaitForChild("Slot1")
		local slot2 = inventory:WaitForChild("Slot2")
		local slot3 = inventory:WaitForChild("Slot3")
		local slot4 = inventory:FindFirstChild("Slot4")
		local v3 = false
		local v4 = RandomItem()
		local name

		if v4 then
			name = v4.Name
		else
			warn("No item found.")
			name = "Pop"
		end

		if slot1.Value == "None" then
			slot1.Value = tostring(name)
			v3 = true
		end

		if slot2.Value == "None" and not v3 then
			slot2.Value = tostring(name)
			v3 = true
		end

		if slot3.Value == "None" and not v3 then
			slot3.Value = tostring(name)
			v3 = true
		end

		if slot4 and slot4.Value == "None" and not v3 then
			slot4.Value = tostring(name)
			v3 = true
		end

		if not v3 then
			return {
				Outcome = false,
				Reason = "Can't use that Ability while Inventory is full!"
			}
		end
	end

	game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")
	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v4 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v4)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "None"
	}
end

return Gigi