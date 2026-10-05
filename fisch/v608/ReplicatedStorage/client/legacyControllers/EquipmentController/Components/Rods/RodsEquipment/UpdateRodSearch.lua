local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local EquipmentSearch = require(script.Parent.Parent.Parent:WaitForChild("EquipmentSearch"))
local v = {
	huntfocus = "preferreddisturbance",
	hunt = "preferreddisturbance",
	lure = "lurespeed",
	maxkg = "strength"
}

local function resolveStatKey(p: string)
	return v[p] or p
end

local function rodMatchesQuery(frame, _: string, query)
	local rod = rods[frame.Name]
	local name = frame.Name:lower()

	if table.find({
		"favorited",
		"favourited",
		"favorite",
		"favourite",
		"fav"
	}, query.key) ~= nil then
		return frame.RodOptions.favorite.ImageTransparency == 0.25 and EquipmentSearch.parseBoolean(query.val)
	end

	if table.find({ "mastery" }, query.key) ~= nil then
		return frame.RodOptions.mastery.ImageTransparency == 0.5 and EquipmentSearch.parseBoolean(query.val)
	end

	if table.find({ "enchant", "enchantment" }, query.key) == nil then
		if table.find({ "secondary", "secondaryenchantment", "secondaryenchant" }, query.key) == nil then
			if table.find({ "from" }, query.key) == nil then
				if not query.key and name:find(query.raw, 1, true) then
					return true
				end

				for _, frame2 in frame.Stats:GetChildren() do
					if not (frame2:IsA("Frame") and frame2.Visible and frame2:FindFirstChild("Label")) then
						continue
					end

					local name2 = frame2.Name:lower()
					local text = frame2.Label.Text:lower()
					local v2 = text:gsub(",", "")

					if query.key then
						if name2:find(query.key, 1, true) then
							if query.compare then
								local number = EquipmentSearch.extractNumber(v2)

								if number and query.compare(number) then
									return true
								end
							elseif text:find(query.val, 1, true) or v2:find(query.val, 1, true) then
								return true
							end
						end
					else
						if name2:find(query.raw, 1, true) or text:find(query.raw, 1, true) or v2:find(
							query.raw,
							1,
							true
						) then
							return true
						end

						local raw = query.raw
						local v3 = v[raw] or raw

						if v3 ~= query.raw and name2:find(v3, 1, true) then
							return true
						end
					end
				end

				return false
			elseif rod and rod.From then
				return rod.From:lower():find(query.val, 1, true) ~= nil
			else
				return false
			end
		else
			local v2 = frame.Rod.Enchants.detail.secondary.Text:lower():gsub("[^%a]", "")
			return v2 ~= "" and v2 ~= "x" and v2:find(query.val:gsub("[^%a]", ""), 1, true) ~= nil
		end
	else
		local v2 = frame.Rod.Enchants.enchant.Text:lower():gsub("[^%a]", "")
		return v2 ~= "" and v2 ~= "x" and v2:find(query.val:gsub("[^%a]", ""), 1, true) ~= nil
	end
end

return function(items, p: string)
	local queries = EquipmentSearch.buildQueries(p, resolveStatKey)

	if queries then
		for k, item in items do
			local frame = item.Frame

			if frame then
				local searchVisible = true

				for _, query in queries do
					if rodMatchesQuery(frame, k, query) then
						continue
					end

					searchVisible = false
					break
				end

				item.searchVisible = searchVisible
			else
				item.searchVisible = false
			end
		end
	else
		for _, item in items do
			item.searchVisible = true
		end
	end
end