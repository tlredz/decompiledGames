local _ = game.Players.LocalPlayer
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local _WorldOrigin = workspace._WorldOrigin
return function(player)
	local character = player.Character
	local rightHand = character.RightHand
	local humanoidRootPart = character.HumanoidRootPart

	if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 or not player.Holding then
		return
	end

	math.min(9.5, humanoidRootPart.Size.Y * 0.5 + humanoidRootPart.Parent.Humanoid.HipHeight)
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local clone = script.Aura:Clone()
	clone.CFrame = rightHand.CFrame
	clone.Parent = folder
	clone.Weld.Part0 = rightHand

	repeat
		task.wait()
	until not (player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace))

	local clone2 = FX:WaitForChild("Angel").AngelGrab.StartImpact:Clone()
	clone2.CFrame = CFrame.new(humanoidRootPart.Position)
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end

	task.wait(0.7)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Util.Debris:AddItem(folder, 2)
end