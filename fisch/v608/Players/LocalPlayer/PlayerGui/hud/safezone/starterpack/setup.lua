game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local _ = ReplicatedStorage.shared.modules
local playerGui = Players.LocalPlayer.PlayerGui
local Monetization = require(ReplicatedStorage.shared.Monetization)
local starterPack = Monetization.products.Others.StarterPack

if not (starterPack and starterPack.Enabled) then
	return
end

local Observers = require(ReplicatedStorage.packages.Observers)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local parent = script.Parent
parent.Close.Activated:Connect(function()
	parent.Visible = false
end)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		ReplicatedStorage.resources.sounds.sfx.treasure.Opening:Play()
	end
end)
local robuxPrice = starterPack.ProductId and Monetization:GetRobuxPrice(starterPack.ProductId)

if robuxPrice then
	parent.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
end

parent.BuyButton.Activated:Connect(function()
	Monetization.BuyProduct:FireServer(starterPack.ProductId)
end)
local starterPack2 = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("right"):WaitForChild("StarterPack")
starterPack2.Visible = false
starterPack2.Activated:Connect(function()
	if parent:GetAttribute("CanOpen") then
		parent.Visible = not parent.Visible
	end
end)
local stats = legacyLocalPlayerData.fetch():WaitForChild("Stats")
Observers.observeChildren(stats, function(instance)
	if instance.Name ~= "starter_pack_timeleft" or instance.Value <= 0 then
		return
	end

	parent:SetAttribute("CanOpen", true)
	starterPack2.Visible = true

	if instance.Value >= Monetization.products.Others.StarterPack.Timer then
		parent.Visible = true
	end

	local v = os.clock() + instance.Value
	local valueChangedConnection = instance:GetPropertyChangedSignal("Value"):Connect(function()
		v = os.clock() + instance.Value
	end)
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local now = os.clock()
		local v2 = v - now
		local v3 = math.floor(v2 / 60)
		local v4 = math.floor(v2) % 60
		parent.timer.title.Text = `Expires in {v3}m {v4}s!`
		starterPack2.timeleft.Text = `Time Left: {v3}m {v4}s`

		if not (v - now <= 0 and heartbeatConnection) then
			return
		end

		parent:SetAttribute("CanOpen", false)
		parent.Visible = false
		starterPack2.Visible = false
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end)
	return function()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		if valueChangedConnection then
			valueChangedConnection:Disconnect()
			valueChangedConnection = nil
		end
	end
end)