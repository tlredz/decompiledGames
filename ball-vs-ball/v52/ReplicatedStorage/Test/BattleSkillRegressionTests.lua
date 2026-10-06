local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BattleSkills = require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("BattleSkills"))
local BattleSimulation = require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("BattleSimulation"))

-- equivalent calls inferred from this helper; original call sites unknown
local function approximately(p: number, p2: number)
	return math.abs(p - p2) <= 1e-6
end

local function testShield()
	local v = {
		config = {
			traits = {
				Shield = {
					charges = 1
				}
			}
		}
	}
	local v2 = {
		traits = {}
	}
	BattleSkills.Shield.initialize(v, v2, "Shield")
	assert(v2.traits.Shield.remainingCharges == 1, "护盾必须按配置获得初始层数")
	assert(BattleSkills.Shield.modifyIncomingDamage(v, v2, 10, "Shield") == 0, "护盾必须抵消首次正数伤害")
	assert(v2.traits.Shield.remainingCharges == 0, "抵消伤害后必须消耗一层护盾")
	assert(BattleSkills.Shield.modifyIncomingDamage(v, v2, 10, "Shield") == 10, "护盾耗尽后必须正常受伤")
	BattleSkills.Shield.initialize(v, v2, "Shield")
	assert(BattleSkills.Shield.modifyIncomingDamage(v, v2, 0, "Shield") == 0, "零伤害必须保持为零")
	assert(v2.traits.Shield.remainingCharges == 1, "零伤害不得消耗护盾")
end

