local Clock = {}

local function plural(p: string, p2: number)
	return (`{p}{p2 == 1 and "" or "s"}`)
end

function Clock:ToTime(p: number)
	return {
		Minutes = math.floor(p / 60),
		Seconds = p % 60
	}
end

function Clock.ToSeconds(_, p)
	return p.Minutes * 60 + p.Seconds
end

function Clock.ToString(_, p: number)
	local time = Clock:ToTime(p)
	return (`{string.format("%0.2i", time.Minutes)}:{string.format("%0.2i", time.Seconds)}`)
end

function Clock.FormatDate(_, p: number)
	local v = os.time() - p

	if v < 60 then
		return v .. " seconds ago"
	end

	if v < 3600 then
		local v2 = math.floor(v / 60)
		return v2 .. (v2 == 1 and " minute ago" or " minutes ago")
	end

	if v < 86400 then
		local v2 = math.floor(v / 3600)
		return v2 .. (v2 == 1 and " hour ago" or " hours ago")
	end

	if v < 604800 then
		local v2 = math.floor(v / 86400)
		return v2 .. (v2 == 1 and " day ago" or " days ago")
	end

	if v < 2419200 then
		local v2 = math.floor(v / 604800)
		return v2 .. (v2 == 1 and " week ago" or " weeks ago")
	else
		return (DateTime.fromUnixTimestamp(p):FormatLocalTime("L", "en-us"))
	end
end

function Clock.ToDHMS(_, p: number)
	local v = math.floor(p / 86400)
	local v2 = math.floor(p % 86400 / 3600)
	local v3 = math.floor(p % 3600 / 60)
	local v4 = p % 60
	return string.format("%d:%02d:%02d:%02d", v, v2, v3, v4)
end

function Clock.ToDynamic(_, p: number)
	local v = math.floor(p / 86400)
	local v2 = math.floor(p % 86400 / 3600)
	local v3 = math.floor(p % 3600 / 60)
	local v4 = p % 60

	if v > 0 then
		return (`in {v} {`day{v == 1 and "" or "s"}`}`)
	end

	if v2 > 1 then
		return (`in {v2} {`hour{v2 == 1 and "" or "s"}`}`)
	end

	return string.format("in %02d:%02d:%02d", v2, v3, v4)
end

return Clock