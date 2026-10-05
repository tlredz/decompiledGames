local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local contractMilestoneSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ContractMilestoneSlot")
local contractSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ContractSlot")
local uDim = UDim2.new(0.05, 0, 0.75, 0)
local BaseContractSlot = {}
BaseContractSlot.__index = BaseContractSlot

function BaseContractSlot.new(_, _)
	local self = setmetatable({}, BaseContractSlot)
	self.Frame = contractSlot:Clone()
	self._num_milestones = 0
	self._progress = 0
	self._scale = 1
	self._milestones = {}
	self._default_tostring_function = nil
	self._requires_previous_milestone_completed = true
	self._contract_icon_image = nil
	self._contract_icon_size = nil
	self:_Init()
	return self
end

function BaseContractSlot:SetImage(image, p2)
	self.Frame.Container.Title.Left.Image = image
	self.Frame.Container.Title.Left.Size = p2 or self.Frame.Container.Title.Left.Size
end

function BaseContractSlot:SetContractImage(contract_icon_image, contract_icon_size)
	self._contract_icon_image = contract_icon_image
	self._contract_icon_size = contract_icon_size
	self:_Update()
end

function BaseContractSlot:SetTitle(text)
	self.Frame.Container.Title.Text = text
end

function BaseContractSlot:SetDescription(text, value)
	self.Frame.Container.Description.Text = text
	self.Frame.Container.Description.Size = UDim2.new(0.9, 0, 0.025 * (value or 1), 0)
	self:_Update()
end

function BaseContractSlot:SetScale(scale)
	self._scale = scale
	self:_Update()
end

function BaseContractSlot:SetProgress(progress)
	self._progress = progress
	self:_Update()
end

function BaseContractSlot:SetRequiresPreviousMilestoneCompleted(requires_previous_milestone_completed)
	self._requires_previous_milestone_completed = requires_previous_milestone_completed
	self:_Update()
end

function BaseContractSlot:AddMilestone(p, p2, p3)
	self._num_milestones += 1
	local clone = contractMilestoneSlot:Clone()
	clone.LayoutOrder = self._num_milestones
	clone.ZIndex = self._num_milestones
	clone.Goal.Visible = clone.Contract.Visible
	clone.Parent = self.Frame.Container.Milestones
	table.insert(self._milestones, {
		clone,
		p,
		p2,
		p3 or self._default_tostring_function
	})

	if p2 then
		local new = RewardSlot.new(p2)
		new.Frame.Parent = clone.Reward
	end

	self:_Update()
end

function BaseContractSlot:Destroy()
	self.Frame:Destroy()
end

function BaseContractSlot:_Update()
	self.Frame.Container.Milestones.Position = UDim2.new(
		0,
		0,
		0.1 + (self.Frame.Container.Description.Text == "" and 0 or 0.01 + self.Frame.Container.Description.Size.Y.Scale or 0),
		0
	)
	self.Frame.Container.Size = UDim2.new(1, 0, 1 * self._scale, 0)
	self.Frame.Size = UDim2.new(
		1,
		0,
		(self.Frame.Container.Milestones.Position.Y.Scale + 0.075 * self._num_milestones + 0.025) * self._scale,
		0
	)
	local v = true

	for _, list in pairs(self._milestones) do
		local v2, v3, _, v4 = table.unpack(list)
		local visible = self._requires_previous_milestone_completed and not v
		v = v3 <= self._progress
		v2.Contract.Image = self._contract_icon_image or "rbxassetid://17619445009"
		v2.Contract.Size = self._contract_icon_size or uDim
		v2.Progress.Bar.Visible = not visible
		v2.Locked.Visible = visible
		v2.Completed.Visible = not visible and v
		v2.Contract.Visible = not (visible or v)
		v2.Progress.Bar.Size = UDim2.new(math.clamp(self._progress / v3, 0, 1), 0, 1, 2)
		v2.Progress.Bar.BackgroundColor3 = v and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(0, 190, 255)
		v2.Goal.Visible = not (visible or v)
		v2.Goal.Text = v4(self._progress) .. " / " .. v4(v3)
	end
end

function BaseContractSlot:_Setup()
	function self._default_tostring_function(...)
		return Utility:PrettyNumber(...)
	end
end

function BaseContractSlot:_Init()
	self:_Setup()
	self:SetImage("")
	self:SetTitle("")
	self:SetDescription("")
	self:SetScale(1)
	self:SetProgress(0)
	self:SetRequiresPreviousMilestoneCompleted(true)
end

return BaseContractSlot