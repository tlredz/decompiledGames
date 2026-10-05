local createVector = vector.create
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, -1, true)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
return {
	new = function(parent, adornee, p)
		local v = {
			_showing = false,
			_dismissed = false,
			_destroyed = false
		}
		local highlight = Instance.new("Highlight")
		highlight.Adornee = adornee
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.Enabled = true
		highlight.Parent = parent
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Adornee = adornee
		billboardGui.AlwaysOnTop = true
		billboardGui.Size = UDim2.fromScale(1.75, 1.75)
		billboardGui.ExtentsOffsetWorldSpace = createVector(-0.85, -1, 0)
		billboardGui.ClipsDescendants = true
		billboardGui.Enabled = false
		billboardGui.Parent = parent
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = "rbxassetid://72802720009643"
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Parent = billboardGui
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 1
		uIScale.Parent = imageLabel
		local v2 = nil
		local v3 = nil
		p.Activated:Once(function()
			v._dismissed = true
			v:hide()
		end)

		function v:show()
			if self._showing or self._dismissed or self._destroyed then
				return
			end

			self._showing = true
			billboardGui.Enabled = true
			v2 = TweenService:Create(highlight, tweenInfo, {
				OutlineTransparency = 0
			})
			v2:Play()
			v3 = TweenService:Create(uIScale, tweenInfo, {
				Scale = 0.75
			})
			v3:Play()
		end

		function v:hide()
			if not self._showing or self._destroyed then
				return
			end

			self._showing = false

			if v2 then
				v2:Cancel()
			end

			if v3 then
				v3:Cancel()
			end

			TweenService:Create(highlight, tweenInfo2, {
				OutlineTransparency = 1
			}):Play()
			billboardGui.Enabled = false
			uIScale.Scale = 1
		end

		function v:destroy()
			if self._destroyed then
				return
			end

			self._destroyed = true
			self:hide()
			highlight:Destroy()
			billboardGui:Destroy()
		end

		return v
	end
}