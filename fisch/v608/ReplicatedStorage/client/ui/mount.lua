local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
require(script.Parent.apps.region)
local serverInfo = require(script.Parent.apps.serverInfo)
require(script.Parent.apps.menu)
require(script.Parent.apps.topbar)
local state = require(script.Parent.state)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
assert(playerGui:IsA("PlayerGui"), "playergui is not playergui?")

local function wrap(callback)
	return vide.create("ScreenGui")({
		ResetOnSpawn = false,
		Enabled = function()
			return not state.cinematic()
		end,
		callback()
	})
end

return function()
	vide.mount(function()
		return { serverInfo() }
	end, playerGui)
end