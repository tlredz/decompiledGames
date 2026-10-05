local parent = script.Parent.Parent.Parent.Parent.Parent
local Fish = {}
Fish.__index = Fish

function Fish.new(p)
	local v = {}
	local v2 = {}

	for _, child in parent.FishData[p]:GetChildren() do
		v[child.Name] = child.Value
	end

	v2.Data = v
	return v2
end

function Fish:UpdateMovement() end

function Fish:UpdateIcon() end

function Fish:Update()
	self:UpdateMovement()
	self:UpdateIcon()
end

return Fish