local replicatedStorage = game.ReplicatedStorage
local _ = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
return function(p, _)
	local localPlayer = game.Players.LocalPlayer
	local cf = p.cf

	if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 30 then
		_G.shake("SmallerBump")
	end

	local clone = replicatedStorage.Chest.FruitEffect.String.new.Spiral:Clone()
	_G.PU:Dust(clone, 1)
	clone.Parent = workspace.Effects
	clone:SetPrimaryPartCFrame(cf)
	task.spawn(function()
		task.wait()
		local ModuleScript = require(clone.ModuleScript)
		ModuleScript()
	end)

	for _, part in pairs(clone:GetChildren()) do
		if part:IsA("BasePart") and part ~= clone.PrimaryPart then
			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = part.CFrame * CFrame.new(-150, 0, 0)
			}):Play()
		end

		if part == clone.PrimaryPart then
			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = part.CFrame * CFrame.new(0, 0, -150)
			}):Play()
		end
	end

	local clone2 = replicatedStorage.Chest.FruitEffect.String.new.Spiral2:Clone()
	clone2.Parent = workspace.Effects
	clone2:SetPrimaryPartCFrame(cf * CFrame.new(0, 0, -5) * CFrame.Angles(0, 3.141592653589793, 0))
	_G.PU:Dust(clone2, 1)
	task.spawn(function()
		local ModuleScript = require(clone2.ModuleScript)
		ModuleScript()
	end)
	clone2.PrimaryPart.Spark:Emit(10)

	for _, part in pairs(clone2:GetChildren()) do
		if part:IsA("BasePart") and part ~= clone.PrimaryPart then
			TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = part.CFrame * CFrame.new(7.5, 0, 0)
			}):Play()
		end
	end

	for i = 1, 3 do
		local clone3 = replicatedStorage.Chest.FruitEffect.String.new.webhandler_x:Clone()
		clone3.Parent = workspace.Effects
		clone3.CFrame = cf * CFrame.Angles(0, 0, 2.0943951023931953 * i) * CFrame.Angles(0, 0, 1.5707963267948966)
		_G.PU:Dust(clone3, 1.5)
		task.spawn(function()
			local ModuleScript = require(clone3.ModuleScript)
			ModuleScript()
		end)
	end

	local clone3 = replicatedStorage.Chest.FruitEffect.String.new.WindRing2:Clone()
	clone3.CFrame = cf * CFrame.new(0, 0, -15) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 1)
	task.spawn(function()
		local ModuleScript = require(clone3.ModuleScript)
		ModuleScript()
	end)
	local clone4 = replicatedStorage.Chest.FruitEffect.String.new.smoko:Clone()
	clone4.CFrame = cf * CFrame.new(0, 0, -30) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 3)
	task.spawn(function()
		wait()
		local ModuleScript = require(clone4.ModuleScript)
		ModuleScript()
	end)
end