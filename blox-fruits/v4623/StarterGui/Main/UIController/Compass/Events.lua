local CollectionService = game:GetService("CollectionService")
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local GuideModule = require(game.ReplicatedStorage.GuideModule)
require(game.ReplicatedStorage.React.RobloxTypes)
local Global = require(game.ReplicatedStorage.Global)
require(game.ReplicatedStorage.Modules.Util.Trove)
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local localPlayer = game.Players.LocalPlayer

local function e(className: string, items, list)
	local instance = Instance.new(className)

	if items then
		for k, item in pairs(items) do
			if item == nil then
				continue
			end

			local v = k
			local v2 = item
			local success, result = pcall(function(...)
				instance[v] = v2
			end)

			if not success then
				task.spawn(error, result)
			end
		end
	end

	if list then
		for _, v in ipairs(list) do
			if v and typeof(v) == "Instance" then
				v.Parent = instance
			end
		end
	end

	return instance
end

return function(callback, callback2, callback3)
	local parent = e("Frame", {
		Name = "EventTrackers",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = GuideModule.SideCompass.Frame
	}, { (Instance.new("UIAspectRatioConstraint")) })

	local function fn(data)
		local v4 = {
			Name = "TextButton",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderMode = Enum.BorderMode.Outline,
			Rotation = 0,
			Text = "",
			Size = UDim2.fromScale(0.3, 0.3),
			Parent = parent
		}
		local v6 = e("UIScale", {
			Scale = LastInput:Get() == "Touch" and 1.25 or 1
		})
		local v7 = e("UICorner", {
			CornerRadius = UDim.new(1, 0)
		})
		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		local v10 = {
			Name = "Icon",
			Image = data.Image,
			ImageTransparency = 0,
			BackgroundTransparency = 1,
			Size = data.ImageSize or UDim2.fromScale(1, 1),
			Position = data.ImagePosition or UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = data.ImageScaleType or Enum.ScaleType.Fit,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageRectOffset = data.ImageRectOffset or Vector2.new(0, 0),
			ImageRectSize = data.ImageRectSize or Vector2.new(0, 0),
			ZIndex = 2
		}
		local v12

		if data.ImageUICorner ~= false then
			v12 = e("UICorner", {
				CornerRadius = UDim.new(1, 0)
			})
		end

		local v13

		if data.HalloweenBatFlares == true then
			v13 = e("ImageLabel", {
				Name = "TopLeftBat",
				Image = "rbxassetid://95554109531917",
				ImageTransparency = 0,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.403, 0.403),
				Position = UDim2.fromScale(0.078, 0.15),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 2
			})
		end

		local v14

		if data.HalloweenBatFlares == true then
			v14 = e("ImageLabel", {
				Name = "BottomRightBat",
				Image = "rbxassetid://95554109531917",
				ImageTransparency = 0,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.403, 0.403),
				Position = UDim2.fromScale(1, 0.8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Rotation = -70,
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 2
			})
		end

		return (e("TextButton", v4, {
			v6,
			v7,
			uIAspectRatioConstraint,
			e("ImageLabel", v10, { v12, v13, v14 }),
			e("UIGradient", {
				Color = data.GradientColorSequence,
				Rotation = 90
			}),
			(e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = data.UIStrokeColor or Color3.fromRGB(),
				Thickness = LastInput:Get() == "Touch" and 1 or 1.5,
				Transparency = 0
			}))
		}))
	end

	local v2 = nil
	v2 = {
		["Lightning Event"] = {
			Enabled = false,
			Description = "Defeat a Lightning Enemy",
			LayoutOrder = 1,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#05e2ff")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#05e2ff")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#20b7e3")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#20b7e3"))
					}),
					ImageRectSize = Vector2.new(256, 256),
					Image = "rbxassetid://135458186392535"
				}))
			end
		},
		["Oni Realm"] = {
			Enabled = false,
			Description = "Travel to the Oni Realm",
			LayoutOrder = 2,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#e97481")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#e97481")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#e04458")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#e04458"))
					}),
					ImageScaleType = Enum.ScaleType.Stretch,
					ImageRectOffset = Vector2.new(256, 0),
					ImageRectSize = Vector2.new(256, 256),
					Image = "rbxassetid://105774483197785"
				}))
			end
		},
		["Corrupted Event"] = {
			Enabled = true,
			Description = "Defeat a Corrupted Enemy",
			LayoutOrder = 3,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#dc2f44")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#dc2f44")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#95233e")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#95233e"))
					}),
					ImageScaleType = Enum.ScaleType.Stretch,
					ImageSize = UDim2.fromScale(1.05, 0.75),
					ImagePosition = UDim2.fromScale(0.5, 0.55),
					Image = "rbxassetid://79867495754613"
				}))
			end
		},
		["Slap Arena"] = {
			Enabled = false,
			Description = "Locate the arena",
			LayoutOrder = 4,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#65d6ff")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#65d6ff")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#31beff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#31beff"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.85, 0.85),
					ImagePosition = UDim2.fromScale(0.525, 0.475),
					Image = "rbxassetid://117238248788196"
				}))
			end
		},
		["Celestial Domain"] = {
			Enabled = false,
			Description = "Travel to the Celestial Domain",
			LayoutOrder = 5,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#b48fff")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#b48fff")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8856f8")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#8856f8"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(1, 1),
					ImageRectSize = Vector2.new(256, 256),
					ImagePosition = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://105774483197785"
				}))
			end
		},
		["Tournament Fisherman"] = {
			Enabled = false,
			Description = "Locate the Fisherman",
			LayoutOrder = 6,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#fff700")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#fff700")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#eeba00")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#dd9e00"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(1, 1),
					ImagePosition = UDim2.fromScale(0.5, 0.45),
					Image = "rbxassetid://75771084463036"
				}))
			end
		},
		["Event Fishing Spot"] = {
			Enabled = false,
			Description = "Locate the Event Fishing Spot",
			LayoutOrder = 7,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#65d6ff")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#65d6ff")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#31beff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#31beff"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.85, 0.85),
					ImagePosition = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://100294043315004"
				}))
			end
		},
		["Celebration Teleporter"] = {
			Enabled = false,
			Description = "Locate the Celebration Teleporter",
			LayoutOrder = 8,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#fff157")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#fff157")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#ffd631")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#ffd631"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(1.15, 1.15),
					ImagePosition = UDim2.fromScale(0.55, 0.45),
					Image = "rbxassetid://116653529485059",
					ImageUICorner = false
				}))
			end
		},
		RedTree = {
			Enabled = false,
			Description = "Locate the event",
			LayoutOrder = 9,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#ff8383")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#ff8383")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#f44747")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#f44747"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.95, 0.95),
					ImagePosition = UDim2.fromScale(0.5, 0.55),
					Image = "rbxassetid://115122652256723",
					ImageUICorner = false
				}))
			end
		},
		PurpleTree = {
			Enabled = false,
			Description = "Locate the event",
			LayoutOrder = 10,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#b8afff")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#b8afff")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#a189ff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#a189ff"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.95, 0.95),
					ImagePosition = UDim2.fromScale(0.5, 0.55),
					Image = "rbxassetid://87576381620057",
					ImageUICorner = false,
					HalloweenBatFlares = true
				}))
			end
		},
		["Halloween Event"] = {
			Enabled = false,
			WorkspaceAttribute = "HalloweenEventActive",
			Description = "Locate the trick-or-treat doors",
			LayoutOrder = 10,
			Locations = {},
			TeleportFunction = function()
				local SharedEventData = require(game.ReplicatedStorage.Modules.Data.SharedEventData)
				local currentLocation = localPlayer:GetAttribute("CurrentLocation")
				local exactLocation = localPlayer:GetAttribute("ExactLocation")
				local v4 = false

				for _, eventIsland in SharedEventData.Halloween2025.EventIslands do
					if not (currentLocation == eventIsland or exactLocation == eventIsland) then
						continue
					end

					v4 = true
					break
				end

				if v4 or v2["Halloween Event"].IsOnCooldown == true then
					return false
				end

				v2["Halloween Event"].IsOnCooldown = true
				task.defer(function()
					remotes.CommF_:InvokeServer("TeleportToSpawn", true)
					task.wait(0.1)
					v2["Halloween Event"].IsOnCooldown = nil
				end)
				print("teleporting")
				return true
			end,
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#ffdf3d")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#ffdf3d")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#ff9d00")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#ff9d00"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.85, 0.85),
					ImagePosition = UDim2.fromScale(0.51, 0.475),
					Image = "rbxassetid://89048261649610",
					UIStrokeColor = Color3.fromRGB(231, 135, 0),
					HalloweenBatFlares = true
				}))
			end
		},
		WerewolfBossDoor = {
			Enabled = true,
			Description = "Locate the Werewolf Boss",
			LayoutOrder = 10,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#a200ff")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#a200ff")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#7300ff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#7300ff"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.9, 0.9),
					ImagePosition = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://125014841388221",
					ImageUICorner = false
				}))
			end
		},
		EasterCodex = {
			Enabled = true,
			WorkspaceAttribute = "EasterClaimEnabled",
			SinkClick = true,
			Description = "Find the Eggs",
			LayoutOrder = 11,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				local parent2 = fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#d4ff78")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#abfbff")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#abfbff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#d5b3ff"))
					}),
					UIStrokeColor = Color3.fromRGB(40, 74, 58),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.9, 0.9),
					ImagePosition = UDim2.fromScale(0.5, 0.5),
					ImageRectOffset = Vector2.new(272, 0),
					ImageRectSize = Vector2.new(136, 168),
					Image = "rbxassetid://88521607622333",
					ImageUICorner = false
				})
				local frame = Instance.new("Frame")
				frame.Active = false
				frame.Selectable = false
				frame.Visible = false
				frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				frame.Size = UDim2.fromScale(0.4, 0.4)
				frame.Position = UDim2.fromScale(0.7, -0.1)
				local uICorner = Instance.new("UICorner", frame)
				uICorner.CornerRadius = UDim.new(1, 0)
				frame.Parent = parent2
				local EasterNetwork = require(game.ReplicatedStorage.Controllers.UI.EasterCodex.EasterNetwork)
				local EasterCodex = require(game.ReplicatedStorage.Controllers.UI.EasterCodex)

				local function updateBadgeState()
					local v5 = false

					if not EasterCodex.IsOpen() then
						for _, v7 in pairs(EasterNetwork.Data.Index) do
							if not v7.IsNew then
								continue
							end

							v5 = true
							break
						end
					end

					frame.Visible = v5 == true
				end

				local connection = EasterNetwork.OnItemChanged(updateBadgeState)
				updateBadgeState()
				local mouseButton1ClickConnection = parent2.MouseButton1Click:Connect(function(_, _: number)
					local EasterCodex2 = require(game.ReplicatedStorage.Controllers.UI.EasterCodex)
					EasterCodex2:Toggle()
					frame.Visible = false
				end)
				parent2.Destroying:Once(function(...)
					connection:Disconnect()
					mouseButton1ClickConnection:Disconnect()
				end)
				return parent2
			end
		},
		ValentinesEvent = {
			Enabled = false,
			Description = "Locate the Valentine NPC",
			LayoutOrder = 12,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#ffc5e7")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#ffc5e7")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#ed8fc2")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#ed8fc2"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.9, 0.9),
					ImagePosition = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://122115937951784",
					ImageUICorner = false
				}))
			end
		},
		ValentinesEvent_Delivery = {
			Enabled = false,
			Description = "Locate the Valentine NPC",
			LayoutOrder = 13,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#ffc5e7")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#ffc5e7")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#ed8fc2")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#ed8fc2"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.9, 0.9),
					ImagePosition = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://103892064380560",
					ImageUICorner = false
				}))
			end
		},
		SealedEgg = {
			Enabled = true,
			Description = "Locate the Sealed Showdown Egg",
			LayoutOrder = 14,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#b50000")),
						ColorSequenceKeypoint.new(0.492, Color3.fromHex("#b50000")),
						ColorSequenceKeypoint.new(0.513, Color3.fromHex("#b30000")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#b30000"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(1.1, 1.1),
					ImagePosition = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://108834373468415",
					ImageUICorner = false
				}))
			end
		},
		[`Friendly Neighborhood Egg_{localPlayer.UserId}`] = {
			Enabled = true,
			Description = "Deliver your egg.",
			LayoutOrder = 15,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#ffff61")),
						ColorSequenceKeypoint.new(0.492, Color3.fromHex("#ffff61")),
						ColorSequenceKeypoint.new(0.513, Color3.fromHex("#cf8a00")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#cf8a00"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.95, 0.95),
					ImagePosition = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://92303998065476",
					ImageUICorner = true
				}))
			end
		},
		AprilFoolsGacha = {
			Enabled = true,
			Description = "Locate the April Fools spinner",
			LayoutOrder = 10,
			Locations = {},
			new = function(p)
				if p.TextButton then
					return p.TextButton
				end

				return (fn({
					GradientColorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("#002806")),
						ColorSequenceKeypoint.new(0.499, Color3.fromHex("#20AA1D")),
						ColorSequenceKeypoint.new(0.5, Color3.fromHex("#053300")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("#306E00"))
					}),
					ImageScaleType = Enum.ScaleType.Fit,
					ImageSize = UDim2.fromScale(0.8, 0.8),
					ImagePosition = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://115609055961734",
					ImageUICorner = true
				}))
			end
		}
	}
	local thread = nil

	local function placeEventIconsAroundCompass(flag: boolean?)
		if not next(v2) or (callback2() or GuideModule.Data.Tracking == true or callback3()) then
			return
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		local function updateButtonPlacement()
			local v4 = {}

			for _, v5 in pairs(v2) do
				local textButton = v5.TextButton

				if textButton then
					table.insert(v4, {
						Button = textButton,
						LayoutOrder = textButton.LayoutOrder
					})
				end
			end

			if #v4 == 0 then
				return
			end

			table.sort(v4, function(a, b)
				return a.LayoutOrder < b.LayoutOrder
			end)
			local absoluteSize = GuideModule.SideCompass.Frame.AbsoluteSize
			local v5 = absoluteSize.X / 2 + (LastInput:Get() == "Touch" and 3 or 0)
			local vector = Vector2.new(absoluteSize.X / 2, absoluteSize.Y / 2)

			for i = 1, #v4 do
				local v6 = v4[i]
				local v7 = math.rad(-310 - (i - 1) * 45)
				local v8 = vector.X + math.cos(v7) * v5
				local v9 = vector.Y + math.sin(v7) * v5
				v6.Button.AnchorPoint = Vector2.new(0, 0)
				v6.Button.Position = UDim2.fromOffset(
					v8 - v6.Button.AbsoluteSize.X / 2,
					v9 - v6.Button.AbsoluteSize.Y / 2
				)
			end
		end

		if flag then
			thread = task.delay(0.1, function()
				thread = nil
				updateButtonPlacement()
			end)
		else
			updateButtonPlacement()
		end
	end

	local fn2

	fn2 = function()
		if not next(v2) then
			return
		end

		local v4 = callback2() or callback3() or GuideModule.Data.Tracking == true

		for tag, v5 in pairs(v2) do
			if v5.Enabled == false then
				if v5.TextButton then
					v5.TextButton:Destroy()
					v5.TextButton = nil
				end
			else
				if v5.CollectionTagAdded == nil then
					local thread2 = nil
					local CollectionService2 = game:GetService("CollectionService")
					v5.CollectionTagAdded = CollectionService2:GetInstanceAddedSignal(tag):Connect(function(_)
						if thread2 then
							task.cancel(thread2)
							thread2 = nil
						end

						thread2 = task.delay(0.5, function()
							thread2 = nil
							fn2()
						end)
					end)
				end

				if v5.CollectionTagRemoved == nil then
					local CollectionService2 = game:GetService("CollectionService")
					local v6 = v5
					v5.CollectionTagRemoved = CollectionService2:GetInstanceRemovedSignal(tag):Connect(function(p)
						local location = v6.Locations[p]
						v6.Locations[p] = nil

						if location then
							if GuideModule.Data.LastClosestNPC == location.UID and not next(v6.Locations) then
								callback(false)
							else
								fn2()
							end
						end
					end)
				end

				local CollectionService2 = game:GetService("CollectionService")

				for _, instance in pairs(CollectionService2:GetTagged(tag)) do
					if v5.Locations[instance] or not (not v5.ShouldCreateLocation or v5.ShouldCreateLocation(instance) == true) then
						continue
					end

					local HttpService = game:GetService("HttpService")
					local v6 = {
						UID = HttpService:GenerateGUID()
					}

					if instance:IsA("Attachment") then
						local v7 = instance

						function v6.GetPosition()
							return v7.WorldPosition
						end
					elseif instance:IsA("Model") then
						local v7 = instance

						function v6.GetPosition()
							return v7:GetPivot().Position
						end
					elseif instance:IsA("BasePart") then
						local v7 = instance

						function v6.GetPosition()
							return v7.Position
						end
					elseif instance:IsA("Workspace") then
						local v7 = instance

						function v6.GetPosition()
							return v7:GetPivot().Position
						end
					end

					if v6.GetPosition then
						v5.Locations[instance] = v6
					else
						warn((`unknown instance: {instance.ClassName}`))
					end
				end

				local v6

				if v5.WorkspaceAttribute then
					if workspace:GetAttribute(v5.WorkspaceAttribute) then
						v6 = true
					else
						if v5.TextButton then
							v5.TextButton:Destroy()
							v5.TextButton = nil
						end

						continue
					end
				else
					v6 = false
				end

				if next(v5.Locations) or v6 then
					local textButton = v5.new(v5)

					if not v5.TextButton then
						textButton.LayoutOrder = v5.LayoutOrder
						local v8 = v5
						local v9 = tag
						textButton.Activated:Connect(function()
							if v8.SinkClick or (v8.TeleportFunction and v8.TeleportFunction() or v8.IsOnCooldown) then
								return
							end

							local maid = callback(true)

							if not maid then
								return
							end

							if v9 == "Lightning Event" then
								Global.TrackingLightningEvent = true
								maid:Add(game.Players.LocalPlayer:GetAttributeChangedSignal("LightningEnemyKilled"):Connect(function(...)
									callback(false)
								end))
							elseif v9 == "Oni Realm" or v9 == "Celestial Domain" or v9 == "Celebration NPC" then
								maid:Add(game.Players.LocalPlayer:GetAttributeChangedSignal("CurrentLocation"):Connect(function()
									local currentLocation = game.Players.LocalPlayer:GetAttribute("CurrentLocation")

									if v9 == "Oni Realm" and currentLocation == "Oni Realm" then
										callback(false)
									elseif v9 == "Celestial Domain" and currentLocation == "Celestial Domain" then
										callback(false)
									elseif v9 == "Celebration NPC" and currentLocation == "Celebration Domain" then
										callback(false)
									end
								end))
							elseif v9 == "Corrupted Event" then
								Global.TrackingCorruptedEvent = true
								maid:Add(game.Players.LocalPlayer:GetAttributeChangedSignal("CorruptedEnemyKilled"):Connect(function(...)
									callback(false)
								end))
							elseif v9 == "Halloween Event" then
								maid:Add(game.Players.LocalPlayer:GetAttributeChangedSignal("TrickOrTreatDoorInteracted"):Connect(function(...)
									callback(false)
								end))
							end

							function Global.GuideCallbacks.SpecialLocation(vector: Vector3, p, p2)
								debug.profilebegin("SpecialLocation")
								local v10 = 1e999
								local v11 = nil
								local v12 = nil

								for k, location in pairs(v8.Locations) do
									local Tracking = require(game.ReplicatedStorage.Modules.Tracking)
									local location2 = Tracking:GetLocation(game.Players.LocalPlayer)
									local cFrame = workspace.CurrentCamera.CFrame

									if location2 and location2.CFrame then
										cFrame = location2.CFrame
									end

									local position = location.GetPosition()
									local magnitude = (cFrame.Position - position).Magnitude

									if not (magnitude < v10) then
										continue
									end

									v12 = position
									v11 = location
									v10 = magnitude
								end

								debug.profileend()

								if v11 == nil then
									callback(false)
									return nil
								end

								GuideModule.Data.LastClosestNPC = v11.UID
								return {
									v12,
									v9,
									v8.Description,
									false
								}
							end
						end)
						v5.TextButton = textButton
					end

					textButton.Visible = true
				elseif v5.TextButton then
					v5.TextButton:Destroy()
					v5.TextButton = nil
				end
			end
		end

		placeEventIconsAroundCompass()
		parent.Visible = v4 == false
	end

	fn2()
	GuideModule.SideCompass:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		placeEventIconsAroundCompass(true)
	end)

	local function updateWorkspaceAttributes()
		fn2()
	end

	fn2()
	workspace:GetAttributeChangedSignal("HalloweenEventActive"):Connect(updateWorkspaceAttributes)
	workspace:GetAttributeChangedSignal("EasterClaimEnabled"):Connect(updateWorkspaceAttributes)
	task.spawn(function()
		if not v2.AprilFoolsGacha.Enabled then
			return
		end

		local v4 = nil

		local function addPartToTrack(model)
			if not model:IsA("Model") then
				return
			end

			local floorPos = model:GetAttribute("FloorPos") or model:GetPivot().Position

			if v4 then
				v4.Position = floorPos
				return
			end

			local part = Instance.new("Part")
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Position = floorPos
			part.Parent = workspace
			part:AddTag("AprilFoolsGacha")
			v4 = part
		end

		for _, v5 in CollectionService:GetTagged("AprilFoolsGacha") do
			addPartToTrack(v5)
			fn2()
		end

		CollectionService:GetInstanceAddedSignal("AprilFoolsGacha"):Connect(function(p)
			addPartToTrack(p)
			fn2()
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function aprilfoolsgachaActiveChanged()
			v2.AprilFoolsGacha.Enabled = game.Players.LocalPlayer:GetAttribute("AprilFoolsGachaTracker") and true or false
			fn2()
		end

		game.Players.LocalPlayer:GetAttributeChangedSignal("AprilFoolsGachaTracker"):Connect(aprilfoolsgachaActiveChanged)
		aprilfoolsgachaActiveChanged() -- equivalent call inferred; original call site unknown
	end)
	return {
		updateEventTrackers = fn2
	}
end