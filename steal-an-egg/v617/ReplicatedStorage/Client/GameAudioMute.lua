local SoundService = game:GetService("SoundService")
local v2 = 0
local v3 = {}
local v4 = {}
local groups = {}
local folder = nil
local descendantAddedConnection = nil
local descendantRemovingConnection = nil
local v5 = {}

local function track(sound)
	if not sound:IsA("Sound") or v3[sound] then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function originalGroup(soundGroup)
		local v6 = groups[soundGroup]

		if v6 == v5 then
			return nil
		end

		return v6 or soundGroup
	end

	local v6 = {
		group = 0
	}
	local group2 = originalGroup(sound.SoundGroup) -- equivalent call inferred; original call site unknown
	v6.group = group2
	v3[sound] = v6

	-- equivalent calls inferred from this helper; original call sites unknown
	local function route()
		local group = v6.group or v5
		local soundGroup = v4[group]

		if not soundGroup then
			soundGroup = Instance.new("SoundGroup")
			soundGroup.Name = "Muted"
			soundGroup.Volume = 0
			groups[soundGroup] = group
			v4[group] = soundGroup
			soundGroup.Parent = folder
		end

		sound.SoundGroup = soundGroup
	end

	v6.changed = sound:GetPropertyChangedSignal("SoundGroup"):Connect(function()
		if groups[sound.SoundGroup] then
			return
		end

		v6.group = sound.SoundGroup
		route() -- equivalent call inferred; original call site unknown
	end)
	route() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function untrack(p)
	local v6 = v3[p]

	if not v6 then
		return
	end

	v3[p] = nil
	v6.changed:Disconnect()

	if groups[p.SoundGroup] then
		p.SoundGroup = v6.group
	end
end

local v = {
	Acquire = function()
		v2 += 1

		if v2 == 1 then
			folder = Instance.new("Folder")
			folder.Name = "FullscreenAudioMute"
			folder.Parent = SoundService
			descendantAddedConnection = game.DescendantAdded:Connect(track)
			descendantRemovingConnection = game.DescendantRemoving:Connect(function(descendant)
				if v3[descendant] then
					untrack(descendant) -- equivalent call inferred; original call site unknown
				end
			end)

			for _, descendant in game:GetDescendants() do
				track(descendant)
			end
		end

		local flag = false
		return function()
			if flag then
				return
			end

			flag = true
			v2 -= 1

			if v2 > 0 then
				return
			end

			descendantAddedConnection:Disconnect()
			descendantRemovingConnection:Disconnect()

			for k in v3 do
				untrack(k) -- equivalent call inferred; original call site unknown
			end

			folder:Destroy()
			folder = nil
			table.clear(v4)
			table.clear(groups)
		end
	end
}
return table.freeze(v)