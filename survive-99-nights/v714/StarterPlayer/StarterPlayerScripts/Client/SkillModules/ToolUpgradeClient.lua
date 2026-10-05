local TweenService = game:GetService("TweenService")
local ToolUpgradeClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local levelUpFrame = nil
local count = 0
local flag = false

function FlashBar(p)
	local barGlow = levelUpFrame.BarGlow

	if p then
		if flag then
			return
		end

		flag = true
		count += 1
		local v = count
		barGlow.ImageTransparency = 1
		barGlow.Visible = true
		task.spawn(function()
			while count == v do
				TweenService:Create(barGlow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					ImageTransparency = 0.3
				}):Play()
				wait(1)

				if count ~= v then
					continue
				end

				TweenService:Create(barGlow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					ImageTransparency = 1
				}):Play()
				wait(1)
			end
		end)
	else
		if not flag then
			return
		end

		flag = false
		count += 1
		barGlow.Visible = false
		TweenService:Create(barGlow, TweenInfo.new(0.001, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ImageTransparency = 1
		}):Play()
	end
end

local v = {}

function SetXP(value, value2, p, p2)
	local v2 = value2 or 100
	local v3 = math.clamp(value, 0, v2) or 0
	levelUpFrame.Frame.Fill.Size = UDim2.new(v3 / v2, 0, 1, 0)

	if v2 <= v3 then
		levelUpFrame.LevelUp.Visible = true

		if not table.find(v, p2) then
			table.insert(v, p2)
			Client.Sound.Play("FishUpgradeReady")
		end
	else
		levelUpFrame.LevelUp.Visible = false
	end

	levelUpFrame.ImageLabel.TextLabel.Text = "lvl " .. p
end

local xPChangedConnection = nil
local v2 = {
	["Fishing Rod"] = true,
	["Taming Flute"] = true
}
local v3 = {
	["Woodsman's Axe"] = "AxeLevel",
	["Happy's Scythe"] = "ScytheLevel"
}
local v4 = {
	["Fishing Rod"] = "rbxassetid://87577115243377",
	["Taming Flute"] = "rbxassetid://98992788742793",
	["Woodsman's Axe"] = "rbxassetid://107550698615106",
	["Happy's Scythe"] = "rbxassetid://105269822208657"
}
Client.Events.EquippedItemChanged:Connect(function(instance)
	local flag2 = false

	if xPChangedConnection then
		xPChangedConnection:Disconnect()
	end

	if instance then
		if v3[instance.Name] then
			levelUpFrame.ImageLabel.Image = v4[instance.Name] or ""

			local function refresh()
				local levelUpXP = instance:GetAttribute("LevelUpXP") or 0

				if levelUpXP <= 0 then
					levelUpFrame.Visible = false
					return
				end

				levelUpFrame.Visible = true
				SetXP(
					instance:GetAttribute("XP") or 0,
					levelUpXP,
					instance:GetAttribute(v3[instance.Name]) or 1,
					instance
				)
			end

			refresh()
			xPChangedConnection = instance:GetAttributeChangedSignal("XP"):Connect(refresh)
		elseif instance:GetAttribute("ToolName") and v2[instance:GetAttribute("ToolName")] and (not instance:GetAttribute("ToolTier") or instance:GetAttribute("ToolTier") ~= 3) then
			local XP = instance:GetAttribute("XP") or 0
			local toolName = instance:GetAttribute("ToolName")

			if v4[toolName] then
				levelUpFrame.ImageLabel.Image = v4[toolName]
			end

			levelUpFrame.Visible = true
			SetXP(XP, instance:GetAttribute("LevelUpXP"), instance:GetAttribute("ToolTier"), instance)
			xPChangedConnection = instance:GetAttributeChangedSignal("XP"):Connect(function()
				SetXP(
					instance:GetAttribute("XP"),
					instance:GetAttribute("LevelUpXP"),
					instance:GetAttribute("ToolTier"),
					instance
				)
			end)

			if (XP or 0) < (instance:GetAttribute("LevelUpXP") or 100) then
				FlashBar(false)
			end
		else
			flag2 = true
		end
	else
		flag2 = true
	end

	if flag2 then
		levelUpFrame.Visible = false
		FlashBar(false)
	end
end)

function IsReadyForUpgrade(instance)
	local XP = instance:GetAttribute("XP")
	local levelUpXP = instance:GetAttribute("LevelUpXP")
	local v5 = v2[instance:GetAttribute("ToolName")]

	if v5 then
		if (instance:GetAttribute("ToolTier") or 1) < 3 then
			return XP and levelUpXP and levelUpXP <= XP
		else
			return false
		end
	end

	return v5
end

function RunUpgradeFlashLoop()
	local inventory = localPlayer:WaitForChild("Inventory")

	while true do
		local v5 = false

		for _, child in pairs(inventory:GetChildren()) do
			if IsReadyForUpgrade(child) then
				v5 = true
			end
		end

		Client.Events.ToolUpgradeFlash:Fire(v5)
		task.wait(2.85)
	end
end

function ToolUpgradeClient.Init()
	levelUpFrame = Client.Interface.LevelUpFrame
	task.spawn(RunUpgradeFlashLoop)
end

return ToolUpgradeClient