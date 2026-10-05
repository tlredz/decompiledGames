local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local DetailPanel = require(ReplicatedStorage.CAM.Client.Components.Misc.DetailPanel)
require(script.Parent.Types)
local info = faye.Info(0.4, Enum.EasingStyle.Back)
return function(object, p, p2, p3, p4)
	return object:State(function(callback, object2)
		local v = p3[callback(p2)]

		if v == nil then
			return
		end

		local v2 = {}

		for k in v.Requirements do
			table.insert(v2, k)
		end

		table.sort(v2)

		local function requirements(data)
			local rowHeight = data.rowHeight
			return {
				object2:Create("Frame")({
					Name = "RequirementsGap",
					LayoutOrder = 3,
					Size = rowHeight(data.SECTION_GAP),
					BackgroundTransparency = 1
				}),
				data.sectionHeader("Requirements", 4),
				object2:Create("TextLabel")({
					Name = "Description",
					LayoutOrder = 5,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Font = Enum.Font.SourceSansSemibold,
					Text = v.Description,
					TextWrapped = true,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0.25,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = data.bodyTextSize()
				}),
				object2:Iterate(v2, function(p5: number, name: string, object3)
					local requirement = v.Requirements[name]
					local v3

					if v.Unlocked then
						v3 = requirement
					else
						v3 = math.min(math.floor(p4[name] or 0), requirement)
					end

					local v4 = requirement - v3
					local text = string.match(name, "^visited_(.+)$")
					local v6 = v3 > 0
					local uDim

					if v6 then
						uDim = UDim2.new(0.55, data.ROW_GAP, 0.5, 0)
					else
						uDim = UDim2.fromScale(0, 0.5)
					end

					local v7 = object3:Create("Frame")
					local v8 = {
						Name = name,
						LayoutOrder = p5 + 5,
						Size = rowHeight(0.09100000000000001),
						BackgroundTransparency = 1
					}
					local v9

					if v6 then
						v9 = object3:Create("Frame")({
							Name = "Bar",
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.fromScale(0, 0.5),
							Size = UDim2.fromScale(0.55, 0.3),
							BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
							object3:Create("UICorner")({
								CornerRadius = UDim.new(1, 0)
							}),
							object3:Create("Frame")({
								Name = "Fill",
								Size = object3:Animation(
									UDim2.fromScale(not (requirement > 0) and 1 or v3 / requirement, 1),
									info,
									{
										From = UDim2.fromScale(0, 1)
									}
								),
								object3:Create("UICorner")({
									CornerRadius = UDim.new(1, 0)
								})
							})
						}) or nil
					end

					local v10 = v4 <= 0 and text == nil and object3:Create("ImageLabel")({
						Name = "Done",
						AnchorPoint = Vector2.new(0, 0.5),
						Position = uDim,
						Size = UDim2.fromScale(0.9, 0.9),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						BackgroundTransparency = 1,
						Image = BunchaIcons.Checkmark
					})

					if not v10 then
						local v11 = object3:Create("TextLabel")
						local v12 = {
							Name = "Left",
							AnchorPoint = Vector2.new(0, 0.5),
							Position = uDim,
							Size = UDim2.fromScale(10, 0.9),
							BackgroundTransparency = 1,
							Font = Enum.Font.SourceSansSemibold,
							Text = 0,
							TextColor3 = 0,
							TextTransparency = 0.25,
							TextXAlignment = 0,
							TextScaled = true
						}

						if text == nil then
							text = `{Utility.addCommasToNumber(v4)} left`
						elseif v4 <= 0 then
							text = `{text}: visited`
						end

						v12.Text = text
						v12.TextColor3 = Color3.new(1, 1, 1)
						v12.TextXAlignment = Enum.TextXAlignment.Left
						v10 = v11(v12)
					end

					v8[1], v8[2] = v9, v10
					return v7(v8)
				end)
			}
		end

		return object2:Create("Frame")({
			Name = "EquippedFrame",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(1, 8, 0.5, 0),
			Size = object2:Animation(UDim2.fromScale(0.28, 1), object2.SpringInfo(0.35, 1, 0.65), {
				From = UDim2.fromScale(0.25200000000000006, 0.9)
			}),
			BackgroundTransparency = 1,
			DetailPanel(object2, p, {
				Name = v.Name,
				Color = Titles.GetColor(v.Id),
				Rarity = table.find(Rarities.Order, v.Rarity) or 1,
				Locked = not v.Unlocked,
				Extra = requirements,
				Sections = {
					{
						Header = "Buffs",
						Lines = v.Buffs
					},
					{
						Header = "Passives",
						Lines = v.Passives
					}
				}
			})
		})
	end)
end