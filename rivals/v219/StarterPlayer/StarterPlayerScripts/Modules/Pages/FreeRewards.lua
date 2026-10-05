local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local BaseContractSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseContractSlot"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.Container = self.PageFrame:WaitForChild("Container")
	self.VerifyButton = self.Container:WaitForChild("Verify")
	self.VerifyButtonReadyFrame = self.VerifyButton:WaitForChild("Ready")
	self.VerifyButtonCountdownFrame = self.VerifyButton:WaitForChild("Countdown")
	self.VerifyButtonCountdownText = self.VerifyButtonCountdownFrame:WaitForChild("Title")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self._verify_countdown_hash = 0
	self._contract_slot = BaseContractSlot.new()
	self:_Init()
	return self
end

function object:_UpdateClaimed()
	local claimedGroupReward = PlayerDataController:Get("ClaimedGroupReward")
	self.VerifyButton.Visible = not claimedGroupReward
	self._contract_slot:SetProgress(claimedGroupReward and 2 or 0)
end

function object:_Countdown()
	self._verify_countdown_hash += 1
	local _verify_countdown_hash = self._verify_countdown_hash
	self.VerifyButtonCountdownFrame.Visible = true
	self.VerifyButtonReadyFrame.Visible = false
	task.spawn(function()
		for i = 15, 1, -1 do
			self.VerifyButtonCountdownText.Text = i
			wait(1)

			if _verify_countdown_hash ~= self._verify_countdown_hash then
				return
			end
		end

		self.VerifyButtonCountdownFrame.Visible = false
		self.VerifyButtonReadyFrame.Visible = true
	end)
end

function object:_Setup()
	self._contract_slot:SetTitle("Free Rewards")
	self._contract_slot:SetImage("rbxassetid://84811629597038", UDim2.new(1.25, 0, 1, 0))
	self._contract_slot:SetScale(1.25)
	self._contract_slot:SetRequiresPreviousMilestoneCompleted(false)
	self._contract_slot:SetDescription("Like the game (RIVALS) 👍 and join the group (Nosniy Games) 💜 to claim!")
	self._contract_slot:AddMilestone(2, {
		Name = "RIVALS",
		Weapon = "IsUniversal"
	})
	self._contract_slot:AddMilestone(2, {
		Name = "Nosniy Games",
		Weapon = "IsUniversal"
	})
	self._contract_slot:AddMilestone(2, {
		Name = "Key",
		Quantity = 3
	})
	self._contract_slot.Frame.Parent = self.Container
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.VerifyButton.MouseButton1Click:Connect(function()
		if not self.VerifyButtonReadyFrame.Visible then
			return
		end

		self:_Countdown()
		local success, result = pcall(GroupService.PromptJoinAsync, GroupService, CONSTANTS.GROUP_ID)

		if not success then
			warn("Failed to prompt group join, error:", result)
		end

		if ReplicatedStorage.Remotes.Data.ClaimGroupReward:InvokeServer() then
			ReplicatedStorage.Remotes.Data.ClaimLikeReward:FireServer()
		else
			self.PromptSystem:Open(
				"ErrorMessage",
				"Whoops!",
				"Failed to verify, make sure to like the game AND join the group!"
			)
		end
	end)
	PlayerDataController:GetDataChangedSignal("ClaimedGroupReward"):Connect(function()
		self:_UpdateClaimed()
	end)
	self:_Setup()
	self:_UpdateClaimed()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.VerifyButton)
end

return object._new()