local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MathEquationTiming = require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("MathEquationTiming"))
local TraitVisualMathEquation = {}
TraitVisualMathEquation.__index = TraitVisualMathEquation
local v = {
	["+"] = "+",
	x = "×"
}
local v2 = {
	"数字模板",
	"符号模板",
	"数字模板",
	"符号模板",
	"结果模板"
}
local v3 = false

local function getBoardTemplate()
	local firstChild = ReplicatedStorage:FindFirstChild("美术素材")
	local UI = firstChild and firstChild:FindFirstChild("悬浮UI")
	local billboardGui = UI and UI:FindFirstChild("数学黑板")

	if billboardGui and billboardGui:IsA("BillboardGui") then
		return billboardGui
	end

	if not v3 then
		v3 = true
		warn("[TraitVisual_MathEquation] 黑板模板 ReplicatedStorage.美术素材.悬浮UI.数学黑板 缺失，黑板不显示")
	end

	return nil
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function popCurve(p: number, mathTokenPopOvershoot: number)
	if p <= 0 then
		return 0
	end

	if p < 0.6 then
		return mathTokenPopOvershoot * (p / 0.6)
	end

	if p < 1 then
		return mathTokenPopOvershoot + (1 - mathTokenPopOvershoot) * ((p - 0.6) / 0.4)
	end

	return 1
end

function TraitVisualMathEquation.new(ctx)
	local self = setmetatable({}, TraitVisualMathEquation)
	self._ctx = ctx
	self._rings = {}
	self._boards = {}
	self._bullets = {}
	return self
end

function TraitVisualMathEquation:_destroyRing(p2: string)
	local _ring = self._rings[p2]

	if _ring then
		for _, segment in _ring.segments do
			segment:Destroy()
		end

		self._rings[p2] = nil
	end
end

function TraitVisualMathEquation:_layoutRing(p, midRadius: number, width: number)
	p.midRadius = midRadius
	p.width = width
	local v4 = 6.283185307179586 * midRadius / 48 * 1.08

	for k, segment in p.segments do
		local v5 = (k - 0.5) / 48 * 2 * 3.141592653589793
		segment.Size = Vector3.new(v4, 0.04, width)
		segment.CFrame = CFrame.new(math.sin(v5) * midRadius, 0, -math.cos(v5) * midRadius) * CFrame.Angles(0, -v5, 0)
	end
end

function TraitVisualMathEquation:_updateRing(p, p2)
	local _ctx = self._ctx
	local ballPart = _ctx.getBallPart(p.id)

	if not ballPart then
		self:_destroyRing(p.id)
		return
	end

	local visual = _ctx.config.visual or {}
	local mathEquation = _ctx.config.traits.MathEquation or {}
	local _ring = self._rings[p.id]

	if _ring and _ring.ballPart ~= ballPart then
		self:_destroyRing(p.id)
		_ring = nil
	end

	if not _ring then
		local segments = {}

		for i = 1, 48 do
			local boxHandleAdornment = Instance.new("BoxHandleAdornment")
			boxHandleAdornment.Name = string.format("MathRing_%s_%d", p.id, i)
			boxHandleAdornment.Adornee = ballPart
			boxHandleAdornment.AlwaysOnTop = false
			boxHandleAdornment.Transparency = 0
			boxHandleAdornment.Visible = false
			boxHandleAdornment.AdornCullingMode = Enum.AdornCullingMode.Never
			boxHandleAdornment.Parent = ballPart
			segments[i] = boxHandleAdornment
		end

		_ring = {
			ballPart = ballPart,
			midRadius = -1,
			width = -1,
			segments = segments
		}
		self._rings[p.id] = _ring
	end

	local mathRingThickness = visual.mathRingThickness or 0.12
	local v4 = ((p.radius or 0) + (visual.mathRingGap or 0) + mathRingThickness * 0.5) * _ctx.arenaScale
	local v5 = math.max(mathRingThickness * _ctx.arenaScale, 0.001)

	if math.abs(v4 - _ring.midRadius) > 0.0001 or math.abs(v5 - _ring.width) > 0.0001 then
		self:_layoutRing(_ring, v4, v5)
	end

	local mathRingReadyColor, v6

	if p2.phase == "Calculating" then
		mathRingReadyColor = visual.mathRingReadyColor or Color3.fromRGB(255, 215, 90)
		v6 = 48
	else
		local chargeDuration = mathEquation.chargeDuration or 0
		v6 = math.floor((not (chargeDuration > 0) and 1 or math.clamp((p2.phaseElapsed or 0) / chargeDuration, 0, 1)) * 48 + 1e-6)
		mathRingReadyColor = visual.mathRingChargingColor or Color3.fromRGB(200, 230, 210)
	end

	for k, segment in _ring.segments do
		segment.Visible = k <= v6
		segment.Color3 = mathRingReadyColor
	end
