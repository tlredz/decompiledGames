local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Adders = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.Adders)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local info = faye.Info(0.45)
local uDim = UDim2.fromScale(0.075, 0.06)

-- equivalent calls inferred from this helper; original call sites unknown
local function size()
	if Platform_Handler.Platform.Value == "Mobile" then
		return UDim2.fromScale(uDim.X.Scale * 2.5, uDim.Y.Scale * 2.5)
	end

	return uDim
end

return function(object, parent, _, p2)
	local v = nil
	p2.Amount = 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function adjust(p3)
		local v2 = math.clamp(math.floor(tonumber(v.Instance.Text) or 0) + p3, 1, 99)
		v.Instance.Text = v2
		p2.Amount = v2
	end

	v = object:Create("TextBox")({
		Size = UDim2.new(1, -2, 1, -2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		TextScaled = true,
		Font = Enum.Font.SourceSansBold,
		Text = 1,
		FocusLost = function(p3, _)
			local v2 = math.clamp(math.floor(tonumber(p3.Text) or 0), 1, 99)
			p3.Text = v2
			p2.Amount = v2
		end
	})
	local v2 = object:Create("CanvasGroup")
	local size2 = size() -- equivalent call inferred; original call site unknown
	return v2({
		Parent = parent,
		Size = size2,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		GroupTransparency = object:Animation(0, info, {
			From = 1
		}),
		OnClean = function(object2)
			return {
				GroupTransparency = object2:Animation(1, info)
			}
		end,
		object:Create("TextLabel")({
			Size = UDim2.fromScale(1, 0.4),
			BackgroundTransparency = 1,
			Text = "Custom Amount",
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			TextColor3 = Color3.new(1, 1, 1),
			TextStrokeTransparency = 0.75
		}),
		Adders(object, {
			Position = UDim2.fromScale(0, 0.72),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromScale(0.2, 0.55)
		}, 90, function()
			adjust(-1) -- equivalent call inferred; original call site unknown
		end),
		Adders(object, {
			Position = UDim2.fromScale(1, 0.72),
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromScale(0.2, 0.55)
		}, -90, function()
			adjust(1) -- equivalent call inferred; original call site unknown
		end),
		object:Create("Frame")({
			Name = "CustomAdderHolder",
			Size = UDim2.fromScale(0.6, 0.55),
			Position = UDim2.fromScale(0.5, 0.45),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 0,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			v
		})
	})
end