local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local Eggs = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))
local EggLuckBillboard = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("EggLuckBillboard"))
local eggs = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Eggs")
local rarityGradients = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RarityGradients")
require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Spawns"))
local EggCycle = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("EggCycle"))
local String = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("String"))
local activeEggs = (ReplicatedStorage:FindFirstChild("ServerData") or ReplicatedStorage):WaitForChild("ActiveEggs")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local eggsHolder = parent:WaitForChild("EggsHolder")
local timer = parent:WaitForChild("Timer")
local eggFrame = script:WaitForChild("EggFrame")
local color = Color3.fromRGB(200, 200, 200)

local function ApplyRarity(clone, rarity)
	if not rarity or rarity == "Common" then
		return rarity
	end

	local child = rarityGradients:FindFirstChild(rarity)

	if not child then
		warn(string.format("EggTracker: no gradient asset for rarity %q", (tostring(rarity))))
		return rarity
	end

	clone.BackgroundColor3 = color
	local uIGradient = clone:FindFirstChildOfClass("UIGradient")

	if uIGradient then
		uIGradient:Destroy()
	end

	local clone2 = child:Clone()
	clone2.Name = rarity
	clone2.Parent = clone
	return rarity
end

local function IsGlobalEgg(p)
	return Eggs[p].MaxAmount ~= nil
end

local function BuildViewport(viewportFrame, childName)
	local folder = eggs:FindFirstChild(childName)

	if not folder then
		return false
	end

	local model = Instance.new("Model")

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()
		clone.Anchored = true
		clone.Parent = model
	end

	if not model:FindFirstChildWhichIsA("BasePart") then
		model:Destroy()
		return false
	end

	model.Parent = viewportFrame
	local boundingBox, v = model:GetBoundingBox()
	local position = boundingBox.Position
	local v2 = math.max(v.Magnitude / 2, 0.1)
	local v3 = v2 / 0.36397023426620234 * 1.15
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.CFrame = CFrame.lookAt(position + Vector3.new(0, v2 * 0.35, v3), position)
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	return true
end

local clones = {}
local v = {}
local serverData = ReplicatedStorage:WaitForChild("ServerData")

local function EggReleased(p)
	local egg = Eggs[p]
	local releaseKey = egg and egg.ReleaseKey

	if releaseKey == nil then
		return true
	end

	local attribute = serverData:GetAttribute("ReleaseAt_" .. releaseKey)
	return typeof(attribute) == "number" and attribute <= os.time()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateFrame(p)
	local v2 = clones[p]

	if not v2 then
		return
	end

	local amount

	if Eggs[p].MaxAmount ~= nil then
		amount = v[p] or 0
	else
		amount = Eggs[p].Amount or 0
	end

	v2.Count.Text = "x" .. amount
	local visible

	if amount > 0 then
		local egg = Eggs[p]
		local releaseKey = egg and egg.ReleaseKey

		if releaseKey == nil then
			visible = true
		else
			local attribute = serverData:GetAttribute("ReleaseAt_" .. releaseKey)

			if typeof(attribute) == "number" then
				visible = attribute <= os.time()
			else
				visible = false
			end
		end
	else
		visible = false
	end

	v2.Visible = visible
end

local function BuildFrames()
	local v2 = {}

	for k in Eggs do
		table.insert(v2, k)
	end

	table.sort(v2, function(a, b)
		return (Eggs[a].Luck or 0) < (Eggs[b].Luck or 0)
	end)

	for k, name in v2 do
		local egg = Eggs[name]
		local clone = eggFrame:Clone()
		clone.Name = name
		clone.LayoutOrder = k
		local luckDisplay = clone:FindFirstChild("LuckDisplay")
		local luck = luckDisplay and luckDisplay:FindFirstChild("Luck")

		if luck then
			luck.Text = EggLuckBillboard.FormatLuck(egg.Luck or 0)
		end

		ApplyRarity(clone, egg.Rarity)
		local visible = egg.Image ~= nil

		if visible then
			clone.ImageLabel.Image = egg.Image
			local v5 = clone
			local v6 = name
			task.spawn(function()
				local v7 = nil
				pcall(function()
					ContentProvider:PreloadAsync({ v5.ImageLabel }, function(p, p2)
						v7 = p2
					end)
				end)

				if v7 == Enum.AssetFetchStatus.Failure and BuildViewport(v5.ViewportFrame, v6) then
					warn("EggTracker: image failed to load for", v6, "- showing viewport instead")
					v5.ImageLabel.Visible = false
					v5.ViewportFrame.Visible = true
				end
			end)
		else
			visible = not BuildViewport(clone.ViewportFrame, name)
		end

		clone.ImageLabel.Visible = visible
		clone.ViewportFrame.Visible = not visible
		clone.Parent = eggsHolder
		clones[name] = clone
		UpdateFrame(name) -- equivalent call inferred; original call site unknown
	end
