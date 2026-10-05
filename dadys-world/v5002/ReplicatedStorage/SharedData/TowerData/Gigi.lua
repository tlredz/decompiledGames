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
	Icon = "rbxassetid://129007194644458",
	VoteIcon = "rbxassetid://115287358262111",
	Render = "rbxassetid://115149371153673",
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 1,
	StealthRank = 3,
	SkillCheckRank = 5,
	Ability1Name = "Surprise!",
	Ability1Type = "Active",
	Ability1Description = "This Toon can grant herself a random item from any Tier (Dandy's Shop items included). Has a Cooldown of 60.",
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://117224741485797",
	AbilityCooldown = 60,
	CustomAbilitySound = {
		Path = "Sounds.Toon.Gigi.Ability.Sound",
		Music = true
	},
	Cost = 2000,
	Requirement1 = { "Coin", 2000 },
	Requirement2 = { "Research", 50, "GigiMonster" },
	Requirement3 = { "RareOrHigher", 45 },
	MasterySkin = "VintageGigi",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 50
		},
		{
			Name = "TravelDistance",
			Requirement = 85000
		},
		{
			Name = "PickUpItem",
			Requirement = 150
		},
		{
			Name = "UseItem",
			Requirement = 200
		},
		{
			Name = "BuyDandyStoreItem",
			Requirement = 30
		},
		{
			Name = "CompleteGenerator",
			Requirement = 65
		}
	},
	RightHandBone = "Fingers.R",
	LatchedBoneOffset = CFrame.new(0.1, 0, -0.35),
	HurtAnimation = function(instance)
		local config = instance:FindFirstChild("Config")
		local hurtTexture = config and config:FindFirstChild("HurtTexture")
		local normalTexture = config and config:FindFirstChild("NormalTexture")

		if hurtTexture and normalTexture then
			setFaceTexture(instance, hurtTexture.Texture)
			task.wait(2)
			setFaceTexture(instance, normalTexture.Texture)
		end
	end
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = {
	Common = {},
	Uncommon = {},
	Rare = {},
	VeryRare = {},
	UltraRare = {}
}
local flag = false

local function grabItems()
	if flag then
		return
	end

	flag = true
	local children = ReplicatedStorage.Items:GetChildren()

	for _, v2 in pairs(children) do
		if v2.Name == "Tape" then
			continue
		end

		local module = require(ReplicatedStorage.ItemModules[v2.Name])

		if module.AbilityOnlyItem then
			continue
		end

		local v3 = v[module.Rarity]

		if v3 then
			table.insert(v3, {
				Name = v2.Name,
				Rarity = module.Rarity
			})
		else
			warn("[Gigi] item skipped from the Surprise! pool, unknown rarity: " .. v2.Name .. " / " .. tostring(module.Rarity))
		end
	end
end

local function getnumberofitemsintier(p)
	local v2 = {}

	for _, v3 in pairs(v[p]) do
		table.insert(v2, v3)
	end

	return #v2
end

