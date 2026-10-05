local ProfileCardConfig = {
	NoneType = "None"
}
local allowed = {
	"Stats",
	"Medals",
	"Toons",
	"Trinkets",
	"Stickers"
}
ProfileCardConfig.Slots = {
	Large = {
		Size = "Large",
		Allowed = { "Thumbnail" }
	},
	SmallA = {
		Size = "Small",
		Allowed = allowed
	},
	SmallB = {
		Size = "Small",
		Allowed = allowed
	}
}
ProfileCardConfig.SlotOrder = { "Large", "SmallA", "SmallB" }
ProfileCardConfig.PositionCount = 3
ProfileCardConfig.DefaultPositions = {
	SmallA = 1,
	SmallB = 2,
	Large = 3
}
ProfileCardConfig.Limits = {
	Large = {
		Thumbnail = 1,
		Stats = 4,
		Medals = 6,
		Toons = 6,
		Twisteds = 6,
		Trinkets = 6,
		Stickers = 6
	},
	Small = {
		Stats = 4,
		Medals = 6,
		Toons = 6,
		Twisteds = 6,
		Trinkets = 6,
		Stickers = 6
	}
}
ProfileCardConfig.FixedSlotTypes = {
	Stats = true
}

function ProfileCardConfig.HasFixedSlots(p: string)
	return ProfileCardConfig.FixedSlotTypes[p] == true
end

ProfileCardConfig.MaxItemsHardCap = 32
ProfileCardConfig.MaxIdLength = 64
ProfileCardConfig.TypeToDescriptorType = {
	Stats = "Stat",
	Medals = "Medal",
	Toons = "Toon",
	Twisteds = "Twisted",
	Trinkets = "Trinket",
	Stickers = "Sticker"
}
ProfileCardConfig.TypeDisplayNames = {
	Thumbnail = "Character Card",
	Stats = "Stats",
	Medals = "Medals",
	Toons = "Toons",
	Twisteds = "Twisteds",
	Trinkets = "Trinkets",
	Stickers = "Stickers"
}
ProfileCardConfig.CompositeTypes = {
	Thumbnail = true
}
local allowed2 = { "Toons", "Twisteds", "Trinkets" }
ProfileCardConfig.FavoriteSlots = {
	Slot1 = {
		Allowed = allowed2,
		Default = "Toons"
	},
	Slot2 = {
		Allowed = allowed2,
		Default = "Twisteds"
	},
	Slot3 = {
		Allowed = allowed2,
		Default = "Trinkets"
	}
}
ProfileCardConfig.FavoriteOrder = { "Slot1", "Slot2", "Slot3" }

function ProfileCardConfig.GetFavoriteSlot(value: string)
	if type(value) == "string" then
		return ProfileCardConfig.FavoriteSlots[value]
	end

	return nil
end

ProfileCardConfig.FavoriteOwnershipRequired = {
	Toons = false,
	Twisteds = true,
	Trinkets = true
}

function ProfileCardConfig.FavoriteRequiresOwnership(p: string)
	return ProfileCardConfig.FavoriteOwnershipRequired[p] ~= false
end

function ProfileCardConfig.IsFavoriteTypeAllowed(p: string, value: string)
	local favoriteSlot = ProfileCardConfig.GetFavoriteSlot(p)

	if favoriteSlot and type(value) == "string" then
		return table.find(favoriteSlot.Allowed, value) ~= nil
	end

	return false
end

ProfileCardConfig.SubjectModes = {
	Image = "Image",
	Model = "Model"
}
ProfileCardConfig.SubjectImageOption = "__image"
ProfileCardConfig.SubjectDefaultSkin = "__default"
ProfileCardConfig.BlockedSubjects = {
	Dyle = true,
	Dandy = true
}

function ProfileCardConfig.IsSubjectAllowed(value)
	return type(value) ~= "string" or value == "" or ProfileCardConfig.BlockedSubjects[value] ~= true
end

function ProfileCardConfig.GetSlot(value: string)
	if type(value) == "string" then
		return ProfileCardConfig.Slots[value]
	end

	return nil
end

function ProfileCardConfig.IsTypeAllowed(p: string, value: string)
	local slot = ProfileCardConfig.GetSlot(p)

	if not slot or type(value) ~= "string" then
		return false
	end

	return value == ProfileCardConfig.NoneType or table.find(slot.Allowed, value) ~= nil
end

function ProfileCardConfig.GetOfferedTypes(p: string)
	local slot = ProfileCardConfig.GetSlot(p)
	return slot and table.clone(slot.Allowed) or {}
end

function ProfileCardConfig.IsComposite(p: string)
	return ProfileCardConfig.CompositeTypes[p] == true
end

function ProfileCardConfig.IsEmptyType(p: string)
	return p == ProfileCardConfig.NoneType
end

function ProfileCardConfig.IsTypeInUse(p, value: string, p2: string?)
	if type(p) ~= "table" or type(value) ~= "string" or ProfileCardConfig.IsEmptyType(value) then
		return false
	end

	for _, v3 in ipairs(ProfileCardConfig.SlotOrder) do
		if v3 == p2 then
			continue
		end

		local v4 = p[v3]

		if type(v4) == "table" and v4.Type == value then
			return true
		end
	end

	return false
end

function ProfileCardConfig.GetTypeDisplayName(p: string)
	return ProfileCardConfig.TypeDisplayNames[p] or tostring(p)
end

function ProfileCardConfig.GetLimit(p: string, value: string)
	local slot = ProfileCardConfig.GetSlot(p)

	if not slot or type(value) ~= "string" then
		return 0
	end

	local limit = ProfileCardConfig.Limits[slot.Size]
	return limit and limit[value] or 0
end

function ProfileCardConfig.CanMove(p, p2: string, p3: number)
	local v3

	if type(p) == "table" then
		v3 = p[p2] or nil
	end

	if type(v3) ~= "table" or type(v3.Position) ~= "number" then
		return false
	end

	local v4 = v3.Position + p3
	return v4 >= 1 and v4 <= ProfileCardConfig.PositionCount
end

function ProfileCardConfig.ValidatePositions(p)
	if type(p) ~= "table" then
		return false, "Sections must be a table"
	end

	local v3 = {}

	for _, v4 in ipairs(ProfileCardConfig.SlotOrder) do
		local v5 = p[v4]

		if type(v5) ~= "table" then
			return false, "Missing section " .. v4
		end

		local position = v5.Position

		if type(position) ~= "number" or position % 1 ~= 0 then
			return false, v4 .. " has no whole-number position"
		end

		if position < 1 or ProfileCardConfig.PositionCount < position then
			return false, v4 .. " position out of range"
		end

		if v3[position] then
			return false, "Two sections share position " .. position
		else
			v3[position] = true
		end
	end

	return true
end

function ProfileCardConfig.GetOrderedSlots(p)
	local clone = table.clone(ProfileCardConfig.SlotOrder)

	if ProfileCardConfig.ValidatePositions(p) then
		table.sort(clone, function(a, b)
			return p[a].Position < p[b].Position
		end)
		return clone
	end

	table.sort(clone, function(a, b)
		return ProfileCardConfig.DefaultPositions[a] < ProfileCardConfig.DefaultPositions[b]
	end)
	return clone
end

return ProfileCardConfig