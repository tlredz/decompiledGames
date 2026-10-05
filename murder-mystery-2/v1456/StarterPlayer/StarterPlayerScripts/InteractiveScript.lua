local v = time()
local v2 = nil

repeat
	task.wait()
until game.Players.LocalPlayer.Character

repeat
	task.wait()
until game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local interactGUI = game.Players.LocalPlayer.PlayerGui:WaitForChild("InteractGUI")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v3 = nil
local v4 = nil
local enabled = false
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local uDim = UDim2.new(1.2, 0, 1.3, 0)

local function CheckIfMurderer()
	local v5 = { game.Players.LocalPlayer.Backpack, game.Players.LocalPlayer.Character }
	local v6 = false

	for _, v7 in pairs(v5) do
		for _, tool in pairs(v7:GetChildren()) do
			if not (tool:IsA("Tool") and tool:FindFirstChild("Stab") and tool:FindFirstChild("KnifeClient")) then
				continue
			end

			v6 = true
		end
	end

	return v6
end

local touchInteractButtons = game.Players.LocalPlayer.PlayerGui:WaitForChild("TouchInteractButtons")
touchInteractButtons:WaitForChild("Phone")
touchInteractButtons:WaitForChild("Tablet")
local touchInteract = nil
local touchInteractKnife = nil
local RunService = game:GetService("RunService")
RunService.PreSimulation:Connect(function()
	if time() - v < 0.1 or game.Players.LocalPlayer.Character == nil then
		return
	end

	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	interactGUI = game.Players.LocalPlayer.PlayerGui:FindFirstChild("InteractGUI")

	if interactGUI == nil then
		v3 = nil
		v4 = nil
	else
		local v5 = UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1
		local enabled2 = UserInputService:GetLastInputType() == Enum.UserInputType.Touch
		interactGUI.Gamepad.Visible = false
		interactGUI.Keyboard.Visible = false
		interactGUI.Mobile.Visible = false
		local gamepad = v5 and interactGUI.Gamepad or enabled2 and interactGUI.Mobile or interactGUI.Keyboard
		gamepad.Visible = true
		local use = gamepad.Use
		local cooldown = gamepad.Cooldown
		touchInteractButtons.Enabled = enabled2

		if enabled2 and _G.MobileDevice ~= nil then
			touchInteract = touchInteractButtons:FindFirstChild(_G.MobileDevice).TouchInteract
			touchInteractKnife = touchInteractButtons:FindFirstChild(_G.MobileDevice).TouchInteractKnife
		end

		if v3 == nil then
			v3 = TweenService:Create(interactGUI, tweenInfo, {
				Size = uDim,
				Enabled = true
			})
			v4 = TweenService:Create(interactGUI, tweenInfo, {
				Size = UDim2.new(0, 0, 0, 0),
				Enabled = false
			})
		end

		local v7 = {}

		for _, v8 in CollectionService:GetTagged("InteractiveBox") do
			table.insert(v7, v8)
		end

		local v8 = {}
		local v9 = 1000
		local adornee = nil

		for _, v11 in pairs(v7) do
			if (v11.Position - humanoidRootPart.Position).magnitude <= 6 then
				table.insert(v8, v11)
			end
		end

		for _, v11 in pairs(v8) do
			local magnitude = (v11.Position - humanoidRootPart.Position).magnitude

			if not (magnitude < v9) then
				continue
			end

			local v12

			if v11:FindFirstChild("KnifeBox") == nil then
				v12 = false
			else
				v12 = v11.KnifeBox.Value == true
			end

			local ray = Ray.new(humanoidRootPart.CFrame.p, (v11.CFrame.p - humanoidRootPart.CFrame.p).unit * magnitude)
			local partOnRay = game.Workspace:FindPartOnRay(ray, character)
			local v13 = {
				BoxDisabled = v11:FindFirstChild("IsDisabled") and v11.IsDisabled.Value == false and true or v11:FindFirstChild("IsDisabled") == nil,
				KeyDoorInnocents = v11:FindFirstChild("KeyToPickupColor") and not CheckIfMurderer() or v11:FindFirstChild("KeyToPickupColor") == nil,
				GunSafe = v11:FindFirstChild("PerPlayerUse") and not CheckIfMurderer() or v11:FindFirstChild("PerPlayerUse") == nil,
				PerUseUsedAlready = v11:FindFirstChild("PerPlayerUse") and not v11.PerPlayerUse:FindFirstChild(game.Players.LocalPlayer.Name) or v11:FindFirstChild("PerPlayerUse") == nil,
				MurdererOnlyInteract = v12 == true and CheckIfMurderer() == true or v12 == false,
				RequiresVision = v11:FindFirstChild("RequireVision") and (v11:FindFirstChild("RequireVision").Value == true and partOnRay == v11 or v11.RequireVision.Value == false) and true or v11:FindFirstChild("RequireVision") == nil
			}
			local flag = true

			for _, v14 in pairs(v13) do
				if not v14 then
					flag = false
				end
			end

			if not flag then
				continue
			end

			adornee = v11
			v9 = magnitude
		end

		if adornee then
			local visible = adornee.InUse.Value
			interactGUI.Adornee = adornee
			v2 = adornee
			local visible2 = adornee:FindFirstChild("KnifeBox") and adornee.KnifeBox.Value == true

			if visible2 then
				use = gamepad.KnifeUse
				cooldown = gamepad.KnifeCooldown
			end

			for _, child in pairs(gamepad:GetChildren()) do
				child.Visible = false
			end

			local keyRequired = adornee:FindFirstChild("KeyRequired")

			if keyRequired then
				cooldown = gamepad.KeyRequired
				local value2 = keyRequired.KeyType.Value
				local value3 = keyRequired.KeyColor.Value
				cooldown.UseText.Text = "Need " .. value2 .. "!"
				local child = game.Players.LocalPlayer.Character:FindFirstChild(value2)
				visible = (not child or child.KeyColor.Value ~= value3 or false) and true
			end

			use.Visible = not visible
			cooldown.Visible = visible

			if enabled2 or visible2 then
				if touchInteract ~= nil then
					touchInteract.Visible = not visible2
					touchInteract.Use.Visible = not visible
					touchInteract.Cooldown.Visible = visible
					touchInteractKnife.Visible = visible2
				end
			elseif adornee:FindFirstChild("UseName") then
				use.UseText.Text = adornee.UseName.Value
			else
				use.UseText.Text = "Activate"
			end

			if enabled == false then
				interactGUI.Enabled = true
				v4:Cancel()
				v3:Play()
			end
		else
			v2 = nil

			if enabled == true then
				v4:Play()
				v3:Cancel()
			end

			if touchInteract ~= nil then
				touchInteract.Visible = false
				touchInteractKnife.Visible = false
			end
		end

		enabled = interactGUI.Enabled
	end
end)
local v5 = time()

local function PressInteractButton(_, p, _)
	if (UserInputService:GetLastInputType() == Enum.UserInputType.Keyboard or UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 or UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad2) and p ~= Enum.UserInputState.Begin then
		return
	end

	if v2 and time() - v5 >= 0.1 then
		if v2:FindFirstChild("KnifeBox") and v2.KnifeBox.Value == true then
			return
		end

		v2.Interact:FireServer()
		v5 = time()

		if v2:FindFirstChild("InteractClient") then
			v2.InteractClient:Fire()
		end
	end
end

local ContextActionService = game:GetService("ContextActionService")
ContextActionService:BindAction("InteractKey", PressInteractButton, false, Enum.KeyCode.F)
local ContextActionService2 = game:GetService("ContextActionService")
ContextActionService2:BindAction("InteractGamepadButton", PressInteractButton, false, Enum.KeyCode.ButtonY)
touchInteractButtons.Phone.TouchInteract.Activated:connect(PressInteractButton)
touchInteractButtons.Tablet.TouchInteract.Activated:connect(PressInteractButton)