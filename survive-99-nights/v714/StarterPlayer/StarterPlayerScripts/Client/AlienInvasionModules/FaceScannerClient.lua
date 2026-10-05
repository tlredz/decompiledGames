local TweenService = game:GetService("TweenService")
local FaceScannerClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}

function doScanVisuals(p)
	local effectHub = p.EffectHub
	local vertical = effectHub.Vertical
	local horizontal = effectHub.Horizontal
	local BV = effectHub.BV
	local BH = effectHub.BH
	local TweenService2 = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(1.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true, 0)
	BV.Enabled = true
	BH.Enabled = true
	effectHub.Attachment.BorderBoxEffect:Emit(1)

	for k, v2 in {
		[0] = vertical,
		horizontal
	} do
		local v3 = k == 0 and v2.CFrame.LookVector * -1.5 or v2.CFrame.UpVector * -1.5
		TweenService2:Create(v2, tweenInfo, {
			CFrame = v2.CFrame + v3
		}):Play()
	end

	task.spawn(function()
		task.wait(3.9)
		BV.Enabled = false
		BH.Enabled = false
	end)
end

function doHighlight(parent, p)
	local highlight = Instance.new("Highlight")
	highlight.Parent = parent
	highlight.FillColor = p or Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	TweenService:Create(highlight, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
		FillTransparency = 0.1
	}):Play()
	task.spawn(function()
		wait(0.4)

		if highlight then
			TweenService:Create(highlight, TweenInfo.new(1.6, Enum.EasingStyle.Linear), {
				FillTransparency = 1
			}):Play()
		end

		wait(1.6)

		if highlight then
			highlight.Adornee = nil
			highlight.Parent = nil
			highlight:Destroy()
			highlight = nil
		end
	end)
end

Client.Events.ScannerVisuals:Connect(function(p, instance, p2)
	if not instance then
		return
	end

	local primaryPart = instance.PrimaryPart
	local surfaceGui = primaryPart:WaitForChild("SurfaceGui")
	local textLabel = surfaceGui:WaitForChild("TextLabel")
	local pointLight = primaryPart.PointLight

	if p == "Scanning" then
		doScanVisuals(instance)
		textLabel.Text = "SCANNING..."
		surfaceGui.Frame.Fill.Visible = true
		surfaceGui.Frame.Fill.BackgroundColor3 = Color3.fromRGB(0, 94, 194)
		surfaceGui.Frame.Fill.Size = UDim2.new(0, 0, 1, 0)
		TweenService:Create(surfaceGui.Frame.Fill, TweenInfo.new(4, Enum.EasingStyle.Linear), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
	elseif p == "Success" then
		textLabel.Text = "APPROVED"
		pointLight.Color = Color3.fromRGB(0, 255, 0)
		pointLight.Enabled = true
		surfaceGui.Frame.Fill.Visible = true
		surfaceGui.Frame.Fill.BackgroundColor3 = Color3.fromRGB(60, 255, 0)

		for _, part in pairs(instance.Cones:GetChildren()) do
			if part:IsA("BasePart") then
				part.Color = Color3.fromRGB(0, 255, 0)
			end
		end

		for _, child in pairs(instance:GetChildren()) do
			if child.Name == "Part2" then
				child.Color = Color3.fromRGB(60, 255, 0)
			end
		end

		instance.Cones.ConeLight.PointLight.Color = Color3.fromRGB(60, 255, 0)

		if p2 then
			doHighlight(p2, Color3.fromRGB(0, 255, 0))
		end
	elseif p == "Failed" then
		textLabel.Text = "DENIED"
		pointLight.Color = Color3.fromRGB(255, 0, 0)
		pointLight.Enabled = true
		surfaceGui.Frame.Fill.Visible = true
		surfaceGui.Frame.Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 4)

		for _, part in pairs(instance.Cones:GetChildren()) do
			if part:IsA("BasePart") then
				part.Color = Color3.fromRGB(255, 0, 4)
			end
		end

		for _, child in pairs(instance:GetChildren()) do
			if child.Name == "Part2" then
				child.Color = Color3.fromRGB(255, 0, 4)
			end
		end

		instance.Cones.ConeLight.PointLight.Color = Color3.fromRGB(255, 0, 4)

		if p2 then
			doHighlight(p2)
		end
	elseif p == "Reset" then
		textLabel.Text = "SCAN FACE"
		textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		pointLight.Enabled = false
		surfaceGui.Frame.Fill.Visible = false
		surfaceGui.Frame.Fill.BackgroundColor3 = Color3.fromRGB(0, 94, 194)

		for _, part in pairs(instance.Cones:GetChildren()) do
			if part:IsA("BasePart") then
				part.Color = Color3.fromRGB(0, 143, 156)
			end
		end

		for _, child in pairs(instance:GetChildren()) do
			if child.Name == "Part2" then
				child.Color = Color3.fromRGB(0, 143, 156)
			end
		end

		instance.Cones.ConeLight.PointLight.Color = Color3.fromRGB(0, 255, 255)
	end
end)

function InitializeFaceScanner(instance)
	instance:WaitForChild("TouchPart").Touched:Connect(function(otherPart)
		if v[instance] or instance:GetAttribute("Done") or instance:GetAttribute("Scanning") then
			return
		end

		local parent = otherPart.Parent

		if parent == localPlayer.Character and not instance.Parent:GetAttribute("DoorCanUnlock") then
			return
		end

		if (not parent or parent ~= localPlayer.Character or not (parent:FindFirstChild("Humanoid") and parent.Humanoid.Health > 0)) and (not parent or not parent:FindFirstChild("NPC") or not parent:GetAttribute("Dead") or parent.Parent ~= workspace.Items) then
			return
		end

		Client.Events.CheckFaceScan:FireServer(instance, parent)
		v[instance] = true
		task.spawn(function()
			wait(0.5)
			v[instance] = false
		end)
	end)
end

function FaceScannerClient.Init()
	task.spawn(function()
		Client.Utility.ForAllTagged("FaceScanner", InitializeFaceScanner)
	end)
end

return FaceScannerClient