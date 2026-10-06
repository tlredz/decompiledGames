local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
return function(p, _)
	local clone = replicatedStorage.Chest.SwordEffect.Muramasa.muramasa_cast:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = p.cf
	clone.Attachment.Swirl:Emit(5)
	clone.Attachment.Swirl2:Emit(3)
	clone.Attachment.Swirl3:Emit(3)
	_G.PU:Dust(clone, 2)
	local clone2 = replicatedStorage.Chest.SwordEffect.Muramasa.muramasa_cast:Clone()
	clone2.Parent = workspace.Effects
	clone2.CFrame = p.cf * CFrame.Angles(0, 0, 0.4363323129985824) * CFrame.Angles(
		3.141592653589793,
		-2.443460952792061,
		0
	)
	_G.PU:Dust(clone2, 2)
	local clone3 = replicatedStorage.Chest.SwordEffect.Muramasa.muramasa_slash:Clone()
	clone3.Parent = workspace.Effects
	clone3.CFrame = p.cf * CFrame.Angles(0, 0, 0.4363323129985824) * CFrame.Angles(
		3.141592653589793,
		-2.0943951023931953,
		0
	)
	local Animate = require(clone3.Animate)
	Animate()
	_G.PU:Dust(clone3, 1.5)
end