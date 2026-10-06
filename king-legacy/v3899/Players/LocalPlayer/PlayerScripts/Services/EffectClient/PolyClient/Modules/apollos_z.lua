local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(p, _)
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
	local function localshake(p2)
		if localPlayer == p.player then
			_G.shake(p2)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rangeshake(p2, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - p.cf.p).Magnitude then
			_G.shake(p2)
		end
	end

	local cf = p.cf
	local AT1s = {}
	local beams = {}

	for i = 7, 1, -1 do
		localshake("SmallerBump") -- equivalent call inferred; original call site unknown
		local cFrame = cf * CFrame.Angles(0, 1.0471975511965976 * i, 0) * CFrame.new(0, i * 5 + 10, 47.5) * CFrame.new(
			0,
			0,
			-i * 2.5
		)
		local worldCFrame = nil

		if i == 7 then
			cFrame = cf * CFrame.Angles(0, 1.0471975511965976 * 7, 0) * CFrame.new(0, 7 * 5 + 25, 0)
		end

		if i - 1 <= 7 then
			local v3 = i - 1
			worldCFrame = cf * CFrame.Angles(0, 1.0471975511965976 * v3, 0) * CFrame.new(0, v3 * 5 + 10, 47.5) * CFrame.new(
				0,
				0,
				-v3 * 2.5
			)

			if v3 == 7 then
				worldCFrame = cf * CFrame.Angles(0, 1.0471975511965976 * 7, 0) * CFrame.new(0, 7 * 5 + 25, 0)
			end
		end

		local clone = replicatedStorage.Chest.SwordEffect.Apollos.apollos_z.Part:Clone()
		clone.CFrame = cFrame
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1.5)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://10839292363",
			Volume = 2
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		AT1s[#AT1s + 1] = clone.AT1
		beams[#beams + 1] = clone.Beam
		clone.AT1.bstar:Emit(2)
		TweenService:Create(clone.Beam, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Width0 = 2,
			Width1 = 2
		}):Play()

		if worldCFrame then
			TweenService:Create(
				clone.AT2,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					WorldCFrame = worldCFrame
				}
			):Play()
		end

		wait(0.05)
	end

	local clone = replicatedStorage.Chest.SwordEffect.Apollos.apollos_z.floor:Clone()
	clone.Size = createVector(0, 1, 0)
	clone.CFrame = cf
	clone.Parent = workspace.Effects
	clone.Decal.Texture = "rbxassetid://10964266562"
	TweenService:Create(clone, TweenInfo.new(0.125, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(97, 1, 97)
	}):Play()
	TweenService:Create(clone.PointLight, TweenInfo.new(0.125, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Range = 80
	}):Play()
	clone.Attachment.sparkl1:Emit(10)
	clone.Attachment.sparkl2:Emit(10)
	clone.Attachment.big:Emit(3)
	clone.Attachment.Spark:Emit(1)
	clone.Attachment.flare:Emit(40)
	clone.Attachment.flare2:Emit(40)
	clone.Attachment.glass:Emit(15)
	clone.Attachment.glass2:Emit(15)
	clone.Attachment.Spark1:Emit(4)
	clone.Attachment.beam:Emit(3)
	clone.Attachment.Specs:Emit(25)
	clone.slow_shard:Emit(15)
	TweenService:Create(clone.Attachment, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Orientation = clone.Attachment.Orientation + createVector(0, 60, 0)
	}):Play()
	local clone2 = replicatedStorage.Chest.SwordEffect.Apollos.apollos_z.wind_ring:Clone()
	clone2.Parent = workspace.Effects
	clone2.CFrame = CFrame.new(cf.p + createVector(0, 2.5, 0)) * CFrame.Angles(0, 1.5707963267948966, 0)
	_G.PU:Dust(clone2, 1)
	local ModuleScript = require(clone2.ModuleScript)
	ModuleScript(60)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://10839302421",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local clone3 = script.bw:Clone()
	clone3.Parent = game.Lighting
	wait(0.1)
	clone3:Destroy()

	local function createslash()
		rangeshake("Bump", 70) -- equivalent call inferred; original call site unknown
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0), {
			Size = createVector(105, 1, 105)
		}):Play()
		TweenService:Create(
			clone.PointLight,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = 1.5
			}
		):Play()
		clone.Attachment.big:Emit(1)
		clone.Attachment.glass:Emit(15)
		clone.Attachment.glass2:Emit(15)
		clone.Attachment.flare:Emit(10)
		clone.Attachment.flare2:Emit(10)
		clone.Attachment.Specs:Emit(20)
		clone.slow_shard:Emit(15)
		clone.shard:Emit(15)
		clone.Attachment.beam:Emit(3)
		clone.Attachment.ring1:Emit(2)
		clone.Attachment.ring2:Emit(2)
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://10860759482",
			Volume = 2
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone
		sound2:Play()

		for _ = 1, math.random(1, 2) do
			local clone4 = replicatedStorage.Chest.SwordEffect.Apollos.apollos_z.big_symbol:Clone()
			clone4.Parent = workspace.Effects
			clone4.CFrame = cf * CFrame.new(math.random(-60, 60) / 2, 20, math.random(-60, 60) / 2) * CFrame.new(
				0,
				math.random(0, 20),
				0
			)
			_G.PU:Dust(clone4, 1)
			local ModuleScript2 = require(clone4.ModuleScript)
			ModuleScript2()
		end

		PeodizService.ForLoop({
			Step = 2,
			WaitTime = 0.25
		}, function(p2)
			local v = math.floor(p2 * 2)
			local clone4 = replicatedStorage.Chest.SwordEffect.Apollos.apollos_z.slash2:Clone()
			clone4.CFrame = cf * CFrame.new(0, 15, 0) * CFrame.Angles(0.29670597283903605, 0, 0) * CFrame.Angles(
				0,
				6.283185307179586 * math.random(),
				0
			)
			clone4.Parent = workspace.Effects
			_G.PU:Dust(clone4, 1.25)
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://10756800684",
				Volume = 2
			})
			_G.PU:Dust(sound3, 3)
			sound3.Parent = clone4
			sound3:Play()
			local sound4 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://7104937177",
				PlaybackSpeed = 0.85,
				Volume = 1
			})
			_G.PU:Dust(sound4, 3)
			sound4.Parent = clone4
			sound4:Play()
			clone4.Mesh.Scale = createVector(1.3499999, 1.3499999, 1.3499999)

			if v % 2 == 1 then
				clone4.CFrame = cf * CFrame.new(0, 15, 0) * CFrame.Angles(-0.29670597283903605, 0, 0) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
			end

			TweenService:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone4.CFrame * CFrame.Angles(0, 6.283185307179586, 0)
			}):Play()
			TweenService:Create(clone4.Mesh, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = createVector(1.8, 1.8, 1.8)
			}):Play()
			task.spawn(function()
				local Animate = require(clone4.Animate)
				Animate()
			end)
		end)
	end

	for _, v in pairs(AT1s) do
		v.star.Enabled = false
		v.bstar.Enabled = false
	end

	for _, v in pairs(beams) do
		TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end

	PeodizService.ForLoop({
		Step = 3,
		WaitTime = 1
	}, function(_)
		task.spawn(function()
			createslash()
		end)
	end)
	TweenService:Create(clone.PointLight, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {
		Brightness = 0.5,
		Range = 0
	}):Play()
	local Animate = require(clone.Animate)
	Animate()
	_G.PU:Dust(clone, 2)
	task.delay(10, function()
		table.clear(beams)
		table.clear(AT1s)
	end)
end