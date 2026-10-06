local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local EffectPlayer = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("EffectPlayer"))
local EventEffects = {}
EventEffects.__index = EventEffects

function EventEffects.new(ctx)
	local self = setmetatable({}, EventEffects)
	self._ctx = ctx
	return self
end

function EventEffects:_worldFromArena(point: Vector2, value: number?)
	local _ctx = self._ctx
	return _ctx.arenaCFrame:PointToWorldSpace((Vector3.new(
		point.X * _ctx.arenaScale,
		point.Y * _ctx.arenaScale,
		-(value or 0) * _ctx.arenaScale
	)))
end

function EventEffects:_arenaFromWorld(vector: Vector3)
	local _ctx = self._ctx
	local pointToObjectSpace = _ctx.arenaCFrame:PointToObjectSpace(vector)
	return Vector2.new(pointToObjectSpace.X / _ctx.arenaScale, pointToObjectSpace.Y / _ctx.arenaScale)
end

function EventEffects:spawnLine(vector: Vector3, vector2: Vector3, color: Color3, p2: number, duration: number)
	local _ctx = self._ctx
	local magnitude = (vector2 - vector).Magnitude

	if magnitude < 0.05 then
		return
	end

	local part = Instance.new("Part")
	part.Name = "ImpactLine"
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.05
	part.Size = Vector3.new(p2 * _ctx.arenaScale, p2 * _ctx.arenaScale, magnitude)
	part.CFrame = CFrame.lookAt((vector + vector2) * 0.5, vector2)
	part.Parent = _ctx.rootFolder
	TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new(p2 * 0.6 * _ctx.arenaScale, p2 * 0.6 * _ctx.arenaScale, magnitude)
	}):Play()
	Debris:AddItem(part, duration + 0.05)
end

