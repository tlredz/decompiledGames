local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local _ = Players.LocalPlayer
local Network = require(game.ReplicatedStorage.Modules.Network)
local Data = require(game.ReplicatedStorage.Modules.Data)
Data.CollectedEggss.Items = {}
local EggData = require(script.EggData)
local children = ReplicatedStorage.Assets.Models.Eggs:GetChildren()
local parent = script.Parent

local function setupGui()
	for _, v in children do
		local clone = script.ImageLabel:Clone()
		clone.Name = v.Name

		if EggData[v.Name] and EggData[v.Name].Order then
			clone.LayoutOrder = -EggData[v.Name].Order
		end

		local viewportFrame = clone.ViewportFrame
		viewportFrame.Ambient = Color3.fromRGB(30, 30, 30)
		local camera = Instance.new("Camera")
		viewportFrame.CurrentCamera = camera
		camera.Parent = viewportFrame
		local clone2 = v:Clone()
		clone2.Parent = viewportFrame
		local vector = Vector3.new(clone2.Position.X, clone2.Position.Y, clone2.Position.Z - 2.5)
		local vector2 = Vector3.new(clone2.Position.X, clone2.Position.Y, clone2.Position.Z - 3.8)
		camera.CFrame = CFrame.new(vector2, clone2.Position)
		local heartbeatConnection = nil
		local cFrame = clone2.CFrame
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		clone.MouseEnter:Connect(function()
			TweenService:Create(camera, tweenInfo, {
				CFrame = CFrame.new(vector, clone2.Position)
			}):Play()
			local RunService = game:GetService("RunService")
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				clone2.CFrame *= CFrame.Angles(0, math.rad(200 * dt), 0)
			end)
		end)
		local currentCamera = camera
		local v7 = tweenInfo
		local v9 = clone2
		clone.MouseLeave:Connect(function()
			TweenService:Create(currentCamera, v7, {
				CFrame = CFrame.new(vector2, v9.Position)
			}):Play()

			if heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			TweenService:Create(v9, v7, {
				CFrame = cFrame
			}):Play()
		end)
		clone.Parent = parent.EggList
	end
end

local function updateGui()
	local count = 0

	for _, child in parent.EggList:GetChildren() do
		if table.find(Data.CollectedEggss.Items, child.Name) == nil then
			continue
		end

		count += 1
		child.ViewportFrame.Ambient = Color3.fromRGB(200, 200, 200)
	end

	if count ~= 0 then
		parent.ProgressBar.ProgressBar:TweenSize(
			UDim2.new(count / 15, 0, 1, 0),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Sine,
			1
		)
	end

	parent.ProgressBar.TextLabel.Text = count .. "/15 EGGS"
end

setupGui()
task.wait(1)
updateGui()
parent.XButton.MouseButton1Click:Connect(function()
	parent.Parent.Visible = false
end)
Network:listen("UpdateEggs", function(items)
	Data.CollectedEggss.Items = items
	updateGui()
end)