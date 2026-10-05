local HttpService = game:GetService("HttpService")
local v = {}

local function cullOldRecords()
	local unixTimestamp = DateTime.now().UnixTimestamp

	for i = #v, 1, -1 do
		local v2 = v[i]

		if not v2 or unixTimestamp - DateTime.fromIsoDate(v2.AtISODate).UnixTimestamp < 180 then
			continue
		end

		for i2 = i, 1, -1 do
			table.remove(v, i2)
		end
	end
end

local function recordGetAsync(url: string)
	local v2 = {
		Type = "Get",
		Url = url,
		AtISODate = DateTime.now():ToIsoDate(),
		AtTick = tick(),
		Traceback = debug.traceback(nil, 3)
	}
	table.insert(v, v2)
	cullOldRecords()
end

local function recordPostAsync(url: string, p2: string)
	local v2 = {
		Type = "Post",
		Url = url,
		AtISODate = DateTime.now():ToIsoDate(),
		AtTick = tick(),
		Data = p2,
		Traceback = debug.traceback(nil, 3)
	}
	table.insert(v, v2)
	cullOldRecords()
end

local HTTPServiceWrapper = {}

function HTTPServiceWrapper.getAsync(url: string, flag: boolean?, p2)
	recordGetAsync(url)
	return table.unpack({ HttpService:GetAsync(url, flag, p2) })
end

function HTTPServiceWrapper.postAsync(url: string, p2: string, p3, flag: boolean?, p4)
	recordPostAsync(url, p2)
	return HttpService:PostAsync(url, p2, p3, flag, p4)
end

function HTTPServiceWrapper.requestAsync(data)
	if data.Method == "GET" then
		recordGetAsync(data.Url)
	elseif data.Method == "POST" then
		recordPostAsync(data.Url, data.Body)
	end

	return HttpService:RequestAsync(data)
end

function HTTPServiceWrapper.generateReport(flag: boolean?)
	local v2 = {
		Get = {},
		Post = {}
	}

	for _, v3 in pairs(v) do
		v2[v3.Type][v3.Url] = (v2[v3.Type][v3.Url] or 0) + 1
	end

	local v3 = {
		Get = {},
		Post = {}
	}

	for k, v4 in pairs(v2) do
		for k2, count in pairs(v4) do
			table.insert(v3[k], {
				Url = k2,
				Count = count
			})
		end

		table.sort(v3[k], function(a, b)
			return a.Count > b.Count
		end)
	end

	local atISODate = v[1].AtISODate
	local atISODate2 = v[#v].AtISODate
	local v4 = [[
HTTPServiceWrapper Report

]] .. ([[
From %s to %s (%d seconds)

]]):format(atISODate, atISODate2, DateTime.fromIsoDate(atISODate2).UnixTimestamp - DateTime.fromIsoDate(atISODate).UnixTimestamp)

	for k, v5 in pairs(v3) do
		local v6 = v4 .. ("%s:\n"):format(k)

		for _, v7 in pairs(v5) do
			v6 ..= ("    %q: %d\n"):format(v7.Url, v7.Count)
		end

		v4 = v6 .. [[


]]
	end

	local v5 = v4 .. [[
Records:

]]

	for _, v6 in pairs(v) do
		local v7 = v5 .. ("%s: %s %q"):format(v6.AtISODate, v6.Type, v6.Url)

		if flag then
			v7 ..= "\n    " .. v6.Traceback
		end

		v5 = v7 .. "\n"
	end

	return v5
end

function HTTPServiceWrapper.getRecords()
	return v
end

return HTTPServiceWrapper