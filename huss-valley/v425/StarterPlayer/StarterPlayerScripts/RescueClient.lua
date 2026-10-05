local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local game2 = chickenOrHero:WaitForChild("Game")
local RescueConfig = require(game2:WaitForChild("RescueConfig"))
local rescueEvent = game2:WaitForChild("RescueEvent")
local session = game2:WaitForChild("Session")
local ParticipantDirectory = require(chickenOrHero.Presentation:WaitForChild("ParticipantDirectory"))
local VerifiedName = require(chickenOrHero.Presentation:WaitForChild("VerifiedName"))
local ControlGate = require(chickenOrHero.Movement:WaitForChild("ControlGate"))
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RescueStatus"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 24
screenGui.IgnoreGuiInset = true
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Status"
textLabel.AnchorPoint = Vector2.new(0.5, 1)
textLabel.Position = UDim2.fromScale(0.5, 0.8)
textLabel.Size = UDim2.fromScale(0.65, 0.065)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(245, 243, 231)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextScaled = true
textLabel.TextStrokeTransparency = 0.5
textLabel.Visible = false
textLabel.Parent = screenGui
local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
uITextSizeConstraint.MinTextSize = 12
uITextSizeConstraint.MaxTextSize = 20
uITextSizeConstraint.Parent = textLabel
local frame = Instance.new("Frame")
frame.Name = "NearbyRescue"
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromScale(0.22, 0.1)
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.fromScale(0.5, 0.78)
frame.Visible = false
frame.Parent = screenGui
local uISizeConstraint = Instance.new("UISizeConstraint")
uISizeConstraint.MinSize = Vector2.new(180, 60)
uISizeConstraint.MaxSize = Vector2.new(240, 74)
uISizeConstraint.Parent = frame
local textButton = Instance.new("TextButton")
textButton.Name = "Hold"
textButton.Size = UDim2.fromScale(1, 1)
textButton.BackgroundColor3 = Color3.fromRGB(12, 27, 30)
textButton.BackgroundTransparency = 0.16
textButton.BorderSizePixel = 0
textButton.Text = ""
textButton.AutoButtonColor = false
textButton.Parent = frame
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 5)
uICorner.Parent = textButton
local textLabel2 = Instance.new("TextLabel")
textLabel2.BackgroundTransparency = 1
textLabel2.Position = UDim2.fromScale(0.05, 0.08)
textLabel2.Size = UDim2.fromScale(0.9, 0.32)
textLabel2.Font = Enum.Font.Gotham
textLabel2.TextColor3 = Color3.fromRGB(187, 199, 194)
textLabel2.TextSize = 12
textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
textLabel2.Parent = textButton
local textLabel3 = Instance.new("TextLabel")
textLabel3.BackgroundTransparency = 1
textLabel3.Position = UDim2.fromScale(0.03, 0.39)
textLabel3.Size = UDim2.fromScale(0.94, 0.4)
textLabel3.Font = Enum.Font.GothamBold
textLabel3.TextSize = 14
textLabel3.TextColor3 = Color3.fromRGB(245, 238, 208)
textLabel3.Parent = textButton
local frame2 = Instance.new("Frame")
frame2.BorderSizePixel = 0
frame2.BackgroundColor3 = Color3.fromRGB(85, 100, 96)
frame2.BackgroundTransparency = 0.4
frame2.Position = UDim2.fromScale(0.04, 0.89)
frame2.Size = UDim2.fromScale(0.92, 0.045)
frame2.Parent = textButton
local frame3 = Instance.new("Frame")
frame3.BorderSizePixel = 0
frame3.BackgroundColor3 = Color3.fromRGB(225, 209, 148)
frame3.Size = UDim2.fromScale(0, 1)
frame3.Parent = frame2
local ReviveMarkers = require(chickenOrHero.Presentation:WaitForChild("ReviveMarkers"))
local v = ReviveMarkers.new(localPlayer.PlayerGui)
local v2 = nil
local v3 = nil
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function cancel()
	if v3 and not v3.sent then
		rescueEvent:FireServer("Cancel", v3.id)
	end

	v3 = nil
	v4 = nil
	frame3.Size = UDim2.fromScale(0, 1)
end

local function begin(input)
	if v3 or not (v2 and frame.Visible) then
		return
	end

	v4 = input
	v3 = {
		id = v2.UserId,
		character = v2.Character,
		started = os.clock()
	}
	rescueEvent:FireServer("Begin", v3.id)
end

textButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		begin(input)
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and not UserInputService:GetFocusedTextBox() and (input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonX) then
		begin(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if v4 and (input == v4 or input.KeyCode ~= Enum.KeyCode.None and input.KeyCode == v4.KeyCode) then
		cancel() -- equivalent call inferred; original call site unknown
	end
end)
rescueEvent.OnClientEvent:Connect(function(p, p2)
	if p == "Cancelled" and v3 and v3.id == p2 then
		v3 = nil
		v4 = nil
		frame3.Size = UDim2.fromScale(0, 1)
	end
end)

