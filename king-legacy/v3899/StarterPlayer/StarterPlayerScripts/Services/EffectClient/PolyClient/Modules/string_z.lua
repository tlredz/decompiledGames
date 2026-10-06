local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
game:GetService("TweenService")
return function(data, _)
	local cf = data.cf
	local fromcf = data.fromcf
	local cFrame = cf * CFrame.new(0, 3, 0)

	if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < 40 or game.Players.LocalPlayer == data.player then
		_G.shake("SmallBump")
	end

	local v2 = {
		Color3.fromRGB(255, 37, 37),
		Color3.fromRGB(255, 180, 50),
		Color3.fromRGB(130, 255, 84),
		Color3.fromRGB(30, 110, 255),
		Color3.fromRGB(255, 41, 238)
	}
	local clone = replicatedStorage.Chest.FruitEffect.String.WindRing2:Clone()
	clone.CFrame = fromcf * CFrame.new(0, 0, -data.mag) * CFrame.new(0, 0, 5) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 1)
	task.spawn(function()
		local ModuleScript = require(clone.ModuleScript)
		ModuleScript()
	end)
	task.spawn(function()
		local clone2 = replicatedStorage.Chest.FruitEffect.String.rainbowtrail:Clone()
		clone2.CFrame = fromcf
		clone2.Parent = workspace.Effects
		clone2.Sparks:Emit(1)
		game.TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = cFrame
		}):Play()
		local lastTime = tick()

		while wait() and not (tick() - lastTime > 0.24) do
			clone2.Sparks:Emit(1)
			clone2.Sparks.Color = ColorSequence.new(v2[math.random(1, 5)])
		end

		clone2.Sparks.Parent = nil
		_G.PU:Dust(clone2, 1)
	end)
	wait()
	local clone2 = replicatedStorage.Chest.FruitEffect.String.rbstring:Clone()
	clone2:SetPrimaryPartCFrame(cFrame)
	clone2.Parent = workspace.Effects
	local ModuleScript = require(clone2.ModuleScript)
	ModuleScript(cFrame)
	_G.PU:Dust(clone2, 3)
end