local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local tocf = data.tocf
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local v = 100
	local p = tocf.p
	local v2 = "Explosion"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)
	PeodizService.ForLoop({
		Step = 5,
		WaitTime = 0.05
	}, function(p2)
		local v3 = math.floor(p2 * 5)
		tocf *= CFrame.new(0, 0, -20)
		local clone = ReplicatedStorage.Chest.Etc.Cyborg.volt:Clone()
		clone.CFrame = tocf
		clone.Size = Vector3.new()
		clone.Parent = workspace.Effects
		local clone2 = ReplicatedStorage.Chest.Etc.Cyborg.volt2:Clone()
		clone2.CFrame = tocf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		clone2.Mesh.Scale = Vector3.new()
		clone2.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://11271018931",
			PlaybackSpeed = 1,
			1,
			Volume = 3
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()

		if v3 == 1 then
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12053064330",
				Volume = 3
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone
			sound2:Play()
		end

		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(54.016502, 54.016502, 54.016502)
		}):Play()
		TweenService:Create(clone2.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Scale = createVector(0.34379998, 0.34379998, 0.34379998)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
		}):Play()
		TweenService:Create(
			clone.PointLight,
			TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Range = 0
			}
		):Play()
		clone.lightning:Emit(5)
		clone.lightning3:Emit(5)
		clone.rock:Emit(8)
		clone.Attachment.Blast2:Emit(5)
		clone.Attachment.shards1:Emit(7)
		clone.Attachment.circle:Emit(4)
		clone.Attachment.smoke:Emit(5)
		task.spawn(function()
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			wait(0.1)
			clone.Specs:Emit(5)
			clone.Attachment.shards1:Emit(7)
			local Animate = require(clone2.Animate)
			Animate()
			TweenService:Create(
				clone2.Decal,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end)
		_G.PU:Dust(clone, 2)
		_G.PU:Dust(clone2, 0.75)
	end)
end