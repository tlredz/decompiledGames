game:GetService("ReplicatedStorage")
local Jolly = {
	["Krampus Pitchfork"] = {
		Display = "Krampus Pitchfork",
		Price = 1000,
		Icon = "rbxassetid://15580241090",
		Type = "Inventory"
	},
	["Snowball Launcher"] = {
		Display = "Snowball Launcher",
		Price = 550,
		Icon = "rbxassetid://133697212998506",
		Type = "Inventory"
	},
	["New Years Bat"] = {
		Display = "New Years Bat",
		Price = 125,
		NewYears = true,
		Icon = "rbxassetid://91278692670986",
		Type = "Skins"
	},
	["Resolution Lasso"] = {
		Display = "Resolution Lasso",
		Price = 100,
		NewYears = true,
		Icon = "rbxassetid://129034444193651",
		Type = "Skins"
	},
	["New Years Jetpack"] = {
		Display = "New Years Jetpack",
		Price = 175,
		NewYears = true,
		Icon = "rbxassetid://85250095395754",
		Type = "Skins"
	},
	["Disco Ball"] = {
		Display = "Disco Ball",
		Price = 75,
		NewYears = true,
		Icon = "rbxassetid://132785786636109",
		Type = "Skins"
	},
	["Cookie King"] = {
		Display = "Cookie King",
		Price = 150,
		Type = "Titles"
	},
	["Cookie Taser"] = {
		Display = "Cookie Taser",
		Price = 100,
		Icon = "rbxassetid://79386097612891",
		Type = "Skins"
	},
	["Jolly Baker"] = {
		Display = "Jolly Baker",
		Price = 50,
		Type = "Titles"
	},
	["Sugar Dust"] = {
		Display = "Sugar Dust",
		Price = 100,
		Type = "Titles"
	},
	["Xmas Lights"] = {
		Display = "Xmas Lights",
		Price = 50,
		Icon = "rbxassetid://100526736634374",
		Type = "Decoration"
	},
	["New Years Decor"] = {
		Display = "New Years",
		Price = 50,
		NewYears = true,
		Icon = "rbxassetid://137390753584675",
		Type = "Decoration"
	},
	["2026"] = {
		Display = "2026",
		Price = 50,
		NewYears = true,
		Icon = "rbxassetid://139970795589629",
		Type = "Decoration"
	},
	Cookie = {
		Display = "Cookie",
		Price = 50,
		Icon = "rbxassetid://100892277526443",
		Type = "Decoration"
	},
	["Stocking Gloves"] = {
		Display = "Stocking Gloves",
		Price = 125,
		Icon = "rbxassetid://118154986014846",
		Type = "Skins"
	},
	["Cookie Gloves"] = {
		Display = "Cookie Gloves",
		Price = 125,
		Icon = "rbxassetid://116345308125853",
		Type = "Skins"
	},
	Breadstick = {
		Display = "Breadstick",
		Price = 200,
		Icon = "rbxassetid://107130836427200",
		Type = "Skins"
	},
	["Naughty List"] = {
		Display = "Naughty List",
		Price = 200,
		Icon = "rbxassetid://122872334103196",
		Type = "Skins"
	},
	["Cookie Ball"] = {
		Display = "Cookie Ball",
		Price = 75,
		Icon = "rbxassetid://101302442278770",
		Type = "Skins"
	},
	Giftbag = {
		Display = "Giftbag",
		Price = 75,
		Icon = "rbxassetid://128308390635645",
		Type = "Skins"
	},
	Stocklash = {
		Display = "Stocklash",
		Price = 225,
		Icon = "rbxassetid://82581699429755",
		Type = "Skins"
	},
	["Chimney Jetpack"] = {
		Display = "Chimney Jetpack",
		Price = 275,
		Icon = "rbxassetid://137533848818329",
		Type = "Skins"
	},
	["Cookie Wings"] = {
		Display = "Cookie Wings",
		Price = 325,
		Icon = "rbxassetid://127460716800007",
		Type = "Skins"
	}
}

for k, v in Jolly do
	v.Name = k
end

return Jolly