local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ExperienceNotificationService = game:GetService("ExperienceNotificationService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Promise)
local remoteEvent = v:RemoteEvent("RequestPromptOptIn")
local remoteFunction = v:RemoteFunction("ClientPromptOptInResult")
local promisify = v2.promisify(function()
	return ExperienceNotificationService:CanPromptOptInAsync()
end)
local ExperienceNotificationController = {}

function ExperienceNotificationController.Start(_)
	remoteEvent.OnClientEvent:Connect(function()
		ExperienceNotificationController:PromptOptIn():catch(warn)
	end)
end

function ExperienceNotificationController:PromptOptIn()
	return v2.retryWithDelay(promisify, 3, 1):andThen(function(p)
		if not p then
			warn("The player cannot be prompted.")
			return v2.resolve(true)
		end

		local success, _ = pcall(ExperienceNotificationService.PromptOptIn, ExperienceNotificationService)

		if success then
			return v2.resolve(true)
		end

		return v2.resolve(false)
	end):andThen(function(p)
		if remoteFunction:InvokeServer(p) then
			return v2.resolve()
		end

		return v2.reject("Failed to give reward!")
	end)
end

return ExperienceNotificationController