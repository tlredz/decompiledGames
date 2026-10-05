local createVector = vector.create
local JungleArenaClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = nil

function ToggleWarning(instance, p)
	local inZonePart = instance:WaitForChild("Functional"):WaitForChild("InZonePart")

	if p then
		inZonePart.Transparency = 0.99999
		inZonePart.Highlight.Enabled = true
	else
		inZonePart.Transparency = 1
		inZonePart.Highlight.Enabled = false
	end

	local timeOut = instance:GetAttribute("TimeOut")

	if not (p and timeOut) then
		Client.Interface.ArenaPopUpMessage.Visible = false
		return
	end

	local v2 = math.max(math.ceil(timeOut - workspace:GetServerTimeNow()), 0)
	local arenaPopUpMessage = Client.Interface.ArenaPopUpMessage
	arenaPopUpMessage.TextLabel.Text = "You have " .. v2 .. " seconds to return to the fight pits"
	arenaPopUpMessage.Visible = true
end

Client.Events.JungleArenaEnded:Connect(function()
	if v then
		ToggleWarning(v, false)
	end

	v = nil
end)
Client.Events.JungleArenaStarted:Connect(function(instance)
	if not instance then
		return
	end

	v = instance
	local cFrame = instance:WaitForChild("Functional"):WaitForChild("InZonePart").CFrame

	while v == instance do
		if localPlayer.Character then
			local pivot = localPlayer.Character:GetPivot()
			local magnitude = ((pivot.Position - cFrame.Position) * createVector(1, 0, 1)).Magnitude
			local v3 = math.abs(pivot.Y - cFrame.Y)

			if magnitude < 90 and v3 < 6 or magnitude < 58 and v3 < 26 then
				ToggleWarning(instance, false)
			else
				ToggleWarning(instance, true)
			end
		end

		task.wait()
	end

	ToggleWarning(instance, false)
end)
Client.InteractionHandler.RegisterInteraction("JungleArenaButton", function(p)
	print("start jungle arena")
	Client.Events.RequestStartJungleArena:FireServer(p.Parent.Parent)
end)

function JungleArenaClient.Init() end

return JungleArenaClient