local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local crosshair = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("Crosshair")
local Crosshair = {}
Crosshair.__index = Crosshair

function Crosshair.new()
	local self = setmetatable({}, Crosshair)
	self.Type = nil
	self.Info = nil
	self.Appearance = nil
	self.Frame = crosshair:Clone()
	self._destroyed = false
	self._visible = true
	self._spacing = 16
	self._spacing_multiplier = 1
	self._transparency = 0
	self._update_queued = false
	self._hitmarker_color = nil
	self._hitmarker_color_crit = nil
	self._last_hitmarker_crit_set = false
	self:_Init()
	return self
end

function Crosshair:GetDisplayAppearance()
	if self.Info.IsSpecial and not (self.Appearance and self.Appearance.Override) then
		return nil
	end

	return self.Appearance
end

function Crosshair:IsStatic()
	local displayAppearance = self:GetDisplayAppearance()

	if displayAppearance then
		return displayAppearance.IsStatic
	end

	return false
end

function Crosshair:IsScopedRedDotDisabled()
	local displayAppearance = self:GetDisplayAppearance()

	if displayAppearance then
		return displayAppearance.ScopedRedDotDisabled
	end

	return false
end

function Crosshair:IsScopedBarsDisabled()
	local displayAppearance = self:GetDisplayAppearance()

	if displayAppearance then
		return displayAppearance.ScopedBarsDisabled
	end

	return false
end

function Crosshair:GetScopedRedDotColor()
	local displayAppearance = self:GetDisplayAppearance()
	return displayAppearance and displayAppearance.ScopedRedDotColor
end

function Crosshair:ShowWhileAiming()
	local displayAppearance = self:GetDisplayAppearance()

	if displayAppearance then
		return displayAppearance.ShowWhileAiming
	end

	return false
end

function Crosshair:ShowWhileInspecting()
	local displayAppearance = self:GetDisplayAppearance()

	if displayAppearance then
		return displayAppearance.ShowWhileInspecting
	end

	return false
end

function Crosshair:GetAppearanceSpacing()
	local displayAppearance = self:GetDisplayAppearance()
	return displayAppearance and displayAppearance.BarsSpacing or 16
end

function Crosshair.SetParent(p, parent)
	p.Frame.Parent = parent
end

function Crosshair:SetType(p, p2)
	self.Type = p
	self.Info = ItemLibrary.Crosshairs[self.Type]
	self:_UpdateDeferred(p2)
end

function Crosshair:SetVisible(visible, p)
	if visible == self._visible then
		return
	end

	self._visible = visible
	self:_UpdateDeferred(p)
end

function Crosshair:SetSpacing(p, p2, p3)
	if p == self._spacing and p2 == self._spacing_multiplier then
		return
	end

	self._spacing = p or self._spacing
	self._spacing_multiplier = p2 or self._spacing_multiplier
	self:_UpdateDeferred(p3)
end

function Crosshair:SetTransparency(transparency, p)
	if transparency == self._transparency then
		return
	end

	self._transparency = transparency
	self:_UpdateDeferred(p)
end

function Crosshair:SetAppearance(appearance, p)
	self.Appearance = appearance
	self:_UpdateDeferred(p)
end

function Crosshair:SetHitmarkerColor(last_hitmarker_crit_set)
	self._last_hitmarker_crit_set = last_hitmarker_crit_set
	local v2

	if self._last_hitmarker_crit_set then
		v2 = self._hitmarker_color_crit or "#ff3232"
	else
		v2 = self._hitmarker_color or "#ffffff"
	end

	local color3FromHex = Utility:Color3FromHex(v2)
	self.Frame.Hitmarker.TL.ImageColor3 = color3FromHex
	self.Frame.Hitmarker.TR.ImageColor3 = color3FromHex
	self.Frame.Hitmarker.BR.ImageColor3 = color3FromHex
	self.Frame.Hitmarker.BL.ImageColor3 = color3FromHex
end

