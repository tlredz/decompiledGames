local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Types)
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideUtil = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VideUtil)
local create = Vide.create
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
local rbxassetfontsfamiliesGothamSSmjson2 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local tweenedSource = VideUtil.TweenedSource
local uDim = UDim2.fromScale(0.5, -2)
local uDim2 = UDim2.fromScale(0.5, 0.15)
local color = Color3.fromRGB(244, 67, 165)
local color2 = Color3.fromRGB(255, 91, 184)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 30, 88)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 43))
})
local colorSequence2 = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 67, 165)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(244, 67, 165)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 246, 251)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(244, 67, 165)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(244, 67, 165))
})
local colorSequence3 = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(151, 129, 224)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 63, 136))
})
local colorSequence4 = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 181, 223)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(218, 67, 151))
})
local source = Vide.source(false)
local source2 = Vide.source(false)
local source3 = Vide.source("A poll is about to begin.")
local source4 = Vide.source({})
local source5 = Vide.source({})
local source6 = Vide.source(nil)
local source7 = Vide.source(0)
local source8 = Vide.source(0)
local source9 = Vide.source(0)
local source10 = Vide.source(0)
local source11 = Vide.source(true)

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(p: string)
	local SoundManager = require(ReplicatedStorage.SoundManager)
	SoundManager:Play(p)
end

local function compactChoiceSize(p: number, _: number)
	if p <= 2 then
		return UDim2.fromScale(1, p == 1 and 1 or 0.46)
	end

	return UDim2.fromScale(0.48, 0.46)
end

local function compactChoicePosition(p: number, p2: number)
	if p <= 2 then
		return UDim2.fromScale(0, (p2 - 1) * 0.54)
	end

	return UDim2.fromScale(p2 % 2 == 0 and 0.52 or 0, p2 > 2 and 0.54 or 0)
end

local function choiceButton(callback, layoutOrder: number, callback2, callback3, callback4, winningChoiceIndex, callback5, callback6, size, position)
	local function isSelected()
		return callback3() == layoutOrder
	end

	local function isWinner()
		return callback4() and winningChoiceIndex() == layoutOrder
	end

	local function choiceAmount()
		return callback2()[layoutOrder] or 0
	end

	local function choiceRatio()
		if callback4() and winningChoiceIndex() == layoutOrder then
			return 1
		end

		local v = callback2()
		local total = 0

		for _, v2 in v do
			total += v2
		end

		if total > 0 then
			return (v[layoutOrder] or 0) / total
		end

		return 0
	end

	local v = tweenedSource(choiceAmount, 1, "quadOut")
	local v2 = tweenedSource(choiceRatio, 1, "quadOut")
	return create("TextButton")({
		Name = `Choice{layoutOrder}`,
		LayoutOrder = layoutOrder,
		Position = position,
		Size = size,
		BackgroundColor3 = function()
			if callback4() and winningChoiceIndex() == layoutOrder then
				return Color3.fromRGB(117, 43, 101)
			end

			if callback3() == layoutOrder then
				return (Color3.fromRGB(71, 42, 117))
			end

			return (Color3.fromRGB(59, 40, 110))
		end,
		AutoButtonColor = false,
		Selectable = callback5,
		ClipsDescendants = true,
		Text = "",
		MouseButton1Click = function()
			if not callback5() or callback3() ~= nil then
				return
			end

			callback3(layoutOrder)
			callback6(layoutOrder, callback())
		end,
		create("UICorner")({
			CornerRadius = UDim.new(0.18, 0)
		}),
		create("Frame")({
			Name = "Progress",
			Size = function()
				return UDim2.fromScale(v2(), 1)
			end,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			create("UICorner")({
				CornerRadius = UDim.new(0.18, 0)
			}),
			create("UIGradient")({
				Rotation = 90,
				Color = function()
					if callback4() and winningChoiceIndex() == layoutOrder then
						return colorSequence4
					end

					return colorSequence3
				end
			})
		}),
		create("TextLabel")({
			Name = "Reply",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.08),
			Size = UDim2.fromScale(0.86, 0.5),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = function()
				return callback().text
			end,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 2,
			create("UITextSizeConstraint")({
				MinTextSize = 9,
				MaxTextSize = 15
			}),
			create("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 0.075,
				Transparency = 0.5,
				StrokeSizingMode = 1
			})
		}),
		create("TextLabel")({
			Name = "Votes",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.63),
			Size = UDim2.fromScale(0.86, 0.22),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = function()
				return (`Votes: {math.round((v()))}`)
			end,
			TextColor3 = Color3.fromRGB(255, 225, 240),
			TextScaled = true,
			ZIndex = 2,
			create("UITextSizeConstraint")({
				MinTextSize = 8,
				MaxTextSize = 11
			}),
			create("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 0.05,
				Transparency = 0.75,
				StrokeSizingMode = 1
			})
		}),
		create("UIStroke")({
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = function()
				if callback4() and winningChoiceIndex() == layoutOrder then
					return Color3.fromRGB(255, 122, 198)
				end

				if callback3() == layoutOrder then
					return (Color3.fromRGB(125, 99, 211))
				end

				return (Color3.fromRGB(80, 63, 136))
			end,
			Thickness = function()
				if callback4() and winningChoiceIndex() == layoutOrder then
					return 0.09
				end

				return 0.05
			end,
			Transparency = 0,
			StrokeSizingMode = 1
		})
	})
