local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local chooseMap = localPlayer.PlayerGui:WaitForChild("ChooseMap")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Shared.MapData)
local v5 = require3(ReplicatedStorage2.ServerInfo)
local v6 = nil
local clone = nil
local v7 = nil
local queueGameMode = nil
local queueType = nil
local thread = nil
local v8 = {}
local mapFound = v.new()
_G.mapFound = mapFound
local ChooseMapController = {}

function ChooseMapController.Start(_)
	mapFound:Connect(function(p: string)
		v6 = p
		ChooseMapController:SetRankedTeleportUI(p)
		ChooseMapController:OnMapFound(p)
	end)

	for _, parent in ipairs({
		chooseMap.Header,
		chooseMap.Loading,
		chooseMap.MapButton,
		chooseMap.Box
	}) do
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 1
		uIScale.Parent = parent
		table.insert(v8, uIScale)
	end

	clone = chooseMap:Clone()
	clone.Parent = script
	localPlayer:GetAttributeChangedSignal("QueueGameMode"):Connect(function()
		queueGameMode = localPlayer:GetAttribute("QueueGameMode") or queueGameMode
	end)
	localPlayer:GetAttributeChangedSignal("QueueType"):Connect(function()
		queueType = localPlayer:GetAttribute("QueueType") or queueType
	end)
end

function ChooseMapController.CancelMapFound(_, flag: boolean?)
	v6 = nil
	v3:Unlock("ChooseMap", true)
	v3:Close("ChooseMap", true)

	if typeof(thread) == "thread" then
		task.cancel(thread)
	end

	if not flag then
		v2(Enum.CoreGuiType.Chat, true)
		v2(Enum.CoreGuiType.PlayerList, true)
	end
end

function ChooseMapController:DestroyRankedTeleportUI(flag: boolean?)
	if v7 then
		v7:Destroy()
		v7 = nil

		if not flag then
			TeleportService:SetTeleportGui(ReplicatedFirst:WaitForChild("TeleportUI"))
		end
	end
end

function ChooseMapController:SetRankedTeleportUI(p: string)
	ChooseMapController:DestroyRankedTeleportUI(true)
	local clone2 = clone:Clone()
	clone2.Name = "RankedTeleportUI"
	local queueType2 = localPlayer:GetAttribute("QueueType")
	local queueGameMode2 = localPlayer:GetAttribute("QueueGameMode")

	local function updateMode()
		queueType2 = localPlayer:GetAttribute("QueueType")
		queueGameMode2 = localPlayer:GetAttribute("QueueGameMode")
		local label = clone2.Box.Label
		local text

		if queueType2 == "Ranked" then
			text = `RANKED {queueGameMode2:upper()}`
		else
			text = string.upper((`{queueGameMode2} {queueType2}`))
		end

		label.Text = text
	end

	if queueGameMode2 then
		updateMode()
	else
		localPlayer:GetAttributeChangedSignal("QueueGameMode"):Once(updateMode)
		localPlayer:GetAttributeChangedSignal("QueueType"):Once(updateMode)
		clone2.Box.Label.Text = ""
	end

	local v10 = {}

	for _, uIScale in ipairs(clone2:GetDescendants()) do
		if not uIScale:IsA("UIScale") then
			continue
		end

		table.insert(v10, uIScale)
		uIScale.Scale = 1
	end

	clone2.VFX.Glow.ImageTransparency = 0
	clone2.VFX.Circle.BackgroundTransparency = 0
	clone2.VFX.Size = UDim2.fromScale(1, 1)
	clone2.VFX.Circle.Visible = false
	clone2.VFX.Glow.Visible = false
	clone2.VFX.Visible = false
	clone2.Loading.Visible = true
	clone2.Box.Visible = true
	clone2.DisplayOrder = 20000000
	local visible = (localPlayer:GetAttribute("QueueType") or queueType) ~= "Duel"
	clone2.Header.Visible = visible
	clone2.MapButton.Visible = visible

	if v5:GetRankType() == "NoAbility" then
		clone2.Box.Mode.Visible = true
	end

	local v12 = v4[p]

	if v12 then
		clone2.MapButton.MapName.Text = v12.DisplayName:upper()
		clone2.MapImage.Image = v12.Thumbnail or v12.RankedImage or v12.Image
	else
		clone2.MapButton.MapName.Text = "FAILED_TO_GET_MAP"
		clone2.MapImage.Image = ""
	end

	clone2.Enabled = true
	clone2.Parent = ReplicatedFirst
	v7 = clone2
	TeleportService:SetTeleportGui(clone2)
