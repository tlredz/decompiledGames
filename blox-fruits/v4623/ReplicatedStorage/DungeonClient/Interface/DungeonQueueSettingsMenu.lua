local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.ReactRoblox)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local createElement = React.createElement
local frozen = table.freeze({
	PaddingLeft = UDim.new(0.05, 0),
	PaddingRight = UDim.new(0.05, 0),
	PaddingTop = UDim.new(0.1, 0),
	PaddingBottom = UDim.new(0.1, 0)
})

local function SimpleButton(props)
	local v = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Font = Enum.Font.SourceSansBold,
		TextScaled = true,
		[React.Event.Activated] = props.onActivated
	}

	for k, v2 in pairs(props.Properties or {}) do
		v[k] = v2
	end

	return React.createElement("TextButton", v, {
		props.children,
		React.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = props.ButtonOutlineThickness or 1.2,
			Color = props.ButtonOutlineColor or Color3.fromRGB(255, 255, 255)
		}),
		React.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Thickness = props.TextOutlineThickness or 0.8
		}),
		(createElement("UIPadding", frozen))
	})
end

local BoxWithHeader = require(ReplicatedStorage.DungeonClient.Interface.BoxWithHeader)
local frozen2 = table.freeze({
	{
		Text = "Normal",
		Color3 = Color3.fromRGB(0, 161, 0)
	},
	{
		Text = "Hard",
		Color3 = Color3.fromRGB(255, 98, 0)
	},
	{
		Text = "Challenge",
		Color3 = Color3.fromRGB(255, 0, 0)
	}
})
local frozen3 = table.freeze({
	PaddingLeft = UDim.new(0.1, 0),
	PaddingRight = UDim.new(0.1, 0),
	PaddingTop = UDim.new(0.1, 0),
	PaddingBottom = UDim.new(0.1, 0)
})

