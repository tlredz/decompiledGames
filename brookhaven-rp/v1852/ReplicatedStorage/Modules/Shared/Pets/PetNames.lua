local PetNames = {
	DEFAULT_NAMES = {
		"Buddy",
		"Lucky",
		"Shadow",
		"Coco",
		"Pepper",
		"Milo",
		"Bella",
		"Charlie",
		"Daisy",
		"Max",
		"Luna",
		"Rocky",
		"Ollie",
		"Nala",
		"Teddy",
		"Scout",
		"Maple",
		"Ziggy",
		"Pumpkin",
		"Bailey",
		"Cooper",
		"Lucy",
		"Molly",
		"Sophie",
		"Jack",
		"Toby",
		"Rosie",
		"Biscuit",
		"Honey",
		"Cookie",
		"Peanut",
		"Buttercup",
		"Whiskers",
		"Paws",
		"Socks",
		"Bubbles",
		"Jasper",
		"Finn",
		"Hazel",
		"Willow"
	}
}
local v = {}

for _, v2 in PetNames.DEFAULT_NAMES do
	v[v2] = true
end

function PetNames.GetRandom()
	return PetNames.DEFAULT_NAMES[math.random(#PetNames.DEFAULT_NAMES)]
end

function PetNames.IsDefaultName(p: string)
	return v[p] == true
end

return PetNames