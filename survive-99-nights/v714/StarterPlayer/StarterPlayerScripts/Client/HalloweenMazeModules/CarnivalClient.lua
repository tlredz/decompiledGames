local CarnivalClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()

function PrintTicket(instance, instance2)
	local pivot = instance2:GetPivot()
	local v = pivot * CFrame.new(-4, 0, 0)
	local lever = instance:FindFirstChild("Lever")
	local pivot2 = lever and lever:GetPivot()
	instance2:PivotTo(pivot)
	instance2.Parent = workspace.Items
	Client.Sound.Play("TicketPrint", {
		Position = pivot.Position,
		Replicate = true
	})

	for i = 1, 4 do
		local v2 = i
		Client.TweenModule.new(function(p)
			local v3 = (v2 - 1) * 0.25 + 0.25 * p
			instance2:PivotTo((pivot:Lerp(v, v3)))

			if lever then
				local v4 = v3 * 200
				lever:PivotTo(pivot2 * CFrame.Angles(0, 0, (math.rad(v4))))
			end
		end, 0.3):Play()
		task.wait(0.3)
		task.wait(0.2)
	end
end

Client.Events.PrintCarnivalTicket:Connect(PrintTicket)

function CarnivalClient.Init() end

return CarnivalClient