local RunService = game:GetService("RunService")

local function isAttackMessage(p)
	return typeof(p) == "table" and p.kind == "BossAttack" and type(p.attack) == "string"
end

return {
	new = function(data)
		assert(#data.attacks > 0, "SummerBossEvent Attacks requires at least one attack")
		local v

		if data.attackDelaySeconds >= 0 then
			v = data.attackDelaySeconds < 1e999
		else
			v = false
		end

		assert(v, "SummerBossEvent attackDelaySeconds must be finite and non-negative")
		local attacksByName = {}

		for _, attack in data.attacks do
			assert(attack.name ~= "", "SummerBossEvent attacks require a non-empty name")
			assert(attack.durationSeconds > 0, (`SummerBossEvent attack '{attack.name}' requires a positive duration`))
			assert(attacksByName[attack.name] == nil, (`Duplicate SummerBossEvent attack '{attack.name}'`))
			attacksByName[attack.name] = attack
		end

		local flag = false
		local flag2 = false
		local flag3 = false
		local v2 = nil
		local v3 = nil
		local v4 = 0
		local v5 = 0
		local v6 = nil

		local function chooseNextAttackIndex()
			local count = #data.attacks

			if count == 1 or v6 == nil then
				return math.random(1, count)
			end

			local v7 = math.random(1, count - 1)

			if v6 <= v7 then
				return v7 + 1
			end

			return v7
		end

		return {
			start = function(p: number)
				assert(not flag3, "Cannot start a cleaned SummerBossEvent attack controller")
				assert(RunService:IsServer(), "SummerBossEvent attacks can only be started on the server")

				if flag then
					return
				end

				flag = true
				flag2 = true
				v5 = p
			end,
			stop = function()
				flag2 = false

				if v2 == nil then
					flag = false
				end
			end,
			update = function(p: number)
				if flag3 or not (flag and RunService:IsServer()) then
					return
				end

				local v7 = v2

				if v7 then
					local v8 = v3

					if not v8 then
						return
					end

					local v9 = math.max(0, p - v4)
					v7.updateServer(v9, v8, data.sendToClients)

					if v9 < v7.durationSeconds then
						return
					end

					v2 = nil
					v3 = nil

					if flag2 then
						v5 = p + data.attackDelaySeconds
					else
						flag = false
					end
				else
					if not flag2 then
						flag = false
						return
					end

					if p < v5 then
						return
					end

					local count = #data.attacks
					local v8

					if count == 1 or v6 == nil then
						v8 = math.random(1, count)
					else
						v8 = math.random(1, count - 1)

						if v6 <= v8 then
							v8 += 1
						end
					end

					local attack = data.attacks[v8]
					local zone = data.getZone(attack.name)

					if not zone then
						return
					end

					v6 = v8
					v2 = attack
					v3 = zone
					v4 = p
					attack.startServer(zone, data.sendToClients)
					attack.updateServer(0, zone, data.sendToClients)
				end
			end,
			handleServerEvent = function(p)
				if not (flag3 or RunService:IsServer()) then
					local v7

					if typeof(p) == "table" and p.kind == "BossAttack" then
						v7 = type(p.attack) == "string"
					else
						v7 = false
					end

					if v7 then
						local v8 = attacksByName[p.attack]

						if v8 then
							v8.handleServerEvent(p)
						end
					end
				end
			end,
			cleanup = function()
				if flag3 then
					return
				end

				flag3 = true
				flag = false
				flag2 = false
				v2 = nil
				v3 = nil

				for _, attack in data.attacks do
					attack.cleanup()
				end
			end
		}
	end
}