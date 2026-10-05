local TargetShooting = {}

function TargetShooting.Do(_, p, p2, _, p3)
	local parent = p3.Parent.Parent
	p2.Station = parent
	p2.W = Instance.new("Weld")
	p2.W.Part0 = p.HumanoidRootPart
	p2.W.Part1 = parent.Root
	p2.W.Parent = parent.Root
	return true, true
end

function TargetShooting.Destroying(_, _, p, _)
	if p.W ~= nil then
		p.W:Destroy()
		p.W = nil
	end
end

function TargetShooting.Stop(_, _, _, ...)
	return true
end

return TargetShooting