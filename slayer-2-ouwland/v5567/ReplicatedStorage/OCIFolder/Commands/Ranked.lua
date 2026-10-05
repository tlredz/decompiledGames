local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Ranked = require(ReplicatedStorage.CAM.Global.Ranked)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)

local function describe(instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function v(childName: string)
		local child = instance:FindFirstChild(childName)

		if child == nil then
			return nil
		end

		return child.Value
	end

	local v2 = v("Points") -- equivalent call inferred; original call site unknown
	local v3 = v2 or 0
	local _, v4 = Ranked.TierOf(v3)
	local name = instance.Name
	local v7 = v("Mu") -- equivalent call inferred; original call site unknown
	local v8 = string.format("%.2f", v7 or 0)
	local v10 = v("Sigma") -- equivalent call inferred; original call site unknown
	local v11 = string.format("%.2f", v10 or 0)
	local name2 = v4.Name
	local v12 = v("Placements") -- equivalent call inferred; original call site unknown
	local v14 = v("Peak") -- equivalent call inferred; original call site unknown
	local v16 = v("Season") -- equivalent call inferred; original call site unknown
	local v18 = v("Wins") -- equivalent call inferred; original call site unknown
	local v20 = v("Losses") -- equivalent call inferred; original call site unknown
	return (`{name}: Mu {v8} Sigma {v11} | {v3} {name2} | placements {v12 or 0} peak {v14 or 0} | season {v16 or "?"} | W{v18 or 0} L{v20 or 0}`)
end

return {
	Clearance = 6,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Action",
			Name = "Action",
			Required = true,
			Suggester = {
				"Show",
				"Reset",
				"Rollover",
				"Cutoffs",
				"Points",
				"Rebuild"
			}
		},
		{
			Type = "Value",
			Name = "Key",
			Required = false,
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return p
			end
		},
		{
			Type = "Value",
			Name = "Value",
			Required = false,
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return p
			end
		}
	},
	Server = function(_, items, p: string, childName: string?, p2: string?)
		local RankedRecord = require(ServerStorage.SAM.Utility.RankedRecord)
		local RankedBoard = require(ServerStorage.SAM.Utility.RankedBoard)
		local v = string.lower((tostring(p)))

		if childName == "" then
			childName = nil
		end

		if childName ~= nil and not Ranked.IsKey(childName) then
			error((`Ranked: "{childName}" is not a ladder key (1v1, 2v2, 3v3, Tourney:<style>)`))
		end

		local v2 = {}

		for _, item in items do
			local _, v4 = Utility.GetData(item)
			local root = RankedRecord.Root(v4)

			if root == nil then
				table.insert(v2, (`{item.Name}: data not loaded`))
			elseif v == "show" then
				table.insert(v2, (`{item.Name} (season {Ranked.Season()}):`))
				local children

				if childName == nil then
					children = root.Modes:GetChildren()
				else
					children = { root.Modes:FindFirstChild(childName) }
				end

				if #children == 0 or children[1] == nil then
					table.insert(v2, "  no ladders yet")
				end

				for _, v5 in children do
					table.insert(v2, "  " .. describe(v5))
				end

				for _, child in root.Rewards:GetChildren() do
					table.insert(v2, (`  reward {child.Name}: {child.Value}`))
				end
			elseif v == "reset" then
				local v5

				if childName == nil then
					v5 = root.Modes:GetChildren()
				else
					v5 = { root.Modes:FindFirstChild(childName) }
				end

				for _, v6 in v5 do
					v6:Destroy()
				end

				if childName == nil then
					root.Recent.Value = ""

					for _, child in root.Rewards:GetChildren() do
						child:Destroy()
					end
				end

				table.insert(v2, (`{item.Name}: reset {childName or "every ladder"}`))
			elseif v == "rollover" then
				if childName == nil then
					error("Ranked: rollover needs a key")
				end

				local child = root.Modes:FindFirstChild(childName)

				if child == nil then
					error((`Ranked: {item.Name} has no {childName} ladder yet`))
				end

				local season = child:FindFirstChild("Season")

				if season == nil then
					error((`Ranked: {item.Name}'s {childName} ladder has no Season`))
				end

				season.Value = Ranked.Previous(Ranked.Season())
				RankedRecord.Entry(v4, childName)
				table.insert(v2, (`{item.Name}: rolled {childName} over — {describe(child)}`))
			elseif v == "cutoffs" then
				if childName == nil then
					error("Ranked: cutoffs needs a key")
				end

				if p2 == nil or p2 == "" then
					p2 = Ranked.Previous(Ranked.Season())
				end

				if Ranked.Season() <= p2 then
					error((`Ranked: cutoffs are only computed for a FINISHED season (before {Ranked.Season()})`))
				end

				local final = RankedBoard.Final(childName, p2)

				if final == nil then
					table.insert(v2, (`{childName} {p2}: the ledger did not answer`))
				else
					local v5 = {}

					for i = 1, math.min(3, #final.Top) do
						table.insert(v5, (`#{i} {final.Top[i].UserId} ({final.Top[i].Score})`))
					end

					for _, v6 in { 1, 3 } do
						table.insert(
							v5,
							(`top {v6}% >= {Ranked.Rules.CutoffFrom(MinigameSettings.Settings.PvP.Ranked, final.Dist, v6) or "none"}`)
						)
					end

					table.insert(
						v2,
						(`{childName} {p2}: population {Ranked.Rules.Population(final.Dist)}, {#final.Top} on the page; {table.concat(v5, ", ")}`)
					)
				end

				break
			elseif v == "points" then
				if childName == nil then
					error("Ranked: points needs a key")
				end

				local v5 = tonumber(p2)

				if v5 == nil then
					error("Ranked: points needs a number")
				end

				local entry = RankedRecord.Entry(v4, childName)

				if entry == nil then
					error((`Ranked: {item.Name}'s data is not loaded`))
				end

				local v6 = RankedRecord.Read(entry)
				v6.Points = math.max(math.floor(v5), 0)
				v6.Peak = math.max(v6.Peak, (Ranked.TierOf(v6.Points)))
				RankedRecord.Write(entry, v6)

				if Ranked.Placed(v6) then
					task.spawn(RankedBoard.Submit, item.UserId, childName, v6.Points)
				end

				table.insert(v2, (`{item.Name}: {describe(entry)}`))
			elseif v == "rebuild" then
				if childName == nil then
					error("Ranked: rebuild needs a key")
				end

				if p2 == nil or p2 == "" then
					p2 = Ranked.Season()
				end

				local v5 = p2
				task.spawn(function()
					local rebuild = RankedBoard.Rebuild(childName, v5)
					local v6

					if rebuild == nil then
						v6 = `[Ranked] {childName} {v5}: rebuild failed, see the warnings`
					else
						v6 = `[Ranked] {childName} {v5}: histogram rebuilt, population {rebuild}`
					end

					print(v6)
				end)
				table.insert(
					v2,
					(`{childName} {p2}: rebuilding from the board, the result prints to the server output`)
				)
				break
			else
				error((`Ranked: unknown action "{v}" (Show, Reset, Rollover, Cutoffs, Points, Rebuild)`))
			end
		end

		return {
			Content = table.concat(v2, "\n"),
			BgColor = Color3.fromRGB(32, 143, 70),
			FgColor = Color3.new(1, 1, 1)
		}
	end
}