local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.AnimationLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
require(ReplicatedStorage.Modules.Utility)
return {
	{
		"Equip Cooldown",
		{ "EquipCooldown" },
		"Time"
	},
	{
		"Move Speed",
		{ "WalkSpeedMultiplier" },
		"Custom",
		function(_, p)
			if p == 1 then
				return "Normal"
			end

			return (p > 1 and "+" or "") .. math.floor((p - 1) * 100 + 0.5) .. "%"
		end
	},
	{
		"Double Jumps",
		{ "MaxDoubleJumps" }
	},
	{
		"Damage",
		{
			"ShootDamage",
			"BurnDamage",
			"AttackDamage",
			"Damage",
			"DirectHitDamage"
		},
		"Custom",
		function(p, p2)
			if p2 == 0 then
				return
			end

			local item = ItemLibrary.Items[p]
			local v

			if item.ShootPellets and item.ShootPellets > 1 then
				v = string.format("%.1fx%s", p2 / item.ShootPellets, item.ShootPellets) or p2
			else
				v = p2
			end

			local v2 = not item.RaycastDamageDropoffMultiplier and "" or item.ShootPellets and item.ShootPellets > 1 and string.format(
				"%.1fx%s",
				p2 / item.ShootPellets * item.RaycastDamageDropoffMultiplier,
				item.ShootPellets
			) or string.format("%.1f", p2 * item.RaycastDamageDropoffMultiplier) or ""
			return v .. (v2 == "" and v2 or " → " .. v2)
		end
	},
	{
		"Damage Dropoff Range",
		{ "RaycastDamageDropoffStartDistance" },
		"Custom",
		function(p, p2)
			return p2 .. "<font weight=\"600\" size=\"6\">studs</font> → " .. ItemLibrary.Items[p].RaycastDamageDropoffEndDistance .. "<font weight=\"600\" size=\"6\">studs</font>"
		end
	},
	{
		"Splash Radius",
		{ "ShootExplosionRadius" },
		"Custom",
		function(_, p)
			if p > 0 then
				return p
			end
		end
	},
	{
		"Damage Per Second",
		{ "DamagePerSecond" }
	},
	{
		"Afterburn Damage",
		{ "AfterburnDamage" }
	},
	{
		"Splash Damage",
		{ "SplashDamage" }
	},
	{
		"Explosion Damage",
		{ "ExplosionDamage" }
	},
	{
		"Critical Damage",
		{ "CriticalExplosionDamage" }
	},
	{
		"Explosion Radius",
		{ "ExplosionRadius" }
	},
	{
		"Cooldown",
		{ "ShootCooldown", "AttackCooldown", "Cooldown" },
		"Time"
	},
	{
		"Spread",
		{ "ShootSpread" },
		"Custom",
		function(_, p)
			if p > 0 then
				return string.format("%.1f°", p)
			end
		end
	},
	{
		"Aim Spread",
		{ "AimSpreadMultiplier" },
		"Custom",
		function(p, p2)
			if p2 > 0 then
				return string.format("%.1f°", ItemLibrary.Items[p].ShootSpread * p2)
			end
		end
	},
	{
		"Dynamic Spread",
		{ "ShootSpreadPerVelocityUnit" },
		"Custom",
		function(_, p)
			if p > 0 then
				return string.format("%0.2f°", p) .. "/studs/s"
			end
		end
	},
	{
		"Recoil",
		{ "ShootCameraDisplacementRecoil" },
		"Custom",
		function(_, p)
			if p.Magnitude > 0 then
				return string.format("%.0f%%", p.X / 25 * 100)
			end
		end
	},
	{
		"Aim Recoil",
		{ "ShootCameraDisplacementRecoilWhileAiming" },
		"Custom",
		function(_, p)
			if p.Magnitude > 0 then
				return string.format("%.0f%%", p.X / 25 * 100)
			end
		end
	},
	{
		"Bounces",
		{ "RaycastBounceCount" },
		"Custom",
		function(_, p)
			if p > 0 then
				return p
			end
		end
	},
	{
		"Burst",
		{ "BurstCount" },
		"Custom",
		function(_, p)
			if p > 1 then
				return p
			end
		end
	},
	{
		"Burst Delay",
		{ "BurstCooldown" },
		"Custom",
		function(_, p)
			if p > 0 then
				return string.format("%.2f", p) .. "s"
			end
		end
	},
	{
		"Fan Cooldown",
		{ "QuickShotCooldown" },
		"Time"
	},
	{
		"Attack Delay",
		{ "AttackDelay" },
		"Custom",
		function(_, p)
			if p > 0 then
				return string.format("%.2f", p) .. "s"
			end
		end
	},
	{
		"Reach",
		{ "Reach" }
	},
	{
		"Attack Reach",
		{ "AttackReach" }
	},
	{
		"Heavy Damage",
		{ "HeavyAttackDamage" }
	},
	{
		"Heavy Cooldown",
		{ "HeavyAttackCooldown" },
		"Time"
	},
	{
		"Heavy Reach",
		{ "HeavyAttackReach" }
	},
	{
		"Critical Damage",
		{ "CriticalDamage" },
		"Custom",
		function(p, p2)
			if p2 == 0 then
				return
			end

			local item = ItemLibrary.Items[p]
			local v

			if item.ShootPellets and item.ShootPellets > 1 then
				v = string.format("%.1fx%s", p2 / item.ShootPellets, item.ShootPellets) or p2
			else
				v = p2
			end

			local v2 = not item.RaycastDamageDropoffMultiplier and "" or item.ShootPellets and item.ShootPellets > 1 and string.format(
				"%.1fx%s",
				p2 / item.ShootPellets * item.RaycastDamageDropoffMultiplier,
				item.ShootPellets
			) or string.format("%.1f", p2 * item.RaycastDamageDropoffMultiplier) or ""
			return v .. (v2 == "" and v2 or " → " .. v2)
		end
	},
	{
		"Ammo",
		{ "MaxAmmo" },
		"Custom",
		function(p, p2)
			local v = (p == "Chainsaw" or p == "Flamethrower") and "∞" or (ItemLibrary.Items[p].MaxAmmoReserve or 0) > 0 and ItemLibrary.Items[p].MaxAmmoReserve or nil
			return (p2 >= 1e999 and "∞" or p2) .. (not v and "" or " <font weight=\"600\" size=\"9\">" .. v .. "</font>")
		end
	},
	{
		"Reload",
		{ "ReloadActionTimestamp" },
		"Time"
	},
	{
		"Empty Reload",
		{ "EmptyReloadActionTimestamp" },
		"Custom",
		function(p, p2)
			if math.abs(p2 - (ItemLibrary.Items[p].ReloadActionTimestamp or 0)) > 0.001 then
				return string.format("%.2fs", p2)
			end
		end
	},
	{
		"Reload",
		{ "ReloadType" },
		"Custom",
		function(_, p)
			if p == "Segmented" then
				return "Segmented"
			end
		end
	},
	{
		"Ability Speed Boost",
		{ "HoldSpeedBoostMax" },
		"Custom",
		function(_, p)
			return "+" .. math.floor(p * 100 + 0.5) .. "%"
		end
	},
	{
		"Ability Damage Per Second",
		{ "HoldDamageMultiplier" },
		"Custom",
		function(p, _)
			return ItemLibrary.Items[p].AttackDamage * ItemLibrary.Items[p].HoldDamageMultiplier
		end
	},
	{
		"Airblast Cooldown",
		{ "AirblastCooldown" },
		"Time"
	},
	{
		"Long Heal",
		{ "LongHeal", "Heal" }
	},
	{
		"Long Heal Time",
		{ "LongActionTimestamp" },
		"Time"
	},
	{
		"Quick Heal",
		{ "QuickHeal" }
	},
	{
		"Quick Heal Time",
		{ "QuickActionTimestamp" },
		"Time"
	},
	{
		"Fire Radius",
		{ "FireRadius" }
	},
	{
		"Fire Lifetime",
		{ "FireDuration" },
		"Time"
	},
	{
		"Blind Duration",
		{ "BlindDuration" },
		"Time"
	},
	{
		"Smoke Radius",
		{ "SmokeRadius" }
	},
	{
		"Smoke Lifetime",
		{ "SmokeDuration" },
		"Time"
	},
	{
		"Deflect Cooldown",
		{ "DeflectCooldown" },
		"Time"
	},
	{
		"Deflect Duration",
		{ "DeflectDuration" },
		"Time"
	},
	{
		"Blade Cooldown",
		{ "BladeCooldown" },
		"Time"
	},
	{
		"Blade Reach",
		{ "BladeReach" }
	},
	{
		"Blade Damage",
		{ "BladeDamage" }
	},
	{
		"Blade Critical Damage",
		{ "BladeCriticalDamage" }
	},
	{
		"Dash Cooldown",
		{ "DashCooldown" },
		"Time"
	},
	{
		"Build Cooldown",
		{ "BuildCooldown" },
		"Time"
	},
	{
		"Build Reach",
		{ "BuildReach" }
	},
	{
		"Max Bricks",
		{ "MaxBricks" }
	},
	{
		"Brick Lifetime",
		{ "BrickLifetime" },
		"Time"
	},
	{
		"Full Charge Time",
		{ "ChargeLevelTimestamps" },
		"Custom",
		function(_, list)
			return string.format("%.2fs", list[#list])
		end
	},
	{
		"Full Charge Damage",
		{ "ChargeLevelDamageMultipliers" },
		"Custom",
		function(p, list)
			return string.format("%.0f", ItemLibrary.Items[p].ShootDamage * list[#list])
		end
	},
	{
		"Charge Damage",
		{ "ChargeDamage" }
	},
	{
		"Charge Knockback",
		{ "ChargeKnockbackForce" }
	},
	{
		"Charge Time",
		{ "ChargeIntro" },
		"Time"
	},
	{
		"Detonate Delay",
		{ "DetonateDelay" },
		"Time"
	},
	{
		"Splash Radius",
		{ "SplashRadius" }
	},
	{
		"Speed Boost",
		{ "SpeedBoost" },
		"Custom",
		function(_, p)
			return "+" .. math.floor(p * 100 + 0.5) .. "%"
		end
	},
	{
		"Speed Duration",
		{ "SpeedBoostDuration" },
		"Time"
	},
	{
		"Spin Damage",
		{ "SpinDamage" }
	},
	{
		"Spin Radius",
		{ "SpinRadius" }
	},
	{
		"Spin Cooldown",
		{ "SpinCooldown" },
		"Time"
	},
	{
		"Charging Windup Time",
		{ "ChargingWindUpLength" },
		"Time"
	},
	{
		"Charging Move Speed",
		{ "ChargingSpeedBoost" },
		"Custom",
		function(_, p)
			if p == 0 then
				return "Normal"
			end

			return (p > 0 and "+" or "") .. math.floor(p * 100 + 0.5) .. "%"
		end
	},
	{
		"Vortex Cooldown",
		{ "VortexCooldown" },
		"Time"
	},
	{
		"Vortex Radius",
		{ "VortexRadius" }
	},
	{
		"Vortex Lifetime",
		{ "VortexLifetime" },
		"Time"
	},
	{
		"Knockback",
		{ "KnockbackForce" }
	},
	{
		"Slam Cooldown",
		{ "SlamCooldown" },
		"Time"
	},
	{
		"Slam Damage",
		{ "SlamDamage" }
	},
	{
		"Slam Radius",
		{ "SlamRadius" }
	},
	{
		"Minimum Slam Altitude",
		{ "SlamFloorDistance" },
		"Custom",
		function(_, p)
			return p .. "studs"
		end
	},
	{
		"Slow Duration",
		{ "SlowDuration" },
		"Time"
	},
	{
		"Slow",
		{ "SlowBoost" },
		"Custom",
		function(_, p)
			return math.floor(p * 100 + 0.5) .. "%"
		end
	},
	{
		"Max Slow",
		{ "MaxSlowBoost" },
		"Custom",
		function(_, p)
			return math.floor(p * 100 + 0.5) .. "%"
		end
	},
	{
		"Max Slow Stacks",
		{ "MaxSlowStacks" }
	},
	{
		"Max Freeze Duration",
		{ "MaxFreezeDuration" },
		"Time"
	},
	{
		"Freeze Duration",
		{ "FreezeDuration" },
		"Time"
	},
	{
		"Miss Cooldown",
		{ "MissedCooldown" },
		"Time"
	},
	{
		"Hook Speed",
		{ "HookSpeed" }
	},
	{
		"Hook Range",
		{ "HookRange" }
	},
	{
		"Pull Speed",
		{ "SelfPullForce" }
	},
	{
		"Enemy Pull Speed",
		{ "EnemyPullForce" }
	},
	{
		"Throw Cooldown",
		{ "ThrowCooldown" },
		"Time"
	},
	{
		"Throw Damage",
		{ "ThrowDamage" }
	},
	{
		"Critical Throw Damage",
		{ "CriticalThrowDamage" }
	},
	{
		"Throw Knockback",
		{ "ThrowKnockbackForce" }
	},
	{
		"Thrown Spear Length",
		{ "ThrownSpearLength" }
	},
	{
		"Thrown Spear Lifetime",
		{ "ThrownSpearLifetime" },
		"Time"
	},
	{
		"Grenade Cooldown",
		{ "GrenadeCooldown" },
		"Time"
	},
	{
		"Grenade Explosion Radius",
		{ "GrenadeExplosionRadius" }
	},
	{
		"Max Health",
		{ "MaxAbsorption" }
	},
	{
		"Damage Reduction",
		{ "AbsorptionPercent" },
		"Custom",
		function(_, p)
			return math.floor(p * 100 + 0.5) .. "%"
		end
	},
	{
		"Lifetime",
		{ "Lifetime" },
		"Time"
	}
}