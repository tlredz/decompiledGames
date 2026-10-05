local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local _ = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
local Trove = require(ReplicatedStorage.Packages.Trove)

local function tweenGroupTransparency(allGroup, transparency: number, duration: number)
	for _, item in pairs(allGroup) do
		TweenService:Create(item, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
			Transparency = transparency
		}):Play()
	end
end

local function startGroupController()
	if workspace:GetAttribute("GroupFader") then
		return
	end

	workspace:SetAttribute("GroupFader", true)

	local function getAllGroups()
		local result = {}

		for _, model in pairs(workspace.Map:GetDescendants()) do
			if not (model:IsA("Model") and model.Name == "MonsterSilhouettes") then
				continue
			end

			local parts = {}

			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") and (part.Name == "Silho_Left" or part.Name == "Silho_Right") then
					table.insert(parts, part)
				end
			end

			if #parts > 0 then
				table.insert(result, parts)
			end
		end

		return result
	end

	task.spawn(function()
		Random.new()
		local allGroups = getAllGroups()
		local v = 1

		for i, allGroup in ipairs(allGroups) do
			for _, v2 in allGroup do
				v2.Transparency = i == v and 0 or 1
			end
		end

		while true do
			local allGroup = allGroups[v]
			task.wait(5)
			tweenGroupTransparency(allGroup, 1, 0.5)
			task.wait(0.5)
			local v2 = v + 1
			v = #allGroups < v2 and 1 or v2
			tweenGroupTransparency(allGroups[v], 0, 0.5)
			task.wait(0.5)
		end
	end)
end

return Observers.observeTag("AnimatedSilhouette", function(instance)
	local maid = Trove.new()
	local random = Random.new()
	startGroupController()
	local speed = instance:GetAttribute("Speed") or 10
	local maxAngle = instance:GetAttribute("MaxAngle") or 10
	local minAngle = instance:GetAttribute("MinAngle") or -10
	local cFrame = instance.CFrame
	local v = 1
	local v2 = 0
	maid:Add(task.spawn(function()
		while instance.Parent and instance:IsDescendantOf(workspace.Map) do
			local v3

			if v == 1 then
				v3 = maxAngle
			else
				v3 = minAngle
			end

			local number = random:NextNumber(v3 * 0.25, v3)
			local v4 = math.abs((v2 - number) / speed)
			maid:Add(FastUtils.fastTween(instance, TweenInfo.new(v4, Enum.EasingStyle.Sine), {
				CFrame = cFrame * CFrame.Angles(0, 0, (math.rad(number)))
			}))
			local number2 = random:NextNumber(0, 0.25)
			task.wait(v4 - number2)
			v2 = number
			v *= -1
		end
	end))
	return function()
		maid:Destroy()
	end
end, { workspace.Map })