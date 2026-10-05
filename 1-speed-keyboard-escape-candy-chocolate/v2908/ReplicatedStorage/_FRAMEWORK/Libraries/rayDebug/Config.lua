require(script.Parent.Types)

local function checkConfigCoherent(data)
	if data.lifetime <= 0 then
		return false, "rayDebug: lifetime must stay above 0"
	end

	if data.maxParts <= 0 then
		return false, "rayDebug: maxParts must stay above 0"
	end

	if data.thickness <= 0 then
		return false, "rayDebug: thickness must stay above 0"
	end

	return true, nil
end

local Config = {}

function Config.default()
	return {
		folderName = "_rayDebug",
		thickness = 0.12,
		lifetime = 0.15,
		maxParts = 256,
		hitColor = Color3.fromRGB(255, 86, 86),
		missColor = Color3.fromRGB(96, 224, 128),
		markerSize = 0.35,
		transparency = 0.3
	}
end

function Config.merge(p, items)
	local clone = table.clone(p)

	for k, item in items do
		if item ~= nil then
			clone[k] = item
		end
	end

	local flag, v

	if clone.lifetime <= 0 then
		flag = false
		v = "rayDebug: lifetime must stay above 0"
	elseif clone.maxParts <= 0 then
		flag = false
		v = "rayDebug: maxParts must stay above 0"
	elseif clone.thickness <= 0 then
		flag = false
		v = "rayDebug: thickness must stay above 0"
	else
		flag = true
	end

	if flag then
		return clone
	end

	error(v)
end

return Config