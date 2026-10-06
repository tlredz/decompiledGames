local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local DISTANCE_THRESHOLD = 40
	local cf = data.cf
	local stud = data.stud
	local tocf = data.tocf
	local plr = data.plr
	local ver = data.ver

	if ver == 2 then
		local awake = require(script.awake)
		awake(data)
	elseif ver == 3 then
		local awake2 = require(script.awake2)
		awake2(data)
	else
		local localPlayer = game.Players.LocalPlayer

		if plr == localPlayer then
			game.TweenService:Create(
				localPlayer.Character.HumanoidRootPart,
				TweenInfo.new(0.03 * stud, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = tocf
				}
			):Play()
		end

		if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < DISTANCE_THRESHOLD then
			_G.shake("SmallBump")
		end

		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9091623120",
			Volume = 1.25,
			PlaybackSpeed = 1.25
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = data.parent
		sound:Play()

		for _ = 1, 3 do
			local clone = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
			clone.CFrame = cf * CFrame.new(math.random(-5, 5), 0, -math.random(0, 12.5))
			clone.Size = createVector(4, 4, 0.5)
			clone.Transparency = -5
			clone.Parent = workspace.Effects
			game.TweenService:Create(
				clone,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(0.05, 0.05, math.random(50, 75))
				}
			):Play()
			game.TweenService:Create(
				clone,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.new(0, 0, -37.5)
				}
			):Play()
			task.spawn(function()
				wait()
				game.TweenService:Create(
					clone,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			_G.PU:Dust(clone, 1)
		end

		PeodizService.ForLoop({
			Step = stud
		}, function(p)
			local v = math.floor(p * stud)
			local clone = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.muramasa_slash2:Clone()
			clone.Parent = workspace.Effects
			clone.Mesh.Scale = clone.Mesh.Scale * math.random(7, 10) / 10
			clone.Size = createVector(9.1305, 0.00075, 9.1305)
			clone.CFrame = cf * CFrame.new(math.random(-25, 25) / 10, 0, -v * 10) * CFrame.Angles(
				0,
				0,
				(math.rad((math.random(-15, 15))))
			) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)

			if math.random(1, 2) == 1 then
				clone.CFrame *= CFrame.Angles(3.141592653589793, 0, 0)
			end

			local Animate = require(clone.Animate)
			Animate()
			clone.CFrame = CFrame.new(clone.CFrame.p)
			clone.sakura:Emit(3)
			clone.Specs:Emit(3)
			_G.PU:Dust(clone, 1)
		end)

		if (localPlayer.Character.HumanoidRootPart.Position - tocf.p).Magnitude < DISTANCE_THRESHOLD then
			_G.shake("SmallBump")
		end

		task.spawn(function()
			local clone = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.muramasa_slash3:Clone()
			clone.Parent = workspace.Effects
			clone.Mesh.Scale = clone.Mesh.Scale * 1.25
			clone.CFrame = tocf * CFrame.Angles(0, 0, 0.2617993877991494)
			local Animate = require(clone.Animate)
			Animate()
			_G.PU:Dust(clone, 1)
			local clone2 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.wind:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = tocf
			local ModuleScript = require(clone2.ModuleScript)
			ModuleScript()
			local clone3 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.slashbeam:Clone()
			clone3.Parent = workspace.Effects
			clone3.CFrame = tocf * CFrame.Angles(0, 0, 0.2617993877991494) * CFrame.new(0, 0, -clone.Mesh.Scale.X)
			_G.PU:Dust(clone3, 2)
			task.spawn(function()
				clone3.Center.Spark:Emit(2)
				clone3.Center.Spark2:Emit(2)
				clone3.Center.sakura:Emit(25)
				clone3.Attachment.Position = Vector3.new()
				clone3.Attachment2.Position = Vector3.new()
				game.TweenService:Create(
					clone3.Attachment,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Position = createVector(20, 0, 0)
					}
				):Play()
				game.TweenService:Create(
					clone3.Attachment2,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Position = createVector(-20, 0, 0)
					}
				):Play()
				clone3.Beam.Width0 = 1.5
				clone3.Beam.Width1 = 1.5
				wait(0.05)
				game.TweenService:Create(
					clone3.Beam,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				):Play()
			end)
		end)
		wait(0.1)

		if (localPlayer.Character.HumanoidRootPart.Position - tocf.p).Magnitude < DISTANCE_THRESHOLD then
			_G.shake({
				1,
				3,
				0,
				0.5
			})
		end

		task.spawn(function()
			local clone = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.muramasa_slash4:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = tocf * CFrame.new(0, 2, -5) * CFrame.Angles(0, 0.3141592653589793, 1.5707963267948966) * CFrame.Angles(
				3.141592653589793,
				0,
				0
			) * CFrame.Angles(0, 0, -0.4363323129985824) * CFrame.Angles(0, 0.4363323129985824, 0)
			local Animate = require(clone.Animate)
			Animate()
			_G.PU:Dust(clone, 1)
			local clone2 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.wind:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = tocf
			local ModuleScript = require(clone2.ModuleScript)
			ModuleScript()
			local clone3 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.slashbeam:Clone()
			clone3.Parent = workspace.Effects
			clone3.CFrame = tocf * CFrame.new(0, 2, -5) * CFrame.Angles(0, 0.3141592653589793, 1.5707963267948966) * CFrame.Angles(
				3.141592653589793,
				0,
				0
			) * CFrame.Angles(0, 0, -0.4363323129985824) * CFrame.Angles(3.141592653589793, 0, 0) * CFrame.new(
				0,
				0,
				-clone.Mesh.Scale.X
			)
			_G.PU:Dust(clone3, 2)
			task.spawn(function()
				clone3.Center.Spark:Emit(2)
				clone3.Center.Spark2:Emit(2)
				clone3.Center.sakura:Emit(25)
				clone3.Attachment.Position = Vector3.new()
				clone3.Attachment2.Position = Vector3.new()
				game.TweenService:Create(
					clone3.Attachment,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Position = createVector(20, 0, 0)
					}
				):Play()
				game.TweenService:Create(
					clone3.Attachment2,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Position = createVector(-20, 0, 0)
					}
				):Play()
				clone3.Beam.Width0 = 1.5
				clone3.Beam.Width1 = 1.5
				wait(0.05)

				if clone3:FindFirstChild("Beam") then
					game.TweenService:Create(
						clone3.Beam,
						TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					):Play()
				end
			end)
		end)
	end
end