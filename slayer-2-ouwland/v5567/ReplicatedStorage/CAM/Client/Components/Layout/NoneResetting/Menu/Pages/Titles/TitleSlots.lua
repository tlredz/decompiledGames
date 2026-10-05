local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local TitleController = require(ReplicatedStorage.CAM.Client.Controllers.TitleController)
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local TitleSlot = require(script.Parent.TitleSlot)
local Types = require(script.Parent.Types)
local BOOST_LABELS = Types.BOOST_LABELS
local color = Color3.fromRGB(105, 135, 165)
local color2 = Color3.new(0.35, 0.35, 0.35)
local color3 = Color3.fromRGB(170, 95, 95)
local info = faye.Info(0.2)
local info2 = faye.Info(0.3, Enum.EasingStyle.Back)
local info3 = faye.Info(0.2)
return function(object, object2, p)
	local equippedTitles = Utility.GetData(Players.LocalPlayer, true).EquippedTitles
	local value = object:Value("")
	local v = {
		Vanity = equippedTitles.Vanity
	}

	for i = 1, Titles.BoostSlots do
		v[`Slot{i}`] = equippedTitles.Boost[`Slot{i}`]
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pick()
		local v2 = p[object2:Get()]

		if v2 == nil or not v2.Unlocked then
			return nil
		end

		return v2.Id
	end

	local function ready(callback)
		return callback(value) ~= ""
	end

	local function holdsPick(callback)
		local v2 = v[callback(value)]
		local v3 = callback(object2)
		return v2 ~= nil and v3 ~= "" and callback(v2) == v3
	end

	local function equip()
		local v2 = value:Get()
		local v3 = pick() -- equivalent call inferred; original call site unknown

		if v2 == "" or v3 == nil then
			return
		end

		if v2 == "Vanity" then
			if TitleController.Vanity() == v3 then
				TitleController.UnequipVanity()
			else
				TitleController.EquipVanity(v3)
			end
		else
			local v4 = tonumber((string.sub(v2, 5)))

			if v4 == nil then
				return
			end

			local boost = TitleController.Boost()

			if boost[v4] == v3 then
				TitleController.UnequipBoost(v4)
				return
			end

			for i = 1, Titles.BoostSlots do
				if boost[i] == v3 then
					TitleController.UnequipBoost(i)
				end
			end

			TitleController.EquipBoost(v3, v4)
		end
	end

	object:Connect(object2.Changed, function()
		if object2:Get() == "" then
			value:Set("")
		end
	end)
	return object:Create("Frame")({
		Name = "SlotsBar",
		Position = UDim2.new(0, 0, 1, 8),
		Size = UDim2.fromScale(1, 0.06),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "Vanity",
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			TitleSlot(object, value, equippedTitles.Vanity, "Vanity", object2)
		}),
		object:Create("Frame")({
			Name = "Boosts",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.Name,
				Padding = UDim.new(0, 8)
			}),
			object:Iterate(Titles.BoostSlots, function(p2: number, _, p3)
				return TitleSlot(p3, value, equippedTitles.Boost[`Slot{p2}`], BOOST_LABELS[p2] or tostring(p2), object2)
			end)
		}),
		object:State(function(callback, object3)
			if callback(object2) == "" then
				return
			end

			local v2 = {
				BgColor = false,
				ContentTransparency = false
			}
			return object3:Create("Frame")({
				Name = "EquipButton",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 1.675, 20),
				Size = object3:Animation(UDim2.fromScale(0.25, 1.35), info2, {
					From = UDim2.fromScale(0.175, 0.945)
				}),
				BackgroundTransparency = 1,
				OnClean = function(animator, folder)
					for _, descendant in folder:GetDescendants() do
						if descendant:IsA("TextLabel") then
							animator:LoadAnimation(descendant, {
								TextTransparency = 1
							}, info3):Play()
						elseif descendant:IsA("UIStroke") then
							animator:LoadAnimation(descendant, {
								Transparency = 1
							}, info3):Play()
						elseif descendant:IsA("Frame") then
							animator:LoadAnimation(descendant, {
								BackgroundTransparency = 1
							}, info3):Play()
						end
					end

					return {
						Size = animator:Animation(UDim2.fromScale(0.2, 1.08), info3)
					}
				end,
				GradientButton(object3, {
					Text = object3:Do(function(callback2)
						local v3 = v[callback2(value)]
						local v4 = callback2(object2)
						local v5

						if v3 == nil or v4 == "" then
							v5 = false
						else
							v5 = callback2(v3) == v4
						end

						if v5 then
							return "Unequip"
						end

						return "Equip"
					end),
					Font = Enum.Font.SourceSansBold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextBoxSize = UDim2.fromScale(0.8, 0.55),
					GradientRotation = -90,
					GradientTransparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.8),
						NumberSequenceKeypoint.new(1, 0.1)
					}),
					BgColor = object3:Do(function(callback2)
						local v3 = v[callback2(value)]
						local v4 = callback2(object2)
						local v5

						if v3 == nil or v4 == "" then
							v5 = false
						else
							v5 = callback2(v3) == v4
						end

						local v6

						if v5 then
							v6 = color3
						elseif callback2(value) ~= "" then
							v6 = color
						else
							v6 = color2
						end

						if v2.BgColor then
							return object3:Animation(v6, info)
						end

						v2.BgColor = true
						return v6
					end),
					ContentTransparency = object3:Do(function(callback2)
						local selected = callback2(value) ~= "" and 0 or 0.5

						if v2.ContentTransparency then
							return object3:Animation(selected, info)
						end

						v2.ContentTransparency = true
						return selected
					end),
					CornerRadius = UDim.new(0.3),
					StrokeClick = true,
					Clicked = equip,
					Properties = {
						Size = UDim2.fromScale(0.9, 1),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5)
					}
				})
			})
		end)
	})
end