function Crosshair:SetHitmarkerVisuals(p, size, p2, _)
	local appearance = self.Appearance
	local hitmarkerTransparencyCrit = self._last_hitmarker_crit_set and appearance and appearance.HitmarkerTransparencyCrit or appearance and appearance.HitmarkerTransparency or 0
	local imageTransparency = hitmarkerTransparencyCrit + (1 - hitmarkerTransparencyCrit) * p2
	self.Frame.Hitmarker.TL.Position = UDim2.new(0.5, -p, 0.5, -p)
	self.Frame.Hitmarker.TR.Position = UDim2.new(0.5, p, 0.5, -p)
	self.Frame.Hitmarker.BR.Position = UDim2.new(0.5, p, 0.5, p)
	self.Frame.Hitmarker.BL.Position = UDim2.new(0.5, -p, 0.5, p)
	self.Frame.Hitmarker.TL.Size = size
	self.Frame.Hitmarker.TR.Size = size
	self.Frame.Hitmarker.BR.Size = size
	self.Frame.Hitmarker.BL.Size = size
	self.Frame.Hitmarker.TL.ImageTransparency = imageTransparency
	self.Frame.Hitmarker.TR.ImageTransparency = imageTransparency
	self.Frame.Hitmarker.BR.ImageTransparency = imageTransparency
	self.Frame.Hitmarker.BL.ImageTransparency = imageTransparency
end

function Crosshair:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	pcall(self.Frame.Destroy, self.Frame)
end

function Crosshair:_UpdateDeferred(...)
	if self._update_queued then
		task.cancel(self._update_queued)
		self._update_queued = nil
	end

	self._update_queued = task.defer(function(...)
		self._update_queued = nil
		self:_Update(...)
	end, ...)
end

