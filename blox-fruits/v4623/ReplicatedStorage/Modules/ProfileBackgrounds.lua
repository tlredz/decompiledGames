local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.SerData.PlayerProfile)
local Textures = require(game.ReplicatedStorage.Textures)
local list = {}
local idToNameMap = {}

local function addBackground(p: string, id: number, p2, p3: string?)
	local v3 = idToNameMap[id]

	if v3 then
		error((`BACKGROUND ID CONFLICT, {id} IS ALREADY MAPPED TO {v3}`))
		return
	end

	p2.Id = id
	p2.Image = Textures.profile.banner[`{p3 or p}.png`] or Textures.profile.banner["Default.png"]
	list[p] = p2
	idToNameMap[id] = p
end

local default = {
	SelectCriteria = function()
		return true
	end,
	Type = "ProfileBackground"
}
local v4 = idToNameMap[0]

if v4 then
	error((`BACKGROUND ID CONFLICT, {0} IS ALREADY MAPPED TO {v4}`))
else
	default.Id = 0
	default.Image = Textures.profile.banner["Default.png"] or Textures.profile.banner["Default.png"]
	list.Default = default
	idToNameMap[0] = "Default"
end

local oni = {
	SelectCriteria = function(p: number)
		return p == 912348
	end,
	Type = "ProfileBackground"
}
local v6 = idToNameMap[1]

if v6 then
	error((`BACKGROUND ID CONFLICT, {1} IS ALREADY MAPPED TO {v6}`))
else
	oni.Id = 1
	oni.Image = Textures.profile.banner["Oni.png"] or Textures.profile.banner["Default.png"]
	list.Oni = oni
	idToNameMap[1] = "Oni"
end

local hacker = {
	SelectCriteria = function(p: number)
		return p == 1278154849
	end,
	Type = "ProfileBackground"
}
local v8 = idToNameMap[2]

if v8 then
	error((`BACKGROUND ID CONFLICT, {2} IS ALREADY MAPPED TO {v8}`))
else
	hacker.Id = 2
	hacker.Image = Textures.profile.banner["Hacker.png"] or Textures.profile.banner["Default.png"]
	list.Hacker = hacker
	idToNameMap[2] = "Hacker"
end

local developer = {
	SelectCriteria = function(_, p)
		return p.IsDeveloper == true
	end,
	Type = "ProfileBackground"
}
local v10 = idToNameMap[3]

if v10 then
	error((`BACKGROUND ID CONFLICT, {3} IS ALREADY MAPPED TO {v10}`))
else
	developer.Id = 3
	developer.Image = Textures.profile.banner["Developer.png"] or Textures.profile.banner["Default.png"]
	list.Developer = developer
	idToNameMap[3] = "Developer"
end

local celestial = {
	SelectCriteria = function(p: number)
		return p == 3095250
	end,
	Type = "ProfileBackground"
}
local v12 = idToNameMap[4]

if v12 then
	error((`BACKGROUND ID CONFLICT, {4} IS ALREADY MAPPED TO {v12}`))
else
	celestial.Id = 4
	celestial.Image = Textures.profile.banner["Celestial.png"] or Textures.profile.banner["Default.png"]
	list.Celestial = celestial
	idToNameMap[4] = "Celestial"
end

local fullMoon = {
	Type = "ProfileBackground"
}
local v14 = idToNameMap[5]

if v14 then
	error((`BACKGROUND ID CONFLICT, {5} IS ALREADY MAPPED TO {v14}`))
else
	fullMoon.Id = 5
	fullMoon.Image = Textures.profile.banner["Full Moon.png"] or Textures.profile.banner["Default.png"]
	list["Full Moon"] = fullMoon
	idToNameMap[5] = "Full Moon"
end

local halloweenTapestry = {
	Type = "ProfileBackground"
}
local v16 = idToNameMap[6]

if v16 then
	error((`BACKGROUND ID CONFLICT, {6} IS ALREADY MAPPED TO {v16}`))
else
	halloweenTapestry.Id = 6
	halloweenTapestry.Image = Textures.profile.banner["Halloween Tapestry.png"] or Textures.profile.banner["Default.png"]
	list["Halloween Tapestry"] = halloweenTapestry
	idToNameMap[6] = "Halloween Tapestry"
end

local auroraSky = {
	Type = "ProfileBackground"
}
local v18 = idToNameMap[7]

if v18 then
	error((`BACKGROUND ID CONFLICT, {7} IS ALREADY MAPPED TO {v18}`))
else
	auroraSky.Id = 7
	auroraSky.Image = Textures.profile.banner["Aurora Sky.png"] or Textures.profile.banner["Default.png"]
	list["Aurora Sky"] = auroraSky
	idToNameMap[7] = "Aurora Sky"
