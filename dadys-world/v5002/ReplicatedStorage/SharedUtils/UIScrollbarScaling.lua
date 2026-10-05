local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UIScrollbarScaling = {}

if not RunService:IsClient() then
	return UIScrollbarScaling
end

local mainGui = Players.LocalPlayer.PlayerGui.MainGui
local vector = Vector2.new(2151, 1159)
local tweens = require(ReplicatedStorage.SharedUtils.tweens)

local function addRotator(instance)
	local v = not instance:GetAttribute("duration") and 8 or instance:GetAttribute("duration") or 8
	tweens:infiniteRotate(instance, TweenInfo.new(v, Enum.EasingStyle.Linear))
end

CollectionService:GetInstanceAddedSignal("infiniteRotate"):Connect(addRotator)
local v = {}

for _, v2 in pairs(CollectionService:GetTagged("infiniteRotate")) do
	task.spawn(addRotator, v2)
end

local instances = {}

local function addFloater(instance)
	local v2 = #instances == 0
	instance:SetAttribute("DefaultPosition", instance.Position)
	instances[#instances + 1] = instance

	if v2 then
		task.spawn(function()
			while #instances > 0 do
				for k, v3 in pairs(instances) do
					v3.Position = v3:GetAttribute("DefaultPosition") + UDim2.fromScale(
						0,
						math.sin(tick() * 3.141592653589793 / 3 + k / 5) * 0.05
					)
				end

				RunService.Heartbeat:Wait()
			end
		end)
	end
end

CollectionService:GetInstanceAddedSignal("animateFloat"):Connect(addFloater)

for _, v2 in pairs(CollectionService:GetTagged("animateFloat")) do
	task.spawn(addFloater, v2)
end

local function handleDefaultButtons(button)
	local v2 = button:FindFirstChild("UIScale")

	if not v2 then
		v2 = Instance.new("UIScale")
		v2.Parent = button
	end

	button.MouseEnter:Connect(function()
		mainGui.TinyTick:Play()
		tweens:playTween(v2, TweenInfo.new(0.15), {
			Scale = 1.04
		})
	end)
	button.MouseLeave:Connect(function()
		tweens:playTween(v2, TweenInfo.new(0.15), {
			Scale = 1
		})
	end)

	if button:IsA("TextButton") or button:IsA("ImageButton") then
		button.Activated:Connect(function()
			mainGui.Click:Play()
			task.spawn(function()
				tweens:playTween(v2, TweenInfo.new(0.1), {
					Scale = 0.95
				})
				task.wait(0.1)
				tweens:playTween(v2, TweenInfo.new(0.1), {
					Scale = 1
				})
			end)
		end)
	end
end

CollectionService:GetInstanceAddedSignal("defaultButton"):Connect(handleDefaultButtons)

for _, v2 in pairs(CollectionService:GetTagged("defaultButton")) do
	task.spawn(handleDefaultButtons, v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupUIStrokeThickness(p)
	v[p] = tonumber(p.Thickness)
	return v[p]
end

local function getUIStrokeStartingThickness(p)
	if v[p] then
		return v[p]
	end

	return setupUIStrokeThickness(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupScrollBarThickness(p)
	v[p] = tonumber(p.ScrollBarThickness)
	return v[p]
end

local function getStartingScrollBarThickness(p)
	if v[p] then
		return v[p]
	end

	return setupScrollBarThickness(p)
end

local function scaleThickness(instance)
	local v2 = workspace.CurrentCamera.ViewportSize.Y / vector.Y

	if instance:IsA("UIStroke") then
		if not v[instance] then
			v[instance] = tonumber(instance.Thickness)
		end

		instance.Thickness = v[instance] * v2
	elseif instance:IsA("ScrollingFrame") then
		if not v[instance] then
			v[instance] = tonumber(instance.ScrollBarThickness)
		end

		instance.ScrollBarThickness = v[instance] * v2
	end
end

local function updateThickness()
	for _, uIStroke in pairs(CollectionService:GetTagged("scaleUIStroke")) do
		if uIStroke:IsA("UIStroke") then
			scaleThickness(uIStroke)
		end
	end

	for _, scrollingFrame in pairs(CollectionService:GetTagged("scaleScrollingBar")) do
		if scrollingFrame:IsA("ScrollingFrame") then
			scaleThickness(scrollingFrame)
		end
	end
end

local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function queueThicknessUpdate()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		updateThickness()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindViewportSignal()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(queueThicknessUpdate)
	end
end

bindViewportSignal() -- equivalent call inferred; original call site unknown
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	bindViewportSignal() -- equivalent call inferred; original call site unknown
	queueThicknessUpdate() -- equivalent call inferred; original call site unknown
end)
CollectionService:GetInstanceAddedSignal("scaleUIStroke"):Connect(function(uIStroke)
	if not uIStroke:IsA("UIStroke") then
		return
	end

	scaleThickness(uIStroke)
end)
CollectionService:GetInstanceAddedSignal("scaleScrollingBar"):Connect(function(scrollingFrame)
	if not scrollingFrame:IsA("ScrollingFrame") then
		return
	end

	scaleThickness(scrollingFrame)
end)
task.delay(1, updateThickness)
return UIScrollbarScaling