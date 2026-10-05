local import = _G.import("romodel")
local import2 = _G.import("global")
local import3 = _G.import("viewImports")
local basic = import3:get("basic")
local menu = import3:get("menu")
local localPlayer = game.Players.LocalPlayer
local model = import.model("ScreenGui", basic.Ui)

function model.init(_)
	return {
		IgnoreGuiInset = true,
		DisplayOrder = 6,
		Name = "PetsPopup",
		AspectRatio = 2,
		Location = "BottomRight",
		Scale = 0.275,
		Content = {
			Panel = import.make(basic.Corner, {
				CornerRadius = UDim.new(0.05, 0),
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(0.98, 0, 0.97, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(20, 20, 40),
				BackgroundTransparency = 0.05
			}, {
				Title = import.make(basic.TextLabel, {
					Position = UDim2.new(0, 0, 0.04, 0),
					Size = UDim2.new(1, 0, 0.225, 0),
					Text = "Win with Pets!",
					StrokeWidth = 3,
					ZIndex = 2
				}),
				Sub = import.make(basic.TextLabel, {
					Position = UDim2.new(0.05, 0, 0.3, 0),
					Size = UDim2.new(0.9, 0, 0.27, 0),
					Text = "Pets help you win with special skills!",
					StrokeWidth = 2,
					ZIndex = 2
				}),
				List = import.make(basic.EmptyList, {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 0.91, 0),
					Size = UDim2.new(0.9, 0, 0.25, 0),
					Padding = UDim.new(0.05, 0),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center
				}, {
					GoButton = import.make(menu.Button, {
						AnchorPoint = Vector2.new(1, 1),
						Position = UDim2.new(0.94, 0, 0.93, 0),
						Size = UDim2.new(0.45, 0, 1, 0),
						LayoutOrder = 1,
						Text = "Get!",
						ZIndex = 2,
						MouseButton1Down = function(p)
							local character = localPlayer.Character

							if not character then
								return
							end

							local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

							if not humanoidRootPart or import2.get("playerSession", localPlayer).Sitting then
								return
							end

							humanoidRootPart.CFrame = workspace.Meta.PetTeleport.CFrame
							p.Ui:Destroy()
						end
					}),
					LaterButton = import.make(menu.Button, {
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0.06, 0, 0.93, 0),
						Size = UDim2.new(0.45, 0, 1, 0),
						LayoutOrder = 2,
						Color = Color3.new(1, 0.0980392, 0.262745),
						ShadowColor = Color3.new(0.619608, 0.0627451, 0.164706),
						Text = "Later",
						ZIndex = 2,
						MouseButton1Down = function(p)
							p.Ui:Destroy()
						end
					})
				})
			})
		}
	}, {}
end

return {
	PetsPopup = model
}