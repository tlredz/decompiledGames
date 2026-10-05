local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local AdminAbuseConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AdminAbuseConfig"))
local StarterPlayer = game:GetService("StarterPlayer")
local AdminAbuseTransition = require(StarterPlayer:WaitForChild("StarterPlayerScripts"):WaitForChild("Client"):WaitForChild("AdminAbuseTransition"))
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local onClientEventConnection = nil
local changedConnection = nil
local v5 = nil
local v6 = 0
local v7 = 1
local v8 = false
local v9 = nil
local onClientEventConnection2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getTweenDuration()
	local bossBarTweenDurationSec = AdminAbuseConfig.BossBarTweenDurationSec

	if type(bossBarTweenDurationSec) == "number" and not (bossBarTweenDurationSec <= 0) then
		return bossBarTweenDurationSec
	end

	return 0.38
end

local function refreshBarFromDriver()
	local v10 = v2
	local v11 = v3
	local v12 = v4

	if not v12 or not v10 or v7 <= 0 then
		return
	end

	local v13 = math.clamp(v12.Value, 0, v7)
	local v14 = math.clamp(v13 / v7, 0, 1)
	v10.Size = UDim2.new(v14, 0, 1, 0)

	if v11 then
		local v15 = v7

		if v15 >= 1000000 then
			v11.Text = string.format("%.3fM / %.1fM", v13 / 1000000, v15 / 1000000)
		else
			v11.Text = string.format("%d / %d", math.floor(v13 + 0.5), (math.floor(v15 + 0.5)))
		end
	end
end

local function onBossHpSync(value, max, value2)
	local v10 = v4

	if not (v10 and type(value) == "number") then
		return
	end

	if type(max) ~= "number" then
		max = value
	end

	if max <= 0 or type(value2) == "number" and value2 < v6 then
		return
	end

	if type(value2) == "number" then
		v6 = value2
	end

	v7 = max

	if v5 then
		v5:Cancel()
		v5 = nil
	end

	local v11 = math.clamp(value, 0, max)
	local v12 = not v8

	if not v12 then
		v12 = getTweenDuration() <= 0
	end

	v8 = true

	if v12 then
		v10.Value = v11
		refreshBarFromDriver()
	else
		local tweenDuration = getTweenDuration() -- equivalent call inferred; original call site unknown
		v5 = TweenService:Create(v10, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Value = v11
		})
		v5:Play()
	end
end

local localPlayer = Players.LocalPlayer
local flag = false
local v10 = {
	"rbxassetid://140658568629873",
	"rbxassetid://135791338543784",
	"rbxassetid://1838475719",
	"rbxassetid://1843024859",
	"rbxassetid://1838450596",
	"rbxassetid://1837922109",
	"rbxassetid://1847617400"
}
local v11 = 1
local sound = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopPlaylist()
	if sound then
		sound:Stop()
		sound:Destroy()
		sound = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startPlaylist()
	stopPlaylist() -- equivalent call inferred; original call site unknown
	v11 = 1
	local playNext

	playNext = function()
		if not (v and v.Parent) then
			return
		end

		if v11 > #v10 then
			v11 = 1
		end

		local soundId = v10[v11]
		sound = Instance.new("Sound")
		sound:SetAttribute("IsEventSound", true)
		sound.Name = "BossMusic"
		sound.SoundId = soundId
		sound.Volume = 0.4
		sound.Parent = workspace.CurrentCamera or localPlayer:WaitForChild("PlayerGui")
		sound:Play()
		sound.Ended:Connect(function()
			if sound then
				sound:Destroy()
			end

			v11 += 1
			playNext()
		end)
	end

	playNext()
end

local function onCharacterAdded(character)
	task.wait(0.1)

	if flag or AdminAbuseTransition.isActive() then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	currentCamera.CameraType = Enum.CameraType.Custom
	local humanoid = character:WaitForChild("Humanoid", 10)

	if humanoid then
		currentCamera.CameraSubject = humanoid
	end
