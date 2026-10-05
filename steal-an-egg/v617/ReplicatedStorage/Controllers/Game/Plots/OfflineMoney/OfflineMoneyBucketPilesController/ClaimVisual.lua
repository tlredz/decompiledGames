local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.numberMin(0), t.numberMaxExclusive(1e999))
local MoneyPiles = require(script.Parent.MoneyPiles)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ClaimVisual = {}
ClaimVisual.__index = ClaimVisual
ClaimVisual.__class = "OfflineMoneyClaimVisual"
local color = Color3.new(1, 1, 1)
local assets = ReplicatedStorage.Assets
local claimArea = assets.Models.ClaimArea
assert(claimArea:IsA("BasePart"), "ReplicatedStorage.Assets.Models.ClaimArea must be a BasePart")
local offlineCash = assets.Billboards.OfflineCash
assert(offlineCash:IsA("BillboardGui"), "ReplicatedStorage.Assets.Billboards.OfflineCash must be a BillboardGui")

function ClaimVisual.new(amount: number, p, parent)
	t.strict(intersection)(amount)
	t.strict(t.instanceIsA("BasePart"))(p)
	t.strict(t.Instance)(parent)
	local object = setmetatable({}, ClaimVisual)
	local maid = Trove.new()
	local model = Instance.new("Model")
	model.Name = "LocalOfflineMoneyClaim"
	model.Parent = parent
	local clone = claimArea:Clone()
	clone.Name = "OfflineMoneyClaimArea"
	clone.CFrame = p.CFrame + createVector(0, 0.2, 0)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Parent = model
	local generatedMoney = MoneyPiles.new(clone, model)
	local clone2 = offlineCash:Clone()
	clone2.Name = "OfflineMoneyClaimBillboard"
	clone2.AlwaysOnTop = true
	clone2.Parent = clone
	clone2.Enabled = true
	local money = clone2.Money
	assert(money and money:IsA("TextLabel"), "OfflineCash.Money must be a TextLabel")
	object._trove = maid
	object._amount = amount
	object._rootModel = model
	object._claimArea = clone
	object._generatedMoney = generatedMoney
	object._billboard = clone2
	object._billboardBaseSize = clone2.Size
	object._billboardPulseTween = nil
	object._billboardTextBlinkTween = nil
	object._billboardPulseActive = false
	object._moneyLabel = money
	object._moneyLabelBaseTextColor = object._moneyLabel.TextColor3
	maid:Add(model)
	maid:Add(function()
		generatedMoney:Destroy()
	end)
	maid:Add(generatedMoney.BillboardAdorneeChanged:Connect(function()
		object:_syncBillboardAdornee()
	end))
	object:Update(amount, p)
	return object
end

function ClaimVisual._formatMoney(p: number)
	return "$" .. Simple.FormatCompact(math.max(p, 0), "precision-integer")
end

function ClaimVisual._scaleBillboardSize(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, math.round(udim.X.Offset * p), udim.Y.Scale * p, (math.round(udim.Y.Offset * p)))
end

function ClaimVisual:_stopBillboardPulse()
	self._billboardPulseActive = false
	local _billboardPulseTween = self._billboardPulseTween

	if _billboardPulseTween then
		_billboardPulseTween:Cancel()
		self._billboardPulseTween = nil
	end

	local _billboardTextBlinkTween = self._billboardTextBlinkTween

	if _billboardTextBlinkTween then
		_billboardTextBlinkTween:Cancel()
		self._billboardTextBlinkTween = nil
	end

	self._billboard.Size = self._billboardBaseSize
	self._moneyLabel.TextColor3 = self._moneyLabelBaseTextColor
end

function ClaimVisual:_syncBillboardPulse()
	if not (self._billboard.Enabled and self._amount > 0) then
		self:_stopBillboardPulse()
		return
	end

	if self._billboardPulseActive then
		return
	end

	self._billboardPulseActive = true
	self._billboard.Size = self._billboardBaseSize
	self._moneyLabel.TextColor3 = self._moneyLabelBaseTextColor
	local tween = TweenService:Create(
		self._billboard,
		TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, -1, true),
		{
			Size = ClaimVisual._scaleBillboardSize(self._billboardBaseSize, 1.75)
		}
	)
	local tween2 = TweenService:Create(
		self._moneyLabel,
		TweenInfo.new(0.6400000000000001, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
		{
			TextColor3 = color
		}
	)
	self._billboardPulseTween = tween
	self._billboardTextBlinkTween = tween2
	tween:Play()
	tween2:Play()
end

function ClaimVisual:_syncBillboardAdornee()
	self._billboard.AlwaysOnTop = true
	local billboardAdornee = self._generatedMoney:GetBillboardAdornee()

	if billboardAdornee then
		self._billboard.Adornee = billboardAdornee
		self._billboard.StudsOffset = offlineCash.StudsOffset
	else
		self._billboard.Adornee = self._claimArea
		self._billboard.StudsOffset = createVector(0, 6, 0)
	end
end

function ClaimVisual:_syncBillboardText()
	self._moneyLabel.RichText = true
	self._moneyLabel.Text = `OFFLINE CLAIM! <br/>{ClaimVisual._formatMoney(self._amount)}`
end

function ClaimVisual:Update(amount: number, p)
	t.strict(intersection)(amount)
	t.strict(t.instanceIsA("BasePart"))(p)
	self._amount = amount
	self._claimArea.CFrame = p.CFrame + createVector(0, 0.2, 0)
	self._generatedMoney:UpdateInstant(amount, true)
	self:_syncBillboardText()
	self:_syncBillboardAdornee()
	self._billboard.Enabled = amount > 0
	self:_syncBillboardPulse()
end

function ClaimVisual:SetBillboardEnabled(flag: boolean)
	t.strict(t.boolean)(flag)
	self._billboard.Enabled = flag and self._amount > 0
	self:_syncBillboardPulse()
end

function ClaimVisual:ContainsWorldPosition(vector2: Vector3)
	t.strict(t.Vector3)(vector2)
	local pointToObjectSpace = self._claimArea.CFrame:PointToObjectSpace(vector2)
	local v = self._claimArea.Size * 0.5

	if self._claimArea:IsA("Part") and self._claimArea.Shape == Enum.PartType.Cylinder then
		local v2 = math.abs(pointToObjectSpace.X) < v.X
		local v3 = math.min(v.Y, v.Z)
		local v4 = pointToObjectSpace.Y * pointToObjectSpace.Y + pointToObjectSpace.Z * pointToObjectSpace.Z
		return v2 and v4 < v3 * v3
	else
		return math.abs(pointToObjectSpace.X) < v.X and math.abs(pointToObjectSpace.Z) < v.Z
	end
end

function ClaimVisual:PlayClaim()
	self._billboard.Enabled = false
	self:_stopBillboardPulse()
	self._generatedMoney:PlayCollectReset()
end

function ClaimVisual:Destroy()
	self:_stopBillboardPulse()
	self._trove:Destroy()
end

return ClaimVisual