end

local function CountsForMe(child)
	local privateTo = child:GetAttribute("PrivateTo")

	if privateTo ~= nil and privateTo ~= localPlayer.UserId then
		return false
	end

	if child:GetAttribute("AdminSpawn") == true then
		local adminEggId = child:GetAttribute("AdminEggId")
		local collectedAdminEggs = localPlayer:GetAttribute("CollectedAdminEggs")
		return type(adminEggId) ~= "string" or type(collectedAdminEggs) ~= "string" or string.find(
			collectedAdminEggs,
			"," .. adminEggId .. ",",
			1,
			true
		) == nil
	else
		local collectedEggs = localPlayer:GetAttribute("CollectedEggs")
		local egg = child:GetAttribute("Egg")

		if typeof(collectedEggs) == "string" and collectedEggs ~= "" and egg and string.find(
			collectedEggs,
			egg .. ",",
			1,
			true
		) then
			return false
		end

		return true
	end
end

local flag = false

local function RecountGlobals()
	for k in v do
		v[k] = 0
	end

	for _, child in activeEggs:GetChildren() do
		local egg = child:GetAttribute("Egg")

		if egg and Eggs[egg] and Eggs[egg].MaxAmount ~= nil and CountsForMe(child) then
			v[egg] = (v[egg] or 0) + 1
		end
	end

	for k in clones do
		UpdateFrame(k) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function QueueRecount()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		RecountGlobals()
	end)
end

serverData.AttributeChanged:Connect(function(value)
	if string.sub(value, 1, 10) == "ReleaseAt_" then
		QueueRecount() -- equivalent call inferred; original call site unknown
	end
end)
task.spawn(function()
	while true do
		local v2 = nil

		for k, v3 in serverData:GetAttributes() do
			if not (string.sub(k, 1, 10) == "ReleaseAt_" and typeof(v3) == "number" and os.time() < v3) then
				continue
			end

			if not (v2 == nil or v3 < v2) then
				continue
			end

			v2 = v3
		end

		if v2 == nil then
			break
		end

		task.wait((math.clamp(v2 - os.time(), 1, 30)))
		QueueRecount() -- equivalent call inferred; original call site unknown
	end
end)
BuildFrames()
activeEggs.ChildAdded:Connect(QueueRecount)
activeEggs.ChildRemoved:Connect(QueueRecount)
localPlayer:GetAttributeChangedSignal("CollectedEggs"):Connect(QueueRecount)
localPlayer:GetAttributeChangedSignal("CollectedAdminEggs"):Connect(QueueRecount)
RecountGlobals()
local total = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateTimer()
	timer.Text = string.format(
		"Egg resets in %s",
		String:ConvertSecondsToMS((math.ceil((EggCycle.SecondsRemaining()))))
	)
end

UpdateTimer() -- equivalent call inferred; original call site unknown
RunService.Heartbeat:Connect(function(dt)
	if not parent.Visible then
		return
	end

	total += dt

	if total < 0.25 then
		return
	end

	total = 0
	UpdateTimer() -- equivalent call inferred; original call site unknown
end)
game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("OpenEggTracker").OnClientEvent:Connect(function()
	UpdateTimer() -- equivalent call inferred; original call site unknown
	UIController.open(parent)
end)