end

local function answers(callback, callback2, p, isEnding, canSelectChoice, callback3)
	local function winningChoiceIndex()
		if not isEnding() then
			return nil
		end

		local count = #callback()
		local v = callback2()

		if count == 0 then
			return nil
		end

		local v2 = v[1] or 0
		local v3 = 1

		for i = 2, count do
			local v4 = v[i] or 0

			if not (v2 < v4) then
				continue
			end

			v3 = i
			v2 = v4
		end

		return v3
	end

	return Vide.show(function()
		return #callback() <= 4
	end, function()
		return create("Frame")({
			Name = "Answers",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.43),
			Size = UDim2.fromScale(0.88, 0.48),
			BackgroundTransparency = 1,
			Vide.indexes(callback, function(p2, layoutOrder)
				return choiceButton(
					p2,
					layoutOrder,
					callback2,
					p,
					isEnding,
					winningChoiceIndex,
					canSelectChoice,
					callback3,
					function()
						return compactChoiceSize(#callback(), layoutOrder)
					end,
					function()
						return compactChoicePosition(#callback(), layoutOrder)
					end
				)
			end)
		})
	end, function()
		return create("ScrollingFrame")({
			Name = "Answers",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.43),
			Size = UDim2.fromScale(0.88, 0.48),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			ScrollBarImageColor3 = Color3.fromRGB(210, 174, 255),
			ScrollBarThickness = 4,
			create("UIGridLayout")({
				CellPadding = UDim2.fromScale(0.04, 0.08),
				CellSize = UDim2.fromScale(0.48, 0.42),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Vide.indexes(callback, function(p2, layoutOrder)
				return choiceButton(
					p2,
					layoutOrder,
					callback2,
					p,
					isEnding,
					winningChoiceIndex,
					canSelectChoice,
					callback3,
					UDim2.fromScale(1, 1),
					UDim2.new()
				)
			end)
		})
	end)
end

local function formatTimeLeft(p: number)
	local v = math.max(0, (math.ceil(p)))
	local v2 = math.floor(v / 3600)
	local v3 = math.floor(v % 3600 / 60)
	local v4 = v % 60

	if v2 > 0 then
		return (`{v2}:{v3 // 10}{v3 % 10}:{v4 // 10}{v4 % 10}`)
	end

	return (`{v3 // 10}{v3 % 10}:{v4 // 10}{v4 % 10}`)
end

local function pollView(callback, callback2, source12, source13, source14, source15, callback3, callback4, callback5, callback6, callback7, callback8)
	local scale = tweenedSource(function()
		if callback() then
			return 1
		end

		return 0.6
	end, 0.45, "backOut")
	local v2 = tweenedSource(function()
		if callback() then
			return 0
		end

		return 1
	end, 0.25, "quadOut")
	local offset = tweenedSource(Vector2.new(-1, 0), 0.75, "quadOut")
	local v4 = tweenedSource(uDim, 0.55, "backOut")
	local v5 = tweenedSource(function()
		local v6 = callback5()
		return (math.max(0, callback7() + callback6() - v6))
	end, 0.1, "quadOut")
	local source16 = Vide.source(os.time())
	local source17 = Vide.source(true)
	local source18 = Vide.source(callback())
	local source19 = Vide.source(false)
	local source20 = Vide.source(false)
	local count = 0
	local v6 = true

	local function displayedContentPosition()
		local v7 = v4()
		local v8 = math.clamp((v7.Y.Scale - uDim.Y.Scale) / (uDim2.Y.Scale - uDim.Y.Scale), 0, 1)
		local v9 = v5() * (1 - v8)
		return UDim2.new(v7.X.Scale, v7.X.Offset, v7.Y.Scale, v7.Y.Offset - v9)
	end

	local function isEnding()
		return callback2()
	end

	local function isContentExpanded()
		return callback8() or callback2()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function shouldShowContent()
		return callback() and source19() and (callback8() or callback2())
	end

	local function canSelectChoice()
		return callback() and source19() and (callback8() or callback2()) and not callback2()
	end

	local rotation = tweenedSource(function()
		if callback8() or callback2() then
			return 0
		end

		return 90
	end, 0.2, "quadOut")
	local backgroundColor = tweenedSource(function()
		if source20() and not callback2() then
			return color2
		end

		return color
	end, 0.1, "quadOut")
	local v9 = tweenedSource(function()
		if callback2() then
			return 1
		end

		if source17() then
			return 0
		end

		return 0.7
	end, 0.3, "quadInOut")
	local updateCurrentTime

	updateCurrentTime = function()
		if not v6 then
			return
		end

		source16(os.time())
		task.delay(1, updateCurrentTime)
	end

	local updateLiveDot

	updateLiveDot = function()
		if not v6 then
			return
		end

		source17(not source17())
		task.delay(0.55, updateLiveDot)
	end

	task.delay(1, updateCurrentTime)
	task.delay(0.55, updateLiveDot)
	Vide.effect(function()
		count += 1
		local v10 = count
		local v11 = callback()
		local untrack = Vide.untrack(source18)

		if v11 then
			source19(false)
			source18(true)
			task.delay(0.25, function()
				if v10 == count then
					offset(Vector2.new(1, 0))
				end
			end)
			task.delay(1, function()
				if v10 == count then
					source19(true)
				end
			end)
		else
			offset(Vector2.new(-1, 0), true)
			source19(false)

			if untrack then
				task.delay(0.45, function()
					if v10 == count then
						source18(false)
					end
				end)
			end
		end
	end)
	Vide.effect(function()
		local v10 = shouldShowContent() -- equivalent call inferred; original call site unknown
		local v12

		if v10 then
			v12 = uDim2
		else
			v12 = uDim
		end

		v4(v12, false, {
			duration = v10 and 0.55 or 0.45,
			easing = v10 and "backOut" or "backIn"
		})
	end)
	Vide.cleanup(function()
		count += 1
		v6 = false
	end)
	return create("Frame")({
		Name = "AdminPoll",
		Position = function()
			return UDim2.fromOffset(0, callback5() + v5())
		end,
		Size = function()
			return UDim2.new(1, 0, 1, -callback5())
		end,
		BackgroundTransparency = 1,
		Visible = source18,
		create("Frame")({
			Name = "Panel",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 12),
			Size = UDim2.fromScale(0.6, 0.3),
			BackgroundTransparency = 1,
			create("UISizeConstraint")({
				MaxSize = Vector2.new(1e999, 180)
			}),
			create("UIAspectRatioConstraint")({
				AspectRatio = 3
			}),
			create("Frame")({
				Name = "Content",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = displayedContentPosition,
				Size = UDim2.fromScale(1, 0.85),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				create("UICorner")({
					CornerRadius = UDim.new(0.1, 0)
				}),
				create("UIStroke")({
					Color = Color3.fromRGB(212, 163, 255),
					Thickness = 0.01,
					Transparency = 0.2,
					StrokeSizingMode = 1
				}),
				create("UIGradient")({
					Color = colorSequence,
					Rotation = 90
				}),
				create("TextLabel")({
					Name = "Question",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.25),
					Size = UDim2.fromScale(0.76, 0.25),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesGothamSSmjson2,
					Text = source12,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextWrapped = true,
					create("UITextSizeConstraint")({
						MinTextSize = 10,
						MaxTextSize = 20
					})
				}),
				create("TextLabel")({
					Name = "TimeLeft",
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(0.975, 0.05),
					Size = UDim2.fromScale(0.22, 0.12),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesGothamSSmjson,
					Text = function()
						if callback2() then
							return "ENDED"
						end

						if callback3() > 0 then
							return (formatTimeLeft(callback3() - source16()))
						end

						return "--:--"
					end,
					TextColor3 = Color3.fromRGB(213, 194, 237),
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Right,
					create("UITextSizeConstraint")({
						MinTextSize = 8,
						MaxTextSize = 14
					})
				}),
				answers(source13, source14, source15, isEnding, canSelectChoice, callback4)
			}),
			create("TextButton")({
				Name = "PollBadge",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.045),
				Size = UDim2.fromScale(0.24, 0.15),
				BackgroundColor3 = backgroundColor,
				BackgroundTransparency = v2,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Selectable = function()
					return callback() and not callback2()
				end,
				Text = "",
				ZIndex = 2,
				MouseButton1Click = function()
					if not callback() or callback2() then
						return
					end

					callback8(not callback8())
					playSound("POLL_CLICK") -- equivalent call inferred; original call site unknown
				end,
				MouseEnter = function()
					source20(true)
				end,
				MouseLeave = function()
					source20(false)
				end,
				create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				}),
				create("UIScale")({
					Scale = scale
				}),
				create("UIGradient")({
					Color = colorSequence2,
					Offset = offset,
					Rotation = 15
				}),
				create("Frame")({
					Name = "LiveDot",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.085, 0.5),
					Size = UDim2.fromScale(0.09, 0.45),
					BackgroundColor3 = Color3.fromRGB(18, 10, 15),
					BackgroundTransparency = function()
						return (math.max(v2(), v9()))
					end,
					BorderSizePixel = 0,
					ZIndex = 3,
					create("UIAspectRatioConstraint")({
						AspectRatio = 1
					}),
					create("UICorner")({
						CornerRadius = UDim.new(1, 0)
					}),
					create("UIStroke")({
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.new(0, 0, 0),
						Thickness = 0.08,
						Transparency = function()
							return (math.max(v2(), v9()))
						end,
						StrokeSizingMode = 1
					})
				}),
				create("TextLabel")({
					Name = "Text",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.47, 0.5),
					Size = UDim2.fromScale(0.62, 0.6),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesGothamSSmjson2,
					Text = function()
						if callback2() then
							return "POLL ENDED"
						end

						return "LIVE POLL"
					end,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = v2,
					TextScaled = true,
					ZIndex = 3
				}),
				create("Frame")({
					Name = "ToggleArrowContainer",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.89, 0.5),
					Size = UDim2.fromScale(0.16, 0.75),
					BackgroundTransparency = 1,
					ZIndex = 3,
					create("UIAspectRatioConstraint")({
						AspectRatio = 1
					}),
					create("ImageLabel")({
						Name = "ToggleArrow",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.7, 0.7),
						BackgroundTransparency = 1,
						Image = "rbxassetid://115590713071678",
						ImageColor3 = Color3.new(1, 1, 1),
						ImageTransparency = v2,
						Rotation = rotation,
						ZIndex = 3
					})
				})
			})
		})
	})
