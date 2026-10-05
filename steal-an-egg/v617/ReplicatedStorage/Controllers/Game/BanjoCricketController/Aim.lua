local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local BanjoCricketFlags = require(ReplicatedStorage.Shared.Flags.BanjoCricketFlags)
local Gears = require(ReplicatedStorage.Data.Gears)
local Mushrooms = require(script.Parent.Mushrooms)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
local v = nil
local v2 = nil
local v3 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function distanceToBox(anchor, position: Vector3)
	local pointToObjectSpace = anchor.CFrame:PointToObjectSpace(position)
	local halfSize = anchor.Size / 2
	return (pointToObjectSpace - pointToObjectSpace:Max(-halfSize):Min(halfSize)).Magnitude
end

local function canHit(instance)
	if instance:GetAttribute("IsBat") == true then
		return true
	end

	local gearName = instance:GetAttribute("GearName")
	local v5

	if typeof(gearName) == "string" then
		v5 = Gears.Directory[gearName]
	end

	return v5 ~= nil and v5.ToolController == "Slap"
end

local function pick(humanoidRootPart)
	local v5 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)

	if v5.Magnitude < 0.001 then
		return nil
	end

	local unit = v5.Unit
	local v6 = 1e999
	local index = nil

	for _, v7 in Mushrooms.Targets() do
		local magnitude = distanceToBox(v7.Anchor, humanoidRootPart.Position) -- equivalent call inferred; original call site unknown

		if magnitude > 13 then
			continue
		end

		local v9 = (v7.Anchor.Position - humanoidRootPart.Position) * createVector(1, 0, 1)
		local v10 = not (v9.Magnitude > 0.001) and 1 or unit:Dot(v9.Unit)

		if v10 < 0.1 and magnitude > 4 then
			continue
		end

		local v11 = v7.Index == v and 1 or 0
		local v12 = magnitude - v10 * 3 - v11

		if not (v12 < v6) then
			continue
		end

		index = v7.Index
		v6 = v12
	end

	return index
end

-- equivalent calls inferred from this helper; original call sites unknown
local function nominate(value: number?)
	if value == v then
		return
	end

	v = value
	Mushrooms.ShowAim(value)
	Remotes.BanjoCricket.Aim:FireServer(value or 0)
end

local function update()
	local v5 = v2
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if v5 == nil or v5.Parent ~= character or humanoidRootPart == nil or not (humanoidRootPart:IsA("BasePart") and BanjoCricketFlags.Enabled:Get()) then
		if v == nil then
			return
		end

		v = nil
		Mushrooms.ShowAim(nil)
		Remotes.BanjoCricket.Aim:FireServer(0)
	else
		nominate(pick(humanoidRootPart)) -- equivalent call inferred; original call site unknown
	end
end

local function isRagdolled()
	local ragdollEndTime = localPlayer:GetAttribute("RagdollEndTime")
	return typeof(ragdollEndTime) == "number" and Workspace:GetServerTimeNow() < ragdollEndTime
end

local function isCoolingDown(instance)
	local cooldownEndTime = instance:GetAttribute("CooldownEndTime")
	return instance:GetAttribute("CooldownActive") == true and typeof(cooldownEndTime) == "number" and Workspace:GetServerTimeNow() < cooldownEndTime
end

local function watchCharacter(instance, object, callback)
	local extended = object:Extend()

	local function equip(tool)
		if tool:IsA("Tool") then
			local v5

			if tool:GetAttribute("IsBat") == true then
				v5 = true
			else
				local gearName = tool:GetAttribute("GearName")
				local v6

				if typeof(gearName) == "string" then
					v6 = Gears.Directory[gearName]
				end

				if v6 == nil then
					v5 = false
				else
					v5 = v6.ToolController == "Slap"
				end
			end

			if v5 then
				extended:Clean()
				v2 = tool
				extended:Connect(tool.Activated, function()
					local now = os.clock()

					if not (now - v3 < 0.7) then
						local v6 = tool
						local cooldownEndTime = v6:GetAttribute("CooldownEndTime")
						local v7

						if v6:GetAttribute("CooldownActive") == true and typeof(cooldownEndTime) == "number" then
							v7 = Workspace:GetServerTimeNow() < cooldownEndTime
						else
							v7 = false
						end

						if not v7 then
							local ragdollEndTime = localPlayer:GetAttribute("RagdollEndTime")
							local v8

							if typeof(ragdollEndTime) == "number" then
								v8 = Workspace:GetServerTimeNow() < ragdollEndTime
							else
								v8 = false
							end

							if not v8 and ToolGameplayGuard.AllowsLocalUse(tool) then
								v3 = now
								local v9 = v

								if v9 then
									callback(v9)
								end
							end
						end
					end
				end)
			end
		end
	end

	object:Connect(instance.ChildAdded, equip)
	object:Connect(instance.ChildRemoved, function(p)
		if p == v2 then
			v2 = nil
			extended:Clean()
		end
	end)

	for _, child in instance:GetChildren() do
		equip(child)
	end
end

local v4 = {
	Start = function(callback)
		local v5 = Trove.new()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onCharacter(character)
			v5:Clean()
			v2 = nil
			watchCharacter(character, v5, callback)
		end

		localPlayer.CharacterAdded:Connect(onCharacter)
		local character = localPlayer.Character

		if character then
			onCharacter(character) -- equivalent call inferred; original call site unknown
		end

		RunService.PreRender:Connect(update)
	end
}
return table.freeze(v4)