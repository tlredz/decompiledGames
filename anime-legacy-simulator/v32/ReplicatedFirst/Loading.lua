local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local color = Color3.new(1, 1, 1)
local uDim = UDim2.fromScale(0.75, 0.75)
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo4 = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local tweenInfo5 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local clone = ReplicatedFirst:WaitForChild("LoadingScreen"):Clone()
local dots = clone:WaitForChild("Dots")
local logo = clone:WaitForChild("Logo")
local banner = clone:WaitForChild("Banner")
local background = clone:WaitForChild("Background")
local accent = clone:WaitForChild("Accent")
local random = Random.new()
local frames = {}
local v = 0
local v2 = 0
local flag = true
local v3 = false

local function GetDots()
	for _, frame in dots:GetChildren() do
		if frame:IsA("Frame") and tonumber(frame.Name) then
			table.insert(frames, frame)
		end
	end

	table.sort(frames, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
end

local function SetProgress(p: number)
	local v4 = math.clamp(math.floor(p * #frames + 1e-6), 0, #frames)

	if v4 <= v then
		return
	end

	for i = v + 1, v4 do
		TweenService:Create(frames[i], tweenInfo, {
			BackgroundColor3 = color
		}):Play()
	end

	v = v4
end

local function BuildSteps(number: number, p: number)
	local total = 0
	local total2 = 0
	local result = {}

	for _ = 1, random:NextInteger(12, 20) do
		local number2 = random:NextNumber(0.2, 1.8)
		local number3 = random:NextNumber(0.15, 0.9)
		local number4 = random:NextNumber()

		if number4 < 0.15 then
			number3 *= 3
		elseif number4 > 0.85 then
			number2 *= 2.5
		end

		total += number2
		total2 += number3
		table.insert(result, {
			Weight = number2,
			Pause = number3
		})
	end

	for _, v4 in result do
		v4.Weight = v4.Weight / total * p
		v4.Pause = v4.Pause / total2 * number
	end

	return result
end

local function RunSteps()
	local number = random:NextNumber(6, 12)
	local v4 = (#frames - 1) / #frames
	local v5 = 0

	for _, v6 in BuildSteps(number, v4) do
		task.wait(v6.Pause)
		v5 = math.min(v5 + v6.Weight, v4)
		SetProgress(v5)
	end
end

local function WaitReady()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	while not localPlayer:GetAttribute("Loaded") do
		localPlayer:GetAttributeChangedSignal("Loaded"):Wait()
	end

	local success, omni = pcall(require, ReplicatedStorage:WaitForChild("Omni"))

	if success then
		omni:WaitInitialization()
	end

	if not localPlayer.Character then
		localPlayer.CharacterAdded:Wait()
	end

	v3 = true
end

local function Jump(p)
	v2 += 1
	local tween = TweenService:Create(p, tweenInfo2, {
		Position = UDim2.new(p.Position.X, UDim.new(-1, 0))
	})
	tween:Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(p, tweenInfo3, {
		Position = UDim2.new(p.Position.X, UDim.new(0, 0))
	})
	tween2:Play()
	tween2.Completed:Wait()
	v2 -= 1
end

local function JumpLoop()
	while flag do
		for _, v4 in frames do
			if not flag then
				break
			end

			task.spawn(Jump, v4)
			task.wait(0.08)
		end

		task.wait(tweenInfo2.Time + tweenInfo3.Time + 0.35)
	end
end

local function Exit()
	while v2 > 0 do
		task.wait()
	end

	for _, v4 in frames do
		TweenService:Create(v4, tweenInfo4, {
			Size = UDim2.fromScale(0, 0)
		}):Play()
		task.wait(0.04)
	end

	task.wait(tweenInfo4.Time)
	local tween = TweenService:Create(logo, tweenInfo5, {
		Position = UDim2.fromScale(0.5, 0.5),
		Size = uDim,
		ImageTransparency = 1
	})
	TweenService:Create(background, tweenInfo5, {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(banner, tweenInfo5, {
		ImageTransparency = 1
	}):Play()

	for _, frame in accent:GetChildren() do
		if frame:IsA("Frame") then
			TweenService:Create(frame, tweenInfo5, {
				BackgroundTransparency = 1
			}):Play()
		end
	end

	tween:Play()
	tween.Completed:Wait()
	clone:Destroy()
end

GetDots()
clone.Enabled = true
clone.Parent = playerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()
task.spawn(WaitReady)
task.spawn(JumpLoop)
RunSteps()
local v4 = os.clock() + 30

while not v3 and os.clock() < v4 do
	task.wait()
end

SetProgress(1)
task.wait(0.3)
flag = false
Exit()