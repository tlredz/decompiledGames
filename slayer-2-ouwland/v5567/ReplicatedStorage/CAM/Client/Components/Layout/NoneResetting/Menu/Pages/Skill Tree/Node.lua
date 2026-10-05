local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConnectorLine = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.Pages["Skill Tree"].MiscComponents.ConnectorLine)
local UnLocked = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.Pages["Skill Tree"].StatesComponents.UnLocked)
local UnLockedBranch = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.Pages["Skill Tree"].StatesComponents.UnLockedBranch)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local faye = require(ReplicatedStorage.Packages.faye)
local Locked = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.Pages["Skill Tree"].StatesComponents.Locked)
local info = faye.Info(0.2)
return function(object, p, object2, current, previous, object3)
	local CS = current.Locked ~= false and 1 or current.IsBranch == nil and 2 or 3
	local state = object2:Value(CS)
	local chainTransparency = object2:Value(0)

	if CS == 1 then
		chainTransparency:Set(0.925)
	end

	local contentTransparency = object2:Value(0.5)
	local outerColor = object2:Value(Color3.new(0.92549, 0.87451, 0.788235))
	local innerColor = object2:Value(Color3.new(0.333333, 0.301961, 0.258824))
	local glowColor = object2:Value(Color3.new(0.721569, 0.615686, 0.45098))
	local gradientDisabled = object2:Value(false)
	local v2 = {
		Current = current,
		Previous = previous,
		State = state,
		ChainTransparency = chainTransparency,
		ContentTransparency = contentTransparency,
		OuterColor = outerColor,
		InnerColor = innerColor,
		GlowColor = glowColor,
		GradientDisabled = gradientDisabled,
		Hovering = false,
		CS = CS
	}
	local v3 = object:Add(v2, object2, true):Call()
	return { object2:Create("CanvasGroup")({
			Name = "ActualHolder",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			GroupTransparency = object2:Animation(contentTransparency, info),
			object2:Create("ImageLabel")({
				Name = "Bg",
				BackgroundTransparency = 1,
				ZIndex = 0,
				Image = "rbxassetid://79024618338298",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1.125, 1.125),
				ImageColor3 = Color3.new(0.25, 0.25, 0.25),
				object2:Create("UICorner")({
					CornerRadius = UDim.new(1)
				})
			}),
			object2:State(function(callback, p3, _)
				local v4 = callback(state)
				local v5 = nil

				if v4 == 1 then
					v5 = Locked(p, p3, current)
				elseif v4 == 2 then
					v5 = UnLocked(p, p3, current, outerColor, innerColor, glowColor, gradientDisabled)
				elseif v4 == 3 then
					v5 = UnLockedBranch(p, p3, current, outerColor, innerColor, glowColor, gradientDisabled)
				end

				return { v5, function()
						if previous == nil then
							return
						end

						local v6 = current.UI.AbsolutePosition + current.UI.AbsoluteSize / 2
						local v7 = previous.UI.AbsolutePosition + previous.UI.AbsoluteSize / 2
						return ConnectorLine(
							p,
							p3,
							current.UI,
							previous.UI,
							v6,
							v7,
							previous.MapIndex == 1 and 1.2 or 1,
							chainTransparency
						)
					end }
			end)
		}), object2:Create("TextButton")({
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			MouseEnter = function()
				v2.Hovering = true
				v3:Call()
			end,
			MouseLeave = function()
				v2.Hovering = false
				v3:Call()
			end,
			MouseButton1Click = function()
				ScreenEffects.CircleClick()

				if object3:Compare(current) then
					object3:Reset()
				else
					object3:Set(current)
				end
			end
		}) }
end