local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)

local function whole(value)
	return type(value) == "number" and value >= 0 and value <= 9007199254740991 and value % 1 == 0
end

local v = {
	Blank = function()
		return {
			Total = 0,
			Scheduled = 0,
			Admin = 0,
			BeforeWeapon = 0,
			AfterWeapon = 0,
			FirstHitAt = 0,
			LastHitAt = 0,
			RecentFightUids = {}
		}
	end,
	Credit = function(data, value: string, flag: boolean, value2: number, value3: number)
		local v2

		if type(value) == "string" and #value > 0 then
			v2 = #value <= 128
		else
			v2 = false
		end

		assert(v2)
		local v3

		if type(flag) == "boolean" then
			if type(value2) == "number" and value2 >= 0 and value2 <= 9007199254740991 then
				v3 = value2 % 1 == 0
			else
				v3 = false
			end

			if v3 then
				if type(value3) == "number" and value3 >= 0 and value3 <= 9007199254740991 then
					v3 = value3 % 1 == 0
				else
					v3 = false
				end
			end
		else
			v3 = false
		end

		assert(v3)

		if table.find(data.RecentFightUids, value) then
			return nil, "AlreadyRecorded"
		end

		if data.Total >= 9007199254740991 then
			return nil, "LimitReached"
		end

		local clone = table.clone(data)
		clone.RecentFightUids = table.clone(data.RecentFightUids)
		table.insert(clone.RecentFightUids, value)

		if #clone.RecentFightUids > 64 then
			table.remove(clone.RecentFightUids, 1)
		end

		clone.Total += 1

		if flag then
			clone.Admin += 1
		else
			clone.Scheduled += 1
		end

		if value3 > 0 and value3 <= value2 then
			clone.AfterWeapon += 1
		else
			clone.BeforeWeapon += 1
		end

		local firstHitAt

		if data.Total == 0 then
			firstHitAt = value2
		else
			firstHitAt = math.min(data.FirstHitAt, value2)
		end

		clone.FirstHitAt = firstHitAt
		clone.LastHitAt = math.max(data.LastHitAt, value2)
		return clone, "Recorded"
	end,
	State = t.interface({
		Total = whole,
		Scheduled = whole,
		Admin = whole,
		BeforeWeapon = whole,
		AfterWeapon = whole,
		FirstHitAt = whole,
		LastHitAt = whole,
		RecentFightUids = t.array(t.string)
	})
}
return table.freeze(v)