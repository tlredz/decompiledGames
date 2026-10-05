local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local localPlayer = Players.LocalPlayer
local itemModules = ReplicatedStorage:WaitForChild("ItemModules")
local v = {}
local v2 = {}

local function getItemDisplayName(childName)
	local child = itemModules:FindFirstChild(childName)

	if child then
		local success, result = pcall(require, child)

		if success and result.Name then
			return result.Name
		end
	end

	return childName
end

local function getNextInventoryItem()
	local character = localPlayer.Character

	if not character then
		return nil
	end

	local inventory = character:FindFirstChild("Inventory")

	if not inventory then
		return nil
	end

	for _, childName in pairs({
		"Slot1",
		"Slot2",
		"Slot3",
		"Slot4"
	}) do
		local child = inventory:FindFirstChild(childName)

		if child and child.Value ~= "None" and child.Value ~= "" then
			return child.Value
		end
	end

	return nil
end

local v3 = {
	GourdyMonster = function(p, instance)
		local lastFeedTime = instance:GetAttribute("LastFeedTime")

		if lastFeedTime then
			local v4 = 1 - (workspace:GetServerTimeNow() - lastFeedTime)

			if v4 > 0 then
				p.ActionText = string.format("Cooldown... %.1fs", v4)
				p.ObjectText = "Twisted Gourdy (Feeding)"
				return
			end
		end

		if instance:GetAttribute("IsStationary") == false then
			p.ActionText = "Too Dangerous!"
			p.ObjectText = "Twisted Gourdy (Mobile)"
		else
			local nextInventoryItem = getNextInventoryItem()

			if nextInventoryItem then
				local child = itemModules:FindFirstChild(nextInventoryItem)

				if child then
					local success, result = pcall(require, child)

					if success and result.Name then
						nextInventoryItem = result.Name
					end
				end

				p.ActionText = string.format("Gift [%s]", nextInventoryItem)
				p.ObjectText = "Twisted Gourdy"
			else
				p.ActionText = "No Items to Gift!"
				p.ObjectText = "Twisted Gourdy (Empty Inventory)"
			end
		end
	end,
	HolidayFreeItemPrompt = function(p)
		if localPlayer:GetAttribute("TookHolidayFreeItem") then
			p.Enabled = false
		end
	end
}

local function getPromptHandler(instance)
	if instance.Name == "HolidayFreeItemPrompt" then
		return v3.HolidayFreeItemPrompt, nil
	end

	local parent = instance.Parent

	if not parent then
		return nil
	end

	if parent.Name == "HumanoidRootPart" then
		local parent2 = parent.Parent

		if parent2 and CollectionService:HasTag(parent2, "GourdyMonster") then
			return v3.GourdyMonster, parent2
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePromptText(instance)
	local holidayFreeItemPrompt, parent

	if instance.Name == "HolidayFreeItemPrompt" then
		holidayFreeItemPrompt = v3.HolidayFreeItemPrompt
	else
		local parent2 = instance.Parent

		if parent2 and parent2.Name == "HumanoidRootPart" then
			parent = parent2.Parent

			if parent and CollectionService:HasTag(parent, "GourdyMonster") then
				holidayFreeItemPrompt = v3.GourdyMonster
			else
				parent = nil
			end
		end
	end

	if holidayFreeItemPrompt then
		holidayFreeItemPrompt(instance, parent)
	end
end

local function setupAttributeListeners(instance, parent)
	local connections = {}

	if not parent then
		return connections
	end

	if parent:GetAttribute("LastFeedTime") ~= nil then
		connections[#connections + 1] = parent:GetAttributeChangedSignal("LastFeedTime"):Connect(function()
			updatePromptText(instance) -- equivalent call inferred; original call site unknown
		end)
	end

	if parent:GetAttribute("IsStationary") ~= nil then
		connections[#connections + 1] = parent:GetAttributeChangedSignal("IsStationary"):Connect(function()
			updatePromptText(instance) -- equivalent call inferred; original call site unknown
		end)
	end

	return connections
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupAttributeListeners(p)
	local v4 = v2[p]

	if v4 then
		for _, connection in pairs(v4) do
			connection:Disconnect()
		end

		v2[p] = nil
	end
