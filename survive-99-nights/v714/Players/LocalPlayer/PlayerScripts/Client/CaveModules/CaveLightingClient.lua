local TweenService = game:GetService("TweenService")
local CaveLightingClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
CaveLightingClient.NearGreen = false
local v = {}

function OnCompleted(folder)
	if v[folder] then
		return
	end

	v[folder] = true
	task.spawn(function()
		local highlight = folder:FindFirstChild("Highlight")

		if not highlight then
			return
		end

		TweenService:Create(highlight, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FillColor = Color3.fromRGB(255, 255, 255),
			FillTransparency = 0
		}):Play()
		wait(1)

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		folder.Material = Enum.Material.Neon
		folder.Color = Color3.fromRGB(0, 190, 207)
		TweenService:Create(highlight, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FillTransparency = 1
		}):Play()
		folder.PointLight.Enabled = true
		local glow = folder.Parent:FindFirstChild("Glow")

		if glow then
			TweenService:Create(glow, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Transparency = 0.8
			}):Play()
		end

		task.spawn(function()
			wait(3)

			if highlight then
				highlight.Adornee = nil
				highlight:Destroy()
			end
		end)
	end)
end

function AdjustFillPart(parent, value)
	if not (parent and parent.Parent) then
		return
	end

	local crystal = parent.Parent.Parent:FindFirstChild("Crystal")

	if not parent:FindFirstChild("Highlight") then
		local highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = Color3.fromRGB(255, 238, 0)
		highlight.FillTransparency = 0.999
		highlight.OutlineTransparency = 1
		highlight.Parent = parent
	end

	if crystal and not crystal:FindFirstChild("Highlight") then
		local highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = Color3.fromRGB(255, 238, 0)
		highlight.FillTransparency = 0
		highlight.OutlineTransparency = 1
		highlight.Parent = crystal
	end

	local v2 = math.clamp(value, 0, 100) / 100
	local originalSize = parent:GetAttribute("OriginalSize")
	local originalPosition = parent:GetAttribute("OriginalPosition")

	if not originalSize then
		originalSize = parent.Size
		parent:SetAttribute("OriginalSize", originalSize)
	end

	if not originalPosition then
		originalPosition = parent.Position
		parent:SetAttribute("OriginalPosition", originalPosition)
	end

	local v3 = originalSize.Y * (1 - v2)
	local v4 = originalSize.Y - v3
	TweenService:Create(parent, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
		Size = Vector3.new(originalSize.X, v3, originalSize.Z)
	}):Play()
	TweenService:Create(parent, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
		Position = originalPosition + Vector3.new(0, v4 / 2, 0)
	}):Play()
	task.spawn(function()
		if value >= 100 then
			if crystal then
				OnCompleted(crystal)
			end

			wait(0.35)

			if parent then
				parent:Destroy()
			end
		end
	end)
end

CaveLightingClient.PlayerInLight = nil
local v2 = {}

function OnPlayerEntered(_, playerInLight)
	if not CaveLightingClient.PlayerInLight and playerInLight:GetAttribute("LightCount") and playerInLight:GetAttribute("LightCount") >= 100 then
		CaveLightingClient.PlayerInLight = playerInLight

		if playerInLight:GetAttribute("IsCave") then
			CaveLightingClient.NearGreen = true
		end

		localPlayer:SetAttribute("CaveCrystal", true)
		Client.ColorCorrectionLightingClient.ForceUpdate()
	end
end

function OnPlayerExited(_, p)
	if CaveLightingClient.PlayerInLight == p then
		CaveLightingClient.PlayerInLight = nil
		localPlayer:SetAttribute("CaveCrystal", false)
		CaveLightingClient.NearGreen = false
		Client.ColorCorrectionLightingClient.ForceUpdate()
	end
end

function ActivateLight(instance)
	local touchZone = instance:WaitForChild("TouchZone", 5)

	if not touchZone or v2[instance] then
		return
	end

	v2[instance] = true

	if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local _ = localPlayer.Character.HumanoidRootPart
		local touchingParts = touchZone:GetTouchingParts()

		for _, touchingPart in pairs(touchingParts) do
			if touchingPart.Parent ~= localPlayer.Character then
				continue
			end

			OnPlayerEntered(localPlayer, instance)
			return
		end
	end
end

function PartsAreTouching(object, p)
	local touchingParts = object:GetTouchingParts()

	for _, touchingPart in pairs(touchingParts) do
		if touchingPart == p then
			return true
		end
	end
end

function SetupTouchParts(instance)
	local touchZone = instance:WaitForChild("TouchZone")
	touchZone.Touched:Connect(function(otherPart)
		if localPlayer.Character and otherPart == localPlayer.Character.PrimaryPart then
			OnPlayerEntered(localPlayer, instance)
		end
	end)
	touchZone.TouchEnded:Connect(function(otherPart)
		if localPlayer.Character and otherPart == localPlayer.Character.PrimaryPart then
			OnPlayerExited(localPlayer, instance)
		end
	end)
end

function CrystalAdded(instance)
	repeat
		wait(1)
	until instance.PrimaryPart and instance:IsDescendantOf(workspace)

	local v3 = {}
	instance.PrimaryPart.Touched:Connect(function(otherPart)
		if v3[otherPart] then
			return
		end

		if localPlayer.Character and otherPart.Name == "TorchTouchZone" then
			v3[otherPart] = true
			Client.Events.CrystalTorchHit:FireServer(instance)

			while true do
				task.wait(0.5)

				if not PartsAreTouching(instance.PrimaryPart, otherPart) then
					break
				end

				Client.Events.CrystalTorchHit:FireServer(instance)
			end

			v3[otherPart] = nil
		end
	end)
	instance:GetAttributeChangedSignal("Completed"):Connect(function() end)
	local part = instance:WaitForChild("FlashlightFill"):WaitForChild("Part")
	SetupTouchParts(instance)
	instance:GetAttributeChangedSignal("LightCount"):Connect(function()
		if instance:GetAttribute("LightCount") >= 100 then
			task.spawn(function()
				wait(2)
				ActivateLight(instance)
			end)
		end

		if not part then
			return
		end

		AdjustFillPart(part, instance:GetAttribute("LightCount") or 0)
	end)
end

Client.Utility.ForAllTagged("LightCrystal", CrystalAdded)
return CaveLightingClient