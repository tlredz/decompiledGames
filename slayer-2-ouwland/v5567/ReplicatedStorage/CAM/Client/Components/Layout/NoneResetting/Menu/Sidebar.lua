local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local SidebarOption = require(script.SidebarOption)
local info = faye.Info(0.25, Enum.EasingStyle.Sine)
local springInfo = faye.SpringInfo(0.2, 0.45, 0.1)
local v = {
	[1] = {
		Name = "Inventory",
		Icon = "rbxassetid://82856611070863"
	},
	[2] = {
		Name = "Skill Tree",
		Icon = "rbxassetid://81159351519240"
	},
	[3] = {
		Name = "Shop",
		Icon = "rbxassetid://138990636577266"
	},
	[4] = {
		Name = "Player Info / Progression",
		Icon = "rbxassetid://102898507621274"
	},
	[5] = {
		Name = "Faction",
		Icon = "rbxassetid://109916080587594"
	},
	[6] = {
		Name = "Titles",
		Icon = "rbxassetid://102898507621274"
	},
	[7] = {
		Name = "Archives",
		Icon = "rbxassetid://97986430219306"
	},
	[8] = {
		Name = "Servers",
		Icon = "rbxassetid://136875410813903"
	},
	[9] = {
		Name = "Settings",
		Icon = "rbxassetid://128063971339098"
	},
	[91] = {
		Name = "Back To Main Menu",
		Icon = "rbxassetid://86818449615839"
	},
	[99] = {
		Name = "Close",
		Icon = "rbxassetid://120986271206642"
	}
}
local color = Color3.new(0.1, 0.1, 0.1)
local uDim = UDim2.fromScale(-0.45)

local function pageNames()
	local v2 = {}

	for k in v do
		if k < 90 then
			table.insert(v2, k)
		end
	end

	table.sort(v2)
	local names = {}

	for _, v3 in v2 do
		table.insert(names, v[v3].Name)
	end

	return names
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rowScale()
	if Platform_Handler.Platform.Value == "Mobile" then
		return 1.5
	end

	return 0.96
end

-- equivalent calls inferred from this helper; original call sites unknown
local function columnY()
	if Platform_Handler.Platform.Value == "Mobile" then
		return 0.56
	end

	return 0.5
end

return function(maid, object)
	local value = maid:Value(true)
	local space = maid:Space(function(state, p, object2, object3, object4, object5)
		local lastState = object:Compare(p) and 1 or state.In == true and 2 or 3

		if state.LastState ~= lastState then
			if lastState == 1 then
				object4:Set(0)
				object3:Set(0.75)
				object2:Set(Color3.new(1, 0.803922, 0.305882))
				object5:Set(UDim2.fromScale(0.25, 0.5))
			elseif lastState == 2 then
				object2:Reset()
				object3:Set(0.975)
				object4:Set(0.25)
				object5:Set(UDim2.fromScale(0.225, 0.5))
			else
				object2:Reset()
				object3:Reset()
				object4:Reset()
				object5:Reset()
			end

			state.LastState = lastState
		end
	end)
	space:Connect(object.Changed)
	local v2 = pageNames()

	local function step(p: number)
		local count = #v2

		if count == 0 then
			return
		end

		local v3 = nil

		for k, v5 in v2 do
			if not object:Compare(v5) then
				continue
			end

			v3 = k
			break
		end

		object:Set(v2[v3 == nil and 1 or (v3 - 1 + p) % count + 1])
	end

	local function stepper(p: number)
		return function(p2: string, flag: boolean)
			if p2 ~= "Down" or flag or InputHandler.IsRecording() then
				return
			end

			step(p)
		end
	end

	local v3 = 1
	maid:Add(InputHandler.ListenTo("Tab_Next", function(p: string, flag: boolean)
		if p ~= "Down" or flag or InputHandler.IsRecording() then
			return
		end

		step(v3)
	end))
	local v4 = -1
	maid:Add(InputHandler.ListenTo("Tab_Prev", function(p: string, flag: boolean)
		if p ~= "Down" or flag or InputHandler.IsRecording() then
			return
		end

		step(v4)
	end))
	return maid:Create("Frame")({
		Size = UDim2.fromScale(0.2, 1),
		ZIndex = 999,
		BackgroundTransparency = 1,
		Name = "Sidebar",
		maid:Create("Frame")({
			Name = "Holder",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.05, columnY()),
			Size = maid:Animation(UDim2.fromScale(rowScale() * 0.5, rowScale() * 0.035), springInfo, {
				From = UDim2.fromScale(rowScale() * 0.5 * 0.8, rowScale() * 0.035 * 0.8)
			}),
			BackgroundTransparency = 1,
			maid:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0.35, 0),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			CleanFunction = function(object2, _)
				value:Set(false)
				return {
					Visible = object2:DelayProperty(false, 0.1),
					Size = object2:Animation(UDim2.fromScale(), info)
				}
			end,
			maid:Create("UIAspectRatioConstraint")({
				AspectRatio = 5
			}),
			maid:Iterate(v, function(p, p2, p3)
				return SidebarOption(p3, p, p2, object, space)
			end),
			maid:Create("Frame")({
				Name = "Tab_Prev",
				LayoutOrder = 0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(0.8, 0.8),
				BackgroundTransparency = 1,
				function(instance)
					instance:SetAttribute("OnlyOn", "Xbox,Playstation")
					instance:AddTag("UIkey")
				end
			}),
			maid:Create("Frame")({
				Name = "Tab_Next",
				LayoutOrder = 100,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(0.8, 0.8),
				BackgroundTransparency = 1,
				function(instance)
					instance:SetAttribute("OnlyOn", "Xbox,Playstation")
					instance:AddTag("UIkey")
				end
			})
		}),
		maid:Create("Frame")({
			Name = "Bg",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = -2,
			maid:Create("ImageLabel")({
				Name = "Actual",
				ZIndex = 5,
				Image = "rbxassetid://118141093981646",
				AnchorPoint = Vector2.new(),
				Position = uDim,
				BackgroundTransparency = 1,
				ImageColor3 = color,
				Size = UDim2.fromScale(3, 1),
				ImageTransparency = maid:Animation(0.75, info, {
					From = 1
				}),
				CleanFunction = function(object2, _)
					return {
						ImageTransparency = object2:Animation(1, info)
					}
				end
			}),
			maid:Create("ImageLabel")({
				Name = "Glow",
				ImageColor3 = color,
				Image = "rbxassetid://75545650705042",
				AnchorPoint = Vector2.new(),
				Position = uDim,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(3, 1),
				ImageTransparency = maid:Animation(0.2, info, {
					From = 1
				}),
				CleanFunction = function(object2, _)
					return {
						ImageTransparency = object2:Animation(1, info)
					}
				end
			})
		})
	})
end