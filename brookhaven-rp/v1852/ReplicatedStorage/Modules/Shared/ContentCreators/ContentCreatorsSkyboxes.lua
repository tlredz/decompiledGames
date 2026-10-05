local v = {
	None = {
		clear = true
	},
	RainSky = {
		SkyboxBk = "http://www.roblox.com/asset/?id=5261319252",
		SkyboxDn = "http://www.roblox.com/asset/?id=5261319252",
		SkyboxFt = "http://www.roblox.com/asset/?id=5261319252",
		SkyboxLf = "http://www.roblox.com/asset/?id=5261319252",
		SkyboxRt = "http://www.roblox.com/asset/?id=5261319252",
		SkyboxUp = "http://www.roblox.com/asset/?id=5261319252"
	},
	SkyClouds = {
		SkyboxBk = "http://www.roblox.com/asset/?id=225469390",
		SkyboxDn = "http://www.roblox.com/asset/?id=225469395",
		SkyboxFt = "http://www.roblox.com/asset/?id=225469403",
		SkyboxLf = "http://www.roblox.com/asset/?id=225469450",
		SkyboxRt = "http://www.roblox.com/asset/?id=225469471",
		SkyboxUp = "http://www.roblox.com/asset/?id=225469481"
	},
	SkyGreen = {
		SkyboxBk = "http://www.roblox.com/asset/?id=429229775",
		SkyboxDn = "http://www.roblox.com/asset/?id=429230074",
		SkyboxFt = "http://www.roblox.com/asset/?id=429229963",
		SkyboxLf = "http://www.roblox.com/asset/?id=429230201",
		SkyboxRt = "http://www.roblox.com/asset/?id=429230276",
		SkyboxUp = "http://www.roblox.com/asset/?id=429230145"
	},
	SkyOrange = {
		SkyboxBk = "rbxassetid://458016711",
		SkyboxDn = "rbxassetid://458016826",
		SkyboxFt = "rbxassetid://458016532",
		SkyboxLf = "rbxassetid://458016655",
		SkyboxRt = "rbxassetid://458016782",
		SkyboxUp = "rbxassetid://458016792"
	}
}
local ContentCreatorsSkyboxes = {}

function ContentCreatorsSkyboxes.GetNames()
	local result = {}

	for k in pairs(v) do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

function ContentCreatorsSkyboxes.GetEntry(p: string)
	return v[p]
end

function ContentCreatorsSkyboxes.IsClearEntry(p)
	return p.clear == true
end

return ContentCreatorsSkyboxes