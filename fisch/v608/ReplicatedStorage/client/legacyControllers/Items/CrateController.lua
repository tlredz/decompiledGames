local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local events = ReplicatedStorage:WaitForChild("events")
local itemGot = ReplicatedStorage.resources.replicated.instances.ui:WaitForChild("ItemGot")
local localPlayer = Players.LocalPlayer

local function createPopupNotification(parent, text: string, color: Color3?, p: number)
	local clone = itemGot:Clone()
	clone.Title.Text = text
	clone.Title.TextColor3 = color or Color3.new(1, 1, 1)
	clone.Parent = parent
	clone.StudsOffsetWorldSpace = Vector3.new(0, p * 0.35, 0)
	clone.Enabled = true
	local v = p / 10 + 1
	local v2 = p / 10
	TweenService:Create(clone.Title, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, v), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(
		clone.Title.UIStroke,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, v),
		{
			Transparency = 1
		}
	):Play()
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, v2), {
		StudsOffsetWorldSpace = clone.StudsOffsetWorldSpace + createVector(0, 0.4, 0)
	}):Play()
	Debris:AddItem(clone, 2)
end

return {
	Start = function(_)
		events.CrateLootNotifs.OnClientEvent:Connect(function(p)
			local part = Instance.new("Part")
			part.Name = "CrateNotifsAnchor"
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CFrame = CFrame.new(p.position)
			part.Parent = workspace
			local clone = ReplicatedStorage.resources.replicated.fx.crateOpen:Clone()
			clone.Parent = part
			clone:Emit(40)
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.item.crateOpen, humanoidRootPart, true)
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.item.crateOpen2, humanoidRootPart, true)
			end

			Debris:AddItem(part, 5)
		end)
	end
}