local GeneratorUIController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local v = nil
local maxActivationDistancesByProximityPrompt = {}
local promptShownConnection = nil
local v2 = false
local v3 = 0
local v4 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function tryMutePrompt(proximityPrompt)
	if not (proximityPrompt:IsA("ProximityPrompt") and maxActivationDistancesByProximityPrompt[proximityPrompt] == nil and proximityPrompt.MaxActivationDistance ~= 0) then
		return
	end

	maxActivationDistancesByProximityPrompt[proximityPrompt] = proximityPrompt.MaxActivationDistance
	proximityPrompt.MaxActivationDistance = 0
end

local function refreshMute()
	local v5 = v2 or v3 > 0

	if v5 == v4 then
		return
	end

	v4 = v5

	if v5 then
		for _, descendant in ipairs(workspace:GetDescendants()) do
			tryMutePrompt(descendant) -- equivalent call inferred; original call site unknown
		end

		promptShownConnection = ProximityPromptService.PromptShown:Connect(tryMutePrompt)
	else
		if promptShownConnection then
			promptShownConnection:Disconnect()
			promptShownConnection = nil
		end

		for k, maxActivationDistance in pairs(maxActivationDistancesByProximityPrompt) do
			if k and k.Parent then
				k.MaxActivationDistance = maxActivationDistance
			end
		end

		table.clear(maxActivationDistancesByProximityPrompt)
	end
end

local function setEngagedMuted(p)
	if p == v2 then
		return
	end

	v2 = p
	refreshMute()
end

function GeneratorUIController.SuppressPrompts()
	v3 += 1
	refreshMute()
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		v3 = math.max(0, v3 - 1)
		refreshMute()
	end
end

function GeneratorUIController.ArePromptsMuted()
	return v4
end

function GeneratorUIController.init(p)
	v = p
end

function GeneratorUIController.updateGui()
	if workspace.Info.FloorActive.Value == true then
		local gui = GameContext.Gui
		local value = workspace.Info.GeneratorsCompleted.Value
		local value2 = workspace.Info.RequiredGenerators.Value
		local v5 = value / value2
		gui.Menu.GeneratorFrame.Message.Text = "Machines Completed: " .. value .. "/" .. value2
		local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(gui.Menu.GeneratorFrame.CurrentAmount, tweenInfo, {
			Size = UDim2.new(math.clamp(v5, 0, 1), 0, 1, 0)
		}):Play()
	end
end

function GeneratorUIController.setupStopInteractingConnection()
	local gui = GameContext.Gui
	return ReplicatedStorage.Events.StopInteracting.OnClientEvent:Connect(function()
		if v2 ~= false then
			v2 = false
			refreshMute()
		end

		if GameContext.skillchecking == true then
			return
		end

		GameContext.currentgenerator = nil
		gui.Menu.StopGenerator.Visible = false
		gui.Menu.SkillCheckFrame.Visible = false
		gui.Menu.SpaceBarPromptText.Visible = false
		gui.Menu.Calibrate.Visible = false
	end)
end

function GeneratorUIController.setupStopGeneratorButton()
	local gui = GameContext.Gui
	return gui.Menu.StopGenerator.Activated:Connect(function()
		if GameContext.cooldown == false and GameContext.currentgenerator ~= nil and GameContext.skillchecking == false then
			local stats = GameContext.currentgenerator:WaitForChild("Stats", 5)
			local stopInteracting = stats and stats:WaitForChild("StopInteracting", 5)

			if not stopInteracting then
				return
			end

			gui.Menu.StopGenerator.Visible = false
			gui.Menu.SpaceBarPromptText.Visible = false
			stopInteracting:FireServer("Stop")
			GameContext.currentgenerator = nil
			GameContext.currentMinigameType = "default"
			v.circleHandler.CleanUp(GameContext.Player)
			v.treadmillHandler.CleanUp()
			GameContext.updateSkillCheckPromptText("default")

			if v2 == false then
				return
			end

			v2 = false
			refreshMute()
		end
	end)
end

