return function(data)
	local root = data.Root

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local Wings = require(game.ReplicatedStorage.Util.Wings)
	local v = Wings.Attach({
		Root = root,
		Size = 1,
		Permanent = true,
		Type = "DracoWings"
	}):Activate()
	local energy = data.Energy
	v:SetAnim("Jetpack", energy / 25)

	repeat
		energy -= task.wait() * 100 / 4
		v:SetAnim("Jetpack", (math.max(0.5, energy / 25)))
		v:SetRate(energy / 100)
	until energy <= 0 or not (data.Reference and data.Reference:IsDescendantOf(workspace))

	v:SetRate(0)
	v:SetAnim(nil)
	v:Destroy()
end