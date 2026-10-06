local v = {
	Exclusives = {},
	List = {
		Karu = {
			Type = "Ground",
			Icon = "rbxassetid://91878431650737",
			MapName = "Heaven Island",
			MaxSpeed = 50
		},
		Chachamare = {
			Type = "Ground",
			Icon = "rbxassetid://130376041895337",
			MapName = "Slayers Village",
			MaxSpeed = 55,
			HideCharacter = true
		},
		["Cursed Wolf"] = {
			Type = "Ground",
			Icon = "rbxassetid://93651353648372",
			MapName = "Cursed Academy",
			MaxSpeed = 60,
			HideCharacter = true
		}
	}
}

function v.Register(name: string, p)
	if v.List[name] then
		warn((`Repeated Mount: {name}!`))
		return
	end

	p.Name = name

	if not p.Rarity then
		p.Rarity = "Mount"
	end

	v.List[name] = p
end

for k, v2 in v.List do
	v2.Name = k

	if not v2.Rarity then
		v2.Rarity = "Mount"
	end
end

return table.freeze(v)