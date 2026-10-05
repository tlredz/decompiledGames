local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Shared.LTM)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local currentLTM = v3.getCurrentLTM()
local lTMServer = v2.isLTMServer()

if lTMServer then
	lTMServer = currentLTM and currentLTM.getGameMode() == "Flying"
end

v3.OnModeChange(function(p)
	lTMServer = v2.isLTMServer() and p.getGameMode() == "Flying"
end)
local lTMDashCharge = playerGui:WaitForChild("LTMDashCharge")
local v4 = 50
local tweens = {}
v:RemoteFunction("UseFlyingDash")
local remoteEvent = v:RemoteEvent("DashPowerChanged")
local alive = workspace:WaitForChild("Alive")
local dead = workspace:WaitForChild("Dead")

function DestroyTweens()
	for _, v5 in ipairs(tweens) do
		v5:Destroy()
	end

	table.clear(tweens)
end

function ResetGui()
	v4 = 50
	OnDashPowerChanged(v4, true)
end

function RefreshGui()
	local v5 = workspace:GetAttribute("CurrentlySelectedMode") == "Hovergoal"
	local character = localPlayer.Character

	if (lTMServer or v5) and character and character:IsDescendantOf(workspace.Alive) then
		ResetGui()
		lTMDashCharge.Enabled = true
	else
		lTMDashCharge.Enabled = false
	end
end

function FormatTextStroke(p: string)
	return (`<stroke color="rgb(89, 30, 0)" joins="round" thickness="2">{p}</stroke>`)
end

function OnDashPowerChanged(value: number, flag: boolean?)
	DestroyTweens()
	local v5 = math.clamp(value, 0, 100)
	local text

	if v5 == 100 then
		text = FormatTextStroke("DASH (CLICK or PRESS ABILITY KEY)")
	else
		text = FormatTextStroke((`Boost: {v5}/{100}`))
	end

	lTMDashCharge.Container.Amount.Text = text
	lTMDashCharge.Container.BarContainer.Bar.Visible = v5 > 0

	if flag then
		lTMDashCharge.Container.BarContainer.Bar.Size = UDim2.fromScale(math.min(v5 / 100, 1), 1)
	else
		local tween = TweenService:Create(
			lTMDashCharge.Container.BarContainer.Bar,
			TweenInfo.new(1, Enum.EasingStyle.Linear),
			{
				Size = UDim2.fromScale(math.min(v5 / 100, 1), 1)
			}
		)
		tween.Completed:Once(function()
			local index = table.find(tweens, tween)

			if index then
				table.remove(tweens, index)
			end
		end)
		tween:Play()
		table.insert(tweens, tween)
	end

	v4 = value
end

return {
	Start = function(_)
		alive.ChildAdded:Connect(function(child)
			local character = localPlayer.Character

			if character and child == character then
				RefreshGui()
			end
		end)
		alive.ChildRemoved:Connect(function(child)
			local character = localPlayer.Character

			if character and child == character then
				RefreshGui()
			end
		end)
		dead.ChildAdded:Connect(function(child)
			local character = localPlayer.Character

			if character and child == character then
				RefreshGui()
			end
		end)
		remoteEvent.OnClientEvent:Connect(OnDashPowerChanged)
	end
}