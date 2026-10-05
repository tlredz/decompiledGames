local EggDeliveryRules = require(game.ReplicatedStorage.GameServices:WaitForChild("EggDeliveryRules"))
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local localPlayer = Players.LocalPlayer
local Audio = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Audio"))
local General = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("General"))
local game2 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local eggBroke = game2:WaitForChild("EggBroke")
local eggBreaking = localPlayer:WaitForChild("PlayerGui"):WaitForChild("EggBreaking")
local eggBreaking2 = eggBreaking:WaitForChild("EggBreaking")
local breakTime = eggBreaking2:WaitForChild("BreakTime")
local bar = breakTime:WaitForChild("Bar")
local timer = breakTime:WaitForChild("Timer")
local chase = SoundService:WaitForChild("Music"):WaitForChild("Chase")
local SFX = SoundService:WaitForChild("SFX")
local eggBreak = SFX:WaitForChild("Game"):WaitForChild("EggBreak")
local musicOverride = localPlayer:WaitForChild("PlayerScripts"):WaitForChild("Audio"):WaitForChild("MusicOverride")

-- equivalent calls inferred from this helper; original call sites unknown
local function GetBasket()
	return localPlayer:FindFirstChild("Basket")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CarriedCount()
	local basket = GetBasket() -- equivalent call inferred; original call site unknown
	return basket and #basket:GetChildren() or 0
end

local function SoonestBreak()
	local basket = GetBasket() -- equivalent call inferred; original call site unknown

	if not basket then
		return nil
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local v2 = nil
	local breakSeconds = nil
	local v3 = nil
	local v4 = nil

	for _, child in basket:GetChildren() do
		local volcanoUntil = tonumber(child:GetAttribute("VolcanoUntil"))

		if volcanoUntil and serverTimeNow < volcanoUntil then
			continue
		end

		local breakAt = tonumber(child:GetAttribute("BreakAt"))
		local breakPausedAt = tonumber(child:GetAttribute("BreakPausedAt"))
		local v5 = breakPausedAt or serverTimeNow

		if not (breakAt and breakAt == breakAt and math.abs(breakAt) < 1e999 and v5 < breakAt + 0.5) then
			continue
		end

		local v6 = breakAt - v5

		if not (not v2 or v6 < v2) then
			continue
		end

		v4 = breakPausedAt ~= nil
		v3 = child:GetAttribute("Escaping") == true
		breakSeconds = tonumber(child:GetAttribute("BreakSeconds")) or math.max(v6, 1)
		v2 = v6
	end

	return v2, breakSeconds, v3, v4
end

local function BasketPaused()
	local basket = GetBasket() -- equivalent call inferred; original call site unknown

	if not basket then
		return false
	end

	for _, child in basket:GetChildren() do
		if child:GetAttribute("BreakPausedAt") ~= nil then
			return true
		end
	end

	return false
end

task.spawn(function()
	local eggTimerPause = game2:WaitForChild("EggTimerPause", 60)

	if not eggTimerPause then
		return
	end

	local v = false
	local cameraTypeChangedConnection = nil

	local function ReportCamera()
		local currentCamera = workspace.CurrentCamera
		local v2

		if currentCamera == nil then
			v2 = false
		else
			v2 = currentCamera.CameraType == Enum.CameraType.Scriptable
		end

		if v2 and not v and CarriedCount() > 0 then
			v = true
			eggTimerPause:FireServer(true)
		elseif not v2 and v then
			v = false
			eggTimerPause:FireServer(false)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function WatchCamera()
		if cameraTypeChangedConnection then
			cameraTypeChangedConnection:Disconnect()
			cameraTypeChangedConnection = nil
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			cameraTypeChangedConnection = currentCamera:GetPropertyChangedSignal("CameraType"):Connect(ReportCamera)
		end

		ReportCamera()
	end

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(WatchCamera)
	WatchCamera() -- equivalent call inferred; original call site unknown
end)
local backgroundColor3 = bar.BackgroundColor3
local textColor3 = timer.TextColor3
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 60, 60)
local total = 0
local v = 0
local v2 = 0

local function Bump(p, p2)
	return (math.exp(-(p / p2) ^ 2))
