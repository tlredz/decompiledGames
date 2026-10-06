local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
game:GetService("TweenService")
return function(p, _)
	local cf = p.cf
	local clone = replicatedStorage.Chest.FruitEffect.String.CloneFX:Clone()
	clone.Parent = workspace.Effects
	clone:SetPrimaryPartCFrame(cf)
	local ModuleScript = require(clone.ModuleScript)
	ModuleScript()
	_G.PU:Dust(clone, 5)
end