local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
local ContractsLibrary = require(ReplicatedStorage.Modules.ContractsLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local parentModule = require(script.Parent)
local object = setmetatable({}, parentModule)
object.__index = object

function object.new(statistics_directory_name, contract_name)
	local self = setmetatable(parentModule.new(), object)
	self._statistics_directory_name = statistics_directory_name
	self._contract_name = contract_name
	self._contract_info = ContractsLibrary.Contracts[self._contract_name]
	self._progress = PlayerDataController:GetDirectoryStatistic(
		self._statistics_directory_name,
		self._contract_info.Identifier,
		self._contract_info.StatisticName,
		self._contract_info.ExtraStatisticNames
	)
	self:_Init()
	return self
end

function object:_Setup()
	local v = StatisticsLibrary.Info[self._contract_info.StatisticName]
	local fullDisplayName = v.FullDisplayName

	for _, extraStatisticName in pairs(self._contract_info.ExtraStatisticNames) do
		fullDisplayName ..= " + " .. StatisticsLibrary.Info[extraStatisticName].FullDisplayName
	end

	self:SetTitle(fullDisplayName)
	self:SetImage(v.Image)
	self:SetProgress(self._progress)

	for _, list in pairs(self._contract_info.Milestones) do
		local v2, v3 = table.unpack(list)
		self:AddMilestone(v2, v3, v.TostringFunction)
	end
end

function object:_Init()
	self:_Setup()
end

return object