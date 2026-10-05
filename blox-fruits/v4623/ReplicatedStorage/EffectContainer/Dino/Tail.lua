local _ = game.Players.LocalPlayer
local player = nil
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local tail = FX:WaitForChild("Dino").Tail
local _ = workspace._WorldOrigin
return function(data)
	player = data.player
	local root = data.Root
	local cFrame = root.CFrame

	if data.Destroy then
		local dinoTail = root.Parent:FindFirstChild("DinoTail")

		if dinoTail then
			dinoTail:Destroy()
		end
	else
		if root.Parent:FindFirstChild("DinoTail") then
			return
		end

		local clone = tail.DinoTail:Clone()
		Util.SetParentOverrideWithColor(clone, root.Parent, player, "TRexFruitVFXColor")
		clone.RootPart.CFrame = cFrame
		clone.RootPart.Weld.C0 *= CFrame.new(0, 0.5, 0.25)
		clone.RootPart.Weld.Part0 = root.Parent.LowerTorso
		Util.Anims:Get(clone, "TRexHybridTailIdle"):Play()
	end
end