local function characterAdded(instance)
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if not humanoid then
		return
	end

	local stateEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.GettingUp)
	local flag = false

	local function update()
		if instance:GetAttribute("Ragdolled") == true then
			flag = true
			humanoid.EvaluateStateMachine = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			humanoid.PlatformStand = true
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		elseif flag then
			flag = false
			humanoid.EvaluateStateMachine = true
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, stateEnabled)
			humanoid.PlatformStand = false

			if humanoid.Health > 0 then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end

	local ragdolledChangedConnection = instance:GetAttributeChangedSignal("Ragdolled"):Connect(update)
	instance.Destroying:Once(function()
		ragdolledChangedConnection:Disconnect()
	end)
	update()
end

localPlayer.CharacterAdded:Connect(characterAdded)

if localPlayer.Character then
	task.spawn(characterAdded, localPlayer.Character)
end

local total = 0
local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total >= 0.1 then
		total = 0
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local globalPaused = session:GetAttribute("GlobalPaused")
		local ragdolled

		if localPlayer:GetAttribute("GameRole") == "Runner" and localPlayer:GetAttribute("RunState") == "Caught" then
			ragdolled = character and character:GetAttribute("Ragdolled")
		else
			ragdolled = false
		end

		local parent = textLabel
		local visible

		if ragdolled then
			visible = not globalPaused or false
		else
			visible = false
		end

		parent.Visible = visible

		if textLabel.Visible then
			textLabel.Text = not character:GetAttribute("RescueAvailable") and "CAUGHT · Joining the catchers next crossing" or character:GetAttribute("RescueHelperId") and "GETTING YOU BACK UP…" or "DOWNED · A crossing runner can revive you"
		end

		local v7 = RescueConfig.Enabled and not (globalPaused or ControlGate.reason(localPlayer))

		if v7 then
			if localPlayer:GetAttribute("GameRole") == "Runner" and localPlayer:GetAttribute("RunState") == "Active" then
				if humanoidRootPart then
					if humanoid then
						if humanoid.Health > 0 then
							v7 = not character:GetAttribute("MovementLocked")
						else
							v7 = false
						end
					else
						v7 = humanoid
					end
				else
					v7 = humanoidRootPart
				end
			else
				v7 = false
			end
		end

		local v8 = v7 and ParticipantDirectory.list() or {}
		v:update(v8, localPlayer, v7)
		local v9 = nil
		local v10 = RescueConfig.Range - 0.25

		if v7 then
			for _, v11 in v8 do
				local character2 = v11.Character
				local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart2 and character2 ~= character and character2:GetAttribute("RescueAvailable") and character2:GetAttribute("Ragdolled")) then
					continue
				end

				local rescueHelperId = character2:GetAttribute("RescueHelperId")
				local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

				if not (magnitude <= v10 and (not rescueHelperId or rescueHelperId == localPlayer.UserId)) then
					continue
				end

				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { character, character2 }
				raycastParams.RespectCanCollide = true
				raycastParams.CollisionGroup = "CoHRunner"

				if workspace:Raycast(
					humanoidRootPart.Position,
					humanoidRootPart2.Position - humanoidRootPart.Position,
					raycastParams
				) then
					continue
				end

				v9 = v11
				v10 = magnitude
			end
		end

		if v3 and (not v9 or v9.UserId ~= v3.id or v9.Character ~= v3.character) then
			cancel() -- equivalent call inferred; original call site unknown
		end

		v2 = v9
		frame.Visible = v2 ~= nil

		if v2 then
			textLabel2.RichText = true
			textLabel2.Text = VerifiedName.player(v2) .. (" · %.1fs"):format(RescueConfig.HoldSeconds)
			local preferredInput = UserInputService.PreferredInput
			local v11 = textLabel3
			local text

			if v3 then
				text = v3.sent and "HELPING…" or "HOLD…"
			else
				text = preferredInput == Enum.PreferredInput.Touch and "HOLD TO REVIVE" or preferredInput == Enum.PreferredInput.Gamepad and "HOLD X · REVIVE" or "HOLD F · REVIVE"
			end

			v11.Text = text
		end
	end

	if v3 then
		local v5 = math.clamp((os.clock() - v3.started) / RescueConfig.HoldSeconds, 0, 1)
		frame3.Size = UDim2.fromScale(v5, 1)

		if v5 >= 1 and not v3.sent then
			v3.sent = true
			rescueEvent:FireServer("Finish", v3.id)
		end

		if v3.sent and os.clock() - v3.started > RescueConfig.HoldSeconds + RescueConfig.FinishGrace + 0.5 then
			cancel() -- equivalent call inferred; original call site unknown
		end
	end
end)
script.Destroying:Connect(function()
	heartbeatConnection:Disconnect()
	cancel() -- equivalent call inferred; original call site unknown
	v:destroy()
	screenGui:Destroy()
end)