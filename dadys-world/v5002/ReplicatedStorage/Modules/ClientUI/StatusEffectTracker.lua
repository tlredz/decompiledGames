local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebuffConfig = require(ReplicatedStorage.Modules.Gameplay.DebuffConfig)
local StatusEffectController = require(ReplicatedStorage.Modules.ClientUI.StatusEffectController)
local StatusEffectTracker = {}

local function debugEnabled()
	local info = workspace:FindFirstChild("Info")
	return info ~= nil and info:GetAttribute("StatusHudDebug") == true
end

local v = {}
local localPlayer = Players.LocalPlayer
local flag = false
local v2 = nil
local v3 = {}
local v4 = true
local v5 = {}

local function debugLog(...)
	local info = workspace:FindFirstChild("Info")
	local v6

	if info == nil then
		v6 = false
	else
		v6 = info:GetAttribute("StatusHudDebug") == true
	end

	if v6 then
		print("[StatusEffectHud/Tracker]", ...)
	end
end

local function track(p)
	table.insert(v3, p)
	return p
end

local function refreshManaged(instance, p)
	local attribute = instance:GetAttribute("Debuff_" .. p .. "_EndTime")
	local attribute2 = instance:GetAttribute("Debuff_" .. p .. "_Strength")

	if type(attribute) ~= "number" then
		StatusEffectController.hide(p)
		return
	end

	local v6 = attribute - workspace:GetServerTimeNow()

	if v6 > 99999 and not v[p] then
		v[p] = true
		warn(("[StatusEffectHud/Tracker] %s reports %.0fs remaining, longer than any duration a call site passes (%d). Debuff_%s_EndTime and this read disagree about their clock -- both must use workspace:GetServerTimeNow(). Rendering as permanent."):format(
			p,
			v6,
			99999,
			p
		))
	end

	if v6 <= 0 then
		StatusEffectController.hide(p)
	else
		StatusEffectController.show(p, {
			duration = v6 <= 100 and v6 or nil,
			tier = attribute2 or 1
		})
	end
end

local function bindManaged(instance, p)
	local connection = instance:GetAttributeChangedSignal("Debuff_" .. p .. "_EndTime"):Connect(function()
		refreshManaged(instance, p)
	end)
	table.insert(v3, connection)
	local connection2 = instance:GetAttributeChangedSignal("Debuff_" .. p .. "_Strength"):Connect(function()
		refreshManaged(instance, p)
	end)
	table.insert(v3, connection2)
	refreshManaged(instance, p)
end

local function readIndicator(instance)
	local debuffStrength = instance:FindFirstChild("DebuffStrength")
	local value = debuffStrength and debuffStrength.Value or 1
	local expiresAt = instance:GetAttribute("ExpiresAt")
	local v6 = nil
	local v7

	if type(expiresAt) ~= "number" then
		return value, v7, v6
	end

	v7 = expiresAt - workspace:GetServerTimeNow()

	if v7 <= 0 or v7 > 100 then
		v7 = nil
	end

	local startedAt = instance:GetAttribute("StartedAt")

	if v7 and type(startedAt) == "number" and startedAt < expiresAt then
		v6 = expiresAt - startedAt
	end

	return value, v7, v6
end

local function recomputeIndicator(p)
	local v6 = v5[p]

	if not v6 then
		return
	end

	local count = 0
	local v7 = 0
	local v8 = nil
	local v9 = false
	local v10 = nil

	for k in pairs(v6) do
		count += 1
		local v11, v12, v13 = readIndicator(k)
		v7 = math.max(v7, v11)

		if v12 == nil then
			v9 = true
		elseif v8 == nil or v8 < v12 then
			v10 = v13
			v8 = v12
		end
	end

	if count == 0 then
		v5[p] = nil
		StatusEffectController.hide(p)
	else
		local v11 = not v9
		StatusEffectController.show(p, {
			duration = v11 and v8 or nil,
			totalDuration = v11 and v10 or nil,
			tier = math.max(v7, 1),
			stacks = DebuffConfig.Stacks(p) and count or nil
		})
	end
end

