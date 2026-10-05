local CommandCatalog = require(script.Parent:WaitForChild("CommandCatalog"))
local v = {
	"OwnersFriend",
	"Collaborator",
	"Supporter",
	"Developer",
	"Tester",
	"Creator",
	"Artist",
	"Animator",
	"CommunityStar",
	"ValleyLegend",
	"OG",
	"EventChampion"
}
return {
	suggest = function(value, p, p2, items, p3)
		if type(value) ~= "string" or #value > 512 then
			return {}
		end

		local v2 = math.clamp(p or #value + 1, 1, #value + 1)

		if value:sub(1, 1) ~= ";" then
			value = ";" .. value
			v2 += 1
		end

		local match, v3 = value:sub(1, v2 - 1):match("()(%S*)$")
		local v4 = value:sub(1, (match or v2) - 1)
		local v5 = value:sub(v2):gsub("^%S*", "")
		local v6 = {}
		local v7 = v3 or ""

		for k in v4:gmatch("%S+") do
			table.insert(v6, k)
		end

		local v8 = {}

		local function add(value2, p4, value3)
			if value2:lower():sub(1, #v7) ~= v7:lower() then
				return
			end

			local v9 = v5:match("^%s") and "" or " "
			local text = v4 .. value2 .. v9 .. v5
			table.insert(v8, {
				Text = text,
				Cursor = #v4 + #value2 + (v5:match("^%s") and 1 or #v9) + 1,
				Label = p4 or value2,
				Detail = value3 or ""
			})
		end

		if #v6 == 0 then
			if v7:sub(1, 1) ~= ";" then
				v7 = ";" .. v7
			end

			for _, command in CommandCatalog.Commands do
				if CommandCatalog.allowed(p2, command.Name, p3) then
					add(";" .. command.Name, ";" .. command.Name .. " " .. command.Usage, command.Description)
				end
			end
		else
			local lower = v6[1]:gsub("^;", ""):lower()
			local v9 = CommandCatalog.find(lower)

			if not (v9 and CommandCatalog.allowed(p2, v9.Name, p3)) then
				return {}
			end

			local arg = v9.Args[#v6]

			if arg == "player" then
				add("me", "me", "Your own character")

				for _, item in items do
					if item.Name:lower():sub(1, #v7) == v7:lower() then
						add(item.Name, item.Name, item.DisplayName)
					elseif item.DisplayName:lower():sub(1, #v7) == v7:lower() then
						local v12 = v7
						v7 = ""
						add(item.Name, item.Name, item.DisplayName)
						v7 = v12
					end
				end
			elseif arg == "skin" then
				local SkinCatalog = require(script.Parent.Parent.Weapons.SkinCatalog)

				for _, v10 in SkinCatalog.Order do
					local v11 = SkinCatalog.get(v10)

					if not v11 then
						continue
					end

					if v10:lower():sub(1, #v7) == v7:lower() then
						add(v10, v10, v11.Name)
					elseif v11.Name:lower():sub(1, #v7) == v7:lower() then
						local v14 = v7
						v7 = ""
						add(v10, v10, v11.Name)
						v7 = v14
					end
				end
			elseif arg == "tier" then
				local creatorRank = CommandCatalog.CreatorRank

				if creatorRank.Name:lower():sub(1, #v7) == v7:lower() or CommandCatalog.rank(v7) == creatorRank then
					local v11 = v7
					v7 = ""
					add(creatorRank.Name, creatorRank.Name .. " · creator tools", creatorRank.Description)
					v7 = v11
					v8[#v8].Order = 0
				end

				for _, tier in CommandCatalog.Tiers do
					if not (tier.Level < 5) then
						continue
					end

					local tier2 = CommandCatalog.tier(v7)

					if not (tier.Name:lower():sub(1, #v7) == v7:lower() or tostring(tier.Level):sub(1, #v7) == v7 or tier2 and tier2.Level == tier.Level) then
						continue
					end

					local v12 = v7
					v7 = ""
					add(tier.Name, tier.Level .. " · " .. tier.Name, tier.Description)
					v7 = v12
					v8[#v8].Order = tier.Level
				end
			elseif arg == "duration" then
				for _, v10 in {
					"15m",
					"1h",
					"1d",
					"7d"
				} do
					add(v10, v10, "Ban duration")
				end

				if p2 >= 4 then
					for _, v10 in { "30d", "365d", "perm" } do
						add(v10, v10, "Head Admin / Owner")
					end
				end
			elseif arg == "title" then
				for _, v10 in v do
					add(v10, v10, "Cosmetic only — no commands")
				end
			elseif arg == "toggle" then
				add("on", "on", "Stay in lobby")
				add("off", "off", "Join the next match")
			elseif arg == "seconds" then
				for _, v10 in {
					"15",
					"30",
					"60",
					"120"
				} do
					add(v10, v10, v10 .. " seconds")
				end
			elseif arg == "notice" then
				for _, v10 in {
					"10",
					"30",
					"60",
					"120"
				} do
					add(v10, v10, v10 .. " seconds before refresh")
				end
			elseif arg == "command" then
				for _, command in CommandCatalog.Commands do
					if CommandCatalog.allowed(p2, command.Name, p3) then
						add(command.Name, command.Name, command.Description)
					end
				end
			end
		end

		table.sort(v8, function(a, b)
			return (a.Order or 99) == (b.Order or 99) and a.Label:lower() < b.Label:lower() or (a.Order or 99) < (b.Order or 99)
		end)

		while #v8 > 6 do
			table.remove(v8)
		end

		return v8
	end
}