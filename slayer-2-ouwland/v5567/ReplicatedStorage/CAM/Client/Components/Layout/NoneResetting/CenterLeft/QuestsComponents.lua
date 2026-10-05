local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local data = Utility.GetData(localPlayer, true)
local IndividualQuest = require(script.IndividualQuest)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)

if RunService:IsStudio() and not RunService:IsRunning() then
	require(ReplicatedStorage.Regions)
end

local info = faye.Info(0.3, Enum.EasingStyle.Sine)

-- equivalent calls inferred from this helper; original call sites unknown
local function sizeRef()
	if Platform_Handler.Platform.Value == "Mobile" then
		return 108.75
	end

	return 145
end

return function(maid)
	local value = maid:Value({})
	local v = 0
	local holder

	if data ~= nil then
		holder = data:WaitForChild("Quests"):WaitForChild("Holder")
	end

	if holder ~= nil then
		for _, child in pairs(holder:GetChildren()) do
			if value:ItemExists(child.Name) then
				continue
			end

			v += 1
			value:Add(child.Name, child)
		end

		maid:Connect(holder.ChildAdded, function(p)
			if not value:ItemExists(p.Name) then
				v += 1
				value:Add(p.Name, p)
			end
		end)
		maid:Connect(holder.ChildRemoved, function(p)
			v -= 1
			value:Remove(p.Name)
		end)
	end

	local miscQuestHud = DataValue.new("Misc/QuestHud", true)
	local value2 = maid:Value(miscQuestHud:Get() ~= false)
	maid:Add(miscQuestHud.Changed:Connect(function(p)
		value2:Set(p ~= false)
	end))
	maid:Add(miscQuestHud)
	local value3 = maid:Value(value2:Compare(true))
	local value4 = maid:Value(false)
	maid:Connect(value2.Changed, function()
		if value2:Compare(true) then
			value4:Set(false)
			value3:Set(true)
		else
			value4:Set(true)
			maid:Delay(info.Time, function()
				if not value2:Compare(true) then
					value3:Set(false)
				end
			end)
		end
	end)
	local uDim = UDim2.new()
	local uDim2 = UDim2.fromScale(-0.25, 0)
	return maid:Create("Frame")({
		Name = "zQuestsFrame",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		maid:State(function(callback, object, guiObject)
			if callback(value3) == true then
				return object:Create("CanvasGroup")({
					Name = "Panel",
					Size = UDim2.new(2, 0, 1, 0),
					BackgroundTransparency = 1,
					object:Create("UIPadding")({
						PaddingRight = UDim.new(0.5, 0)
					}),
					Position = object:Do(function(callback2)
						local v4 = callback2(value4) == true
						local v6

						if v4 then
							v6 = uDim2
						else
							v6 = uDim
						end

						return object:Animation(v6, info, not v4 and {
							From = uDim2
						} or nil)
					end),
					GroupTransparency = object:Do(function(callback2)
						local v4 = callback2(value4) == true
						return object:Animation(v4 and 1 or 0, info, not v4 and {
							From = 1
						} or nil)
					end),
					object:Create("UIListLayout")({
						Name = "List",
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 5),
						[object:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p)
							local Y = p.AbsoluteContentSize.Y

							if guiObject ~= nil and guiObject:IsA("GuiObject") then
								guiObject.Size = UDim2.new(guiObject.Size.X.Scale, 0, 0, not (Y > 0) and 0 or Y + 2)
							end
						end
					}),
					object:Iterate(value, function(p, p2, p3)
						return IndividualQuest(p3, p, p2, sizeRef())
					end)
				})
			else
				if guiObject ~= nil and guiObject:IsA("GuiObject") then
					guiObject.Size = UDim2.new(guiObject.Size.X.Scale, 0, 0, 0)
				end

				return nil
			end
		end)
	})
end