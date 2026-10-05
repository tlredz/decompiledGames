local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)

local function keyHolders(p, p2, p3: string)
	local names = {}

	for _, keybind in SettingsKeys.Keybinds do
		if keybind.Name == p3 then
			continue
		end

		local keyBinding, v = InputHandler.KeyBinding(keybind.Name)

		if keyBinding == p and v == p2 then
			table.insert(names, keybind.Name)
		end
	end

	return names
end

local function padHolders(p, p2, p3: string)
	local names = {}

	for _, keybind in SettingsKeys.Keybinds do
		if keybind.Name == p3 then
			continue
		end

		local padBinding, v = InputHandler.PadBinding(keybind.Name)

		if padBinding == p and v == p2 then
			table.insert(names, keybind.Name)
		end
	end

	return names
end

local function write(p: string, p2, p3)
	local defaultKey = InputHandler.DefaultKey(p)

	if p2 == nil or p2 == defaultKey and p3 == nil then
		SignalEvent.ToServer("Keybind", p)
		return
	end

	local toServer = SignalEvent.ToServer
	local name = p2.Name
	local v2

	if p3 ~= nil then
		v2 = p3.Name
	end

	toServer("Keybind", p, name, v2)
end

local Keybinding = {
	Record = function(p: string, p2, p3)
		if not (SettingsKeys.IsEditable(p) and SettingsKeys.IsBindable(p2, p3)) then
			return false
		end

		local keyBinding, v = InputHandler.KeyBinding(p)

		if keyBinding == p2 and v == p3 then
			return true
		end

		for k, v2 in keyHolders(p2, p3, p) do
			if k == 1 then
				write(v2, keyBinding, v)
			else
				InputHandler.DefaultKey(v2)
				SignalEvent.ToServer("Keybind", v2)
			end
		end

		write(p, p2, p3)
		return true
	end
}

local function writePad(p: string, p2, p3)
	local padDefault, v = InputHandler.PadDefault(p)

	if p2 == nil or p2 == padDefault and p3 == v then
		SignalEvent.ToServer("PadKeybind", p)
		return
	end

	local toServer = SignalEvent.ToServer
	local name = p2.Name
	local v3

	if p3 ~= nil then
		v3 = p3.Name
	end

	toServer("PadKeybind", p, name, v3)
end

function Keybinding.RecordPad(p: string, p2, p3)
	if not (SettingsKeys.IsEditable(p) and SettingsKeys.IsPadBindable(p2, p3)) then
		return false
	end

	local padBinding, v = InputHandler.PadBinding(p)

	if padBinding == p2 and v == p3 then
		return true
	end

	for k, v2 in padHolders(p2, p3, p) do
		if k == 1 then
			writePad(v2, padBinding, v)
		else
			local _, _ = InputHandler.PadDefault(v2)
			SignalEvent.ToServer("PadKeybind", v2)
		end
	end

	writePad(p, p2, p3)
	return true
end

return Keybinding