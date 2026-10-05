local createVector = vector.create
local _ = Enum.KeyCode.ButtonR2
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local localPlayer = game.Players.LocalPlayer
local touchEnabled = UserInputService.TouchEnabled
local isTenFootInterface = GuiService:IsTenFootInterface()
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local function buildOffset()
	local s_ShiftlockX = localPlayer:GetAttribute("S_ShiftlockX")
	local s_ShiftlockY = localPlayer:GetAttribute("S_ShiftlockY")
	local s_ShiftlockZ = localPlayer:GetAttribute("S_ShiftlockZ")
	return CFrame.new(
		typeof(s_ShiftlockX) == "number" and s_ShiftlockX or 1.75,
		typeof(s_ShiftlockY) == "number" and s_ShiftlockY or 0,
		typeof(s_ShiftlockZ) == "number" and s_ShiftlockZ or 0
	)
end

local offset = buildOffset()
localPlayer:GetAttributeChangedSignal("S_ShiftlockX"):Connect(function()
	offset = buildOffset()
end)
localPlayer:GetAttributeChangedSignal("S_ShiftlockY"):Connect(function()
	offset = buildOffset()
end)
localPlayer:GetAttributeChangedSignal("S_ShiftlockZ"):Connect(function()
	offset = buildOffset()
end)
local billboardGui = script.BillboardGui
billboardGui.Parent = workspace.Cutscenes.Billboard
billboardGui.Enabled = true
local v = nil
localPlayer:GetMouse()

local function fn()
	local v2 = nil
	local v3 = 100
	local currentCamera = workspace.CurrentCamera
	local character = localPlayer.Character
	local primaryPart = character.PrimaryPart

	if not character then
		return
	end

	local vector2 = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)

	for _, v4 in pairs(workspace.Live:children()) do
		if v4 == character or v4:GetAttribute("NPC") then
			continue
		end

		local primaryPart2 = v4.PrimaryPart

		if not (v4 and v4:FindFirstChild("Humanoid") and v4.Humanoid.Health ~= 0 and primaryPart2) then
			continue
		end

		local worldToViewportPoint = currentCamera:WorldToViewportPoint(v4.HumanoidRootPart.Position)
		local magnitude = (Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - vector2).magnitude
		local magnitude2 = (primaryPart2.Position - primaryPart.Position).magnitude
		local _ = (primaryPart.Position - primaryPart2.Position).magnitude

		if not (magnitude < v3 and magnitude2 <= 100) then
			continue
		end

		v2 = v4
		v3 = magnitude
	end

	return v2
end

local v2 = nil

