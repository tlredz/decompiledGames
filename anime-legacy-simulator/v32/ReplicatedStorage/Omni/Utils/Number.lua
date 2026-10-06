local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local v = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qd",
	"Qn",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"De",
	"βA",
	"βB",
	"βC",
	"βD",
	"βE",
	"βF",
	"βG",
	"βH",
	"βI",
	"βJ",
	"βK",
	"βL",
	"βM",
	"βN",
	"βO",
	"βP",
	"βQ",
	"βR",
	"βS",
	"βT",
	"βU",
	"βV",
	"βW",
	"βX",
	"βY",
	"βZ",
	"αA",
	"αB",
	"αC",
	"αD",
	"αE",
	"αF",
	"αG",
	"αH",
	"αI",
	"αJ",
	"αK",
	"αL",
	"αM",
	"αN",
	"αO",
	"αP",
	"αQ",
	"αR",
	"αS",
	"αT",
	"αU",
	"αV",
	"αW",
	"αX",
	"αY",
	"αZ",
	"εA",
	"εB",
	"εC",
	"εD",
	"εE",
	"εF",
	"εG",
	"εH",
	"εI",
	"εJ",
	"εK",
	"εL",
	"εM",
	"εN",
	"εO",
	"εP",
	"εQ",
	"εR",
	"εS",
	"εT",
	"εU",
	"εV",
	"εW",
	"εX",
	"εY",
	"εZ"
}
local heartbeatConnection = nil
local v2 = {}
local v3 = {
	Random = function(_, list)
		return list[math.random(1, #list)]
	end,
	Sanitize = function(_, value: number)
		repeat
			local v4
			value, v4 = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
		until v4 <= 0

		return value
	end,
	Round = function(_, p: number, value: number?)
		local v4 = 10 ^ (value or 2)
		return math.floor(p * v4 + 0.5) / v4
	end,
	FormatDecimal = function(self, p: number)
		local v4 = string.format("%.2f", p)
		local v5 = string.gsub(v4, "0+$", "")
		local v6 = string.gsub(v5, "%.$", "")

		if v6 == "-0" then
			return "0"
		end

		return v6
	end,
	Format = function(self, p: number)
		local v4 = ""
		local v5

		if p == 1e999 or not (p >= 10000) then
			v5 = p
		else
			v5 = p

			for i = 1, #v do
				if not (p < 10 ^ (i * 3)) then
					continue
				end

				v5 = math.floor(p / (10 ^ ((i - 1) * 3) / 100)) / 100
				v4 = v[i]
				break
			end
		end

		return self:FormatDecimal(v5) .. v4
	end,
	Unformat = function(_, value: string)
		if tonumber(value) then
			return (tonumber(value))
		end

		local v4 = ""
		local v5 = ""

		for i = 1, #value do
			local v6 = string.sub(value, i, i)

			if tonumber(v6) or v6 == "." then
				v4 ..= v6
			else
				v5 ..= v6
			end
		end

		if #v5 == 0 or not table.find(v, v5) then
			return 0
		end

		local v6 = 1

		for _ = 1, ((table.find(v, v5) or 0) - 1) * 3 do
			v6 ..= 0
		end

		return tonumber(v4) * v6
	end,
	Time = function(_, p: number)
		local v4 = math.abs(p)

		if v4 >= 0 and v4 < 60 then
			return ("%02i"):format(v4)
		end

		if v4 >= 60 and v4 < 3600 then
			return ("%02i:%02i"):format(v4 / 60 % 60, v4 % 60)
		end

		if v4 > 3599 and v4 < 86399 then
			return ("%02i:%02i:%02i"):format(v4 / 3600 % 24, v4 / 60 % 60, v4 % 60)
		end

		if v4 > 86398 then
			return ("%02i:%02i:%02i:%02i"):format(v4 / 86400, v4 / 3600 % 24, v4 / 60 % 60, v4 % 60)
		end
	end,
	Time2 = function(_, p: number)
		local v4 = math.abs(p)
		local v5 = math.floor(v4 % 86400 / 3600)
		local v6 = math.floor(v4 % 3600 / 60)
		local v7 = v4 % 60

		if v4 < 60 then
			return ("%ds"):format(v7)
		end

		if v4 < 3600 then
			if v7 == 0 then
				return ("%dm"):format(v6)
			end

			return ("%dm %ds"):format(v6, v7)
		elseif v4 < 86400 then
			local v8 = {}

			if v5 > 0 then
				table.insert(v8, ("%dh"):format(v5))
			end

			if v6 > 0 then
				table.insert(v8, ("%dm"):format(v6))
			end

			if v7 > 0 then
				table.insert(v8, ("%ds"):format(v7))
			end

			return table.concat(v8, " ")
		else
			local v8 = math.round(v4 / 86400)

			if v8 >= 365 then
				return "1y+"
			end

			local v9 = math.floor(v8 / 30)
			local v10 = v8 % 30
			local v11 = math.floor(v10 / 7)
			local v12 = v10 % 7
			local v13 = {}

			if v9 > 0 then
				table.insert(v13, ("%dmo"):format(v9))
			end

			if v11 > 0 then
				table.insert(v13, ("%dw"):format(v11))
			end

			if v12 > 0 then
				table.insert(v13, ("%dd"):format(v12))
			end

			return table.concat(v13, " ")
		end
	end,
	Time3 = function(_, p: number)
		if p >= -999999 and p < 60 then
			return ("%02is"):format(p % 60)
		end

		if p > 59 and p < 3600 then
			return ("%02im %02is"):format(p / 60 % 60, p % 60)
		end

		if p > 3599 and p < 86399 then
			return ("%02ih %02im %02is"):format(p / 3600 % 24, p / 60 % 60, p % 60)
		end

		if p > 86398 then
			return ("%02id %02ih %02im"):format(p / 86400, p / 3600 % 24, p / 60 % 60)
		end
	end,
	Time4 = function(_, p: number)
		if p >= -999999 and p < 60 then
			return ("%02is"):format(p % 60)
		end

		if p > 59 and p < 3600 then
			return ("%02im %02is"):format(p / 60 % 60, p % 60)
		end

		if p > 3599 and p < 86399 then
			return ("%02ih %02im %02is"):format(p / 3600 % 24, p / 60 % 60, p % 60)
		end

		if p > 86398 then
			return ("%02id %02ih %02im %02is"):format(p / 86400, p / 3600 % 24, p / 60 % 60, p % 60)
		end
	end,
	CurrentDay = function(_)
		local serverTimeNow = workspace:GetServerTimeNow()
		local day = DateTime.now():ToUniversalTime().Day
		return math.floor(serverTimeNow / 86400), day
	end,
	GetCurrentDate = function(_)
		local universalTime = DateTime.now():ToUniversalTime()
		return
			string.format("%02d/%02d/%04d", universalTime.Day, universalTime.Month, universalTime.Year),
			(string.format("%02d:%02d:%02d", universalTime.Hour, universalTime.Minute, universalTime.Second))
	end
}
local v4 = {
	1000,
	900,
	500,
	400,
	100,
	90,
	50,
	40,
	10,
	9,
	5,
	4,
	1
}
local v5 = {
	"M",
	"CM",
	"D",
	"CD",
	"C",
	"XC",
	"L",
	"XL",
	"X",
	"IX",
	"V",
	"IV",
	"I"
}

function v3.ToRoman(_, p)
	if p < 1 or p > 3999 then
		return "N/A"
	end

	local v6 = ""

	for i = 1, #v4 do
		local v7 = math.floor(p / v4[i])
		p %= v4[i]
		v6 ..= string.rep(v5[i], v7)
	end

	return v6
end

local function UpdateLerpNumber(p)
	for i = #v2, 1, -1 do
		local v6 = v2[i]
		v6.Alpha += p / v6.Time

		if v6.Alpha >= 1 then
			v6.Callback(v6.Goal, true)
			table.remove(v2, i)
		else
			local v7 = v6.Start + (v6.Goal - v6.Start) * v6.Alpha
			v6.Callback(v7)
		end
	end

	if #v2 == 0 then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

function v3.LerpNumber(_, start: number, goal: number, time: number, callback)
	local v6 = {
		Start = start,
		Goal = goal,
		Time = time,
		Alpha = 0,
		Callback = callback,
		Running = true
	}
	table.insert(v2, v6)

	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(UpdateLerpNumber)
	end

	return {
		Disconnect = function()
			v6.Running = false
		end
	}
end

function v3.TweenNumber(_, p: number, p2: number, p3, callback)
	local v6 = {}
	v6.Instance = Instance.new("NumberValue")
	v6.Instance.Value = p
	v6.Instance.Parent = workspace.Cache
	v6.Tween = TweenService:Create(v6.Instance, p3, {
		Value = p2
	})
	v6.Connection = v6.Instance.Changed:Connect(function()
		callback(v6.Instance.Value)
	end)
	v6.Connection2 = v6.Tween.Completed:Once(function()
		callback(p2, true)
		v6.Stop()
	end)

	function v6.Stop()
		if not v6 then
			return
		end

		if v6.Tween then
			v6.Tween:Cancel()
			v6.Tween = nil
		end

		if v6.Connection then
			v6.Connection:Disconnect()
			v6.Connection = nil
		end

		if v6.Connection2 then
			v6.Connection2:Disconnect()
			v6.Connection2 = nil
		end

		if v6.Instance then
			v6.Instance:Destroy()
			v6.Instance = nil
		end

		v6 = nil
	end

	v6.Tween:Play()
	return v6
end

function v3.RandomNumbers(p: number, p2: number, p3: number)
	if p2 - p + 1 < p3 then
		error("Quantidade solicitada é maior que o intervalo disponível!")
	end

	local v6 = {}
	local result = {}

	for i = p, p2 do
		table.insert(v6, i)
	end

	for i = #v6, 2, -1 do
		local v7 = math.random(1, i)
		local v8 = v6[v7]
		local v9 = v6[i]
		v6[i] = v8
		v6[v7] = v9
	end

	for i = 1, p3 do
		table.insert(result, v6[i])
	end

	return result
end

function v3.Sigmoid(p: number)
	return 1 / (math.exp(-p) + 1)
end

return table.freeze(v3)