end

local controlOverride = {
	Type = "ProfileBackground"
}
local v20 = idToNameMap[8]

if v20 then
	error((`BACKGROUND ID CONFLICT, {8} IS ALREADY MAPPED TO {v20}`))
else
	controlOverride.Id = 8
	controlOverride.Image = Textures.profile.banner["Control Override.png"] or Textures.profile.banner["Default.png"]
	list["Control Override"] = controlOverride
	idToNameMap[8] = "Control Override"
end

local lover = {
	Type = "ProfileBackground"
}
local v22 = idToNameMap[9]

if v22 then
	error((`BACKGROUND ID CONFLICT, {9} IS ALREADY MAPPED TO {v22}`))
else
	lover.Id = 9
	lover.Image = Textures.profile.banner["Lover.png"] or Textures.profile.banner["Default.png"]
	list.Lover = lover
	idToNameMap[9] = "Lover"
end

local heartbreak = {
	Type = "ProfileBackground"
}
local v24 = idToNameMap[10]

if v24 then
	error((`BACKGROUND ID CONFLICT, {10} IS ALREADY MAPPED TO {v24}`))
else
	heartbreak.Id = 10
	heartbreak.Image = Textures.profile.banner["Heartbreak.png"] or Textures.profile.banner["Default.png"]
	list.Heartbreak = heartbreak
	idToNameMap[10] = "Heartbreak"
end

local easterTapestry = {
	Type = "ProfileBackground"
}
local v26 = idToNameMap[11]

if v26 then
	error((`BACKGROUND ID CONFLICT, {11} IS ALREADY MAPPED TO {v26}`))
else
	easterTapestry.Id = 11
	easterTapestry.Image = Textures.profile.banner["Easter Tapestry.png"] or Textures.profile.banner["Default.png"]
	list["Easter Tapestry"] = easterTapestry
	idToNameMap[11] = "Easter Tapestry"
end

local dogeProfileFullArt = {
	ItemConfigNameOverride = "Doge",
	Type = "ProfileFullArt"
}
local v28 = idToNameMap[12]

if v28 then
	error((`BACKGROUND ID CONFLICT, {12} IS ALREADY MAPPED TO {v28}`))
else
	dogeProfileFullArt.Id = 12
	dogeProfileFullArt.Image = Textures.profile.banner["Doge Profile Full Art.png"] or Textures.profile.banner["Default.png"]
	list["Doge Profile Full Art"] = dogeProfileFullArt
	idToNameMap[12] = "Doge Profile Full Art"
end

local doge = {
	Type = "ProfileBackground"
}
local v30 = idToNameMap[13]

if v30 then
	error((`BACKGROUND ID CONFLICT, {13} IS ALREADY MAPPED TO {v30}`))
else
	doge.Id = 13
	doge.Image = Textures.profile.banner["Doge Profile Background.png"] or Textures.profile.banner["Default.png"]
	list.Doge = doge
	idToNameMap[13] = "Doge"
end

local beach = {
	Type = "ProfileBackground"
}
local v32 = idToNameMap[14]

if v32 then
	error((`BACKGROUND ID CONFLICT, {14} IS ALREADY MAPPED TO {v32}`))
else
	beach.Id = 14
	beach.Image = Textures.profile.banner["Beach Profile Background.png"] or Textures.profile.banner["Default.png"]
	list.Beach = beach
	idToNameMap[14] = "Beach"
end

local vaporwave = {
	Type = "ProfileBackground"
}
local v34 = idToNameMap[15]

if v34 then
	error((`BACKGROUND ID CONFLICT, {15} IS ALREADY MAPPED TO {v34}`))
else
	vaporwave.Id = 15
	vaporwave.Image = Textures.profile.banner["Vaporwave.png"] or Textures.profile.banner["Default.png"]
	list.Vaporwave = vaporwave
	idToNameMap[15] = "Vaporwave"
end

local vaporwaveProfileFullArt = {
	ItemConfigNameOverride = "Vaporwave",
	Type = "ProfileFullArt"
}
local v36 = idToNameMap[16]

if v36 then
	error((`BACKGROUND ID CONFLICT, {16} IS ALREADY MAPPED TO {v36}`))
else
	vaporwaveProfileFullArt.Id = 16
	vaporwaveProfileFullArt.Image = Textures.profile.banner["Vaporwave Profile Full Art.png"] or Textures.profile.banner["Default.png"]
	list["Vaporwave Profile Full Art"] = vaporwaveProfileFullArt
	idToNameMap[16] = "Vaporwave Profile Full Art"
end

return {
	List = list,
	IdToNameMap = idToNameMap
}