local RunService = game:GetService("RunService")
require(game.ReplicatedStorage.Packages.Result)
local IdMap = require(game.ReplicatedStorage.IdMap)
local Stat = require(game.ReplicatedStorage.Definitions.Stat)
local Global = require(game.ReplicatedStorage.Global)
local isStudio = RunService:IsStudio()
return {
	solve = function(p: number, p2: number, p3: number, p4: number, _: number)
		local v = {}

		local function replace(object)
			local v2

			if Global.IsUnitTest or isStudio then
				v2 = object:unwrap()
			elseif object:isOk() then
				v2 = object:unwrap()
			else
				return
			end

			for i = #v, 1, -1 do
				local v3 = v[i]

				if not (v3.Index.StatType == v2.Index.StatType and v3.Index.Type == v2.Index.Type) then
					continue
				end

				if not (v3.Index.StatType ~= "Complex" or v2.Index.StatType ~= "Complex" or v2.Index.Variant == v3.Index.Variant) then
					continue
				end

				table.remove(v, i)
			end

			table.insert(v, v2)
		end

		local function add(object)
			if Global.IsUnitTest or isStudio then
				table.insert(v, object:unwrap())
			elseif object:isOk() then
				table.insert(v, object:unwrap())
			end
		end

		if p == IdMap.Race.Human then
			if p2 >= 2 and p2 < 4 then
				local solve = Stat.solve({
					StatType = "Simple",
					Type = "SpeedMultiplier"
				}, "*1.2")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve:unwrap())
				elseif solve:isOk() then
					table.insert(v, solve:unwrap())
				end

				local solve2 = Stat.solve({
					StatType = "Complex",
					Type = "Cooldown",
					Variant = "FlashStep"
				}, 10)

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve2:unwrap())
				elseif solve2:isOk() then
					table.insert(v, solve2:unwrap())
				end

				local solve3 = Stat.solve({
					StatType = "Simple",
					Type = "FlashStepRange"
				}, "*2")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve3:unwrap())
				elseif solve3:isOk() then
					table.insert(v, solve3:unwrap())
				end

				local solve4 = Stat.solve({
					StatType = "Complex",
					Type = "DashLength",
					Variant = "All"
				}, "+10")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve4:unwrap())
				elseif solve4:isOk() then
					table.insert(v, solve4:unwrap())
				end

				local solve5 = Stat.solve({
					StatType = "Complex",
					Type = "AllSpeed",
					Variant = "Melee"
				}, "*1.1")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve5:unwrap())
				elseif solve5:isOk() then
					table.insert(v, solve5:unwrap())
				end
			elseif p2 == 4 and p3 == 2 then
				local solve = Stat.solve({
					StatType = "Complex",
					Type = "DashLength",
					Variant = "All"
				}, "+10")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve:unwrap())
				elseif solve:isOk() then
					table.insert(v, solve:unwrap())
				end

				replace(Stat.solve({
					StatType = "Simple",
					Type = "SpeedMultiplier"
				}, "*1.2"))
				local solve2 = Stat.solve({
					StatType = "Simple",
					Type = "Unbreakable"
				}, true)

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve2:unwrap())
				elseif solve2:isOk() then
					table.insert(v, solve2:unwrap())
				end
			end
		elseif p == IdMap.Race.Draco then
			replace(Stat.solve({
				StatType = "Complex",
				Type = "AllResist",
				Variant = "All"
			}, 0.05))
			replace(Stat.solve({
				StatType = "Simple",
				Type = "Health"
			}, "*1.05"))
			replace(Stat.solve({
				StatType = "Complex",
				Type = "AllDamage",
				Variant = "Melee"
			}, 0.05))

			if p2 >= 2 then
				local solve = Stat.solve({
					StatType = "Complex",
					Type = "DashLength",
					Variant = "All"
				}, "+5")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve:unwrap())
				elseif solve:isOk() then
					table.insert(v, solve:unwrap())
				end
			end

			if p2 == 4 then
				replace(Stat.solve({
					StatType = "Complex",
					Type = "AllResist",
					Variant = "All"
				}, p3 * 0.15))
				replace(Stat.solve({
					StatType = "Complex",
					Type = "AllDamage",
					Variant = "All"
				}, 0.15))
			end
		elseif p == IdMap.Race.Rabbit then
			if p2 == 1 then
				replace(Stat.solve({
					StatType = "Simple",
					Type = "SpeedMultiplier"
				}, "*1.5"))
			elseif p2 == 2 then
				replace(Stat.solve({
					StatType = "Simple",
					Type = "SpeedMultiplier"
				}, "*2"))
				local solve = Stat.solve({
					StatType = "Complex",
					Type = "DashLength",
					Variant = "All"
				}, "+8")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve:unwrap())
				elseif solve:isOk() then
					table.insert(v, solve:unwrap())
				end

				replace(Stat.solve({
					StatType = "Simple",
					Type = "DashEfficiency"
				}, "*0.5"))
			elseif p2 == 3 then
				local solve = Stat.solve({
					StatType = "Complex",
					Type = "DashLength",
					Variant = "All"
				}, "+16")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve:unwrap())
				elseif solve:isOk() then
					table.insert(v, solve:unwrap())
				end

				replace(Stat.solve({
					StatType = "Simple",
					Type = "SpeedMultiplier"
				}, "*4"))
				replace(Stat.solve({
					StatType = "Simple",
					Type = "DashEfficiency"
				}, "*0.5"))
			elseif p2 == 4 then
				if p3 >= 1 then
					local solve = Stat.solve({
						StatType = "Complex",
						Type = "DashLength",
						Variant = "All"
					}, "+20")

					if Global.IsUnitTest or isStudio then
						table.insert(v, solve:unwrap())
					elseif solve:isOk() then
						table.insert(v, solve:unwrap())
					end

					replace(Stat.solve({
						StatType = "Simple",
						Type = "SpeedMultiplier"
					}, "*6"))
					replace(Stat.solve({
						StatType = "Simple",
						Type = "DashEfficiency"
					}, "*0.5"))
				else
					local solve = Stat.solve({
						StatType = "Complex",
						Type = "DashLength",
						Variant = "All"
					}, "+16")

					if Global.IsUnitTest or isStudio then
						table.insert(v, solve:unwrap())
					elseif solve:isOk() then
						table.insert(v, solve:unwrap())
					end

					replace(Stat.solve({
						StatType = "Simple",
						Type = "SpeedMultiplier"
					}, "*4"))
					replace(Stat.solve({
						StatType = "Simple",
						Type = "DashEfficiency"
					}, "*0.5"))
				end
			end
		elseif p == IdMap.Race.Angel then
			local solve = Stat.solve({
				StatType = "Simple",
				Type = "JumpHeight"
			}, "*1.25")

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve:unwrap())
			elseif solve:isOk() then
				table.insert(v, solve:unwrap())
			end

			if p2 == 2 then
				replace(Stat.solve({
					StatType = "Simple",
					Type = "AirJumpEfficiency"
				}, "*0.8"))
			end
		elseif p == IdMap.Race.Ghoul then
			local solve = Stat.solve({
				StatType = "Simple",
				Type = "HealthRegen"
			}, 0.2)

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve:unwrap())
			elseif solve:isOk() then
				table.insert(v, solve:unwrap())
			end

			local solve2 = Stat.solve({
				StatType = "Simple",
				Type = "SpeedMultiplier"
			}, "*1.3")

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve2:unwrap())
			elseif solve2:isOk() then
				table.insert(v, solve2:unwrap())
			end

			if p2 >= 2 and p2 <= 3 then
				if p2 < 4 then
					local solve3 = Stat.solve({
						StatType = "Complex",
						Type = "PvpLeech",
						Variant = "All"
					}, 0.25)

					if Global.IsUnitTest or isStudio then
						table.insert(v, solve3:unwrap())
					elseif solve3:isOk() then
						table.insert(v, solve3:unwrap())
					end

					local solve4 = Stat.solve({
						StatType = "Complex",
						Type = "PveLeech",
						Variant = "All"
					}, 0.05)

					if Global.IsUnitTest or isStudio then
						table.insert(v, solve4:unwrap())
					elseif solve4:isOk() then
						table.insert(v, solve4:unwrap())
					end
				else
					if p4 >= 1 then
						local solve3 = Stat.solve({
							StatType = "Complex",
							Type = "Cooldown",
							Variant = "All"
						}, 0.28125)

						if Global.IsUnitTest or isStudio then
							table.insert(v, solve3:unwrap())
						elseif solve3:isOk() then
							table.insert(v, solve3:unwrap())
						end
					end

					if p3 == 1 then
						local solve3 = Stat.solve({
							StatType = "Complex",
							Type = "PvpLeech",
							Variant = "All"
						}, 0.2)

						if Global.IsUnitTest or isStudio then
							table.insert(v, solve3:unwrap())
						elseif solve3:isOk() then
							table.insert(v, solve3:unwrap())
						end

						local solve4 = Stat.solve({
							StatType = "Complex",
							Type = "PveLeech",
							Variant = "All"
						}, 0.09000000000000001)

						if Global.IsUnitTest or isStudio then
							table.insert(v, solve4:unwrap())
						elseif solve4:isOk() then
							table.insert(v, solve4:unwrap())
						end
					elseif p3 == 2 then
						local solve3 = Stat.solve({
							StatType = "Complex",
							Type = "PvpLeech",
							Variant = "All"
						}, 0.3)

						if Global.IsUnitTest or isStudio then
							table.insert(v, solve3:unwrap())
						elseif solve3:isOk() then
							table.insert(v, solve3:unwrap())
						end

						local solve4 = Stat.solve({
							StatType = "Complex",
							Type = "PveLeech",
							Variant = "All"
						}, 0.135)

						if Global.IsUnitTest or isStudio then
							table.insert(v, solve4:unwrap())
						elseif solve4:isOk() then
							table.insert(v, solve4:unwrap())
						end
					end
				end
			end
		elseif p == IdMap.Race.Shark then
			if p2 == 1 then
				local solve = Stat.solve({
					StatType = "Simple",
					Type = "SeaDamageReduction"
				}, "*1.1")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve:unwrap())
				elseif solve:isOk() then
					table.insert(v, solve:unwrap())
				end
			else
				local solve = Stat.solve({
					StatType = "Simple",
					Type = "SeaDamageReduction"
				}, "*2")

				if Global.IsUnitTest or isStudio then
					table.insert(v, solve:unwrap())
				elseif solve:isOk() then
					table.insert(v, solve:unwrap())
				end
			end

			if p2 == 2 then
				replace(Stat.solve({
					StatType = "Simple",
					Type = "SpeedMultiplier"
				}, "*1.2"))
			end
		elseif p == IdMap.Race.Cyborg and p2 >= 2 then
			local solve = Stat.solve({
				StatType = "Complex",
				Type = "AllResist",
				Variant = "Melee"
			}, "*1.1")

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve:unwrap())
			elseif solve:isOk() then
				table.insert(v, solve:unwrap())
			end

			local solve2 = Stat.solve({
				StatType = "Complex",
				Type = "AllResist",
				Variant = "Sword"
			}, "*1.1")

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve2:unwrap())
			elseif solve2:isOk() then
				table.insert(v, solve2:unwrap())
			end

			local solve3 = Stat.solve({
				StatType = "Complex",
				Type = "AllResist",
				Variant = "Gun"
			}, "*1.1")

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve3:unwrap())
			elseif solve3:isOk() then
				table.insert(v, solve3:unwrap())
			end

			local solve4 = Stat.solve({
				StatType = "Simple",
				Type = "DamageToEnergy"
			}, 0.15)

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve4:unwrap())
			elseif solve4:isOk() then
				table.insert(v, solve4:unwrap())
			end
		end

		if p2 == 4 then
			local solve = Stat.solve({
				StatType = "Complex",
				Type = "AllDamage",
				Variant = "All"
			}, "*1.1")

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve:unwrap())
			elseif solve:isOk() then
				table.insert(v, solve:unwrap())
			end

			local solve2 = Stat.solve({
				StatType = "Simple",
				Type = "MaxStats"
			}, true)

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve2:unwrap())
			elseif solve2:isOk() then
				table.insert(v, solve2:unwrap())
			end

			local solve3 = Stat.solve({
				StatType = "Simple",
				Type = "Energy"
			}, "*1.1")

			if Global.IsUnitTest or isStudio then
				table.insert(v, solve3:unwrap())
			elseif solve3:isOk() then
				table.insert(v, solve3:unwrap())
			end
		end

		table.freeze(v)
		return v
	end
}