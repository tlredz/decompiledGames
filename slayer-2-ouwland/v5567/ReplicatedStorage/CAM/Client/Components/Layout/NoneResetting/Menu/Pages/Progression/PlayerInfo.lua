local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Clans = require(ReplicatedStorage.CAM.Clans)
local Load_Custom = require(ReplicatedStorage.CAM.Global.Load_Custom)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
return function(object)
	local v = gameSettings.raceColors[data.Race.Value] or gameSettings.raceColors.Human
	local v2 = math.floor(data.Exp.Goal.Value / gameSettings.expPerLevel)
	local value = data.Clan.Value
	local displayName = localPlayer.DisplayName

	if value ~= "" and value ~= "None" then
		local tier = Clans.TierOf(value)

		if tier == nil then
			displayName = `{displayName} {value}`
		else
			displayName = `{displayName} <font color="#{tier.color:ToHex()}">{value}</font>`
		end
	end

	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 0.2),
		Name = "PlaeyrInfoHolder",
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.01)
		}),
		object:Create("Frame")({
			Size = UDim2.fromScale(1, 1),
			Instance.new("UIAspectRatioConstraint"),
			Name = "IconHolder",
			BackgroundTransparency = 1,
			object:Create("Frame")({
				Name = "Bg",
				Size = UDim2.fromScale(0.8, 0.8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = v,
				object:Create("UICorner")({
					CornerRadius = UDim.new(0.15)
				}),
				Rotation = 45,
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.5),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = -120
				}),
				object:Create("UIShadow")({
					BlurRadius = UDim.new(1)
				})
			}),
			object:Create("CanvasGroup")({
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				object:Create("ViewportFrame")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					object:Create("UICorner")({
						CornerRadius = UDim.new(0.25)
					}),
					function(parent)
						local worldModel = Instance.new("WorldModel", parent)
						local clone = ReplicatedStorage.Assets.StarterCharacterCloneable:Clone()
						clone.Parent = worldModel
						clone.HumanoidRootPart.Anchored = true
						local camera = Instance.new("Camera")
						camera.Parent = parent
						parent.CurrentCamera = camera
						local v3 = clone.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2).Position
						local position = clone.HumanoidRootPart.Position
						local humanIdle = game.ReplicatedStorage.Assets.Animations.mainPlace.humanIdle

						if data.Race.Value == "Demon" then
							camera.CFrame = CFrame.new(v3, position) + createVector(0, 1.5, 0)
							humanIdle = game.ReplicatedStorage.Assets.Animations.mainPlace.demonIdle
						else
							camera.CFrame = CFrame.new(v3, position) + createVector(0, 1.25, 0)
						end

						clone.Humanoid.Animator:LoadAnimation(humanIdle):Play(0)
						Load_Custom(localPlayer, clone, data, true)
					end
				})
			})
		}),
		object:Create("Frame")({
			Name = "InfoHolder",
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical
			}),
			object:Create("TextLabel")({
				Name = "FullName",
				Size = UDim2.fromScale(3, 0.35),
				BackgroundTransparency = 1,
				RichText = true,
				Text = displayName,
				TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = true,
				Font = Enum.Font.SourceSansBold
			}),
			object:Create("Frame")({
				Name = "RaceHolder",
				Size = UDim2.fromScale(1, 0.22),
				BackgroundTransparency = 1,
				object:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 6)
				}),
				object:Create("TextLabel")({
					Name = "Level",
					LayoutOrder = 1,
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					Text = `Lv {v2}`,
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold
				}),
				object:Create("TextLabel")({
					Name = "Race",
					LayoutOrder = 2,
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					Text = data.Race.Value,
					TextColor3 = v,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold
				})
			})
		})
	})
end