local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Packages.faye)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local PartyMember = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler.Styles.RegularType.PartyMember)
local Ping = require(script.Parent.Ping)
local MapSettings = require(ReplicatedStorage.CAM.Client.Modules.MapSettings)
require(script.Parent.Types)
local color = Color3.new(0.4, 0.4, 0.4)

local function positionOf(p)
	local position = p.position

	if typeof(position) == "Instance" then
		position = position.Position
	elseif typeof(position) ~= "Vector3" then
		position = nil
	end

	if position == nil then
		return nil
	end

	return position + (p.offset or createVector(0, 0, 0))
end

local function isPlayer(p)
	return p.player ~= nil
end

return function(object, data, name: string, data2)
	local position = data2.position

	if typeof(position) == "Instance" then
		position = position.Position
	elseif typeof(position) ~= "Vector3" then
		position = nil
	end

	local v

	if position ~= nil then
		v = position + (data2.offset or createVector(0, 0, 0))
	end

	if v == nil then
		return
	end

	local point = data.Point(v)
	local position3 = object:Value(UDim2.fromScale(point.X, point.Y))

	if typeof(data2.position) == "Instance" then
		object:Connect(RunService.RenderStepped, function()
			local v2 = data2
			local position2 = v2.position

			if typeof(position2) == "Instance" then
				position2 = position2.Position
			elseif typeof(position2) ~= "Vector3" then
				position2 = nil
			end

			local v3

			if position2 ~= nil then
				v3 = position2 + (v2.offset or createVector(0, 0, 0))
			end

			if v3 == nil then
				return
			end

			local point2 = data.Point(v3)
			position3:Set(UDim2.fromScale(point2.X, point2.Y))
		end)
	end

	local v2 = object:Create("Frame")
	local v3 = {
		Name = name,
		Visible = MapSettings.Watch(
			object,
			data2.player ~= nil and "PartyMarkers" or data2.kind == "TrackedSpawn" and "TrackedSpawns" or "QuestMarkers"
		),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position3,
		Size = UDim2.fromOffset(data.Side, data.Side),
		Rotation = -data.Rotation,
		BackgroundTransparency = 1
	}
	local v4

	if data2.ping ~= nil then
		v4 = Ping(object, {
			Color = data2.ping,
			ZIndex = 0
		})
	end

	local v5 = object:Create("ImageLabel")
	local v6 = {
		Name = "Plate",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = data2.player == nil and "rbxassetid://77304560969574" or PartyMember.PLATE_IMAGE,
		ImageColor3 = 0
	}
	local imageColor

	if data2.player ~= nil then
		imageColor = PartyMember.PLATE_COLOR
	else
		imageColor = data2.color or color
	end

	v6.ImageColor3 = imageColor
	local v8 = v5(v6)
	local v9

	if data2.player ~= nil then
		v9 = function(p2)
			task.spawn(PartyMember.buildViewport, p2, data2.player)
		end
	else
		v9 = object:Create("ImageLabel")({
			Name = "Icon",
			ZIndex = 2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.71, 0.71),
			BackgroundTransparency = 1,
			Image = data2.img or "",
			ScaleType = Enum.ScaleType.Crop,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1, 0)
			})
		})
	end

	v3[1], v3[2], v3[3] = v4, v8, v9
	return v2(v3)
end