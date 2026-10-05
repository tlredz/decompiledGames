local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
local state = require(script.Parent.Parent.state)
return function(list)
	local v = {
		touch = table.find(list.devices or {}, "touch") ~= nil,
		keyboard = table.find(list.devices or {}, "keyboard") ~= nil,
		controller = table.find(list.devices or {}, "controller") ~= nil
	}
	return vide.create("ScreenGui")({
		Name = list.name,
		ResetOnSpawn = false,
		IgnoreGuiInset = list.ignoreGuiInset,
		Enabled = function()
			if not list.core then
				return not state.cinematic()
			end

			if not list.devices or v.touch and state.touchscreenEnabled() or v.keyboard and state.keyboardEnabled() then
				return true
			end

			if v.controller and state.controllerEnabled() then
				return true
			end

			return false
		end,
		table.unpack(list)
	})
end