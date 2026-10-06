local CommerceCatalog = require(script.Parent.CommerceCatalog)
local RoleRewards = {
	Sender = {
		UserId = 0,
		UserName = "Anime Legacy",
		NickName = "ALS Team"
	},
	Roles = {
		["Early Access Plus"] = {
			Order = 1,
			Trigger = "TimeChamber",
			Title = "Early Access Plus",
			Messages = {
				"Thank you for joining Anime Legacy early!",
				"Here are your exclusive rewards. Claim them below!"
			},
			Rewards = {
				{
					Type = "Item",
					Name = "Free Gems",
					Amount = 1500
				},
				{
					Type = "Mount",
					Name = "Starbara",
					Amount = 1
				}
			},
			Bundles = { "Starter Pack" }
		},
		["Senior CC"] = {
			Order = 2,
			Trigger = "Join",
			Ranks = { 12 },
			Title = "Senior CC",
			Messages = {
				"Thank you for creating content for Anime Legacy!",
				"Here are your exclusive rewards. Claim them below!"
			},
			Rewards = {},
			Bundles = { "All Gamepasses" }
		},
		["Junior CC"] = {
			Order = 3,
			Trigger = "Join",
			Ranks = { 11 },
			Title = "Junior CC",
			Messages = {
				"Thank you for creating content for Anime Legacy!",
				"Here are your exclusive rewards. Claim them below!"
			},
			Rewards = {},
			Bundles = { "All Gamepasses" }
		},
		["Beginner CC"] = {
			Order = 4,
			Trigger = "Join",
			Ranks = { 10 },
			Title = "Beginner CC",
			Messages = {
				"Thank you for creating content for Anime Legacy!",
				"Here are your exclusive rewards. Claim them below!"
			},
			Rewards = {},
			Bundles = { "All Gamepasses" }
		}
	},
	GetInboxID = function(p: string)
		return (`RoleRewards:{p}`)
	end
}

function RoleRewards.GetRewards(p: string)
	local role = RoleRewards.Roles[p]

	if not role then
		return {}
	end

	local result = {}

	for _, v in role.Rewards or {} do
		table.insert(result, table.clone(v))
	end

	for _, v in role.Bundles or {} do
		for _, v2 in CommerceCatalog.GetRewards(v) do
			table.insert(result, v2)
		end
	end

	return result
end

function RoleRewards.GetRankRoles(items)
	local result = {}

	for k, role in RoleRewards.Roles do
		if role.Trigger ~= "Join" then
			continue
		end

		for _, item in items do
			if not table.find(role.Ranks or {}, item) then
				continue
			end

			table.insert(result, k)
			break
		end
	end

	return result
end

function RoleRewards.GetOrderedRoles()
	local result = {}

	for k in RoleRewards.Roles do
		table.insert(result, k)
	end

	table.sort(result, function(a, b)
		return RoleRewards.Roles[a].Order < RoleRewards.Roles[b].Order
	end)
	return result
end

return RoleRewards