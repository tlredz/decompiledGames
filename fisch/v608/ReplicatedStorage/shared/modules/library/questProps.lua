local sets = {
	BalloonAnimals = {
		Id = "BalloonAnimals",
		Tag = "QuestProp_BalloonAnimal",
		TemplateFolder = "BalloonAnimals",
		QuestIds = { "ClownQuest1" },
		Total = 20,
		ActionText = "Pop",
		ObjectText = "Balloon Animal",
		Award = {
			Path = "Cache.ClownQuest1",
			Mode = "increment",
			Amount = 1
		}
	},
	SoulreaperGhosts = {
		Id = "SoulreaperGhosts",
		Tag = "QuestProp_SoulreaperGhost",
		TemplateFolder = "SoulreaperGhosts",
		QuestIds = { "Soulreaper6" },
		Total = 3,
		ActionText = "Give",
		ObjectText = "Ghost Buddy",
		Award = {
			Path = "Cache.SoulreaperGhost1",
			Mode = "set"
		},
		PerProp = {
			Ghost1 = {
				Award = {
					Path = "Cache.SoulreaperGhost1",
					Mode = "set"
				},
				RequiresItem = "Soulreaper Handle",
				ObjectText = "Ghost Buddy — Handle"
			},
			Ghost2 = {
				Award = {
					Path = "Cache.SoulreaperGhost2",
					Mode = "set"
				},
				RequiresItem = "Soulreaper Blade",
				ObjectText = "Ghost Buddy — Blade"
			},
			Ghost3 = {
				Award = {
					Path = "Cache.SoulreaperGhost3",
					Mode = "set"
				},
				RequiresItem = "Soulreaper Bonds",
				ObjectText = "Ghost Buddy — Bonds"
			}
		}
	}
}
local QuestProps = {
	Sets = sets,
	Get = function(p: string)
		return sets[p]
	end,
	SetsForQuest = function(p: string)
		local result = {}

		for _, v2 in sets do
			if table.find(v2.QuestIds, p) then
				table.insert(result, v2)
			end
		end

		return result
	end,
	GetOverride = function(p, p2: string)
		return p.PerProp and p.PerProp[p2] or nil
	end
}

function QuestProps.GetAward(p, p2: string)
	local override = QuestProps.GetOverride(p, p2)
	return override and override.Award or p.Award
end

return QuestProps