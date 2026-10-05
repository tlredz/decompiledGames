local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local modules = {
	LocationChange = require(script.LocationChange)
}
local bottomCenterNotification = ReplicatedStorage.Communication.CnC.Notifications.BottomCenterNotification
local AreaLocator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)

-- equivalent calls inferred from this helper; original call sites unknown
local function stripWidth()
	if Platform_Handler.Platform.Value == "Mobile" then
		return 2.4
	end

	return 1.2
end

local localPlayer = Players.LocalPlayer
local character = nil
local getvaluesfolder = Utility.getvaluesfolder(localPlayer)
local isStudio = RunService:IsStudio()
local v2 = {
	isStudio and "LastEngaged" or nil,
	isStudio and "LastAttacked" or nil,
	not isStudio and "LastAttackedByPlayer" or nil,
	not isStudio and "LastEngagedPlayer" or nil
}
script:WaitForChild("States")
script.States:WaitForChild("InCombat")
script.States:WaitForChild("InSafeZone")
script.States:WaitForChild("CapturingZone")
local states = {
	InCombat = require(script.States.InCombat),
	InSafeZone = require(script.States.InSafeZone),
	CapturingZone = require(script.States.CapturingZone)
}
local random = Random.new()
local info = faye.Info(0.25)
local v4 = isStudio and "RegularIncludeAI" or "Regular"
return function(object, _)
	local value = object:Value(stripWidth())
	object:Connect(Platform_Handler.Platform.Changed.Event, function()
		value:Set(stripWidth())
	end)
	local uDim = UDim2.new(0.5, 0, 0.5, 5)
	local v5 = false
	object:Delay(3, function()
		local character2 = localPlayer.Character

		if character2 == nil or character2 == character then
			return
		end

		if v5 == false then
			v5 = true
			character = character2
			bottomCenterNotification:Fire("LocationChange", {
				Text = AreaLocator.AreaEquipped.Parent,
				SubText = AreaLocator.AreaEquipped.Sub
			})
		end
	end)
	local value2 = object:Value()
	local value3 = object:Value({})
	local v6 = 0
	local v7 = false

	local function setInCombat(flag: boolean)
		if flag == v7 then
			return
		end

		v7 = flag

		if flag then
			value3 += "InCombat"
		else
			value3 -= "InCombat"
		end
	end

	local v8 = nil
	local connections = {}

	local function unbindDMG()
		v8 = nil
		v6 = random:NextNumber()

		for _, connection in connections do
			object:Remove(connection)
			connection:Disconnect()
		end

		table.clear(connections)

		if v7 == false then
			return
		end

		v7 = false
		value3 -= "InCombat"
	end

	local function updDMG(instance)
		if instance == v8 then
			return
		end

		unbindDMG()
		v8 = instance

		local function updInCombat()
			if v8 ~= instance then
				return
			end

			local number = random:NextNumber()
			v6 = number

			if InCombat[v4](localPlayer) then
				if v7 ~= true then
					v7 = true
					value3 += "InCombat"
				end

				object:Spawn(function()
					while v6 == number do
						local v9 = 0

						for _, attributeName in v2 do
							local attribute = instance:GetAttribute(attributeName)

							if attribute ~= nil and v9 < attribute then
								v9 = attribute
							end
						end

						local v10 = math.floor(v9 + InCombat.InCombatTime - Utility.Tick())
						value2:Set((math.max(0, (math.floor(v10)))))

						if v10 <= 0 then
							if not (v6 == number and v7 ~= false) then
								break
							end

							v7 = false
							value3 -= "InCombat"
							break
						else
							task.wait(1)
						end
					end
				end)
			else
				if v7 == false then
					return
				end

				v7 = false
				value3 -= "InCombat"
			end
		end

		for _, v9 in v2 do
			table.insert(connections, object:Connect(instance:GetAttributeChangedSignal(v9), updInCombat))
		end

		updInCombat()
	end

	object:Connect(getvaluesfolder.ChildAdded, function(p)
		if p.Name == "DMG" then
			updDMG(p)
		end
	end)
	object:Connect(getvaluesfolder.ChildRemoved, function(p)
		if p ~= v8 then
			return
		end

		unbindDMG()
		local DMG = getvaluesfolder:FindFirstChild("DMG")

		if DMG ~= nil then
			updDMG(DMG)
		end
	end)
	local DMG = getvaluesfolder:FindFirstChild("DMG")

	if DMG ~= nil then
		updDMG(DMG)
	end

	local v9 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function upd()
		local v10 = localPlayer:GetAttribute("Situation") == "Safezone"

		if v10 == v9 then
			return
		end

		v9 = v10

		if v10 then
			value3 += "InSafeZone"
		else
			value3 -= "InSafeZone"
		end
	end

	upd() -- equivalent call inferred; original call site unknown
	object:Connect(localPlayer:GetAttributeChangedSignal("Situation"), upd)
	local v10 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function upd2()
		local v11 = localPlayer:GetAttribute("RescueZoneState") == "Capturing"

		if v11 == v10 then
			return
		end

		v10 = v11

		if v11 then
			value3 += "CapturingZone"
		else
			value3 -= "CapturingZone"
		end
	end

	upd2() -- equivalent call inferred; original call site unknown
	object:Connect(localPlayer:GetAttributeChangedSignal("RescueZoneState"), upd2)
	return object:Create("Frame")({
		Name = "AAA" .. script.Name,
		ZIndex = 5,
		Position = uDim,
		AnchorPoint = Vector2.new(0.5, 0),
		Size = object:Do(function(callback)
			return UDim2.fromScale(callback(value), 2)
		end),
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 5
		}),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 2),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		}),
		object:AdvancedIterate(value3, function(_, p, object2, _)
			return object2:Create("CanvasGroup")({
				Size = UDim2.fromScale(0.3, 0.4),
				BackgroundTransparency = 1,
				states[p](object2, value2),
				GroupTransparency = object:Animation(0, info, {
					From = 1
				}),
				OnClean = function()
					return {
						GroupTransparency = object:Animation(1, info)
					}
				end
			})
		end),
		object:Signal(bottomCenterNotification.Event, function(p, p2, p3: string, ...)
			if p3 == "LocationChange" then
				v5 = true
				character = localPlayer.Character
			end

			if modules[p3] == nil then
				return
			else
				return modules[p3](p, p2, ...)
			end
		end)
	})
end