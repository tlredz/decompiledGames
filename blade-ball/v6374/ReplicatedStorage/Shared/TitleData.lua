local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.RankedSeasonData)
local v2 = {
	{
		Name = "PHONK",
		Priority = 1,
		Tag = {
			Text = "PHONK",
			Color = Color3.fromRGB(255, 255, 255)
		}
	},
	{
		Name = "Clutch",
		Priority = 1,
		Tag = {
			Text = "Clutch",
			Color = Color3.fromRGB(255, 255, 255)
		}
	},
	{
		Name = "P2W",
		Priority = 1,
		Tag = {
			Text = "P2W",
			Color = Color3.fromRGB(255, 255, 255)
		}
	},
	{
		Name = "67",
		Priority = 1,
		Tag = {
			Text = "67",
			Color = Color3.fromRGB(255, 255, 255)
		}
	},
	{
		Name = "2026",
		Priority = 1,
		Tag = {
			Text = "2026",
			Color = Color3.fromRGB(255, 255, 255)
		}
	},
	{
		Name = "Titan",
		Priority = 1,
		Tag = {
			Text = "Titan",
			Color = Color3.fromRGB(255, 170, 127)
		}
	},
	{
		Name = "Dot",
		Priority = 1,
		Tag = {
			Text = "Dot",
			Color = Color3.fromRGB(255, 170, 127)
		}
	},
	{
		Name = "GOAT",
		Priority = 1,
		Tag = {
			Text = "GOAT",
			Color = Color3.fromRGB(255, 170, 127)
		}
	},
	{
		Name = "Millionaire",
		Priority = 1,
		Tag = {
			Text = "MILLIONAIRE",
			Color = Color3.fromRGB(85, 255, 127)
		},
		Chat = {
			Color = Color3.fromRGB(85, 255, 127)
		}
	},
	{
		Name = "RegionalChampion",
		Priority = 1,
		Tag = {
			Text = "CHAMPION",
			Color = Color3.fromRGB(120, 85, 255)
		},
		Chat = {
			Color = Color3.fromRGB(120, 85, 255)
		}
	},
	{
		Name = "VIP",
		ChatOperator = { "VIP" },
		Priority = 1,
		Tag = {
			Text = "VIP",
			Color = Color3.fromRGB(255, 255, 0)
		},
		Chat = {
			Color = Color3.fromRGB(200, 200, 127)
		}
	},
	{
		Name = "Contributor",
		ChatOperator = { "CONTRIBUTOR" },
		Priority = 7,
		Tag = {
			Text = "CONTRIBUTOR",
			Color = Color3.fromRGB(152, 152, 255)
		}
	},
	{
		Name = "Trial Tester",
		ChatOperator = { "HELPER" },
		Priority = 7,
		Tag = {
			Text = "TRIAL" .. utf8.char(57344),
			Color = Color3.fromRGB(56, 192, 255)
		}
	},
	{
		Name = "ContentCreator",
		ChatOperator = { "CONTENTCREATOR" },
		Priority = 8,
		Tag = {
			Text = "CONTENT" .. utf8.char(57344),
			Color = Color3.fromRGB(255, 17, 0)
		}
	},
	{
		Name = "Tester",
		ChatOperator = { "TESTER" },
		Priority = 10,
		Tag = {
			Text = "TESTER" .. utf8.char(57344),
			Color = Color3.fromRGB(80, 120, 255)
		},
		Chat = {
			Color = Color3.fromRGB(80, 120, 255)
		}
	},
	{
		Name = "Moderator",
		ChatOperator = { "SUPPORT", "MODERATOR" },
		Priority = 20,
		Tag = {
			Text = "STAFF" .. utf8.char(57344),
			Color = Color3.fromRGB(77, 204, 255)
		},
		Chat = {
			Color = Color3.fromRGB(77, 204, 255)
		}
	},
	{
		Name = "Admin",
		ChatOperator = { "ADMIN" },
		Priority = 50,
		Tag = {
			Text = "ADMIN" .. utf8.char(57344),
			Color = Color3.fromRGB(214, 0, 0)
		},
		Chat = {
			Color = Color3.fromRGB(214, 0, 0)
		}
	},
	{
		Name = "Developer",
		ChatOperator = { "DEVELOPER" },
		Priority = 100,
		Tag = {
			Text = "DEV" .. utf8.char(57344),
			Color = Color3.fromRGB(255, 204, 77)
		},
		Chat = {
			Color = Color3.fromRGB(255, 204, 77)
		}
	},
	{
		Name = "Management",
		ChatOperator = { "MANAGER" },
		Priority = 100,
		Tag = {
			Text = "MANAGER" .. utf8.char(57344),
			Color = Color3.fromRGB(255, 16, 240)
		},
		Chat = {
			Color = Color3.fromRGB(255, 16, 240)
		}
	},
	{
		Name = "EXECUTIVE",
		ChatOperator = { "EXECUTIVE" },
		Priority = 150,
		Tag = {
			Text = "EXECUTIVE" .. utf8.char(57344),
			Color = Color3.fromRGB(233, 30, 99)
		},
		Chat = {
			Color = Color3.fromRGB(233, 30, 99)
		}
	}
}

for k in v.Seasons.Normal do
	table.insert(v2, {
		Name = `S{k} Champion`,
		Priority = 2,
		Tag = {
			Text = `S{k} CHAMPION`,
			Color = Color3.fromRGB(36, 160, 255)
		}
	})
end

return (table.freeze(v2))