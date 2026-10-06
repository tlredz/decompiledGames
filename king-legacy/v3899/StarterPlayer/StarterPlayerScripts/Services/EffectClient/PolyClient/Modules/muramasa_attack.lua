local replicatedStorage = game.ReplicatedStorage
local v = {
	CFrame.Angles(-0.08726646259971647, -0.4363323129985824, 0),
	CFrame.Angles(0, -0.4363323129985824, 3.141592653589793),
	CFrame.Angles(-0.17453292519943295, -0.4363323129985824, 0),
	(CFrame.Angles(0, -0.4363323129985824, 3.141592653589793))
}
return function(data, p)
	wait(0.1)

	if p == "Bindable" then
		wait(0.1)
	end

	if data.anim == 4 and data.mode then
		if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - data.root.CFrame.p).Magnitude < 30 then
			_G.shake("Bump")
		end

		local clone = replicatedStorage.Chest.SwordEffect.Muramasa.flame_floor2:Clone()
		clone.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, -2.5, 0) * CFrame.Angles(
			0,
			6.283185307179586 * math.random(),
			0
		)
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1)
		local ModuleScript = require(clone.ModuleScript)
		ModuleScript()
		local clone2 = replicatedStorage.Chest.SwordEffect.Muramasa.muramasa_slash2:Clone()
		clone2.CFrame = CFrame.new(data.root.CFrame.p, data.cf.p) * CFrame.new(0, 1, 0) * v[data.anim]
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 1.5)
		clone2.Attachment2.Swirl:Emit(3)
		clone2.Attachment2.Swirl2:Emit(3)
		clone2.Attachment2.Swirl3:Emit(3)
		clone2.Attachment2.Swirl4:Emit(3)
		clone2.Attachment2.Swirl5:Emit(4)
		clone2.Attachment3.sm2:Emit(50)
		clone2.Attachment3.Flames:Emit(30)
		local Animate = require(clone2.Animate)
		Animate()
	else
		local clone = replicatedStorage.Chest.SwordEffect.Muramasa.muramasa_attack:Clone()

		if data.mode then
			clone = replicatedStorage.Chest.SwordEffect.Muramasa.muramasa_attack2:Clone()
		end

		clone.CFrame = data.root.CFrame * CFrame.new(0, 1, 0) * v[data.anim]
		clone.Parent = workspace.Effects
		local Animate = require(clone.Animate)
		Animate()
	end
end