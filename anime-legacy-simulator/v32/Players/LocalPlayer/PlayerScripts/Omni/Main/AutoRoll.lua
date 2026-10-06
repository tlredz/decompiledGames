local module = require("@game/ReplicatedStorage/Omni")
local v = {
	Cooldown = true,
	Busy = true,
	Character = true
}
local v2 = nil
local v3 = false
local star = nil
local v4 = nil
local v5 = {}
local AutoRoll = {}

local function LoadSaved()
	local autoRoll = module.Data and module.Data.AutoRoll

	if typeof(autoRoll) ~= "table" then
		return
	end

	if typeof(autoRoll.Star) == "string" then
		star = autoRoll.Star
	end

	local gacha = autoRoll.Gacha

	if typeof(gacha) == "table" and typeof(gacha.System) == "string" and typeof(gacha.Target) == "string" then
		v4 = {
			System = gacha.System,
			Target = gacha.Target
		}
	end
end

local function WaitInterface(p: string)
	local v6 = os.clock() + 60

	while not (module.Scripts.Interface and module.Scripts.Interface[p]) do
		if v6 < os.clock() then
			return false
		else
			task.wait(0.1)
		end
	end

	return true
end

local function PruneExpired()
	local now = os.clock()

	for k, v6 in v5 do
		for k2, v7 in v6 do
			if now - v7 >= 300 then
				v6[k2] = nil
			end
		end

		if not next(v6) then
			v5[k] = nil
		end
	end
end

LoadSaved()

function AutoRoll.Hold()
	v3 = true
end

function AutoRoll.SaveStar(p: string?)
	if star == p or v3 and p == nil then
		return
	end

	star = p
	module.Signal:Fire("General", "AutoRoll", "SetStar", p)
end

function AutoRoll.SaveGacha(system: string?, target: string?)
	if system == nil or target == nil then
		if v4 == nil or v3 then
			return
		end

		v4 = nil
		module.Signal:Fire("General", "AutoRoll", "SetGacha")
	else
		if v4 and v4.System == system and v4.Target == target then
			return
		end

		v4 = {
			System = system,
			Target = target
		}
		module.Signal:Fire("General", "AutoRoll", "SetGacha", system, target)
	end
end

function AutoRoll.Claim(cancel, system: string?, p2: string?)
	local v6 = v2
	v2 = nil

	if v6 then
		v6.Cancel()
	end

	local v7 = {
		Cancel = cancel,
		System = system
	}
	v2 = v7

	if system and p2 then
		AutoRoll.SaveGacha(system, p2)
	end

	return v7
end

function AutoRoll.Release(p)
	if not p or v2 ~= p then
		return
	end

	v2 = nil

	if p.System then
		AutoRoll.SaveGacha(nil)
	end
end

function AutoRoll.ShouldRetry(value)
	return typeof(value) == "string" and v[value] == true
end

function AutoRoll.Expire(p: string, p2: number)
	PruneExpired()
	local nows = v5[p]

	if not nows then
		nows = {}
		v5[p] = nows
	end

	nows[p2] = os.clock()
end

function AutoRoll.TakeExpired(p: string, p2: number?)
	local v6 = v5[p]

	if not v6 or p2 == nil or not v6[p2] then
		return false
	end

	v6[p2] = nil

	if not next(v6) then
		v5[p] = nil
	end

	return true
end

function AutoRoll.Destroy()
	v3 = true
	local v6 = v2
	v2 = nil

	if v6 then
		v6.Cancel()
	end
end

function AutoRoll.Init()
	module:WaitInitialization()
	local v6 = star
	local v7 = v4

	if v6 then
		task.spawn(function()
			if not WaitInterface("Stars") then
				return
			end

			module.Signal:FireSelf("Interface", "Stars", "Resume", v6)
		end)
	end

	if v7 then
		task.spawn(function()
			if not WaitInterface(v7.System) then
				return
			end

			module.Signal:FireSelf("Interface", v7.System, "Resume", v7.Target)
		end)
	end
end

script.Destroying:Connect(AutoRoll.Destroy)
return AutoRoll