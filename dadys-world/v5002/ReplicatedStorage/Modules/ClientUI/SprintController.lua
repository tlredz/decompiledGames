local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local v = nil
local sprintEvent = nil
local flag = false
local flag2 = false
local connection = nil
local connection2 = nil
local onClientEventConnection = nil
local preferredInputChangedConnection = nil
local gameplayInterruptedConnection = nil

local function canStartSprint()
	local character = v.getCharacter()

	if not character or character:FindFirstChild("BoxAbilityActive") then
		return false
	end

	return not character:GetAttribute("StaminaFatigued") and not character:GetAttribute("TreadmillDazed")
end

local function isToggleMode()
	local replicatedData = v.replicatedData

	if not replicatedData then
		return false
	end

	local sprintToggle = replicatedData:FindFirstChild("SprintToggle")
	return sprintToggle ~= nil and sprintToggle.Value == true
end

local function isToggleLike()
	local v2

	if InputService:GetPreferredInput() == "Touch" then
		v2 = true
		return true
	end

	local replicatedData = v.replicatedData

	if not replicatedData then
		return false
	end

	local sprintToggle = replicatedData:FindFirstChild("SprintToggle")
	return sprintToggle ~= nil and sprintToggle.Value == true
end

local function setMobileButtonSprinting(p)
	local gui = v.gui

	if not gui then
		return
	end

	local mobileRun = gui:FindFirstChild("MobileRun")

	if not mobileRun then
		return
	end

	local textLabel = mobileRun:FindFirstChild("TextLabel")

	if textLabel then
		textLabel.Text = p and "SPRINT: ON" or "SPRINT: OFF"
	end

	mobileRun.Image = p and "rbxassetid://11866539249" or "rbxassetid://11866517702"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSprintIconVisible(visible)
	local gui = v.gui

	if not gui then
		return
	end

	local sprintIcon = gui:FindFirstChild("SprintIcon")

	if not sprintIcon then
		return
	end

	if InputService:GetPreferredInput() == "Touch" then
		sprintIcon.Visible = false
	else
		sprintIcon.Visible = visible
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startSprint()
	if flag then
		return
	end

	local character = v.getCharacter()
	local v2

	if character and not (character:FindFirstChild("BoxAbilityActive") or character:GetAttribute("StaminaFatigued")) then
		v2 = not character:GetAttribute("TreadmillDazed")
	else
		v2 = false
	end

	if not v2 then
		return
	end

	flag = true
	sprintEvent:FireServer(true)
	local gui = v.gui
	local mobileRun = gui and gui:FindFirstChild("MobileRun")

	if mobileRun then
		local textLabel = mobileRun:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Text = "SPRINT: ON"
		end

		mobileRun.Image = "rbxassetid://11866539249"
	end

	setSprintIconVisible(true) -- equivalent call inferred; original call site unknown
end

local function stopSprint()
	if not flag then
		return
	end

	flag = false
	sprintEvent:FireServer(false)
	local gui = v.gui
	local mobileRun = gui and gui:FindFirstChild("MobileRun")

	if mobileRun then
		local textLabel = mobileRun:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Text = "SPRINT: OFF"
		end

		mobileRun.Image = "rbxassetid://11866517702"
	end

	local gui2 = v.gui

	if not gui2 then
		return
	end

	local sprintIcon = gui2:FindFirstChild("SprintIcon")

	if not sprintIcon then
		return
	end

	if InputService:GetPreferredInput() == "Touch" then
	end

	sprintIcon.Visible = false
end

local function onSprintPressed()
	task.spawn(function()
		if InputService:IsTyping() then
			return
		end

		local v2

		if InputService:GetPreferredInput() == "Touch" then
			v2 = true
		else
			local replicatedData = v.replicatedData

			if replicatedData then
				local sprintToggle = replicatedData:FindFirstChild("SprintToggle")

				if sprintToggle == nil then
					v2 = false
				else
					v2 = sprintToggle.Value == true
				end
			else
				v2 = false
			end
		end

		if v2 and flag then
			if not flag then
				return
			end

			flag = false
			sprintEvent:FireServer(false)
			local gui = v.gui
			local mobileRun = gui and gui:FindFirstChild("MobileRun")

			if mobileRun then
				local textLabel = mobileRun:FindFirstChild("TextLabel")

				if textLabel then
					textLabel.Text = "SPRINT: OFF"
				end

				mobileRun.Image = "rbxassetid://11866517702"
			end

			local gui2 = v.gui

			if not gui2 then
				return
			end

			local sprintIcon = gui2:FindFirstChild("SprintIcon")

			if not sprintIcon then
				return
			end

			if InputService:GetPreferredInput() == "Touch" then
			end

			sprintIcon.Visible = false
			return
		end

		startSprint() -- equivalent call inferred; original call site unknown
	end)
end

