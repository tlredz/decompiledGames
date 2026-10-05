local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = game.Players.LocalPlayer
local v = { "Map", "DetachedMaps", "ParkourTraining" }
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function strippedNow()
	local device = localPlayer:GetAttribute("Device")

	if device == nil then
		return Platform_Handler.Platform.Value == "Mobile" or Platform_Handler.IsGamepad() == true
	end

	return device == "Mobile" or device == "Xbox" or device == "Playstation"
end

local function stripped()
	if v2 ~= nil then
		return v2
	end

	local device = localPlayer:GetAttribute("Device")
	local v3

	if device == nil then
		return Platform_Handler.Platform.Value == "Mobile" or Platform_Handler.IsGamepad() == true
	end

	if device ~= "Mobile" and device ~= "Xbox" then
		return device == "Playstation"
	end

	v3 = true
	return true
end

local function remembered(instance)
	return instance:GetAttribute("HazardCanTouch") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remember(instance)
	if instance:GetAttribute("HazardCanTouch") ~= nil then
		return
	end

	instance:SetAttribute("HazardTransparency", instance.Transparency)
	instance:SetAttribute("HazardCanCollide", instance.CanCollide)
	instance:SetAttribute("HazardCanTouch", instance.CanTouch)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forget(instance)
	instance:SetAttribute("HazardTransparency", nil)
	instance:SetAttribute("HazardCanCollide", nil)
	instance:SetAttribute("HazardCanTouch", nil)
end

local function armBrick(instance, flag: boolean)
	if flag then
		if instance:GetAttribute("HazardCanTouch") == nil then
			return
		end

		instance.CanTouch = instance:GetAttribute("HazardCanTouch")
		forget(instance) -- equivalent call inferred; original call site unknown
	else
		remember(instance) -- equivalent call inferred; original call site unknown
		instance.CanTouch = false
	end
end

local function showSpike(instance, flag: boolean)
	if flag then
		if instance:GetAttribute("HazardCanTouch") == nil then
			return
		end

		instance.Transparency = instance:GetAttribute("HazardTransparency")
		instance.CanCollide = instance:GetAttribute("HazardCanCollide")
		instance.CanTouch = instance:GetAttribute("HazardCanTouch")
		forget(instance) -- equivalent call inferred; original call site unknown
	else
		remember(instance) -- equivalent call inferred; original call site unknown
		instance.Transparency = 1
		instance.CanCollide = false
		instance.CanTouch = false
	end
end

local function apply(p: string, part)
	if part:GetAttribute("Ignore") == true then
		return
	end

	local v3

	if v2 == nil then
		local device = localPlayer:GetAttribute("Device")

		if device == nil then
			v3 = Platform_Handler.Platform.Value == "Mobile" or Platform_Handler.IsGamepad() == true
		else
			v3 = device == "Mobile" or device == "Xbox" or device == "Playstation"
		end
	else
		v3 = v2
	end

	local v4 = not v3
	local v5

	if p == "KillBricks" then
		v5 = armBrick
	else
		v5 = showSpike
	end

	if part:IsA("BasePart") then
		v5(part, v4)
	end

	for _, part2 in part:GetDescendants() do
		if part2:IsA("BasePart") then
			v5(part2, v4)
		end
	end
end

local function hazardOf(p, parent)
	while parent ~= nil and parent.Parent ~= p do
		parent = parent.Parent
	end

	return parent
end

local childrenByChildName = {}

local function sweepAll()
	for k, v3 in childrenByChildName do
		for _, child in v3:GetChildren() do
			apply(k, child)
		end
	end
end

local function findMap()
	local workspace2 = workspace

	for _, childName in v do
		workspace2 = workspace2:WaitForChild(childName, 30)

		if workspace2 == nil then
			return nil
		end
	end

	return workspace2
end

local function watch(map, childName: string)
	if childrenByChildName[childName] ~= nil then
		return
	end

	local child = map:WaitForChild(childName, 30)

	if child == nil then
		return
	end

	childrenByChildName[childName] = child
	child.DescendantAdded:Connect(function(parent)
		local v3 = child

		while parent ~= nil and parent.Parent ~= v3 do
			parent = parent.Parent
		end

		if parent ~= nil then
			apply(childName, parent)
		end
	end)

	for _, child2 in child:GetChildren() do
		apply(childName, child2)
	end
end

local function ready()
	return childrenByChildName.KillBricks ~= nil and childrenByChildName.Spikes ~= nil
end

local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function setup()
	local v4

	if childrenByChildName.KillBricks == nil then
		v4 = false
	else
		v4 = childrenByChildName.Spikes ~= nil
	end

	if v4 or v3 then
		return
	end

	v3 = true
	local map = findMap()

	if map ~= nil then
		watch(map, "KillBricks")
		watch(map, "Spikes")
	end

	v3 = false
end

task.spawn(setup)
Platform_Handler.Platform.Changed.Event:Connect(sweepAll)
localPlayer:GetAttributeChangedSignal("Device"):Connect(sweepAll)
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local v4 = nil
getvaluesfolder.ChildAdded:Connect(function(child)
	if child.Name ~= "Training" or child:GetAttribute("Type") ~= "Parkour Dungeon" then
		return
	end

	v4 = child
	v2 = strippedNow() -- equivalent call inferred; original call site unknown
	task.spawn(function()
		setup() -- equivalent call inferred; original call site unknown

		if v4 ~= child then
			return
		end

		sweepAll()
	end)
end)
getvaluesfolder.ChildRemoved:Connect(function(child)
	if child ~= v4 then
		return
	end

	v4 = nil
	v2 = nil
	sweepAll()
end)