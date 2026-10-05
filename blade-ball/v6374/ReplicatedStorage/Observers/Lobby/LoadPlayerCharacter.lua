local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local NPCLobbyAnimation = require(ReplicatedStorage.Shared.LobbyLimitedSwords.NPCLobbyAnimation)
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local v = false
local flag = false
local v2 = nil
local threads = {}

local function getLocalDescription()
	if flag then
		return v2
	end

	if not v then
		v = true
		task.spawn(function()
			for i = 1, 5 do
				local success, humanoidDescriptionFromUserId = pcall(
					Players.GetHumanoidDescriptionFromUserId,
					Players,
					localPlayer.UserId
				)

				if success and humanoidDescriptionFromUserId then
					v2 = humanoidDescriptionFromUserId
					break
				else
					task.wait((math.min(2 ^ i * 0.25, 2)))
				end
			end

			flag = true

			for _, callback in threads do
				task.spawn(callback)
			end

			table.clear(threads)
		end)
	end

	table.insert(threads, coroutine.running())
	coroutine.yield()
	return v2
end

local function playTween(...)
	local tween = TweenService:Create(...)
	tween.Completed:Once(function()
		tween:Destroy()
		tween = nil
	end)
	tween:Play()
	return tween
end

local function fadeIn(clone, tweenInfo)
	for _, v3 in clone:QueryDescendants("BasePart"), nil, nil do
		local transparency = v3.Transparency
		v3.Transparency = 1
		playTween(v3, tweenInfo, {
			Transparency = transparency
		})
	end
end

local function fadeOut(stand, tweenInfo)
	for _, v3 in stand:QueryDescendants("BasePart"), nil, nil do
		playTween(v3, tweenInfo, {
			Transparency = 1
		})
	end
end

return Observers.observeTagNoAncestry("LoadPlayerCharacter", function(instance)
	FFlagClient:WaitForData()
	local key = FFlagClient:GetKey("LimitedQuantityDropTimestamp")
	local nPCStudio = instance:WaitForChild("NPCStudio", 5)

	if not nPCStudio then
		return
	end

	task.spawn(getLocalDescription)
	task.wait(2)
	local clone = nPCStudio:Clone()
	clone.Name = "NPC"
	clone.Parent = nPCStudio.Parent
	nPCStudio:Destroy()
	local pivot = clone:GetPivot()
	task.defer(function()
		local localDescription = getLocalDescription()

		if localDescription and clone.Parent then
			local success, result = pcall(function()
				clone.Humanoid:ApplyDescription(localDescription)
			end)

			if not success then
				warn("[LoadPlayerCharacter] ApplyDescription falhou:", result)
			end
		end

		if clone.Parent then
			xpcall(NPCLobbyAnimation, warn, clone)
		end
	end)
	local stand = instance.Parent.Parent:WaitForChild("Stand")
	local pivot2 = stand:GetPivot()

	if not key then
		return nil
	end

	if key < 0 then
		key = workspace:GetServerTimeNow()
	end

	if key <= workspace:GetServerTimeNow() then
		stand:Destroy()
		local clone2 = script:WaitForChild("NewStand"):Clone()
		clone2:PivotTo(pivot2)
		clone2.Parent = instance.Parent.Parent
	else
		if key - workspace:GetServerTimeNow() > 310 then
			local v3 = key - 300
			task.wait(v3 - workspace:GetServerTimeNow())
			fadeOut(stand, TweenInfo.new(5))
			task.delay(5, function()
				stand:Destroy()
			end)
		else
			stand:Destroy()
		end

		clone:PivotTo(CFrame.new(10000, 0, 10000))
		local v3 = key - workspace:GetServerTimeNow()

		if v3 > 0 then
			task.wait(v3)
		end

		local clone2 = script:WaitForChild("NewStand"):Clone()
		clone2:PivotTo(pivot2)
		fadeIn(clone2, TweenInfo.new(5))
		clone2.Parent = instance.Parent.Parent
		task.wait(5)
		clone:PivotTo(pivot)
	end

	return nil
end)