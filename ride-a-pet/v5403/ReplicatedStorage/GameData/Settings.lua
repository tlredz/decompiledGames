local Settings = {
	Definitions = {
		MusicVolume = {
			Kind = "Number",
			Default = 0.5,
			Minimum = 0,
			Maximum = 1
		},
		SFXVolume = {
			Kind = "Number",
			Default = 0.5,
			Minimum = 0,
			Maximum = 1
		},
		ViewOtherPets = {
			Kind = "Boolean",
			Default = true
		},
		ViewYourPets = {
			Kind = "Boolean",
			Default = true
		}
	}
}

function Settings.Defaults()
	local defaults = {}

	for k, definition in Settings.Definitions do
		defaults[k] = definition.Default
	end

	return defaults
end

function Settings.Sanitise(p, p2)
	local definition = Settings.Definitions[p]

	if not definition then
		return nil
	end

	if definition.Kind == "Boolean" then
		if type(p2) == "boolean" then
			return p2
		end

		return nil
	else
		local v = tonumber(p2)

		if v and v == v then
			return (math.clamp(v, definition.Minimum, definition.Maximum))
		end

		return nil
	end
end

function Settings.Resolve(p)
	local result = Settings.Defaults()

	if type(p) ~= "table" then
		return result
	end

	for k in Settings.Definitions do
		local sanitise = Settings.Sanitise(k, p[k])

		if sanitise ~= nil then
			result[k] = sanitise
		end
	end

	return result
end

return Settings