function Crosshair:_Update(p)
	if self._destroyed or p then
		return
	end

	local appearance = self.Appearance
	local visible = self._visible and (not appearance or not appearance.IsDisabled)
	self.Frame.Foreground.Visible = visible
	self.Frame.Background.Visible = visible
	local visible2 = not appearance or not appearance.HitmarkerDisabled
	self._hitmarker_color = appearance and appearance.HitmarkerColor
	self._hitmarker_color_crit = appearance and appearance.HitmarkerColorCrit
	self.Frame.Hitmarker.Visible = visible2

	if not visible then
		return
	end

	local displayAppearance = self:GetDisplayAppearance()
	local scale = not displayAppearance and 1 or displayAppearance.Scale or 1
	local rotation = not displayAppearance and 0 or displayAppearance.Rotation or 0
	local v5 = not displayAppearance and 1 or displayAppearance.HitmarkerScale or 1
	local v6 = not displayAppearance and 0 or displayAppearance.HitmarkerRotation or 0
	self.Frame.UIScale.Scale = scale
	self.Frame.Rotation = rotation
	self.Frame.Hitmarker.UIScale.Scale = v5 / scale
	self.Frame.Hitmarker.Rotation = -rotation + v6
	local default = self.Info.IsSpecial and self.Appearance and self.Appearance.Override and ItemLibrary.Crosshairs.Default or self.Info
	self.Frame.Foreground.Dot.Image = default.DotImage
	self.Frame.Foreground.Right.Image = default.RightBarImage
	self.Frame.Foreground.Left.Image = default.LeftBarImage
	self.Frame.Foreground.Down.Image = default.BottomBarImage
	self.Frame.Foreground.Up.Image = default.TopBarImage
	self.Frame.Background.Dot.Image = self.Frame.Foreground.Dot.Image
	self.Frame.Background.Right.Image = self.Frame.Foreground.Right.Image
	self.Frame.Background.Left.Image = self.Frame.Foreground.Left.Image
	self.Frame.Background.Down.Image = self.Frame.Foreground.Down.Image
	self.Frame.Background.Up.Image = self.Frame.Foreground.Up.Image
	local v7 = not displayAppearance or not displayAppearance.DotDisabled
	local v8 = not displayAppearance or not displayAppearance.BarsDisabled
	local v9 = not displayAppearance or not displayAppearance.BarsTopDisabled
	local v10 = not displayAppearance or not displayAppearance.BarsBottomDisabled
	local v11 = not displayAppearance or not displayAppearance.BarsRightDisabled
	local v12 = not displayAppearance or not displayAppearance.BarsLeftDisabled
	local v13 = not displayAppearance or not displayAppearance.CircleDisabled
	self.Frame.Foreground.Dot.Visible = default.DotEnabled and v7
	self.Frame.Foreground.Right.Visible = default.BarsEnabled and v8 and v11
	self.Frame.Foreground.Left.Visible = default.BarsEnabled and v8 and v12
	self.Frame.Foreground.Down.Visible = default.BarsEnabled and v8 and v10
	self.Frame.Foreground.Up.Visible = default.BarsEnabled and v8 and v9
	self.Frame.Foreground.Circle.Visible = default.CircleEnabled and v13
	self.Frame.Background.Dot.Visible = self.Frame.Foreground.Dot.Visible
	self.Frame.Background.Right.Visible = self.Frame.Foreground.Right.Visible
	self.Frame.Background.Left.Visible = self.Frame.Foreground.Left.Visible
	self.Frame.Background.Down.Visible = self.Frame.Foreground.Down.Visible
	self.Frame.Background.Up.Visible = self.Frame.Foreground.Up.Visible
	self.Frame.Background.Circle.Visible = self.Frame.Foreground.Circle.Visible
	local v14

	if displayAppearance then
		v14 = displayAppearance.IsStatic
	else
		v14 = false
	end

	local v15 = (v14 and self:GetAppearanceSpacing() or self._spacing) * self._spacing_multiplier
	self.Frame.Foreground.Right.Position = UDim2.new(0.5, v15, 0.5, 0)
	self.Frame.Foreground.Left.Position = UDim2.new(0.5, -v15, 0.5, 0)
	self.Frame.Foreground.Down.Position = UDim2.new(0.5, 0, 0.5, v15)
	self.Frame.Foreground.Up.Position = UDim2.new(0.5, 0, 0.5, -v15)
	self.Frame.Background.Right.Position = self.Frame.Foreground.Right.Position
	self.Frame.Background.Left.Position = self.Frame.Foreground.Left.Position
	self.Frame.Background.Down.Position = self.Frame.Foreground.Down.Position
	self.Frame.Background.Up.Position = self.Frame.Foreground.Up.Position
	local v16 = not displayAppearance and 0 or displayAppearance.DotTransparency or 0
	local imageTransparency = v16 + (1 - v16) * self._transparency
	local v18 = not displayAppearance and 0 or displayAppearance.BarsTransparency or 0
	local imageTransparency2 = v18 + (1 - v18) * self._transparency
	local v20 = not displayAppearance and 0 or displayAppearance.CircleTransparency or 0
	local transparency = v20 + (1 - v20) * self._transparency
	self.Frame.Foreground.Dot.ImageTransparency = imageTransparency
	self.Frame.Foreground.Right.ImageTransparency = imageTransparency2
	self.Frame.Foreground.Left.ImageTransparency = imageTransparency2
	self.Frame.Foreground.Down.ImageTransparency = imageTransparency2
	self.Frame.Foreground.Up.ImageTransparency = imageTransparency2
	self.Frame.Foreground.Circle.UIStroke.Transparency = transparency
	self.Frame.Background.Dot.ImageTransparency = self.Frame.Foreground.Dot.ImageTransparency
	self.Frame.Background.Right.ImageTransparency = self.Frame.Foreground.Right.ImageTransparency
	self.Frame.Background.Left.ImageTransparency = self.Frame.Foreground.Left.ImageTransparency
	self.Frame.Background.Down.ImageTransparency = self.Frame.Foreground.Down.ImageTransparency
	self.Frame.Background.Up.ImageTransparency = self.Frame.Foreground.Up.ImageTransparency
	local v22 = not displayAppearance and 2 or displayAppearance.DotThickness or 2
	local v23 = not displayAppearance and 6 or displayAppearance.BarsLength or 6
	local v24 = not displayAppearance and 2 or displayAppearance.BarsThickness or 2
	local v25 = not displayAppearance and 16 or displayAppearance.CircleSize or 16
	local v26 = not displayAppearance and 2 or displayAppearance.CircleThickness or 2
	self.Frame.Foreground.Dot.Size = default.DotSize or UDim2.new(0, v22, 0, v22)
	self.Frame.Foreground.Right.Size = default.RightBarSize or UDim2.new(0, v23, 0, v24)
	self.Frame.Foreground.Left.Size = default.LeftBarSize or UDim2.new(0, v23, 0, v24)
	self.Frame.Foreground.Down.Size = default.BottomBarSize or UDim2.new(0, v24, 0, v23)
	self.Frame.Foreground.Up.Size = default.TopBarSize or UDim2.new(0, v24, 0, v23)
	self.Frame.Foreground.Circle.Size = default.CircleSize or UDim2.new(0, v25, 0, v25)
	self.Frame.Foreground.Circle.UIStroke.Thickness = default.CircleThickness or v26
	self.Frame.Background.Dot.Size = self.Frame.Foreground.Dot.Size
	self.Frame.Background.Right.Size = self.Frame.Foreground.Right.Size
	self.Frame.Background.Left.Size = self.Frame.Foreground.Left.Size
	self.Frame.Background.Down.Size = self.Frame.Foreground.Down.Size
	self.Frame.Background.Up.Size = self.Frame.Foreground.Up.Size
	local enabled = not displayAppearance or not displayAppearance.OutlineDisabled
	self.Frame.Background.Circle.UIStroke.Enabled = enabled
	self.Frame.Background.Dot.UIStroke.Enabled = enabled
	self.Frame.Background.Right.UIStroke.Enabled = enabled
	self.Frame.Background.Left.UIStroke.Enabled = enabled
	self.Frame.Background.Down.UIStroke.Enabled = enabled
	self.Frame.Background.Up.UIStroke.Enabled = enabled

	if enabled then
		local v28 = not displayAppearance and 0 or displayAppearance.OutlineTransparency or 0
		local transparency2 = v28 + (1 - v28) * self._transparency
		self.Frame.Background.Dot.UIStroke.Transparency = transparency2
		self.Frame.Background.Right.UIStroke.Transparency = transparency2
		self.Frame.Background.Left.UIStroke.Transparency = transparency2
		self.Frame.Background.Down.UIStroke.Transparency = transparency2
		self.Frame.Background.Up.UIStroke.Transparency = transparency2
		self.Frame.Background.Circle.UIStroke.Transparency = transparency2
		local thickness = not displayAppearance and 0 or displayAppearance.OutlineThickness or 0
		local _ = thickness * 2 + v26
		self.Frame.Background.Dot.UIStroke.Thickness = thickness
		self.Frame.Background.Right.UIStroke.Thickness = thickness
		self.Frame.Background.Left.UIStroke.Thickness = thickness
		self.Frame.Background.Down.UIStroke.Thickness = thickness
		self.Frame.Background.Up.UIStroke.Thickness = thickness
		self.Frame.Background.Circle.UIStroke.Thickness = thickness * 2 + v26
		self.Frame.Background.Circle.Size = UDim2.new(
			0,
			math.max(0, self.Frame.Foreground.Circle.Size.X.Offset - thickness * 2),
			0,
			(math.max(0, self.Frame.Foreground.Circle.Size.Y.Offset - thickness * 2))
		)
		local lineJoinMode = Enum.LineJoinMode[not displayAppearance and "Miter" or displayAppearance.OutlineType or "Miter"]
		self.Frame.Background.Dot.UIStroke.LineJoinMode = lineJoinMode
		self.Frame.Background.Right.UIStroke.LineJoinMode = lineJoinMode
		self.Frame.Background.Left.UIStroke.LineJoinMode = lineJoinMode
		self.Frame.Background.Down.UIStroke.LineJoinMode = lineJoinMode
		self.Frame.Background.Up.UIStroke.LineJoinMode = lineJoinMode
	end

	local color3FromHex = Utility:Color3FromHex(not displayAppearance and "#ffffff" or displayAppearance.DotColor or "#ffffff")
	local color3FromHex2 = Utility:Color3FromHex(not displayAppearance and "#ffffff" or displayAppearance.BarsColor or "#ffffff")
	local color3FromHex3 = Utility:Color3FromHex(not displayAppearance and "#ffffff" or displayAppearance.CircleColor or "#ffffff")
	self.Frame.Foreground.Dot.ImageColor3 = color3FromHex
	self.Frame.Foreground.Right.ImageColor3 = color3FromHex2
	self.Frame.Foreground.Left.ImageColor3 = color3FromHex2
	self.Frame.Foreground.Down.ImageColor3 = color3FromHex2
	self.Frame.Foreground.Up.ImageColor3 = color3FromHex2
	self.Frame.Foreground.Circle.UIStroke.Color = color3FromHex3
	self.Frame.Background.Dot.ImageColor3 = self.Frame.Foreground.Dot.ImageColor3
	self.Frame.Background.Right.ImageColor3 = self.Frame.Foreground.Right.ImageColor3
	self.Frame.Background.Left.ImageColor3 = self.Frame.Foreground.Left.ImageColor3
	self.Frame.Background.Down.ImageColor3 = self.Frame.Foreground.Down.ImageColor3
	self.Frame.Background.Up.ImageColor3 = self.Frame.Foreground.Up.ImageColor3
	local color3FromHex4 = Utility:Color3FromHex(not displayAppearance and "#000000" or displayAppearance.OutlineColor or "#000000")
	self.Frame.Background.Dot.UIStroke.Color = color3FromHex4
	self.Frame.Background.Right.UIStroke.Color = color3FromHex4
	self.Frame.Background.Left.UIStroke.Color = color3FromHex4
	self.Frame.Background.Down.UIStroke.Color = color3FromHex4
	self.Frame.Background.Up.UIStroke.Color = color3FromHex4
	self.Frame.Background.Circle.UIStroke.Color = color3FromHex4
	local v28 = not displayAppearance and "Sharp" or displayAppearance.BarsShape or "Sharp"
	local v29 = not displayAppearance and "Sharp" or displayAppearance.DotShape or "Sharp"
	local circleShape = displayAppearance and displayAppearance.CircleShape or "Circle"
	self.Frame.Foreground.Dot.UICorner.CornerRadius = v29 == "Round" and UDim.new(1, 0) or UDim.new(0, 0)
	self.Frame.Foreground.Right.UICorner.CornerRadius = v28 == "Round" and UDim.new(1, 0) or UDim.new(0, 0)
	self.Frame.Foreground.Left.UICorner.CornerRadius = v28 == "Round" and UDim.new(1, 0) or UDim.new(0, 0)
	self.Frame.Foreground.Down.UICorner.CornerRadius = v28 == "Round" and UDim.new(1, 0) or UDim.new(0, 0)
	self.Frame.Foreground.Up.UICorner.CornerRadius = v28 == "Round" and UDim.new(1, 0) or UDim.new(0, 0)
	self.Frame.Foreground.Circle.UICorner.CornerRadius = circleShape == "Circle" and UDim.new(1, 0) or circleShape == "Round" and UDim.new(
		0.25,
		0
	) or UDim.new(0, 0)
	self.Frame.Background.Dot.UICorner.CornerRadius = self.Frame.Foreground.Dot.UICorner.CornerRadius
	self.Frame.Background.Right.UICorner.CornerRadius = self.Frame.Foreground.Right.UICorner.CornerRadius
	self.Frame.Background.Left.UICorner.CornerRadius = self.Frame.Foreground.Left.UICorner.CornerRadius
	self.Frame.Background.Down.UICorner.CornerRadius = self.Frame.Foreground.Down.UICorner.CornerRadius
	self.Frame.Background.Up.UICorner.CornerRadius = self.Frame.Foreground.Up.UICorner.CornerRadius
	self.Frame.Background.Circle.UICorner.CornerRadius = self.Frame.Foreground.Circle.UICorner.CornerRadius
end

function Crosshair:_Setup()
	self.Frame.Visible = true
end

function Crosshair:_Init()
	self.Frame.Destroying:Connect(function()
		self:Destroy()
	end)
	self:_Setup()
	self:SetType("Default", true)
	self:SetSpacing(16, 1, true)
	self:SetTransparency(0, true)
	self:SetHitmarkerVisuals(0, UDim2.new(0, 0, 0), 1, 0)
	self:SetVisible(true, true)
	self:SetAppearance(nil, true)
	self:_Update()
end

return Crosshair