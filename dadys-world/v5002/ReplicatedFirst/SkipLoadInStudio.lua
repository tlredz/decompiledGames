local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

if not isStudio then
	return
end

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local localPlayer = Players.LocalPlayer

local function purgeLoadingScreens(instance)
	if not isStudio then
		return
	end

	for _, child in ipairs(instance:GetChildren()) do
		if not (child ~= script and child.Name == "LoadingScreen") then
			continue
		end

		local v = child
		pcall(function()
			v:Destroy()
		end)
	end
end

pcall(function()
	ReplicatedFirst:RemoveDefaultLoadingScreen()
end)
purgeLoadingScreens(ReplicatedFirst)
local playerGui = localPlayer:WaitForChild("PlayerGui", 5)

if not playerGui then
	return
end

task.spawn(function()
	local v = os.clock() + 8

	while os.clock() < v do
		if not isStudio then
			break
		end

		purgeLoadingScreens(playerGui)
		task.wait(0.1)
	end
end)