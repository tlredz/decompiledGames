local KidTasks = {
	Tasks = {
		DinoKid = {
			{
				Id = "Tent",
				Name = "Place at tent",
				Level = 1,
				Description = "Cuts wood and leaves it at his tent"
			},
			{
				Id = "Campfire",
				Name = "Place in Campfire",
				Level = 3,
				Description = "Cuts wood and puts it in the Campfire"
			},
			{
				Id = "Scrapper",
				Name = "Place in Scrapper",
				Level = 3,
				Description = "Cuts wood and puts it in the Scrapper"
			}
		},
		KrakenKid = {
			{
				Id = "Tent",
				Name = "Place at tent",
				Level = 1,
				Description = "Fish for basic fish"
			},
			{
				Id = "BetterFish",
				Name = "Better Fishing",
				Level = 3,
				Description = "Try to fish for better fish"
			}
		},
		SquidKid = {
			{
				Id = "Tent",
				Name = "Place at tent",
				Level = 1,
				Description = "Cooks food and leaves it at tent"
			},
			{
				Id = "Crockpot",
				Name = "Place in Crockpot",
				Level = 5,
				Description = "Puts food in the crockpot if it's empty"
			}
		},
		KoalaKid = {
			{
				Id = "Tent",
				Name = "Place at tent",
				Level = 1,
				Description = "Digs for scrap and places it at tent"
			},
			{
				Id = "Scrapper",
				Name = "Place in Scrapper",
				Level = 5,
				Description = "Digs for scrap and places it in the scrapper"
			}
		}
	}
}

function KidTasks.GetTasks(p: string)
	return KidTasks.Tasks[p]
end

function KidTasks.GetTask(p: string, p2: string)
	for _, v in pairs(KidTasks.Tasks[p] or {}) do
		if v.Id == p2 then
			return v
		end
	end
end

function KidTasks.GetDefaultTask(p: string)
	local v = nil

	for _, v2 in pairs(KidTasks.Tasks[p] or {}) do
		if v == nil or v2.Level < v.Level then
			v = v2
		end
	end

	return v
end

return KidTasks