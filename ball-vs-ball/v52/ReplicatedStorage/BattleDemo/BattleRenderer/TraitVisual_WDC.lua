local TweenService = game:GetService("TweenService")
local TraitVisualWDC = {}
TraitVisualWDC.__index = TraitVisualWDC

-- equivalent calls inferred from this helper; original call sites unknown
local function configurePart(p)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
end

local function scaleModelToArena(folder, instance, X: number, Y: number)
	local v = X / 16.5
	local v2 = Y / 16.5
	local cFrame = instance.CFrame

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part ~= instance) then
			continue
		end

		local objectSpace = cFrame:ToObjectSpace(part.CFrame)
		local position = objectSpace.Position
		local vector = Vector3.new(position.X * v, position.Y, position.Z * v2)
		part.Size = Vector3.new(part.Size.X * v, part.Size.Y, part.Size.Z * v2)
		part.CFrame = cFrame * (objectSpace.Rotation + vector)
	end

	instance.Size = Vector3.new(instance.Size.X * v, instance.Size.Y, instance.Size.Z * v2)
end

function TraitVisualWDC.new(ctx)
	local self = setmetatable({}, TraitVisualWDC)
	self._ctx = ctx
	self.entries = {}
	return self
end

function TraitVisualWDC:_destroyEntry(p2: string)
	local entry = self.entries[p2]

	if not entry then
		return
	end

	for _, tween in entry.tweens do
		tween:Cancel()
	end

	if entry.model then
		entry.model:Destroy()
	end

	self.entries[p2] = nil
end

function TraitVisualWDC:_createEntry(p2)
	local wdcTemplateBundle = self._ctx.wdcTemplateBundle

	if not wdcTemplateBundle then
		return nil
	end

	local templateModel, root = self._ctx.cloneTemplateModel(wdcTemplateBundle, p2.id .. "_WDCBoard")
	configurePart(root) -- equivalent call inferred; original call site unknown
	root.Transparency = 1
	local parts = {}
	local texts = {}
	local firstChild = templateModel:FindFirstChild("装饰")
	local union = firstChild and firstChild:FindFirstChild("Union")

	if firstChild then
		for i = 1, 9 do
			local part = firstChild:FindFirstChild((tostring(i)))

			if not (part and part:IsA("BasePart")) then
				continue
			end

			configurePart(part) -- equivalent call inferred; original call site unknown
			part.Transparency = 1
			parts[i] = part
			local surfaceGui = part:FindFirstChild("SurfaceGui")
			local mainFrame = surfaceGui and surfaceGui:FindFirstChild("MainFrame")
			texts[i] = mainFrame and mainFrame:FindFirstChild("text")
		end

		if union and union:IsA("BasePart") then
			configurePart(union) -- equivalent call inferred; original call site unknown
			union.Transparency = 1
		end
	end

	local boardSize = self._ctx.boardSize()
	scaleModelToArena(templateModel, root, boardSize.X, boardSize.Y)
	templateModel:PivotTo(self._ctx.boardCFrame() * CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	) * CFrame.Angles(0, 1.5707963267948966, 0))
	local v2 = {
		model = templateModel,
		root = root,
		tweens = {},
		fading = false,
		cellParts = parts,
		cellLabels = texts,
		union = union
	}
	self.entries[p2.id] = v2

	if union then
		local tween = TweenService:Create(
			union,
			TweenInfo.new((math.max(0.01, self._ctx.config.boardFadeInDuration or 0.3))),
			{
				Transparency = 0
			}
		)
		table.insert(v2.tweens, tween)
		tween:Play()
	end

	return v2
end

function TraitVisualWDC:_refreshCellNumbers(p, p2)
	if not p2.cells then
		return
	end

	for k, cell in p2.cells do
		local cellLabel = p.cellLabels[k]

		if cellLabel then
			cellLabel.Text = tostring(cell.value)
		end
	end
end

function TraitVisualWDC:update(p)
	local WDC = p.traits and p.traits.WDC
	local entry = self.entries[p.id]

	if WDC and WDC.phase == "active" then
		local v = entry or self:_createEntry(p)

		if not v then
			return
		end

		self:_refreshCellNumbers(v, WDC)
	elseif entry and not entry.fading then
		entry.fading = true
		local boardFadeOutDuration = self._ctx.config.boardFadeOutDuration or 0.3

		if entry.union then
			local tween = TweenService:Create(entry.union, TweenInfo.new((math.max(0.01, boardFadeOutDuration))), {
				Transparency = 1
			})
			table.insert(entry.tweens, tween)
			tween:Play()
		end

		task.delay(boardFadeOutDuration, function()
			if self.entries[p.id] == entry then
				self:_destroyEntry(p.id)
			end
		end)
	end
end

function TraitVisualWDC:playCellHit(p2)
	local entry = self.entries[p2.ballId]

	if not entry then
		return
	end

	local cellPart = entry.cellParts[p2.cellIndex]

	if not cellPart then
		return
	end

	local cellFlashDuration = self._ctx.config.cellFlashDuration or 0.15
	cellPart.Transparency = 0.3
	local tween = TweenService:Create(cellPart, TweenInfo.new((math.max(0.01, cellFlashDuration))), {
		Transparency = 1
	})
	table.insert(entry.tweens, tween)
	tween:Play()
end

function TraitVisualWDC:cleanupBall(p: string)
	self:_destroyEntry(p)
end

function TraitVisualWDC:reset()
	for k in self.entries do
		self:_destroyEntry(k)
	end
end

function TraitVisualWDC:destroy()
	self:reset()
end

return TraitVisualWDC