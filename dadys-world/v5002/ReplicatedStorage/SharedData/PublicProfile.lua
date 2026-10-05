local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileCardConfig = require(ReplicatedStorage.SharedData.ProfileCardConfig)
local ProfileBackgrounds = require(ReplicatedStorage.SharedData.ProfileBackgrounds)
local ProfileBackdrops = require(ReplicatedStorage.SharedData.ProfileBackdrops)
local ProfileBackdropColors = require(ReplicatedStorage.SharedData.ProfileBackdropColors)
local frozen = table.freeze({
	Image = true,
	Model = true
})

local function isUsableId(value)
	return type(value) == "string" and value ~= "" and #value <= ProfileCardConfig.MaxIdLength
end

local function permits(callback, p: string, p2: string, flag: boolean)
	return not callback or callback(p, p2, flag) == true
end

local function projectFavorites(favorites, callback)
	local v = type(favorites) == "table" and favorites or {}
	local result = {}

	for _, v2 in ipairs(ProfileCardConfig.FavoriteOrder) do
		local v3 = type(v[v2]) ~= "table" and {} or v[v2] or {}
		local favoriteSlot = ProfileCardConfig.GetFavoriteSlot(v2)
		local type2 = v3.Type

		if type(type2) ~= "string" or not ProfileCardConfig.IsFavoriteTypeAllowed(v2, type2) then
			type2 = favoriteSlot and favoriteSlot.Default or ""
		end

		local id = ""

		if type2 ~= "" then
			local id2 = v3.Id
			local v4

			if type(id2) == "string" and id2 ~= "" then
				v4 = #id2 <= ProfileCardConfig.MaxIdLength
			else
				v4 = false
			end

			if v4 then
				local id3 = v3.Id
				local favoriteRequiresOwnership = ProfileCardConfig.FavoriteRequiresOwnership(type2)

				if not callback or callback(type2, id3, favoriteRequiresOwnership) == true then
					id = v3.Id
				end
			end
		end

		result[v2] = {
			Type = type2,
			Id = id
		}
	end

	return result
end

local function projectThumbnail(thumbnail, callback)
	local v = type(thumbnail) == "table" and thumbnail or {}
	local subject = ""
	local subject2 = v.Subject
	local v2

	if type(subject2) == "string" and subject2 ~= "" then
		v2 = #subject2 <= ProfileCardConfig.MaxIdLength
	else
		v2 = false
	end

	if v2 and ProfileCardConfig.IsSubjectAllowed(v.Subject) then
		local subject3 = v.Subject

		if not callback or callback("Toons", subject3, true) == true then
			subject = v.Subject
		end
	end

	local subjectSkin = ""

	if subject ~= "" then
		local subjectSkin2 = v.SubjectSkin
		local v3

		if type(subjectSkin2) == "string" and subjectSkin2 ~= "" then
			v3 = #subjectSkin2 <= ProfileCardConfig.MaxIdLength
		else
			v3 = false
		end

		if v3 then
			local subjectSkin3 = v.SubjectSkin

			if not callback or callback("Skins", subjectSkin3, true) == true then
				subjectSkin = v.SubjectSkin
			end
		end
	end

	local defaultKey = ProfileBackgrounds.DefaultKey
	local background = v.Background
	local v3

	if type(background) == "string" and background ~= "" then
		v3 = #background <= ProfileCardConfig.MaxIdLength
	else
		v3 = false
	end

	if v3 then
		local background2 = v.Background

		if not callback or callback("Backgrounds", background2, true) == true then
			defaultKey = v.Background
		end
	end

	local sticker = ""
	local sticker2 = v.Sticker
	local v4

	if type(sticker2) == "string" and sticker2 ~= "" then
		v4 = #sticker2 <= ProfileCardConfig.MaxIdLength
	else
		v4 = false
	end

	if v4 then
		local sticker3 = v.Sticker

		if not callback or callback("Stickers", sticker3, true) == true then
			sticker = v.Sticker
		end
	end

	local frame = ""
	local frame2 = v.Frame
	local v5

	if type(frame2) == "string" and frame2 ~= "" then
		v5 = #frame2 <= ProfileCardConfig.MaxIdLength
	else
		v5 = false
	end

	if v5 then
		local frame3 = v.Frame

		if not callback or callback("Frames", frame3, true) == true then
			frame = v.Frame
		end
	end

	return {
		Background = defaultKey,
		Subject = subject,
		SubjectSkin = subjectSkin,
		SubjectMode = frozen[v.SubjectMode] and v.SubjectMode or "Image",
		Sticker = sticker,
		Frame = frame
	}
end

local function projectSections(sections, callback)
	local v = type(sections) == "table" and sections or {}
	local result = {}

	for position, v2 in ipairs(ProfileCardConfig.SlotOrder) do
		local v3 = type(v[v2]) ~= "table" and {} or v[v2] or {}
		local type2 = v3.Type

		if type(type2) ~= "string" or not ProfileCardConfig.IsTypeAllowed(v2, type2) then
			type2 = ProfileCardConfig.NoneType
		end

		local items = {}

		if not ProfileCardConfig.IsEmptyType(type2) and not ProfileCardConfig.IsComposite(type2) and type(v3.Items) == "table" then
			local v5 = math.min(ProfileCardConfig.GetLimit(v2, type2), ProfileCardConfig.MaxItemsHardCap)
			local v6 = {}

			for _, item in ipairs(v3.Items) do
				if v5 <= #items then
					break
				end

				local v8

				if type(item) == "string" and item ~= "" then
					v8 = #item <= ProfileCardConfig.MaxIdLength
				else
					v8 = false
				end

				if not v8 or v6[item] or not (not callback or callback(type2, item, true) == true) then
					continue
				end

				v6[item] = true
				table.insert(items, item)
			end
		end

		if type(v3.Position) == "number" then
			position = v3.Position or position
		end

		result[v2] = {
			Type = type2,
			Items = items,
			Position = position
		}
	end

	return result
end

return {
	ProjectCard = function(p, callback)
		local v = type(p) == "table" and p or {}
		local defaultKey = ProfileBackdrops.DefaultKey
		local backdropImage = v.BackdropImage
		local v2

		if type(backdropImage) == "string" and backdropImage ~= "" then
			v2 = #backdropImage <= ProfileCardConfig.MaxIdLength
		else
			v2 = false
		end

		if v2 then
			local backdropImage2 = v.BackdropImage

			if not callback or callback("Backdrops", backdropImage2, true) == true then
				defaultKey = v.BackdropImage
			end
		end

		return {
			Version = type(v.Version) ~= "number" and 1 or v.Version or 1,
			Favorites = projectFavorites(v.Favorites, callback),
			Thumbnail = projectThumbnail(v.Thumbnail, callback),
			Sections = projectSections(v.Sections, callback),
			BackdropImage = defaultKey,
			BackdropColor = ProfileBackdropColors.Normalize(v.BackdropColor)
		}
	end
}