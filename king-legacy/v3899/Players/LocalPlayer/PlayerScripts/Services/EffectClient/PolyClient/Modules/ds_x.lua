local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
local Utility = require(replicatedStorage.Chest.Modules.Utility)
local FastRenderer = require(replicatedStorage.Chest.Modules.FastRenderer)
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

function SetupPart(p)
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.CastShadow = false
	p.Massless = true
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

	local cf = p.cf
	local skillX = replicatedStorage.Chest.SwordEffect.DragonsStandard.SkillX
	task.spawn(function()
		if localPlayer == p.plr then
			local currentCamera = workspace.CurrentCamera
			local clone = skillX.CameraFX:Clone()
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

	for i = 1, 3 do
		local v = cf * CFrame.Angles(0, 2.0943951023931953 * i, 0) * CFrame.new(0, 20, 45) * CFrame.Angles(
			0,
			6.283185307179586 * math.random(),
			(math.rad((math.random(-25, 25))))
		)
		local clone = replicatedStorage.Chest.SwordEffect.DragonsStandard.fake2:Clone()
		clone.Parent = workspace.Effects
		clone:PivotTo(v)
		clone.AnimationController:LoadAnimation(replicatedStorage.Chest.Animation["Dragons Standard"].Idle):Play()
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = v
		TweenService:Create(cFrameValue, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Value = cFrameValue.Value * CFrame.new(0, -12.5, 0)
		}):Play()
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 0.25
			}, function()
				if not clone or clone and not clone.Parent then
					return true
				end

				clone:PivotTo(cFrameValue.Value)
			end)
		end)
		local clone2 = skillX.Step1:Clone()
		SetupPart(clone2)
		clone2.CFrame = CFrame.new((v * CFrame.new(0, -23, 0)).p)
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
			PlaybackSpeed = 1.2,
			Volume = 1.5
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone2
		sound2:Play()
		local clone3 = skillX.Step2:Clone()
		SetupPart(clone3)
		clone3.CFrame = CFrame.new((v * CFrame.new(0, -23, 0)).p)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 6)
		task.spawn(function()
			task.wait(0.5)
			PeodizService.ForceForLoop({
				Step = 3,
				WaitTime = 1,
				Instant = true
			}, function()
				PeodizService.ForceForLoop({
					Step = 3,
					WaitTime = 0.2,
					Instant = true
				}, function()
					Utility.EmitParticles(clone3)
					local sound3 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://13870577360",
						PlaybackSpeed = 1.2,
						Volume = 1.5
					})
					_G.PU:Dust(sound3, 3)
					sound3.Parent = clone3
					sound3:Play()
					rangeshake("SmallerBump", 60) -- equivalent call inferred; original call site unknown
				end)
			end)
		end)
		local v5 = clone
		task.spawn(function()
			task.wait(6)

			for i2, part in pairs(v5:GetChildren()) do
				if part:IsA("BasePart") then
					TweenService:Create(
						part,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end
			end

			for i2, emitter in pairs(v5.Handle:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		_G.PU:Dust(clone, 7)
	end
end