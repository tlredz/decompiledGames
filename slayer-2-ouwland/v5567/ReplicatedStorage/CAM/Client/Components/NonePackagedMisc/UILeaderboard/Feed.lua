local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ranked = require(ReplicatedStorage.CAM.Global.Ranked)
local SeasonBoards = require(ReplicatedStorage.CAM.Global.SeasonBoards)
local RankedController = require(ReplicatedStorage.CAM.Client.Controllers.RankedController)
local UserNames = require(ReplicatedStorage.CAM.Client.Modules.UserNames)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
require(script.Parent)
return function(object, p: string, flag: boolean?)
	local kind = SeasonBoards.KindOf(p)
	local entries = object:Value({})
	local mine2 = object:Value()
	local mineRank = object:Value()
	local share = object:Value()
	local mineIcon = object:Value("")

	local function show()
		local page = RankedController.Page(p)

		if page == nil then
			return
		end

		local v = {}

		for i = 1, math.min(#page.Top, 100) do
			local v2 = page.Top[i]
			local v3 = {
				UserId = v2.UserId,
				Name = UserNames.Get(v2.UserId),
				Score = v2.Score,
				Icon = 0
			}
			local icon

			if kind.Tiers then
				icon = Ranked.IconOf(v2.Score)
			end

			v3.Icon = icon
			v[i] = v3
		end

		local mine = RankedController.Mine(p)
		local standing, v2 = RankedController.Standing(p)
		entries:Set(v)
		mine2:Set(mine)

		if not (standing > 0) then
			standing = nil
		end

		mineRank:Set(standing)

		if not (v2 > 0) then
			v2 = nil
		end

		share:Set(v2)
		mineIcon:Set((not kind.Tiers or mine == nil) and "" or Ranked.IconOf(mine) or "")
	end

	object:Connect(RankedController.PageChanged, function(p2: string)
		if p2 == p then
			show()
		end
	end)
	object:Connect(UserNames.Changed, show)
	show()
	RankedController.Fetch(p)

	local function line()
		local formatted = `<b><font {gameSettings.RichTextPopularConfigs.SoroundColorRBX}>{kind.Label(kind.Season())}</font></b>`

		if not flag then
			return formatted
		end

		local v = math.max(Ranked.SeasonEnds() - os.time(), 0)
		return (`{formatted}, {math.floor(v / 86400)}d {math.floor(v % 86400 / 3600)}h left`)
	end

	local season = object:Value((line()))

	if flag then
		object:Spawn(function()
			while true do
				task.wait(60)
				season:Set((line()))
			end
		end)
	end

	local v = {
		Title = kind.Title(p),
		Season = season,
		Entries = entries,
		Mine = mine2,
		MineRank = mineRank,
		Share = share,
		MineIcon = 0
	}

	if not kind.Tiers then
		mineIcon = nil
	end

	v.MineIcon = mineIcon
	return v
end