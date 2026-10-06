local module = require("@game/ReplicatedStorage/Omni")
local v = 0
local v2 = 0
local v3 = false
local v4 = false
local v5 = nil
local Combat = {
	UpdateHitboxes = function()
		module.Libs.Hittox.SetDebugModeEnabled(module.Data.Settings.Hitboxes == true)
	end,
	Attack = function()
		module.Signal:Fire("General", "Combat", "PlayerAttack")
	end,
	UpdateAutoClick = function()
		v4 = module.Data.Settings["Auto Clicker"] == true
	end,
	UpdateAutoAttack = function()
		v3 = module.Data.Settings["Auto Attack"] == true
	end,
	Hitted = function(hit: number, weapon: string, time: number)
		v5 = {
			Hit = hit,
			Time = time,
			Weapon = weapon
		}
		local v6 = module.Data.Weapons.List[weapon]

		if not v6 then
			return
		end

		local v7 = module.Shared.Weapons.List[v6.Name]
		local character = module.Instance.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if v7 and humanoidRootPart then
			module.Scripts.Rendering.Combat.Hit(module.Instance, v7.CombatSound, hit, humanoidRootPart, weapon)
		end

		local animate = module:GetAnimate()

		if not animate then
			return
		end

		local weaponHitAnimation = module.Utils.Weapons.GetWeaponHitAnimation(v6.Name, hit)

		if not weaponHitAnimation then
			return
		end

		local v8 = animate:PlayAnimation({
			Animation = weaponHitAnimation,
			Priority = Enum.AnimationPriority.Action4,
			Looped = false
		})
		local v9 = v7 and v7.Hits[hit]

		if v8 and v9 and v9.Delay then
			v8:AdjustSpeed(module.Shared.Weapons.GetSolvedHit(hit, v6, module.Data).AnimationSpeed)
		end
	end
}

function Combat.Init()
	module:OnDataChanged({ "Settings" }, function()
		Combat.UpdateHitboxes()
		Combat.UpdateAutoClick()
		Combat.UpdateAutoAttack()
	end)
	module.Services.UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonR2 then
			Combat.Attack()
		end
	end)
	module.Services.RunService.Heartbeat:Connect(function()
		local serverTimeNow = workspace:GetServerTimeNow()

		if serverTimeNow - v >= 0.1 then
			v = serverTimeNow

			if v4 then
				local equipped = module.Data.Weapons.Equipped
				local v6 = equipped and module.Data.Weapons.List[equipped]
				local v7 = v6 and module.Shared.Weapons.List[v6.Name]

				if v7 then
					local v8 = v5

					if v8 and v8.Weapon ~= equipped then
						v8 = nil
					end

					local flag = false

					if v8 and v7.Hits[v8.Hit] then
						local v9 = serverTimeNow - v8.Time
						local solvedHit = module.Shared.Weapons.GetSolvedHit(v8.Hit, v6, module.Data)

						if solvedHit.Cooldown < v9 then
							flag = true

							if v8.Hit < #v7.Hits then
								if v7.ComboTime and solvedHit.Cooldown + v7.ComboTime < v9 then
									v8.Hit = 1
								else
									v8.Hit += 1
								end
							else
								v8.Hit = 1
							end
						end
					else
						local _ = {
							Hit = 1,
							Weapon = equipped,
							Time = serverTimeNow
						}
						flag = true
					end

					if flag then
						Combat.Attack()
					end
				end
			end
		end

		if serverTimeNow - v2 >= 1 then
			v2 = serverTimeNow
			local HRP = v3 and module:GetHRP()

			if HRP then
				local fighterTargets = module.Utils.PlayerStats.GetFighterTargets(module.Data, module.Instance)
				local v6 = {}

				for k, fighterTarget in fighterTargets do
					if fighterTarget == "" then
						table.insert(v6, k)
					end
				end

				if #v6 > 0 then
					local autoAttackRange = module.Utils.PlayerStats.AutoAttackRange(module.Data, module.Instance)
					local v7 = module.Utils.Enemies.GetEnemiesInRange(HRP.Position, autoAttackRange)[1]

					if v7 then
						if module.Data.Settings["Send All Fighters"] then
							module.Signal:Invoke("General", "Combat", "FighterAttack", v7.ID, v6)
						else
							module.Signal:Invoke("General", "Combat", "FighterAttack", v7.ID, { v6[1] })
						end
					end
				end
			end
		end
	end)
	Combat.UpdateHitboxes()
	Combat.UpdateAutoClick()
	Combat.UpdateAutoAttack()
end

return Combat