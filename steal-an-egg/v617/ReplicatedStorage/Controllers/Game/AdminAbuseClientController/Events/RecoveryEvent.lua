local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = nil
local v2 = {}
local heartbeatConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function fadeSecondsFor(list)
	local v3 = list[1]

	if v3 == nil then
		return 1.2
	end

	return tonumber(v3:GetAttribute("FadeSeconds")) or 1.2
end

local function show()
	if v ~= nil then
		return
	end

	local recoveryVignette = playerGui:WaitForChild("RecoveryVignette", 10)

	if recoveryVignette == nil or not recoveryVignette:IsA("ScreenGui") then
		warn("[RecoveryEvent] Missing StarterGui.RecoveryVignette; the vignette is skipped")
		return
	end

	if not (v == nil and Workspace:GetAttribute("Event_RecoveryEvent")) then
		return
	end

	local clone = recoveryVignette:Clone()
	clone.Name = "RecoveryVignetteActive"
	clone.Enabled = true
	local images = {}
	local uIGradients = {}

	for _, image in clone:GetChildren() do
		if not image:IsA("ImageLabel") then
			continue
		end

		table.insert(images, image)
		local uIGradient = image:FindFirstChildOfClass("UIGradient")

		if uIGradient ~= nil then
			table.insert(uIGradients, uIGradient)
		end
	end

	if #images == 0 then
		warn("[RecoveryEvent] RecoveryVignette needs at least one ImageLabel; the vignette is skipped")
		clone:Destroy()
	else
		local v3 = fadeSecondsFor(images) -- equivalent call inferred; original call site unknown
		local spinDegreesPerSecond = tonumber(images[1]:GetAttribute("SpinDegreesPerSecond")) or 45

		for _, v4 in images do
			v4.ImageTransparency = 1
		end

		v = clone
		v2 = images
		clone.Parent = playerGui

		for _, v4 in images do
			local restTransparency = tonumber(v4:GetAttribute("RestTransparency")) or 0.25
			TweenService:Create(v4, TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				ImageTransparency = restTransparency
			}):Play()
		end

		if #uIGradients > 0 then
			local rotation = uIGradients[1].Rotation
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				rotation = (rotation + spinDegreesPerSecond * dt) % 360

				for _, v4 in uIGradients do
					v4.Rotation = rotation
				end
			end)
		end
	end
end

local function hide()
	local v3 = v
	local v4 = v2
	v = nil
	v2 = {}

	if v3 == nil then
		return
	end

	local v5 = fadeSecondsFor(v4) -- equivalent call inferred; original call site unknown

	if #v4 > 0 then
		for _, v6 in v4 do
			TweenService:Create(v6, TweenInfo.new(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				ImageTransparency = 1
			}):Play()
		end
	end

	local connection = heartbeatConnection
	heartbeatConnection = nil
	task.delay(v5, function()
		if connection ~= nil then
			connection:Disconnect()
		end

		v3:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onEventAttributeChanged()
	if Workspace:GetAttribute("Event_RecoveryEvent") then
		show()
	else
		hide()
	end
end

Workspace:GetAttributeChangedSignal("Event_RecoveryEvent"):Connect(onEventAttributeChanged)
onEventAttributeChanged() -- equivalent call inferred; original call site unknown
local RecoveryEvent = {}

function RecoveryEvent.StartEvent(_, _: number, _)
	show()
end

function RecoveryEvent.StopEvent(_)
	hide()
end

return RecoveryEvent