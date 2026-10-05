local GetColorPropertiesFor = require(game.ReplicatedStorage.Util.GetColorPropertiesFor)

local function restoreProperties(instance, items)
	for _, item in items do
		local v = instance[item]
		local v2 = "DefaultColor_" .. item
		local attribute = instance:GetAttribute(v2)

		if attribute == nil or typeof(attribute) ~= typeof(v) then
			if typeof(v) == "ColorSequence" then
				local attribute2 = instance:GetAttribute(v2 .. "_Sequence")

				if typeof(attribute2) == "ColorSequence" then
					instance[item] = attribute2
				else
					local v3 = {}
					local flag = false

					for _, keypoint in v.Keypoints do
						local attribute3 = instance:GetAttribute(v2 .. "_" .. tostring(math.floor((keypoint.Time + 0.005) / 0.01) * 0.01):gsub(
							"%.",
							"_"
						))

						if typeof(attribute3) == "Color3" then
							table.insert(v3, ColorSequenceKeypoint.new(keypoint.Time, attribute3))
							flag = true
						else
							table.insert(v3, keypoint)
						end
					end

					if flag then
						instance[item] = ColorSequence.new(v3)
					end
				end
			end
		else
			instance[item] = attribute
		end
	end
end

local function restoreDefaultColorProperties(folder, items)
	if items then
		for _, item in items do
			if item.obj == folder or item.obj.Parent ~= nil then
				restoreProperties(item.obj, item.props)
			end
		end
	else
		for _, descendant in folder:GetDescendants() do
			restoreProperties(descendant, GetColorPropertiesFor(descendant))
		end

		restoreProperties(folder, GetColorPropertiesFor(folder))
	end
end

return restoreDefaultColorProperties