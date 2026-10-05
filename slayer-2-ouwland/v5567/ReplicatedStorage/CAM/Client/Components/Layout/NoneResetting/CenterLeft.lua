local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local PartyComponents = require(script.PartyComponents)
local QuestsComponents = require(script.QuestsComponents)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local KeybindHelper = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.KeybindHelper)
local PvpSwitch = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.PvpSwitch)

-- equivalent calls inferred from this helper; original call sites unknown
local function columnScale()
	if Platform_Handler.Platform.Value == "Mobile" then
		return 0.34
	end

	return 0.2
end

local HUD = ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD
local centerLeft = ReplicatedStorage.Communication.CnC.Notifications.CenterLeft
local modulesByName = {}

for _, moduleScript in script.Notifications:QueryDescendants("ModuleScript") do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

local function Build(object, parent)
	local value = object:Value(columnScale())
	object:Connect(Platform_Handler.Platform.Changed.Event, function()
		value:Set(columnScale())
	end)
	local canvasSize = object:Value(UDim2.new())
	return object:Create("ScrollingFrame")({
		Name = "LeftCenterFramesHolder",
		Parent = parent,
		ClipsDescendants = false,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = canvasSize,
		ScrollBarThickness = 0,
		Size = object:Do(function(callback)
			local v = callback(value)
			return UDim2.fromScale(v, v)
		end),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 5, 0.5, 0),
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 2
		}),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 3),
			AbsoluteContentSizeOnChangedInit = function(p2)
				canvasSize:Set(UDim2.fromOffset(0, p2.AbsoluteContentSize.Y))
			end
		}),
		QuestsComponents(object),
		PartyComponents(object),
		PvpSwitch(object, {
			OnlyOn = {
				Mobile = true
			},
			RowHeight = 25,
			FillWidth = true,
			HorizontalAlignment = Enum.HorizontalAlignment.Left
		}),
		object:Create("Frame")({
			Name = "Notifications",
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 3)
			}),
			object:Signal(centerLeft.Event, function(p2, _, p3: string, ...)
				local v = modulesByName[p3]

				if v == nil then
					return
				else
					return v(p2, ...)
				end
			end)
		}),
		KeybindHelper(object, {
			OnlyOn = {
				Mobile = true
			},
			RowHeight = 16.900000000000002,
			FillWidth = true,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top
		})
	})
end

return function(parent)
	local v = faye.new()
	local v2 = nil
	local v3 = nil
	local v4 = {}
	local v5 = false
	v:Connect(centerLeft.Event, function(...)
		if v3 ~= nil or v5 then
			return
		end

		table.insert(v4, table.pack(...))
	end)

	local function updVisibility()
		local value = HUD.Value

		if value ~= v2 then
			v2 = value

			if v3 ~= nil then
				v3:Destroy()
				v3 = nil
			end

			if value then
				v3 = v:Extend()
				Build(v3, parent)

				if #v4 > 0 then
					local v6 = v4
					v4 = {}
					v5 = true

					for _, list in v6 do
						centerLeft:Fire(table.unpack(list, 1, list.n))
					end

					v5 = false
				end
			end
		end
	end

	updVisibility()
	v:Connect(HUD.Changed, updVisibility)
	return function()
		v:Destroy()
	end
end