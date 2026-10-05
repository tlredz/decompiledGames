local createVector = vector.create
local mouse = game.Players.LocalPlayer:GetMouse()
local frame = script.Parent:WaitForChild("Frame")
local selection = script.Parent:WaitForChild("Selection")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Graffiti = require(game.ReplicatedStorage.Assets.Tools.Graffiti)
local UI = require(game.ReplicatedStorage.Modules.UI)
local Network = require(game.ReplicatedStorage.Modules.Network)
local Money = require(game.ReplicatedStorage.Modules.Money)
local limit = script.Parent:WaitForChild("Limit")
local bar = limit:WaitForChild("Bar")
local label = limit:WaitForChild("Label")
local draw = selection:WaitForChild("Draw")
local erase = selection:WaitForChild("Erase")
local v = { "S", "M", "L" }
local v2 = nil
local v3 = nil
local v4 = nil

if not Graffiti.ShouldCount then
	limit.Visible = false
end

for k, color in Graffiti.Colors do
	local clone = script.Sample:Clone()
	clone.Name = k
	clone.LayoutOrder = k
	clone.BackgroundColor3 = color
	clone.Parent = frame

	if k == Graffiti.CurrentColor then
		v2 = clone
		clone.Text = "X"
	end

	local currentColor = k
	clone.MouseButton1Click:connect(function()
		if v2 then
			v2.Text = ""
		end

		v2 = clone
		v2.Text = "X"
		Graffiti.CurrentColor = currentColor
		Network:fire("SetGraffitiColor", Graffiti:GetCurrentColor())
	end)
	UI:Bind(clone)
end

for k, _ in Graffiti.Sizes do
	local clone = script.SizeSample:Clone()
	clone.Name = k
	clone.LayoutOrder = -30 + k
	clone.Text = v[k]
	clone.Parent = frame

	if k == Graffiti.CurrentSize then
		v3 = clone
		clone.UIStroke.Color = Color3.fromRGB(255, 255, 255)
	end

	local currentSize = k
	clone.MouseButton1Click:connect(function()
		if v3 then
			v3.UIStroke.Color = Color3.fromRGB(0, 0, 0)
		end

		v3 = clone
		v3.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		Graffiti.CurrentSize = currentSize
	end)
	local v7 = clone
	clone.MouseEnter:connect(function()
		TweenService:Create(v7, TweenInfo.new(0.15), {
			TextColor3 = Color3.fromRGB(157, 157, 157)
		}):Play()
	end)
	local v8 = clone
	clone.MouseLeave:connect(function()
		TweenService:Create(v8, TweenInfo.new(0.15), {
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end)
	UI:Bind(clone)
end

for _, v5 in { draw, erase } do
	if Graffiti.CurrentMode == Graffiti.Modes[v5.Name] then
		v4 = v5
		v5.UIStroke.Color = Color3.fromRGB(255, 255, 255)
	else
		v5.UIStroke.Color = Color3.fromRGB(0, 0, 0)
	end

	local v6 = v5
	v5.MouseEnter:connect(function()
		TweenService:Create(v6.Icon, TweenInfo.new(0.15), {
			ImageColor3 = Color3.fromRGB(157, 157, 157)
		}):Play()
	end)
	local v7 = v5
	v5.MouseLeave:connect(function()
		TweenService:Create(v7.Icon, TweenInfo.new(0.15), {
			ImageColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end)
	local v8 = v5
	v5.MouseButton1Click:connect(function()
		if v4 then
			v4.UIStroke.Color = Color3.fromRGB(0, 0, 0)
		end

		v4 = v8
		v4.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		Graffiti.CurrentMode = Graffiti.Modes[v8.Name]
	end)
end

UI:Bind(draw)
UI:Bind(erase)

if UserInputService.TouchEnabled then
	frame.Position = UDim2.new(0, 5, 0, 5)
	frame.AnchorPoint = Vector2.new(0, 0)
	selection.Position = UDim2.new(0, 110, 0, 5)
	selection.AnchorPoint = Vector2.new(0, 0)
end

if workspace.CurrentCamera:FindFirstChild("Erase") then
	workspace.CurrentCamera.Erase:Destroy()
end

local erase2 = script:WaitForChild("Erase")
script.Parent.Destroying:connect(function()
	erase2:Destroy()
end)
local RunService = game:GetService("RunService")
RunService.Heartbeat:connect(function(_)
	if not erase2:IsDescendantOf(game) then
		return
	end

	if Graffiti.CurrentMode == Graffiti.Modes.Draw then
		erase2.Parent = script
		return
	end

	local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 200, Graffiti.Params)
	local size = createVector(0, 1, 1) * Graffiti.Sizes[Graffiti.CurrentSize] * 2.5 + createVector(0.2, 0, 0)

	if not erase2.Size:FuzzyEq(size) then
		erase2.Size = size
	end

	if raycastResult then
		erase2.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
			0,
			1.5707963267948966,
			0
		)
	else
		erase2.CFrame = CFrame.new(0, 2000, 0)
	end

	erase2.Parent = workspace.CurrentCamera
end)
local money = Money(Graffiti.Limit, true)

while true do
	label.Text = Money(Graffiti.Count, true) .. " / " .. money
	bar.Size = UDim2.new(Graffiti.Count / Graffiti.Limit, 0, 1, 0)
	task.wait(0.25)
end