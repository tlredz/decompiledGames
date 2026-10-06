local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TemplateLibrary = require(script.Parent.TemplateLibrary)
local EffectPlayer = require(ReplicatedStorage2.Engine.Service.EffectPlayer)
local TraitVisualVerityForms = {}
TraitVisualVerityForms.__index = TraitVisualVerityForms

function TraitVisualVerityForms.new(renderer)
	return (setmetatable({
		renderer = renderer,
		bundles = {},
		playedStart = {},
		playedStage = {},
		effects = {}
	}, TraitVisualVerityForms))
end

function TraitVisualVerityForms.getBundle(p, p2)
	local verityForms = p2.traits and p2.traits.VerityForms

	if not verityForms or verityForms.stage == 1 then
		return p.renderer.ballTemplateBundles[p2.roleId], 1
	end

	local verityForm = p.renderer.config.traits.VerityForms["stage" .. verityForms.stage .. "Model"]
	local bundle = p.bundles[verityForm]

	if not bundle then
		bundle = TemplateLibrary.getTemplateBundle(p.renderer.effectAssetRoot, verityForm)
		p.bundles[verityForm] = bundle
	end

	return bundle, verityForms.stage
end

function TraitVisualVerityForms:track(instance, p2)
	self.effects[instance] = p2 or true
	instance.Destroying:Once(function()
		self.effects[instance] = nil
	end)
end

function TraitVisualVerityForms.update(p, p2)
	for k, effect in p.effects do
		if typeof(effect) ~= "string" then
			continue
		end

		local v = p2[effect]

		if v and not (v.hp <= 0) then
			if k.Parent then
				k:PivotTo(p.renderer:_getArenaBallCFrame(p.renderer:_worldFromArena(v.position)))
			end
		else
			k:Destroy()
		end
	end
end

function TraitVisualVerityForms:playEvent(data)
	local renderer = self.renderer

	if data.type == "verity_start" then
		if self.playedStart[data.ballId] then
			return
		end

		self.playedStart[data.ballId] = true
		local ballTemplateBundle = renderer.ballTemplateBundles[data.roleId]
		local sound = ballTemplateBundle and ballTemplateBundle.root:FindFirstChild("开局音效")

		if not (sound and sound:IsA("Sound")) then
			return
		end

		local part = Instance.new("Part")
		part.Name = data.ballId .. "_VerityStartSound"
		part.Size = createVector(0.01, 0.01, 0.01)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Position = renderer:_worldFromArena(data.position)
		part.Parent = renderer.rootFolder
		local clone = sound:Clone()
		clone.Looped = false
		clone.Parent = part
		self:track(part)
		clone.Ended:Once(function()
			part:Destroy()
		end)
		DuelAudioController.prepare(clone)
		clone:Play()
		Debris:AddItem(part, (math.max(30, clone.TimeLength / math.max(clone.PlaybackSpeed, 0.01) + 5)))
	elseif data.type == "verity_transform" then
		if data.stage <= (self.playedStage[data.ballId] or 1) then
			return
		end

		self.playedStage[data.ballId] = data.stage
		local model = renderer.effectAssetRoot:FindFirstChild(data.effectName)
		assert(model and model:IsA("Model"), "[VerityVisual] 缺少变身特效: " .. tostring(data.effectName))
		local clone = model:Clone()
		clone.Name = data.ballId .. "_VerityTransform_" .. data.stage
		local part = clone:FindFirstChild("碰撞箱")
		assert(part and part:IsA("BasePart"), "[VerityVisual] 变身特效缺少碰撞箱")
		clone.PrimaryPart = part

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = false
			elseif descendant:IsA("ParticleEmitter") then
				descendant.LockedToPart = true
			end
		end

		clone.Parent = renderer.rootFolder
		self:track(clone, data.ballId)
		local v = renderer._latestBallStates and renderer._latestBallStates[data.ballId]
		EffectPlayer.play(
			clone,
			renderer:_getArenaBallCFrame(renderer:_worldFromArena(v and v.position or data.position))
		)
	end
end

function TraitVisualVerityForms.reset(data)
	for k in data.effects do
		k:Destroy()
	end

	table.clear(data.effects)
	table.clear(data.playedStart)
	table.clear(data.playedStage)
end

return TraitVisualVerityForms