local v = {
	"CheckIn",
	"OnlineReward",
	"UpdateLog",
	"Mail"
}
local v2 = {}
local v3 = 1
local v4 = {}
local v5 = nil
local v6 = true

local function fn()
	return true
end

local flag = false

local function pump()
	if v5 or not (v6 and fn()) then
		return
	end

	while true do
		local name, open

		if v3 <= #v then
			name = v[v3]
			local v7 = v2[name]

			if not v7 then
				break
			end

			v3 += 1
			open = v7.open
		else
			local v7 = table.remove(v4, 1)

			if not v7 then
				break
			end

			name = v7.name
			open = v7.open
		end

		if open then
			v5 = name
			local success, result = pcall(open)

			if not success then
				warn("[RewardAutoOpenQueue] " .. name .. ": " .. tostring(result))
			end

			if success and result == true then
				break
			else
				v5 = nil
			end
		end

		if not (v6 and fn()) then
			break
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function schedule()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		pump()
	end)
end

local RewardAutoOpenQueue = {}

function RewardAutoOpenQueue.ResolveInitial(p: string, open)
	if v2[p] then
		return
	end

	v2[p] = {
		open = open
	}
	schedule() -- equivalent call inferred; original call site unknown
end

function RewardAutoOpenQueue.Enqueue(name: string, open)
	if v5 == name then
		return false
	end

	for i = v3, #v do
		if v[i] == name then
			return false
		end
	end

	for _, v7 in v4 do
		if v7.name == name then
			return false
		end
	end

	table.insert(v4, {
		name = name,
		open = open
	})
	schedule() -- equivalent call inferred; original call site unknown
	return true
end

function RewardAutoOpenQueue.Finish(p: string)
	if v5 ~= p then
		return
	end

	v5 = nil
	schedule() -- equivalent call inferred; original call site unknown
end

function RewardAutoOpenQueue.SetCanOpen(callback)
	fn = callback
	schedule() -- equivalent call inferred; original call site unknown
end

function RewardAutoOpenQueue.SetEnabled(flag2: boolean)
	v6 = flag2

	if v6 then
		schedule() -- equivalent call inferred; original call site unknown
	end
end

function RewardAutoOpenQueue.Resume()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		pump()
	end)
end

return RewardAutoOpenQueue