local function DifficultySelectionComponent(p)
	local selectedDifficulty = useAttribute(p.teleporterPad, "Difficulty")
	local v2 = p.localPlayerData.DataForDungeonTypes[p.teleporterPad:GetAttribute("Destination")] or {
		UnlockedDifficulties = {
			Normal = {
				MaxFloorReached = 0
			}
		}
	}
	local v3 = {}

	for _, v4 in frozen2 do
		local isLocked = not v2.UnlockedDifficulties[v4.Text]
		local simulationData1 = Spritesheets.MAP["Simulation Data1"] or {
			Image = ""
		}
		local properties = {
			Size = UDim2.fromScale(0.25, 0.5),
			BackgroundColor3 = 0,
			Text = 0,
			TextColor3 = 0
		}
		local backgroundColor

		if isLocked then
			backgroundColor = Color3.fromRGB(122, 122, 122)
		else
			backgroundColor = v4.Color3
		end

		properties.BackgroundColor3 = backgroundColor
		properties.Text = isLocked and "" or v4.Text:upper()
		properties.TextColor3 = Color3.new(1, 1, 1)
		local v12 = v4
		local v8 = {
			Properties = properties,
			IsLocked = isLocked,
			onActivated = function()
				if isLocked then
					game.ReplicatedStorage.DungeonShared.DataRemote:InvokeServer(
						"TryUnlockDifficulty",
						p.teleporterPad:GetAttribute("Destination"),
						v12.Text
					)
				else
					p.teleporterPad:FindFirstChild("DungeonSettingsChanged"):FireServer("Difficulty", v12.Text)
				end
			end,
			selectedDifficulty = selectedDifficulty,
			Difficulty = v4.Text,
			ButtonOutlineThickness = selectedDifficulty == v4.Text and 1.5 or 1,
			ButtonOutlineColor = 0
		}
		local buttonOutlineColor

		if selectedDifficulty == v4.Text then
			buttonOutlineColor = Color3.fromRGB(199, 199, 199)
		else
			buttonOutlineColor = Color3.fromRGB(0, 0, 0)
		end

		v8.ButtonOutlineColor = buttonOutlineColor
		table.insert(
			v3,
			createElement(
				SimpleButton,
				v8,
				{ createElement("UIPadding", frozen3), isLocked and { createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0, 0)
						}), createElement("TextLabel", {
							Size = UDim2.fromScale(1, 0.5),
							Position = UDim2.fromScale(0, 0),
							BackgroundTransparency = 1,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							Text = "UNLOCK",
							Font = Enum.Font.SourceSansBold
						}, { createElement("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
								Thickness = 1
							}) }), (createElement("Frame", {
							Size = UDim2.fromScale(1, 0.75),
							Position = UDim2.fromScale(0, 0.5),
							BackgroundTransparency = 1
						}, {
							createElement("UIPadding", {
								PaddingLeft = UDim.new(0.1, 0)
							}),
							createElement("UIListLayout", {
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Top,
								Padding = UDim.new(0, 3)
							}),
							createElement("ImageLabel", {
								Size = UDim2.fromScale(0.5, 1),
								Position = UDim2.fromScale(0, 0),
								BackgroundTransparency = 1,
								Image = simulationData1.Image,
								ImageRectSize = simulationData1.ImageRectSize,
								ImageRectOffset = simulationData1.ImageRectOffset,
								ImageColor3 = Color3.fromRGB(255, 255, 255)
							}, {
								UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
									AspectRatio = 1
								})
							}),
							(createElement("TextLabel", {
								Size = UDim2.fromScale(0.5, 1),
								Position = UDim2.fromScale(0, 0),
								BackgroundTransparency = 1,
								TextColor3 = Color3.fromRGB(201, 218, 255),
								TextScaled = true,
								Text = v4.Text == "Hard" and " 200" or v4.Text == "Challenge" and " 1000" or "",
								Font = Enum.Font.SourceSansBold,
								TextXAlignment = Enum.TextXAlignment.Center
							}, { createElement("UIStroke", {
									ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
									Thickness = 1
								}) }))
						})) } or nil }
			)
		)
	end

	local element = createElement("TextLabel", {
		Size = UDim2.fromScale(0.3, 0.25),
		Position = UDim2.fromScale(0.35, 0),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(60, 60, 60),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		Text = "DIFFICULTY",
		Font = Enum.Font.SourceSansBold,
		ZIndex = 99
	}, {
		UIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Thickness = 1
		}),
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 0),
			PaddingTop = UDim.new(0.025, 0),
			PaddingBottom = UDim.new(0, 0)
		})
	})
	local element2 = createElement("Frame", {
		Size = UDim2.fromScale(1, 0.7),
		Position = UDim2.fromScale(0, 0.1),
		BackgroundTransparency = 1
	}, { createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0.05, 0)
		}), v3 })
	return createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, {
		createElement("UIAspectRatioConstraint", {
			AspectRatio = 4
		}),
		element,
		element2,
		(createElement("Frame", {
			Size = UDim2.fromScale(0.95, 0.6),
			Position = UDim2.fromScale(0.025, 0.15),
			BackgroundTransparency = 1
		}, { createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1.5
			}) }))
	})
end

