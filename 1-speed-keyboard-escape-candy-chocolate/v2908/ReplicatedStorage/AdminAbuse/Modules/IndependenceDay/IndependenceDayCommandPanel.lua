local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local FireworksController = require(script.Parent.FireworksController)
local IndependenceDayConfig = require(script.Parent.IndependenceDayConfig)
local IndependenceDayCutscenes = require(script.Parent.IndependenceDayCutscenes)
local OrbController = require(script.Parent.Parent.Shared.OrbController)
local localPlayer, playerGui

if RunService:IsClient() then
	localPlayer = Players.LocalPlayer
	playerGui = localPlayer.PlayerGui
else
	localPlayer = nil
	playerGui = nil
end

local color = Color3.fromRGB(24, 24, 26)
local color2 = Color3.fromRGB(38, 38, 42)
local color3 = Color3.fromRGB(48, 48, 54)
local color4 = Color3.fromRGB(210, 255, 80)
local color5 = Color3.fromRGB(235, 235, 238)
local robotoMono = Enum.Font.RobotoMono
local equals = Enum.KeyCode.Equals
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = false
local inputBeganConnection = nil
local independenceDayCommandTrustedChangedConnection = nil
local inputChangedConnection = nil
local v7 = {}
local flag = false
local v8 = nil
local v9 = nil
local endedConnection = nil
local v10 = nil
local v11 = {}

local function stopJetsSequence()
	if flag then
		RunService:UnbindFromRenderStep("IndependenceDayJetsCameraFollow")
		flag = false
	end

	if endedConnection then
		endedConnection:Disconnect()
		endedConnection = nil
	end

	if v8 and v8.IsPlaying then
		v8:Stop(0)
	end

	v8 = nil

	if v9 then
		IndependenceDayCutscenes.hideRig(v9)
		v9 = nil
	end

	if v10 then
		v10:Stop()
		v10 = nil
	end

	if v11 then
		for _, highlight in ipairs(v11) do
			if highlight and highlight:IsA("Highlight") then
				highlight.Enabled = false
			end
		end
	end
end

local function runJetsSequence(_)
	stopJetsSequence()
	local cutsceneRigsFolder = IndependenceDayCutscenes.getCutsceneRigsFolder()

	if not cutsceneRigsFolder then
		warn("[IndependenceDayCommandPanel] RunJetsSequence: CutsceneRigs not found")
		return
	end

	local jets = cutsceneRigsFolder:FindFirstChild("Jets")

	if not (jets and jets:IsA("Model")) then
		warn("[IndependenceDayCommandPanel] RunJetsSequence: Jets rig not found")
		return
	end

	v9 = jets
	IndependenceDayCutscenes.showRig(jets)
	local track = IndependenceDayCutscenes.loadTrack(jets, IndependenceDayConfig.ANIM_IDS.Command.Jets)

	if track then
		v8 = track
		track:Play(0, 1, 1)
		local jet_1 = jets:FindFirstChild("Jet_1", true)

		if jet_1 and jet_1:IsA("BasePart") then
			RunService:BindToRenderStep(
				"IndependenceDayJetsCameraFollow",
				Enum.RenderPriority.Camera.Value + 1,
				function(p: number)
					if not jet_1.Parent then
						return
					end

					local currentCamera = Workspace.CurrentCamera

					if not currentCamera then
						return
					end

					local v12 = currentCamera.CFrame + Vector3.new(
						0,
						IndependenceDayConfig.COMMAND_CAMERA_FOLLOW_HEIGHT_OFFSET,
						0
					)
					currentCamera.CFrame = v12:Lerp(
						CFrame.lookAt(v12.Position, jet_1.Position),
						1 - math.exp(-p / IndependenceDayConfig.COMMAND_CAMERA_FOLLOW_SMOOTH_TIME)
					)
				end
			)
			flag = true

			for _, part in ipairs(jets:GetChildren()) do
				if not (part:IsA("BasePart") and part ~= jets.PrimaryPart) then
					continue
				end

				local v12 = part:FindFirstChildOfClass("Highlight")

				if not v12 then
					v12 = Instance.new("Highlight")
					v12.Parent = part
					v12.FillColor = Color3.fromHex(part:GetAttribute("HighlightColor")) or Color3.fromHex("#FF0000")
					table.insert(v11, v12)
				end

				v12.Enabled = true
			end

			local SFX = jet_1:FindFirstChild("SFX")

			if SFX and not v10 then
				SFX.RollOffMaxDistance = 5000
				SFX.Volume = 5
				v10 = SFX
				SFX:Play()
				task.delay(track.Length - 3, function()
					local tween = TweenService:Create(SFX, TweenInfo.new(2), {
						Volume = 0
					})
					tween:Play()
					tween.Completed:Once(function(_)
						tween:Destroy()
					end)
				end)
				print("played sfx")
			end
		else
			warn("[IndependenceDayCommandPanel] RunJetsSequence: Jet_1 part not found — skipping camera follow")
		end

		endedConnection = track.Ended:Once(stopJetsSequence)
		task.delay(track.Length - 0.5, function()
			if v8 == track then
				stopJetsSequence()
			end
		end)
	else
		warn("[IndependenceDayCommandPanel] RunJetsSequence: failed to load Command.Jets animation")
		IndependenceDayCutscenes.hideRig(jets)
		v9 = nil
	end