end

function ChooseMapController:OnMapFound(value: string)
	chooseMap.VFX.Glow.ImageTransparency = 0
	chooseMap.VFX.Circle.BackgroundTransparency = 0
	chooseMap.VFX.Size = UDim2.fromScale(1, 1)
	chooseMap.VFX.Circle.Visible = true
	chooseMap.VFX.Glow.Visible = true
	chooseMap.VFX.Visible = true
	chooseMap.Header.Visible = false
	chooseMap.Loading.Visible = false
	chooseMap.MapButton.Visible = false
	chooseMap.Box.Visible = false

	for _, v10 in ipairs(v8) do
		v10.Scale = 0.8
	end

	if v5:GetRankType() == "NoAbility" then
		chooseMap.Box.Mode.Visible = true
	end

	local queueGameMode2 = localPlayer:GetAttribute("QueueGameMode") or queueGameMode or "FFA"
	local queueType2 = localPlayer:GetAttribute("QueueType") or queueType or "Ranked"
	local label = chooseMap.Box.Label
	local text

	if queueType2 == "Ranked" then
		text = `RANKED {queueGameMode2:upper()}`
	else
		text = string.upper((`{queueGameMode2} {queueType2}`))
	end

	label.Text = text
	local v11 = v4[value]

	if queueType2 == "Duel" then
		chooseMap.MapImage.Image = not v11 and "" or v11.RankedImage or v11.Image or ""
		chooseMap.MapButton.MapName.Text = ""
	elseif v11 then
		chooseMap.MapButton.MapName.Text = v11.DisplayName:upper()
		chooseMap.MapImage.Image = v11.RankedImage or v11.Image
	else
		chooseMap.MapButton.MapName.Text = value:upper()
		chooseMap.MapImage.Image = ""
	end

	local tween = TweenService:Create(
		chooseMap.VFX,
		TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{
			Size = UDim2.fromScale(4, 4)
		}
	)
	local tween2 = TweenService:Create(
		chooseMap.VFX.Circle,
		TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		{
			BackgroundTransparency = 1
		}
	)
	local tween3 = TweenService:Create(
		chooseMap.VFX.Glow,
		TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		{
			ImageTransparency = 1
		}
	)
	local v12 = {}

	for _, v13 in ipairs(v8) do
		table.insert(
			v12,
			TweenService:Create(v13, TweenInfo.new(0.425, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Scale = 1
			})
		)
	end

	chooseMap.Enabled = true
	tween:Play()
	tween.Completed:Wait()
	_G.cancelMatchFound:Fire(true)
	v3:CloseCurrent(true)
	chooseMap.Loading.Visible = true
	local visible = (localPlayer:GetAttribute("QueueType") or queueType) ~= "Duel"
	chooseMap.Header.Visible = visible
	chooseMap.MapButton.Visible = visible
	chooseMap.Box.Visible = true
	thread = task.spawn(function()
		while true do
			for i = 1, 3 do
				local v14 = ("."):rep(i)
				chooseMap.Loading.Text = ("Loading Map%s"):format(v14)
				task.wait(0.5)
			end
		end
	end)
	tween2:Play()
	tween3:Play()
	tween3.Completed:Once(function()
		chooseMap.VFX.Circle.Visible = false
		chooseMap.VFX.Glow.Visible = false
	end)

	for _, v14 in ipairs(v12) do
		v14:Play()
	end

	v12[#v12].Completed:Wait()
end

return ChooseMapController