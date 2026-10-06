local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local BattleConfig = require(ReplicatedStorage2:WaitForChild("BattleDemo"):WaitForChild("BattleConfig"))
require(ReplicatedStorage2:WaitForChild("BattleDemo"):WaitForChild("BattleRenderer"):WaitForChild("RenderMath"))
local EffectPlayer = require(script.Parent:WaitForChild("EffectPlayer"))
local Config = require(script.Parent:WaitForChild("Config"))
local v = ReplicatedStorage2:WaitForChild("美术素材"):WaitForChild("爆炸特效")
local v2 = v:WaitForChild("默认_击杀特效")
local killDeathSettlement = BattleConfig.visual.killDeathSettlement
local child = v2:WaitForChild("默认_" .. killDeathSettlement.killEffectTemplateName)
local child2 = v2:WaitForChild("默认_" .. killDeathSettlement.deathEffectTemplateName)
local child3 = v2:WaitForChild("默认_" .. killDeathSettlement.jumpKillEffectTemplateName)
local duelSettlement = BattleConfig.visual.duelSettlement
local v3 = v2:WaitForChild("默认_爆炸特效")
local child4 = v2:WaitForChild("默认_" .. duelSettlement.jumpKillTrailTemplateName)

local function resolveSkinModel(p: string?, p2: string, p3)
	if not p then
		return p3
	end

	local v4 = Config.skin.byCnId[p]
	local assetName = v4 and v4.assetName

	if not assetName then
		warn(string.format("[BattleSettlementEffects] 找不到爆炸特效皮肤配置: %s", p))
		return p3
	end

	local child5 = v:FindFirstChild(assetName)

	if not child5 then
		warn(string.format("[BattleSettlementEffects] 找不到爆炸特效皮肤: %s", p))
		return p3
	end

	local model = child5:FindFirstChild(p .. "_" .. p2)

	if model and model:IsA("Model") then
		return model
	end

	warn(string.format("[BattleSettlementEffects] 皮肤 %s 缺少模型: %s", p, p2))
	return p3
end

local BattleSettlementEffects = {
	resolveSkinModel = resolveSkinModel
}
local cframe = CFrame.Angles(0, -1.5707963267948966, 0)

function BattleSettlementEffects.alignToArena(instance, position: Vector3, cframe2: CFrame?)
	if not cframe2 then
		return position
	end

	local v4 = cframe2.Rotation * cframe:Inverse()
	return CFrame.new(position) * v4 * instance:GetPivot().Rotation
end

function BattleSettlementEffects.killShake(list, cframe2: CFrame, position: Vector3?, callback, p: string?, p2, p3)
	local skinModel = resolveSkinModel(p, killDeathSettlement.killEffectTemplateName, child)

	if #list == 0 then
		if position then
			local clone = skinModel:Clone()
			DuelAudioController.bindRoot(clone, p2)
			clone.Parent = p3 or Workspace
			local play = EffectPlayer.play

			if cframe2 then
				local v4 = cframe2.Rotation * cframe:Inverse()
				position = CFrame.new(position) * v4 * skinModel:GetPivot().Rotation
			end

			play(clone, position)
		end

		task.delay(killDeathSettlement.ballKillShakeDuration, function()
			callback(nil)
		end)
		return {}
	else
		local count = #list
		local v4 = {}
		local result = {}

		for _, model in list do
			local clone = skinModel:Clone()
			DuelAudioController.bindRoot(clone, p2)
			clone.Parent = p3 or Workspace
			local play = EffectPlayer.play
			local position2 = model:GetPivot().Position

			if cframe2 then
				local v6 = cframe2.Rotation * cframe:Inverse()
				position2 = CFrame.new(position2) * v6 * skinModel:GetPivot().Rotation
			end

			play(clone, position2)
			local v6 = model
			table.insert(result, (EffectPlayer.playModule("结算击杀抖动", {
				model = model,
				arenaCFrame = cframe2,
				duration = killDeathSettlement.ballKillShakeDuration,
				amplitude = killDeathSettlement.ballKillShakeAmplitude,
				minFrequency = killDeathSettlement.ballKillShakeMinFrequency,
				maxFrequency = killDeathSettlement.ballKillShakeMaxFrequency,
				onComplete = function(vector2: Vector3)
					v4[v6] = vector2
					count -= 1

					if count <= 0 then
						callback(v4)
					end
				end
			})))
		end

		return result
	end
