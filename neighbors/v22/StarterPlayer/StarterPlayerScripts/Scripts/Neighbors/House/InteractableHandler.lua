local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local Interactable = require(ReplicatedStorage.Modules.Neighbors.Interactable)
local Janitor = require(ReplicatedStorage.Modules.Janitor)
require(ReplicatedStorage.Modules.Network)
local houseInteractables = ReplicatedStorage.Modules.HouseInteractables
require(houseInteractables.BaseInteractable)
local maid = nil

local function getState(p: string, flag: boolean?)
	if flag == nil then
		return Interactable.Interactables[p].DefaultValue
	end

	return flag
end

local function reloadInteractables()
	if maid then
		maid:Destroy()
		maid = nil
	end

	local currentHouse = House:GetCurrentHouse()

	if currentHouse then
		maid = Janitor.new()
		local interactables = currentHouse.Model:FindFirstChild("Server"):FindFirstChild("Interactables")
		maid:Add(interactables.AttributeChanged:Connect(function(attributeName: string)
			local interactable = Interactable:GetInteractable(attributeName)

			if not interactable then
				return
			end

			local attribute = interactables:GetAttribute(attributeName)

			if attribute == nil then
				attribute = Interactable.Interactables[attributeName].DefaultValue
			end

			if interactable.Controller.State == attribute then
				return
			end

			interactable.Controller:SetState(attribute, true)
		end))
		task.defer(function()
			for attributeName, interactable in next, Interactable.Interactables, nil do
				local controller = interactable.Controller
				local attribute = interactables:GetAttribute(attributeName)

				if attribute == nil then
					attribute = Interactable.Interactables[attributeName].DefaultValue
				end

				controller:SetState(attribute, true, true)
			end
		end)
	end
end

House.ActiveHouseChanged:Connect(reloadInteractables)