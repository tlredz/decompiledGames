local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)

function UpdateCanvasSize(p, p2)
	p.CanvasSize = UDim2.new(0, 0, 0, p2.AbsoluteContentSize.Y)
end

script.Parent.Interactable = true
local v = {}
local offeritem = ReplicatedStorage:WaitForChild("events"):WaitForChild("offeritem")

offeritem.OnClientInvoke = function(player, p: string?)
	if player == game.Players.LocalPlayer then
		return nil
	end

	if v[player] then
		return false
	end

	local success, result = pcall(function()
		return table.find(StarterGui:GetCore("GetBlockedUserIds"), player.UserId)
	end)

	if success and result then
		return false
	end

	local clone = script:WaitForChild("offer"):Clone()
	clone.Size = UDim2.new(clone.Size.X.Scale / 1.5, 0, clone.Size.Y.Scale / 1.5, 0)
	TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = script:WaitForChild("offer").Size
	}):Play()
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)
	local v2 = nil
	clone.deny.Activated:Once(function()
		v2 = false
		clone:Destroy()
	end)
	clone.confirm.Activated:Once(function()
		v2 = true
		clone:Destroy()
	end)
	local hud = HudController:GetHud()
	local safeZone = HudController:GetSafeZone()
	v[player] = clone
	local total = 0

	while true do
		if p then
			clone.question.Text = `{player.DisplayName} (@{player.Name}) wants to trade for your <b>{p}</b>! Would you like to accept? {math.ceil(10 - total)}s`
		else
			clone.question.Text = `{player.DisplayName} (@{player.Name}) is requesting to trade with you! Would you like to accept? {math.ceil(10 - total)}s`
		end

		if total > 10 then
			v2 = false
			clone:Destroy()
		end

		task.wait()

		if hud.Enabled and safeZone.Visible then
			total += task.wait()
		end

		if not (v2 ~= nil or not clone.Parent) then
			continue
		end

		v[player] = nil
		return v2 or false
	end
end

Net:RemoteEvent("Trade/CancelRequest", -1).OnClientEvent:Connect(function(p)
	if v[p] then
		v[p]:Destroy()
		v[p] = nil
	end
end)