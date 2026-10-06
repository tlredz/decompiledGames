local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local _ = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local TweenService = game:GetService("TweenService")
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local char = data.char
	local cf = data.cf

	if not char then
		return
	end

	tick()
	PeodizService.HeartbeatWait({
		Time = 4,
		WaitTime = 0.025
	}, function()
		if not char:IsDescendantOf(workspace) then
			return true
		end

		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and char:FindFirstChild("DragonClawHold")) then
			return true
		end

		if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 15 or game.Players.LocalPlayer == data.player then
			_G.shake("SmallestBump")
		end

		local cFrame = humanoidRootPart.CFrame
		local v = humanoidRootPart.CFrame * CFrame.new(0, 0, -60)
		local magnitude = (cFrame.p - v.p).magnitude
		local v2 = math.random(-8, 8)
		local v3 = math.random(0, 8)
		local clone = replicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
		clone.Color = Color3.fromRGB(213, 115, 61)
		clone.CFrame = CFrame.new(cFrame.p, v.p) * CFrame.new(v2, v3, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		clone.Size = createVector(19.252, 19.252, 1.565)
		clone.Parent = workspace.Effects
		local clone2 = replicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
		clone2.Color = Color3.fromRGB(213, 115, 61)
		clone2.CFrame = CFrame.new(cFrame.p, v.p) * CFrame.new(v2, v3, -5)
		clone2.Size = createVector(8, 8, 5)
		clone2.Parent = workspace.Effects
		local clone3 = replicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
		clone3.Color = Color3.fromRGB(175, 128, 89)
		clone3.CFrame = CFrame.new(cFrame.p, v.p) * CFrame.new(v2, v3, -10) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone3.Size = createVector(8.897, 0.658, 8.897)
		clone3.Parent = workspace.Effects
		local attachment = Instance.new("Attachment", clone)
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone
		pointLight.Color = Color3.fromRGB(213, 168, 137)
		pointLight.Brightness = 1.5
		pointLight.Range = 30
		local clone4 = replicatedStorage.Chest.Etc.DragonClaw.Flame2:Clone()
		clone4.Parent = attachment
		clone4:Emit(math.random(3, 5))
		clone4.Enabled = false
		TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Brightness = 0
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(8.374, 8.374, 23.01),
			CFrame = CFrame.new(cFrame.p, v.p) * CFrame.new(v2, v3, -magnitude / 1.15) * CFrame.Angles(
				0,
				3.141592653589793,
				3.839724354387525
			)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(21.166, 1.565, 21.166),
			CFrame = CFrame.new(cFrame.p, v.p) * CFrame.new(v2, v3, 1) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, magnitude - 5),
			CFrame = CFrame.new(cFrame.p, v.p) * CFrame.new(v2, v3, -magnitude / 2 + 5)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1.5)
		_G.PU:Dust(clone3, 1)
		_G.PU:Dust(clone2, 1)
	end)
end