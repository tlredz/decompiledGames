local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Dropdown = require(ReplicatedStorage.CAM.Client.Components.Misc.Dropdown)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local ClassFilter = {
	ALL = "All"
}

function ClassFilter:Tally(p2: string)
	local item = Items[p2]
	local class

	if item ~= nil then
		class = item.Class
	end

	if class ~= nil then
		self[class] = (self[class] or 0) + 1
	end

	self[ClassFilter.ALL] = (self[ClassFilter.ALL] or 0) + 1
end

function ClassFilter.Pick(p, p2, p3, p4: number)
	local v = {
		{
			Value = ClassFilter.ALL,
			Label = `All classes ({p3[ClassFilter.ALL] or 0})`
		}
	}

	for _, class in StatTypes.Classes do
		local v2 = p3[class] or 0

		if v2 > 0 then
			table.insert(v, {
				Value = class,
				Label = `{class} ({v2})`
			})
		end
	end

	return Dropdown(p, p2, v, {
		Size = UDim2.fromScale(0.22, p4),
		Position = UDim2.fromScale(0.32, -0.015),
		AnchorPoint = Vector2.new(0, 1),
		ZIndex = 20
	})
end

return ClassFilter