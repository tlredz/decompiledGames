local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
local testGameWarn = nil
local RunService2 = game:GetService("RunService")

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	task.spawn(function()
		repeat
			task.wait()
			local Global = require(game.ReplicatedStorage.Global)
		until Global.TestGameWarn

		if RunService:IsServer() then
			local Global = require(game.ReplicatedStorage.Global)
			testGameWarn = Global.TestGameWarn
		elseif RunService:IsClient() then
			local Global = require(game.ReplicatedStorage.Global)
			testGameWarn = Global.TestGamePrint
		end
	end)
end

local function VerifyAccessoryAddedCorrectly(p, instance)
	local parent = p.Parent

	if not parent then
		error("Humanoid has no parent. " .. debug.traceback())
	end

	local handle = instance:FindFirstChild("Handle")

	if instance.Parent ~= parent then
		testGameWarn("Accessory failed to parent correctly: " .. debug.traceback())
		return
	end

	if not (handle and handle:IsA("BasePart") and handle:IsDescendantOf(workspace)) then
		testGameWarn("Handle not found or not a BasePart or not a descendant of workspace: " .. debug.traceback())
		return
	end

	local v = nil

	for _, descendant in ipairs(parent:GetDescendants()) do
		if descendant.ClassName ~= "Weld" then
			continue
		end

		local part0 = descendant.Part0
		local part1 = descendant.Part1

		if not (part0 == handle or part1 == handle) then
			continue
		end

		if part0 == handle then
			part0 = part1 or part0
		end

		if part0 and parent and part0:IsDescendantOf(parent) then
			local enabled = descendant.Enabled == true
			local active = descendant.Active == true

			if enabled and active then
				return true
			end

			testGameWarn("Weld found but not Enabled/Active: Enabled=" .. tostring(descendant.Enabled) .. ", Active=" .. tostring(descendant.Active) .. " " .. debug.traceback())
			v = nil
		else
			testGameWarn("Weld found but other part not a descendant of character: " .. debug.traceback())
			v = nil
		end

		if v then
			break
		end
	end

	if not v then
		testGameWarn("No valid weld found attaching the handle to character: " .. debug.traceback())
	end
end

return VerifyAccessoryAddedCorrectly