local Pushups = {}

function Pushups.Do(_, p, p2, _, p3)
	local parent = p3.Parent.Parent
	p2.Mat = parent
	p2.W = Instance.new("Weld")
	p2.W.Part0 = p.HumanoidRootPart
	p2.W.Part1 = parent.Root
	p2.W.Parent = parent.Root
	return true, true
end

function Pushups.Destroying(_, _, p, _)
	if p.W ~= nil then
		p.W:Destroy()
		p.W = nil
	end
end

function Pushups.Stop(_, _, _, ...)
	return true
end

return Pushups