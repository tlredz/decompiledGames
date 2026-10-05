local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local presentation = chickenOrHero:WaitForChild("Presentation")
local HudStyle = require(presentation:WaitForChild("HudStyle"))
local DashMeterModel = require(presentation:WaitForChild("DashMeterModel"))
local CatchMeterModel = require(presentation:WaitForChild("CatchMeterModel"))
local TackleProfile = require(chickenOrHero:WaitForChild("Game"):WaitForChild("TackleProfile"))
local GameConfig = require(chickenOrHero.Game.GameConfig)
local tackle = GameConfig.Tackle
local MovementProfiles = require(chickenOrHero.Movement:WaitForChild("MovementProfiles"))
local BoostInput = require(chickenOrHero.Movement:WaitForChild("BoostInput"))
local ControlGate = require(chickenOrHero.Movement:WaitForChild("ControlGate"))
local barMainFrame = script.Parent:WaitForChild("MainFrame"):WaitForChild("BarMainFrame")
local bar = barMainFrame:WaitForChild("BarBG"):WaitForChild("Bar")
local status = barMainFrame:WaitForChild("Status")
local hint = barMainFrame:WaitForChild("Hint")
local controlPrompt = barMainFrame:WaitForChild("ControlPrompt")
local meleeControl = barMainFrame:WaitForChild("MeleeControl")
local imageLabel = meleeControl:FindFirstChildWhichIsA("ImageLabel")
local image = imageLabel and imageLabel.Image
local v = nil
local total = 0
local v2 = false
local v3 = nil
local connections = {}

local function update()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	barMainFrame.Visible = humanoid ~= nil and humanoid.Health > 0 and humanoidRootPart ~= nil and localPlayer:GetAttribute("ReleaseCameraForUI") ~= true

	if barMainFrame.Visible then
		if v3 ~= character then
			v3 = character
			v2 = false
		end

		local v6 = humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)
		local paused = character:GetAttribute("MovementLocked") == true or (humanoidRootPart.Anchored or character:GetAttribute("TackleActive") == true or humanoid.Sit or humanoid.PlatformStand or game.GuiService.MenuIsOpen or game.UserInputService:GetFocusedTextBox() ~= nil or not BoostInput.available(localPlayer))
		local v8 = localPlayer:GetAttribute("GameRole") == "Catcher"
		local preferredInput = game.UserInputService.PreferredInput
		meleeControl.Visible = v8 and preferredInput ~= Enum.PreferredInput.Touch

		if imageLabel and preferredInput ~= v then
			v = preferredInput

			if preferredInput == Enum.PreferredInput.Gamepad then
				local success, imageForKeyCode = pcall(
					game.UserInputService.GetImageForKeyCode,
					game.UserInputService,
					Enum.KeyCode.ButtonL2
				)
				imageLabel.Image = (not success or imageForKeyCode == "" or not imageForKeyCode) and "rbxasset://textures/ui/Controls/xboxLT.png" or imageForKeyCode
			else
				imageLabel.Image = image
			end
		end

		local control

		if v8 then
			control = preferredInput == Enum.PreferredInput.Touch and "Tap CATCH" or preferredInput == Enum.PreferredInput.Gamepad and "RT / R2" or "Space"
		else
			control = BoostInput.control()
		end

		local v10

		if v8 then
			local serverTimeNow = workspace:GetServerTimeNow()
			local tackleActive = character:GetAttribute("TackleActive") == true
			local tackleVariant = tackleActive and character:GetAttribute("TackleVariant") or TackleProfile.select(
				tackle,
				v6.Magnitude,
				MovementProfiles.get("Catcher", localPlayer).MaxSpeed
			).Name
			v10 = CatchMeterModel.read({
				cooldown = math.max(0, (localPlayer:GetAttribute("TackleReadyAt") or 0) - serverTimeNow),
				active = tackleActive,
				elapsed = serverTimeNow - (character:GetAttribute("TackleStartedAt") or serverTimeNow),
				duration = character:GetAttribute("TackleDuration") or tackle.Duration,
				variant = tackleVariant,
				control = control,
				grounded = humanoid.FloorMaterial ~= Enum.Material.Air,
				paused = localPlayer:GetAttribute("RunState") ~= "Active" or character:GetAttribute("MovementLocked") == true or (humanoid.Sit or humanoid.PlatformStand or game.GuiService.MenuIsOpen or game.UserInputService:GetFocusedTextBox() ~= nil or ControlGate.reason(localPlayer) ~= nil or humanoidRootPart.Anchored and not tackleActive)
			}, tackle)
		else
			v10 = DashMeterModel.read({
				cooldown = math.max(0, (character:GetAttribute("DashCooldownUntil") or 0) - os.clock()),
				recovery = math.max(0, (character:GetAttribute("BoostRecoveryUntil") or 0) - os.clock()),
				boosting = character:GetAttribute("MovementState") == "Boosting",
				control = control,
				ready = character:GetAttribute("DashReady") == true,
				speed = v6.Magnitude,
				grounded = humanoid.FloorMaterial ~= Enum.Material.Air,
				paused = paused
			}, MovementProfiles.get(localPlayer:GetAttribute("GameRole"), localPlayer))
		end

		if v8 and v10.ready then
			v10.hint = "Tag in front  ·  " .. control .. " to dive"
		end

		local color = HudStyle.Colors[v10.tone]
		status.Text = v10.label
		hint.Text = v10.hint
		status.TextColor3 = color
		bar.BackgroundColor3 = color
		bar.Size = UDim2.fromScale(v10.fill, 1)
		local ready = v10.ready == true
		controlPrompt.Visible = preferredInput ~= Enum.PreferredInput.Touch
		local v11 = v8 and "CATCH" or "DASH"
		controlPrompt.Text = ready and "PRESS " .. string.upper(control) .. " TO " .. v11 or string.upper(control) .. "  ·  " .. v11
		controlPrompt.TextColor3 = ready and HudStyle.Colors.Text or HudStyle.Colors.Muted

		if ready and not v2 then
			bar.BackgroundTransparency = 0.25
			TweenService:Create(bar, TweenInfo.new(0.25), {
				BackgroundTransparency = 0
			}):Play()
		end

		v2 = ready
	else
		v3 = nil
		v2 = false
	end
end

table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	total += dt

	if total < 0.03333333333333333 then
		return
	end

	total = 0
	update()
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end
end)
update()