local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local CollectionService = game:GetService("CollectionService")
local screenGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local vector = Vector2.new(2151, 1159)
local tweens = require(ReplicatedStorage.Modules.Utils.tweens)

local function inPlayerGui(instance)
	return instance:IsDescendantOf(screenGui)
end

local function addRotator(instance)
	if not instance:IsDescendantOf(screenGui) then
		return
	end

	local duration = instance:GetAttribute("duration") or 8
	tweens:infiniteRotate(instance, TweenInfo.new(duration, Enum.EasingStyle.Linear))
end

CollectionService:GetInstanceAddedSignal("infiniteRotate"):Connect(addRotator)

for _, v in CollectionService:GetTagged("infiniteRotate") do
	task.spawn(addRotator, v)
end

local v = {}
local v2 = {}

local function addFloater(instance)
	if not instance:IsDescendantOf(screenGui) or v2[instance] then
		return
	end

	local v3 = #v == 0
	local v4 = {
		ui = instance,
		defaultPos = instance.Position
	}
	v[#v + 1] = v4
	v2[instance] = #v

	if v3 then
		task.spawn(function()
			while #v > 0 do
				local v5 = os.clock() * 3.141592653589793 / 3

				for k, v6 in v do
					v6.ui.Position = v6.defaultPos + UDim2.fromScale(0, math.sin(v5 + k / 5) * 0.05)
				end

				RunService.Heartbeat:Wait()
			end
		end)
	end
end

local function removeFloater(p)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v2[p] = nil
	local count = #v

	if v3 ~= count then
		v[v3] = v[count]
		v2[v[v3].ui] = v3
	end

	v[count] = nil
end

CollectionService:GetInstanceAddedSignal("animateFloat"):Connect(addFloater)
CollectionService:GetInstanceRemovedSignal("animateFloat"):Connect(removeFloater)

for _, v3 in CollectionService:GetTagged("animateFloat") do
	task.spawn(addFloater, v3)
end

local function handleDefaultButton(button)
	if not button:IsDescendantOf(screenGui) then
		return
	end

	local v3 = button:FindFirstChild("UIScale")

	if not v3 then
		v3 = Instance.new("UIScale")
		v3.Parent = button
	end

	button.MouseEnter:Connect(function()
		Audio:PlayOne("Sounds.UI.SkillCheck.Ticks.TinyTick")
		tweens:playTween(v3, TweenInfo.new(0.15), {
			Scale = 1.04
		})
	end)
	button.MouseLeave:Connect(function()
		tweens:playTween(v3, TweenInfo.new(0.15), {
			Scale = 1
		})
	end)

	if button:IsA("TextButton") or button:IsA("ImageButton") then
		button.Activated:Connect(function()
			Audio:PlayOne("Sounds.UI.Buttons.Click")
			task.spawn(function()
				tweens:playTween(v3, TweenInfo.new(0.1), {
					Scale = 0.95
				})
				task.wait(0.1)
				tweens:playTween(v3, TweenInfo.new(0.1), {
					Scale = 1
				})
			end)
		end)
	end
end

CollectionService:GetInstanceAddedSignal("defaultButton"):Connect(handleDefaultButton)

for _, v3 in CollectionService:GetTagged("defaultButton") do
	task.spawn(handleDefaultButton, v3)
end

local object = setmetatable({}, {
	__mode = "k"
})

local function getStartingThickness(p)
	local v3 = object[p]

	if v3 then
		return v3
	end

	local thickness = tonumber(p.Thickness)
	object[p] = thickness
	return thickness
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleThickness(uIStroke)
	local v3 = workspace.CurrentCamera.ViewportSize.Y / vector.Y
	local thickness = object[uIStroke]

	if not thickness then
		thickness = tonumber(uIStroke.Thickness)
		object[uIStroke] = thickness
	end

	uIStroke.Thickness = thickness * v3
end

local function updateAllThickness()
	for _, uIStroke in CollectionService:GetTagged("scaleUIStroke") do
		if not (uIStroke:IsA("UIStroke") and uIStroke:IsDescendantOf(screenGui)) then
			continue
		end

		scaleThickness(uIStroke) -- equivalent call inferred; original call site unknown
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
		updateAllThickness()
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
	if uIStroke:IsA("UIStroke") and uIStroke:IsDescendantOf(screenGui) then
		scaleThickness(uIStroke) -- equivalent call inferred; original call site unknown
	end
end)
task.delay(1, updateAllThickness)
task.spawn(function()
	local selectionFrame = screenGui:WaitForChild("SelectionFrame", 30)

	if not selectionFrame then
		return
	end

	local v3 = {
		"infiniteRotate",
		"animateFloat",
		"defaultButton",
		"scaleUIStroke"
	}
	local visible = selectionFrame.Visible
	local flag2 = false

	local function cleanup()
		if flag2 then
			return
		end

		flag2 = true

		for _, tag in v3 do
			for _, v4 in CollectionService:GetTagged(tag) do
				if v4:IsDescendantOf(selectionFrame) then
					CollectionService:RemoveTag(v4, tag)
				end
			end
		end
	end

	selectionFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if selectionFrame.Visible then
			visible = true
		elseif visible then
			cleanup()
		end
	end)
end)