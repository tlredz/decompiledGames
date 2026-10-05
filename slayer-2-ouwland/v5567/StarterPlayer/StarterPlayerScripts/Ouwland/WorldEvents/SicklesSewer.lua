local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local lever = require(ReplicatedStorage.CAM.Global.Training["Parkour Dungeon"].lever)
local cframe = CFrame.new(-1024.848, 825.807, 599.323)
local cframe2 = CFrame.new(-1024.848, 834.371, 582.002) * CFrame.Angles(0.7853981633974483, 0, 0)
local localPlayer = Players.LocalPlayer
local v = cleanit.new()
local v2 = {}
local v3 = {}
local v4 = cframe
local v5 = false
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function placePart(p)
	local v6 = v3[p]

	if v6 == nil then
		v6 = cframe2:Inverse() * p.CFrame
		v3[p] = v6
	end

	p.CFrame = v4 * v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lock(instance)
	if instance:GetAttribute("Item") ~= "Nightfall Sickles" then
		return
	end

	instance:SetAttribute("Locked", not v5 or nil)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unlock()
	v5 = true

	for _, v6 in CollectionService:GetTagged("StudyProp") do
		lock(v6) -- equivalent call inferred; original call site unknown
	end
end

local function animate(parent)
	if flag then
		return
	end

	flag = true
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = cframe
	cFrameValue.Changed:Connect(function(p)
		v4 = p

		for k in v3 do
			placePart(k) -- equivalent call inferred; original call site unknown
		end
	end)
	cFrameValue.Parent = parent
	local tween = TweenService:Create(
		cFrameValue,
		TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Value = cframe2
		}
	)
	tween.Completed:Once(function()
		cFrameValue:Destroy()
	end)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	if not localPlayer:GetAttribute("SicklesSewerOpen") then
		return
	end

	unlock() -- equivalent call inferred; original call site unknown
	local parent = CollectionService:GetTagged("SicklesSewerHole")[1]

	if parent ~= nil then
		animate(parent)
	end
end

local function complete(instance)
	local A_ = instance:FindFirstChild("A_")
	local color = instance:FindFirstChild("color")
	return A_ ~= nil and A_:FindFirstChild("LeverMain") ~= nil and A_:FindFirstChild("color") ~= nil and color ~= nil and color:FindFirstChild("PointLight") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function keyOf(leverMain)
	local position = leverMain.Position
	return (`{math.round(position.X * 10)},{math.round(position.Y * 10)},{math.round(position.Z * 10)}`)
end

local wire

wire = function(instance)
	if complete(instance) then
		local A_ = instance:FindFirstChild("A_")
		local v6 = keyOf(A_:FindFirstChild("LeverMain")) -- equivalent call inferred; original call site unknown

		if v2[v6] then
			A_:SetAttribute("On", true)
		end

		local configuration = Instance.new("Configuration")
		configuration:SetAttribute("Level", 0)
		lever(instance, nil, v, configuration, 0, 1)
		A_:GetAttributeChangedSignal("On"):Connect(function()
			if A_:GetAttribute("On") then
				v2[v6] = true
			end
		end)
	else
		local descendantAddedConnection = nil
		descendantAddedConnection = instance.DescendantAdded:Connect(function()
			if complete(instance) then
				descendantAddedConnection:Disconnect()
				wire(instance)
			end
		end)
	end
end

local function place(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		placePart(part) -- equivalent call inferred; original call site unknown
	end

	folder.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			placePart(part) -- equivalent call inferred; original call site unknown
		end
	end)
	folder.DescendantRemoving:Connect(function(descendant)
		v3[descendant] = nil
	end)
	update() -- equivalent call inferred; original call site unknown
end

for _, v6 in CollectionService:GetTagged("SicklesLever") do
	wire(v6)
end

CollectionService:GetInstanceAddedSignal("SicklesLever"):Connect(wire)

for _, v6 in CollectionService:GetTagged("SicklesSewerHole") do
	place(v6)
end

CollectionService:GetInstanceAddedSignal("SicklesSewerHole"):Connect(place)

for _, v6 in CollectionService:GetTagged("StudyProp") do
	lock(v6) -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("StudyProp"):Connect(lock)
localPlayer:GetAttributeChangedSignal("SicklesSewerOpen"):Connect(update)
update() -- equivalent call inferred; original call site unknown