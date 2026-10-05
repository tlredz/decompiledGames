local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Invite = require(script.Invite)
local Member = require(script.Member)
local TopSidebar = require(script.TopSidebar)
local GradientOvalButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientOvalButton)
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local data = Utility.GetData(Players.LocalPlayer, true)
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

-- equivalent calls inferred from this helper; original call sites unknown
local function normJob(jobId)
	local v = jobId == nil and "" or tostring(jobId)

	if isStudio and (v == "" or v:gsub("[%-0]", "") == "") then
		return ""
	end

	return v
end

local v = normJob(game.JobId) -- equivalent call inferred; original call site unknown
local info = faye.Info(0.3, Enum.EasingStyle.Sine)

function addMember(object, object2, instance)
	if object2 == nil or instance == nil then
		return
	end

	local v2 = nil
	local v3 = nil

	local function sync()
		local location = instance:GetAttribute("Location")
		local jobId2 = instance:GetAttribute("JobId")
		local isInHere

		if game.PlaceId == location then
			isInHere = normJob(jobId2) == v
		else
			isInHere = false
		end

		local name

		if isInHere then
			name = instance.Name
		else
			name = "notingame" .. instance.Name
		end

		if name == v2 and location == v3 then
			return
		end

		v3 = location

		if v2 ~= nil then
			object2:Remove(v2)
		end

		v2 = name
		object2:Add(name, {
			UserId = tonumber(instance.Name),
			DisplayName = instance:GetAttribute("DisplayName"),
			Location = location,
			IsInHere = isInHere,
			JobId = jobId2
		})
	end

	sync()
	object:Connect(instance.AttributeChanged, function(p)
		if p == "JobId" or p == "Location" then
			sync()
		end
	end)
end

function removeMember(object, p: string)
	if object == nil or p == nil then
		return
	end

	object:Remove(p)
	object:Remove("notingame" .. p)
end

return function(maid, p)
	if MinigameSettings.Get("NoPartyHud") == true then
		return maid:Create("Frame")({
			Name = "aPartyComponents",
			Size = UDim2.new(),
			BackgroundTransparency = 1
		})
	end

	local shown

	if p == nil or p.Shown == nil then
		shown = maid:Value(true)
	else
		shown = p.Shown
	end

	if not gameSettings.IsMenu and (p == nil or p.Shown == nil) then
		local miscPartyHud = DataValue.new("Misc/PartyHud", true)
		shown:Set(miscPartyHud:Get() ~= false)
		maid:Add(miscPartyHud.Changed:Connect(function(p2)
			shown:Set(p2 ~= false)
		end))
		maid:Add(miscPartyHud)
	end

	local value = maid:Value(shown:Compare(true))
	local value2 = maid:Value(false)
	maid:Connect(shown.Changed, function()
		if shown:Compare(true) then
			value2:Set(false)
			value:Set(true)
		else
			value2:Set(true)
			maid:Delay(info.Time, function()
				if not shown:Compare(true) then
					value:Set(false)
				end
			end)
		end
	end)
	local uDim = UDim2.new()
	local uDim2 = UDim2.fromScale(-0.25, 0)
	return maid:Create("Frame")({
		Name = "aPartyComponents",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		maid:State(function(callback, object, guiObject)
			if callback(value) == true then
				return object:Create("CanvasGroup")({
					Name = "Panel",
					Size = UDim2.new(1, 40, 1, 0),
					BackgroundTransparency = 1,
					object:Create("UIPadding")({
						PaddingRight = UDim.new(0, 40)
					}),
					Position = object:Do(function(callback2)
						local v4 = callback2(value2) == true
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
						local v4 = callback2(value2) == true
						return object:Animation(v4 and 1 or 0, info, not v4 and {
							From = 1
						} or nil)
					end),
					object:Create("UIListLayout")({
						Name = "List",
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 5),
						[object:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
							local Y = p2.AbsoluteContentSize.Y

							if guiObject ~= nil and guiObject:IsA("GuiObject") then
								guiObject.Size = UDim2.new(guiObject.Size.X.Scale, 0, 0, not (Y > 0) and 0 or Y + 2)
							end
						end
					}),
					object:State(function(callback2, object2, _)
						local partyInfo

						if data ~= nil then
							partyInfo = data.Parent.Parent:FindFirstChild("partyInfo")
						end

						if partyInfo == nil then
							return nil
						end

						local v6 = callback2(partyInfo.partyId)

						if v6 == "" then
							return object2:Create("Frame")({
								Name = "NoParty",
								Size = UDim2.new(1, 0, 0, 25),
								BackgroundTransparency = 1,
								object2:Create("UIListLayout")({
									Name = "List",
									SortOrder = Enum.SortOrder.Name,
									Padding = UDim.new(0, 2),
									[object2:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
										local Y = p2.AbsoluteContentSize.Y
										p2.Parent.Size = UDim2.new(
											p2.Parent.Size.X.Scale,
											0,
											0,
											not (Y > 0) and 0 or Y + 2
										)
									end
								}),
								TopSidebar(object2, 25, {
									invite = true
								}),
								object2:Create("Frame")({
									Name = "CreateParty",
									Size = UDim2.new(0.4, 0, 0, 25),
									BackgroundTransparency = 1,
									GradientOvalButton(object2, {
										Text = "Create Party",
										Image = "rbxassetid://109672595148261",
										Clicked = function()
											local v11 = PopUpCreator.new({
												Type = "LoadingFull"
											})
											SignalFunction.ToServer("Create Party")
											v11:Destroy()
										end
									})
								})
							})
						else
							local child = game.ReplicatedStorage.Player_Service.Parties:FindFirstChild(v6)

							if child == nil then
								return
							end

							local value3 = object2:Value({})

							for _, child2 in child:GetChildren() do
								addMember(object2, value3, child2)
							end

							object2:Connect(child.ChildAdded, function(p2)
								addMember(object2, value3, p2)
							end)
							object2:Connect(child.ChildRemoved, function(p2)
								removeMember(value3, p2.Name)
							end)
							return object2:Create("Frame")({
								Size = UDim2.new(1, 0, 0, 200),
								Name = "PartyMain",
								BackgroundTransparency = 1,
								object2:Create("UIListLayout")({
									Name = "List",
									SortOrder = Enum.SortOrder.Name,
									Padding = UDim.new(0, 2),
									[object2:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p2)
										local Y = p2.AbsoluteContentSize.Y
										p2.Parent.Size = UDim2.new(
											p2.Parent.Size.X.Scale,
											0,
											0,
											not (Y > 0) and 0 or Y + 2
										)
									end
								}),
								TopSidebar(object2, 25),
								object2:AdvancedIterate(value3, function(p2, p3, p4, _)
									return Member(p4, p2, p3, 25)
								end),
								Invite(object2, v6, 25)
							})
						end
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