end

function BattleSettlementEffects.deathEffect(list, p, position: Vector3?, callback, p2: string?, p3, cframe2: CFrame?, p4)
	local skinModel = resolveSkinModel(p2, killDeathSettlement.deathEffectTemplateName, child2)

	if #list == 0 then
		if position then
			local clone = skinModel:Clone()
			DuelAudioController.bindRoot(clone, p3)
			clone.Parent = p4 or Workspace
			local play = EffectPlayer.play

			if cframe2 then
				local v4 = cframe2.Rotation * cframe:Inverse()
				position = CFrame.new(position) * v4 * skinModel:GetPivot().Rotation
			end

			play(clone, position)
		end
	else
		for _, v4 in list do
			local v5 = p and p[v4] or v4:GetPivot().Position
			v4:Destroy()
			local clone = skinModel:Clone()
			DuelAudioController.bindRoot(clone, p3)
			clone.Parent = p4 or Workspace
			local play = EffectPlayer.play

			if cframe2 then
				local v6 = cframe2.Rotation * cframe:Inverse()
				v5 = CFrame.new(v5) * v6 * skinModel:GetPivot().Rotation
			end

			play(clone, v5)
		end
	end

	callback()
end

function BattleSettlementEffects.jumpKillWindup(list, cframe2: CFrame, callback, p: string?, p2, p3)
	local skinModel = resolveSkinModel(p, killDeathSettlement.jumpKillEffectTemplateName, child3)

	if #list == 0 then
		task.delay(killDeathSettlement.jumpKillWindupDuration, callback)
		return
	end

	local v4 = createVector(0, 0, 0)

	for _, v5 in list do
		v4 += v5:GetPivot().Position
	end

	local v5 = v4 / #list
	local clone = skinModel:Clone()
	DuelAudioController.bindRoot(clone, p2)
	clone.Parent = p3 or Workspace
	EffectPlayer.play(clone, cframe2.Rotation + v5)
	task.delay(killDeathSettlement.jumpKillWindupDuration, callback)
end

local function muteSounds(folder)
	for _, sound in ipairs(folder:GetDescendants()) do
		if sound:IsA("Sound") then
			sound.Volume = 0
		end
	end
end

local function limitSoundRollOff(folder, soundRollOffMaxDistance: number)
	for _, sound in ipairs(folder:GetDescendants()) do
		if not sound:IsA("Sound") then
			continue
		end

		sound.RollOffMaxDistance = soundRollOffMaxDistance
		sound.RollOffMinDistance = math.min(sound.RollOffMinDistance, soundRollOffMaxDistance)
	end
end

