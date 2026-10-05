local Localtest = {
	otherPlayer = {
		Name = "1x1x1x1",
		UserId = 8166491
	}
}
local name = game.Players.LocalPlayer.Name
Localtest.state = {
	[name] = {}
}
Localtest.key_sep = "\254\254"

function Localtest.add(p: string, p2: string, p3)
	local formatted = `{p}{Localtest.key_sep}{p2}`
	Localtest.state[name][formatted] = {
		type = p,
		data = p3
	}
end

function Localtest.remove(p, p2: string)
	local formatted = `{p}{Localtest.key_sep}{p2}`
	Localtest.state[name][formatted] = nil
end

return Localtest