local function testSnakeTail()
	local blue = {
		id = "Blue",
		direction = Vector2.new(1, 0),
		traits = {},
		currentSpeed = 0
	}
	local yellow = {
		id = "Yellow",
		position = Vector2.new(0, 0),
		direction = Vector2.new(-1, 0),
		radius = 1,
		hp = 100,
		traits = {}
	}
	local v3 = {
		config = {
			traits = {
				SnakeTail = {
					maxTailSegments = 12,
					startingFullyGrownSegments = 2,
					tailBaseDamage = 5,
					tailHitCooldown = 0.35,
					initialGrowthThreshold = 2,
					growthThresholdIncrement = 1,
					incompleteMinScale = 0.25,
					tailEndFullScale = 0.5
				}
			}
		},
		state = {
			balls = {
				Blue = blue,
				Yellow = yellow
			}
		},
		multiEntityMode = false,
		_applyDamageModifiers = function(_, _, _, p)
			return p
		end,
		_pushBallAwayFromEffect = function(_, state, p, p2, p3)
			local v4 = state.position - p

			if v4.Magnitude < 0.001 then
				v4 = p3
			end

			local unit = v4.Unit
			state.position = p + unit * (p2 + state.radius + 0.01)
			state.direction = unit
			return unit
		end,
		_refreshSnakeTail = function(_, _) end,
		_onDamageDealt = function(_, _, _, _, _) end
	}
	BattleSkills.SnakeTail.initialize(v3, blue, "SnakeTail")
	local snakeTail = blue.traits.SnakeTail
	assert(#snakeTail.tailSegments == 2, "蛇球开局必须有两节完全成长尾巴")

	for k, tailSegment in snakeTail.tailSegments do
		tailSegment.position = Vector2.new(k * 0.1, 0)
		tailSegment.radius = 2
	end

	BattleSkills.SnakeTail.weaponHits(v3, blue, yellow, {}, "SnakeTail")
	assert(yellow.hp == 90, "两个尾节同帧命中必须各造成 5 点伤害")
	local v4

	if #snakeTail.tailSegments == 3 then
		v4 = snakeTail.tailSegments[3].isFullyGrown
	else
		v4 = false
	end

	assert(v4, "首次两次有效尾击必须完成第 3 节尾巴")
	local v5

	if snakeTail.growthThreshold == 3 then
		v5 = snakeTail.growthCharge == 0
	else
		v5 = false
	end

	assert(v5, "完成尾节后门槛必须递增并清空充能")
	assert(snakeTail.tailSegments[1].hitCooldownByTarget.Yellow == 0.35, "每个尾节必须独立记录同目标冷却")
	assert(snakeTail.tailSegments[2].hitCooldownByTarget.Yellow == 0.35, "第二尾节必须独立记录同目标冷却")
end

local function testExecute()
	local v = {
		config = {
			traits = {
				Execute = {
					hpThreshold = 0.2,
					damageMultiplier = 2
				}
			}
		}
	}
	local v2 = {
		traits = {
			Execute = {}
		}
	}
	local v3 = {
		hp = 20,
		maxHp = 100
	}
	assert(BattleSkills.Execute.modifyGlobalOutgoingDamage(v, v2, v3, 5, "Execute") == 5, "生命恰好 20% 时斩杀不得触发")
	v3.hp = 19
	assert(BattleSkills.Execute.modifyGlobalOutgoingDamage(v, v2, v3, 5, "Execute") == 10, "生命低于 20% 时斩杀必须翻倍")
	v3.maxHp = 0
	assert(BattleSkills.Execute.modifyGlobalOutgoingDamage(v, v2, v3, 5, "Execute") == 5, "最大生命异常时斩杀必须安全返回")
end

local function testStarBuffs()
	local v = {
		config = {
			traits = {
				DamageAmplification = {
					damageMultiplier = 1.2
				},
				StrongParalysis = {
					slowDuration = 1,
					slowMultiplier = 0
				},
				Gravity = {
					pullAcceleration = 24,
					maxPullSpeed = 8
				}
			}
		}
	}
	local v2 = {
		id = "Blue",
		team = "Blue",
		position = Vector2.new(0, 0),
		radius = 1,
		traits = {}
	}
	local v3 = {
		id = "Yellow",
		team = "Yellow",
		position = Vector2.new(5, 0),
		radius = 1,
		hp = 100,
		traits = {}
	}
	assert(
		BattleSkills.DamageAmplification.modifyGlobalOutgoingDamage(v, v2, v3, 5, "DamageAmplification") == 6,
		"伤害增强必须乘以全局伤害倍率"
	)

	function v._applySlow(p, p2, slowedByTraitId)
		p2.slowRemaining = p.config.traits[slowedByTraitId].slowDuration
		p2.slowedByTraitId = slowedByTraitId
	end

	BattleSkills.StrongParalysis.onCollisionResolved(v, v2, v3, {}, "StrongParalysis")
	local v4

	if v3.slowRemaining == 1 then
		v4 = v3.slowedByTraitId == "StrongParalysis"
	else
		v4 = false
	end

	assert(v4, "强力麻痹必须每次碰撞刷新一秒冻结")
	BattleSkills.Gravity.updateFrame(v, v2, v3, 0.25, {}, "Gravity")
	assert(v3.position == Vector2.new(5, 0), "引力不得直接改写目标位置")
	assert(v3.gravityVelocity == Vector2.new(-6, 0), "引力必须按加速度乘 dt 累积附加速度")
	BattleSkills.Gravity.updateFrame(v, v2, v3, 0.25, {}, "Gravity")
	assert(v3.gravityVelocity == Vector2.new(-8, 0), "引力附加速度必须受最大速度限制")
	v3.hookCapturedByBallId = "HookOwner"
	BattleSkills.Gravity.updateFrame(v, v2, v3, 1, {}, "Gravity")
	assert(v3.gravityVelocity == Vector2.new(-8, 0), "引力不得改写被钩爪完全控制目标的附加速度")
end

local function testKnockback()
	local v = {
		config = {
			traits = {
				Knockback = {
					duration = 0.5,
					speedMultiplier = 1.2
				}
			}
		},
		_activeTraitIds = BattleSimulation._activeTraitIds,
		_applyKnockback = BattleSimulation._applyKnockback
	}
	local v2 = {
		skill = {
			trigger = "Knockback"
		},
		secondaryTraitIds = {},
		currentSpeed = 10,
		knockbackRemaining = 0,
		knockbackPeakBonus = 0
	}
	local v3 = {
		skill = {
			trigger = "None"
		},
		secondaryTraitIds = {},
		currentSpeed = 4,
		knockbackRemaining = 0,
		knockbackPeakBonus = 0
	}
	v:_applyKnockback(v2, v3)
	local v4

	if v3.knockbackRemaining == 0.5 then
		v4 = approximately(v3.knockbackPeakBonus, 7.2)
	else
		v4 = false
	end

	assert(v4, "攻击方带击退特性时必须把追速差值放大 1.2 倍")
	v3.knockbackRemaining = 0
	v3.knockbackPeakBonus = 0
	v2.skill.trigger = "None"
	v:_applyKnockback(v2, v3)
	local v5

	if v3.knockbackRemaining == 0.5 then
		v5 = approximately(v3.knockbackPeakBonus, 6)
	else
		v5 = false
	end

	assert(v5, "默认碰撞必须让慢的一方完全追平对方速度")
	v:_applyKnockback(v3, v2)
	local v6

	if v2.knockbackRemaining == 0 then
		v6 = v2.knockbackPeakBonus == 0
	else
		v6 = false
	end

	assert(v6, "更快的一方不得获得追速加成")
	v3.knockbackRemaining = 0
	v3.knockbackPeakBonus = 0
	v3.currentSpeed = 0
	v:_applyKnockback(v2, v3)
	local v7

	if v3.knockbackRemaining == 0 then
		v7 = v3.knockbackPeakBonus == 0
	else
		v7 = false
	end

	assert(v7, "防守方完全静止时必须跳过击退，避免绕过控制效果")
	v3.currentSpeed = 4
	v:_applyKnockback(v2, v3, 40)
	assert(approximately(v3.knockbackPeakBonus, 36), "传入速度覆盖值时必须以该值计算追速差值")
end

return {
	run = function()
		testShield()
		testSnakeTail()
		testExecute()
		testStarBuffs()
		testKnockback()
		print("[BattleSkillRegressionTests] PASS：星级 Buff 与既有技能规则")
		return "BattleSkillRegressionTests: PASS"
	end
}