function BattleSettlementEffects.flyAndImpact(instance, vector2: Vector3, callback, options)
	local v4 = options or {}
	local muted = v4.muted == true
	local soundRollOffMaxDistance = v4.soundRollOffMaxDistance
	local skinCnId = v4.skinCnId
	local soundGroup = v4.soundGroup
	local effectParent = v4.effectParent
	local flag = false
	local v5 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function trackHandle(p)
		if not flag then
			table.insert(v5, p)
		elseif p and p.destroy then
			p.destroy()
		end
	end

	local function beginFlight()
		if flag then
			return
		end

		local v6 = nil
		trackHandle(EffectPlayer.playModule("结算跳杀飞行", {
			model = instance,
			targetPosition = vector2,
			duration = v4.duration or duelSettlement.flightDuration,
			arcHeight = v4.arcHeight or duelSettlement.flightArcHeight,
			arcUpVector = v4.arcUpVector or createVector(0, 1, 0),
			cameraBulge = v4.cameraBulge or 0,
			bulgeVector = v4.bulgeVector or createVector(0, 0, 1),
			bezierX1 = v4.bezierX1 or duelSettlement.flightEaseBezierX1,
			bezierY1 = v4.bezierY1 or duelSettlement.flightEaseBezierY1,
			bezierX2 = v4.bezierX2 or duelSettlement.flightEaseBezierX2,
			bezierY2 = v4.bezierY2 or duelSettlement.flightEaseBezierY2,
			onComplete = function()
				if flag then
					return
				end

				if v6 then
					v6.destroy()
				end

				if v4.playImpactEffect == false then
					callback(0)
					return
				end

				local skinModel = resolveSkinModel(skinCnId, "爆炸特效", v3)
				local clone = skinModel:Clone()

				if muted then
					muteSounds(clone)
				end

				if soundRollOffMaxDistance then
					limitSoundRollOff(clone, soundRollOffMaxDistance)
				end

				DuelAudioController.bindRoot(clone, soundGroup)
				clone.Parent = effectParent or Workspace
				local playLive = EffectPlayer.playLive
				local v8 = vector2
				local arenaCFrame = v4.arenaCFrame

				if arenaCFrame then
					local v9 = arenaCFrame.Rotation * cframe:Inverse()
					v8 = CFrame.new(v8) * v9 * skinModel:GetPivot().Rotation
				end

				local v9 = playLive(clone, v8)
				Debris:AddItem(clone, v9)
				callback(v9)
			end
		})) -- equivalent call inferred; original call site unknown

		if v4.trail ~= false then
			v6 = EffectPlayer.playModule("结算跳杀拖尾", {
				soundGroup = soundGroup,
				parent = effectParent,
				template = resolveSkinModel(skinCnId, duelSettlement.jumpKillTrailTemplateName, child4),
				model = instance
			})
			trackHandle(v6) -- equivalent call inferred; original call site unknown
		end
	end

	if v4.startShake then
		local arenaCFrame = v4.arenaCFrame or instance:GetPivot()
		local skinModel = resolveSkinModel(skinCnId, killDeathSettlement.killEffectTemplateName, child)
		local clone = skinModel:Clone()

		if muted then
			muteSounds(clone)
		end

		if soundRollOffMaxDistance then
			limitSoundRollOff(clone, soundRollOffMaxDistance)
		end

		DuelAudioController.bindRoot(clone, soundGroup)
		clone.Parent = effectParent or Workspace
		local play = EffectPlayer.play
		local position = instance:GetPivot().Position
		local arenaCFrame2 = v4.arenaCFrame

		if arenaCFrame2 then
			local v6 = arenaCFrame2.Rotation * cframe:Inverse()
			position = CFrame.new(position) * v6 * skinModel:GetPivot().Rotation
		end

		play(clone, position)
		trackHandle(EffectPlayer.playModule("结算击杀抖动", {
			model = instance,
			arenaCFrame = arenaCFrame,
			duration = killDeathSettlement.ballKillShakeDuration,
			amplitude = killDeathSettlement.ballKillShakeAmplitude,
			minFrequency = killDeathSettlement.ballKillShakeMinFrequency,
			maxFrequency = killDeathSettlement.ballKillShakeMaxFrequency,
			onComplete = function()
				beginFlight()
			end
		})) -- equivalent call inferred; original call site unknown
	else
		beginFlight()
	end

	return {
		destroy = function()
			if flag then
				return
			end

			flag = true

			for _, v6 in v5 do
				if v6 and v6.destroy then
					v6.destroy()
				end
			end

			table.clear(v5)
		end
	}
end

return BattleSettlementEffects