end

local function spawnWinOrbsEffect(p)
	if not v3 then
		warn("[IndependenceDayCommandPanel] SpawnWinOrbs: win orb remote not ready")
		return
	end

	local arg = type(p) == "table" and p.arg or 0

	if type(arg) ~= "number" or arg <= 0 then
		return
	end

	local adminAbuse = Workspace:FindFirstChild("AdminAbuse")
	local map = adminAbuse and adminAbuse:FindFirstChild("Map")
	local child = map and map:FindFirstChild(IndependenceDayConfig.MAP_LIVE_NAME)

	if not child then
		warn("[IndependenceDayCommandPanel] SpawnWinOrbs: live map not found")
		return
	end

	if not v4 then
		v4 = OrbController.new(v3, {
			despawnSec = IndependenceDayConfig.WIN_ORB_DESPAWN_SEC
		})
	end

	if not v4:isScanned() then
		v4:scan(child)
	end

	v4:spawnFromZone(arg)
end

local function launchFireworksEffect(p)
	local v12 = type(p) ~= "table" and 0 or p.arg or 0

	if type(v12) ~= "number" or v12 <= 0 then
		return
	end

	local adminAbuse = Workspace:FindFirstChild("AdminAbuse")
	local map = adminAbuse and adminAbuse:FindFirstChild("Map")
	local child = map and map:FindFirstChild(IndependenceDayConfig.MAP_LIVE_NAME)

	if not child then
		warn("[IndependenceDayCommandPanel] LaunchFireworks: live map not found")
		return
	end

	local v13

	if type(p) == "table" then
		v13 = p.colors or nil
	end

	FireworksController.FireMany(child, v12, v13)
end

local v12 = {
	RunJetsSequence = runJetsSequence,
	SpawnWinOrbs = spawnWinOrbsEffect,
	LaunchFireworks = launchFireworksEffect
}

local function isTrusted()
	return localPlayer:GetAttribute("IndependenceDayCommandTrusted") == true
end

