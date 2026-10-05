local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnLocked = require(script.UnLocked)
local UnlockPrevious = require(script.UnlockPrevious)
require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.Pages["Skill Tree"].TreeConfigurations)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local SkillTreeholder = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.15)
local info2 = faye.Info(0.3)
local info3 = faye.Info(0.2)
local uDim = UDim2.fromScale(0.95, 0.32)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.04, 0),
	NumberSequenceKeypoint.new(0.88, 0),
	NumberSequenceKeypoint.new(1, 1)
})
return function(object, data, p, p2)
	local v = false
	local locked = data.Locked

	if locked then
		if data.Requirements == nil then
			locked = false
		else
			locked = p == nil or not p.Locked
		end
	end

	if locked then
		for k, requirement in data.Requirements do
			local v3 = SkillTreeholder.RequirementsSolver[k]

			if not v3 or v3.CanBuy(Players.LocalPlayer, data.Name, requirement) then
				continue
			end

			v = true
			break
		end
	end

	local v2 = false
	return object:Create("CanvasGroup")({
		Name = "EquipInfo",
		Size = object:Animation(UDim2.fromScale(0.15, 0.5), info, {
			From = UDim2.fromScale(0.12, 0.4)
		}),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.925),
		BackgroundTransparency = 0.65,
		GroupTransparency = object:Animation(0, info3, {
			From = 1
		}),
		BackgroundColor3 = Color3.new(0.35, 0.35, 0.35),
		ZIndex = 2,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0, 6)
		}),
		object:Create("Frame")({
			Name = "Gloss",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -8, 1, -8),
			BackgroundTransparency = 0.85,
			object:Create("UICorner")({
				CornerRadius = UDim.new(0, 6)
			}),
			object:Create("UIGradient")({
				Rotation = -80,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) })
			})
		}),
		object:Create("Frame")({
			Name = "TextHolder",
			Size = UDim2.fromScale(0.95, 0.35),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			BackgroundTransparency = 1,
			function()
				if data.Locked then
					return object:Create("ImageLabel")({
						Size = UDim2.fromScale(0.1, 1),
						Instance.new("UIAspectRatioConstraint"),
						BackgroundTransparency = 1,
						Image = BunchaIcons.Locked
					})
				end
			end,
			object:Create("TextLabel")({
				Name = "Txt",
				BackgroundTransparency = 1,
				Position = data.Locked and UDim2.fromScale(0.1, 0) or nil,
				Size = UDim2.fromScale(1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSansSemibold,
				Text = data.DisplayName or data.Name,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Color3.new(1, 1, 1),
				After = function(p3)
					if not data.Locked then
						return
					end

					p3.TextTransparency = 0.5
					return object:Create("Frame")({
						Size = UDim2.new(1, 0, 0, 1),
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, -3, 0.55, 0),
						After = function(p4)
							local parent = p4.Parent

							-- equivalent calls inferred from this helper; original call sites unknown
							local function updateBounds()
								p4.Size = UDim2.new(parent.TextBounds.X / parent.Parent.AbsoluteSize.X, 6, 0, 1)
							end

							updateBounds() -- equivalent call inferred; original call site unknown
							object:Connect(parent:GetPropertyChangedSignal("TextBounds"), updateBounds)
						end
					})
				end
			})
		}),
		function()
			if locked then
				return object:Create("CanvasGroup")({
					Name = "RequirementsFade",
					Size = uDim,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0.05, 0.465),
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					object:Create("UIGradient")({
						Transparency = numberSequence
					}),
					object:Create("ScrollingFrame")({
						Name = "RequirementsHolder",
						ClipsDescendants = false,
						Size = UDim2.fromScale(1, 1),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						ScrollBarThickness = 0,
						ScrollingDirection = Enum.ScrollingDirection.X,
						CanvasSize = UDim2.fromScale(0, 0),
						object:Create("UIListLayout")({
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0, 8),
							AbsoluteContentSizeOnChangedInit = function(p3)
								p3.Parent.CanvasSize = UDim2.new(0, p3.AbsoluteContentSize.X, 0, 0)
							end
						}),
						object:Iterate(data.Requirements, function(p3, text, object2, _)
							local v3 = SkillTreeholder.RequirementsSolver[p3]

							if v3 == nil then
								return
							end

							local canBuy = v3.CanBuy(Players.LocalPlayer, data.Name, text)
							local color = Color3.new(1, 1, 1)
							local v4 = canBuy and 0.1 or 0.25

							if not canBuy then
								color = Color3.new(1, 0.5, 0.5)
							end

							local v6 = object2:Create("Frame")
							local v7 = {
								Size = UDim2.new(0, 0, 1, 0),
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundTransparency = 1
							}
							local v8 = object2:Create("UIListLayout")({
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								Padding = UDim.new(0, 3)
							})
							local v9 = object2:Create("ImageLabel")
							local v10 = {
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								ZIndex = 2,
								ClipsDescendants = false,
								Image = type(v3.Icon) == "function" and v3.Icon(data.Name) or v3.Icon,
								ImageColor3 = v3.IconColor or color,
								ImageTransparency = v4
							}
							local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
							local v11

							if v3.IconCornerRadius ~= nil then
								v11 = object2:Create("UICorner")({
									CornerRadius = v3.IconCornerRadius
								}) or nil
							end

							v10[1], v10[2] = uIAspectRatioConstraint, v11
							do local _values = table.pack(v8, v9(v10), object2:Create("TextLabel")({
	Size = UDim2.new(0, 0, 1, 0),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	ZIndex = 2,
	TextScaled = true,
	TextTransparency = v4,
	Text = type(v3.DisplayName) == "function" and v3.DisplayName(data.Name) or v3.DisplayName,
	Font = Enum.Font.SourceSansSemibold,
	TextColor3 = color
}), object2:Create("TextLabel")({
	Size = UDim2.new(0, 0, 1.15, 0),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	ZIndex = 2,
	TextScaled = true,
	TextTransparency = canBuy and 0 or 0.15,
	Text = text,
	Font = Enum.Font.SourceSansBold,
	TextColor3 = color,
	Visible = v3.HideValue ~= true
})); for _k = 1, _values.n do v7[_k] = _values[_k] end end
							return v6(v7)
						end)
					})
				})
			end
		end,
		object:Create("Frame")({
			Name = "ButtonHolder",
			Size = locked and UDim2.fromScale(0.8, 0.25) or UDim2.fromScale(0.82, 0.45),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = locked and UDim2.fromScale(0.5, 0.65) or UDim2.fromScale(0.5, 0.45),
			BackgroundTransparency = 1,
			function()
				if not data.Locked then
					return UnLocked(object)
				end

				if p.Locked then
					return UnlockPrevious(object)
				end

				return GradientButton(object, {
					TweenInfo = object.Info(0.1),
					BgColor = not v and Color3.new(0.603922, 1, 0.568627) or Color3.new(1, 0.35, 0.35),
					TextXAlignment = Enum.TextXAlignment.Center,
					TextBoxSize = UDim2.fromScale(1, 1),
					Font = Enum.Font.SourceSansBold,
					GradientTransparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 0.6)
					}),
					Properties = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5)
					},
					Text = v and "REQUIREMENTS NOT MET" or "UNLOCK",
					Clicked = function()
						if v2 == true then
							return
						end

						v2 = true

						if not v then
							local v3 = PopUpCreator.new({
								Type = "LoadingFull"
							})
							local server, text = SignalFunction.ToServer("UnlockSkillTreeNode", data.Name)

							if server == false then
								ReplicatedStorage.Communication.CnC.Notifications.Notification:Fire("Notify", {
									Text = text,
									Type = "Denied"
								})
							else
								ReplicatedStorage.Communication.CnC.Notifications.Notification:Fire("Notify", {
									Text = `You unlocked \\[['{data.DisplayName or data.Name}']<{gameSettings.RichTextPopularConfigs.SoroundColor}>]`,
									Type = "Success"
								})
							end

							v3:Destroy()
						end

						v2 = false
					end
				})
			end
		}),
		OnClean = function()
			if p2.Value == nil then
				return {
					Size = object:Animation(UDim2.fromScale(0.12, 0.4), info2),
					GroupTransparency = object:Animation(1, info2)
				}
			end
		end
	})
end