local Players = game:GetService("Players")
local Net = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"))
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local remoteEvent = Net:RemoteEvent("MomentEventStage")
local remoteFunction = Net:RemoteFunction("RequestMomentEventStages")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local version = 0
local v3 = nil
local v4 = nil
local bossPrimedChangedConnection = nil

local function isPrimed(p)
	local parent = p and p.Parent
	return parent ~= nil and parent:GetAttribute("BossPrimed") == true
end

local function stagedRoot()
	local currentLocation = localPlayer:GetAttribute("CurrentLocation")

	if typeof(currentLocation) ~= "string" or not v[currentLocation] then
		return nil
	end

	local v5 = v2[currentLocation]

	if v5 and v5.Parent then
		return v5
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopSound()
	local v5 = v3
	v3 = nil

	if v5 then
		Util.Sound:FadeOut(v5, 1.5)
	end
end

local refresh

refresh = function()
	local currentLocation = localPlayer:GetAttribute("CurrentLocation")
	local v5

	if typeof(currentLocation) == "string" and v[currentLocation] then
		v5 = v2[currentLocation]

		if not (v5 and v5.Parent) then
			v5 = nil
		end
	end

	if v5 ~= v4 then
		local connection = bossPrimedChangedConnection
		bossPrimedChangedConnection = nil

		if connection then
			connection:Disconnect()
		end

		v4 = v5
		local parent = v5 and v5.Parent

		if parent then
			bossPrimedChangedConnection = parent:GetAttributeChangedSignal("BossPrimed"):Connect(function()
				refresh()
			end)
		end
	end

	if v5 then
		local parent = v5 and v5.Parent
		local v6

		if parent == nil then
			v6 = false
		else
			v6 = parent:GetAttribute("BossPrimed") == true
		end

		if v6 then
			if v3 then
				return
			end

			v3 = Util.Sound:Play("Lazy.BossPrimedLoop", v5, {
				volume = 0.45,
				fadeIn = 1.5,
				radius = 17.5
			})
			return
		end
	end

	stopSound() -- equivalent call inferred; original call site unknown
end

remoteEvent.OnClientEvent:Connect(function(value: string, flag: boolean, value2: number, part)
	if typeof(value) ~= "string" or typeof(value2) ~= "number" or value2 < version then
		return
	end

	version = value2

	if flag then
		v[value] = true
		local v5 = v2

		if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
			part = nil
		end

		v5[value] = part
	else
		v[value] = nil
		v2[value] = nil
	end

	refresh()
end)
localPlayer:GetAttributeChangedSignal("CurrentLocation"):Connect(refresh)
local success, result = pcall(function()
	return remoteFunction:InvokeServer()
end)

if success and typeof(result) == "table" and typeof(result.Version) == "number" and typeof(result.Islands) == "table" and version <= result.Version then
	version = result.Version
	table.clear(v)
	table.clear(v2)

	for k, island in result.Islands do
		if typeof(k) == "string" and island == true then
			v[k] = true
		end
	end

	if typeof(result.Roots) == "table" then
		for k, part in result.Roots do
			if not (typeof(k) == "string" and typeof(part) == "Instance" and part:IsA("BasePart")) then
				continue
			end

			v2[k] = part
		end
	end
end

refresh()