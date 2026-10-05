local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local NumberLib = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.NumberLib)
local Vide = require(ReplicatedStorage.Packages.Vide)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local create = Vide.create
local rbxassetfontsfamiliesFredokaOnejson = Font.new(
	"rbxasset://fonts/families/FredokaOne.json",
	Enum.FontWeight.Regular
)
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local color = Color3.fromRGB(255, 255, 255)
local uDim = UDim.new(0.5, 0)
local uDim2 = UDim.new(0, 0)

local function textStroke(textStrokeColor: Color3, thickness: number)
	return create("UIStroke")({
		Color = textStrokeColor,
		Thickness = thickness,
		StrokeSizingMode = 1
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wobble(p: number)
	return math.sin(p * 0.83) * 0.6 + math.sin(p * 0.31) * 0.4
end

local function sideLabel(data)
	return create("TextLabel")({
		Name = data.name,
		AnchorPoint = Vector2.new(data.anchorX, 0),
		Position = UDim2.fromScale(data.anchorX, 1.1),
		Size = UDim2.fromScale(0.48, 0.65),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesFredokaOnejson,
		Text = data.name,
		TextColor3 = data.color,
		TextScaled = true,
		TextXAlignment = data.alignment,
		textStroke(Config.textStrokeColor, 0.11)
	})
end

local function sideCount(data)
	return create("TextLabel")({
		Name = `{data.name}Count`,
		AnchorPoint = Vector2.new(data.anchorX, 0.5),
		Position = UDim2.fromScale(data.anchorX == 0 and 0.02 or 0.98, 0.5),
		Size = UDim2.fromScale(0.42, 0.62),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesGothamSSmjson,
		Text = function()
			return NumberLib.toShort((math.round((data.count()))))
		end,
		TextColor3 = color,
		TextScaled = true,
		TextXAlignment = data.alignment,
		ZIndex = 4,
		textStroke(Config.textStrokeColor, 0.09)
	})
end

local function totalStrip(spring)
	return create("Frame")({
		Name = "TotalVotes",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 1.2),
		Size = UDim2.fromScale(0.46, 0.7),
		BackgroundColor3 = Config.statusColor,
		BackgroundTransparency = 0.5,
		create("UICorner")({
			CornerRadius = UDim.new(0.3, 0)
		}),
		create("UIGradient")({
			Color = Config.statusGradient,
			Rotation = 90
		}),
		create("TextLabel")({
			Name = "Label",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.95, 0.68),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = function()
				return (`TOTAL VOTES: {NumberLib.toShort((math.round((spring()))))}`)
			end,
			TextColor3 = color,
			TextScaled = true,
			textStroke(Config.textStrokeColor, 0.08)
		})
	})
end

local SupportBarView = {
	create = function(data)
		local source = Vide.source(os.clock())
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			source(os.clock())
		end)
		Vide.cleanup(function()
			renderSteppedConnection:Disconnect()
		end)
		local spring = Vide.spring(function()
			return data.cruz() + data.splink()
		end, Config.countSpringPeriod, Config.countSpringDamping)
		local spring2 = Vide.spring(function()
			return data.cruzRatio() + wobble(source()) * Config.idleWobble
		end, Config.barSpringPeriod, Config.barSpringDamping)

		local function fn()
			if math.clamp(spring2(), 0, 1) < 0.001 then
				return uDim
			end

			return uDim2
		end

		return create("Frame")({
			Name = "SupportBar",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.02),
			Size = UDim2.fromScale(0.64, 0.06),
			BackgroundTransparency = 1,
			Visible = data.visible,
			ZIndex = 10,
			sideLabel({
				name = Config.cruzName,
				color = Config.cruzColor,
				anchorX = 0,
				alignment = Enum.TextXAlignment.Left
			}),
			sideLabel({
				name = Config.splinkName,
				color = Config.splinkColor,
				anchorX = 1,
				alignment = Enum.TextXAlignment.Right
			}),
			create("Frame")({
				Name = "Track",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				create("UICorner")({
					CornerRadius = uDim
				}),
				create("UIGradient")({
					Color = Config.cruzGradient,
					Rotation = 90
				}),
				create("UIStroke")({
					Color = Config.strokeColor,
					Thickness = 0.07,
					StrokeSizingMode = 1,
					create("UIGradient")({
						Color = Config.strokeGradient,
						Rotation = 90
					})
				}),
				create("Frame")({
					Name = "SplinkFill",
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(1, 0),
					Size = function()
						return UDim2.fromScale(1 - math.clamp(spring2(), 0, 1), 1)
					end,
					BackgroundColor3 = color,
					BorderSizePixel = 0,
					ZIndex = 2,
					create("UICorner")({
						TopRightRadius = uDim,
						BottomRightRadius = uDim,
						TopLeftRadius = fn,
						BottomLeftRadius = fn
					}),
					create("UIGradient")({
						Color = Config.splinkGradient,
						Rotation = 90
					})
				}),
				sideCount({
					name = Config.cruzName,
					count = function()
						return spring() * math.clamp(spring2(), 0, 1)
					end,
					anchorX = 0,
					alignment = Enum.TextXAlignment.Left
				}),
				sideCount({
					name = Config.splinkName,
					count = function()
						return spring() * (1 - math.clamp(spring2(), 0, 1))
					end,
					anchorX = 1,
					alignment = Enum.TextXAlignment.Right
				}),
				create("TextLabel")({
					Name = "Share",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.18, 0.56),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesGothamSSmjson,
					Text = function()
						return (`{math.round(math.clamp(spring2(), 0, 1) * 100)}%`)
					end,
					TextColor3 = color,
					TextScaled = true,
					ZIndex = 4,
					textStroke(Config.textStrokeColor, 0.09)
				})
			}),
			totalStrip(spring)
		})
	end
}

function SupportBarView.mount(p)
	local source = Vide.source(false)
	local source2 = Vide.source(0)
	local source3 = Vide.source(0)
	local source4 = Vide.source(0.5)
	local v = Vide.mount(function()
		return create("ScreenGui")({
			Name = "SupportBar",
			DisplayOrder = Config.displayOrder,
			IgnoreGuiInset = false,
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			SupportBarView.create({
				visible = source,
				cruz = source2,
				splink = source3,
				cruzRatio = source4
			})
		})
	end, p)
	local v2 = false
	return {
		update = function(data)
			if not v2 then
				local v3 = data.cruz + data.splink
				source(data.active and v3 > 0)
				source2(data.cruz)
				source3(data.splink)
				source4(not (v3 > 0) and 0.5 or data.cruz / v3)
			end
		end,
		destroy = function()
			if not v2 then
				v2 = true
				v()
			end
		end
	}
end

return SupportBarView