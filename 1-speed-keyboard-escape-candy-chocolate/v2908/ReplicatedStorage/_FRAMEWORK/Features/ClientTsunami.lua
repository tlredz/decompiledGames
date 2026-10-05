local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = {}
local localPlayer = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function killLocalPlayer()
	local character

	if localPlayer then
		character = localPlayer.Character
	end

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end
end

local function checkTsunamiReady(model)
	if not model:IsA("Model") then
		return false, nil, "ClientTsunamiModel tag must be on a Model"
	end

	local tsunami = model:FindFirstChild("Tsunami")
	local tsunamiSpawn = model:FindFirstChild("TsunamiSpawn")
	local tsunamiEnd = model:FindFirstChild("TsunamiEnd")

	if not (tsunami and tsunamiSpawn and tsunamiEnd) then
		return false, nil, "ClientTsunamiModel is missing Tsunami, TsunamiSpawn, or TsunamiEnd"
	end

	local speed = model:GetAttribute("Speed") or 70
	local magnitude = (tsunamiEnd.Position - tsunamiSpawn.Position).Magnitude

	if typeof(speed) ~= "number" or speed <= 0 or magnitude <= 0 then
		return false, nil, "ClientTsunamiModel has invalid Speed or zero travel distance"
	end

	local timer = model:FindFirstChild("Timer", true)
	local v4 = {
		union = tsunami,
		startCF = tsunamiSpawn.CFrame,
		endCF = tsunamiEnd.CFrame,
		travelTime = magnitude / speed,
		label = 0
	}

	if not (timer and timer:IsA("TextLabel")) then
		timer = nil
	end

	v4.label = timer
	return true, v4, ""
end

local function applyTsunamiSetup(p, data)
	data.union.CanTouch = true
	local touchedConnection = data.union.Touched:Connect(function(otherPart)
		local character

		if localPlayer then
			character = localPlayer.Character
		end

		if character and otherPart:IsDescendantOf(character) then
			killLocalPlayer() -- equivalent call inferred; original call site unknown
		end
	end)
	local janitor = Janitor.new()
	janitor:Add(touchedConnection)
	v[p] = {
		union = data.union,
		startCF = data.startCF,
		endCF = data.endCF,
		travelTime = data.travelTime,
		label = data.label,
		janitor = janitor
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardownTsunami(k)
	local v3 = v[k]

	if v3 then
		v3.janitor:Destroy()
		v[k] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupTsunami(p)
	if v[p] == nil then
		local v3, v4, v5 = checkTsunamiReady(p)

		if v3 and v4 then
			applyTsunamiSetup(p, v4)
		else
			logger:warn(v5)
		end
	end
end

local function updateTsunamis()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v3 in v do
		if k.Parent then
			local v4 = serverTimeNow % v3.travelTime
			v3.union.CFrame = v3.startCF:Lerp(v3.endCF, v4 / v3.travelTime)

			if v3.label then
				v3.label.Text = string.format("%.1f", v3.travelTime - v4)
			end
		else
			teardownTsunami(k) -- equivalent call inferred; original call site unknown
		end
	end
end

local function startClient()
	localPlayer = Players.LocalPlayer

	for _, v3 in CollectionService:GetTagged("ClientTsunamiModel") do
		setupTsunami(v3) -- equivalent call inferred; original call site unknown
	end

	local connection = CollectionService:GetInstanceAddedSignal("ClientTsunamiModel"):Connect(setupTsunami)
	local connection2 = CollectionService:GetInstanceRemovedSignal("ClientTsunamiModel"):Connect(teardownTsunami)
	v2 = Janitor.new()
	v2:Add(connection)
	v2:Add(connection2)
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			startClient()
		end
	end,
	OnUpdate = function()
		if RunService:IsClient() then
			updateTsunamis()
		end
	end
})
return {}