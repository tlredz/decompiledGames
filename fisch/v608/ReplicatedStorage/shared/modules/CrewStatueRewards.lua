local frozen = table.freeze({
	"Catches",
	"Rarest",
	"Rating",
	"Weight"
})
local frozen2 = table.freeze({
	Catches = "rbxassetid://108060928350942",
	Rarest = "rbxassetid://99970316755594",
	Rating = "rbxassetid://92065890080696",
	Weight = "rbxassetid://133580146731066"
})
local v = os.date("!*t")
local year = v.year
local month = v.month
local CrewStatueRewards = {
	toMonthNo = function(p: number, p2: number)
		return (p - 2026) * 12 + p2
	end,
	fromMonthNo = function(p: number)
		return (p - 1) // 12 + 2026, (p - 1) % 12 + 1
	end
}

function CrewStatueRewards:addBobbers()
	for i = 8, CrewStatueRewards.toMonthNo(year, month) + 1 do
		local v2, v3 = CrewStatueRewards.fromMonthNo(i)
		local formatted = `{v3}/{v2}`

		for _, v4 in ipairs(frozen) do
			local formatted2 = `Crew Trophy: {v4} ({formatted})`
			self[formatted2] = {
				Icon = frozen2[v4],
				Rarity = "Exotic",
				Name = formatted2,
				OverrideModel = `Crew Trophy: {v4}`,
				Untradeable = true
			}
		end
	end
end

function CrewStatueRewards:addFurniture()
	for i = 8, CrewStatueRewards.toMonthNo(year, month) + 1 do
		local v2, v3 = CrewStatueRewards.fromMonthNo(i)
		local formatted = `{v3}/{v2}`

		for _, v4 in ipairs(frozen) do
			local formatted2 = `Crew Trophy: {v4} ({formatted})`
			self[formatted2] = {
				DisplayName = formatted2,
				Icon = frozen2[v4],
				OverrideModel = `Crew Trophy: {v4}`,
				Recolorable = false
			}
		end
	end
end

return CrewStatueRewards