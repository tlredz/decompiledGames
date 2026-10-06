local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
return function(p, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p2)
		if localPlayer == p.plr then
			_G.shake(p2)
		end
	end

	local function rangeshake(p2, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - p.cf.p).Magnitude then
			_G.shake(p2)
		end
	end

	local function local_rangeshake(p2, value, p3)
		task.spawn(function()
			value = value or 100

			if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < value then
				_G.shake(p2)
			end
		end)
	end

	local cf = p.cf
	local clone = replicatedStorage.Chest.FruitEffect.Flame.V2.jet_fx:Clone()
	_G.PU:Dust(clone, 1)
	clone.CFrame = cf * CFrame.new(0, 0, -2) * CFrame.Angles(0, 3.141592653589793, 0)
	clone.Parent = workspace.Effects
	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 81, 0)
	pointLight.Range = 35
	pointLight.Brightness = 1
	pointLight.Parent = clone
	TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = 0
	}):Play()

	if clone:FindFirstChild("Attachment") then
		for _, emitter in pairs(clone.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end
end