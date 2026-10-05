local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local faye = require(ReplicatedStorage.Packages.faye)
local localPlayer = Players.LocalPlayer
local info = faye.Info(0.1)
local miscEquippedBaitId = DataValue.new("Misc/EquippedBaitId", 0)
return function(maid, _, object)
	local value = maid:Value(miscEquippedBaitId:Get())
	local image = maid:Value("")
	local value3 = maid:Value(0.75)
	local value4 = maid:Value(0.95)
	local value5 = maid:Value(0.95)
	local value6 = maid:Value(Color3.new(0.53, 0.78, 0.62))
	local text = maid:Value("Equip Bait")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function entryId(instance)
		if instance == nil then
			return nil
		end

		local id = instance:FindFirstChild("Id")

		if id == nil or not id:IsA("ValueBase") then
			return nil
		end

		return id.Value
	end

	local function isSelectedEquipped()
		local v = value:Get()

		if v == 0 then
			return false
		else
			local v4 = entryId(object:Get()) -- equivalent call inferred; original call site unknown
			return v4 == v
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resolveEquippedConfig()
		local v = value:Get()

		if type(v) ~= "number" or v == 0 then
			return nil
		end

		local success, itemFromId = pcall(Character_info_provider.GetItemFromId, localPlayer, v)

		if success and itemFromId ~= nil then
			return Items[itemFromId.Name]
		end

		return nil
	end

	local function update()
		local equippedConfig = resolveEquippedConfig() -- equivalent call inferred; original call site unknown
		image:Set(equippedConfig == nil and "" or equippedConfig.Icon or "")

		if equippedConfig == nil then
			value3:Reset()
		else
			value3:Set(0)
		end

		local v = value:Get()
		local v2

		if v == 0 then
			v2 = false
		else
			local v4 = entryId(object:Get()) -- equivalent call inferred; original call site unknown
			v2 = v4 == v
		end

		if v2 then
			text:Set("UnEquip")
			value6:Set(Color3.new(1, 0, 0))
		else
			text:Reset()
			value6:Reset()
		end
	end

	update()
	maid:Connect(object.Changed, update)
	maid:Add(miscEquippedBaitId.Changed:Connect(function(p)
		value:Set(p)
		update()
	end))
	return maid:Create("Frame")({
		Name = "BaitEquipped",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		maid:Create("Frame")({
			Name = "Holder",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			maid:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal
			}),
			maid:Create("Frame")({
				Name = "Slot",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Instance.new("UIAspectRatioConstraint"),
				maid:Create("Frame")({
					Name = "Bg",
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(0.8, 0.8),
					BackgroundTransparency = maid:Animation(value5, info),
					maid:Create("UICorner")({
						CornerRadius = UDim.new(0.15, 0)
					})
				}),
				maid:Create("Frame")({
					Name = "StrokeHolder",
					Size = UDim2.fromScale(0.88, 0.88),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					maid:Create("UICorner")({
						CornerRadius = UDim.new(0.15, 0)
					}),
					maid:Create("UIStroke")({
						Color = Color3.new(1, 1, 1),
						Transparency = maid:Animation(value4, info),
						Thickness = 1
					})
				}),
				maid:Create("ImageLabel")({
					Name = "Img",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.6, 0.6),
					BackgroundTransparency = 1,
					ImageTransparency = maid:Animation(value3, info),
					Image = image
				})
			})
		}),
		GradientButton(maid, {
			Properties = {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 1.15),
				Size = UDim2.fromScale(0.2, 0.4)
			},
			GradientTransparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.75, 0.5),
				NumberSequenceKeypoint.new(1, 0.5)
			}),
			TextXAlignment = Enum.TextXAlignment.Center,
			Clicked = function()
				local v2 = entryId(object:Get()) -- equivalent call inferred; original call site unknown

				if v2 == nil then
					return
				end

				local toServer = SignalEvent.ToServer
				local v4 = value:Get()
				local v5

				if v4 == 0 then
					v5 = false
				else
					local v7 = entryId(object:Get()) -- equivalent call inferred; original call site unknown
					v5 = v7 == v4
				end

				toServer("EquipBait", v5 and 0 or v2)
			end,
			BgColor = maid:Animation(value6, info),
			GradientRotation = -90,
			Text = text,
			ContentColor = Color3.new(1, 1, 1)
		})
	})
end