end

if localPlayer then
	if localPlayer.Character then
		onCharacterAdded(localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(onCharacterAdded)
end

local cFrame = nil
RunService:BindToRenderStep("LokiiBossCinematicLock", Enum.RenderPriority.Camera.Value + 2, function()
	if flag then
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			currentCamera.CameraSubject = nil

			if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
				currentCamera.CameraType = Enum.CameraType.Scriptable

				if cFrame then
					currentCamera.CFrame = cFrame
				end
			end

			cFrame = currentCamera.CFrame
		end
	else
		cFrame = nil
	end
end)

local function destroyUi()
	if v5 then
		v5:Cancel()
		v5 = nil
	end

	if changedConnection then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	if onClientEventConnection then
		onClientEventConnection:Disconnect()
		onClientEventConnection = nil
	end

	if onClientEventConnection2 then
		onClientEventConnection2:Disconnect()
		onClientEventConnection2 = nil
	end

	if v and v.Parent then
		v:Destroy()
	end

	v = nil
	v2 = nil
	v3 = nil
	v4 = nil
	flag = false
	v6 = 0
	v7 = 1
	v8 = false
	v9 = nil
	stopPlaylist() -- equivalent call inferred; original call site unknown

	if pulseGui then
		pulseGui:Destroy()
		pulseGui = nil
	end
end

local function ensureUi()
	if v then
		return
	end

	local localPlayer2 = Players.LocalPlayer

	if not localPlayer2 then
		return
	end

	local playerGui = localPlayer2:WaitForChild("PlayerGui")
	local pulseBoss = ReplicatedStorage:FindFirstChild("PulseBoss")

	if pulseBoss and pulseBoss:IsA("ScreenGui") then
		pulseGui = pulseBoss:Clone()
		pulseGui.Parent = playerGui
		local frame = pulseGui:FindFirstChild("Frame")

		if frame then
			task.spawn(function()
				while pulseGui and pulseGui.Parent do
					frame.BackgroundTransparency = (math.sin(os.clock() * 3) + 1) / 2 * 0.3 + 0.6
					task.wait()
				end
			end)
		end
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LokiiBossHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 80
	screenGui.Parent = playerGui
	v = screenGui
	local frame = Instance.new("Frame")
	frame.Name = "LevelFrame"
	frame.Parent = screenGui
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.new(0.5, 0, 0, 45)
	frame.Size = UDim2.new(0.6, 0, 0.08, 0)
	local frame2 = Instance.new("Frame")
	frame2.Name = "ProgressBg"
	frame2.Parent = frame
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(38, 17, 0)
	frame2.BackgroundTransparency = 0.4
	frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame2.Size = UDim2.new(1, 0, 0.65, 0)
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = frame2
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "BossIcon"
	imageLabel.Parent = frame2
	imageLabel.AnchorPoint = Vector2.new(0, 0.5)
	imageLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	imageLabel.BorderSizePixel = 0
	imageLabel.Position = UDim2.new(0, -65, 0.5, 0)
	imageLabel.Size = UDim2.new(0, 60, 0, 60)
	imageLabel.Image = "rbxthumb://type=AvatarHeadShot&id=3845375404&w=150&h=150"
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(1, 0)
	uICorner2.Parent = imageLabel
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(255, 215, 0)
	uIStroke.Thickness = 2
	uIStroke.Parent = imageLabel
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TrophyIcon"
	textLabel.Parent = frame2
	textLabel.AnchorPoint = Vector2.new(0, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.new(1, 10, 0.5, 0)
	textLabel.Size = UDim2.new(0, 50, 0, 50)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = "🏆"
	textLabel.TextScaled = true
	textLabel.Parent = frame2
	local frame3 = Instance.new("Frame")
	frame3.Name = "ProgressFill"
	frame3.Parent = frame2
	frame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame3.Size = UDim2.new(0, 0, 1, 0)
	v2 = frame3
	local uICorner3 = Instance.new("UICorner")
	uICorner3.CornerRadius = UDim.new(0.5, 0)
	uICorner3.Parent = frame3
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(167, 126, 69)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(221, 174, 120))
	})
	uIGradient.Rotation = -90
	uIGradient.Parent = frame3
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "LevelText"
	textLabel2.Parent = frame2
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.new(0.4, 0, 1, 0)
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.Text = "LOKII BOSS EVENT"
	textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel2.TextScaled = true
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingBottom = UDim.new(0.15, 0)
	uIPadding.PaddingLeft = UDim.new(0.04, 0)
	uIPadding.PaddingTop = UDim.new(0.15, 0)
	uIPadding.Parent = textLabel2
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "XPText"
	textLabel3.Parent = frame2
	textLabel3.AnchorPoint = Vector2.new(1, 0)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Position = UDim2.new(1, 0, 0, 0)
	textLabel3.Size = UDim2.new(0.4, 0, 1, 0)
	textLabel3.Font = Enum.Font.GothamBold
	textLabel3.Text = "0 / 100M"
	textLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel3.TextScaled = true
	textLabel3.TextXAlignment = Enum.TextXAlignment.Right
	v3 = textLabel3
	local uIPadding2 = Instance.new("UIPadding")
	uIPadding2.PaddingBottom = UDim.new(0.15, 0)
	uIPadding2.PaddingRight = UDim.new(0.04, 0)
	uIPadding2.PaddingTop = UDim.new(0.15, 0)
	uIPadding2.Parent = textLabel3

	for i, v12 in ipairs({ 0.6, 0.9 }) do
		local frame4 = Instance.new("Frame")
		frame4.Name = "PhaseMarker" .. i
		frame4.Parent = frame2
		frame4.AnchorPoint = Vector2.new(0.5, 0)
		frame4.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		frame4.BorderSizePixel = 0
		frame4.ZIndex = 6
		frame4.Position = UDim2.new(v12, 0, 0, 0)
		frame4.Size = UDim2.new(0, 3, 1, 0)
	end

	local frame4 = Instance.new("Frame")
	frame4.Name = "SpeedDisplay"
	frame4.Parent = frame
	frame4.AnchorPoint = Vector2.new(0.5, 0)
	frame4.BackgroundTransparency = 1
	frame4.Position = UDim2.new(0.5, 0, 1, 0)
	frame4.Size = UDim2.new(0.3, 0, 0.6, 0)
	local textLabel4 = Instance.new("TextLabel")
	textLabel4.Name = "SpeedValue"
	textLabel4.Parent = frame4
	textLabel4.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel4.BackgroundTransparency = 1
	textLabel4.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel4.Size = UDim2.new(1, 0, 1, 0)
	textLabel4.Font = Enum.Font.GothamBlack
	textLabel4.Text = "GLOBAL TROPHIES WON"
	textLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel4.TextScaled = true
	textLabel4.TextYAlignment = Enum.TextYAlignment.Bottom
	local frame5 = Instance.new("Frame")
	frame5.Name = "GamepassMultiplierDisplay"
	frame5.Parent = frame
	frame5.AnchorPoint = Vector2.new(0, 0)
	frame5.BackgroundTransparency = 1
	frame5.Position = UDim2.new(0, 0, 1, 0)
	frame5.Size = UDim2.new(0.3, 0, 0.3, 0)
	local textLabel5 = Instance.new("TextLabel")
	textLabel5.Name = "GamepassMultiplierLabel"
	textLabel5.Parent = frame5
	textLabel5.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel5.BackgroundTransparency = 1
	textLabel5.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel5.Size = UDim2.new(1, 0, 1, 0)
	textLabel5.Font = Enum.Font.GothamBlack
	textLabel5.Text = "ACTIVE EVENT x2"
	textLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel5.TextScaled = true
	textLabel5.TextXAlignment = Enum.TextXAlignment.Left
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Parent = textLabel5
	task.spawn(function()
		local total = 0

		while textLabel5 and textLabel5.Parent do
			total += RunService.RenderStepped:Wait() * 0.2
			local v12 = total % 1
			local v13 = (total + 0.1) % 1
			uIGradient2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(v12, 0.7, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(v13, 0.7, 1))
			})
		end
	end)
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "BossHpDisplay"
	numberValue.Value = 0
	numberValue.Parent = screenGui
	v4 = numberValue
	changedConnection = numberValue.Changed:Connect(refreshBarFromDriver)
	startPlaylist() -- equivalent call inferred; original call site unknown
