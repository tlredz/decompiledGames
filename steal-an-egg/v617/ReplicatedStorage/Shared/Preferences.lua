local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local catalogue = {
	{
		Section = "Audio",
		Items = {
			{
				Key = "Music",
				Default = true,
				Title = "Music",
				Summary = "Play background music."
			},
			{
				Key = "SFX",
				Default = true,
				Title = "Sound Effects",
				Summary = "Play sound effects."
			}
		}
	},
	{
		Section = "Gameplay",
		Items = {
			{
				Key = "HideOtherPets",
				Default = false,
				Title = "Hide Other Pets",
				Summary = "Hide the pets of other players."
			},
			{
				Key = "HideSelfPets",
				Default = false,
				Title = "Hide Your Pets",
				Summary = "Hide your own pets on your plot."
			},
			{
				Key = "DisableVideos",
				Default = false,
				Title = "Disable Videos",
				Summary = "Turn off the treadmill video."
			},
			{
				Key = "AFK",
				Default = false,
				Title = "AFK Mode",
				Summary = "Stay in the lobby and skip Murder Mystery rounds."
			}
		}
	},
	{
		Section = "Interface",
		Items = {
			{
				Key = "VirtualCursor",
				Default = false,
				Title = "Menu Navigation",
				Summary = "Use a cursor instead of button navigation in menus."
			},
			{
				Key = "CreatorPanel",
				Default = true,
				Title = "Creator Panel",
				Summary = "Open the creator panel with F3. Shown to accounts with creator access."
			}
		}
	},
	{
		Section = "Internal",
		Items = {
			{
				Key = "SeenNavigationHint",
				Default = false,
				Title = "Navigation Hint Seen"
			}
		}
	}
}
local lists = {}
local defaults = {}
local v2 = {}
local v3 = {
	Catalogue = catalogue
}

for _, list in catalogue do
	for _, list2 in list.Items do
		lists[list2.Key] = list2
		defaults[list2.Key] = list2.Default
		v2[list2.Key] = {}
		table.freeze(list2)
	end

	table.freeze(list.Items)
	table.freeze(list)
end

table.freeze(catalogue)

local function itemFor(p: string)
	local v4 = lists[p]

	if v4 == nil then
		error(`"{tostring(p)}" is not a preference`, 3)
	end

	return v4
end

local function asFlag(p, p2)
	if typeof(p2) == "boolean" then
		return p2
	end

	return p.Default
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(p: string)
	local v4 = defaults[p]

	for _, v5 in table.clone(v2[p]) do
		v5.Notify(v4)
	end
end

local function put(p: string, default)
	local v4 = lists[p]

	if typeof(default) ~= "boolean" then
		default = v4.Default
	end

	if defaults[p] == default then
		return false
	end

	defaults[p] = default
	return true
end

local function absorb(p)
	local v4 = typeof(p) ~= "table" and {} or p
	local v5 = {}

	for k in lists do
		local default = v4[k]
		local v6 = lists[k]

		if typeof(default) ~= "boolean" then
			default = v6.Default
		end

		local flag

		if defaults[k] == default then
			flag = false
		else
			defaults[k] = default
			flag = true
		end

		if flag then
			table.insert(v5, k)
		end
	end

	for _, v6 in v5 do
		notify(v6) -- equivalent call inferred; original call site unknown
	end
end

function v3.IsOn(p: string)
	if lists[p] == nil then
		error(`"{tostring(p)}" is not a preference`, 3)
	end

	return defaults[p]
end

function v3.Set(p: string, default: boolean)
	if lists[p] == nil then
		error(`"{tostring(p)}" is not a preference`, 3)
	end

	if typeof(default) ~= "boolean" then
		error(`preference values are booleans, got {typeof(default)}`, 2)
	end

	local success, result, v4 = pcall(function()
		return Remotes.Preferences.AskWrite:InvokeServer(p, default)
	end)

	if not success then
		warn((`preference write for {p} raised: {tostring(result)}`))
		return false
	end

	if result ~= true then
		return false
	end

	if typeof(v4) == "table" then
		absorb(v4)
	else
		local v5 = lists[p]

		if typeof(default) ~= "boolean" then
			default = v5.Default
		end

		local flag

		if defaults[p] == default then
			flag = false
		else
			defaults[p] = default
			flag = true
		end

		if flag then
			notify(p) -- equivalent call inferred; original call site unknown
		end
	end

	return true
end

function v3.Toggle(p: string)
	return v3.Set(p, not v3.IsOn(p))
end

function v3.Observe(p: string, notify2)
	if lists[p] == nil then
		error(`"{tostring(p)}" is not a preference`, 3)
	end

	local v4 = v2[p]
	local v5 = {
		Notify = notify2
	}
	table.insert(v4, v5)
	notify2(defaults[p])
	return function()
		local index = table.find(v4, v5)

		if index ~= nil then
			table.remove(v4, index)
		end
	end
end

Remotes.Preferences.PreferenceShifted.OnClientEvent:Connect(function(value, default)
	if typeof(value) == "string" and lists[value] ~= nil then
		local v4 = lists[value]

		if typeof(default) ~= "boolean" then
			default = v4.Default
		end

		local flag

		if defaults[value] == default then
			flag = false
		else
			defaults[value] = default
			flag = true
		end

		if flag then
			notify(value) -- equivalent call inferred; original call site unknown
		end
	end
end)
Save.Watch("Settings"):Connect(absorb)
task.spawn(function()
	local v4 = Save.Await()

	if v4 ~= nil then
		absorb(v4.Settings)
	end
end)
return table.freeze(v3)