local function bindDrag(frame)
	local v13 = false
	local v14 = nil
	local position = nil
	local position2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update(input)
		local v15 = input.Position - position
		local v16 = position2
		frame.Position = UDim2.new(v16.X.Scale, v16.X.Offset + v15.X, v16.Y.Scale, v16.Y.Offset + v15.Y)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v13 = true
			position = input.Position
			position2 = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					v13 = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			v14 = input
		end
	end)
	inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if input == v14 and v13 then
			update(input) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function buildPanel()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "IndependenceDayCommandPanel"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 100
	screenGui.Enabled = false
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "Root"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0.15, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Size = UDim2.new(0, 240, 0, 0)
	frame.BackgroundColor3 = color
	frame.BorderSizePixel = 0
	frame.ZIndex = 2
	frame.Parent = screenGui
	bindDrag(frame)
	local frame2 = Instance.new("Frame")
	frame2.Name = "Stripe"
	frame2.BackgroundColor3 = color4
	frame2.BorderSizePixel = 0
	frame2.Size = UDim2.new(0, 4, 1, 0)
	frame2.ZIndex = 3
	frame2.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.new(0, 12, 0, 10)
	textLabel.Size = UDim2.new(1, -20, 0, 20)
	textLabel.Font = robotoMono
	textLabel.Text = "independenceday_cmd"
	textLabel.TextColor3 = color4
	textLabel.TextSize = 14
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 3
	textLabel.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "List"
	frame3.BackgroundTransparency = 1
	frame3.Position = UDim2.new(0, 10, 0, 36)
	frame3.Size = UDim2.new(1, -20, 0, 0)
	frame3.AutomaticSize = Enum.AutomaticSize.Y
	frame3.ZIndex = 3
	frame3.Parent = frame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Padding = UDim.new(0, 4)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = frame3
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingBottom = UDim.new(0, 10)
	uIPadding.Parent = frame3
	local count = 0

	for k, v13 in pairs(IndependenceDayConfig.COMMANDS) do
		count += 1
		local hasArg = v13.HasArg == true
		local frame4 = Instance.new("Frame")
		frame4.Name = k
		frame4.BackgroundTransparency = 1
		frame4.Size = UDim2.new(1, 0, 0, 36)
		frame4.LayoutOrder = count
		frame4.ZIndex = 4
		frame4.Parent = frame3
		local uIListLayout2 = Instance.new("UIListLayout")
		uIListLayout2.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout2.Padding = UDim.new(0, 4)
		uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout2.Parent = frame4
		local textBox

		if hasArg then
			textBox = Instance.new("TextBox")
			textBox.Name = "Arg"
			textBox.BackgroundColor3 = color2
			textBox.BorderSizePixel = 0
			textBox.Size = UDim2.new(0, 60, 1, 0)
			textBox.LayoutOrder = 1
			textBox.Font = robotoMono
			textBox.PlaceholderText = v13.ArgPlaceholder or "Count"
			textBox.Text = v13.ArgDefault or ""
			textBox.TextColor3 = color5
			textBox.TextSize = 14
			textBox.ClearTextOnFocus = false
			textBox.ZIndex = 5
			textBox.Parent = frame4
		else
			textBox = nil
		end

		local textButton = Instance.new("TextButton")
		textButton.Name = "Button"
		textButton.AutoButtonColor = false
		textButton.BackgroundColor3 = color2
		textButton.BorderSizePixel = 0
		local size

		if hasArg then
			size = UDim2.new(1, -64, 1, 0)
		else
			size = UDim2.new(1, 0, 1, 0)
		end

		textButton.Size = size
		textButton.LayoutOrder = 2
		textButton.Font = robotoMono
		textButton.Text = "  " .. (v13.DisplayName or k)
		textButton.TextColor3 = color5
		textButton.TextSize = 14
		textButton.TextXAlignment = Enum.TextXAlignment.Left
		textButton.ZIndex = 4
		textButton.MouseEnter:Connect(function()
			textButton.BackgroundColor3 = color3
		end)
		local v16 = textButton
		textButton.MouseLeave:Connect(function()
			v16.BackgroundColor3 = color2
		end)
		local hasColorPicker = v13.HasColorPicker == true
		local v18 = v13
		local v20 = k
		textButton.MouseButton1Click:Connect(function()
			if not v2 then
				return
			end

			if not hasArg then
				v2:FireServer(v20)
				return
			end

			local v21 = math.clamp(
				math.floor(tonumber(textBox.Text) or tonumber(v18.ArgDefault) or 1),
				1,
				v18.ArgMax or IndependenceDayConfig.WIN_ORB_MAX_COUNT
			)

			if not hasColorPicker then
				v2:FireServer(v20, v21)
				return
			end

			local v22 = {}

			for k2, v23 in IndependenceDayConfig.FIREWORK_COLOR_ORDER do
				if v7[v23] then
					table.insert(v22, v23)
				end
			end

			v2:FireServer(v20, v21, v22)
		end)
		textButton.Parent = frame4

		if not hasColorPicker then
			continue
		end

		count += 1
		local frame5 = Instance.new("Frame")
		frame5.Name = k .. "Colors"
		frame5.BackgroundTransparency = 1
		frame5.Size = UDim2.new(1, 0, 0, 40)
		frame5.LayoutOrder = count
		frame5.ZIndex = 4
		frame5.Parent = frame3
		local uIListLayout3 = Instance.new("UIListLayout")
		uIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout3.Padding = UDim.new(0, 2)
		uIListLayout3.Parent = frame5
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "Selected"
		textLabel2.BackgroundTransparency = 1
		textLabel2.Size = UDim2.new(1, 0, 0, 16)
		textLabel2.LayoutOrder = 1
		textLabel2.Font = robotoMono
		textLabel2.Text = "Current colors selected: None (default)"
		textLabel2.TextColor3 = color5
		textLabel2.TextSize = 12
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.ZIndex = 4
		textLabel2.Parent = frame5
		local frame6 = Instance.new("Frame")
		frame6.Name = "Swatches"
		frame6.BackgroundTransparency = 1
		frame6.Size = UDim2.new(1, 0, 0, 20)
		frame6.LayoutOrder = 2
		frame6.ZIndex = 4
		frame6.Parent = frame5
		local uIListLayout4 = Instance.new("UIListLayout")
		uIListLayout4.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout4.Padding = UDim.new(0, 4)
		uIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout4.Parent = frame6
		local v21 = {}

		local function refreshColorPickerDisplay()
			local v24 = {}

			for k2, v25 in IndependenceDayConfig.FIREWORK_COLOR_ORDER do
				if v7[v25] then
					table.insert(v24, v25)
					local v26 = v21[v25]

					if v26 then
						v26.Enabled = true
					end
				else
					local v26 = v21[v25]

					if v26 then
						v26.Enabled = false
					end
				end
			end

			textLabel2.Text = "Current colors selected: " .. (not (#v24 > 0) and "None (default)" or table.concat(
				v24,
				", "
			))
		end

		for k2, name in IndependenceDayConfig.FIREWORK_COLOR_ORDER do
			local textButton2 = Instance.new("TextButton")
			textButton2.Name = name
			textButton2.AutoButtonColor = false
			textButton2.BackgroundColor3 = IndependenceDayConfig.FIREWORK_COLORS[name]
			textButton2.BorderSizePixel = 0
			textButton2.Size = UDim2.new(0, 40, 1, 0)
			textButton2.LayoutOrder = k2
			textButton2.Text = ""
			textButton2.ZIndex = 5
			textButton2.Parent = frame6
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Name = "Selected"
			uIStroke.Color = color4
			uIStroke.Thickness = 2
			uIStroke.Enabled = false
			uIStroke.Parent = textButton2
			v21[name] = uIStroke
			local v25 = name
			local refreshColorPickerDisplay2 = refreshColorPickerDisplay
			textButton2.MouseButton1Click:Connect(function()
				v7[v25] = not v7[v25]
				refreshColorPickerDisplay2()
			end)
		end

		refreshColorPickerDisplay()
	end

	return screenGui