if touchEnabled or isTenFootInterface or UserInputService.GamepadEnabled then
	local v3 = nil
	local v4 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isShiftlockActive()
		if touchEnabled then
			return localPlayer:GetAttribute("ShiftLockOn") ~= true
		end

		if isTenFootInterface then
			return localPlayer:GetAttribute("S_ShiftLocks") == true
		end

		return false
	end

	local function updateShiftlockOverlay()
		local s_ShiftlockSkin = localPlayer:GetAttribute("S_ShiftlockSkin")
		local image = typeof(s_ShiftlockSkin) == "string" and s_ShiftlockSkin or ""
		local v6 = image:sub(1, 1) == "H"

		if v6 then
			image = image:sub(2) or image
		end

		local s_ShiftlockScale = localPlayer:GetAttribute("S_ShiftlockScale")
		local v7 = typeof(s_ShiftlockScale) ~= "number" and 1 or s_ShiftlockScale
		local shiftlockActive = isShiftlockActive() -- equivalent call inferred; original call site unknown

		if shiftlockActive and not v6 then
			if not (v3 and v3.Parent) then
				local playerGui = localPlayer:WaitForChild("PlayerGui")
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "MobileShiftlockCursor"
				screenGui.ResetOnSpawn = false
				screenGui.IgnoreGuiInset = true
				screenGui.DisplayOrder = 2147483646
				screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				screenGui.Parent = playerGui
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "CursorImage"
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				imageLabel.BackgroundTransparency = 1
				imageLabel.BorderSizePixel = 0
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
				imageLabel.ZIndex = 999
				imageLabel.Parent = screenGui
				v3 = screenGui
				v4 = imageLabel
			end

			if image == "" then
				image = "rbxasset://textures/MouseLockedCursor.png"
			elseif not (image:match("^rbx") or image:match("^http")) then
				image = "rbxassetid://" .. image
			end

			v4.Image = image
			local v8 = math.max(math.abs(v7), 0.05) * 0.04
			v4.Size = UDim2.new(v8, 0, v8, 0)
			v4.Visible = true
			v3.Enabled = true
		elseif v3 then
			v3.Enabled = false
		end
	end

	localPlayer:GetAttributeChangedSignal("ShiftLockOn"):Connect(updateShiftlockOverlay)
	localPlayer:GetAttributeChangedSignal("S_ShiftLocks"):Connect(updateShiftlockOverlay)
	localPlayer:GetAttributeChangedSignal("S_ShiftlockSkin"):Connect(updateShiftlockOverlay)
	localPlayer:GetAttributeChangedSignal("S_ShiftlockScale"):Connect(updateShiftlockOverlay)
	task.spawn(updateShiftlockOverlay)
	local imageLabel = game.Players.LocalPlayer.PlayerGui:WaitForChild("Emotes"):WaitForChild("ImageLabel")

	if isTenFootInterface or UserInputService.GamepadEnabled then
		imageLabel:GetPropertyChangedSignal("Visible"):Connect(function()
			if imageLabel.Visible then
				local GamepadService = game:GetService("GamepadService")
				GamepadService:EnableGamepadCursor(imageLabel)
			else
				local GamepadService = game:GetService("GamepadService")
				GamepadService:DisableGamepadCursor()
			end
		end)
	end

	local _ = script.ImageLabel
	local v5

	if isTenFootInterface or UserInputService.GamepadEnabled then
		v5 = true
		UserGameSettings.RotationType = Enum.RotationType.CameraRelative
		local v6 = false
		UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.DPadRight then
				v6 = false
			end
		end)
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.DPadLeft then
				if UserGameSettings.RotationType == Enum.RotationType.CameraRelative then
					UserGameSettings.RotationType = Enum.RotationType.MovementRelative
					v5 = false
				else
					v5 = true
					UserGameSettings.RotationType = Enum.RotationType.CameraRelative
				end
			elseif input.KeyCode == Enum.KeyCode.DPadRight then
				local imageLabel2 = game.Players.LocalPlayer.PlayerGui.Emotes.ImageLabel
				v6 = true
				spawn(function()
					local lastTime = tick()

					repeat
						task.wait()
					until tick() - lastTime >= 0.5

					if not v6 then
						return
					end

					if imageLabel2.Visible then
						imageLabel2.Visible = false
						return
					end

					if localPlayer:GetAttribute("Burst") >= 100 then
						return
					end

					imageLabel2.Visible = true
				end)
			end

			if input.KeyCode == Enum.KeyCode.ButtonL3 then
				local v7 = fn()
				local primaryPart = v7 and v7.PrimaryPart

				if v or not primaryPart then
					v = nil
					billboardGui.Adornee = nil
				else
					v = v7
					billboardGui.Adornee = primaryPart
				end
			end
		end)
		local v7 = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA) == "ButtonCross" and "PS" or "Xbox"
		script[v7].Parent = script.Parent
		v2 = script.Parent[v7]
		local burst = v2:FindFirstChild("burst")

		if burst then
			local TweenService = game:GetService("TweenService")
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			local function fadeBurst(p)
				for _, guiObject in ipairs(burst:GetDescendants()) do
					if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
						TweenService:Create(guiObject, tweenInfo, {
							ImageTransparency = p and 0 or 1
						}):Play()
					elseif guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
						TweenService:Create(guiObject, tweenInfo, {
							TextTransparency = p and 0 or 1
						}):Play()
					end
				end
			end

			local _ = v2.Size
			local _ = v2.Position
			v2.Size = UDim2.new(0, 125, 0, 260)
			v2.Position = UDim2.new(0, 0, 1, -265)
			burst.Visible = true

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateBurst()
				if (localPlayer:GetAttribute("Burst") or 0) >= 100 then
					burst.Visible = true
					fadeBurst(true)
				else
					fadeBurst(false)
				end
			end

			updateBurst() -- equivalent call inferred; original call site unknown
			localPlayer:GetAttributeChangedSignal("Burst"):Connect(updateBurst)
		end
	else
		v5 = false
	end

	local function OnStep()
		local currentCamera = workspace.CurrentCamera

		if currentCamera and currentCamera.CameraType ~= Enum.CameraType.Scriptable and not localPlayer:GetAttribute("NoShiftlock") and (currentCamera.Focus.Position - currentCamera.CFrame.Position).Magnitude >= 0.99 then
			local cFrame = currentCamera.CFrame
			local v6 = false

			if v and v.Parent then
				local primaryPart = v.PrimaryPart

				if primaryPart then
					if (primaryPart.Position - currentCamera.CFrame.Position).magnitude > 165 then
						v = nil
						billboardGui.Adornee = nil
					elseif not v:FindFirstChild("BeingGrabbed") then
						cFrame = CFrame.new(cFrame.Position + createVector(0, 0.75, 0), primaryPart.Position) * CFrame.new(
							0.35,
							0,
							0
						)
						v6 = true
					end
				else
					billboardGui.Adornee = nil
					v = nil
				end
			else
				v = nil
				billboardGui.Adornee = nil
			end

			local s_ShiftLocks = false

			if isTenFootInterface then
				s_ShiftLocks = localPlayer:GetAttribute("S_ShiftLocks")
			elseif touchEnabled then
				s_ShiftLocks = not localPlayer:GetAttribute("ShiftLockOn")
			end

			if s_ShiftLocks or v6 then
				UserGameSettings.RotationType = Enum.RotationType.CameraRelative
				local cFrame2 = cFrame * offset
				local focus = CFrame.fromMatrix(
					currentCamera.Focus.Position,
					currentCamera.CFrame.RightVector,
					currentCamera.CFrame.UpVector
				) * offset
				local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart
				local v9 = not primaryPart and 0 or (primaryPart.Position - cFrame2.Position).Magnitude or 0
				local v10 = not primaryPart and 0 or (primaryPart.Position - focus.Position).Magnitude or 0
				local v11 = v9 ~= v9 and 2000000000 or v9
				local v12 = v10 ~= v10 and 2000000000 or v10

				if cFrame2 == cFrame2 and focus == focus and (not primaryPart or v11 < 2000 and v12 < 2000) then
					currentCamera.CFrame = cFrame2
					currentCamera.Focus = focus
				end
			elseif not v5 then
				UserGameSettings.RotationType = Enum.RotationType.MovementRelative
			end
		end
	end

	RunService:BindToRenderStep("ShiftlockMobile", Enum.RenderPriority.Camera.Value + 1, OnStep)
	wait(1.5)
	local v6 = nil

	for _, image in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
		if not (image:IsA("ImageLabel") and image.Name == "EmoteControllerIndicator") then
			continue
		end

		v6 = image
		break
	end

	UserInputService.GamepadConnected:Connect(function()
		RunService:BindToRenderStep("ShiftlockMobile", Enum.RenderPriority.Camera.Value + 1, OnStep)
		v2.Visible = true

		if v6 then
			v6.Visible = true
		end

		billboardGui.Enabled = true
	end)
	UserInputService.GamepadDisconnected:Connect(function()
		v2.Visible = false
		RunService:UnbindFromRenderStep("ShiftlockMobile", Enum.RenderPriority.Camera.Value + 1, OnStep)
		UserGameSettings.RotationType = Enum.RotationType.MovementRelative

		if v6 then
			v6.Visible = false
		end

		billboardGui.Enabled = false
		local GamepadService = game:GetService("GamepadService")
		GamepadService:DisableGamepadCursor()
	end)
else
	billboardGui.Enabled = false
end