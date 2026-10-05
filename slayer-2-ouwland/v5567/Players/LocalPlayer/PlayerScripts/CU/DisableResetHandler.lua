local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local getvaluesfolder = Utility.getvaluesfolder(Players.LocalPlayer, true)
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function apply(flag: boolean)
	if v == flag then
		return
	end

	v = flag
	task.spawn(function()
		local count = 0

		while not pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", flag) do
			count += 1

			if count > 20 or v ~= flag then
				break
			else
				task.wait(0.5)
			end
		end
	end)
end

getvaluesfolder.ChildAdded:Connect(function(child)
	if not (child.Name == "DisableReset" and v ~= false) then
		return
	end

	v = false
	local v2 = false
	task.spawn(function()
		local count = 0

		while not pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", v2) do
			count += 1

			if count > 20 or v ~= v2 then
				break
			else
				task.wait(0.5)
			end
		end
	end)
end)
getvaluesfolder.ChildRemoved:Connect(function(child)
	if child.Name ~= "DisableReset" then
		return
	end

	apply(getvaluesfolder:FindFirstChild("DisableReset") == nil) -- equivalent call inferred; original call site unknown
end)
local v2 = getvaluesfolder:FindFirstChild("DisableReset") == nil

if v ~= v2 then
	v = v2
	task.spawn(function()
		local count = 0

		while not pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", v2) do
			count += 1

			if count > 20 or v ~= v2 then
				break
			else
				task.wait(0.5)
			end
		end
	end)
end