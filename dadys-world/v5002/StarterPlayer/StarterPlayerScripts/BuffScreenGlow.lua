local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local v = {
	Ignited = Color3.fromRGB(110, 255, 150)
}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BuffScreenGlow"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = -5
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local v2 = {}

local function makeEdge(name, size, position, rotation)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = v.Ignited
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = size
	frame.Position = position
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = rotation
	uIGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
	uIGradient.Parent = frame
	frame.Parent = screenGui
	table.insert(v2, frame)
end

makeEdge("Top", UDim2.new(1, 0, 0.16, 0), UDim2.new(0, 0, 0, 0), 90)
makeEdge("Bottom", UDim2.new(1, 0, 0.16, 0), UDim2.new(0, 0, 0.84, 0), -90)
makeEdge("Left", UDim2.new(0.16, 0, 1, 0), UDim2.new(0, 0, 0, 0), 0)
makeEdge("Right", UDim2.new(0.16, 0, 1, 0), UDim2.new(0.84, 0, 0, 0), 180)
local v3 = {}

local function refresh()
	local backgroundColor = nil

	for _, v6 in pairs(v3) do
		backgroundColor = v6
		break
	end

	local v6

	if localPlayer:GetAttribute("BuffScreenGlow") == true then
		v6 = backgroundColor ~= nil
	else
		v6 = false
	end

	for _, v7 in ipairs(v2) do
		if backgroundColor then
			v7.BackgroundColor3 = backgroundColor
		end

		TweenService:Create(v7, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = v6 and 0.8 or 1
		}):Play()
	end
end

local function watchCharacter(character)
	table.clear(v3)
	character.ChildAdded:Connect(function(stringValue)
		local v4 = v[stringValue.Name]

		if v4 and stringValue:IsA("StringValue") then
			v3[stringValue] = v4
			refresh()
		end
	end)
	character.ChildRemoved:Connect(function(child)
		if v3[child] then
			v3[child] = nil
			refresh()
		end
	end)

	for _, stringValue in ipairs(character:GetChildren()) do
		local v4 = v[stringValue.Name]

		if v4 and stringValue:IsA("StringValue") then
			v3[stringValue] = v4
		end
	end

	refresh()
end

localPlayer:GetAttributeChangedSignal("BuffScreenGlow"):Connect(refresh)
localPlayer.CharacterAdded:Connect(watchCharacter)

if localPlayer.Character then
	watchCharacter(localPlayer.Character)
end