end

local function AdvanceBeat(p, value)
	local v3 = 1 - math.clamp(p / 10, 0, 1)
	local v4 = math.min(v3 * 1.8 + 1.2, 3)
	local v5 = total
	total += v4 * math.clamp(value, 0, 0.1)
	local v6 = total % 1
	v = (math.cos(v6 * 3.141592653589793 * 2) + 1) / 2
	v2 = math.max(math.exp(-(math.min(v6, 1 - v6) / 0.08) ^ 2), 0.55 * math.exp(-((v6 - 0.3) / 0.07) ^ 2))
	return math.floor(total) > math.floor(v5) or v5 == 0, v3
end

local clone = nil

local function PlayTick(p)
	if not clone then
		local pop = SFX:FindFirstChild("Pop") or SFX:FindFirstChild("Click")

		if not pop then
			return
		end

		clone = pop:Clone()
		clone.Name = "EggBreakTick"
		clone.Parent = SFX
	end

	clone.PlaybackSpeed = 0.85 + 0.75 * p
	clone.Volume = 0.3 + 0.35 * p
	clone.TimePosition = 0
	clone:Play()
end

local anchorPoint = timer.AnchorPoint

if anchorPoint ~= Vector2.new(0.5, 0.5) then
	local size = timer.Size
	timer.Position = UDim2.new(
		timer.Position.X.Scale + size.X.Scale * (0.5 - anchorPoint.X),
		timer.Position.X.Offset + size.X.Offset * (0.5 - anchorPoint.X),
		timer.Position.Y.Scale + size.Y.Scale * (0.5 - anchorPoint.Y),
		timer.Position.Y.Offset + size.Y.Offset * (0.5 - anchorPoint.Y)
	)
	timer.AnchorPoint = Vector2.new(0.5, 0.5)
end

local position = timer.Position
local size = timer.Size
local uIScale = timer:FindFirstChildOfClass("UIScale")

if uIScale then
	uIScale:Destroy()
end

local highlight = nil
local flag = false

local function OverheadEgg()
	local character = localPlayer.Character

	if not character then
		return nil
	end

	for _, child in character:GetChildren() do
		if child:HasTag("EggPack") then
			return child:FindFirstChild("DisplayEgg")
		end
	end

	return nil
end

local object = setmetatable({}, {
	__mode = "k"
})

local function HideExpiredDisplay()
	local folder = OverheadEgg()

	if not folder then
		return
	end

	local breakAt = tonumber(folder:GetAttribute("BreakAt"))

	if not breakAt or workspace:GetServerTimeNow() < breakAt + 0.5 or BasketPaused() or object[folder] then
		return
	end

	object[folder] = true

	local function Hide(descendant)
		if descendant:IsA("BasePart") then
			descendant.LocalTransparencyModifier = 1
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
			descendant:Clear()
		elseif descendant:IsA("Trail") then
			descendant.Enabled = false
			descendant:Clear()
		elseif descendant:IsA("Beam") or descendant:IsA("BillboardGui") or descendant:IsA("Highlight") or descendant:IsA("Light") then
			descendant.Enabled = false
		end
	end

	for _, descendant in folder:GetDescendants() do
		Hide(descendant)
	end
end

local function SetWarning(p, p2)
	if p then
		flag = true
		bar.BackgroundColor3 = backgroundColor3:Lerp(color2, p2 * 0.85):Lerp(color, v * 0.3)
		timer.TextColor3 = textColor3:Lerp(color2, 0.35 + 0.65 * p2)
		local v3 = 1 + v2 * (0.18 + 0.22 * p2)
		timer.Size = UDim2.new(size.X.Scale * v3, size.X.Offset * v3, size.Y.Scale * v3, size.Y.Offset * v3)
		timer.Rotation = math.sin(total * 3.141592653589793 * 2) * (1.5 + 3.5 * p2)
		local parent = OverheadEgg()

		if parent then
			if not highlight or highlight.Parent ~= parent then
				if highlight then
					highlight:Destroy()
				end

				highlight = Instance.new("Highlight")
				highlight.Name = "BreakWarning"
				highlight.FillColor = color2
				highlight.OutlineColor = color2
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.Parent = parent
			end

			highlight.FillTransparency = 1 - v * 0.2 * (0.5 + 0.5 * p2)
			highlight.OutlineTransparency = 1 - (v * 0.65 + 0.35)
		elseif highlight then
			highlight:Destroy()
			highlight = nil
		end
	else
		if flag then
			flag = false
			bar.BackgroundColor3 = backgroundColor3
			timer.TextColor3 = textColor3
			timer.Position = position
			timer.Size = size
			timer.Rotation = 0
		end

		total = 0

		if highlight then
			highlight:Destroy()
			highlight = nil
		end
	end
