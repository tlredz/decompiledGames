local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraAuthority = require(ReplicatedStorage.SharedUtils.CameraAuthority)
local CameraController = require(ReplicatedStorage.SharedUtils.CameraController)
local Network = require(ReplicatedStorage.SharedUtils.Network)
local localPlayer = Players.LocalPlayer
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseRotationGate()
	pcall(CameraAuthority.setRotationEnabled, "BrushaMinigame", true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function acquirePromptMute()
	local success, result = pcall(function()
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		local clientUI = modules and modules:FindFirstChild("ClientUI")
		local generatorUIController = clientUI and clientUI:FindFirstChild("GeneratorUIController")

		if not generatorUIController then
			return nil
		end

		local module = require(generatorUIController)
		return module.SuppressPrompts and module.SuppressPrompts()
	end)

	if success then
		return typeof(result) == "function" and result or nil
	end

	warn("[BrushaMinigameClient] prompt mute unavailable:", result)
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releasePromptMute(p)
	local promptRelease = p.promptRelease

	if not promptRelease then
		return
	end

	p.promptRelease = nil
	pcall(promptRelease)
end

local function failsafeRelease(abortReason)
	local v2 = v

	if not v2 then
		return
	end

	v2.aborted = true
	v2.abortReason = abortReason

	if v2.minigame and v2.minigame.interrupt then
		pcall(v2.minigame.interrupt, v2, abortReason)
	end

	releasePromptMute(v2) -- equivalent call inferred; original call site unknown
	pcall(function()
		CameraController:UnlockOrientation()
	end)
	releaseRotationGate() -- equivalent call inferred; original call site unknown
end

local function getEngine()
	local modules = ReplicatedStorage:FindFirstChild("Modules")
	local gameplay = modules and modules:FindFirstChild("Gameplay")
	local brushaAbility = gameplay and gameplay:FindFirstChild("BrushaAbility")

	if not brushaAbility then
		warn("[BrushaMinigameClient] BrushaAbility module not found")
		return nil
	end

	local success, result = pcall(require, brushaAbility)

	if success then
		return result
	end

	warn("[BrushaMinigameClient] BrushaAbility failed to load:", result)
	return nil
end

Network:AddAction("BrushaMinigameStart", function(sessionId, value)
	if v then
		Network:Post("BrushaMinigameResult", sessionId, false)
		return
	end

	local engine = getEngine()
	local minigame = engine and engine.GetMinigame()

	if minigame and minigame.run then
		local v3 = {
			sessionId = sessionId,
			minigame = minigame,
			player = localPlayer,
			character = localPlayer.Character,
			maxDuration = value or 5,
			aborted = false,
			abortReason = nil,
			state = nil
		}
		local flag = false

		function v3.report(p2)
			if flag then
				return
			end

			flag = true
			Network:Post("BrushaMinigameResult", sessionId, p2 == true)
		end

		v = v3
		pcall(function()
			local StickerController = require(ReplicatedStorage.Modules.ClientUI.StickerController)

			if StickerController.ForceCloseWheel then
				StickerController.ForceCloseWheel()
			end
		end)
		local promptRelease = acquirePromptMute() -- equivalent call inferred; original call site unknown
		v3.promptRelease = promptRelease
		task.delay(70, function()
			if v == v3 then
				warn("[BrushaMinigameClient] session " .. tostring(sessionId) .. " wedged past " .. 70 .. "s — releasing the camera")
				failsafeRelease("Timed out")
				v = nil
			end
		end)
		task.spawn(function()
			local v5 = false

			if minigame.setup then
				local success, result = pcall(minigame.setup, v3)

				if not success then
					warn("[BrushaMinigameClient] setup errored:", result)
					result = false
				end

				if result == false then
					if minigame.cleanup then
						pcall(minigame.cleanup, v3)
					end

					releasePromptMute(v3) -- equivalent call inferred; original call site unknown
					releaseRotationGate() -- equivalent call inferred; original call site unknown
					v = nil
					Network:Post("BrushaMinigameResult", sessionId, false)
					return
				end
			end

			local success, result = pcall(minigame.run, v3)

			if success then
				v5 = result == true
			else
				warn("[BrushaMinigameClient] run errored:", result)
			end

			if minigame.cleanup then
				pcall(minigame.cleanup, v3)
			end

			releasePromptMute(v3) -- equivalent call inferred; original call site unknown
			releaseRotationGate() -- equivalent call inferred; original call site unknown
			v = nil
			v3.report(v5)
		end)
	else
		warn("[BrushaMinigameClient] no runnable minigame")
		Network:Post("BrushaMinigameResult", sessionId, false)
	end
end)
Network:AddAction("BrushaMinigameCancel", function(p, abortReason)
	local v2 = v

	if not v2 or v2.sessionId ~= p then
		return
	end

	v2.aborted = true
	v2.abortReason = abortReason

	if v2.minigame and v2.minigame.interrupt then
		pcall(v2.minigame.interrupt, v2, abortReason)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function watchCharacter(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.Died:Connect(function()
			failsafeRelease("Brusha went down")
		end)
	end
end

localPlayer.CharacterRemoving:Connect(function()
	failsafeRelease("Character removed")
end)
localPlayer.CharacterAdded:Connect(function(character)
	failsafeRelease("Respawned")
	watchCharacter(character) -- equivalent call inferred; original call site unknown
end)
local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

if humanoid then
	humanoid.Died:Connect(function()
		failsafeRelease("Brusha went down")
	end)
end