local function RandomItem(p)
	grabItems()
	local itemRarity = workspace.Info.CardModifiers:FindFirstChild("ItemRarity")
	local itemRarity2 = workspace.Info.CardModifiers:FindFirstChild("ItemRarity2")
	local v2 = {
		Common = 44,
		Uncommon = 34,
		Rare = 16,
		VeryRare = 5,
		UltraRare = 1
	}

	if itemRarity and not itemRarity2 or itemRarity2 and not itemRarity then
		v2.Rare += 2
		v2.VeryRare += 1
		v2.UltraRare += 1
	elseif itemRarity and itemRarity2 then
		v2.Rare += 4
		v2.VeryRare += 2
		v2.UltraRare += 2
	end

	if p then
		v2.Common = 0
	end

	local v3 = {}

	for k, v4 in pairs(v2) do
		for _ = 1, v4 do
			table.insert(v3, k)
		end
	end

	local v4 = v3[math.random(1, #v3)]
	local v5 = v[v4]
	local v6 = {}

	for _, v8 in pairs(v[v4]) do
		table.insert(v6, v8)
	end

	return v5[math.random(1, #v6)]
end

local function hasLuckyCoin(instance)
	local trinkets = instance:FindFirstChild("Trinkets")

	if not trinkets then
		return false
	end

	for _, childName in ipairs({ "Trinket1", "Trinket2" }) do
		local child = trinkets:FindFirstChild(childName)

		if child and child.Value == "LuckyCoin" then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(player, p)
	if not player then
		return
	end

	local events = ReplicatedStorage:FindFirstChild("Events")
	local messageEvent = events and events:FindFirstChild("MessageEvent")

	if messageEvent then
		messageEvent:FireClient(player, p)
	end
end

local v2 = {
	"Slot1",
	"Slot2",
	"Slot3",
	"Slot4"
}

local function firstFreeSlot(instance)
	local inventory = instance:FindFirstChild("Inventory")

	if not inventory then
		return nil
	end

	for _, childName in ipairs(v2) do
		local child = inventory:FindFirstChild(childName)

		if child and child.Value == "None" then
			return child
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function grantRolledItem(instance, p)
	local v3 = firstFreeSlot(instance)

	if not v3 then
		return false
	end

	v3.Value = tostring(p)
	return true
end

local function rollsWithoutCommons(p)
	return (hasLuckyCoin(p))
end

local function readWheelTiming(p, p2)
	local success, result = pcall(function()
		return require(ReplicatedStorage.Modules.ClientUI.GigiWheelController)
	end)

	if success then
		if type(result) == "table" then
			success = result[p]
		else
			success = false
		end
	end

	if type(success) == "function" then
		local success2, result2 = pcall(success)

		if success2 and type(result2) == "number" and result2 > 0 then
			return result2
		end
	end

	return p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getWheelDuration()
	return (readWheelTiming("getSequenceDuration", 3.7))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSpinEndDelay()
	return (readWheelTiming("getSpinEndOffset", 2.35))
end

function Gigi.AbilityDialogueDelay()
	return (readWheelTiming("getSpinEndOffset", 2.35))
end

local function buildWheelEntries(name, luckyCoin)
	local v3 = math.random(1, 16)
	local result = {
		[v3] = name
	}

	for i = 1, 16 do
		if i == v3 then
			continue
		end

		local name2 = name

		for _ = 1, 10 do
			local randomItem = RandomItem(luckyCoin)

			if not randomItem then
				continue
			end

			name2 = randomItem.Name

			if name2 ~= name then
				break
			end
		end

		result[i] = name2
	end

	return result, v3
end

local v3 = nil

local function provisionWheelGui(player)
	if not RunService:IsServer() then
		return
	end

	if not v3 then
		local success, result = pcall(function()
			local ServerScriptService = game:GetService("ServerScriptService")
			return require(ServerScriptService.Modules.GuiProvisioner)
		end)

		if success then
			v3 = result
		else
			warn("[Gigi] GuiProvisioner unavailable:", result)
			return
		end
	end

	v3.give(player, "GigiAbilityUI")
end

local function resolveWheelRemote()
	local events = ReplicatedStorage:FindFirstChild("Events")
	local clientAbilityEvent = events and events:FindFirstChild("ClientAbilityEvent")
	local modules = ReplicatedStorage:FindFirstChild("Modules")
	local clientUI = modules and modules:FindFirstChild("ClientUI")
	local gigiWheelController = clientUI and clientUI:FindFirstChild("GigiWheelController")

	if clientAbilityEvent and gigiWheelController then
		return clientAbilityEvent, gigiWheelController
	end

	return nil, nil
end

local function showWheel(player, instance, wheelEntries, winningIndex)
	if not player then
		return
	end

	local wheelRemote, v4 = resolveWheelRemote()

	if not wheelRemote then
		return
	end

	provisionWheelGui(player)
	wheelRemote:FireClient(player, v4, instance, {
		Entries = wheelEntries,
		WinningIndex = winningIndex
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideWheel(player, character)
	if not player then
		return
	end

	local wheelRemote, v4 = resolveWheelRemote()

	if not wheelRemote then
		return
	end

	wheelRemote:FireClient(player, v4, character, {
		Cancel = true
	})
end

local object = setmetatable({}, {
	__mode = "k"
})

local function finishCast(state)
	if not state.active then
		return
	end

	state.active = false

	for _, connection in ipairs(state.connections) do
		connection:Disconnect()
	end

	table.clear(state.connections)
	pcall(function()
		state.character:SetAttribute("AbilityCooldownProvisional", nil)
	end)
end

local function cancelCast(data, p)
	if not data.active then
		return
	end

	print(string.format(
		"[Gigi] Cast cancelled for %s (%s, %.2fs in): %s withheld",
		data.character.Name,
		p,
		os.clock() - data.startedAt,
		(tostring(data.item))
	))

	if data.refundCooldown then
		data.refundCooldown()
	end

	finishCast(data)
	hideWheel(data.player, data.character) -- equivalent call inferred; original call site unknown
	notify(data.player, "Surprise! was interrupted.") -- equivalent call inferred; original call site unknown
end

local function beginCast(player, instance, name)
	local v4 = {
		active = true,
		player = player,
		character = instance,
		item = name,
		startedAt = os.clock(),
		connections = {}
	}
	instance:SetAttribute("AbilityCooldownProvisional", true)
	table.insert(v4.connections, instance.AncestryChanged:Connect(function()
		if instance.Parent == nil then
			finishCast(v4)
		end
	end))
	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function beatMayPlay(p)
	if not p.active then
		return false
	end

	local character = p.character
	local humanoid = character:FindFirstChild("Humanoid")

	if character.Parent and humanoid and not (humanoid.Health <= 0) then
		return true
	end

	cancelCast(p, "caster dead or removed at the beat")
	return false
end

function Gigi.UseActiveAbility(player, instance, _, _)
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

	local inElevator = stats:FindFirstChild("InElevator")

	if inElevator and inElevator.Value == true then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	local v5

	if instance:FindFirstChild("Humanoid") and instance.Humanoid.Health > 0 then
		instance:WaitForChild("Inventory")

		if not firstFreeSlot(instance) then
			return {
				Outcome = false,
				Reason = "Can't use that Ability while Inventory is full!"
			}
		end

		local luckyCoin = hasLuckyCoin(instance)
		local randomItem = RandomItem(luckyCoin)
		local name

		if randomItem then
			name = randomItem.Name
		else
			warn("No item found.")
			name = "Pop"
		end

		local wheelEntries, winningIndex = buildWheelEntries(name, luckyCoin)
		v5 = beginCast(player, instance, name)
		local wheelDuration = getWheelDuration() -- equivalent call inferred; original call site unknown
		local spinEndDelay = getSpinEndDelay() -- equivalent call inferred; original call site unknown
		print(string.format(
			"[Gigi] Cast by %s: rolled %s; wheel %.2fs, reveal at %.2fs",
			instance.Name,
			tostring(name),
			wheelDuration,
			spinEndDelay
		))
		showWheel(player, instance, wheelEntries, winningIndex)
		task.delay(spinEndDelay, function()
			-- equivalent call inferred; original call site unknown
			if not beatMayPlay(v5) then
				return
			end

			local decoding2 = instance:FindFirstChild("Decoding")

			if decoding2 and decoding2.Value ~= nil then
				return
			end

			game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")
		end)
		task.delay(wheelDuration, function()
			local v9 = beatMayPlay(v5) -- equivalent call inferred; original call site unknown
			finishCast(v5)

			if not v9 then
				return
			end

			-- equivalent call inferred; original call site unknown
			if grantRolledItem(instance, name) then
				local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
				ActionEvent:Record(player, "ReceiveItem", name, "Ability")
			else
				notify(player, "Your Inventory filled up! Lost the " .. tostring(name) .. ".") -- equivalent call inferred; original call site unknown
			end
		end)
	else
		v5 = nil
	end

	if not v5 or v5.active then
		currentCooldown.Value = cooldown.Value
		local v6 = {}
		object[instance] = v6

		if v5 then
			function v5.refundCooldown()
				if object[instance] ~= v6 then
					return
				end

				object[instance] = nil
				currentCooldown.Value = 0
			end
		end

		task.spawn(function()
			local lastTime = os.clock()

			while instance and instance.Parent and currentCooldown.Value > 0 do
				if object[instance] ~= v6 then
					break
				end

				currentCooldown.Value = math.max(0, currentCooldown.Value - 0.1)

				if currentCooldown.Value <= 0 then
					break
				end

				local v7 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v7)
			end
		end)
	end

	return {
		Outcome = true,
		Reason = "None"
	}
end

local nows = {}
Gigi.PlayFunctions = {
	RPAbility = {
		Cooldown = 5,
		DisplayName = Gigi.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
			local track = humanoid:LoadAnimation((animations:WaitForChild("Ability")))

			local function dothing()
				for _, v4 in pairs(humanoid:GetPlayingAnimationTracks()) do
					if v4.Name ~= "Ability" then
						continue
					end

					v4:Stop()
					v4:Destroy()
				end

				track:Play()
			end

			if nows[p] then
				if p2 < tick() - nows[p] then
					nows[p] = tick()
					dothing()
				end
			else
				nows[p] = tick()
				dothing()
			end
		end
	}
}
return Gigi