local function removeIndicator(name, stringValue)
	local v6 = v5[name]
	local v7 = v6 and v6[stringValue]

	if not v7 then
		return
	end

	for _, v8 in ipairs(v7) do
		local connection = v8
		pcall(function()
			connection:Disconnect()
		end)
	end

	v6[stringValue] = nil
	debugLog(("indicator removed: %s"):format(name))
	recomputeIndicator(name)
end

local function addIndicator(stringValue)
	if not stringValue:IsA("StringValue") then
		return
	end

	local name = stringValue.Name
	local v6 = DebuffConfig.Get(name)

	if not v6 or v6.managedByManager or not DebuffConfig.ShowsInStatusHud(name) then
		return
	end

	local connectionsByStringValue = v5[name]

	if not connectionsByStringValue then
		connectionsByStringValue = {}
		v5[name] = connectionsByStringValue
	end

	if connectionsByStringValue[stringValue] then
		return
	end

	local connections = {}
	connectionsByStringValue[stringValue] = connections
	table.insert(connections, stringValue:GetAttributeChangedSignal("ExpiresAt"):Connect(function()
		recomputeIndicator(name)
	end))
	local debuffStrength = stringValue:FindFirstChild("DebuffStrength")

	if debuffStrength then
		table.insert(connections, debuffStrength:GetPropertyChangedSignal("Value"):Connect(function()
			recomputeIndicator(name)
		end))
	end

	table.insert(connections, stringValue.Destroying:Connect(function()
		removeIndicator(name, stringValue)
	end))
	debugLog(("indicator added: %s"):format(name))
	recomputeIndicator(name)
end

local function refreshAll()
	if not v4 then
		return
	end

	local v6 = v2

	if not v6 then
		return
	end

	for _, v7 in ipairs(DebuffConfig.GetStatusHudNames()) do
		local v8 = DebuffConfig.Get(v7)

		if v8 and v8.managedByManager then
			refreshManaged(v6, v7)
		end
	end

	for k in pairs(v5) do
		recomputeIndicator(k)
	end

	debugLog("re-pushed active effects after the HUD came back")
end

function StatusEffectTracker.unbind()
	for _, v6 in ipairs(v3) do
		local connection = v6
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(v3)

	for _, v6 in pairs(v5) do
		for _, list in pairs(v6) do
			for _, v7 in ipairs(list) do
				local connection = v7
				pcall(function()
					connection:Disconnect()
				end)
			end
		end
	end

	table.clear(v5)
	v2 = nil
	StatusEffectController.clear()
end

function StatusEffectTracker.bind(instance)
	if not (instance and v4 and v2 ~= instance) then
		return
	end

	StatusEffectTracker.unbind()
	v2 = instance

	for _, v6 in ipairs(DebuffConfig.GetStatusHudNames()) do
		if DebuffConfig.Get(v6).managedByManager then
			bindManaged(instance, v6)
		end
	end

	local childAddedConnection = instance.ChildAdded:Connect(addIndicator)
	table.insert(v3, childAddedConnection)
	local childRemovedConnection = instance.ChildRemoved:Connect(function(stringValue)
		if stringValue:IsA("StringValue") then
			removeIndicator(stringValue.Name, stringValue)
		end
	end)
	table.insert(v3, childRemovedConnection)

	for _, child in ipairs(instance:GetChildren()) do
		addIndicator(child)
	end

	debugLog(("bound to %s"):format(instance.Name))
end

function StatusEffectTracker.setEnabled(p)
	local v6 = p == true

	if v4 == v6 then
		return
	end

	v4 = v6

	if v4 then
		debugLog("enabled by setting")

		if localPlayer and localPlayer.Character then
			StatusEffectTracker.bind(localPlayer.Character)
		end
	else
		StatusEffectTracker.unbind()
		debugLog("disabled by setting - unbound")
	end
end

function StatusEffectTracker.start()
	if not localPlayer then
		warn("[StatusEffectHud/Tracker] start() is client-only")
		return
	end

	if flag then
		return
	end

	flag = true
	StatusEffectController.onAvailable(refreshAll)
	localPlayer.CharacterAdded:Connect(function(character)
		StatusEffectTracker.bind(character)
	end)
	localPlayer.CharacterRemoving:Connect(function()
		StatusEffectTracker.unbind()
	end)

	if localPlayer.Character then
		StatusEffectTracker.bind(localPlayer.Character)
	end
end

return StatusEffectTracker