local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Blade").Passive.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
game:GetService("TweenService")
game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local CreateBlade = require(script.Parent.Modules.CreateBlade)
return function(player)
	local character = player.Character or player.Root and player.Root.Parent
	local TryGetColorFolderParent = require(game.ReplicatedStorage.Modules.TryGetColorFolderParent)
	local tryGetColorFolderParent = TryGetColorFolderParent(player)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 500 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 2)
	local blade = CreateBlade(
		humanoidRootPart.Parent.RightLowerArm,
		folder,
		CFrame.Angles(0, 3.141592653589793, 0),
		tryGetColorFolderParent
	)
	local blade2 = CreateBlade(humanoidRootPart.Parent.LeftLowerArm, folder, nil, tryGetColorFolderParent)
	local cFrame = humanoidRootPart.CFrame
	local clone = assets.Phase1.Spark:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, tryGetColorFolderParent, "BladeFruitVFXColor")

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter
		task.spawn(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			v4:Emit(v4:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	Util.Sound:Play("ShortClash" .. math.random(1, 3), cFrame)
	task.spawn(function()
		task.wait(0.1)
		task.spawn(function()
			blade:Shrink()
		end)
		blade2:Shrink()
	end)
end