local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local edges = parent:WaitForChild("Edges")
local v = {}

for _, childName in {
	"Top",
	"Bottom",
	"Left",
	"Right"
} do
	table.insert(v, edges:WaitForChild(childName))
end

local count = 0
local tweens = {}
local connections = {}
local runState = localPlayer:GetAttribute("RunState")

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTweens()
	for _, v2 in tweens do
		v2:Cancel()
	end

	table.clear(tweens)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clear()
	count += 1
	stopTweens() -- equivalent call inferred; original call site unknown
	edges.Visible = false

	for _, v2 in v do
		v2.BackgroundTransparency = 1
	end
end

local function allowed()
	return localPlayer:GetAttribute("InMatch") == true and localPlayer:GetAttribute("GameRole") == "Runner" and localPlayer:GetAttribute("InitialLoadingComplete") == true and localPlayer:GetAttribute("ScreenPresentationActive") ~= true and localPlayer:GetAttribute("MatchSummaryVisible") ~= true
end

local function animate(duration, backgroundTransparency)
	stopTweens() -- equivalent call inferred; original call site unknown

	for _, v2 in v do
		local tween = TweenService:Create(
			v2,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				BackgroundTransparency = backgroundTransparency
			}
		)
		table.insert(tweens, tween)
		tween:Play()
	end
end

local function pulse(runState2)
	clear() -- equivalent call inferred; original call site unknown

	if not allowed() then
		return
	end

	local v2 = count
	local fadeIn = parent:GetAttribute("FadeIn") or 0.1
	local holdTime = parent:GetAttribute("HoldTime") or 0.28
	local fadeOut = parent:GetAttribute("FadeOut") or 0.75
	local attribute = parent:GetAttribute(runState2 == "Safe" and "SafeColor" or "CaughtColor")

	for _, v3 in v do
		v3.BackgroundColor3 = attribute
	end

	edges.Visible = true
	animate(fadeIn, parent:GetAttribute("PeakTransparency") or 0.38)
	task.delay(fadeIn + holdTime, function()
		if count ~= v2 then
			return
		end

		animate(fadeOut, 1)
	end)
	task.delay(fadeIn + holdTime + fadeOut, function()
		if count == v2 then
			clear() -- equivalent call inferred; original call site unknown
		end
	end)
end

local function stateChanged()
	local runState2 = localPlayer:GetAttribute("RunState")
	local v2 = runState
	runState = runState2

	if v2 == "Active" and (runState2 == "Safe" or runState2 == "Caught") then
		pulse(runState2)
	elseif runState2 ~= "Safe" and runState2 ~= "Caught" then
		clear() -- equivalent call inferred; original call site unknown
	end
end

table.insert(connections, localPlayer:GetAttributeChangedSignal("RunState"):Connect(stateChanged))

for _, v2 in {
	"InMatch",
	"GameRole",
	"InitialLoadingComplete",
	"ScreenPresentationActive",
	"MatchSummaryVisible"
} do
	table.insert(connections, localPlayer:GetAttributeChangedSignal(v2):Connect(function()
		if not allowed() then
			clear() -- equivalent call inferred; original call site unknown
		end
	end))
end

table.insert(connections, localPlayer.CharacterRemoving:Connect(clear))
table.insert(connections, localPlayer.CharacterAdded:Connect(function()
	runState = localPlayer:GetAttribute("RunState")
	clear() -- equivalent call inferred; original call site unknown
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	clear() -- equivalent call inferred; original call site unknown
end)
clear() -- equivalent call inferred; original call site unknown