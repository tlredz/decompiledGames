local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local v = string.match(SettingsKeys.KeybindRoot, "[^/]+$")
local v2 = string.match(SettingsKeys.PadKeybindRoot, "[^/]+$")
local v3 = {}
local v4 = {}

local function codeOf(value)
	if type(value) ~= "string" then
		return nil
	end

	local success, result = pcall(function()
		return Enum.KeyCode[value]
	end)

	if success then
		return result
	end

	return nil
end

local function keyOf(valueBase)
	if not valueBase:IsA("ValueBase") then
		return nil, nil
	end

	local value = valueBase.Value

	if typeof(value) ~= "string" then
		return nil, nil
	end

	local v5, v6 = string.match(value, "^(.-)%" .. SettingsKeys.PadChordSeparator .. "(.+)$")

	if v5 == nil then
		v5 = value
	end

	local result

	if type(v5) == "string" then
		local success
		success, result = pcall(function()
			return Enum.KeyCode[v5]
		end)

		if not success then
			result = nil
		end
	end

	local result2

	if not (v6 == nil or type(v6) ~= "string") then
		local success
		success, result2 = pcall(function()
			return Enum.KeyCode[v6]
		end)

		if not success then
			result2 = nil
		end
	end

	if result == nil or v6 ~= nil and result2 == nil then
		return nil, nil
	end

	if SettingsKeys.IsBindable(result, result2) then
		return result, result2
	end

	return nil, nil
end

local function apply(instance)
	local v5 = {}

	if instance ~= nil then
		for _, child in instance:GetChildren() do
			local name = child.Name

			if not SettingsKeys.IsEditable(name) then
				continue
			end

			local v6, v7 = keyOf(child)

			if v6 == nil then
				continue
			end

			v5[name] = true
			InputHandler.RebindKey(name, v6, v7)
		end
	end

	for k in v3 do
		if v5[k] ~= true then
			InputHandler.RebindKey(k, InputHandler.DefaultKey(k))
		end
	end

	v3 = v5
	local rebindKey = InputHandler.RebindKey
	local v7

	if InputHandler.KeyBinding("Emotes") == Enum.KeyCode.R then
		v7 = Enum.KeyCode.E
	else
		v7 = Enum.KeyCode.R
	end

	rebindKey("Emotes_Next", v7)
end

local function padKeyOf(p: string)
	local success, result = pcall(function()
		return Enum.KeyCode[p]
	end)

	if success then
		return result
	end

	return nil
end

local function padBindingOf(valueBase)
	if not valueBase:IsA("ValueBase") then
		return nil, nil
	end

	local value = valueBase.Value

	if typeof(value) ~= "string" then
		return nil, nil
	end

	local v5, v6 = string.match(value, "^(.-)%" .. SettingsKeys.PadChordSeparator .. "(.+)$")

	if v5 == nil then
		v5 = value
	end

	local success, result = pcall(function()
		return Enum.KeyCode[v5]
	end)

	if not success then
		result = nil
	end

	local result2

	if v6 ~= nil then
		local success2
		success2, result2 = pcall(function()
			return Enum.KeyCode[v6]
		end)

		if not success2 then
			result2 = nil
		end
	end

	if result == nil or v6 ~= nil and result2 == nil then
		return nil, nil
	end

	if SettingsKeys.IsPadBindable(result, result2) then
		return result, result2
	end

	return nil, nil
end

local function applyPad(instance)
	local v5 = {}

	if instance ~= nil then
		for _, child in instance:GetChildren() do
			local name = child.Name

			if not SettingsKeys.IsEditable(name) then
				continue
			end

			local v6, v7 = padBindingOf(child)

			if v6 == nil then
				continue
			end

			v5[name] = true
			InputHandler.RebindPad(name, v6, v7)
		end
	end

	for k in v4 do
		if v5[k] ~= true then
			InputHandler.RebindPad(k, InputHandler.PadDefault(k))
		end
	end

	v4 = v5
end

local _, v5 = Utility.GetData(Players.LocalPlayer, true)

if v5 == nil then
	return
end

local settings = v5:WaitForChild("Settings", 30)

if settings == nil then
	return
end

local function watch(child, callback)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function reread()
		local v7

		if child.Parent ~= nil then
			v7 = child
		end

		callback(v7)
	end

	child.ChildAdded:Connect(function(valueBase)
		reread() -- equivalent call inferred; original call site unknown

		if valueBase:IsA("ValueBase") then
			valueBase:GetPropertyChangedSignal("Value"):Connect(reread)
		end
	end)
	child.ChildRemoved:Connect(reread)
	child.Destroying:Connect(function()
		callback(nil)
	end)

	for _, valueBase in child:GetChildren() do
		if valueBase:IsA("ValueBase") then
			valueBase:GetPropertyChangedSignal("Value"):Connect(reread)
		end
	end

	callback(child)
end

local v6 = {
	[v] = apply,
	[v2] = applyPad
}
settings.ChildAdded:Connect(function(child)
	local v7 = v6[child.Name]

	if v7 ~= nil then
		watch(child, v7)
	end
end)

for childName, v7 in v6 do
	local child = settings:FindFirstChild(childName)

	if child ~= nil then
		watch(child, v7)
	end
end