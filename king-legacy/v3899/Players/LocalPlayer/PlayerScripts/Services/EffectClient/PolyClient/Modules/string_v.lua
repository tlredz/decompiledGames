local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local cf = data.cf
	local clone = replicatedStorage.Chest.FruitEffect.String.WindCircle:Clone()
	clone.CFrame = cf * CFrame.new(0, 100, 0)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 1)
	task.spawn(function()
		local ModuleScript = require(clone.ModuleScript)
		ModuleScript()
	end)
	local clone2 = replicatedStorage.Chest.FruitEffect.String.fx:Clone()
	clone2.CFrame = cf
	clone2.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9366054763",
		Volume = 3
	})
	_G.PU:Dust(sound, 5)
	sound.Parent = clone2
	sound:Play()
	_G.PU:Dust(clone2, 5)
	task.spawn(function()
		wait()

		for _ = 1, math.random(3, 4) do
			local v = math.random(50, 75)
			local clone3 = replicatedStorage.Chest.FruitEffect.String.sphere:Clone()
			clone3.CFrame = cf * CFrame.new(math.random(-10, 10), 150, math.random(-10, 10)) * CFrame.new(
				0,
				math.random(-10, 10),
				0
			)
			clone3.Size = Vector3.new(0.25, v, 0.25)
			clone3.Transparency = 0
			clone3.Parent = workspace.Effects
			game.TweenService:Create(
				clone3,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new()
				}
			):Play()
			game.TweenService:Create(
				clone3,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone3.CFrame * CFrame.new(0, -150 + v / 3, 0)
				}
			):Play()
			_G.PU:Dust(clone3, 0.5)
			task.spawn(function()
				wait(0.15)
				game.TweenService:Create(
					clone3,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end

		local pointLight = clone2.PointLight
		TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Range = 60,
			Brightness = 0.5
		}):Play()
		clone2.start.big:Emit(1)
		wait(0.6)
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(255, 139, 85),
			Brightness = 0.5
		}):Play()
		TweenService:Create(pointLight, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Range = 65
		}):Play()
		wait(1)
		TweenService:Create(pointLight, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Range = 0,
			Brightness = 0
		}):Play()
	end)
	local jail = data.jail

	if jail and data.plr == localPlayer then
		jail.CanCollide = false
	end

	for _ = 1, 3 do
		task.wait()
		local clone3 = replicatedStorage.Chest.FruitEffect.String.webdown:Clone()
		clone3.CFrame = cf * CFrame.new(0, 150, 0)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 3)
		task.spawn(function()
			local ModuleScript = require(clone3.ModuleScript)
			ModuleScript()
		end)
	end

	if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 90 or localPlayer == data.plr then
		_G.shake("SmallBump")
	end

	PeodizService.ForLoop({
		Step = 13
	}, function(p)
		local v = math.floor(p * 13)
		local cframe = CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		local v2

		if v == 1 then
			cframe = CFrame.Angles(0, 0, -0.6283185307179586)
			v2 = 0.2
		else
			v2 = 0.1
		end

		local clone3 = replicatedStorage.Chest.FruitEffect.String.circleweb:Clone()
		clone3.CFrame = cf * cframe
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 3)
		task.spawn(function()
			local ModuleScript = require(clone3.ModuleScript)
			ModuleScript(v, v2)
		end)
	end)
	wait(1.25)
	local clone3 = replicatedStorage.Chest.FruitEffect.String.stringexp:Clone()
	_G.PU:Dust(clone3, 3)
	clone3.CFrame = cf * CFrame.new(0, 0.5, 0)
	clone3.Parent = workspace.Effects
	clone3.Attachment.big:Emit(1)
	clone3.Attachment.Ring2:Emit(1)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1250,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://2648563122",
		Volume = 1.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone3
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 400,
		RollOffMinDistance = 25,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5169902349",
		Volume = 3.5
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone3
	sound3:Play()
	wait()
	clone3.Attachment.Ring:Emit(1)
	local ray = Ray.new((cf * CFrame.new(0, 5, 0)).p, createVector(0, -13, 0))
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Island }
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
	local instance

	if raycastResult then
		instance = raycastResult.Instance or nil
	end

	if not (raycastResult and raycastResult.Position) then
		local _ = ray.Origin + ray.Direction
	end

	if instance then
		clone3.Attachment.Crack:Emit(8)
	end

	clone3.Attachment.Sparks:Emit(25)
	clone3.Attachment.BrightWave:Emit(5)
	clone3.Attachment.Blast:Emit(25)
	clone3.Attachment.sparkl1:Emit(10)
	clone3.Attachment.sparkl2:Emit(10)
	local clone4 = replicatedStorage.Chest.FruitEffect.String.cy:Clone()
	_G.PU:Dust(clone4, 3)
	clone4.CFrame = cf * CFrame.Angles(0, 0, 1.5707963267948966)
	clone4.Parent = workspace.Effects
	clone4.Specs:Emit(30)
	local groundcrack = require(script.groundcrack)
	groundcrack(CFrame.new(cf.p))
	local pointLight = clone3.PointLight
	TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Range = 60,
		Brightness = 1
	}):Play()
	task.spawn(function()
		wait(1)
		TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Range = 0,
			Brightness = 0
		}):Play()
	end)

	if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 90 or localPlayer == data.plr then
		_G.shake("Bump2")
	end
end