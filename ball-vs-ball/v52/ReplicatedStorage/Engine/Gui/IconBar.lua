local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local UIManager = require(script.Parent.UIManager)
local LobbyShortcuts = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.LobbyShortcuts)
local GamepadPages = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local flag = false

local function setupButtonFeedback(data, _, fn)
	local size = data.Size
	data.MouseEnter:Connect(function()
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = UDim2.new(size.X.Scale * 1.05, 0, size.Y.Scale * 1.05, 0)
		}):Play()
	end)
	data.MouseLeave:Connect(function()
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = size
		}):Play()
	end)

	local function activate()
		if not GamepadSupport.CanActivate(data) then
			return
		end

		TweenService:Create(data, TweenInfo.new(0.05), {
			Size = UDim2.new(size.X.Scale * 0.95, 0, size.Y.Scale * 0.95, 0)
		}):Play()
		task.delay(0.05, function()
			TweenService:Create(data, TweenInfo.new(0.1), {
				Size = size
			}):Play()
		end)
		fn()
	end

	ButtonActions.Bind(data, activate)
end

return {
	Init = function()
		if flag then
			return
		end

		flag = true
		local v = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("界面图标"):WaitForChild("左侧按钮区")
		v.Visible = true
		GamepadPages.Observe(v, {
			base = true,
			available = LobbyShortcuts.IsAvailable
		})
		local v2 = v:WaitForChild("商店按钮")
		local v3 = v:WaitForChild("库存按钮")
		local v4 = v:WaitForChild("表情按钮")
		setupButtonFeedback(v2, Enum.KeyCode.DPadLeft, function()
			local store = UIManager.Get("Store")

			if not store.IsOpen() then
				store.OpenHome()
			end
		end)
		setupButtonFeedback(v3, Enum.KeyCode.DPadDown, function()
			UIManager.Get("Inventory").Open()
		end)
		setupButtonFeedback(v4, Enum.KeyCode.DPadUp, function()
			UIManager.Get("EmoteWheel").Toggle()
		end)
		setupButtonFeedback(v:WaitForChild("首充小球按钮"), Enum.KeyCode.DPadRight, function()
			UIManager.Get("FirstChargeBall").PromptPurchase()
		end)
		local firstChild = v4:FindFirstChild("快捷键提示")

		if firstChild then
			firstChild.Visible = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled
		end
	end
}