function EventEffects:spawnValueFloat(childName: string, point: Vector2, text: string?, data)
	local _ctx = self._ctx
	local part = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("身份标识模板"):WaitForChild(childName)
	assert(part:IsA("BasePart"), string.format("飘字模板必须是 BasePart：%s", childName))
	local clone = part:Clone()
	clone.Name = string.format("%s飘字", childName)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Massless = true
	clone.CastShadow = false
	clone.Position = self:_worldFromArena(point, data.worldHeight)
	clone.Parent = _ctx.rootFolder
	local UI = clone:WaitForChild("效果UI")
	assert(UI:IsA("BillboardGui"), string.format("飘字模板缺少 BillboardGui：%s.效果UI", childName))
	local label = UI:WaitForChild("血量字")
	assert(label:IsA("TextLabel"), string.format("飘字模板缺少 TextLabel：%s.效果UI.血量字", childName))

	if text then
		label.Text = text
	end

	local duration = data.duration
	local fadeOutDuration = data.fadeOutDuration
	TweenService:Create(UI, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffset = UI.StudsOffset + Vector3.new(0, data.floatUpDistance * _ctx.arenaScale, 0)
	}):Play()
	local tweenInfo = TweenInfo.new(fadeOutDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, duration)

	for _, descendant in ipairs(UI:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			TweenService:Create(descendant, tweenInfo, {
				BackgroundTransparency = 1,
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			TweenService:Create(descendant, tweenInfo, {
				BackgroundTransparency = 1,
				ImageTransparency = 1
			}):Play()
		elseif descendant:IsA("UIStroke") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		elseif descendant:IsA("GuiObject") then
			TweenService:Create(descendant, tweenInfo, {
				BackgroundTransparency = 1
			}):Play()
		end
	end

	Debris:AddItem(clone, duration + fadeOutDuration + 0.08)
end

function EventEffects:spawnDamageNumberGravity(point: Vector2, text: string, data)
	local _ctx = self._ctx
	local part = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("身份标识模板"):WaitForChild("扣血方块")
	assert(part:IsA("BasePart"), string.format("飘字模板必须是 BasePart：%s", "扣血方块"))
	local clone = part:Clone()
	clone.Name = string.format("%s飘字", "扣血方块")
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Massless = true
	clone.CastShadow = false
	clone.Position = self:_worldFromArena(point, data.worldHeight)
	clone.Parent = _ctx.rootFolder
	local UI = clone:WaitForChild("效果UI")
	assert(UI:IsA("BillboardGui"), string.format("飘字模板缺少 BillboardGui：%s.效果UI", "扣血方块"))
	local label = UI:WaitForChild("血量字")
	assert(label:IsA("TextLabel"), string.format("飘字模板缺少 TextLabel：%s.效果UI.血量字", "扣血方块"))
	label.Text = text
	local duration = data.duration
	local v = math.min(data.fadeOutDuration, duration)
	local arenaScale = _ctx.arenaScale
	local v2 = (math.random() * 2 - 1) * data.horizontalSpeed * arenaScale
	local v3 = data.riseSpeed * arenaScale
	local v4 = data.gravity * arenaScale
	local studsOffset = UI.StudsOffset
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if duration <= total or UI.Parent == nil then
			heartbeatConnection:Disconnect()
		else
			UI.StudsOffset = studsOffset + Vector3.new(v2 * total, v3 * total - 0.5 * v4 * total * total, 0)
		end
	end)
	local tweenInfo = TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, duration - v)

	for _, descendant in ipairs(UI:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			TweenService:Create(descendant, tweenInfo, {
				BackgroundTransparency = 1,
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			TweenService:Create(descendant, tweenInfo, {
				BackgroundTransparency = 1,
				ImageTransparency = 1
			}):Play()
		elseif descendant:IsA("UIStroke") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		elseif descendant:IsA("GuiObject") then
			TweenService:Create(descendant, tweenInfo, {
				BackgroundTransparency = 1
			}):Play()
		end
	end

	Debris:AddItem(clone, duration + 0.08)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatFloatValue(p: number)
	if p == math.floor(p) then
		return string.format("%d", p)
	end

	return string.format("%.1f", p)
end

function EventEffects:spawnDamageNumber(data)
	local _ctx = self._ctx

	if not data.damage then
		return
	end

	local damageFloat = _ctx.config.visual.damageFloat
	local targetBallId = data.targetBallId or data.ballId
	local v = targetBallId and _ctx.ballParts[targetBallId]
	local position = data.position

	if v then
		position = self:_arenaFromWorld(v.Position)
	end

	if not position then
		return
	end

	local v3 = formatFloatValue(data.damage) -- equivalent call inferred; original call site unknown
	self:spawnDamageNumberGravity(position, "-" .. v3, damageFloat)

	if targetBallId and v and _ctx.onHitFlash then
		_ctx.onHitFlash(targetBallId)
	end
end

function EventEffects:spawnHealNumber(p)
	local _ctx = self._ctx

	if not (p.heal and p.sourceBallId) then
		return
	end

	local ballPart = _ctx.ballParts[p.sourceBallId]

	if not ballPart then
		return
	end

	local vector = Vector2.new(self:_arenaFromWorld(ballPart.Position).X, self:_arenaFromWorld(ballPart.Position).Y)
	local v3 = formatFloatValue(p.heal) -- equivalent call inferred; original call site unknown
	self:spawnValueFloat("补血方块", vector, "+" .. v3, _ctx.config.visual.healFloat)
end

function EventEffects:spawnThomasUpgradeFloat(p)
	local _ctx = self._ctx

	if not p.position then
		return
	end

	self:spawnValueFloat("升级方块", p.position, nil, _ctx.config.visual.healFloat)
end

function EventEffects:_bindEffectToBall(instance, instance2)
	local rotation = instance:GetPivot().Rotation
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if instance.Parent == nil or instance2.Parent == nil then
			heartbeatConnection:Disconnect()
		else
			instance:PivotTo(CFrame.new(instance2.Position) * rotation)
		end
	end)
end

function EventEffects:playOneShotModelEffect(childName: string, point: Vector2?, p: number?, p2: string?, p3: number?)
	local _ctx = self._ctx
	local v = p2 and _ctx.ballParts[p2]

	if not (point or v) then
		return
	end

	local model = _ctx.effectAssetRoot:FindFirstChild(childName)

	if not (model and model:IsA("Model")) then
		warn(string.format("[EventEffects] 一次性特效素材缺失：%s", childName))
		return
	end

	local position

	if v then
		position = v.Position
	else
		position = self:_worldFromArena(point, p or _ctx.config.visual.ballHeight)
	end

	local clone = model:Clone()

	if p3 then
		for _, sound in clone:GetDescendants() do
			if sound:IsA("Sound") then
				sound.PlaybackSpeed *= p3
			end
		end
	end

	clone.Parent = _ctx.rootFolder
	EffectPlayer.play(clone, CFrame.new(position) * _ctx.effectArenaRotation * model:GetPivot().Rotation)

	if v then
		self:_bindEffectToBall(clone, v)
	end
end

function EventEffects:playBladeHit(p)
	local _ctx = self._ctx

	if not p.position then
		return
	end

	local _worldFromArena = self:_worldFromArena(p.position, 2.1)
	_ctx._audio:playCue("bladeHit", _worldFromArena)
end

function EventEffects:playBladeGrowth(p2)
	local _ctx = self._ctx

	if not p2.ballId then
		return
	end

	local ballPart = _ctx.ballParts[p2.ballId]

	if not ballPart then
		return
	end

	_ctx._audio:playCue("bladeGrowth", ballPart.Position)
end

function EventEffects:playChargeGain(p2)
	local _ctx = self._ctx

	if not p2.ballId then
		return
	end

	local ballPart = _ctx.ballParts[p2.ballId]

	if not ballPart then
		return
	end

	_ctx._audio:playCue("chargeGain", ballPart.Position)
end

function EventEffects:playChargeRelease(p2)
	local _ctx = self._ctx

	if not p2.ballId then
		return
	end

	local ballPart = _ctx.ballParts[p2.ballId]

	if not ballPart then
		return
	end

	_ctx._audio:playCue("chargeRelease", ballPart.Position)
end

function EventEffects:playSpiderWebHit(p)
	local _ctx = self._ctx

	if not p.position then
		return
	end

	local _worldFromArena = self:_worldFromArena(p.position, _ctx.config.visual.spiderWebHeight)
	_ctx._audio:playCue("spiderWebHit", _worldFromArena)
end

function EventEffects:playZoneTick(p)
	local _ctx = self._ctx

	if not p.position then
		return
	end

	local _worldFromArena = self:_worldFromArena(p.position, _ctx.config.visual.zoneLineHeight * 0.8)
	_ctx._audio:playCue("zoneTick", _worldFromArena)
end

function EventEffects:playPoisonSpikeCreated(p)
	local _ctx = self._ctx

	if not p.position then
		return
	end

	local _worldFromArena = self:_worldFromArena(p.position)
	_ctx._audio:playCue("poisonSpikeCreate", _worldFromArena)
end

function EventEffects:playPoisonSpikeHit(data)
	local _ctx = self._ctx
	local targetBallId = data.targetBallId or data.ballId
	local v = targetBallId and _ctx.ballParts[targetBallId]
	local v2 = v and self:_arenaFromWorld(v.Position) or data.position

	if not v2 then
		return
	end

	local _worldFromArena = self:_worldFromArena(v2, _ctx.config.visual.ballHeight)
	_ctx._audio:playCue("poisonSpikeHit", _worldFromArena)
end

return EventEffects