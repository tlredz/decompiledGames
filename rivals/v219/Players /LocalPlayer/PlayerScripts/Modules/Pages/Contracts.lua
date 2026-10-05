local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContractsLibrary = require(ReplicatedStorage.Modules.ContractsLibrary)
require(ReplicatedStorage.Modules.ItemLibrary)
local ContractSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseContractSlot"):WaitForChild("ContractSlot"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local contractDivider = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ContractDivider")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._weapon_name = nil
	self._contract_slots = {}
	self:_Init()
	return self
end

function object:SetWeapon(weapon_name)
	self._weapon_name = weapon_name
	self:_Update()
end

function object:_Update()
	for _, _contract_slot in pairs(self._contract_slots) do
		_contract_slot:Destroy()
	end

	self._contract_slots = {}

	if not self._weapon_name then
		return
	end

	local count = 0

	for k, v in pairs(ContractsLibrary:GetWeaponContracts(self._weapon_name)) do
		if k > 1 then
			local clone = contractDivider:Clone()
			clone.LayoutOrder = count
			clone.Parent = self.Container
			table.insert(self._contract_slots, clone)
			count += 1
		end

		local weaponStatistics = ContractSlot.new("WeaponStatistics", v)
		weaponStatistics.Frame.LayoutOrder = count
		weaponStatistics.Frame.Parent = self.Container
		table.insert(self._contract_slots, weaponStatistics)
		count += 1
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self:_Update()
	ButtonEffect:Add(self.CloseButton)
end

return object._new()