local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.ClientGameModules.UIHover)
local InviteRewards = require(ReplicatedStorage.Shared.InviteRewards)
local Statable = require(ReplicatedStorage.Shared.Statable)
local InviteRewardsController = require(ReplicatedStorage.Controllers.UI.InviteRewardsController)
local v = Signal.new()
local v2 = false
local v3 = false
task.spawn(function()
	v2 = InviteRewardsController:HasFriends()
	v3 = true
	v:Fire()
end)
local clones = {}

for k, inviteReward in InviteRewards do
	local clone = table.clone(inviteReward)
	clone.Id = k
	table.insert(clones, clone)
end

table.sort(clones, function(a, b)
	return a.Invites < b.Invites
end)
local v4 = not GuiService:IsTenFootInterface() and UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
return Observers.observeTagNoAncestry("UI_InviteRewardsButton", function(instance)
	local maid = Trove.new()
	instance:AddTag("UI_ButtonHoverAnimation")
	local v5 = true
	Replion.Client:AwaitReplion("Data", function(object)
		if not v5 then
			return
		end

		local attributeState, v6 = Statable.getAttributeState(instance, "MobileOnly")
		maid:Add(v6)
		local computed = Statable.Computed(function(callback)
			local v7

			if callback(attributeState) then
				v7 = v4
			else
				v7 = not v4
			end

			if not v7 then
				return false
			end

			local count = #clones

			for k, v9 in clones do
				if object:Find("InviteRewards.ClaimedRewards", v9.Id) then
					continue
				end

				count = k
				break
			end

			for k, _ in clones do
				local child = instance:FindFirstChild((`Reward{k}`))

				if child then
					child.Visible = k == count
				end
			end

			instance.Visible = InviteRewardsController:CanInvite() and v3 and v2 and not InviteRewardsController:HasRewards()
			return true
		end)
		maid:Add(computed)

		local function update()
			computed:Update()
		end

		maid:Add(InviteRewardsController:Watch(update))

		if not v3 then
			maid:Add(v:Once(update))
		end
	end)
	maid:Add(instance.Activated:Connect(function()
		InviteRewardsController:PromptFriendInvite()
	end))
	return function()
		v5 = false
		maid:Destroy()
	end
end)