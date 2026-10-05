local shared = script.Parent.Parent.Parent.Shared
local React = require(shared.React)
local Emotes = require(shared.Emotes)
local Promise = require(shared.Promise)
local AssetService = game:GetService("AssetService")
local parent = script.Parent
local useTagged = require(parent.useTagged)
local useProductInfo = require(parent.useProductInfo)
local v = {}
local v2 = {}

local function getCachedPromise(p: number)
	return v[p]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCachedPromise(p: number, p2)
	if v[p] then
		return
	end

	local v3 = #v2 >= 500 and table.remove(v2, 1)

	if v3 then
		v[v3] = nil
	end

	v[p] = p2
	table.insert(v2, p)
end

local promisify = Promise.promisify(function(p)
	return AssetService:GetAudioMetadataAsync(p)[1]
end)

local function useSong(p: number?)
	local v3 = useTagged("RelicsSong")

	if not p then
		return nil
	end

	for _, v5 in ipairs(v3) do
		local id = v5:GetAttribute("Id")
		local artist = v5:GetAttribute("Artist")

		if p and type(id) == "string" and type(artist) == "string" and tonumber(id:match("%d+$")) == p then
			return v5
		end
	end

	return nil
end

local function useMetadata(value)
	local v3

	if type(value) == "string" then
		v3 = tonumber(value:match("%d+$"))
	else
		v3 = value and value // 1 or nil
	end

	local v4 = useSong(v3)
	local v5 = useProductInfo(v3)
	local state, setState = React.useState(function()
		local v6 = v3 and v[v3]

		if v6 then
			if v6:getStatus() == "Resolved" then
				return v6:expect()
			end
		elseif v3 then
			setCachedPromise(v3, Promise.retry(promisify, 5, { v3 })) -- equivalent call inferred; original call site unknown
		end

		return nil
	end)

	if v3 and state and state.AssetId ~= tostring(v3) then
		setState(nil)
	end

	if v3 and not v[v3] then
		setCachedPromise(v3, Promise.retry(promisify, 5, { v3 })) -- equivalent call inferred; original call site unknown
	end

	React.useEffect(function()
		local v6

		if v3 and not state then
			local v7 = v[v3]

			if not v7 then
				v7 = Promise.retry(promisify, 5, { v3 })
				setCachedPromise(v3, v7) -- equivalent call inferred; original call site unknown
			end

			v6 = v7:andThen(setState)
		else
			v6 = nil
		end

		return function()
			if v6 then
				v6:cancel()
			end
		end
	end, { v3, state })
	local title = state and state.Title
	local artist = state and state.Artist
	local name = v5 and v5.Name
	local name2 = v5 and v5.Creator.Name
	local name3 = v4 and v4.Name
	local artist2 = v4 and v4:GetAttribute("Artist")
	local emote = Emotes.GetEmoteBySongId(v3)

	if emote then
		return {
			Title = not emote and "Emote" or emote.Name,
			Artist = ""
		}
	end

	if name3 and type(artist2) == "string" then
		return {
			Title = name3,
			Artist = artist2
		}
	end

	if title and artist then
		if title == "00000000" and artist == "Roblox" then
			return {
				Title = "[ Content Encrypted ]",
				Artist = "Unknown Artist"
			}
		end

		if name ~= title or name2 ~= artist then
			return {
				Title = title,
				Artist = artist
			}
		end

		if name:find(" - ") then
			local parts = name:split(" - ")

			if #parts == 2 and not artist:lower():find("remix") then
				return {
					Title = parts[2],
					Artist = parts[1]
				}
			end
		end

		return {
			Title = title,
			Artist = `Uploaded by: @{artist}`
		}
	elseif name and name2 then
		if name == "00000000" and name2 == "Roblox" then
			return {
				Title = "[ Content Encrypted ]",
				Artist = "Unknown Artist"
			}
		end

		return {
			Title = name,
			Artist = `Uploaded by: @{name2}`
		}
	else
		return {
			Title = "Unknown Song",
			Artist = "Unknown Artist"
		}
	end
end

return useMetadata