local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local v = nil

local function disconnectAllPerCharacterSignals()
	for _, v2 in ipairs({
		"sprintchanged",
		"sprintchanged2",
		"fatiguechanged",
		"healthchanged",
		"shieldchanged",
		"slot1changed",
		"slot2changed",
		"slot3changed",
		"slot4changed",
		"decodechanged"
	}) do
		local connection = GameContext[v2]

		if connection then
			connection:Disconnect()
		end
	end
end

local function reconnectStatsHandlers(instance)
	local stats = instance:FindFirstChild("Stats")
	local humanoid = instance:FindFirstChild("Humanoid")

	if not (stats and humanoid) then
		return
	end

	if not (GameContext.updateStaminaGui and GameContext.updateHealthGui) then
		warn("[CharacterLifecycleController] stat GUI fns unavailable (HUD degraded); skipping stats handler reconnect")
		return
	end

	local currentStamina = stats:FindFirstChild("CurrentStamina")
	local stamina = stats:FindFirstChild("Stamina")

	if currentStamina then
		GameContext.sprintchanged = currentStamina:GetPropertyChangedSignal("Value"):Connect(function()
			GameContext.updateStaminaGui(stats)
		end)
	end

	if stamina then
		GameContext.sprintchanged2 = stamina:GetPropertyChangedSignal("Value"):Connect(function()
			GameContext.updateStaminaGui(stats)
		end)
	end

	GameContext.fatiguechanged = instance.AttributeChanged:Connect(function(p)
		if p == "StaminaFatigued" then
			GameContext.updateStaminaGui(stats)
		end
	end)
	GameContext.healthchanged = humanoid.HealthChanged:Connect(function()
		GameContext.updateHealthGui(stats, humanoid)
	end)
	GameContext.updateStaminaGui(stats)
	GameContext.updateHealthGui(stats, humanoid)
end

local function installDiedHandler(instance)
	local gui = GameContext.Gui
	local player = GameContext.Player
	local humanoid = instance:WaitForChild("Humanoid")

	if GameContext.changed then
		GameContext.changed:Disconnect()
	end

	GameContext.changed = humanoid.Died:Connect(function()
		GameContext.currentgenerator = nil
		GameContext.skillchecking = false

		if GameContext.renderstep then
			GameContext.renderstep:Disconnect()
		end

		gui.Menu.StopGenerator.Visible = false

		if v.circleHandler then
			v.circleHandler.CleanUp(player)
		end

		if v.treadmillHandler then
			v.treadmillHandler.CleanUp()
		end

		if GameContext.hideAllSkillCheckUI then
			GameContext.hideAllSkillCheckUI()
		end

		pcall(function()
			local SprintController = require(ReplicatedStorage.Modules.ClientUI.SprintController)
			SprintController.resetState()
		end)
		pcall(function()
			local InputService = require(ReplicatedStorage.SharedUtils.InputService)
			InputService.GameplayInterrupted:Fire()
		end)
		GameContext.changed:Disconnect()
	end)
end

local v2 = nil
local v3 = nil

local function wireCharacter(character)
	v2 = character

	if v.onCharacterAdded then
		v.onCharacterAdded(character)
	end

	GameContext.setCharacter(character)
	disconnectAllPerCharacterSignals()

	if character.Parent == workspace.InGamePlayers then
		v3 = character

		if GameContext.setupStats then
			GameContext.setupStats()
		end

		if GameContext.setUpAbility then
			GameContext.setUpAbility(character)
		end

		reconnectStatsHandlers(character)
	end

	installDiedHandler(character)
end

local CharacterLifecycleController = {}

function CharacterLifecycleController.setupAll()
	local player = GameContext.Player
	player.CharacterAdded:Connect(wireCharacter)
	v2 = v.getCurrentCharacter and v.getCurrentCharacter() or player.Character

	if v2 and v2.Parent == workspace.InGamePlayers then
		v3 = v2
	end

	task.spawn(function()
		while true do
			task.wait(1)
			local character = player.Character

			if not (character and character.Parent) then
				continue
			end

			if character == v2 then
				if character ~= v3 and character.Parent == workspace.InGamePlayers then
					warn("[CharacterLifecycleController] stats wiring raced the InGamePlayers reparent for " .. character.Name .. " — late-wiring")
					v3 = character

					if GameContext.setupStats then
						GameContext.setupStats()
					end

					if GameContext.setUpAbility then
						GameContext.setUpAbility(character)
					end

					reconnectStatsHandlers(character)
				end
			else
				warn("[CharacterLifecycleController] CharacterAdded missed for " .. character.Name .. " (parent=" .. character.Parent.Name .. ") — late-wiring")
				wireCharacter(character)
			end
		end
	end)
end

function CharacterLifecycleController.reconcile()
	local character = GameContext.Player.Character

	if character and character ~= GameContext.Character then
		wireCharacter(character)
	end
end

function CharacterLifecycleController.init(options)
	v = options or {}
end

return CharacterLifecycleController