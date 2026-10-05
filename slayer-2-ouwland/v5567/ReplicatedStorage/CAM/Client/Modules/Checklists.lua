local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Checklists = require(ReplicatedStorage.CAM.Global.Checklists)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local localPlayer = Players.LocalPlayer
local uDim = UDim.new(1, 0)
local v = {}

local function refresh(p: string)
	local v2 = v[p]
	local checklist = Checklists[p]
	local v3 = tonumber(v2.Count:Get()) or 0
	local active = v2.Active

	if active then
		if v2.Target == nil then
			active = false
		else
			active = v3 < checklist.Goal
		end
	end

	local shown = v2.Shown

	if shown ~= nil and active and shown.Target == v2.Target and shown.Count == v3 then
		return
	end

	if shown ~= nil then
		shown.Popup:Destroy()
		v2.Shown = nil
	end

	if not active then
		return
	end

	local shown2 = {
		Target = v2.Target,
		Count = v3,
		Popup = 0
	}
	local new = PopUpCreator.new
	local v5 = {
		Type = "Checklist",
		Focus = v2.Target,
		Content = checklist.Content,
		Side = checklist.Side,
		Count = {
			Current = v3,
			Goal = checklist.Goal
		},
		Corner = 0
	}
	local corner

	if Platform_Handler.Platform.Value == "Mobile" then
		corner = uDim
	end

	v5.Corner = corner
	shown2.Popup = new(v5)
	v2.Shown = shown2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setActive(p: string, active: boolean)
	local v2 = v[p]

	if v2.Active == active then
		return
	end

	v2.Active = active
	refresh(p)
end

local v2 = {
	Block = function()
		local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
		local v3 = false

		local function update()
			local v4 = getvaluesfolder:FindFirstChild("Stun") ~= nil or getvaluesfolder:FindFirstChild("CombatStun") ~= nil

			if v4 then
				if getvaluesfolder:FindFirstChild("Blocking") ~= nil then
					v3 = true
				end
			else
				v3 = false
			end

			setActive("Block", v4 and not v3 and getvaluesfolder:FindFirstChild("Strict_Stun") == nil) -- equivalent call inferred; original call site unknown
		end

		getvaluesfolder.ChildAdded:Connect(update)
		getvaluesfolder.ChildRemoved:Connect(update)
		update()
	end
}

local function stateOf(p: string)
	local v3 = v[p]

	if v3 ~= nil then
		return v3
	end

	local v4 = {
		Count = DataValue.new(Checklists[p].Path, 0),
		Target = nil,
		Active = false,
		Shown = nil
	}
	v[p] = v4
	v4.Count.Changed:Connect(function()
		refresh(p)
	end)
	local v5 = v2[p]

	if v5 ~= nil then
		task.spawn(v5)
	end

	return v4
end

return {
	Claim = function(p: string, target, flag: boolean)
		if Checklists[p] == nil then
			return
		end

		local v3 = stateOf(p)

		if flag then
			v3.Target = target
		elseif v3.Target == target then
			v3.Target = nil
		else
			return
		end

		refresh(p)
	end
}