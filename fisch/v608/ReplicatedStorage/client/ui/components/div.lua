local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
require(script.Parent.Parent.state)

local function loadDefaultProp(p, p2: string, p3)
	if not p[p2] then
		p[p2] = p3
	end
end

return function(state)
	local uDim = UDim2.fromScale(0.5, 0.5)

	if not state.Position then
		state.Position = uDim
	end

	local vector = Vector2.new(0.5, 0.5)

	if not state.AnchorPoint then
		state.AnchorPoint = vector
	end

	if not state.BackgroundTransparency then
		state.BackgroundTransparency = 1
	end

	return vide.create("Frame")(state)
end