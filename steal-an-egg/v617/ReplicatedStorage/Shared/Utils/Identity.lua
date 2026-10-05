local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local v = {}

local function recordOf(p: number)
	local v3 = v[p]

	if v3 == nil then
		v3 = {
			Portraits = {}
		}
		v[p] = v3
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function acceptName(p, username)
	if type(username) == "string" and string.match(username, "^[%w_]+$") ~= nil then
		p.Name = username
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function acceptDisplayName(p, displayName)
	if type(displayName) == "string" and displayName ~= "" then
		p.DisplayName = displayName
	end
end

local function learnNames(p: number)
	local selected = v[p]

	if selected == nil then
		selected = {
			Portraits = {}
		}
		v[p] = selected
	end

	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId == nil then
		local v4 = UserService:GetUserInfosByUserIdsAsync({ p })[1]

		if v4 == nil then
			return selected
		end

		acceptName(selected, v4.Username) -- equivalent call inferred; original call site unknown
		acceptDisplayName(selected, v4.DisplayName) -- equivalent call inferred; original call site unknown
		return selected
	else
		selected.Name = playerByUserId.Name
		selected.DisplayName = playerByUserId.DisplayName
		return selected
	end
end

return table.freeze({
	Name = function(p: number)
		local v3 = v[p]
		local name

		if v3 ~= nil then
			name = v3.Name
		end

		if name == nil then
			name = learnNames(p).Name
		end

		return name or error((`user {p} resolved to an unusable username`))
	end,
	DisplayName = function(p: number)
		local v3 = v[p]
		local displayName

		if v3 ~= nil then
			displayName = v3.DisplayName
		end

		if displayName == nil then
			displayName = learnNames(p).DisplayName
		end

		return displayName or error((`no display name is available for user {p}`))
	end,
	Thumbnail = function(p: number, p2, p3)
		local v3 = v[p]

		if v3 == nil then
			v3 = {
				Portraits = {}
			}
			v[p] = v3
		end

		local portraits = v3.Portraits
		local userThumbnailAsyncs = portraits[p2]
		local selected

		if userThumbnailAsyncs ~= nil then
			selected = userThumbnailAsyncs[p3]
		end

		if selected ~= nil then
			return selected
		end

		local userThumbnailAsync, v5 = Players:GetUserThumbnailAsync(p, p2, p3)

		if type(userThumbnailAsync) ~= "string" or string.match(userThumbnailAsync, "^%a[%w+.-]*:") == nil then
			error((`thumbnail lookup for user {p} returned no content uri`))
		end

		if v5 ~= true then
			return userThumbnailAsync
		end

		if userThumbnailAsyncs == nil then
			userThumbnailAsyncs = {}
			portraits[p2] = userThumbnailAsyncs
		end

		userThumbnailAsyncs[p3] = userThumbnailAsync
		return userThumbnailAsync
	end
})