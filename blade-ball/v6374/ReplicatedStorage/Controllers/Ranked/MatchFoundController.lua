local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TeleportService")
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("ReplicatedFirst")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local matchFound = Players.LocalPlayer.PlayerGui:WaitForChild("MatchFound")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Controllers.Ranked.ChooseMapController)
local remoteEvent = v:RemoteEvent("RankedMatchFound")
local cancelMatchFound = v2.new()
_G.cancelMatchFound = cancelMatchFound
local v7 = {
	Left = {
		Active = {
			Position = UDim2.fromScale(0, 0.5),
			AnchorPoint = Vector2.new(0, 0.5)
		},
		Inactive = {
			Position = UDim2.fromScale(-2, 0.5),
			AnchorPoint = Vector2.new(0, 0.5)
		}
	},
	Right = {
		Active = {
			Position = UDim2.fromScale(1, 0.5),
			AnchorPoint = Vector2.new(1, 0.5)
		},
		Inactive = {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(2, 0.5)
		}
	}
}
local flag = false
local v8 = {}
local MatchFoundController = {}

function MatchFoundController.Start(_)
	cancelMatchFound:Connect(function(flag2: boolean)
		return MatchFoundController:CancelMatchFound(flag2)
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string, flag2: boolean)
		if flag2 then
			flag = true
			MatchFoundController:MatchFound(p)
		else
			v5:DestroyRankedTeleportUI()
			MatchFoundController:CancelMatchFound(false)
		end
	end)

	for _, parent in ipairs({
		matchFound.Frame.CountdownSpritesheet,
		matchFound.Frame.Header,
		matchFound.Frame.Subheader
	}) do
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 1
		uIScale.Parent = parent
		table.insert(v8, uIScale)
	end
end

function MatchFoundController:CancelMatchFound(flag2: boolean)
	flag = false
	v4:Unlock("MatchFound", true)
	v4:Close("MatchFound", true)

	if not flag2 then
		v4:Unlock("ChooseMap", true)
		v4:Close("ChooseMap", true)
		v3(Enum.CoreGuiType.Chat, true)
		v3(Enum.CoreGuiType.PlayerList, true)
	end
end

function MatchFoundController:MatchFound(value: string)
	v4:CloseCurrent(true)
	v3(Enum.CoreGuiType.Chat, false)
	v3(Enum.CoreGuiType.PlayerList, false)
	local matchFound_VA

	if LocalizationService.RobloxLocaleId:find("en") ~= nil then
		matchFound_VA = script.MatchFound_VA
	else
		matchFound_VA = script.MatchFound_NoVA
	end

	task.defer(function()
		local soundIds = { "rbxassetid://15840773325", "rbxassetid://15851499402", "rbxassetid://9379271565" }
		table.insert(soundIds, matchFound_VA.SoundId)
		ContentProvider:PreloadAsync(soundIds)
	end)
	matchFound.Frame.CountdownSpritesheet.ImageRectOffset = Vector2.new(0, 0)
	matchFound.BlackoutBottom.BackgroundTransparency = 1
	matchFound.Frame.Visible = false
	matchFound.Frame.CountdownSpritesheet.Visible = false
	matchFound.Frame.Header.Visible = false
	matchFound.Frame.Subheader.Visible = false
	matchFound.Frame.Glow.Visible = false
	matchFound.Frame.Glow.ImageTransparency = 0.3
	matchFound.VFX.Left.Size = UDim2.fromScale(0.5, 1)
	matchFound.VFX.Left.Position = v7.Left.Inactive.Position
	matchFound.VFX.Left.AnchorPoint = v7.Left.Inactive.AnchorPoint
	matchFound.VFX.Right.Size = UDim2.fromScale(0.5, 1)
	matchFound.VFX.Right.Position = v7.Right.Inactive.Position
	matchFound.VFX.Right.AnchorPoint = v7.Right.Inactive.AnchorPoint

	for _, v9 in ipairs(v8) do
		v9.Scale = 0.8
	end

	local tween = TweenService:Create(
		matchFound.BlackoutBottom,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{
			BackgroundTransparency = 0.25
		}
	)
	local tween2 = TweenService:Create(
		matchFound.VFX.Left,
		TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		{
			Position = v7.Right.Active.Position,
			AnchorPoint = v7.Right.Active.AnchorPoint
		}
	)
	local tween3 = TweenService:Create(
		matchFound.VFX.Right,
		TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		{
			Position = v7.Left.Active.Position,
			AnchorPoint = v7.Left.Active.AnchorPoint
		}
	)
	local tween4 = TweenService:Create(
		matchFound.Frame.Glow,
		TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true),
		{
			ImageTransparency = 0.8
		}
	)
	local tween5 = TweenService:Create(
		matchFound.VFX.Left,
		TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{
			Size = UDim2.fromScale(0, 1)
		}
	)
	local tween6 = TweenService:Create(
		matchFound.VFX.Right,
		TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{
			Size = UDim2.fromScale(0, 1)
		}
	)
	local v9 = {}

	for _, v10 in ipairs(v8) do
		table.insert(
			v9,
			TweenService:Create(v10, TweenInfo.new(0.425, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Scale = 1
			})
		)
	end

	v5:SetRankedTeleportUI(value)
	v4:Open("MatchFound", true)
	v4:Lock("MatchFound", true)
	tween:Play()
	tween.Completed:Wait()
	task.delay(0.1, function()
		matchFound_VA:Play()
	end)
	tween2:Play()
	tween3:Play()
	tween3.Completed:Wait()
	task.wait(0.1)
	matchFound.Frame.Glow.Visible = true
	matchFound.Frame.CountdownSpritesheet.Visible = true
	matchFound.Frame.Header.Visible = true
	matchFound.Frame.Subheader.Visible = true
	matchFound.Frame.Visible = true
	tween5:Play()
	tween6:Play()
	tween6.Completed:Once(function()
		tween4:Play()
	end)

	for _, v10 in ipairs(v9) do
		v10:Play()
	end

	v9[#v9].Completed:Wait()

	for i = 5, 1, -1 do
		if i == 5 then
			task.wait(1)
		else
			local tween7 = TweenService:Create(
				matchFound.Frame.CountdownSpritesheet,
				TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
				{
					ImageRectOffset = Vector2.new(0, (5 - i) * 200)
				}
			)
			tween7:Play()
			tween7.Completed:Wait()
			task.wait(0.5)
		end
	end

	_G.mapFound:Fire(value or "Heaven")
end

return MatchFoundController