end

local gameMessages = localPlayer.PlayerGui:WaitForChild("Reusable"):FindFirstChild("GameMessages")
local position2 = gameMessages and gameMessages.Position
local v3 = false

local function ShiftMessages(p)
	if not gameMessages or p == v3 then
		return
	end

	v3 = p

	if not p then
		gameMessages.Position = position2
		return
	end

	local v4 = math.max(breakTime.AbsolutePosition.Y + breakTime.AbsoluteSize.Y - gameMessages.AbsolutePosition.Y, 0) + 12
	gameMessages.Position = position2 + UDim2.fromOffset(0, v4)
end

local v4 = false

local function SetChase(p)
	if p == v4 then
		return
	end

	v4 = p
	musicOverride:Fire(p and chase or nil)
end

local carryEgg = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("CarryEgg")
local track = nil
local v5 = nil
local v6 = false

local function GetCarryTrack()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	if track and v5 == animator then
		return track
	end

	track = animator:LoadAnimation(carryEgg)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = true
	v5 = animator
	return track
end

local function SetCarry(p)
	if p then
		local carryTrack = GetCarryTrack()

		if not carryTrack then
			v6 = false
			return
		end

		if p and not carryTrack.IsPlaying then
			carryTrack:Play(0.2)
		elseif not p and carryTrack.IsPlaying then
			carryTrack:Stop(0.2)
		end

		v6 = p
	else
		v6 = false

		if track then
			pcall(function()
				if track.IsPlaying then
					track:Stop(0.2)
				end
			end)
		end
	end
end

localPlayer.CharacterAdded:Connect(function()
	track = nil
	v5 = nil
	v6 = false
end)

local function HoldingEggTool()
	local character = localPlayer.Character

	if not character then
		return false
	end

	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") and tool:HasTag("Egg") then
			return true
		end
	end

	return false
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggChaseVignette"
screenGui.IgnoreGuiInset = true
screenGui.ScreenInsets = Enum.ScreenInsets.None
screenGui.ClipToDeviceSafeArea = false
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 90
screenGui.Enabled = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local color3 = Color3.fromRGB(120, 0, 0)
local v7 = {}

local function MakeEdge(name, size2, position3, rotation)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = color3
	frame.BorderSizePixel = 0
	frame.Size = size2
	frame.Position = position3
	frame.BackgroundTransparency = 0
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = rotation
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Parent = frame
	frame.Parent = screenGui
	table.insert(v7, {
		Frame = frame,
		Gradient = uIGradient
	})
end

MakeEdge("Top", UDim2.new(1, 120, 0.28, 60), UDim2.fromOffset(-60, -60), 90)
MakeEdge("Bottom", UDim2.new(1, 120, 0.28, 60), UDim2.new(0, -60, 0.72, 0), -90)
MakeEdge("Left", UDim2.new(0.28, 60, 1, 120), UDim2.fromOffset(-60, -60), 0)
MakeEdge("Right", UDim2.new(0.28, 60, 1, 120), UDim2.new(0.72, 0, 0, -60), 180)
local total2 = 0

local function StepVignette(p, p2, p3)
	total2 += ((p and 1 or 0) - total2) * math.clamp(p3 * 4, 0, 1)

	if total2 < 0.01 then
		if screenGui.Enabled then
			screenGui.Enabled = false
		end
	else
		screenGui.Enabled = true
		local v8, v9

		if p and p2 then
			v8 = v * 0.2 + 0.8
			v9 = 0.45 + 0.2 * p2
		else
			v8 = (math.sin(os.clock() * 1.5) + 1) * 0.2 / 2 + 0.8
			v9 = 0.45
		end

		local v10 = 1 - v9 * total2 * v8

		for _, v11 in v7 do
			v11.Gradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, v10),
				NumberSequenceKeypoint.new(1, 1)
			})
		end
	end