end

ProximityPromptService.PromptShown:Connect(function(instance, _)
	local holidayFreeItemPrompt, parent

	if instance.Name == "HolidayFreeItemPrompt" then
		holidayFreeItemPrompt = v3.HolidayFreeItemPrompt
	else
		local parent2 = instance.Parent

		if parent2 and parent2.Name == "HumanoidRootPart" then
			parent = parent2.Parent

			if parent and CollectionService:HasTag(parent, "GourdyMonster") then
				holidayFreeItemPrompt = v3.GourdyMonster
			else
				parent = nil
			end
		end
	end

	if holidayFreeItemPrompt then
		v[instance] = {
			handler = holidayFreeItemPrompt,
			context = parent
		}
		v2[instance] = setupAttributeListeners(instance, parent)
		updatePromptText(instance) -- equivalent call inferred; original call site unknown
	end
end)
ProximityPromptService.PromptHidden:Connect(function(p, _)
	cleanupAttributeListeners(p) -- equivalent call inferred; original call site unknown
	v[p] = nil
end)
RunService.Heartbeat:Connect(function()
	for k, v4 in pairs(v) do
		if k and k.Parent then
			if v4.context then
				local lastFeedTime = v4.context:GetAttribute("LastFeedTime")

				if lastFeedTime and 1 - (workspace:GetServerTimeNow() - lastFeedTime) > 0 then
					v4.handler(k, v4.context)
				end
			end
		else
			cleanupAttributeListeners(k) -- equivalent call inferred; original call site unknown
			v[k] = nil
		end
	end
end)

local function setupInventoryListeners()
	local character = localPlayer.Character

	if not character then
		return
	end

	local inventory = character:WaitForChild("Inventory", 5)

	if not inventory then
		return
	end

	for _, childName in pairs({
		"Slot1",
		"Slot2",
		"Slot3",
		"Slot4"
	}) do
		local child = inventory:FindFirstChild(childName)

		if child then
			child:GetPropertyChangedSignal("Value"):Connect(function()
				for k, v4 in pairs(v) do
					if v4.handler then
						v4.handler(k, v4.context)
					end
				end
			end)
		end
	end
end

localPlayer.CharacterAdded:Connect(function(_)
	task.wait(0.5)
	setupInventoryListeners()
end)

if localPlayer.Character then
	setupInventoryListeners()
end

local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function stashRuleActive()
	local info = workspace:FindFirstChild("Info")
	local gigiSearchNeedsSpace = info and info:GetAttribute("GigiSearchNeedsSpace")
	return typeof(gigiSearchNeedsSpace) ~= "boolean" or gigiSearchNeedsSpace
end

local function hasFreeInventorySlot()
	local character = localPlayer.Character
	local inventory = character and character:FindFirstChild("Inventory")

	if not inventory then
		return true
	end

	local v4 = false

	for _, stringValue in ipairs(inventory:GetChildren()) do
		if not stringValue:IsA("StringValue") then
			continue
		end

		if stringValue.Value == "None" then
			return true
		else
			v4 = true
		end
	end

	return not v4
end

