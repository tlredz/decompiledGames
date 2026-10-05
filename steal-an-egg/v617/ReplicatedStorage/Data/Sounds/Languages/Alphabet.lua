-- equivalent calls inferred from this helper; original call sites unknown
local function buildSound(soundId: string)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 1.3
	sound.Parent = script
	return sound
end

local frozen = table.freeze({
	a = {
		Sound = buildSound("rbxassetid://131409529367871"),
		Modifiers = {}
	},
	z = {
		Sound = buildSound("rbxassetid://131409529367871"),
		Modifiers = {}
	},
	e = {
		Sound = buildSound("rbxassetid://86304009158692"),
		Modifiers = {}
	},
	r = {
		Sound = buildSound("rbxassetid://109826642525119"),
		Modifiers = {}
	},
	u = {
		Sound = buildSound("rbxassetid://124287498697887"),
		Modifiers = {}
	},
	t = {
		Sound = buildSound("rbxassetid://92263969947825"),
		Modifiers = {}
	},
	y = {
		Sound = buildSound("rbxassetid://132445985810760"),
		Modifiers = {}
	},
	i = {
		Sound = buildSound("rbxassetid://125216371424793"),
		Modifiers = {}
	},
	g = {
		Sound = buildSound(""),
		Modifiers = {}
	},
	o = {
		Sound = buildSound("rbxassetid://77857299324635"),
		Modifiers = {}
	},
	j = {
		Sound = buildSound("rbxassetid://107060200636030"),
		Modifiers = {}
	},
	p = {
		Sound = buildSound("rbxassetid://92082924357386"),
		Modifiers = {}
	},
	h = {
		Sound = buildSound("rbxassetid://72592612249456"),
		Modifiers = {}
	},
	f = {
		Sound = buildSound("rbxassetid://91139623147952"),
		Modifiers = {}
	},
	s = {
		Sound = buildSound("rbxassetid://132760805757526"),
		Modifiers = {}
	},
	d = {
		Sound = buildSound("rbxassetid://95979804353066"),
		Modifiers = {}
	},
	l = {
		Sound = buildSound("rbxassetid://126906012434922"),
		Modifiers = {}
	},
	m = {
		Sound = buildSound("rbxassetid://130061800174383"),
		Modifiers = {}
	},
	w = {
		Sound = buildSound("rbxassetid://78460231249208"),
		Modifiers = {}
	},
	x = {
		Sound = buildSound("rbxassetid://104197881050019"),
		Modifiers = {}
	},
	k = {
		Sound = buildSound("rbxassetid://99934858533464"),
		Modifiers = {}
	},
	c = {
		Sound = buildSound("rbxassetid://80568126993314"),
		Modifiers = {}
	},
	v = {
		Sound = buildSound("rbxassetid://108719311859555"),
		Modifiers = {}
	},
	b = {
		Sound = buildSound("rbxassetid://109557008188628"),
		Modifiers = {}
	},
	n = {
		Sound = buildSound("rbxassetid://75583689302851"),
		Modifiers = {}
	},
	q = {
		Sound = buildSound("rbxassetid://133664824158668"),
		Modifiers = {}
	}
})
return table.freeze({
	Normal = frozen
})