local function onSprintReleased()
	local v2

	if InputService:GetPreferredInput() == "Touch" then
		v2 = true
	else
		local replicatedData = v.replicatedData

		if replicatedData then
			local sprintToggle = replicatedData:FindFirstChild("SprintToggle")

			if sprintToggle == nil then
				v2 = false
			else
				v2 = sprintToggle.Value == true
			end
		else
			v2 = false
		end
	end

	if not v2 then
		if not flag then
			return
		end

		flag = false
		sprintEvent:FireServer(false)
		local gui = v.gui
		local mobileRun = gui and gui:FindFirstChild("MobileRun")

		if mobileRun then
			local textLabel = mobileRun:FindFirstChild("TextLabel")

			if textLabel then
				textLabel.Text = "SPRINT: OFF"
			end

			mobileRun.Image = "rbxassetid://11866517702"
		end

		setSprintIconVisible(false) -- equivalent call inferred; original call site unknown
	end
end

local SprintController = {}

function SprintController.init(p)
	v = p
	sprintEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SprintEvent")
end

function SprintController.start()
	if flag2 then
		return
	end

	if not v then
		warn("[SprintController] start() called before init()")
		return
	end

	connection = InputService:OnAction("Sprint", onSprintPressed)
	connection2 = InputService:OnActionReleased("Sprint", onSprintReleased)
	local gui = v.gui
	local mobileRun = gui and gui:FindFirstChild("MobileRun")

	if mobileRun then
		InputService:BindTouchButton("Sprint", mobileRun)
	end

	onClientEventConnection = sprintEvent.OnClientEvent:Connect(function()
		flag = false
		sprintEvent:FireServer(false)
		local gui2 = v.gui
		local mobileRun2 = gui2 and gui2:FindFirstChild("MobileRun")

		if mobileRun2 then
			local textLabel = mobileRun2:FindFirstChild("TextLabel")

			if textLabel then
				textLabel.Text = "SPRINT: OFF"
			end

			mobileRun2.Image = "rbxassetid://11866517702"
		end

		local gui3 = v.gui

		if not gui3 then
			return
		end

		local sprintIcon = gui3:FindFirstChild("SprintIcon")

		if not sprintIcon then
			return
		end

		if InputService:GetPreferredInput() == "Touch" then
		end

		sprintIcon.Visible = false
	end)

	local function updateMobileAffordances()
		local visible = InputService:GetPreferredInput() == "Touch"

		if gui and gui:FindFirstChild("ViewStats") then
			gui.ViewStats.Visible = visible
		end
	end

	preferredInputChangedConnection = InputService.PreferredInputChanged:Connect(updateMobileAffordances)
	task.spawn(updateMobileAffordances)
	gameplayInterruptedConnection = InputService.GameplayInterrupted:Connect(function()
		local v2

		if InputService:GetPreferredInput() == "Touch" then
			v2 = true
		else
			local replicatedData = v.replicatedData

			if replicatedData then
				local sprintToggle = replicatedData:FindFirstChild("SprintToggle")

				if sprintToggle == nil then
					v2 = false
				else
					v2 = sprintToggle.Value == true
				end
			else
				v2 = false
			end
		end

		if not v2 and flag then
			if not flag then
				return
			end

			flag = false
			sprintEvent:FireServer(false)
			local gui2 = v.gui
			local mobileRun2 = gui2 and gui2:FindFirstChild("MobileRun")

			if mobileRun2 then
				local textLabel = mobileRun2:FindFirstChild("TextLabel")

				if textLabel then
					textLabel.Text = "SPRINT: OFF"
				end

				mobileRun2.Image = "rbxassetid://11866517702"
			end

			setSprintIconVisible(false) -- equivalent call inferred; original call site unknown
		end
	end)
	flag2 = true
end

function SprintController.resetState()
	flag = false
	local gui = v.gui
	local mobileRun = gui and gui:FindFirstChild("MobileRun")

	if mobileRun then
		local textLabel = mobileRun:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Text = "SPRINT: OFF"
		end

		mobileRun.Image = "rbxassetid://11866517702"
	end

	local gui2 = v.gui

	if not gui2 then
		return
	end

	local sprintIcon = gui2:FindFirstChild("SprintIcon")

	if not sprintIcon then
		return
	end

	if InputService:GetPreferredInput() == "Touch" then
	end

	sprintIcon.Visible = false
end

function SprintController.isSprinting()
	return flag
end

function SprintController.stop()
	if not flag2 then
		return
	end

	if connection then
		connection:Disconnect()
		connection = nil
	end

	if connection2 then
		connection2:Disconnect()
		connection2 = nil
	end

	if onClientEventConnection then
		onClientEventConnection:Disconnect()
		onClientEventConnection = nil
	end

	if preferredInputChangedConnection then
		preferredInputChangedConnection:Disconnect()
		preferredInputChangedConnection = nil
	end

	if gameplayInterruptedConnection then
		gameplayInterruptedConnection:Disconnect()
		gameplayInterruptedConnection = nil
	end

	flag2 = false
end

return SprintController