local function spinny(items)
	local refs = {}
	local children = {}

	for i = 1, 16 do
		local ref = React.useRef(Color3.fromRGB(255, 255, 255))
		table.insert(refs, ref)
		table.insert(children, createElement("Frame", {
			Size = UDim2.fromScale(0.075, 0.01),
			Position = UDim2.fromScale(
				math.cos((i - 1) * 3.141592653589793 * 2 / 16) * 0.1 + 0.5,
				math.sin((i - 1) * 3.141592653589793 * 2 / 16) * 0.1 + 0.5
			),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = ref,
			BorderSizePixel = 0,
			Rotation = (i - 1) * 22.5
		}, { (createElement("UICorner", {
				CornerRadius = UDim.new(1, 1)
			})) }))
	end

	React.useEffect(function()
		local thread = task.spawn(function()
			local v = 0

			while true do
				v = (v - 360 * task.wait()) % 360

				for k, v2 in refs do
					local v3 = (math.rad(((k - 1) * (360 / #refs) + v) % 360) + 1) / 20 * 3 + 0
					v2.current = Color3.fromRGB(math.floor(v3 * 255), math.floor(v3 * 255), (math.floor(v3 * 255)))
				end
			end
		end)
		return function()
			pcall(task.cancel, thread)
		end
	end, {})
	local v = {
		Size = UDim2.fromScale(0.75, 0.75),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1
	}

	for k, item in pairs(items) do
		v[k] = item
	end

	return createElement("Frame", v, { createElement("UIAspectRatioConstraint", {
			AspectRatio = 1
		}), children })
end

local function DungeonQueueSettingsMenu(p)
	local v = Maid.new()
	local ReplicatedPlayerData = require(game.ReplicatedStorage.DungeonClient.ReplicatedPlayerData)
	local localPlayerData = ReplicatedPlayerData.get()
	local matchInitiator = useAttribute(p.teleporterPad, "Initiator") or math.random(1, 2)
	local v4 = useAttribute(p.teleporterPad, "PreparingToTeleport")
	local v5 = useAttribute(p.teleporterPad, "Difficulty")
	local v6 = useAttribute(p.teleporterPad, "TeleportCountdown")
	local v7 = useAttribute(game.Players.LocalPlayer, "IsTeleporting")
	local v8 = useAttribute(p.teleporterPad, "NumPlayersOnPad") or 0
	local state, setState = React.useState(0)
	React.useMemo(function()
		ReplicatedPlayerData.OnUpdated.Event:Connect(function()
			setState(function(p2)
				return p2 + 1
			end)
		end)
	end, {})
	local v9 = localPlayerData.DataForDungeonTypes[p.teleporterPad:GetAttribute("Destination")] or {
		UnlockedDifficulties = {
			Normal = {
				MaxFloorReached = 0
			}
		}
	}
	localPlayerData.CurrentEnergy = math.floor(localPlayerData.CurrentEnergy)
	local v10 = not v9.UnlockedDifficulties[v5]
	local v11 = localPlayerData.CurrentEnergy < 10
	React.useEffect(function()
		return function()
			v:DoCleaning()
		end
	end, {})
	local userId = game.Players.LocalPlayer and game.Players.LocalPlayer.UserId or math.random(1, 2)
	React.useRef(nil)
	local v12 = React.useMemo(function()
		return createElement(BoxWithHeader, {
			AspectRatio = 4,
			Size = UDim2.fromScale(0.6, 0.1),
			Position = UDim2.fromScale(0.5, 0.5),
			headerText = "DUNGEON SETTINGS",
			children = { createElement(spinny, {
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0.85, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), (createElement("TextLabel", {
					Size = UDim2.fromScale(0.7, 0.7),
					Position = UDim2.fromScale(0.45, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					Text = "<i>Transfer in progress...</i>",
					RichText = true,
					Font = Enum.Font.SourceSansBold,
					TextXAlignment = Enum.TextXAlignment.Right
				}, { createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 0),
						PaddingRight = UDim.new(0, 0),
						PaddingTop = UDim.new(0.025, 0),
						PaddingBottom = UDim.new(0, 0)
					}), createElement("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
						Thickness = 0
					}) })) }
		})
	end, { v4, v6, v7 })

	if not v7 then
		v12 = nil
	end

	local v15 = {
		AspectRatio = 4,
		Size = UDim2.fromScale(0.6, 0.1),
		Position = UDim2.fromScale(0.5, 0.5),
		headerText = "DUNGEON SETTINGS",
		children = 0
	}
	local v17 = React.useMemo(function()
		return { createElement("UIPadding", {
				PaddingTop = UDim.new(0.05, 0)
			}), (createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 0)
			})) }
	end)
	local v20 = {
		Size = UDim2.fromScale(1, 0.2),
		Position = UDim2.fromScale(0.05, 0.35),
		BackgroundTransparency = 1,
		TextColor3 = 0,
		TextScaled = true,
		Text = 0,
		Font = 0
	}
	local textColor

	if matchInitiator == userId then
		textColor = Color3.fromRGB(176, 255, 112)
	else
		textColor = Color3.fromRGB(255, 163, 83)
	end

	v20.TextColor3 = textColor
	v20.Text = matchInitiator == userId and "You are the party leader." or "Settings can only be changed by the initiator."
	v20.Font = Enum.Font.SourceSansBold
	v15.children = {
		v17,
		createElement("TextLabel", v20, {
			UIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 0),
				PaddingRight = UDim.new(0, 0),
				PaddingTop = UDim.new(0.025, 0),
				PaddingBottom = UDim.new(0, 0)
			})
		}),
		createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1
		}, { (createElement(DifficultySelectionComponent, {
				teleporterPad = p.teleporterPad,
				matchInitiator = matchInitiator,
				localPlayerData = localPlayerData
			})) }),
		(createElement("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			BackgroundTransparency = 1
		}, { React.useMemo(function()
				return { (createElement("TextLabel", {
						Size = UDim2.fromScale(0.35, 1),
						Position = UDim2.fromScale(0.025, -0.3),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						Text = `Energy: {localPlayerData.CurrentEnergy} (MAX: 50)`,
						Font = Enum.Font.SourceSansBold,
						TextXAlignment = Enum.TextXAlignment.Left
					}, { createElement("UIPadding", {
							PaddingLeft = UDim.new(0, 0),
							PaddingRight = UDim.new(0, 0),
							PaddingTop = UDim.new(0.025, 0),
							PaddingBottom = UDim.new(0, 0)
						}), createElement("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
							Thickness = 1
						}) })) }
			end, { localPlayerData }), React.useMemo(function()
				if v4 then
					return { createElement(spinny, {
							Size = UDim2.fromScale(1, 3),
							Position = UDim2.fromScale(0.95, 0.2)
						}), (createElement("TextLabel", {
							Size = UDim2.fromScale(0.45, 1),
							Position = UDim2.fromScale(0.46, -0.3),
							BackgroundTransparency = 1,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							Text = `<i>Transfer starting... {v6 or ""}</i>`,
							RichText = true,
							Font = Enum.Font.SourceSansBold,
							TextXAlignment = Enum.TextXAlignment.Right
						}, { createElement("UIPadding", {
								PaddingLeft = UDim.new(0, 0),
								PaddingRight = UDim.new(0, 0),
								PaddingTop = UDim.new(0.025, 0),
								PaddingBottom = UDim.new(0, 0)
							}), createElement("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
								Thickness = 0
							}) })) }
				end

				return {}
			end, { v4, v6 }), React.useMemo(function()
				if v4 then
					return {}
				end

				if v8 < p.teleporterPad:GetAttribute("MinPlayers") then
					return { (createElement("TextLabel", {
							Size = UDim2.fromScale(0.65, 1),
							Position = UDim2.fromScale(0.325, -0.7),
							BackgroundTransparency = 1,
							TextColor3 = Color3.fromRGB(255, 65, 65),
							TextScaled = true,
							Text = "Not enough players to start!",
							Font = Enum.Font.SourceSansBold,
							TextXAlignment = Enum.TextXAlignment.Right
						}, { createElement("UIPadding", {
								PaddingLeft = UDim.new(0, 0),
								PaddingRight = UDim.new(0, 0),
								PaddingTop = UDim.new(0.025, 0),
								PaddingBottom = UDim.new(0, 0)
							}), createElement("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
								Thickness = 0
							}) })) }
				end

				if v10 or v11 then
					return { (createElement("TextLabel", {
							Size = UDim2.fromScale(0.65, 1),
							Position = UDim2.fromScale(0.325, -0.7),
							BackgroundTransparency = 1,
							TextColor3 = Color3.fromRGB(255, 65, 65),
							TextScaled = true,
							Text = v10 and "You haven't unlocked this difficulty!" or "You don't have enough energy!",
							Font = Enum.Font.SourceSansBold,
							TextXAlignment = Enum.TextXAlignment.Right
						}, { createElement("UIPadding", {
								PaddingLeft = UDim.new(0, 0),
								PaddingRight = UDim.new(0, 0),
								PaddingTop = UDim.new(0.025, 0),
								PaddingBottom = UDim.new(0, 0)
							}), createElement("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
								Thickness = 0
							}) })) }
				end

				if v4 then
					return {}
				end

				return { createElement(SimpleButton, {
						Properties = {
							Size = UDim2.fromScale(0.2, 1),
							Position = UDim2.fromScale(0.77, -0.65),
							AnchorPoint = Vector2.new(0, 0),
							BackgroundColor3 = Color3.fromRGB(0, 161, 0),
							Text = "START",
							TextColor3 = Color3.new(1, 1, 1),
							AutoButtonColor = true
						},
						onActivated = function()
							p.teleporterPad:FindFirstChild("DungeonSettingsChanged"):FireServer("Start")
						end
					}, {}) }
			end, {
				v10,
				v11,
				v4,
				v8
			}) }))
	}
	local v22 = createElement(BoxWithHeader, v15)
	local v23 = v12 or v22
	return React.useMemo(function()
		return v23
	end, {
		matchInitiator,
		localPlayerData,
		v4,
		v10,
		v11,
		v6,
		v7,
		v8,
		state
	})
end

return DungeonQueueSettingsMenu