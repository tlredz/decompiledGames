local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local fromcf = data.fromcf
	local tocf = data.tocf
	local magnitude = (fromcf.p - tocf.p).Magnitude
	local step = math.floor(magnitude / 10)
	local cframe = CFrame.new(fromcf.p, tocf.p)
	local clone = ReplicatedStorage.Chest.SwordEffect.SoulCane.Whirl:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
	local ModuleScript = require(clone.ModuleScript)
	ModuleScript()
	_G.PU:Dust(clone, 2)
	local clone2 = ReplicatedStorage.Chest.SwordEffect.SoulCane.sphere:Clone()
	clone2.CFrame = cframe * CFrame.new(0, 3, 0) * CFrame.new(0, 0, -magnitude / 2)
	clone2.Size = Vector3.new(3, 3, magnitude)
	clone2.Transparency = -1
	clone2.Color = Color3.fromRGB(110, 153, 202)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 0.75)
	task.spawn(function()
		wait()
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, magnitude)
		}):Play()
		wait(0.2)
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)

	if data.plr == game.Players.LocalPlayer then
		_G.shake("SmallBump")
	end

	task.spawn(function()
		wait(math.random() * wait())

		for _ = 1, math.random(2, 3) do
			local clone3 = ReplicatedStorage.Chest.SwordEffect.SoulCane.sphere:Clone()
			clone3.CFrame = cframe * CFrame.new(math.random(-3, 3), math.random(3, 8), -magnitude / 3) * CFrame.new(
				0,
				0,
				math.random(-3, 3)
			)
			clone3.Size = Vector3.new(1, 1, magnitude / 3)
			clone3.Transparency = -1
			clone3.Color = Color3.fromRGB(110, 153, 202)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.new(0, 0, -magnitude) * CFrame.new(0, 0, magnitude / 4)
			}):Play()
			_G.PU:Dust(clone3, 0.75)
			task.spawn(function()
				wait(0.2)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
	PeodizService.ForLoop({
		Step = step
	}, function(p)
		local v2 = math.floor(p * step)
		local clone3 = ReplicatedStorage.Chest.SwordEffect.SoulCane.icepath:Clone()
		clone3.CFrame = CFrame.new(fromcf.p, tocf.p) * CFrame.new(0, 0, v2 * -10)
		clone3.Parent = workspace.Effects
		clone3.Size = Vector3.new()
		clone3.Sm:Emit(10)
		clone3.Lines:Emit(8)
		TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(12.5, 0.875, 12.5)
		}):Play()
		task.spawn(function()
			wait(0.9)
			TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end)
		_G.PU:Dust(clone3, 2)

		if v2 % 2 == 1 then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9357891524",
				Volume = 0.1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone3
			sound:Play()
			task.wait()
		end
	end)
end