local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local screenGui = parent:FindFirstAncestorOfClass("ScreenGui")
local v = {}
local v2 = {}

for _, button in ipairs(parent:GetChildren()) do
	if not (button:IsA("GuiButton") and button:FindFirstChild("Art")) then
		continue
	end

	local jSONDecode = game.HttpService:JSONDecode(button:GetAttribute("CarouselImages") or "[]")

	if not (#jSONDecode > 1) then
		continue
	end

	local art = button.Art
	local frame = Instance.new("Frame")
	frame.Name = "ArtWindow"
	frame.BackgroundTransparency = 1
	frame.Position = art.Position
	frame.Size = art.Size
	frame.ClipsDescendants = true
	frame.ZIndex = 2
	frame.Parent = button
	art.Parent = frame
	art.Position = UDim2.new()
	art.Size = UDim2.fromScale(1, 1)
	local clone = art:Clone()
	clone.Name = "NextArt"
	clone.Position = UDim2.fromScale(1, 0)
	clone.Parent = frame
	table.insert(v, {
		art = art,
		nextArt = clone,
		images = jSONDecode,
		index = 1
	})

	for _, v3 in ipairs(jSONDecode) do
		table.insert(v2, v3)
	end
end

task.spawn(function()
	pcall(function()
		ContentProvider:PreloadAsync(v2)
	end)
end)
local v3 = 0

local function advance(state)
	state.index = state.index % #state.images + 1

	if localPlayer:GetAttribute("ReducedMotion") then
		state.art.Image = state.images[state.index]
		return
	end

	state.nextArt.Image = state.images[state.index]
	state.nextArt.Position = UDim2.fromScale(1, 0)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tween = TweenService:Create(state.art, tweenInfo, {
		Position = UDim2.fromScale(-1, 0)
	})
	local tween2 = TweenService:Create(state.nextArt, tweenInfo, {
		Position = UDim2.new()
	})
	tween:Play()
	tween2:Play()
	tween2.Completed:Wait()
	state.art.Image = state.nextArt.Image
	state.art.Position = UDim2.new()
	state.nextArt.Position = UDim2.fromScale(1, 0)
end

RunService.Heartbeat:Connect(function(dt)
	if not (screenGui.Enabled and parent.Visible) then
		v3 = 0
		return
	end

	v3 += dt

	if v3 < 3 then
		return
	end

	v3 %= 3

	for _, v4 in ipairs(v) do
		task.spawn(advance, v4)
	end
end)