local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local Data = require(ReplicatedStorage.Modules.Data)
local localPlayer = Players.LocalPlayer
local eggs = ReplicatedStorage.Assets.Models.Eggs
local descendants = {}

for _, child in workspace:WaitForChild("Prefabs"):GetChildren() do
	for _, descendant in child:WaitForChild("Prefab"):GetDescendants() do
		if descendant.Name == "EggSpot" then
			table.insert(descendants, descendant)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCurrentMap()
	return localPlayer:GetAttribute("CurrentInternalMap")
end

local function GetCurrentSkin()
	local currentMap = GetCurrentMap() -- equivalent call inferred; original call site unknown
	local child = workspace.Places:FindFirstChild(currentMap)

	if child then
		return child:GetAttribute("SkinName")
	end

	return "Default"
end

local clone = nil
local flag = false

local function spawnEgg(flag2: boolean)
	if #Data.CollectedEggss.Items == 15 then
		return
	end

	if not flag2 then
		flag = true
		script.Spawn1:Play()
		task.wait(0.3)
		script.Spawn2:Play()
		_G.DisplayText("An Egg has spawned!", 8)
	end

	local parent = descendants[math.random(#descendants)]

	repeat
		clone = eggs:GetChildren()[math.random(#eggs:GetChildren())]
	until table.find(Data.CollectedEggss.Items, clone.Name) == nil

	clone = clone:Clone()
	clone.CFrame = parent.CFrame
	clone.Size = parent.Size
	clone.Parent = parent
	local clone2 = script.Nah.Attachment:Clone()
	clone2.Parent = clone
	clone2.ParticleEmitter.Enabled = true
	local clone3 = script.Nah.ParticleEmitter:Clone()
	clone3.Parent = clone
	clone3.Enabled = true
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Collect Egg"
	proximityPrompt.ObjectText = "Collect Egg"
	proximityPrompt.MaxActivationDistance = 5
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.HoldDuration = 0
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.Parent = clone
	proximityPrompt.Triggered:Once(function()
		flag = false
		clone.Transparency = 1
		proximityPrompt.Enabled = false
		clone2.ParticleEmitter.Enabled = false
		clone3.Enabled = false
		Network:fire("CollectEgg", clone.Name)
		_G.DisplayText("You got an Egg!", 8)
		script.Collect:Play()
		script.Collect2:Play()
		task.wait()
		clone:Destroy()
	end)
end

localPlayer:GetAttributeChangedSignal("CurrentInternalMap"):Connect(function()
	if localPlayer:GetAttribute("CurrentInternalMap") then
		descendants = {}

		for _, descendant in GetCurrentPrefab():WaitForChild("Prefab"):GetDescendants() do
			if descendant.Name == "EggSpot" then
				table.insert(descendants, descendant)
			end
		end

		if flag then
			if clone then
				clone:Destroy()
			end

			spawnEgg(true)
		end
	end
end)
task.wait(20)

if #Data.CollectedEggss.Items == 0 then
	spawnEgg()
end

while true do
	task.wait(5)

	if flag ~= false then
		continue
	end

	task.wait(math.random(90, 220))

	if #Data.CollectedEggss.Items == 15 then
		break
	end

	if localPlayer:GetAttribute("CurrentInternalMap") then
		spawnEgg()
	end
end