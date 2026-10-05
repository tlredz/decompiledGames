local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local localPlayer = Players.LocalPlayer
local Holiday = require(ReplicatedStorage.Modules.Holiday)

if Holiday:GetCurrentHoliday().Name ~= "Halloween" then
	return
end

local prefabs = workspace:WaitForChild("Prefabs")
local clone = ReplicatedStorage.Assets.Misc.Candies:Clone()
clone.Parent = workspace
local Network = require(ReplicatedStorage.Modules.Network)

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

local function GetCurrentPrefab()
	local currentMap = GetCurrentMap() -- equivalent call inferred; original call site unknown
	local child = workspace.Places:FindFirstChild(currentMap)
	return (prefabs:FindFirstChild((`{not child and "Default" or child:GetAttribute("SkinName")}Prefab`)))
end

local function SetCandyVisible(folder, flag: boolean)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = flag
		elseif descendant:IsA("PointLight") then
			descendant.Enabled = flag
		end
	end

	folder.Transparency = flag and 0 or 1
	local sound = folder:FindFirstChildOfClass("Sound")

	if sound then
		sound.SoundGroup = SoundService.Event
		sound.Playing = flag
	end
end

local function HideAllCandies()
	for _, part in clone:GetChildren() do
		if part.Name == "Candy" and part:IsA("BasePart") then
			SetCandyVisible(part, false)
		end
	end
end

local function TouchedCandy(p)
	if p.Transparency == 1 then
		return
	end

	script.Collect:Play()
	HideAllCandies()
	Network:fire("CollectCandy")
end

local function PickRandomCandy()
	local children = clone:GetChildren()

	for k, v in children do
		if v.Name ~= "Candy" then
			table.remove(children, k)
		end
	end

	return children[math.random(1, #children)]
end

for _, part in clone:GetChildren() do
	if not (part.Name == "Candy" and part:IsA("BasePart")) then
		continue
	end

	local v = part
	part.Touched:Connect(function()
		if v.Transparency == 1 then
			return
		end

		script.Collect:Play()
		HideAllCandies()
		Network:fire("CollectCandy")
	end)
end

localPlayer:GetAttributeChangedSignal("CurrentInternalMap"):Connect(function()
	local currentMap = GetCurrentMap() -- equivalent call inferred; original call site unknown
	local child = currentMap and workspace.Places:FindFirstChild(currentMap)

	if child then
		clone:PivotTo(child:GetPivot())
	end
end)
local v = {}

for _, part in clone:GetChildren() do
	if not (part:IsA("BasePart") and part.Name == "Candy") then
		continue
	end

	local clone_2 = script["DISTURBED WHISPERS 01"]:Clone()
	clone_2.Parent = part
	v[part] = part.CFrame * clone:GetPivot()
end

RunService.RenderStepped:Connect(function()
	local v2 = CFrame.new(0, math.sin((tick())), 0) * CFrame.Angles(0, math.sin((tick())), 0)

	for _, part in clone:GetChildren() do
		if not (part.Name == "Candy" and part:IsA("BasePart")) then
			continue
		end

		local v3 = v[part] * v2
		part.CFrame = clone.Baseplate.CFrame:ToWorldSpace(v3)
	end
end)
RunService.Heartbeat:Connect(function()
	SoundService.Event.Volume = Players.LocalPlayer:GetAttribute("MuteEventSounds") and 0 or 1
end)

while true do
	local pickRandomCandy = PickRandomCandy()
	HideAllCandies()
	SetCandyVisible(pickRandomCandy, true)
	task.delay(60, function()
		SetCandyVisible(pickRandomCandy, false)
	end)

	repeat
		task.wait()
	until pickRandomCandy.Transparency == 1

	task.wait(60)
end