local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TextChatService")
game:GetService("TextService")
local StarwatchController = {}
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local RemoteConfig = require(ReplicatedStorage.Modules.Shared.RemoteConfig)
local maid = Janitor.new()
local flag = false

function StarwatchController.FrameworkInit() end

function StarwatchController.StopTracking()
	if not flag then
		return
	end

	flag = false
	maid:Cleanup()
	local starwatchshared = require(ReplicatedStorage.Packages["starwatch-shared"])
	starwatchshared.Client.StarwatchClient.pause()
end

function StarwatchController.StartTracking()
	local starwatchshared = require(ReplicatedStorage.Packages["starwatch-shared"])
	local starwatchClient = starwatchshared.Client.StarwatchClient

	if flag then
		starwatchClient.resume()
		return
	end

	flag = true
	starwatchClient.init()
	local localPlayer = Players.LocalPlayer

	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid", 60)

		if not humanoid then
			return
		end

		maid:Add(humanoid.Died:Connect(function()
			starwatchClient.submitEvent("Death")
		end))
		maid:Add(humanoid.FallingDown:Connect(function()
			starwatchClient.submitEvent("FallingDown")
		end))
		maid:Add(humanoid.Jumping:Connect(function(p)
			if not p then
				return
			end

			starwatchClient.submitEvent("Jump")
		end))
		maid:Add(humanoid.Seated:Connect(function(p, _)
			if p then
				starwatchClient.submitEvent("Seated")
			else
				starwatchClient.submitEvent("Unseated")
			end
		end))
	end

	maid:Add(localPlayer.CharacterAdded:Connect(function(character)
		onCharacterAdded(character)
	end))

	if localPlayer.Character then
		onCharacterAdded(localPlayer.Character)
	end
end

function StarwatchController.FrameworkStart()
	local v, v2 = RemoteConfig.getLiveOpsPath("Starwatch/Config"):await()

	if v then
		if not (v2 and v2.isEnabled and game.Players.LocalPlayer.UserId % 100 < v2.rampPercentage) then
			return
		end

		local total = 0
		RunService.Stepped:Connect(function(_: number, dt: number)
			total += dt

			if total < 5 then
				return
			end

			total = 0
			local starwatchEnabled = workspace:GetAttribute("StarwatchEnabled")

			if starwatchEnabled and starwatchEnabled == false and flag then
				StarwatchController.StopTracking()
			end
		end)
		StarwatchController.StartTracking()
	else
		if RunService:IsStudio() then
			return
		end

		error("[StarwatchController] Failed to load Starwatch config: " .. tostring(v2))
	end
end

return StarwatchController