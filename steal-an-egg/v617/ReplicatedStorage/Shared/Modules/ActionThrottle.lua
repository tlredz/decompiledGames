local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TokenBucket = require(ReplicatedStorage.Shared.Modules.TokenBucket)
local Log = require(ReplicatedStorage.Packages.Log)
local wrapped = Log.new():AtWarning():Wrap()
local t = require(ReplicatedStorage.Packages.t)

local function callerName()
	for i = 2, 8 do
		local v = debug.info(i, "s")

		if v == nil then
			break
		end

		local v2 = string.match(v, "([^%.]-)$") or ""

		if v2 ~= "" and v2 ~= "ActionThrottle" then
			return v2
		end
	end

	return ""
end

local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function watch(object, instance)
	if not object.watched[instance] then
		object.watched[instance] = true
		instance.Destroying:Connect(function()
			object:Clear(instance)
			object.watched[instance] = nil
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requireBucket(object, p: string?)
	t.strict(t.optional(t.string))(p)

	if p then
		assert(
			object.buckets[p] and p ~= "Global",
			string.format("no endpoint named '%s' is configured on this limiter", p)
		)
	end
end

local function charge(object, instance, p)
	local spend = TokenBucket.Spend(p, instance)

	if spend then
		return true
	end

	if spend and object.warns then
		warn(string.format(object.logFormat, "ENDPOINT_EXHAUSTED", instance.Name, instance.UserId, p.name))
	end

	if p.causesBan then
		object:Block(instance)
	end

	return false
end

local v2 = {
	Block = function(self, p, p2: number?)
		t.strict(t.instanceIsA("Player"))(p)
		t.strict(t.optional(t.number))(p2)
		local v3 = self.bannedUntil[p]
		local v4 = workspace:GetServerTimeNow() + (p2 or self.banSeconds)
		local bannedUntil = self.bannedUntil

		if v3 ~= nil then
			v4 = math.max(v4, v3)
		end

		bannedUntil[p] = v4

		if self.warns and v3 == nil then
			wrapped(string.format(self.logFormat, "BAN", p.Name, p.UserId, "Banned!"))
		end
	end,
	Unblock = function(p, p2)
		t.strict(t.instanceIsA("Player"))(p2)

		if p.bannedUntil[p2] then
			p.bannedUntil[p2] = nil
			return true
		end

		return
			false,
			wrapped((string.format(p.logFormat, "BAN", p2.Name, p2.UserId, "lifted a ban that was never applied")))
	end,
	IsBlocked = function(self, p2)
		t.strict(t.instanceIsA("Player"))(p2)
		local v3 = self.bannedUntil[p2]
		local v4

		if v3 == nil then
			v4 = false
		else
			v4 = v3 < workspace:GetServerTimeNow()
		end

		if v4 then
			self.bannedUntil[p2] = nil
		end

		return v3 ~= nil and not v4
	end,
	Clear = function(self, p2)
		local v3 = p2 and { p2 } or game.Players:GetPlayers()

		for _, v4 in ipairs(v3) do
			self.bannedUntil[v4] = nil

			for _, bucket in pairs(self.buckets) do
				TokenBucket.Forget(bucket, v4)
			end
		end
	end,
	Check = function(self, instance, p: string?)
		t.strict(t.instanceIsA("Player"))(instance)
		requireBucket(self, p) -- equivalent call inferred; original call site unknown
		watch(self, instance) -- equivalent call inferred; original call site unknown
		local v3 = p and self.buckets[p]
		local global = self.buckets.Global
		local UNAVAILABLE = nil

		if self.retired then
			UNAVAILABLE = v.Rejection.UNAVAILABLE
		elseif self:IsBlocked(instance) then
			UNAVAILABLE = v.Rejection.BLOCKED
		elseif v3 and not charge(self, instance, v3) or global and not charge(self, instance, global) then
			UNAVAILABLE = v.Rejection.BUSY
		end

		if UNAVAILABLE then
			return false, UNAVAILABLE
		end

		return true
	end
}
v = {
	Rejection = {
		BUSY = "You're doing that too fast!",
		BLOCKED = "You're on cooldown. Please try again later.",
		UNAVAILABLE = "Endpoint not permitted."
	},
	LogTemplates = {
		BAN = "[RATE LIMIT][%*] (%*): %*, %*: (%*)"
	},
	DefaultBlockSeconds = 60,
	DefaultLogging = true,
	Build = function(data)
		t.strict(t.table)(data)
		t.strict(t.optional(t.number))(data.BanLength)
		assert(data.Global or data.Endpoints, "a limiter needs at least one endpoint")
		local buckets = {}

		if data.Global then
			buckets.Global = TokenBucket.Build("Global", data.Global)
		end

		for k, v4 in pairs(data.Endpoints or {}) do
			assert(k ~= "Global", "the global endpoint is configured through Global")
			buckets[k] = TokenBucket.Build(k, v4)
		end

		assert(next(buckets) ~= nil, "a limiter needs at least one endpoint")
		local id = data.Id or callerName()
		local v4 = {
			retired = false,
			label = id,
			logFormat = string.format(v.LogTemplates.BAN, "%*", id, "%*", "%*", "%*"),
			warns = 0,
			buckets = 0,
			bannedUntil = 0,
			banSeconds = 0,
			watched = 0
		}
		local warns

		if data.Warn == nil then
			warns = v.DefaultLogging
		else
			warns = data.Warn
		end

		v4.warns = warns
		v4.buckets = buckets
		v4.bannedUntil = {}
		v4.banSeconds = data.BanLength or v.DefaultBlockSeconds
		v4.watched = {}
		return (setmetatable(v4, {
			__index = v2
		}))
	end,
	Once = function()
		return v.Build({
			BanLength = 1e999,
			Global = {
				MaximumTokens = 1
			}
		})
	end,
	AtRate = function(p: number, value: number?)
		assert(p > 0, "a per-second allowance needs a positive rate")
		t.strict(t.optional(t.number))(value)
		local v3 = {
			Interval = 1 / p,
			Tokens = 1
		}
		return v.Build({
			BanLength = v.DefaultBlockSeconds,
			Global = {
				Ban = false,
				MaximumTokens = value or 1,
				Refresh = { v3 }
			}
		})
	end
}
return (table.freeze(v))