local function isEligibleSearcher()
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if not inGamePlayers then
		return false
	end

	local character = localPlayer.Character

	if not character or character.Parent ~= inGamePlayers then
		return false
	end

	local humanoid = character:FindFirstChild("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local function applyStashPromptState(instance)
	if not instance.Parent then
		return
	end

	local stashPromptEnabled = instance:GetAttribute("StashPromptEnabled")

	if typeof(stashPromptEnabled) ~= "boolean" then
		stashPromptEnabled = instance.Enabled
	end

	if stashPromptEnabled then
		local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

		if inGamePlayers then
			local character = localPlayer.Character

			if character and character.Parent == inGamePlayers then
				local humanoid = character:FindFirstChild("Humanoid")

				if humanoid == nil then
					stashPromptEnabled = false
				else
					stashPromptEnabled = humanoid.Health > 0
				end
			else
				stashPromptEnabled = false
			end
		else
			stashPromptEnabled = false
		end

		if stashPromptEnabled then
			stashPromptEnabled = not (stashRuleActive() and not hasFreeInventorySlot())
		end
	end

	if instance.Enabled ~= stashPromptEnabled then
		instance.Enabled = stashPromptEnabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshStashPrompts()
	for _, v4 in ipairs(CollectionService:GetTagged("GigiHoardPrompt")) do
		applyStashPromptState(v4)
	end
end

local function trackStashPrompt(instance)
	if object[instance] then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reapply()
		applyStashPromptState(instance)
	end

	object[instance] = {
		instance:GetAttributeChangedSignal("StashPromptEnabled"):Connect(reapply),
		instance:GetPropertyChangedSignal("Enabled"):Connect(reapply)
	}
	reapply() -- equivalent call inferred; original call site unknown
end

local count = 0
local connections = {}

for _, v4 in ipairs(CollectionService:GetTagged("GigiHoardPrompt")) do
	trackStashPrompt(v4)
end

CollectionService:GetInstanceAddedSignal("GigiHoardPrompt"):Connect(trackStashPrompt)
CollectionService:GetInstanceRemovedSignal("GigiHoardPrompt"):Connect(function(p)
	local v4 = object[p]

	if v4 then
		for _, connection in ipairs(v4) do
			connection:Disconnect()
		end

		object[p] = nil
	end
end)

local function bindStashInventory(character)
	count += 1
	local v4 = count

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)

	if character then
		local inventory = character:WaitForChild("Inventory", 10)

		if v4 ~= count then
			return
		end

		if inventory then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				table.insert(connections, humanoid.Died:Connect(refreshStashPrompts))
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function watchSlot(stringValue)
				if not stringValue:IsA("StringValue") then
					return
				end

				table.insert(connections, stringValue:GetPropertyChangedSignal("Value"):Connect(refreshStashPrompts))
			end

			for _, child in ipairs(inventory:GetChildren()) do
				watchSlot(child) -- equivalent call inferred; original call site unknown
			end

			table.insert(connections, inventory.ChildAdded:Connect(function(child)
				watchSlot(child) -- equivalent call inferred; original call site unknown
				refreshStashPrompts() -- equivalent call inferred; original call site unknown
			end))
			refreshStashPrompts() -- equivalent call inferred; original call site unknown
			return
		end
	end

	refreshStashPrompts() -- equivalent call inferred; original call site unknown
end

localPlayer.CharacterAdded:Connect(bindStashInventory)
localPlayer:GetPropertyChangedSignal("Character"):Connect(function()
	bindStashInventory(localPlayer.Character)
end)

if localPlayer.Character then
	task.spawn(bindStashInventory, localPlayer.Character)
end

task.spawn(function()
	local inGamePlayers = workspace:WaitForChild("InGamePlayers", 30)

	if not inGamePlayers then
		return
	end

	inGamePlayers.ChildAdded:Connect(refreshStashPrompts)
	inGamePlayers.ChildRemoved:Connect(refreshStashPrompts)
	refreshStashPrompts() -- equivalent call inferred; original call site unknown
end)
task.spawn(function()
	local info = workspace:WaitForChild("Info", 30)

	if not info then
		return
	end

	info:GetAttributeChangedSignal("GigiSearchNeedsSpace"):Connect(refreshStashPrompts)
end)
localPlayer:GetAttributeChangedSignal("TookHolidayFreeItem"):Connect(function()
	if not localPlayer:GetAttribute("TookHolidayFreeItem") then
		return
	end

	for k in pairs(v) do
		if k.Name == "HolidayFreeItemPrompt" then
			k.Enabled = false
		end
	end

	for _, v4 in ipairs(CollectionService:GetTagged("Dandy_HolidayItem")) do
		local holidayFreeItemPrompt = v4:FindFirstChild("HolidayFreeItemPrompt", true)

		if holidayFreeItemPrompt and holidayFreeItemPrompt:IsA("ProximityPrompt") then
			holidayFreeItemPrompt.Enabled = false
		end
	end

	for _, proximityPrompt in ipairs(workspace:GetDescendants()) do
		if proximityPrompt:IsA("ProximityPrompt") and proximityPrompt.Name == "HolidayFreeItemPrompt" then
			proximityPrompt.Enabled = false
		end
	end
end)