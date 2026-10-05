local _ = game.Players.LocalPlayer
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local script2 = script
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
return function(p)
	local root = p.Root
	local holding = p.Holding

	if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local cFrame = root.CFrame
	local clone = script2.Phase1.Flight:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	clone.Anchored = false
	clone.Weld.Part0 = root
	clone.Weld.C0 = CFrame.new(0, -1.66, 0)

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local v = Util.Sound:Play("SpinningWithWindLoop", root)

	while holding:IsDescendantOf(workspace) and holding.Value do
		wait()
	end

	Util.Sound:FadeOut(v, 0.3)
	clone.Weld.Enabled = false
	clone.Anchored = true

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	task.delay(2, function()
		folder:Destroy()
	end)
end