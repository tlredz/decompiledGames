local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local InputUtils = require(script.Parent.InputUtils)
local Motion = require(script.Parent.Motion)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement
local tabBarHeight = Theme.TabBarHeight
local v = tabBarHeight - 10

local function FloatingCollapseButton(props)
	local zIndex = props.ZIndex or 50
	local ref = React.useRef(nil)
	local ref2 = React.useRef(false)

	local function beginPress(p)
		if not InputUtils.isPrimaryPointer(p) then
			return
		end

		ref2.current = false
		local position = InputUtils.position(p)
		local inputEndedConnection = nil
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if not InputUtils.isPointerMove(input) then
				return
			end

			if (InputUtils.position(input) - position).Magnitude > 3 then
				ref2.current = true
			end
		end)
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= p.UserInputType then
				return
			end

			if inputChangedConnection then
				inputChangedConnection:Disconnect()
			end

			if inputEndedConnection then
				inputEndedConnection:Disconnect()
			end
		end)
	end

	return createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(tabBarHeight, tabBarHeight),
		ZIndex = zIndex
	}, {
		Button = createElement("TextButton", {
			ref = ref,
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Header,
			BorderSizePixel = 0,
			Font = Theme.FontBold,
			Position = UDim2.fromOffset(5, 5),
			Selectable = false,
			Size = UDim2.fromOffset(v, v),
			Text = props.Collapsed and "+" or "_",
			TextColor3 = Theme.TextSubtle,
			TextSize = props.Collapsed and 24 or 22,
			TextStrokeTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = zIndex + 1,
			[React.Tag] = "IrisLogFloatingCollapseButton",
			[React.Event.Activated] = function()
				if ref2.current then
					ref2.current = false
				else
					props.OnActivated()
				end
			end,
			[React.Event.InputBegan] = function(_, p)
				beginPress(p)
			end,
			[React.Event.MouseEnter] = function()
				Motion.to(ref.current, Motion.Hover, {
					BackgroundColor3 = Theme.ButtonHover,
					TextColor3 = Theme.Text
				})
			end,
			[React.Event.MouseLeave] = function()
				Motion.to(ref.current, Motion.Hover, {
					BackgroundColor3 = Theme.Header,
					TextColor3 = Theme.TextSubtle
				})
			end
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			})
		})
	})
end

return React.memo(FloatingCollapseButton)