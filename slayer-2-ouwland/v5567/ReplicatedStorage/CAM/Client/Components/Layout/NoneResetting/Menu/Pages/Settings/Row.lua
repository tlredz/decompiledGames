local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Toggle = require(ReplicatedStorage.CAM.Client.Components.Misc.Toggle)
local Dragbar = require(ReplicatedStorage.CAM.Client.Components.Misc.Dragbar)
local Recorder = require(ReplicatedStorage.CAM.Client.Components.Misc.Recorder)
local Dropdown = require(ReplicatedStorage.CAM.Client.Components.Misc.Dropdown)
require(ReplicatedStorage.Packages.faye)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
require(script.Parent.Sections)
local Keybinding = require(script.Parent.Keybinding)
local Pref = require(script.Parent.Pref)
local color = Color3.new(0.62, 0.62, 0.62)
local color2 = Color3.new(0.15, 0.15, 0.15)
local Row = {
	Height = function(p)
		if p.Kind == "Heading" then
			return 0.62
		end

		return 1
	end,
	Layer = function(p, p2: number)
		if p.Kind == "Choice" then
			return 200 - p2
		end

		return 1
	end,
	Overhang = function(list)
		local v = list[#list]

		if v == nil or v.Kind ~= "Choice" then
			return 0
		end

		return #v.Choices * 25
	end
}

local function control(object, data, announce, uiScale, controller, tone)
	local uDim = UDim2.fromScale(1, 1)

	if data.Kind == "Heading" then
		return object:Create("TextLabel")({
			Name = "Heading",
			Text = data.Label,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0.08, 1),
			Size = UDim2.fromScale(0.92, 0.62),
			BackgroundTransparency = 1,
			TextColor3 = color,
			Font = Enum.Font.SourceSansBold,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	if data.Kind == "Recorder" then
		local keybind = data.Keybind
		return Recorder(object, keybind, data.Label, {
			Size = uDim,
			CanEdit = data.CanEdit,
			Announce = announce,
			Controller = controller,
			Tone = tone,
			uiScale = uiScale,
			OnRecord = function(p4, p5)
				return Keybinding.Record(keybind, p4, p5)
			end,
			OnRecordPad = function(p4, p5)
				return Keybinding.RecordPad(keybind, p4, p5)
			end,
			PadIgnore = SettingsKeys.PadReserved
		})
	end

	local v, onCommit = Pref(object, data.Key, data.Action, data.Arg)

	if data.Kind == "Choice" then
		object:Connect(v.Changed, function()
			onCommit(v:Get())
		end)
		return object:Create("Frame")({
			Name = "Choice",
			Size = uDim,
			BackgroundColor3 = color2,
			ZIndex = 5,
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.6),
					NumberSequenceKeypoint.new(1, 0)
				})
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			object:Create("TextLabel")({
				Name = "Label",
				Text = data.Label,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.08, 0.5),
				Size = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				ZIndex = 6,
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.SourceSansSemibold,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			Dropdown(object, v, data.Choices, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(0.96, 0.5),
				Size = UDim2.fromScale(0.3, 0.6),
				ZIndex = 7
			})
		})
	else
		if data.Kind ~= "Toggle" then
			return Dragbar(object, v, data.Label, {
				Size = uDim,
				Min = data.Min,
				Max = data.Max,
				Step = data.Step,
				Format = data.Format,
				OnCommit = onCommit,
				uiScale = uiScale
			})
		end

		object:Connect(v.Changed, function()
			onCommit(v:Compare(true))
		end)
		return Toggle(object, v, data.Label, {
			Size = uDim,
			Fade = true
		})
	end
end

function Row.Build(object, p, p2, layoutOrder: number, announce, uiScale, controller, tone)
	local height = Row.Height(p)
	return object:Create("Frame")({
		Name = "Row",
		LayoutOrder = layoutOrder,
		ZIndex = Row.Layer(p, layoutOrder),
		Size = object:Do(function(callback2)
			return UDim2.new(1, 0, 0, callback2(p2) * height)
		end),
		BackgroundTransparency = 1,
		control(object, p, announce, uiScale, controller, tone)
	})
end

return Row