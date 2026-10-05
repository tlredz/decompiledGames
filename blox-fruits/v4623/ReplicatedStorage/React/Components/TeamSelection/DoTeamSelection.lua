local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parentModule = require(script.Parent)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local v = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function clean()
	if v then
		v:unmount()
		v = nil
	end

	if v2 then
		v2:Destroy()
		v2 = nil
	end
end

task.spawn(function()
	repeat
		task.wait()
	until Players.LocalPlayer.Character

	clean() -- equivalent call inferred; original call site unknown
end)
return function()
	local createElement = React.createElement

	local function rootComponent()
		return createElement(parentModule, {})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeamSelection"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local frame = Instance.new("Frame")
	frame.Name = "ROOT"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Parent = screenGui
	screenGui.Parent = playerGui
	local root = ReactRoblox.createRoot(screenGui:WaitForChild("ROOT"))
	v = root
	v2 = screenGui
	root:render(React.createElement(rootComponent, {}))
end