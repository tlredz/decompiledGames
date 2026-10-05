local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local PlayerCommands = require(ReplicatedStorage.CAM.Global.PlayerCommands)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local Input = require(script.Input)
local Line = require(script.Line)
local v = Platform_Handler.Platform.Value == "Mobile" and 0.095 or 0.075
local rbxassetfontsfamiliesSourceSansProjson = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
local rbxassetfontsfamiliesSourceSansProjson2 = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.SemiBold,
	Enum.FontStyle.Normal
)
return function(object, _)
	local value = object:Value({})
	local value2 = object:Value({})
	local flag = false
	local v2 = nil

	local function push(text: string, kind: string)
		local clone = table.clone(value2:Get())
		table.insert(clone, {
			Text = text,
			Kind = kind
		})

		while #clone > 60 do
			table.remove(clone, 1)
		end

		value2:Set(clone)
		task.defer(function()
			if not object.IsActive or v2 == nil then
				return
			end

			v2.CanvasPosition = Vector2.new(0, v2.AbsoluteCanvasSize.Y)
		end)
	end

	local function greet(result)
		local usages = {}

		for _, v3 in PlayerCommands.List do
			if result[v3.Name] then
				table.insert(usages, v3.Usage)
			end
		end

		if #usages == 0 then
			push("You have no commands here right now.", "Note")
			return
		end

		push("Commands you can run here:", "Note")

		for _, v3 in usages do
			push("   " .. v3, "Echo")
		end
	end

	object:Spawn(function()
		local success, result = pcall(SignalFunction.ToServer, "PlayerCommands", {
			action = "list"
		})

		if not object.IsActive then
			return
		end

		if not success or typeof(result) ~= "table" then
			push("Could not reach the server. Try again in a moment.", "Denied")
			return
		end

		value:Set(result)
		greet(result)
	end)

	local function submit(line: string)
		if flag then
			return
		end

		flag = true
		push("> " .. line, "Echo")
		object:Spawn(function()
			local success, result, v3 = pcall(SignalFunction.ToServer, "PlayerCommands", {
				action = "run",
				line = line
			})
			flag = false

			if not object.IsActive then
				return
			end

			if not success then
				push("Could not reach the server. Try again in a moment.", "Denied")
			elseif result == nil and v3 == nil then
				push("No answer came back.", "Denied")
			else
				push(
					(v3 == nil or v3 == "") and (result and "Done." or "That did not work.") or v3,
					result and "Success" or "Denied"
				)
			end
		end)
	end

	return object:Create("Frame")({
		Name = "Commands",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = object:Animation(UDim2.fromScale(0.9, 0.85), object.SpringInfo(0.35, 1, 0.65), {
			From = UDim2.fromScale(0.81, 0.765)
		}),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "Header",
			Size = UDim2.fromScale(1, 0.085),
			BackgroundTransparency = 1,
			object:Create("TextLabel")({
				Name = "Title",
				Text = "COMMANDS",
				Size = UDim2.fromScale(1, 0.6),
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = rbxassetfontsfamiliesSourceSansProjson
			}),
			object:Create("TextLabel")({
				Name = "Sub",
				Text = "Type a command and press enter. Nothing here needs chat.",
				Position = UDim2.fromScale(0, 0.6),
				Size = UDim2.fromScale(1, 0.35),
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(0.6, 0.6, 0.6),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = rbxassetfontsfamiliesSourceSansProjson2
			})
		}),
		object:Create("Frame")({
			Name = "LogPlate",
			Position = UDim2.fromScale(0, 0.085),
			Size = UDim2.fromScale(1, 0.915 - v - 0.025),
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
			BackgroundTransparency = 0.35,
			object:Create("UICorner")({
				CornerRadius = UDim.new(0, 8)
			}),
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				Transparency = 0.95
			}),
			object:Create("ScrollingFrame")({
				Name = "Log",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.96, 0.92),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 4,
				ScrollBarImageTransparency = 0.6,
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				function(p)
					v2 = p
				end,
				object:Create("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2)
				}),
				object:AdvancedIterate(value2, function(p: number, p2, p3)
					return Line(p3, p, p2)
				end)
			})
		}),
		object:Create("Frame")({
			Name = "InputHolder",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, v),
			BackgroundTransparency = 1,
			ZIndex = 3,
			Input(object, value, submit)
		})
	})
end