function GeneratorUIController.setupGeneratorUpdate()
	local gui = GameContext.Gui
	return ReplicatedStorage:WaitForChild("Events"):WaitForChild("GeneratorUpdate").OnClientEvent:Connect(function(currentgenerator, p, value)
		if currentgenerator and p then
			if p == "Begin" then
				local currentgenerator2 = GameContext.currentgenerator

				if currentgenerator2 and currentgenerator2 ~= currentgenerator and currentgenerator2.Parent and currentgenerator2:FindFirstChild("Stats") and not currentgenerator:FindFirstChild("Stats") then
					return
				end

				GameContext.currentgenerator = currentgenerator

				if v2 ~= true then
					v2 = true
					refreshMute()
				end

				gui.Menu.StopGenerator.Visible = value ~= "barnaby"
				local currentMinigameType = value or "default"

				if not value then
					warn("[GeneratorUIController] Server didn't provide minigameType - using default")
				end

				GameContext.currentMinigameType = currentMinigameType

				if currentMinigameType == "movement" then
					gui.Menu.SpaceBarPromptText.Text = "Sprint to run faster!"
					gui.Menu.SpaceBarPromptText.Visible = true
				else
					gui.Menu.SpaceBarPromptText.Text = ""
					gui.Menu.SpaceBarPromptText.Visible = true
					GameContext.updateSkillCheckPromptText(currentMinigameType)
				end

				GameContext.cooldown = true
				GameContext._cooldownGen = (GameContext._cooldownGen or 0) + 1
				local _cooldownGen = GameContext._cooldownGen
				task.delay(0.5, function()
					if GameContext._cooldownGen == _cooldownGen then
						GameContext.cooldown = false
					end
				end)
			elseif p == "Fail" then
				pcall(function()
					local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
					require(ReplicatedStorage2.Modules.ClientUI.SkillCheckController).playFailFeedback()
				end)
			elseif p == "Complete" then
				if GameContext.currentgenerator ~= nil and currentgenerator ~= GameContext.currentgenerator then
					return
				end

				pcall(function()
					local SkillCheckController = require(ReplicatedStorage.Modules.ClientUI.SkillCheckController)
					SkillCheckController.abortActive(currentgenerator)
				end)
				v.circleHandler.CleanUp(GameContext.Player)
				v.treadmillHandler.CleanUp()
				GameContext.currentgenerator = nil
				GameContext.currentMinigameType = "default"
				GameContext.skillchecking = false
				gui.Menu.StopGenerator.Visible = false
				gui.Menu.SkillCheckFrame.Visible = false
				gui.Menu.SpaceBarPromptText.Visible = false
				gui.Menu.Calibrate.Visible = false

				if v2 == false then
					return
				end

				v2 = false
				refreshMute()
			end
		end
	end)
end

function GeneratorUIController.setupProgressListeners()
	local _ = GameContext.Gui
	local value = 0
	return workspace.Info.GeneratorsCompleted.Changed:Connect(function()
		GeneratorUIController.updateGui()
		local value2 = workspace.Info.GeneratorsCompleted.Value

		if value <= value2 then
			Audio:PlayOne("Sounds.UI.Alerts.HintSound", {
				TimePosition = 0.85
			})
		end

		value = workspace.Info.GeneratorsCompleted.Value
	end), (workspace.Info.RequiredGenerators.Changed:Connect(function()
		GeneratorUIController.updateGui()
	end))
end

function GeneratorUIController.setupStopInteractInput()
	local gui = GameContext.Gui
	local flag = false
	InputService:OnAction("GeneratorStop", function()
		if InputService:IsTyping() or flag then
			return
		end

		flag = true
		task.wait()

		if gui.Menu.StopGenerator.Visible == true and GameContext.cooldown == false and GameContext.currentgenerator ~= nil and GameContext.skillchecking == false then
			local stats = GameContext.currentgenerator:WaitForChild("Stats", 5)
			local stopInteracting = stats and stats:WaitForChild("StopInteracting", 5)

			if stopInteracting then
				gui.Menu.StopGenerator.Visible = false
				gui.Menu.SpaceBarPromptText.Visible = false
				stopInteracting:FireServer("Stop")
				GameContext.currentgenerator = nil
				GameContext.currentMinigameType = "default"
				v.circleHandler.CleanUp(GameContext.Player)
				v.treadmillHandler.CleanUp()
				GameContext.updateSkillCheckPromptText("default")

				if v2 ~= false then
					v2 = false
					refreshMute()
				end
			end
		end

		flag = false
	end)
end

function GeneratorUIController.setupAll()
	GeneratorUIController.updateGui()
	local v5 = {}
	table.insert(v5, GeneratorUIController.setupStopInteractingConnection())
	table.insert(v5, GeneratorUIController.setupStopGeneratorButton())
	table.insert(v5, GeneratorUIController.setupGeneratorUpdate())
	local v6, v7 = GeneratorUIController.setupProgressListeners()
	table.insert(v5, v6)
	table.insert(v5, v7)
	GeneratorUIController.setupStopInteractInput()
	table.insert(v5, GameContext.Player.CharacterRemoving:Connect(function()
		if v2 == false then
			return
		end

		v2 = false
		refreshMute()
	end))
	return v5
end

return GeneratorUIController