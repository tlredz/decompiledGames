local Abbreviate = {}
local v = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi"
}

function Abbreviate.ShowNum(p)
	local v2 = "None"
	local number = Abbreviate.GetNumber(p)

	if number >= 1e18 then
		return math.floor(number / 1e16) / 100 .. "Qi"
	end

	if number >= 1000000000000000 and number < 1e18 then
		return math.floor(number / 10000000000000) / 100 .. "Qa"
	end

	if number >= 1000000000000 and number < 1000000000000000 then
		return math.floor(number / 10000000000) / 100 .. "T"
	end

	if number >= 1000000000 and number < 1000000000000 then
		return math.floor(number / 10000000) / 100 .. "B"
	end

	if number >= 1000000 and number < 1000000000 then
		return math.floor(number / 10000) / 100 .. "M"
	end

	if number >= 1000 and number < 1000000 then
		return math.floor(number / 10) / 100 .. "K"
	end

	if number < 1000 then
		return number
	end

	return v2
end

function Abbreviate.convertSeconds(p)
	local years = math.floor(p / 31536000)
	local v3 = p % 31536000
	local months = math.floor(v3 / 2592000)
	local v5 = v3 % 2592000
	local days = math.floor(v5 / 86400)
	local v7 = v5 % 86400
	local hours = math.floor(v7 / 3600)
	local v9 = v7 % 3600
	return {
		years = years,
		months = months,
		days = days,
		hours = hours,
		minutes = math.floor(v9 / 60),
		seconds = v9 % 60
	}
end

function Abbreviate.formatTime(data, p)
	local v2 = {}

	if p then
		if data.years > 0 then
			table.insert(v2, data.years .. " ปี")
		end

		if data.months > 0 then
			table.insert(v2, data.months .. " เดือน")
		end

		if data.days > 0 then
			table.insert(v2, data.days .. " วัน")
		end

		if data.hours > 0 then
			table.insert(v2, data.hours .. " ชั่วโมง")
		end

		if data.minutes > 0 then
			table.insert(v2, data.minutes .. " นาที")
		end

		if data.seconds > 0 or #v2 == 0 then
			table.insert(v2, data.seconds .. " วินาที")
		end
	else
		if data.years > 0 then
			table.insert(v2, data.years .. " year" .. (data.years > 1 and "s" or ""))
		end

		if data.months > 0 then
			table.insert(v2, data.months .. " month" .. (data.months > 1 and "s" or ""))
		end

		if data.days > 0 then
			table.insert(v2, data.days .. " day" .. (data.days > 1 and "s" or ""))
		end

		if data.hours > 0 then
			table.insert(v2, data.hours .. " hour" .. (data.hours > 1 and "s" or ""))
		end

		if data.minutes > 0 then
			table.insert(v2, data.minutes .. " minute" .. (data.minutes > 1 and "s" or ""))
		end

		if data.seconds > 0 or #v2 == 0 then
			table.insert(v2, data.seconds .. " second" .. (data.seconds > 1 and "s" or ""))
		end
	end

	return table.concat(v2, " ")
end

function Abbreviate.Format(p, p2)
	local v2 = math.floor((math.log(math.max(1, (math.abs(p))), 1000)))
	local v3 = v[v2 + 1] or "e+" .. v2
	local v4 = math.floor(p * (10 ^ p2 / 1000 ^ v2)) / 10 ^ p2
	return ("%." .. p2 .. "f%s"):format(v4, v3)
end

function Abbreviate.Format_Comma(p, p2)
	return (tonumber(string.format(`%.{p2}f`, p)))
end

function Abbreviate.Comma(p)
	local number = Abbreviate.GetNumber(p)

	repeat
		local v2
		number, v2 = string.gsub(number, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return number
end

function Abbreviate.GetNumber(value)
	local v2 = tonumber((string.gsub(value, ",", "")))

	if v2 == nil then
		return nil
	end

	return (math.floor(v2))
end

return Abbreviate