local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingLogConsole = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.MessagingLogConsole)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local rbxassetfontsfamiliesRobotoMonojson = Font.new("rbxasset://fonts/families/RobotoMono.json")
return UILabs.CreateVideStory({
	name = "Messaging Log Console",
	vide = Vide
}, function()
	local v = nil
	local v2 = true
	Vide.cleanup(function()
		if v then
			v()
		end
	end)
	return create("Frame")({
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		Size = UDim2.fromOffset(420, 380),
		MessagingLogConsole({
			baseZIndex = 1,
			onRowsMounted = function(p)
				v = Vide.mount(function()
					return create("Frame")({
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -4, 0, 0),
						ZIndex = 3,
						create("UIListLayout")({
							Padding = UDim.new(0, 1)
						}),
						create("TextLabel")({
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundColor3 = Color3.fromRGB(23, 23, 23),
							FontFace = rbxassetfontsfamiliesRobotoMonojson,
							Size = UDim2.new(1, -3, 0, 40),
							Text = [[
[12:04:31.092] [SENT] [AdminAnnounce] (58 B)
{"text":"Concert begins in five minutes"}]],
							TextColor3 = Color3.fromRGB(105, 195, 255),
							TextSize = 12,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = 4
						}),
						create("TextLabel")({
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundColor3 = Color3.fromRGB(28, 28, 28),
							FontFace = rbxassetfontsfamiliesRobotoMonojson,
							Size = UDim2.new(1, -3, 0, 40),
							Text = [[
[12:04:31.184] [RECV] [FRAMEWORK_GlobalState] (96 B)
{"stateKey":"AdminAbuseTreadmill","body":{...}}]],
							TextColor3 = Color3.fromRGB(125, 235, 155),
							TextSize = 12,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = 4
						})
					})
				end, p)
			end,
			onSearchChanged = function() end,
			onDirectionChanged = function() end,
			onToggleFollow = function(p)
				v2 = not v2
				p.Text = v2 and "Follow: ON" or "Follow: OFF"
			end,
			onClear = function() end
		})
	})
end)