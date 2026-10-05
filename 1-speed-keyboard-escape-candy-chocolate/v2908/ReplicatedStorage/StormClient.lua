local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local LightingSnapshot = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("LightingSnapshot"))
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local StormClient = {}
local storm = EventsConfig.Storm

if not storm then
	return StormClient
end

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local flag = false
local child = ReplicatedStorage:FindFirstChild(storm.LightningFolder or "Ligtning")

local function onLightningEvent(p)
	if type(p) ~= "table" or not p.position then
		return
	end

	local position = p.position
	local hitParticles = child and child:FindFirstChild("HitParticles")

	if hitParticles then
		local clone = hitParticles:Clone()
		clone.Position = position
		clone.Parent = workspace
		Debris:AddItem(clone, 3)
		task.delay(0.3, function()
			if clone and clone.Parent then
				for _, descendant in ipairs(clone:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
						descendant.Enabled = false
					end
				end
			end
		end)
	end

	local lightningSound = child and child:FindFirstChild("LightningSound")

	if lightningSound then
		local clone = lightningSound:Clone()
		clone.Volume = storm.LightningSoundVolume or 2
		clone.Parent = playerGui
		clone:Play()
		Debris:AddItem(clone, 5)
	end
end

local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function saveOriginalSky()
	if flag2 then
		return
	end

	flag2 = true
	LightingSnapshot.acquireShared()

	if not Lighting:FindFirstChild("StormCC") then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "StormCC"
		colorCorrectionEffect.Parent = Lighting
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rgbTable(list)
	if type(list) == "table" and #list >= 3 then
		return Color3.fromRGB(list[1], list[2], list[3])
	end

	return Color3.fromRGB(255, 255, 255)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applySky(sky, instant)
	if not sky then
		return
	end

	saveOriginalSky() -- equivalent call inferred; original call site unknown

	if instant then
		if sky.Brightness then
			Lighting.Brightness = sky.Brightness
		end

		if sky.Ambient then
			local parent = Lighting
			local ambient = rgbTable(sky.Ambient) -- equivalent call inferred; original call site unknown
			parent.Ambient = ambient
		end

		if sky.OutdoorAmbient then
			local parent = Lighting
			local outdoorAmbient = rgbTable(sky.OutdoorAmbient) -- equivalent call inferred; original call site unknown
			parent.OutdoorAmbient = outdoorAmbient
		end

		if sky.FogEnd then
			Lighting.FogEnd = sky.FogEnd
		end

		if sky.FogColor then
			local parent = Lighting
			local fogColor = rgbTable(sky.FogColor) -- equivalent call inferred; original call site unknown
			parent.FogColor = fogColor
		end

		local stormCC = Lighting:FindFirstChild("StormCC")

		if stormCC then
			if sky.Saturation then
				stormCC.Saturation = sky.Saturation
			end

			if sky.ColorTint then
				local tintColor = rgbTable(sky.ColorTint) -- equivalent call inferred; original call site unknown
				stormCC.TintColor = tintColor
			end
		end
	else
		local skyTween = sky.SkyTween or 2
		local tweenInfo = TweenInfo.new(skyTween, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local v = {}

		if sky.Brightness then
			v.Brightness = sky.Brightness
		end

		if sky.Ambient then
			local ambient = rgbTable(sky.Ambient) -- equivalent call inferred; original call site unknown
			v.Ambient = ambient
		end

		if sky.OutdoorAmbient then
			local outdoorAmbient = rgbTable(sky.OutdoorAmbient) -- equivalent call inferred; original call site unknown
			v.OutdoorAmbient = outdoorAmbient
		end

		if sky.FogEnd then
			v.FogEnd = sky.FogEnd
		end

		if sky.FogColor then
			local fogColor = rgbTable(sky.FogColor) -- equivalent call inferred; original call site unknown
			v.FogColor = fogColor
		end

		if next(v) then
			TweenService:Create(Lighting, tweenInfo, v):Play()
		end

		local stormCC = Lighting:FindFirstChild("StormCC")

		if stormCC then
			local v2 = {}

			if sky.Saturation then
				v2.Saturation = sky.Saturation
			end

			if sky.ColorTint then
				local tintColor = rgbTable(sky.ColorTint) -- equivalent call inferred; original call site unknown
				v2.TintColor = tintColor
			end

			if next(v2) then
				TweenService:Create(stormCC, tweenInfo, v2):Play()
			end
		end
	end
end

local function restoreSky()
	if not flag2 then
		return
	end

	flag2 = false
	local skyRestoreDuration = storm.SkyRestoreDuration or 3
	LightingSnapshot.releaseShared(skyRestoreDuration)
	local tweenInfo = TweenInfo.new(skyRestoreDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local stormCC = Lighting:FindFirstChild("StormCC")

	if stormCC then
		TweenService:Create(stormCC, tweenInfo, {
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
		task.delay(skyRestoreDuration + 0.5, function()
			if stormCC and stormCC.Parent then
				stormCC:Destroy()
			end
		end)
	end
end

local function onWaveEvent(data)
	if type(data) ~= "table" then
		return
	end

	local action = data.action

	if action == "start" then
		local wave = data.wave

		if wave and wave.Sky then
			applySky(wave.Sky, data.instant)
		end
	else
		if action == "stop" then
			return
		end

		if action == "end" then
			restoreSky()
		end
	end
end

local function handleSyncEvent(p)
	if type(p) ~= "table" then
		return
	end

	if p.skyWaveIndex and p.skyWaveIndex > 0 then
		local waves = storm.Waves

		if waves and waves[p.skyWaveIndex] then
			local wave = waves[p.skyWaveIndex]

			if wave.Sky then
				applySky(wave.Sky, true) -- equivalent call inferred; original call site unknown
			end
		end
	end
end

local adminUserId = storm.AdminUserId or 0
local v = nil
local flag3 = false
local v2 = {}
local stormAdmin = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function fireAdmin(action, args)
	if not stormAdmin then
		return
	end

	stormAdmin:FireServer({
		action = action,
		args = args,
		allServers = flag3
	})
end

local function createAdminPanel()
	if localPlayer.UserId ~= adminUserId then
		return
	end

	local color = Color3.fromRGB(30, 30, 35)
	local color2 = Color3.fromRGB(40, 40, 48)
	local color3 = Color3.fromRGB(40, 160, 70)
	local color4 = Color3.fromRGB(180, 50, 50)
	local color5 = Color3.fromRGB(50, 110, 190)
	local color6 = Color3.fromRGB(130, 60, 180)
	local color7 = Color3.fromRGB(230, 230, 235)
	local color8 = Color3.fromRGB(160, 160, 170)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StormAdminPanel"
	screenGui.DisplayOrder = 200
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.Parent = playerGui
	v = screenGui
	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.Size = UDim2.new(0, 340, 0, 400)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = 0.02
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	local v3 = false
	local position = nil
	local position2 = nil
	local UserInputService = game:GetService("UserInputService")
	frame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y - frame.AbsolutePosition.Y <= 38 then
			v3 = true
			position = input.Position
			position2 = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if v3 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local v4 = input.Position - position
			frame.Position = UDim2.new(
				position2.X.Scale,
				position2.X.Offset + v4.X,
				position2.Y.Scale,
				position2.Y.Offset + v4.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v3 = false
		end
	end)
	local uICorner = Instance.new("UICorner", frame)
	uICorner.CornerRadius = UDim.new(0, 10)
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(80, 80, 100)
	uIStroke.Thickness = 1.5
	uIStroke.Parent = frame
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, -16, 1, -50)
	scrollingFrame.Position = UDim2.new(0, 8, 0, 42)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.Parent = frame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = UDim.new(0, 6)
	uIListLayout.Parent = scrollingFrame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0, 4)
	uIPadding.PaddingRight = UDim.new(0, 4)
	uIPadding.PaddingTop = UDim.new(0, 4)
	uIPadding.Parent = scrollingFrame
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 0, 38)
	textLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	textLabel.BackgroundTransparency = 0.1
	textLabel.BorderSizePixel = 0
	textLabel.Text = "STORM CONTROL"
	textLabel.TextColor3 = color7
	textLabel.TextSize = 16
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = frame
	local uICorner_2 = Instance.new("UICorner", textLabel)
	uICorner_2.CornerRadius = UDim.new(0, 10)
	local textButton = Instance.new("TextButton")
	textButton.Size = UDim2.new(0, 30, 0, 30)
	textButton.Position = UDim2.new(1, -34, 0, 4)
	textButton.BackgroundColor3 = color4
	textButton.BackgroundTransparency = 0.3
	textButton.Text = "X"
	textButton.TextColor3 = color7
	textButton.TextSize = 14
	textButton.Font = Enum.Font.GothamBold
	textButton.BorderSizePixel = 0
	textButton.Parent = frame
	local uICorner_3 = Instance.new("UICorner", textButton)
	uICorner_3.CornerRadius = UDim.new(0, 6)
	textButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
	end)
	local count = 0

	local function sectionHeader(text)
		count += 1
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Size = UDim2.new(1, 0, 0, 22)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = text
		textLabel2.TextColor3 = color8
		textLabel2.TextSize = 11
		textLabel2.Font = Enum.Font.GothamBold
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.LayoutOrder = count
		textLabel2.Parent = scrollingFrame
	end

	local function makeBtn(text, color9, frame2, uDim)
		local textButton2 = Instance.new("TextButton")
		textButton2.Size = uDim or UDim2.new(0, 100, 0, 30)
		textButton2.BackgroundColor3 = color9
		textButton2.Text = text
		textButton2.TextColor3 = color7
		textButton2.TextSize = 12
		textButton2.Font = Enum.Font.GothamBold
		textButton2.BorderSizePixel = 0
		textButton2.AutoButtonColor = true
		textButton2.Parent = frame2
		local uICorner = Instance.new("UICorner", textButton2)
		uICorner.CornerRadius = UDim.new(0, 6)
		return textButton2
	end

	local function rowFrame(value)
		count += 1
		local frame2 = Instance.new("Frame")
		frame2.Size = UDim2.new(1, 0, 0, value or 34)
		frame2.BackgroundTransparency = 1
		frame2.LayoutOrder = count
		frame2.Parent = scrollingFrame
		return frame2
	end

	sectionHeader("STATUS")
	count += 1
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.new(1, 0, 0, 34)
	frame2.BackgroundTransparency = 1
	frame2.LayoutOrder = count
	frame2.Parent = scrollingFrame
	frame2.BackgroundColor3 = color2
	frame2.BackgroundTransparency = 0.3
	local uICorner_4 = Instance.new("UICorner", frame2)
	uICorner_4.CornerRadius = UDim.new(0, 6)
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(1, -12, 1, 0)
	textLabel2.Position = UDim2.new(0, 6, 0, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Text = "Wave: None | Lightning: OFF"
	textLabel2.TextColor3 = Color3.fromRGB(120, 220, 160)
	textLabel2.TextSize = 11
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.TextWrapped = true
	textLabel2.Parent = frame2
	v2.main = textLabel2
	sectionHeader("SCOPE")
	count += 1
	local frame3 = Instance.new("Frame")
	frame3.Size = UDim2.new(1, 0, 0, 30)
	frame3.BackgroundTransparency = 1
	frame3.LayoutOrder = count
	frame3.Parent = scrollingFrame
	local btn = makeBtn("This Server", color5, frame3, UDim2.new(0.48, 0, 1, 0))
	btn.Position = UDim2.new(0, 0, 0, 0)
	local btn2 = makeBtn("All Servers", color2, frame3, UDim2.new(0.48, 0, 1, 0))
	btn2.Position = UDim2.new(0.52, 0, 0, 0)
	btn2.BackgroundTransparency = 0.3

	local function updateScopeVisual()
		if flag3 then
			btn.BackgroundColor3 = color2
			btn.BackgroundTransparency = 0.3
			btn2.BackgroundColor3 = color6
			btn2.BackgroundTransparency = 0
		else
			btn.BackgroundColor3 = color5
			btn.BackgroundTransparency = 0
			btn2.BackgroundColor3 = color2
			btn2.BackgroundTransparency = 0.3
		end
	end

	btn.MouseButton1Click:Connect(function()
		flag3 = false
		btn.BackgroundColor3 = color5
		btn.BackgroundTransparency = 0
		btn2.BackgroundColor3 = color2
		btn2.BackgroundTransparency = 0.3
	end)
	btn2.MouseButton1Click:Connect(function()
		flag3 = true
		btn.BackgroundColor3 = color2
		btn.BackgroundTransparency = 0.3
		btn2.BackgroundColor3 = color6
		btn2.BackgroundTransparency = 0
	end)
	sectionHeader("EVENT")
	count += 1
	local frame4 = Instance.new("Frame")
	frame4.Size = UDim2.new(1, 0, 0, 34)
	frame4.BackgroundTransparency = 1
	frame4.LayoutOrder = count
	frame4.Parent = scrollingFrame
	local btn3 = makeBtn("Full Auto", color3, frame4, UDim2.new(0.48, -2, 1, 0))
	btn3.Position = UDim2.new(0, 0, 0, 0)
	btn3.MouseButton1Click:Connect(function()
		if not stormAdmin then
			return
		end

		stormAdmin:FireServer({
			action = "fullAuto",
			args = nil,
			allServers = flag3
		})
	end)
	local btn4 = makeBtn("Stop All", color4, frame4, UDim2.new(0.48, -2, 1, 0))
	btn4.Position = UDim2.new(0.52, 0, 0, 0)
	btn4.MouseButton1Click:Connect(function()
		if not stormAdmin then
			return
		end

		stormAdmin:FireServer({
			action = "stopAll",
			args = nil,
			allServers = flag3
		})
	end)
	sectionHeader("WAVES")
	count += 1
	local frame5 = Instance.new("Frame")
	frame5.Size = UDim2.new(1, 0, 0, 34)
	frame5.BackgroundTransparency = 1
	frame5.LayoutOrder = count
	frame5.Parent = scrollingFrame
	local waveIndex = 1
	local textButton2 = Instance.new("TextButton")
	textButton2.Size = UDim2.new(0.36, -2, 1, 0)
	textButton2.Position = UDim2.new(0, 0, 0, 0)
	textButton2.BackgroundColor3 = color2
	textButton2.Text = "Wave 1"
	textButton2.TextColor3 = color7
	textButton2.TextSize = 12
	textButton2.Font = Enum.Font.GothamBold
	textButton2.BorderSizePixel = 0
	textButton2.Parent = frame5
	local uICorner_5 = Instance.new("UICorner", textButton2)
	uICorner_5.CornerRadius = UDim.new(0, 6)
	textButton2.MouseButton1Click:Connect(function()
		local waves = storm.Waves or {}
		waveIndex = waveIndex % #waves + 1
		local wave = waves[waveIndex]
		textButton2.Text = "Wave " .. waveIndex .. (wave and " - " .. wave.Name or "")
	end)
	local btn5 = makeBtn("Start", color3, frame5, UDim2.new(0.3, -2, 1, 0))
	btn5.Position = UDim2.new(0.38, 0, 0, 0)
	btn5.MouseButton1Click:Connect(function()
		fireAdmin("startWave", {
			waveIndex = waveIndex
		}) -- equivalent call inferred; original call site unknown
	end)
	local btn6 = makeBtn("Stop", color4, frame5, UDim2.new(0.3, -2, 1, 0))
	btn6.Position = UDim2.new(0.7, 0, 0, 0)
	btn6.MouseButton1Click:Connect(function()
		if not stormAdmin then
			return
		end

		stormAdmin:FireServer({
			action = "stopWave",
			args = nil,
			allServers = flag3
		})
	end)
	sectionHeader("AMBIANCE / SKY")
	count += 1
	local frame6 = Instance.new("Frame")
	frame6.Size = UDim2.new(1, 0, 0, 34)
	frame6.BackgroundTransparency = 1
	frame6.LayoutOrder = count
	frame6.Parent = scrollingFrame
	local waveIndex2 = 0
	local textButton3 = Instance.new("TextButton")
	textButton3.Size = UDim2.new(0.55, -2, 1, 0)
	textButton3.Position = UDim2.new(0, 0, 0, 0)
	textButton3.BackgroundColor3 = color2
	textButton3.Text = "Normal"
	textButton3.TextColor3 = color7
	textButton3.TextSize = 12
	textButton3.Font = Enum.Font.GothamBold
	textButton3.BorderSizePixel = 0
	textButton3.Parent = frame6
	local uICorner_6 = Instance.new("UICorner", textButton3)
	uICorner_6.CornerRadius = UDim.new(0, 6)
	textButton3.MouseButton1Click:Connect(function()
		local waves = storm.Waves or {}
		waveIndex2 = (waveIndex2 + 1) % (#waves + 1)

		if waveIndex2 == 0 then
			textButton3.Text = "Normal"
			return
		end

		local wave = waves[waveIndex2]
		textButton3.Text = "Wave " .. waveIndex2 .. (wave and " - " .. wave.Name or "")
	end)
	local btn7 = makeBtn("Apply", color5, frame6, UDim2.new(0.43, -2, 1, 0))
	btn7.Position = UDim2.new(0.57, 0, 0, 0)
	btn7.MouseButton1Click:Connect(function()
		if waveIndex2 == 0 then
			fireAdmin("restoreSky", nil) -- equivalent call inferred; original call site unknown
		else
			fireAdmin("applySky", {
				waveIndex = waveIndex2
			}) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function updateAdminStatus(data)
	if not (v2.main and type(data) == "table") then
		return
	end

	local v3 = data.lightning and "ON" or "OFF"
	local v4 = data.fullAuto and " | AUTO" or ""
	v2.main.Text = "Wave: " .. (data.wave or "None") .. " | Lightning: " .. v3 .. v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hookAdminButton()
	if localPlayer.UserId ~= adminUserId then
		return
	end

	task.spawn(function()
		local adminMenuGUI_v2 = playerGui:WaitForChild("AdminMenuGUI_v2", 30)

		if not adminMenuGUI_v2 then
			return
		end

		local panel = adminMenuGUI_v2:WaitForChild("Panel", 10)

		if not panel then
			return
		end

		local stormButton = panel:WaitForChild("StormButton", 10)

		if not stormButton then
			return
		end

		stormButton.MouseButton1Click:Connect(function()
			if v then
				v.Enabled = not v.Enabled
			end
		end)
	end)
end

function StormClient.Init(_)
	if flag then
		return
	end

	flag = true
	remotes:WaitForChild("StormLightning").OnClientEvent:Connect(onLightningEvent)
	remotes:WaitForChild("StormWave").OnClientEvent:Connect(onWaveEvent)
	remotes:WaitForChild("StormSync").OnClientEvent:Connect(handleSyncEvent)

	if localPlayer.UserId == adminUserId then
		stormAdmin = remotes:WaitForChild("StormAdmin")
		remotes:WaitForChild("StormStatus").OnClientEvent:Connect(updateAdminStatus)
		createAdminPanel()
		hookAdminButton() -- equivalent call inferred; original call site unknown
	end
end

return StormClient