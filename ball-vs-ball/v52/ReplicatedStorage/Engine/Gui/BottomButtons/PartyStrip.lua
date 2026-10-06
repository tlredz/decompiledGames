local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PartyService = require(ReplicatedStorage.Engine.Service.PartyService)
local PlayerThumbnail = require(ReplicatedStorage.Engine.Service.PlayerThumbnail)
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
return {
	new = function(instance)
		local localPlayer = Players.LocalPlayer
		local parent = instance:WaitForChild("队伍入口")
		local v2 = parent:WaitForChild("成员模板")
		local v3 = parent:WaitForChild("队长模板")
		local v4 = parent:WaitForChild("添加成员按钮")
		local clones = {}
		local v5 = false

		local function open()
			if not v5 then
				return
			end

			local Party = require(ReplicatedStorage.Engine.Gui.Party)
			Party.Init()
			Party.Open()
		end

		local function bind(instance2)
			GamepadSupport.WatchRoot(instance2)
			ButtonActions.Bind(instance2, open)
			local firstChild = instance2:FindFirstChild("动效缩放")
			local v6 = nil

			local function feedback(scale)
				if v6 then
					v6:Cancel()
				end

				v6 = TweenService:Create(firstChild, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
					Scale = scale
				})
				v6:Play()
			end

			instance2.MouseEnter:Connect(function()
				if v5 then
					feedback(1.045)
				end
			end)
			instance2.MouseLeave:Connect(function()
				feedback(1)
			end)
			instance2.SelectionGained:Connect(function()
				if v5 then
					feedback(1.045)
				end
			end)
			instance2.SelectionLost:Connect(function()
				feedback(1)
			end)
			instance2.InputBegan:Connect(function(input)
				if v5 and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					feedback(0.94)
				end
			end)
			instance2.InputEnded:Connect(function()
				feedback(1)
			end)
		end

		local function sync()
			for _, v6 in clones do
				v6:Destroy()
			end

			table.clear(clones)
			local state = PartyService.client.getState()
			local members

			if #state.members > 0 then
				members = state.members
			else
				members = {
					{
						userId = localPlayer.UserId
					}
				}
			end

			local leaderId = state.leaderId or members[1].userId

			for k, member in members do
				local v6 = member.userId == leaderId
				local v7

				if v6 then
					v7 = v3
				else
					v7 = v2
				end

				local clone = v7:Clone()
				clone.Name = (v6 and "队长_" or "成员_") .. member.userId
				clone.LayoutOrder = v6 and 0 or k
				clone.Visible = true
				clone.Parent = parent
				clone.Active = v5
				clone.Interactable = v5
				clone.Selectable = v5
				PlayerThumbnail.applyAsync(clone["玩家头像"], member.userId)
				bind(clone)
				table.insert(clones, clone)
			end

			v4.Visible = #members < 4
		end

		bind(v4)
		v2.Visible = false
		v3.Visible = false
		PartyService.client.Changed:Connect(sync)
		local v6 = {
			SetVisible = function(self, visible)
				parent.Visible = visible
			end,
			SetEnabled = function(self, p)
				v5 = p

				for _, v7 in clones do
					v7.Active = p
					v7.Interactable = p
					v7.Selectable = p
				end

				v4.Active = p
				v4.Interactable = p
				v4.Selectable = p
			end
		}
		sync()
		v6:SetEnabled(false)
		v6:SetVisible(false)
		return v6
	end
}