end

function TraitVisualMathEquation:_destroyBoard(p2: string)
	local _board = self._boards[p2]

	if _board then
		_board.gui:Destroy()
		self._boards[p2] = nil
	end
end

function TraitVisualMathEquation:_rebuildTokens(state, data)
	for _, token in state.tokens do
		token.label:Destroy()
	end

	state.tokens = {}
	local scale = state.gui.Size.Y.Scale
	local v4 = not state.padding and 0 or state.padding.PaddingTop.Scale
	local v5 = not state.padding and 0 or state.padding.PaddingBottom.Scale
	local v6 = 0.62 * scale * math.max(1 - v4 - v5, 0.1)

	for k, text in {
		tostring(data.a),
		v[data.operator] or tostring(data.operator),
		tostring(data.b),
		"=",
		(tostring(data.result))
	} do
		local label = state.background:FindFirstChild(v2[k])

		if not (label and label:IsA("TextLabel")) then
			continue
		end

		local clone = label:Clone()
		clone.Name = string.format("Token_%d", k)
		clone.Text = text
		clone.LayoutOrder = k
		clone.Visible = false
		clone.Parent = state.background
		table.insert(state.tokens, {
			label = clone,
			scale = clone:FindFirstChildOfClass("UIScale"),
			widthStuds = v6 * (utf8.len(text) or #text)
		})
	end
end

function TraitVisualMathEquation:_updateBoard(p, data)
	local _ctx = self._ctx
	local _board = self._boards[p.id]

	if data.phase == "Calculating" and data.equation then
		local ballPart = _ctx.getBallPart(p.id)

		if not _board then
			local boardTemplate = getBoardTemplate()

			if not boardTemplate then
				return
			end

			local clone = boardTemplate:Clone()
			local frame = clone:FindFirstChild("背景")

			if not (frame and frame:IsA("Frame")) then
				clone:Destroy()
				return
			end

			clone.Name = "MathBoard_" .. p.id
			clone.Parent = _ctx.rootFolder
			_board = {
				gui = clone,
				background = frame,
				layout = frame:FindFirstChildOfClass("UIListLayout"),
				padding = frame:FindFirstChildOfClass("UIPadding"),
				serial = -1,
				tokens = {},
				lastTotalStuds = -1
			}
			self._boards[p.id] = _board
		end

		if _board.serial ~= data.calcSerial then
			_board.serial = data.calcSerial
			_board.lastTotalStuds = -1
			self:_rebuildTokens(_board, data.equation)
		end

		local mathEquation = _ctx.config.traits.MathEquation or {}
		local visual = _ctx.config.visual or {}
		local v4 = math.max(visual.mathTokenPopDuration or 0.18, 0.001)
		local mathTokenPopOvershoot = visual.mathTokenPopOvershoot or 1.2
		local phaseElapsed = data.phaseElapsed or 0
		local count = 0
		local total = 0.44

		for k, token in _board.tokens do
			local v5 = phaseElapsed - MathEquationTiming.tokenRevealTime(mathEquation, k)
			local visible = v5 >= 0
			token.label.Visible = visible

			if not visible then
				continue
			end

			count += 1
			total += token.widthStuds

			if not token.scale then
				continue
			end

			local scale = token.scale
			scale.Scale = popCurve(v5 / v4, mathTokenPopOvershoot)
		end

		local lastTotalStuds = total + math.max(count - 1, 0) * 0.08

		if math.abs(lastTotalStuds - _board.lastTotalStuds) > 0.0001 then
			_board.lastTotalStuds = lastTotalStuds
			local scale = _board.gui.Size.X.Scale
			local v6 = math.max(scale, lastTotalStuds)

			if v6 ~= scale then
				_board.gui.Size = UDim2.new(v6, 0, _board.gui.Size.Y.Scale, 0)
			end

			_board.background.Size = UDim2.new(lastTotalStuds / v6, 0, 1, 0)

			for _, token in _board.tokens do
				token.label.Size = UDim2.new(token.widthStuds / lastTotalStuds, 0, 1, 0)
			end

			if _board.layout then
				_board.layout.Padding = UDim.new(0.08 / lastTotalStuds, 0)
			end

			if _board.padding then
				_board.padding.PaddingLeft = UDim.new(0.22 / lastTotalStuds, 0)
				_board.padding.PaddingRight = UDim.new(0.22 / lastTotalStuds, 0)
			end
		end

		_board.gui.Adornee = ballPart
		_board.gui.Enabled = ballPart ~= nil
	elseif _board then
		_board.gui.Enabled = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyBullet(p)
	p.model:Destroy()

	if p.levelGui then
		p.levelGui:Destroy()
	end
end

function TraitVisualMathEquation:_updateBullets(p2, p3)
	local _ctx = self._ctx
	local mathBulletTemplateBundle = _ctx.mathBulletTemplateBundle

	if not mathBulletTemplateBundle then
		return
	end

	self._bullets[p2.id] = self._bullets[p2.id] or {}
	local _bullet = self._bullets[p2.id]
	local lookVector = _ctx.arenaCFrame.LookVector
	local v4 = {}

	for _, v5 in p3.bullets or {} do
		v4[v5.bulletId] = true
		local v6 = _bullet[v5.bulletId]

		if not v6 then
			local templateModel, adornee = _ctx.cloneTemplateModel(
				mathBulletTemplateBundle,
				string.format("MathBullet_%s_%d", p2.id, v5.bulletId)
			)
			templateModel.Parent = _ctx.rootFolder
			local UI = templateModel:FindFirstChild("等级UI")

			if UI and UI:IsA("BillboardGui") then
				UI.Parent = _ctx.rootFolder
				UI.Adornee = adornee
				UI.Enabled = true
				local label = UI:FindFirstChild("等级字")

				if label and label:IsA("TextLabel") then
					label.Text = tostring(v5.damage)
				end
			else
				UI = nil
			end

			v6 = {
				model = templateModel,
				levelGui = UI
			}
			_bullet[v5.bulletId] = v6
		end

		local model = v6.model
		local worldFromArena = _ctx.worldFromArena(v5.position)
		local worldFromArena2 = _ctx.worldFromArena(v5.position + v5.direction)

		if (worldFromArena2 - worldFromArena).Magnitude > 0.001 then
			model:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, lookVector) * mathBulletTemplateBundle.forwardOffset:Inverse())
		else
			model:PivotTo(CFrame.new(worldFromArena) * model:GetPivot().Rotation)
		end

		_ctx.setTemplateModelVisibility(model, true)
	end

	for k, v5 in _bullet do
		if v4[k] then
			continue
		end

		destroyBullet(v5) -- equivalent call inferred; original call site unknown
		_bullet[k] = nil
	end
end

function TraitVisualMathEquation:update(p)
	local mathEquation = p.traits and p.traits.MathEquation

	if not mathEquation then
		return
	end

	self:_updateRing(p, mathEquation)
	self:_updateBoard(p, mathEquation)
	self:_updateBullets(p, mathEquation)
end

function TraitVisualMathEquation:cleanupBall(p: string)
	self:_destroyRing(p)
	self:_destroyBoard(p)

	for _, v4 in self._bullets[p] or {} do
		destroyBullet(v4) -- equivalent call inferred; original call site unknown
	end

	self._bullets[p] = nil
end

function TraitVisualMathEquation:reset()
	local v4 = {}

	for k in self._rings do
		v4[k] = true
	end

	for k in self._boards do
		v4[k] = true
	end

	for k in self._bullets do
		v4[k] = true
	end

	for k in v4 do
		self:cleanupBall(k)
	end

	self._rings = {}
	self._boards = {}
	self._bullets = {}
end

return TraitVisualMathEquation