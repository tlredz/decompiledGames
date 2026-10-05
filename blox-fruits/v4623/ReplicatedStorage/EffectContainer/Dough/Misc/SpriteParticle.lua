local Util = require(game.ReplicatedStorage.Util)
local misc = Util.Misc
local v = {
	AnimatedSlash = {
		"rbxassetid://7904955547",
		"rbxassetid://7904957119",
		"rbxassetid://7904960317",
		"rbxassetid://7904961838",
		"rbxassetid://7904963416",
		"rbxassetid://7904965317",
		"rbxassetid://7904967714",
		"rbxassetid://7904969412",
		"rbxassetid://7904971049",
		"rbxassetid://7904972833",
		"rbxassetid://7904975548",
		"rbxassetid://7904977120",
		"rbxassetid://7904978532",
		"rbxassetid://7904980208",
		"rbxassetid://7904982132",
		"rbxassetid://7904984424",
		""
	},
	AnimatedShockwave = {
		"rbxassetid://8033167966",
		"rbxassetid://8033200808",
		"rbxassetid://8033203083",
		"rbxassetid://8033207617",
		"rbxassetid://8033210431",
		"rbxassetid://8033213019",
		"rbxassetid://8033217331",
		"rbxassetid://8033220213",
		"rbxassetid://8033223285",
		"rbxassetid://8033226859",
		"rbxassetid://8033230343",
		"rbxassetid://8033233191",
		"rbxassetid://8033236283",
		"rbxassetid://8033245692",
		"rbxassetid://8033248989",
		"rbxassetid://8033251643",
		"rbxassetid://8033255963",
		"rbxassetid://8033259254",
		"rbxassetid://8033262747",
		"rbxassetid://8033265643",
		"rbxassetid://8033269272",
		""
	},
	AnimatedShockwave2 = {
		"rbxassetid://7876464710",
		"rbxassetid://7876468802",
		"rbxassetid://7876470409",
		"rbxassetid://7876472824",
		"rbxassetid://7876481828",
		"rbxassetid://7876483169",
		"rbxassetid://7876487263",
		"rbxassetid://7876490968",
		"rbxassetid://7876494199",
		"rbxassetid://7876498951",
		"rbxassetid://7876503301",
		"rbxassetid://7876505503",
		"rbxassetid://7876507501",
		"rbxassetid://7876510474",
		"rbxassetid://7876514292",
		"rbxassetid://7876516195",
		"rbxassetid://7876519342",
		"rbxassetid://7876522789",
		"rbxassetid://7876524908",
		"rbxassetid://7876528216",
		"rbxassetid://7876530766",
		"rbxassetid://7876534680",
		"rbxassetid://7876538930",
		"rbxassetid://7876541063",
		"rbxassetid://7876546492",
		"rbxassetid://7876553444",
		"rbxassetid://7876555344",
		"rbxassetid://7876559376",
		"rbxassetid://7876562206",
		"rbxassetid://7876565970",
		"rbxassetid://7876568589",
		""
	},
	Lightning = {
		"rbxassetid://8189652665",
		"",
		"rbxassetid://8189653993",
		"rbxassetid://8189655563",
		"",
		"rbxassetid://8189656720",
		"rbxassetid://8189657822",
		"rbxassetid://8189659765",
		"rbxassetid://8189661518",
		""
	},
	Lightning2 = {
		"rbxassetid://8189970113",
		"",
		"rbxassetid://8189983044",
		"rbxassetid://8189984421",
		"rbxassetid://8189985650",
		"rbxassetid://8189986587",
		"rbxassetid://8189989098",
		"rbxassetid://8189990246",
		""
	}
}
return function(data)
	local v2 = data.Sprite and v[data.Sprite] or v[data.Particle.Name] or {}
	local duration = data.Duration or 1
	local lifetime = data.Lifetime

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		if #v2 > 0 and duration > 0 then
			misc.LoadTexture(data.Particle, v2, duration / #v2)
		end
	end

	if lifetime then
		local v3 = 0
		Util.DistributedLoop:add(function(p, _)
			local now = tick()

			if duration < now - v3 then
				task.spawn(fn)
				v3 = now
			end

			if lifetime < p then
				return true
			end
		end)
	else
		fn() -- equivalent call inferred; original call site unknown
	end
end