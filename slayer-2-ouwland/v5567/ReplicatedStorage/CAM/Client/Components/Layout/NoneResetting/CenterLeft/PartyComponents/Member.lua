local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Load_Custom = require(ReplicatedStorage.CAM.Global.Load_Custom)
local Teleporter = require(ReplicatedStorage.CAM.Client.Modules.Teleporter)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.1)
local info2 = faye.Info(0.2)
local color = Color3.new(1, 0.529412, 0.529412)
local color2 = Color3.new(1, 0.85, 0.25)
local flag = false
return function(object, _: string, player, p: number)
	local visible = object:Value(false)
	local v = player.UserId == Players.LocalPlayer.UserId
	local v2 = Worlds.ById[player.Location]
	local v3 = not player.IsInHere

	if v3 then
		v3 = v2 == nil or v2.BanPartyTeleport ~= true
	end

	local value2 = object:Value(UDim2.fromScale(1, 1))
	local value3 = object:Value(Color3.new(1, 1, 1))
	local size = object:Value(UDim2.new(0, 10000, 0.9, 0))
	local value5 = object:Value(0)
	local value6 = object:Value(0)
	local id = Worlds.ByName["Main Menu"].Id
	local isInHere = player.IsInHere

	if not isInHere then
		if game.PlaceId == id then
			isInHere = player.Location == id
		else
			isInHere = false
		end
	end

	local value7 = object:Value(isInHere and 0 or 0.5, info2)

	local function liveDestination()
		local player_Service = ReplicatedStorage:FindFirstChild("Player_Service")
		local parties = player_Service ~= nil and player_Service:FindFirstChild("Parties") or nil

		if parties == nil then
			return nil, nil
		end

		for _, child in parties:GetChildren() do
			local child2 = child:FindFirstChild((tostring(player.UserId)))

			if child2 ~= nil then
				return child2:GetAttribute("Location"), child2:GetAttribute("JobId")
			end
		end

		return nil, nil
	end

	local visible2 = object:Value(false)
	local value9 = object:Value(0)
	local heartbeatConnection = nil
	local now = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopHoldLoop()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resetHold()
		stopHoldLoop() -- equivalent call inferred; original call site unknown
		visible2:Set(false)
		value9:Set(0)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function leave()
		visible:Reset()
		size:Reset()
		value7:Reset()
		value3:Reset()
		value2:Refresh()
		resetHold() -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function afterRelease()
		if Platform_Handler.Platform.Value == "Mobile" then
			leave() -- equivalent call inferred; original call site unknown
		else
			value3:Set(color)
			value7:Set(0)
		end
	end

	return object:Create("Frame")({
		Name = v and "AAMemberFile" or "AMemberFile",
		Size = UDim2.new(1, 0, 0, p),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "HitBox",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 3,
			BackgroundTransparency = 1,
			object:Create("TextButton")({
				Name = "Button",
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 4,
				Text = "",
				BackgroundTransparency = 1,
				MouseEnter = function()
					visible:Set(true)
					value3:Set(color)
					value2:Refresh()
					size:Set(UDim2.new(0, 10000, v3 and 0.635 or 0.8, 0))
					value7:Set(0)
				end,
				MouseLeave = leave,
				MouseButton1Down = function()
					now = os.clock()

					if not v3 then
						return
					end

					stopHoldLoop() -- equivalent call inferred; original call site unknown
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						local v7 = os.clock() - now

						if v7 < 0.3 then
							return
						end

						if not visible2.Value then
							visible2:Set(true)
							value3:Set(color2)
							value7:Set(0.25)
						end

						value9:Set(math.clamp((v7 - 0.3) / 0.7, 0, 1) * 360)

						if v7 >= 1 then
							resetHold() -- equivalent call inferred; original call site unknown
							afterRelease() -- equivalent call inferred; original call site unknown
							task.spawn(function()
								if PopUpCreator.new({
									Type = "Question",
									Content = `Do you want to join {Utility.NameTag(player.DisplayName, true)}?`
								}).Result:Wait() == "Yes" then
									local placeId, jobId = liveDestination()
									local notification = ReplicatedStorage.Communication.CnC.Notifications.Notification

									if placeId == nil then
										notification:Fire("Notify", {
											Text = `{player.DisplayName} is no longer in your party`,
											Type = "Denied"
										})
										return
									end

									if jobId == game.JobId then
										notification:Fire("Notify", {
											Text = `{player.DisplayName} is already in this server`,
											Type = "Denied"
										})
										return
									end

									local v10 = Worlds.ById[placeId]

									if v10 == nil or v10.BanPartyTeleport ~= true then
										Teleporter.Request({
											placeId = placeId,
											jobId = jobId
										})
									else
										notification:Fire("Notify", {
											Text = `{player.DisplayName} is in the {v10.Name} right now`,
											Type = "Denied"
										})
									end
								end
							end)
						end
					end)
				end,
				MouseButton1Up = function()
					local v7 = os.clock() - now
					local value10 = visible2.Value
					resetHold() -- equivalent call inferred; original call site unknown
					afterRelease() -- equivalent call inferred; original call site unknown

					if not v3 or not value10 and v7 < 0.3 then
						ScreenEffects.CircleClick()

						if flag then
							return
						end

						flag = true

						if PopUpCreator.new({
							Type = "Question",
							Content = v and "Are you sure you want to leave this party?" or `Are you sure you want to kick {Utility.NameTag(player.DisplayName, true)} from this party?`
						}).Result:Wait() == "Yes" then
							SignalFunction.ToServer("Remove From Party", player.UserId)
						end

						flag = false
					end
				end
			})
		}),
		object:Create("Frame")({
			Name = "Actual",
			Size = UDim2.fromScale(10, 1),
			BackgroundTransparency = 1,
			function()
				if v3 then
					return object:Create("Frame")({
						Name = "Radial",
						Visible = visible2,
						ZIndex = 0,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, 6, 1, 6),
						BackgroundTransparency = 1,
						object:Create("Frame")({
							Name = "Left",
							Size = UDim2.fromScale(0.5, 1),
							BackgroundTransparency = 1,
							ClipsDescendants = true,
							object:Create("Frame")({
								Size = UDim2.fromScale(2, 1),
								BackgroundTransparency = 1,
								object:Create("UICorner")({
									CornerRadius = UDim.new(1)
								}),
								object:Create("UIStroke")({
									Thickness = 2,
									BorderOffset = UDim.new(0, -3),
									Color = Color3.new(1, 1, 1),
									object:Create("UIGradient")({
										Transparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 0),
											NumberSequenceKeypoint.new(0.495, 0),
											NumberSequenceKeypoint.new(0.505, 1),
											NumberSequenceKeypoint.new(1, 1)
										}),
										Rotation = object:Do(function(callback)
											return (math.clamp(180 - callback(value9), 0, 180))
										end)
									})
								})
							})
						}),
						object:Create("Frame")({
							Name = "Right",
							Position = UDim2.fromScale(0.5, 0),
							Size = UDim2.fromScale(0.5, 1),
							BackgroundTransparency = 1,
							ClipsDescendants = true,
							object:Create("Frame")({
								Size = UDim2.fromScale(2, 1),
								Position = UDim2.fromScale(-1, 0),
								BackgroundTransparency = 1,
								object:Create("UICorner")({
									CornerRadius = UDim.new(1)
								}),
								object:Create("UIStroke")({
									Thickness = 2,
									BorderOffset = UDim.new(0, -3),
									Color = Color3.new(1, 1, 1),
									object:Create("UIGradient")({
										Transparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 0),
											NumberSequenceKeypoint.new(0.495, 0),
											NumberSequenceKeypoint.new(0.505, 1),
											NumberSequenceKeypoint.new(1, 1)
										}),
										Rotation = object:Do(function(callback)
											return -math.clamp(callback(value9) - 180, 0, 180)
										end)
									})
								})
							})
						})
					})
				end

				return nil
			end,
			object:Create("CanvasGroup")({
				Name = "Holder",
				GroupTransparency = object:Animation(value7, info2, {
					From = 1
				}),
				OnClean = function()
					return {
						GroupTransparency = object:Animation(1, info2)
					}
				end,
				BackgroundColor3 = object:Animation(value3, info2),
				Size = object:Animation(value2, info, {
					AlwaysFrom = UDim2.fromScale(0.95, 0.925)
				}),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 0,
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				object:Create("Frame")({
					Name = "ContentHolder",
					Size = UDim2.fromScale(1, 1),
					ZIndex = 2,
					BackgroundTransparency = 1,
					object:Create("UIListLayout")({
						Padding = UDim.new(0, 1),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						[object:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
							if p2.Parent == nil or p2.Parent:FindFirstChild("IconHolder") == nil then
								return
							end

							local uDim = UDim2.new(0, p2.AbsoluteContentSize.X, p2.Parent.Size.Y.Scale, 0)
							p2.Parent.Parent.Parent.Size = uDim
							local hitBox = p2.Parent.Parent.Parent.Parent.HitBox

							if uDim.X.Offset >= hitBox.Size.X.Offset then
								hitBox.Size = uDim
							end
						end
					}),
					object:Create("Frame")({
						Name = "ActionTxt",
						Visible = visible,
						ClipsDescendants = true,
						Size = object:Do(function(callback)
							return UDim2.new(0, math.max(callback(value5), callback(value6) + 15) + 10, 1, 0)
						end),
						BackgroundTransparency = 1,
						object:Create("UIListLayout")({
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(-0.15, 0)
						}),
						object:Create("TextLabel")({
							Name = "Main",
							LayoutOrder = 1,
							Size = size,
							BackgroundTransparency = 1,
							TextXAlignment = Enum.TextXAlignment.Center,
							Text = v and "Leave" or "Kick",
							TextScaled = true,
							Font = Enum.Font.SourceSansBold,
							TextBoundsOnChangedInit = function(p2)
								if p2.TextBounds.X > 0 then
									value5:Set(p2.TextBounds.X)
								end
							end
						}),
						function()
							if v3 then
								return object:Create("TextLabel")({
									Name = "Sub",
									LayoutOrder = 2,
									Size = UDim2.new(0, 10000, 0.55, 0),
									BackgroundTransparency = 1,
									TextXAlignment = Enum.TextXAlignment.Center,
									Text = "Or Hold To Join",
									TextColor3 = Color3.new(0, 0, 0),
									TextScaled = true,
									Font = Enum.Font.SourceSansSemibold,
									TextBoundsOnChangedInit = function(p2)
										if p2.TextBounds.X > 0 then
											value6:Set(p2.TextBounds.X)
										end
									end
								})
							end

							return nil
						end
					}),
					object:Create("Frame")({
						Size = UDim2.fromScale(1, 1),
						Name = "IconHolder",
						Visible = object:Do(function(callback)
							return not callback(visible)
						end),
						BackgroundTransparency = 1,
						Instance.new("UIAspectRatioConstraint"),
						object:Create("UIStroke")({
							BorderOffset = UDim.new(0, -2),
							Transparency = 0,
							object:Create("UIGradient")({
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.875),
									NumberSequenceKeypoint.new(1, 0.975)
								}),
								Rotation = 220
							})
						}),
						object:Create("UICorner")({
							CornerRadius = UDim.new(1)
						}),
						function()
							if player.IsInHere then
								return object:Create("ViewportFrame")({
									Size = UDim2.fromScale(0.9, 0.9),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									BackgroundTransparency = 1,
									object:Create("UICorner")({
										CornerRadius = UDim.new(1)
									}),
									function(parent)
										local playerByUserId = Players:GetPlayerByUserId(player.UserId)

										if playerByUserId == nil then
											return
										end

										local data = Utility.GetData(playerByUserId, true)

										if data == nil then
											return
										end

										local worldModel = Instance.new("WorldModel", parent)
										local clone = ReplicatedStorage.Assets.StarterCharacterCloneable:Clone()
										clone.Parent = worldModel
										local humanoid = clone:FindFirstChild("Humanoid")

										if humanoid then
											humanoid:Destroy()
										end

										local humanoid2 = Instance.new("Humanoid")
										humanoid2.Name = "Humanoid"
										humanoid2.RigType = Enum.HumanoidRigType.R15
										humanoid2.Parent = clone
										clone.HumanoidRootPart.Anchored = true
										local camera = Instance.new("Camera")
										camera.Parent = parent
										parent.CurrentCamera = camera
										local v16 = clone.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2).Position
										local position = clone.HumanoidRootPart.Position

										if data.Race.Value == "Demon" then
											camera.CFrame = CFrame.new(v16, position) + createVector(0, 2, 0)
										else
											camera.CFrame = CFrame.new(v16, position) + createVector(0, 1.75, 0)
										end

										Load_Custom(playerByUserId, clone, data, true)
									end
								})
							end

							return object:Create("ImageLabel")({
								object:Create("UICorner")({
									CornerRadius = UDim.new(1)
								}),
								Size = UDim2.fromScale(0.9, 0.9),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								BackgroundTransparency = 1,
								Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
							})
						end
					}),
					object:Create("TextLabel")({
						Name = "Txt",
						Visible = object:Do(function(callback)
							return not callback(visible)
						end),
						Size = UDim2.fromScale(1, 0.8),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = v and "Me" or player.DisplayName,
						TextScaled = true,
						Font = Enum.Font.SourceSansSemibold,
						TextBoundsOnChangedInit = function(state)
							if state.TextBounds.X > 0 then
								state.Size = UDim2.new(0, state.TextBounds.X + 10, state.Size.Y.Scale, 0)
							end
						end
					})
				})
			})
		})
	})
end