end

local PollView = {}

function PollView.mount(callback, p)
	local v = callback or function() end
	local playerGui = p or Players.LocalPlayer.PlayerGui

	if playerGui:IsA("PlayerGui") then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateGuiInsets()
			source8(GuiService.TopbarInset.Height)
			source9(GuiService:GetGuiInset().Y)
		end

		updateGuiInsets() -- equivalent call inferred; original call site unknown
		GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(updateGuiInsets)
		task.spawn(function()
			local mainFrame = playerGui:WaitForChild("AdminAnnounce"):WaitForChild("MainFrame")

			if mainFrame and mainFrame:IsA("GuiObject") then
				local uIListLayout = mainFrame:FindFirstChildWhichIsA("UIListLayout")

				local function updateAdminAnnouncementBottom()
					local v2 = 0

					for _, frame in mainFrame:GetChildren() do
						if frame:IsA("Frame") and frame.Visible then
							v2 = math.max(v2, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y)
						end
					end

					source10(v2)
				end

				updateAdminAnnouncementBottom()
				mainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateAdminAnnouncementBottom)

				if uIListLayout then
					uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateAdminAnnouncementBottom)
				end
			end
		end)
	else
		source8(0)
		source9(0)
		source10(0)
	end

	Vide.mount(function()
		local v2 = pollView(
			source,
			source2,
			source3,
			source4,
			source5,
			source6,
			source7,
			v,
			source8,
			source9,
			source10,
			source11
		)

		if playerGui:IsA("PlayerGui") then
			return create("ScreenGui")({
				Name = "AdminPollUI",
				DisplayOrder = 30,
				IgnoreGuiInset = true,
				ResetOnSpawn = false,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				v2
			})
		end

		return v2
	end, playerGui)
end

function PollView.setVisible(flag: boolean)
	if flag and not source() then
		source11(true)
		playSound("POLL_NOTIF1") -- equivalent call inferred; original call site unknown
	end

	source(flag)
end

function PollView.isVisible()
	return source()
end

function PollView.setPollData(data)
	source2(false)
	source11(true)
	source3(data.question)
	source4(data.choices)
	source7(data.endTime)
	source5({})
	source6(nil)
end

function PollView.setEndPoll(p)
	source5(p)

	if not source2() then
		playSound("POLL_END") -- equivalent call inferred; original call site unknown
	end

	source2(true)
	source11(true)
end

function PollView.deactivateEndPoll()
	source2(false)
end

function PollView.setChoiceAmount(p: number, p2: number)
	local clone = table.clone(Vide.untrack(source5))
	clone[p] = p2
	source5(clone)
end

function PollView.setData(p)
	source2(false)
	source11(true)
	source3(p.state.question)
	source4(p.state.choices)
	source5(p.results)
	source7(p.state.endTime)
	source6(nil)
end

return PollView