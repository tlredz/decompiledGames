local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.modules.library.bait)
local Trove = require(ReplicatedStorage.packages.Trove)
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
return {
	Start = function(_)
		Net:RemoteEvent("BaitWhirlPoolPassive/Visual", 1e999).OnClientEvent:Connect(function(p, p2)
			local maid = Trove.new()
			local clone = script.Template:Clone()
			clone.Name = "W_BAIT"
			local currentCamera = game.Workspace.CurrentCamera
			clone.Parent = playerGui
			local worldToScreenPoint, _ = currentCamera:WorldToScreenPoint(p2)
			local vector = Vector2.new(worldToScreenPoint.X, worldToScreenPoint.Y)
			local _ = worldToScreenPoint.Z
			clone.Icon.Position = UDim2.fromOffset(vector.X, vector.Y)
			clone.Icon.Image = p.Icon
			clone.Icon.Value.Text = "x3"
			local size = clone.Icon.Size
			clone.Icon.Size = UDim2.fromScale(0.1, 0.1)
			clone.Enabled = true
			local tween = TweenService:Create(clone.Icon, tweenInfo, {
				Size = size,
				Position = UDim2.fromScale(0.5, 0.5)
			})
			tween:Play()
			maid:Add(tween)
			maid:Add(tween.Completed:Connect(function()
				local tween2 = TweenService:Create(clone.Icon, tweenInfo, {
					Size = size,
					Position = UDim2.fromScale(0.5, 1.2)
				})
				maid:Add(tween2)
				maid:Add(tween2.Completed:Connect(function()
					clone:Destroy()
					maid:Destroy()
				end))
				maid:Add(task.delay(1, function()
					tween2:Play()
				end))
			end))
		end)
	end
}