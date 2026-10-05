local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage2.shared.modules:WaitForChild("fx"))
require(ReplicatedStorage.shared.utils.Spring)
local cathuluChainBreakIK = nil
local v = 0
local Net = require(ReplicatedStorage.packages.Net)
local cthuluBoss = game.Players.LocalPlayer.PlayerGui:WaitForChild("CthuluBoss")
local remoteEvent = Net:RemoteEvent("CthuluAttack")
local subtitles = require(ReplicatedStorage.client.modules.subtitles)
ReplicatedStorage.events.cthuluEvent.OnClientEvent:Connect(function(p, ...)
	if p == "setLookAngle" then
		v = select(1, ...)
	elseif p == "phase2start" then
		subtitles.show("That's all?", 1.4, "cthulu")
		task.delay(2.3, function()
			subtitles.show("You can do better than that!", 3, "cthulu")
		end)
	end
end)
remoteEvent.OnClientEvent:Connect(function(p, ...)
	local WAIT_INTERVAL = 0.2
	local cthulu = workspace:FindFirstChild("active"):FindFirstChild("bosses"):FindFirstChild("cthulu")

	if cthulu then
		cathuluChainBreakIK = cthulu:FindFirstChild("CathuluChainBreakIK")

		if cthulu:GetAttribute("players") and cathuluChainBreakIK and cathuluChainBreakIK:GetAttribute("Health") then
			if not table.find(cthulu:GetAttribute("players"):split(","), (tostring(game.Players.LocalPlayer.UserId))) then
				return
			end

			if p == "AOEAttack" then
				local highlight = workspace.active.bosses.cthulu.AOEIndicator.Highlight
				task.wait(WAIT_INTERVAL)
				fx:PlaySound(script.AOEAttack.Sound, game.Players.LocalPlayer.PlayerGui, true)
				highlight.Enabled = true
				task.wait(WAIT_INTERVAL)
				highlight.Enabled = false
				task.wait(WAIT_INTERVAL)
				highlight.Enabled = true
				task.wait(WAIT_INTERVAL)
				task.delay(0.4, function()
					highlight.Enabled = false
				end)
				local AOEAttack = require(script.AOEAttack)
				local v2 = AOEAttack.new(game.Players.LocalPlayer.Character)
				v2:Play(script.AOEAttack.location.CFrame.Position)
				v2:Clean()
			else
				local v2 = ...
				local DirectedAttack = require(script.DirectedAttack)
				local v3 = DirectedAttack.new(game.Players.LocalPlayer.Character)
				v3:Play(
					cathuluChainBreakIK.RootPart.RootThingy.Torso.UpperTorso["Shoulder.R"].rightarm.WorldPosition + createVector(
						0,
						30,
						0
					),
					v2
				)
				v3:Clean()
			end
		end
	end
end)
RunService.Stepped:Connect(function()
	local cthulu = workspace:FindFirstChild("active"):FindFirstChild("bosses"):FindFirstChild("cthulu")

	if cthulu then
		cathuluChainBreakIK = cthulu:FindFirstChild("CathuluChainBreakIK")

		if cthulu:GetAttribute("players") and cathuluChainBreakIK and cathuluChainBreakIK:GetAttribute("Health") then
			if table.find(cthulu:GetAttribute("players"):split(","), (tostring(game.Players.LocalPlayer.UserId))) and not workspace:GetAttribute("ClientCutsceneRunning") then
				cthuluBoss.Enabled = true
				cthuluBoss.Frame.Fill.Size = UDim2.fromScale(
					cathuluChainBreakIK:GetAttribute("Health") / cathuluChainBreakIK:GetAttribute("MaxHealth"),
					1
				)
			else
				cthuluBoss.Enabled = false
			end
		end
	end

	if cathuluChainBreakIK then
		if not cathuluChainBreakIK:GetAttribute("cf") then
			cathuluChainBreakIK:SetAttribute("cf", cathuluChainBreakIK:GetPivot())
		end

		local rootThingy = cathuluChainBreakIK:FindFirstChild("RootPart"):FindFirstChild("RootThingy")
		rootThingy.CFrame = rootThingy.CFrame:Lerp(CFrame.Angles(0, v, 0), 0.03)
	end
end)
return nil