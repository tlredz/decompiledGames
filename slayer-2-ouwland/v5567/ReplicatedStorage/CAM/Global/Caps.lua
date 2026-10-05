local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Clans = require(ReplicatedStorage.CAM.Clans)
local Caps = {}
local v = {
	["Max Level"] = function()
		return gameSettings.maxLevel
	end,
	["Max Mastery"] = function()
		return gameSettings.maxMastery
	end
}
Caps.Keys = table.freeze({ "Max Level", "Max Mastery" })

function Caps.MasteryKey(p: string)
	return "Max Mastery" .. ":" .. p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function baseKeyOf(value: string)
	if string.sub(value, 1, 12) == "Max Mastery:" then
		return "Max Mastery"
	end

	return value
end

local function clanOf(instance)
	local clan = instance ~= nil and instance:FindFirstChild("Clan") or nil
	return clan ~= nil and Clans.GetClan(clan.Value) or nil
end

local function unlockValue(instance, childName: string)
	local capUnlocks

	if instance ~= nil then
		capUnlocks = instance:FindFirstChild("CapUnlocks") or nil
	end

	local valueBase = capUnlocks ~= nil and capUnlocks:FindFirstChild(childName) or nil

	if valueBase == nil or not valueBase:IsA("ValueBase") or typeof(valueBase.Value) ~= "number" then
		return 0
	end

	return valueBase.Value
end

function Caps.Get(p, value: string)
	local v2 = v[baseKeyOf(value)]

	if v2 == nil then
		error((`Caps: unknown cap "{value}"`))
	end

	local v3 = v2()
	local v4

	if p ~= nil then
		v4 = Utility.GetData(p) or nil
	end

	if v4 == nil then
		return v3
	end

	local total = 0
	local total2 = 0
	local clan

	if v4 ~= nil then
		clan = v4:FindFirstChild("Clan") or nil
	end

	local v5

	if clan ~= nil then
		v5 = Clans.GetClan(clan.Value) or nil
	end

	if v5 ~= nil and v5.caps ~= nil then
		total += v5.caps[value] or 0
		total2 += v5.caps[value .. " Factor"] or 0
	end

	local v6 = total + unlockValue(v4, value)
	local v7 = total2 + unlockValue(v4, value .. " Factor")
	return (math.max(v3, (math.floor((v3 + v6) * (v7 + 1)))))
end

function Caps.Listen(p, p2: string, callback)
	local connections = {}
	local v2 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fire()
		if not v2 then
			return
		end

		callback(Caps.Get(p, p2))
	end

	task.spawn(function()
		local data = Utility.GetData(p, true)

		if not v2 or data == nil then
			return
		end

		local clan = data:FindFirstChild("Clan")

		if clan ~= nil and clan:IsA("ValueBase") then
			table.insert(connections, clan:GetPropertyChangedSignal("Value"):Connect(fire))
		end

		local function bindUnlock(valueBase)
			if not valueBase:IsA("ValueBase") or valueBase.Name ~= p2 and valueBase.Name ~= p2 .. " Factor" then
				return
			end

			table.insert(connections, valueBase:GetPropertyChangedSignal("Value"):Connect(fire))
			fire() -- equivalent call inferred; original call site unknown
		end

		local function bindFolder(instance)
			for _, child in instance:GetChildren() do
				bindUnlock(child)
			end

			table.insert(connections, instance.ChildAdded:Connect(bindUnlock))
			table.insert(connections, instance.ChildRemoved:Connect(fire))
		end

		local capUnlocks = data:FindFirstChild("CapUnlocks")

		if capUnlocks == nil then
			table.insert(connections, data.ChildAdded:Connect(function(child)
				if child.Name == "CapUnlocks" then
					bindFolder(child)
				end
			end))
		else
			bindFolder(capUnlocks)
		end

		fire() -- equivalent call inferred; original call site unknown
	end)
	return function()
		v2 = false

		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end
end

function Caps.AddUnlock(p, name: string, p2: number)
	if not RunService:IsServer() then
		error("Caps.AddUnlock is server-only")
	end

	local v2

	if string.sub(name, -7) == " Factor" then
		v2 = string.sub(name, 1, -8)
	else
		v2 = name
	end

	if v[baseKeyOf(v2)] == nil then
		error((`Caps: unknown cap "{name}"`))
	end

	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	local parent = data:FindFirstChild("CapUnlocks")

	if parent == nil then
		parent = Instance.new("Configuration")
		parent.Name = "CapUnlocks"
		parent.Parent = data
	end

	local v4 = parent:FindFirstChild(name)

	if v4 == nil then
		v4 = Instance.new("NumberValue")
		v4.Name = name
		v4.Parent = parent
	end

	v4.Value += p2
end

return Caps