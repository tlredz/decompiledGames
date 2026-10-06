local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local TraitVisualChargedBow = {}
TraitVisualChargedBow.__index = TraitVisualChargedBow

function TraitVisualChargedBow.new(ctx)
	local self = setmetatable({}, TraitVisualChargedBow)
	self._ctx = ctx
	self._bowModels = {}
	self._bowSubModels = {}
	self._arrowModels = {}
	return self
end

function TraitVisualChargedBow:_drawStage(_, p2)
	local chargedBow = self._ctx.config.traits.ChargedBow

	if p2.phase ~= "Charging" then
		return "idle"
	end

	if (not ((chargedBow.chargeDuration or 0) > 0) and 0 or p2.chargeElapsed / chargedBow.chargeDuration or 0) >= (chargedBow.drawStageRatio or 0) then
		return "full"
	end

	return "drawing"
end

function TraitVisualChargedBow:update(p)
	local _ctx = self._ctx
	local chargedBow = p.traits.ChargedBow

	if not chargedBow then
		return
	end

	local ballPart = _ctx.getBallPart(p.id)

	if ballPart then
		local attachment = ballPart:FindFirstChild("朝向标记")

		if attachment and attachment:IsA("Attachment") then
			local _bowModel = self._bowModels[p.id]
			local _bowSubModel = self._bowSubModels[p.id]

			if not _bowModel then
				_bowModel = _ctx.cloneTemplateModel(_ctx.bowTemplateBundle, p.id .. "_ChargedBow")
				_bowModel.Parent = _ctx.rootFolder
				local firstChild = _bowModel:FindFirstChild("装饰")
				_bowSubModel = {
					idle = firstChild and firstChild:FindFirstChild("空弦"),
					drawing = firstChild and firstChild:FindFirstChild("拉弓"),
					full = firstChild and firstChild:FindFirstChild("满弓")
				}
				self._bowModels[p.id] = _bowModel
				self._bowSubModels[p.id] = _bowSubModel
			end

			_bowModel:PivotTo(attachment.WorldCFrame * _ctx.bowTemplateBundle.markerOffset:Inverse())
			local _drawStage = self:_drawStage(p, chargedBow)

			for k, folder in _bowSubModel do
				if not folder then
					continue
				end

				local v = k == _drawStage

				for _, part in ipairs(folder:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = v and 0 or 1
					end
				end

				if folder:IsA("BasePart") then
					folder.Transparency = v and 0 or 1
				end
			end
		end
	end

	self._arrowModels[p.id] = self._arrowModels[p.id] or {}
	local v = {}

	for _, v2 in chargedBow.arrows or {} do
		v[v2.arrowId] = true
		local v3 = self._arrowModels[p.id][v2.arrowId]

		if not v3 then
			v3 = _ctx.cloneTemplateModel(_ctx.arrowTemplateBundle, string.format("Arrow_%s_%d", p.id, v2.arrowId))
			v3.Parent = _ctx.rootFolder
			self._arrowModels[p.id][v2.arrowId] = v3
			local firstChild = v3:FindFirstChild("碰撞箱")
			local sound = firstChild and firstChild:FindFirstChild("音效")

			if sound and sound:IsA("Sound") then
				sound.TimePosition = 0
				DuelAudioController.prepare(sound)
				sound:Play()
			end
		end

		local worldFromArena = _ctx.worldFromArena(v2.position)
		local worldFromArena2 = _ctx.worldFromArena(v2.position + v2.direction)
		v3:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2) * _ctx.arrowTemplateBundle.markerOffset:Inverse())
		_ctx.setTemplateModelVisibility(v3, true)
	end

	for k, v2 in self._arrowModels[p.id] or {} do
		if v[k] then
			continue
		end

		v2:Destroy()
		self._arrowModels[p.id][k] = nil
	end
end

function TraitVisualChargedBow:playDrawStarted(p2: string)
	local _bowModel = self._bowModels[p2]

	if not _bowModel then
		return
	end

	local firstChild = _bowModel:FindFirstChild("碰撞箱")
	local sound = firstChild and firstChild:FindFirstChild("音效")

	if sound and sound:IsA("Sound") then
		sound.TimePosition = 0
		DuelAudioController.prepare(sound)
		sound:Play()
	end
end

function TraitVisualChargedBow:cleanupBall(p)
	local _bowModel = self._bowModels[p]

	if _bowModel then
		_bowModel:Destroy()
	end

	local _bowModels = self._bowModels
	local _bowSubModels = self._bowSubModels
	_bowModels[p] = nil
	_bowSubModels[p] = nil

	for _, v in self._arrowModels[p] or {} do
		v:Destroy()
	end

	self._arrowModels[p] = nil
end

function TraitVisualChargedBow:reset()
	local v = {}

	for k in self._bowModels do
		table.insert(v, k)
	end

	for k in self._arrowModels do
		if not self._bowModels[k] then
			table.insert(v, k)
		end
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualChargedBow