local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
require(game.ReplicatedStorage.Util.Maid)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
local color = Color3.new(0.188235, 0.188235, 0.188235)

local function rootComponent(data)
	local thickness = React.useMemo(function()
		return math.clamp(workspace.CurrentCamera.ViewportSize.X / 1000, 2, 10) * 0.6
	end, { workspace.CurrentCamera.ViewportSize })

	local function WindowHeader()
		return (createElement("Frame", {
			Size = UDim2.new(1, 0, 0.2, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
			BackgroundColor3 = CONSTANTS.COLOR.HEADER.BACKGROUND,
			ZIndex = (data.ZIndex or 0) + 1,
			BorderSizePixel = 0
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = 1,
				Color = Color3.new(0, 0, 0),
				Transparency = 0,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.PRIMARY.HIGHLIGHT),
					ColorSequenceKeypoint.new(0.5, CONSTANTS.COLOR.PRIMARY.HIGHLIGHT),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.PRIMARY.HIGHLIGHT)
				})
			}),
			createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "DUNGEON",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = (data.ZIndex or 0) + 2
			}, { createElement("UIStroke", {
					Thickness = 1,
					Color = Color3.new(0, 0, 0),
					Transparency = 0,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
				}) })
		}))
	end

	local function MainFrame()
		return (createElement("Frame", {
			Active = false,
			AnchorPoint = Vector2.new(0, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundColor3 = color,
			BackgroundTransparency = 0.25,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.new(0, 0, 0.2, 0),
			Size = UDim2.new(1, 0, 0.8, 0)
		}, {
			React.useMemo(function()
				return createElement("UIStroke", {
					Thickness = 0,
					Color = Color3.new(0, 0, 0),
					Transparency = 0,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				})
			end, {}),
			createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0.4, 0),
				Position = UDim2.new(0, 0, 0.05, 0),
				BackgroundTransparency = 1,
				Text = "Would you like to attempt to re-connect to the dungeon instance?",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = 1,
					Color = Color3.new(0, 0, 0),
					Transparency = 0,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
				})
			}),
			createElement("TextButton", {
				Size = UDim2.new(0.35, 0, 0.3, 0),
				Position = UDim2.new(0.75, 0, 0.7, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0,
				Text = "CONNECT",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSans,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = Color3.new(0.2, 0.635294, 0.184314),
				[React.Event.Activated] = function()
					data.event:Fire(true)
				end
			}, { createElement("UIStroke", {
					Thickness = thickness,
					Color = Color3.new(0, 0, 0),
					Transparency = 0,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}) }),
			createElement("TextButton", {
				Size = UDim2.new(0.35, 0, 0.3, 0),
				Position = UDim2.new(0.25, 0, 0.7, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0,
				Text = "   CANCEL   ",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSans,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = Color3.new(0.635294, 0.184314, 0.184314),
				[React.Event.Activated] = function()
					data.event:Fire(false)
				end
			}, { createElement("UIStroke", {
					Thickness = thickness,
					Color = Color3.new(0, 0, 0),
					Transparency = 0,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}) })
		}))
	end

	local ref = React.useRef(UDim2.new(-1, 0, 0.42, 0))
	local v4 = createElement("Frame", {
		[React.Tag] = data[React.Tag],
		Active = false,
		AnchorPoint = Vector2.new(0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		LayoutOrder = data.LayoutOrder,
		Position = ref,
		Size = UDim2.new(0.25, 0, 0.2, 0),
		SizeConstraint = data.SizeConstraint,
		ZIndex = data.ZIndex
	}, {
		createElement("UIStroke", {
			Thickness = thickness,
			Color = Color3.new(0, 0, 0),
			Transparency = 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}),
		createElement("UISizeConstraint", {
			MaxSize = Vector2.new(300, 150),
			MinSize = Vector2.new(100, 25)
		}),
		WindowHeader(),
		(MainFrame())
	})
	React.useEffect(function()
		local thread = task.spawn(function()
			local v5 = 0

			while v5 < 1 do
				v5 = math.min(v5 + task.wait() * 4, 1)
				ref.current = UDim2.new(v5 * 0.26 + -0.255, 0, 0.42, 0)
			end
		end)
		return function()
			if thread and coroutine.status(thread) ~= "dead" then
				task.cancel(thread)
			end
		end
	end)
	return v4
end

function setupInterface(event)
	local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
	screenGui.Name = "DungeonReconnectionPrompt"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.IgnoreGuiInset = true
	local root = ReactRoblox.createRoot(screenGui)
	root:render(createElement(rootComponent, {
		event = event
	}))
	return screenGui, root
end

task.spawn(function()
	local dungeonReconnectionPrompt = game.ReplicatedStorage.Remotes:WaitForChild("DungeonReconnectionPrompt", 1e999)

	dungeonReconnectionPrompt.OnClientInvoke = function()
		local bindableEvent = Instance.new("BindableEvent")
		local v, v2 = setupInterface(bindableEvent)
		local v3 = bindableEvent.Event:Wait()
		task.spawn(function()
			v:Destroy()
			task.spawn(v2.unmount, v2)
		end)
		return v3
	end
end)
return {
	setupInterface = setupInterface,
	rootComponent = rootComponent
}