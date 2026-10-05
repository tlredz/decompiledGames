game:GetService("TweenService")
local mRcoolThingsStickman = workspace.SkillsJanuary_2025.MRcoolThingsStickman
Random.new(3.141592653589793)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
return {
	Fire = function(p, p2)
		local position = p2.Position
		local _ = p2.GroundPosition

		if position then
			task.spawn(function()
				math.random(-180, 180)
				local clone = mRcoolThingsStickman.StickmanFlipbook:Clone()
				clone:PivotTo(position)
				clone.Parent = workspace.Thrown
				game.Debris:AddItem(clone, 3)
				local big = clone.big
				local small = clone.small
				task.delay(0.01, function()
					p.Auxillary:MeshFlipbook(big, "StickmanMeshFlipbookThing2Alteredbig", nil, 0.01)
				end)
				p.Auxillary:MeshFlipbook(small, "StickmanMeshFlipbookThingSmall1", nil, 0.01)
				task.delay(0.15, function()
					small.Decal.Transparency = 1
					big.Decal.Transparency = 1
				end)
			end)
		end
	end
}