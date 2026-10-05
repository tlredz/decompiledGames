local Players = game:GetService("Players")
game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local _ = localPlayer.PlayerScripts
local currentCamera = workspace.CurrentCamera
local toolsScreen = playerGui:WaitForChild("ToolsScreen")
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local controls = CharacterController.Controls
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("UseItem")
local originalMoveFunction = CharacterController.originalMoveFunction
remoteEvent.OnClientEvent:Connect(function(p)
	if p ~= "Fire Extinguisher" then
		return
	end

	local v = math.sqrt(currentCamera.ViewportSize.X * currentCamera.ViewportSize.X + currentCamera.ViewportSize.Y * currentCamera.ViewportSize.Y)

	for _ = 1, math.random(3, 6) do
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new()
		frame.BorderSizePixel = 0
		frame.BackgroundTransparency = 1
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.Position = UDim2.new(math.random(), 0, math.random(), 0)
		frame.Parent = toolsScreen
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = frame
		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.AspectRatio = 1
		uIAspectRatioConstraint.Parent = frame
		local v2 = math.random(math.floor(v * 0.3), (math.floor(v * 0.6)))
		local TweenService = game:GetService("TweenService")
		TweenService:Create(frame, TweenInfo.new(0.5), {
			Size = UDim2.new(0, v2, 0, v2),
			BackgroundTransparency = 0.1
		}):Play()
		task.delay(8, function()
			local TweenService2 = game:GetService("TweenService")
			local tween = TweenService2:Create(frame, TweenInfo.new(0.5), {
				Size = UDim2.new()
			})
			tween:Play()
			tween.Completed:Wait()
			frame:Destroy()
		end)
	end

	function controls.moveFunction(p2, p3, p4)
		CharacterController:RequestMove(p2, -p3, p4)
	end

	task.delay(8, function()
		controls.moveFunction = originalMoveFunction
	end)
end)
return {}