end

local function ensurePanel()
	if not v5 then
		v5 = buildPanel()
	end

	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPanelVisible(flag2: boolean)
	v6 = flag2

	if flag2 then
		if not v5 then
			v5 = buildPanel()
		end

		v5.Enabled = true
	elseif v5 then
		v5.Enabled = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function togglePanel()
	if localPlayer:GetAttribute("IndependenceDayCommandTrusted") ~= true then
		return
	end

	setPanelVisible(not v6) -- equivalent call inferred; original call site unknown
end

local IndependenceDayCommandPanel = {}

function IndependenceDayCommandPanel.init(object, p, p2)
	v = object
	v2 = p
	v3 = p2
	object:onFire("Command", function(p3)
		if type(p3) ~= "table" then
			return
		end

		local v13 = v12[p3.command]

		if v13 then
			v13(p3)
		end
	end)
	inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == equals then
			togglePanel() -- equivalent call inferred; original call site unknown
		end
	end)
	independenceDayCommandTrustedChangedConnection = localPlayer:GetAttributeChangedSignal("IndependenceDayCommandTrusted"):Connect(function()
		if localPlayer:GetAttribute("IndependenceDayCommandTrusted") ~= true then
			setPanelVisible(false) -- equivalent call inferred; original call site unknown
		end
	end)
end

function IndependenceDayCommandPanel.Stop()
	stopJetsSequence()

	if v4 then
		v4:destroy()
		v4 = nil
	end

	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end

	if independenceDayCommandTrustedChangedConnection then
		independenceDayCommandTrustedChangedConnection:Disconnect()
		independenceDayCommandTrustedChangedConnection = nil
	end

	if inputChangedConnection then
		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
	end

	if v5 then
		v5:Destroy()
		v5 = nil
	end

	v6 = false
	v = nil
	v2 = nil
	v3 = nil
end

return IndependenceDayCommandPanel