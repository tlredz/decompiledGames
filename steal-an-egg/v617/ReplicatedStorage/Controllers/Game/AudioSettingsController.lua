local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Preferences = require(ReplicatedStorage.Shared.Preferences)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {
	Music = { "Music" },
	SFX = { "Gameplay", "GameplayReverb" }
}
local v2 = {
	Music = 1,
	SFX = 1
}
local v3 = {}
local v4 = {
	Changed = Signal.new(),
	Get = function(p: string)
		return v2[p]
	end
}

function v4.Set(p: string, value: number)
	assert(v2[p] ~= nil, (`no volume category called {p}`))
	local v5 = math.clamp(value, 0, 1)

	if v2[p] == v5 then
		return
	end

	v2[p] = v5
	v4.Changed:Fire(p, v5)
end

function v4.Start()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function gainFor(setting: string)
		if Preferences.IsOn(setting) then
			return (v4.Get(setting))
		end

		return 0
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function apply(data)
		local v5 = gainFor(data.Setting) -- equivalent call inferred; original call site unknown

		for k, group in data.Groups do
			group.Volume = data.Authored[k] * v5
		end
	end

	local function onTouched(p: string)
		local v5 = v3[p]

		if v5 ~= nil then
			apply(v5) -- equivalent call inferred; original call site unknown
		end
	end

	for k, v5 in v do
		local children = {}
		local volumes = {}

		for _, childName in v5 do
			local child = SoundService:WaitForChild(childName)
			table.insert(children, child)
			table.insert(volumes, child.Volume)
		end

		v3[k] = {
			Setting = k,
			Groups = children,
			Authored = volumes
		}
	end

	v4.Changed:Connect(onTouched)

	for _, v5 in v3 do
		local v6 = v5
		Preferences.Observe(v5.Setting, function()
			apply(v6) -- equivalent call inferred; original call site unknown
		end)
	end
end

return table.freeze(v4)