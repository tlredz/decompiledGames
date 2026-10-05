local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.instanceIsA("BasePart"))
local strict2 = t.strict(t.string)

local function buttonWithin(instance, childName: string)
	local button = instance:FindFirstChild(childName, true)

	if button and button:IsA("GuiButton") then
		return button
	end

	return nil
end

return {
	Find = function(instance, childName: string)
		strict(instance)
		strict2(childName)
		local children = instance:GetChildren()
		local button = nil
		local v = 1

		while button == nil and v <= #children do
			local surfaceGui = children[v]

			if surfaceGui:IsA("SurfaceGui") then
				button = surfaceGui:FindFirstChild(childName, true)

				if not (button and button:IsA("GuiButton")) then
					button = nil
				end
			else
				button = nil
			end

			v += 1
		end

		return button
	end
}