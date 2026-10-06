local TweenService = game:GetService("TweenService")
local TraitVisualChessPath = {}
TraitVisualChessPath.__index = TraitVisualChessPath

-- equivalent calls inferred from this helper; original call sites unknown
local function configurePart(p)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fadePart(part, lineFadeOutDuration: number)
	return TweenService:Create(part, TweenInfo.new((math.max(0.01, lineFadeOutDuration))), {
		Transparency = 1
	})
end

function TraitVisualChessPath.new(ctx)
	local self = setmetatable({}, TraitVisualChessPath)
	self._ctx = ctx
	self.entries = {}
	return self
end

function TraitVisualChessPath:_destroyEntry(p2: string)
	local entry = self.entries[p2]

	if not entry then
		return
	end

	for _, tween in entry.tweens do
		tween:Cancel()
	end

	for _, instance in entry.instances do
		instance:Destroy()
	end

	self.entries[p2] = nil
end

function TraitVisualChessPath:_createLines(p2, p3)
	for _, v in p2.routeGroups or {} do
		for i = 1, #v - 1 do
			local v2 = v[i]
			local v3 = v[i + 1]
			local worldFromArena = self._ctx.worldFromArena(v2, 0.06)
			local worldFromArena2 = self._ctx.worldFromArena(v3, 0.06)
			local magnitude = (worldFromArena2 - worldFromArena).Magnitude

			if not (magnitude > 0.0001) then
				continue
			end

			local part = Instance.new("Part")
			part.Name = "ChessPathLine"
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 65, 65)
			part.Size = Vector3.new(0.08, 0.08, magnitude)
			part.Transparency = 1
			part.CFrame = CFrame.lookAt((worldFromArena + worldFromArena2) * 0.5, worldFromArena2, self._ctx.upVector())
			configurePart(part) -- equivalent call inferred; original call site unknown
			part.Parent = self._ctx.rootFolder
			table.insert(p3.instances, part)
			table.insert(
				p3.tweens,
				TweenService:Create(
					part,
					TweenInfo.new((math.max(0.01, self._ctx.config.lineFadeInDuration or 0.12))),
					{
						Transparency = 0.12
					}
				)
			)
		end
	end
end

function TraitVisualChessPath:_createEntry(p, p2)
	local v = {
		instances = {},
		tweens = {},
		fading = false,
		piece = nil,
		shield = nil
	}
	self.entries[p.id] = v
	local clone = self._ctx.chessAssets.board:Clone()
	configurePart(clone) -- equivalent call inferred; original call site unknown
	clone.Name = p.id .. "_ChessBoard"
	clone.Transparency = 1
	local boardSize = self._ctx.boardSize()
	clone.Size = Vector3.new(boardSize.X, clone.Size.Y, boardSize.Y)
	clone.CFrame = self._ctx.boardCFrame() * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Parent = self._ctx.rootFolder
	table.insert(v.instances, clone)
	table.insert(
		v.tweens,
		TweenService:Create(clone, TweenInfo.new((math.max(0.01, self._ctx.config.previewDuration or 0.6))), {
			Transparency = 0.02
		})
	)
	local clone2 = (p2.selectedPiece == "Rook" and self._ctx.chessAssets.rook or p2.selectedPiece == "Bishop" and self._ctx.chessAssets.bishop or self._ctx.chessAssets.knight):Clone()
	configurePart(clone2) -- equivalent call inferred; original call site unknown
	clone2.Name = p.id .. "_ChessPiece"
	clone2.Parent = self._ctx.rootFolder
	v.piece = clone2
	table.insert(v.instances, clone2)
	self:_createLines(p2, v)

	for _, tween in v.tweens do
		tween:Play()
	end

	return v
end

function TraitVisualChessPath:_updateShield(p2: string, state)
	local ballPart = self._ctx.getBallPart(p2)

	if not ballPart then
		return
	end

	local attachment = ballPart:FindFirstChild("朝向标记")

	if not (attachment and attachment:IsA("Attachment")) then
		return
	end

	if not state.shield then
		local templateModel, _ = self._ctx.cloneTemplateModel(self._ctx.shieldTemplateBundle, p2 .. "_ChessShield")
		state.shield = templateModel
		table.insert(state.instances, templateModel)
	end

	state.shield:PivotTo(attachment.WorldCFrame * self._ctx.shieldTemplateBundle.markerOffset:Inverse())
end

function TraitVisualChessPath:update(p)
	local chessPath = p.traits and p.traits.ChessPath
	local entry = self.entries[p.id]

	if chessPath and chessPath.isActive then
		local v = entry or self:_createEntry(p, chessPath)
		local ballPart = self._ctx.getBallPart(p.id)

		if v.piece and ballPart then
			local attachment = ballPart:FindFirstChild("朝向标记")
			local worldPosition = attachment and attachment:IsA("Attachment") and attachment.WorldPosition or ballPart.Position
			v.piece.CFrame = self._ctx.pieceCFrame(worldPosition + self._ctx.upVector() * (self._ctx.config.pieceHoverHeight or 2.2))
		end

		self:_updateShield(p.id, v)
	elseif entry and not entry.fading then
		entry.fading = true
		local lineFadeOutDuration = self._ctx.config.lineFadeOutDuration or 0.2

		for _, part in entry.instances do
			if not part:IsA("BasePart") then
				continue
			end

			local v = fadePart(part, lineFadeOutDuration) -- equivalent call inferred; original call site unknown
			table.insert(entry.tweens, v)
			v:Play()
		end

		task.delay(
			math.max(lineFadeOutDuration, self._ctx.config.boardFadeOutDuration or lineFadeOutDuration),
			function()
				if self.entries[p.id] == entry then
					self:_destroyEntry(p.id)
				end
			end
		)
	end
end

function TraitVisualChessPath:cleanupBall(p: string)
	self:_destroyEntry(p)
end

function TraitVisualChessPath:reset()
	for k in self.entries do
		self:_destroyEntry(k)
	end
end

function TraitVisualChessPath:destroy()
	self:reset()
end

return TraitVisualChessPath