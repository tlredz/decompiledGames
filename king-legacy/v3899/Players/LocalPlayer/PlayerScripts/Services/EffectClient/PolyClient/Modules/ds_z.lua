local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local TweenService = game:GetService("TweenService")
local Utility = require(replicatedStorage2.Chest.Modules.Utility)
local FastRenderer = require(replicatedStorage2.Chest.Modules.FastRenderer)
local RunService = game:GetService("RunService")

function resizeModel(folder, p)
	local position = folder.PrimaryPart.Position

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Position = position:Lerp(part.Position, p)
		part.Size *= p
	end
end

function tweenModelSize(p, p2, p3, p4, p5)
	local v = p3 - 1
	local v2 = 0
	local v3 = 0

	while v2 < 1 do
		v2 = math.min(v2 + RunService.Heartbeat:Wait() / p2, 1)
		local value = TweenService:GetValue(v2, p4, p5)
		resizeModel(p, (value * v + 1) / (v3 * v + 1))
		v3 = value
	end
end

function SetupPart(p)
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.CastShadow = false
	p.Massless = true
end

return function(p, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p2)
		if localPlayer == p.plr then
			_G.shake(p2)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
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

	local skillZ = replicatedStorage2.Chest.SwordEffect.DragonsStandard.SkillZ
	task.spawn(function()
		if localPlayer == p.plr then
			local currentCamera = workspace.CurrentCamera
			local clone = skillZ.CameraFX:Clone()
			SetupPart(clone)
			clone.CFrame = currentCamera.CFrame
			clone.Parent = currentCamera
			_G.PU:Dust(clone, 1)
			Utility.EmitParticles(clone)
			FastRenderer.new({
				Time = 1
			}, function()
				if clone and not clone.Parent then
					return true
				end

				clone.CFrame = currentCamera.CFrame
			end)
		end
	end)
	local cf = p.cf
	rangeshake("Bump2", 60) -- equivalent call inferred; original call site unknown

	if localPlayer == p.plr then
		local clone = script.ColorCorrection:Clone()
		clone.Parent = game.Lighting
		TweenService:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
		_G.PU:Dust(clone, 2)
	end

	local clone = replicatedStorage2.Chest.SwordEffect.DragonsStandard.fake:Clone()
	clone.Parent = workspace.Effects
	clone:SetPrimaryPartCFrame(cf * CFrame.new(0, 23, 0))
	_G.PU.PlayOneShotAnim({
		Animator = clone.AnimationController,
		Animation = replicatedStorage2.Chest.Animation["Dragons Standard"].Idle
	})
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = cf * CFrame.new(0, 23, 0)
	cFrameValue.Parent = workspace.Effects
	TweenService:Create(cFrameValue, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = cFrameValue.Value * CFrame.new(0, -12.5, 0)
	}):Play()
	task.spawn(function()
		PeodizService.HeartbeatWait({
			Time = 0.55
		}, function(_)
			if not cFrameValue or cFrameValue and not cFrameValue.Parent then
				return true
			end

			clone:PivotTo(cFrameValue.Value)
		end)
		cFrameValue:Destroy()
		cFrameValue = nil
	end)
	task.spawn(function()
		wait(0.2)

		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("BasePart") then
				TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end
		end
	end)
	_G.PU:Dust(clone, 1)
	local clone2 = skillZ.Step1:Clone()
	SetupPart(clone2)
	clone2.CFrame = cf
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 3)
	Utility.EmitParticles(clone2)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13859742618",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13859816402",
		Volume = 1.5,
		PlaybackSpeed = 1.2
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	local position = (clone2.CFrame * CFrame.new(0, 0, 0)).Position
	local v4 = clone2.CFrame.UpVector * -10
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Island }
	local raycastResult = workspace:Raycast(position, v4, raycastParams)

	if raycastResult then
		local position2 = raycastResult.Position
		local clone3 = skillZ.Ground_Ray:Clone()
		clone3.Anchored = true
		clone3.CanCollide = false
		clone3.Transparency = 1
		clone3.CFrame = CFrame.new(position2 + Vector3.new(0, clone3.Size.Y / 2, 0)) * CFrame.Angles(
			0,
			math.rad(clone2.Orientation.Y),
			0
		)
		clone3.Parent = workspace.Effects
		Utility.EmitParticles(clone3)
		_G.PU:Dust(clone3, 4)
	end
end