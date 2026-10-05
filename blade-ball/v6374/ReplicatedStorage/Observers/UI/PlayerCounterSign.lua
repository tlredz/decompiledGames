local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local Signal = require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Packages.Replion)
local UseNewLobby = require(ReplicatedStorage.Shared.UseNewLobby)
local alive = workspace.Alive

local function infiniteYieldForChild(instance, childName: string)
	local child = instance:FindFirstChild(childName)

	if child then
		return child
	end

	local v = Signal.new()
	task.defer(function()
		v:Fire((instance:WaitForChild(childName, 10000)))
	end)
	child = v:Wait()
	v:Destroy()
	return child
end

return Observers.observeTagNoAncestry("UI_PlayerCounterSign", function(instance)
	local maid = Utils.Maid.new()
	workspace:WaitForChild("Spawn")
	local text, text2, text3

	if UseNewLobby() and instance.Name == "NewPlayerCounter" then
		local bottom = infiniteYieldForChild(instance, "GUI"):WaitForChild("SurfaceGui"):WaitForChild("Bottom")
		text = bottom:WaitForChild("Server"):WaitForChild("Text")
		text2 = bottom:WaitForChild("Alive"):WaitForChild("Text")
		text3 = bottom:WaitForChild("Playing"):WaitForChild("Text")
	else
		text = infiniteYieldForChild(instance, "InServer"):WaitForChild("SurfaceGui"):WaitForChild("rats"):WaitForChild("Common")
		text2 = infiniteYieldForChild(instance, "Alive"):WaitForChild("SurfaceGui"):WaitForChild("rats"):WaitForChild("Common")
		text3 = infiniteYieldForChild(instance, "Playing"):WaitForChild("SurfaceGui"):WaitForChild("rats"):WaitForChild("Common")
	end

	local function count()
		local count2 = #Players:GetPlayers()
		local v = #alive:GetChildren()
		local v2 = count2 - (workspace:GetAttribute("AFK_Players") or 0)
		text.Text = string.format("IN SERVER: %s", (tostring(count2)))
		text2.Text = string.format("ALIVE: %s", (tostring(v)))
		text3.Text = string.format("PLAYING: %s", (tostring(v2)))
	end

	task.defer(function()
		while instance.Parent do
			count()
			task.wait(1)
		end
	end)
	return function()
		maid:Destroy()
	end
end)