end

local now = os.clock()
local v8 = {}

local function SafeEffect(p, callback, ...)
	if os.clock() < (v8[p] or 0) then
		return
	end

	local success, result = pcall(callback, ...)

	if not success then
		v8[p] = os.clock() + 1

		if p == "carry" then
			track = nil
			v5 = nil
			v6 = false
		end

		warn("[BreakTimer] " .. p .. " recovered: " .. tostring(result))
	end
end

local function ClearExpiredHUD()
	eggBreaking2.Visible = false
	total2 = 0
	screenGui.Enabled = false
	timer.Text = ""
	bar.Size = UDim2.new(0, 0, 1, 0)
	SafeEffect("warning", SetWarning, false)
	SafeEffect("messages", ShiftMessages, false)
	SafeEffect("chase", SetChase, false)

	if clone then
		SafeEffect("tick-stop", function()
			clone:Stop()
		end)
	end

	SafeEffect("expired-display", HideExpiredDisplay)
end

local eggArrivalClaim = game2:WaitForChild("EggArrivalClaim")
local object2 = setmetatable({}, {
	__mode = "k"
})
local v9 = 0

local function SendArrivalClaim(character)
	local serverTimeNow = workspace:GetServerTimeNow()

	if serverTimeNow < v9 then
		return
	end

	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local basket = GetBasket() -- equivalent call inferred; original call site unknown

	if not (humanoidRootPart and basket) then
		return
	end

	local names = {}

	for _, child in basket:GetChildren() do
		local breakAt = tonumber(child:GetAttribute("BreakAt"))

		if not (not object2[child] or serverTimeNow - object2[child] >= 1) or not breakAt or not (serverTimeNow <= breakAt + 0.5) or child:GetAttribute("Delivering") then
			continue
		end

		object2[child] = serverTimeNow
		table.insert(names, child.Name)

		if #names >= 64 then
			break
		end
	end

	if #names == 0 then
		return
	end

	v9 = serverTimeNow + 0.25
	eggArrivalClaim:FireServer(serverTimeNow, humanoidRootPart.Position, names)
end

local plot = nil
local v10 = 0

local function PredictHomeArrival(character)
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local now2 = os.clock()

	if v10 <= now2 or not (plot and plot.Parent) then
		v10 = os.clock() + 0.5
		plot = General:GetPlot(localPlayer)
	end

	local data = plot and plot:FindFirstChild("Data")
	local owner = data and data:FindFirstChild("Owner")

	if owner and owner.Value == localPlayer then
		return EggDeliveryRules.Contains(plot:FindFirstChild("Baseplate"), humanoidRootPart.Position)
	end

	return false
end

local lastTime = nil
local v11 = nil

local function NoteHome(p)
	if p and not lastTime then
		local soonestBreak = SoonestBreak()
		lastTime = os.clock()
		v11 = soonestBreak

		if soonestBreak then
			print(string.format("[EggChase] home on your screen with %.1fs left", (math.max(soonestBreak, 0))))
		end
	elseif not p and lastTime then
		lastTime = nil
		v11 = nil
	end
end

local function LiveTimer()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return nil
	end

	local predictHomeArrival = PredictHomeArrival(character)
	NoteHome(predictHomeArrival)

	if not predictHomeArrival then
		return SoonestBreak()
	end

	SendArrivalClaim(character)
	return nil
end

