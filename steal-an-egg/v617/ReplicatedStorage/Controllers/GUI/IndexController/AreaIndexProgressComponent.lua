local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage.Packages.t)
local Gears = require(ReplicatedStorage.Data.Gears)
local SurfaceButton = require(ReplicatedStorage.Client.UI.VFX.SurfaceButton)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(script.Types.Interface)
local AreaIndexProgressComponent = {}
AreaIndexProgressComponent.__index = AreaIndexProgressComponent
AreaIndexProgressComponent.__class = "AreaIndexProgressComponent"
local color = Color3.fromRGB(0, 182, 24)
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- equivalent calls inferred from this helper; original call sites unknown
local function gearIcon(p: string)
	local v = Gears.Directory[p]

	if v == nil then
		return ""
	end

	return v.Icon
end

function AreaIndexProgressComponent.new(view, onAction)
	local object = setmetatable({}, AreaIndexProgressComponent)
	object._view = view
	object._onAction = onAction
	object._sectionId = nil
	object._actionEnabled = false
	object._defaultTextColor = view.TextLabel.TextColor3
	object._progressTween = nil
	object._trove = Trove.new()
	object:_init()
	return object
end

function AreaIndexProgressComponent:_setProgress(p: number, flag: boolean?)
	local _progressTween = self._progressTween

	if _progressTween then
		_progressTween:Cancel()
		_progressTween:Destroy()
	end

	local uDim = UDim2.fromScale(p, 1)

	if flag then
		self._view.Fill.Size = uDim
		return
	end

	local tween = TweenService:Create(self._view.Fill, tweenInfo, {
		Size = uDim
	})
	self._progressTween = tween
	tween:Play()
end

function AreaIndexProgressComponent:_render(sectionId: string, image: string, p: number, p2: number, text: string, flag: boolean, flag2: boolean)
	t.strict(t.string)(sectionId)
	t.strict(t.string)(image)
	t.strict(t.number)(p)
	t.strict(t.number)(p2)
	t.strict(t.string)(text)
	t.strict(t.boolean)(flag)
	t.strict(t.boolean)(flag2)
	local _view = self._view
	local v

	if p2 > 0 then
		v = p2 <= p
	else
		v = false
	end

	local v2 = v and flag2
	local v3 = p2 == 0 and 0 or math.clamp(p / p2, 0, 1)
	self._sectionId = sectionId
	self._actionEnabled = v2
	_view.Active = v2
	_view.ImageLabel.Image = image
	_view.ImageLabel.Visible = image ~= ""
	local textLabel = _view.TextLabel

	if not v then
		text = `{p}/{p2}`
	end

	textLabel.Text = text
	local textLabel2 = _view.TextLabel
	local textColor

	if v and flag then
		textColor = color
	else
		textColor = self._defaultTextColor
	end

	textLabel2.TextColor3 = textColor
	self:_setProgress(v3)
end

function AreaIndexProgressComponent:RenderAreaBat(p: string, p2: string, p3: number, p4: number, flag: boolean, flag2: boolean)
	t.strict(t.string)(p)
	t.strict(t.string)(p2)
	t.strict(t.number)(p3)
	t.strict(t.number)(p4)
	t.strict(t.boolean)(flag)
	t.strict(t.boolean)(flag2)
	self:_render(p, gearIcon(p2), p3, p4, flag2 and "Equipped" or "Equip Bat!", flag2, not flag2)
end

function AreaIndexProgressComponent:RenderGearClaim(p: string, p2: string, p3: number, p4: number, flag: boolean)
	t.strict(t.boolean)(flag)
	self:_render(p, gearIcon(p2), p3, p4, flag and "CLAIMED!" or "CLAIM!", flag, not flag)
end

function AreaIndexProgressComponent:RenderCollection(p: string, p2: string, p3: number, p4: number)
	self:_render(p, p2, p3, p4, "COMPLETE!", true, false)
end

function AreaIndexProgressComponent:Destroy()
	local _progressTween = self._progressTween

	if _progressTween then
		_progressTween:Cancel()
		_progressTween:Destroy()
		self._progressTween = nil
	end

	self._teardown()
	self._trove:Destroy()
end

function AreaIndexProgressComponent:_init()
	self._teardown = SurfaceButton(self._view, 1.04, function()
		local _sectionId = self._sectionId

		if _sectionId ~= nil and self._actionEnabled then
			self._onAction(_sectionId)
		end
	end)
end

return AreaIndexProgressComponent