end

local function wireBossRemoteListeners()
	local adminAbuseBossSync = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes"):WaitForChild("AdminAbuseBossSync")

	if adminAbuseBossSync:IsA("RemoteEvent") then
		if onClientEventConnection then
			onClientEventConnection:Disconnect()
		end

		onClientEventConnection = adminAbuseBossSync.OnClientEvent:Connect(function(...)
			ensureUi()

			if v4 then
				onBossHpSync(...)
			end
		end)
	end

	local adminAbuseBossFx = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes"):WaitForChild("AdminAbuseBossFx")

	if adminAbuseBossFx:IsA("RemoteEvent") then
		if onClientEventConnection2 then
			onClientEventConnection2:Disconnect()
		end

		onClientEventConnection2 = adminAbuseBossFx.OnClientEvent:Connect(function(value, data)
			if type(value) ~= "string" or type(data) ~= "table" then
				return
			end

			local function num(p: string, p2: number)
				local v12 = data[p]

				if type(v12) == "number" then
					return v12
				end

				return p2
			end

			if value == "ZoneWarn" then
				local x = data.x
				local v12 = type(x) ~= "number" and 0 or x
				local y = data.y
				local v13 = type(y) ~= "number" and 0 or y
				local z = data.z
				local vector2 = Vector3.new(v12, v13, type(z) ~= "number" and 0 or z)
				local hx = data.hx
				local v14 = type(hx) ~= "number" and 6 or hx
				local hz = data.hz
				local v15 = type(hz) ~= "number" and 6 or hz
				local t = data.t
				local v16 = type(t) ~= "number" and 1.2 or t
				local part = Instance.new("Part")
				part.Name = "BossZoneWarnFx"
				part.Shape = Enum.PartType.Cylinder
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(200, 70, 70)
				part.Size = Vector3.new(4.5, v14 * 2, v15 * 2)
				part.CFrame = CFrame.new(vector2 + createVector(0, -0.2, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
				part.Transparency = 0.4
				part.Parent = workspace
				task.delay(v16, function()
					if part.Parent then
						part:Destroy()
					end
				end)
			elseif value == "ZoneHit" then
				local x = data.x
				local v12 = type(x) ~= "number" and 0 or x
				local y = data.y
				local v13 = type(y) ~= "number" and 0 or y
				local z = data.z
				local vector2 = Vector3.new(v12, v13, type(z) ~= "number" and 0 or z)
				local hx = data.hx
				local v14 = type(hx) ~= "number" and 6 or hx
				local hz = data.hz
				local v15 = type(hz) ~= "number" and 6 or hz
				local style = data.style
				local color

				if (type(style) ~= "string" and "sweet" or style) == "chocolate" then
					color = Color3.fromRGB(113, 54, 0)
				else
					color = Color3.fromRGB(255, 130, 210)
				end

				local part = Instance.new("Part")
				part.Name = "BossZoneJetFx"
				part.Shape = Enum.PartType.Cylinder
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.Material = Enum.Material.SmoothPlastic
				part.Color = color
				part.Size = Vector3.new(2, v14 * 1.5, v15 * 1.5)
				part.CFrame = CFrame.new(vector2 + createVector(0, -10, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
				part.Parent = workspace
				local vector3 = Vector3.new(150, v14 * 1.8, v15 * 1.8)
				local v16 = vector2 + createVector(0, 65, 0)
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = vector3,
					CFrame = CFrame.new(v16) * CFrame.Angles(0, 0, 1.5707963267948966)
				}):Play()
				task.delay(0.4, function()
					local tween = TweenService:Create(
						part,
						TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Transparency = 1,
							Size = createVector(150, 0.1, 0.1)
						}
					)
					tween:Play()
					tween.Completed:Connect(function()
						part:Destroy()
					end)
				end)
				local part2 = Instance.new("Part")
				part2.Anchored = true
				part2.CanCollide = false
				part2.CanQuery = false
				part2.Size = createVector(2, 0.4, 2)
				part2.Transparency = 0.5
				part2.Color = Color3.fromRGB(255, 255, 255)
				part2.CFrame = CFrame.new(vector2 + createVector(0, 0.2, 0))
				part2.Parent = workspace
				TweenService:Create(part2, TweenInfo.new(0.3), {
					Transparency = 1,
					Size = Vector3.new(v14 * 3, 0.4, v15 * 3)
				}):Play()
				task.delay(0.35, function()
					if part2.Parent then
						part2:Destroy()
					end
				end)
			elseif value == "DashTelegraph" then
				local sx = data.sx
				local v12 = type(sx) ~= "number" and 0 or sx
				local sy = data.sy
				local v13 = type(sy) ~= "number" and 0 or sy
				local sz = data.sz
				local v14 = type(sz) ~= "number" and 0 or sz
				local lx = data.lx
				local v15 = type(lx) ~= "number" and 0 or lx
				local ly = data.ly
				local v16 = type(ly) ~= "number" and 0 or ly
				local lz = data.lz
				local v17 = type(lz) ~= "number" and 0 or lz
				local r = data.r
				local v18 = type(r) ~= "number" and 11 or r
				local t = data.t
				local v19 = type(t) ~= "number" and 2.5 or t
				local v20 = math.min(v13, v16) + 0.35
				local vector2 = Vector3.new(v12, v20, v14)
				local vector3 = Vector3.new(v15, v20, v17)
				local magnitude = (vector3 - vector2).Magnitude
				local v21 = (vector2 + vector3) * 0.5
				local part = Instance.new("Part")
				part.Name = "BossDashTrailFx"
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(255, 50, 80)
				part.Transparency = 0.28
				part.Size = Vector3.new(math.clamp(v18 * 0.75, 6, 32), 1.7, (math.max(magnitude, 0.05)))
				local cFrame2

				if magnitude > 0.05 then
					cFrame2 = CFrame.lookAt(v21 + createVector(0, 0.85, 0), vector3 + createVector(0, 0.85, 0))
				else
					cFrame2 = CFrame.new(v21 + createVector(0, 0.85, 0))
				end

				part.CFrame = cFrame2
				part.Parent = workspace
				local part2 = Instance.new("Part")
				part2.Name = "BossDashLandFx"
				part2.Shape = Enum.PartType.Cylinder
				part2.Anchored = true
				part2.CanCollide = false
				part2.CanQuery = false
				part2.Material = Enum.Material.Neon
				part2.Color = Color3.fromRGB(255, 90, 110)
				part2.Size = Vector3.new(1.7, v18 * 2, v18 * 2)
				part2.CFrame = CFrame.new((Vector3.new(v15, v20 + 0.85, v17))) * CFrame.Angles(0, 0, 1.5707963267948966)
				part2.Transparency = 0.45
				part2.Parent = workspace
				local tween = TweenService:Create(
					part2,
					TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Transparency = 0.2
					}
				)
				local tween2 = TweenService:Create(
					part2,
					TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Transparency = 0.55
					}
				)
				tween:Play()
				tween.Completed:Connect(function()
					tween2:Play()
				end)
				task.delay(v19, function()
					if part.Parent then
						part:Destroy()
					end

					if part2.Parent then
						part2:Destroy()
					end
				end)
			elseif value == "CircleWarn" then
				local x = data.x
				local v12 = type(x) ~= "number" and 0 or x
				local y = data.y
				local v13 = type(y) ~= "number" and 0 or y
				local z = data.z
				local v14 = type(z) ~= "number" and 0 or z
				local r = data.r
				local v15 = type(r) ~= "number" and 26 or r
				local t = data.t
				local v16 = type(t) ~= "number" and 2.2 or t
				local part = Instance.new("Part")
				part.Name = "BossCircleWarnFx"
				part.Shape = Enum.PartType.Cylinder
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(235, 45, 65)
				part.Size = Vector3.new(1.7, v15 * 2, v15 * 2)
				part.CFrame = CFrame.new(v12, v13 + 0.85, v14) * CFrame.Angles(0, 0, 1.5707963267948966)
				part.Transparency = 0.52
				part.Parent = workspace
				local part2 = Instance.new("Part")
				part2.Name = "BossCircleWarnRingFx"
				part2.Shape = Enum.PartType.Cylinder
				part2.Anchored = true
				part2.CanCollide = false
				part2.CanQuery = false
				part2.Material = Enum.Material.Neon
				part2.Color = Color3.fromRGB(255, 120, 70)
				part2.Size = Vector3.new(0.18, v15 * 2 + 4, v15 * 2 + 4)
				part2.CFrame = CFrame.new(v12, v13 + 0.04, v14) * CFrame.Angles(0, 0, 1.5707963267948966)
				part2.Transparency = 0.65
				part2.Parent = workspace
				local tween = TweenService:Create(
					part,
					TweenInfo.new(math.min(0.4, v16 * 0.18), Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Transparency = 0.22
					}
				)
				local tween2 = TweenService:Create(
					part2,
					TweenInfo.new(math.min(0.45, v16 * 0.2), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Transparency = 0.38
					}
				)
				tween:Play()
				tween2:Play()
				task.delay(v16, function()
					if part.Parent then
						part:Destroy()
					end

					if part2.Parent then
						part2:Destroy()
					end
				end)
			elseif value == "DashHit" then
				local x = data.x
				local v12 = type(x) ~= "number" and 0 or x
				local y = data.y
				local v13 = type(y) ~= "number" and 0 or y
				local z = data.z
				local vector2 = Vector3.new(v12, v13, type(z) ~= "number" and 0 or z)
				local part = Instance.new("Part")
				part.Shape = Enum.PartType.Ball
				part.Anchored = true
				part.CanCollide = false
				part.Size = createVector(6, 6, 6)
				part.Transparency = 0.65
				part.Color = Color3.fromRGB(255, 50, 80)
				part.CFrame = CFrame.new(vector2 + createVector(0, 2, 0))
				part.Parent = workspace
				TweenService:Create(part, TweenInfo.new(0.2), {
					Transparency = 1,
					Size = createVector(18, 18, 18)
				}):Play()
				task.delay(0.22, function()
					if part.Parent then
						part:Destroy()
					end
				end)
			elseif value == "PlaySound" then
				local id = data.id

				if type(id) ~= "string" then
					return
				end

				local vol = data.vol
				local volume = type(vol) ~= "number" and 1 or vol
				local pitch = data.pitch
				local playbackSpeed = type(pitch) ~= "number" and 1 or pitch
				local global = data.global == true
				local parent

				if global then
					parent = workspace.CurrentCamera or localPlayer:FindFirstChild("PlayerGui")
				else
					local x = data.x
					local v15 = type(x) ~= "number" and 0 or x
					local y = data.y
					local v16 = type(y) ~= "number" and 0 or y
					local z = data.z
					local vector2 = Vector3.new(v15, v16, type(z) ~= "number" and 0 or z)
					parent = Instance.new("Part")
					parent.Transparency = 1
					parent.Anchored = true
					parent.CanCollide = false
					parent.CFrame = CFrame.new(vector2)
					parent.Parent = workspace
				end

				if not parent then
					return
				end

				local sound2 = Instance.new("Sound")
				sound2.SoundId = id
				sound2.Volume = volume
				sound2.PlaybackSpeed = playbackSpeed
				sound2.Parent = parent
				local minDist = data.minDist
				local rollOffMinDistance = type(minDist) ~= "number" and 0 or minDist
				local maxDist = data.maxDist
				local rollOffMaxDistance = type(maxDist) ~= "number" and 0 or maxDist

				if rollOffMinDistance > 0 then
					sound2.RollOffMinDistance = rollOffMinDistance
				end

				if rollOffMaxDistance > 0 then
					sound2.RollOffMaxDistance = rollOffMaxDistance
				end

				sound2:Play()
				sound2.Ended:Connect(function()
					if global then
						sound2:Destroy()
					else
						parent:Destroy()
					end
				end)
				task.delay(10, function()
					if global or not (parent and parent.Parent) then
						if global and sound2.Parent then
							sound2:Destroy()
						end
					else
						parent:Destroy()
					end
				end)
			elseif value == "StopSound" then
				local id = data.id

				if type(id) ~= "string" then
					return
				end

				for _, v12 in { workspace.CurrentCamera, localPlayer:FindFirstChild("PlayerGui") } do
					if not v12 then
						continue
					end

					for _, sound2 in v12:GetChildren() do
						if not (sound2:IsA("Sound") and sound2.SoundId == id) then
							continue
						end

						sound2:Stop()
						sound2:Destroy()
					end
				end
			elseif value == "ScreenShake" then
				local intensity = data.intensity
				local v12 = type(intensity) ~= "number" and 1 or intensity
				local duration = data.duration
				local v13 = type(duration) ~= "number" and 0.5 or duration
				local x = data.x
				local y = data.y
				local z = data.z
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					if type(x) == "number" and type(y) == "number" and type(z) == "number" then
						local magnitude = (currentCamera.CFrame.Position - Vector3.new(x, y, z)).Magnitude

						if magnitude > 150 then
							return
						else
							v12 *= math.clamp(1 - magnitude / 150, 0, 1)
						end
					end

					if v12 <= 0.01 then
						return
					else
						task.spawn(function()
							local lastTime = os.clock()

							while os.clock() - lastTime < v13 do
								local v14 = os.clock() - lastTime
								local v15 = v12 * (1 - v14 / v13)
								currentCamera.CFrame *= CFrame.new(
									(math.random() - 0.5) * v15,
									(math.random() - 0.5) * v15,
									(math.random() - 0.5) * v15
								)
								RunService.RenderStepped:Wait()
							end
						end)
					end
				end
			elseif value == "DustPuff" then
				local x = data.x
				local v12 = type(x) ~= "number" and 0 or x
				local y = data.y
				local v13 = type(y) ~= "number" and 0 or y
				local z = data.z
				local vector2 = Vector3.new(v12, v13, type(z) ~= "number" and 0 or z)
				local part = Instance.new("Part")
				part.Transparency = 1
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = CFrame.new(vector2)
				part.Parent = workspace
				local attachment = Instance.new("Attachment")
				attachment.Parent = part
				local particleEmitter = Instance.new("ParticleEmitter")
				particleEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
				particleEmitter.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 2),
					NumberSequenceKeypoint.new(1, 0)
				})
				particleEmitter.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.2, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				})
				particleEmitter.Lifetime = NumberRange.new(0.5, 1)
				particleEmitter.Rate = 0
				particleEmitter.Speed = NumberRange.new(5, 10)
				particleEmitter.SpreadAngle = Vector2.new(0, 360)
				particleEmitter.Parent = attachment
				particleEmitter:Emit(15)
				task.delay(1.5, function()
					part:Destroy()
				end)
			elseif value == "MapBreak" then
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					local cFrame2 = currentCamera.CFrame
					task.spawn(function()
						for _ = 1, 8 do
							if not currentCamera or currentCamera.Parent == nil then
								break
							end

							currentCamera.CFrame = cFrame2 * CFrame.new(
								(math.random() - 0.5) * 0.8,
								(math.random() - 0.5) * 0.6,
								0
							)
							task.wait(0.03)
						end

						if currentCamera then
							currentCamera.CFrame = cFrame2
						end
					end)
				end
			elseif value == "SetCamera" then
				local currentCamera = workspace.CurrentCamera

				if not currentCamera then
					return
				end

				local type2 = data.type

				if type2 == "Reset" then
					task.wait(0.1)
					flag = false
					currentCamera.CameraType = Enum.CameraType.Custom
					local character = Players.LocalPlayer.Character
					local humanoid = character and character:FindFirstChild("Humanoid")

					if humanoid then
						currentCamera.CameraSubject = humanoid
					end
				else
					local cx = data.cx
					local v12 = type(cx) ~= "number" and 0 or cx
					local cy = data.cy
					local v13 = type(cy) ~= "number" and 0 or cy
					local cz = data.cz
					local cframe = CFrame.new(v12, v13, type(cz) ~= "number" and 0 or cz)
					local tx = data.tx
					local v14 = type(tx) ~= "number" and 0 or tx
					local ty = data.ty
					local v15 = type(ty) ~= "number" and 0 or ty
					local tz = data.tz
					local vector2 = Vector3.new(v14, v15, type(tz) ~= "number" and 0 or tz)
					local cframe2 = CFrame.lookAt(cframe.Position, vector2)
					flag = true
					currentCamera.CameraType = Enum.CameraType.Scriptable
					currentCamera.CameraSubject = nil

					if type2 == "Fixed" then
						currentCamera.CFrame = cframe2
					elseif type2 == "Tween" then
						local dur = data.dur
						local v16 = type(dur) ~= "number" and 2 or dur
						TweenService:Create(
							currentCamera,
							TweenInfo.new(v16, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								CFrame = cframe2
							}
						):Play()
					end
				end
			elseif value == "Presentation" then
				flag = true
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					currentCamera.CameraType = Enum.CameraType.Scriptable
					currentCamera.CameraSubject = nil
				end

				task.wait(1)

				if not currentCamera then
					return
				end

				local bossRig_Live = workspace:FindFirstChild("BossRig_Live")

				if not bossRig_Live then
					for _, child in workspace:GetChildren() do
						if not child.Name:find("Boss") then
							continue
						end

						bossRig_Live = child
						break
					end
				end

				local v12 = not bossRig_Live and createVector(0, 20, -320) or bossRig_Live:GetPivot().Position
				local _ = currentCamera.CFrame
				local v13 = v12 + createVector(0, 25, 60)
				local cframe = CFrame.lookAt(v13, v12)
				local tween = TweenService:Create(
					currentCamera,
					TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						CFrame = cframe
					}
				)
				tween:Play()
				tween.Completed:Connect(function()
					ensureUi()
					task.wait(0.5)
					flag = false
					currentCamera.CameraType = Enum.CameraType.Custom
					local character = localPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						currentCamera.CameraSubject = humanoid
					end
				end)
			end
		end)
	end
end

local function bossModuleStop()
	destroyUi()
end

local function bossModuleFire()
	destroyUi()
	wireBossRemoteListeners()
end

return {
	Stop = bossModuleStop,
	Fire = bossModuleFire,
	Hidden = true,
	IsAdminAbuse = true
}