local total3 = 0
RunService.Heartbeat:Connect(function(dt)
	total3 += dt

	if total3 < 0.1 then
		return
	end

	total3 = 0

	if not LiveTimer() then
		ClearExpiredHUD()
	end
end)
localPlayer.CharacterRemoving:Connect(ClearExpiredHUD)
RunService.RenderStepped:Connect(function()
	local now2 = os.clock()
	local v12 = now2 - now
	now = now2
	local v13, v14, v15, v16 = LiveTimer()

	if v13 == nil then
		ClearExpiredHUD()
		SafeEffect("carry", SetCarry, CarriedCount() > 0 or HoldingEggTool())
	else
		local v17 = math.max(v13, 0)
		eggBreaking2.Visible = true
		local text = v15 and "Egg Will Return" or "Egg Will Break"

		if eggBreaking2.Text ~= text then
			eggBreaking2.Text = text
		end

		timer.Text = string.format("%.1fs", math.floor(v17 * 10) / 10)
		local v19 = not (v14 and v14 > 0) and 0 or math.clamp(v17 / v14, 0, 1) or 0
		bar.Size = UDim2.new(1 * v19, 0, 1, 0)
		SafeEffect("carry", SetCarry, CarriedCount() > 0 or HoldingEggTool())
		SafeEffect("chase", SetChase, true)
		SafeEffect("messages", ShiftMessages, true)
		local v22

		if v17 <= 10 then
			v22 = not v16
		else
			v22 = false
		end

		local v23

		if v22 then
			local v24
			v24, v23 = AdvanceBeat(v17, v12)

			if v24 then
				SafeEffect("tick", PlayTick, v23)
			end
		end

		SafeEffect("warning", SetWarning, v22, v23)
		SafeEffect("vignette", StepVignette, true, v23, v12)
		SafeEffect("expired-display", HideExpiredDisplay)
	end
end)
local TweenService = game:GetService("TweenService")
local firstTime = eggBreaking:WaitForChild("FirstTime")
local anchorPoint2 = firstTime.AnchorPoint

if anchorPoint2 ~= Vector2.new(0.5, 0.5) then
	local size2 = firstTime.Size
	firstTime.Position = UDim2.new(
		firstTime.Position.X.Scale + size2.X.Scale * (0.5 - anchorPoint2.X),
		firstTime.Position.X.Offset + size2.X.Offset * (0.5 - anchorPoint2.X),
		firstTime.Position.Y.Scale + size2.Y.Scale * (0.5 - anchorPoint2.Y),
		firstTime.Position.Y.Offset + size2.Y.Offset * (0.5 - anchorPoint2.Y)
	)
	firstTime.AnchorPoint = Vector2.new(0.5, 0.5)
end

local uIScale2 = firstTime:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
uIScale2.Scale = 0
uIScale2.Parent = firstTime
local flag2 = false

local function PlayFirstTimeHint()
	if flag2 then
		return
	end

	flag2 = true
	uIScale2.Scale = 0
	firstTime.Visible = true
	local tween = TweenService:Create(
		uIScale2,
		TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	)
	tween:Play()
	tween.Completed:Wait()
	task.wait(1)
	local tween2 = TweenService:Create(uIScale2, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Scale = 0
	})
	tween2:Play()
	tween2.Completed:Wait()
	firstTime.Visible = false
	flag2 = false
end

localPlayer:GetAttributeChangedSignal("EggBreakHint"):Connect(function()
	if localPlayer:GetAttribute("EggBreakHint") then
		task.spawn(PlayFirstTimeHint)
	end
end)
local Effects = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Effects"))

local function NoteOwnBreak(p, p2, instance)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local v12

	if instance then
		if character == nil then
			v12 = false
		else
			v12 = instance:IsDescendantOf(character)
		end
	elseif typeof(p) == "Vector3" and humanoidRootPart ~= nil then
		v12 = (p - humanoidRootPart.Position).Magnitude < 8
	else
		v12 = false
	end

	if v12 and lastTime then
		warn(string.format(
			"[EggChase] your %s broke %.1fs after this screen showed you home with %.1fs left - the server didnt see you arrive in time",
			tostring(p2),
			os.clock() - lastTime,
			(math.max(v11 or 0, 0))
		))
	end
end

eggBroke.OnClientEvent:Connect(function(p, p2, instance)
	NoteOwnBreak(p, p2, instance)
	local eggCrack = instance and instance.Parent and instance:FindFirstChild("EggCrack", true)

	if eggCrack then
		Effects:PlayVFX(eggCrack)
	elseif typeof(p) == "Vector3" then
		Audio:PlayAtPosition(eggBreak, p)
	end
end)