local createVector = vector.create
local parent = script.Parent
local WEEE = parent:WaitForChild("Handle"):WaitForChild("WEEE")
local fire = parent:WaitForChild("tube"):WaitForChild("Attachment"):WaitForChild("Fire")
local fire2 = parent:WaitForChild("tube2"):WaitForChild("Attachment"):WaitForChild("Fire")
local swoosh = parent.Handle:WaitForChild("Swoosh")

function Up()
	WEEE.MaxForce = createVector(0, 1e999, 0)
	fire.Enabled = true
	fire2.Enabled = true
	swoosh:Play()
	local humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = 80
end

function Down()
	WEEE.MaxForce = createVector(0, 0, 0)
	fire.Enabled = false
	fire2.Enabled = false
	swoosh:Stop()
	local humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = 15
end

local flag = false
parent.Equipped:Connect(function()
	flag = true
	local humanoid = parent.Parent:WaitForChild("Humanoid")

	while flag do
		if humanoid.MoveDirection.X == 0 and humanoid.MoveDirection.Y == 0 and humanoid.MoveDirection.Z == 0 then
			if fire.Enabled == true then
				Down()
			end
		elseif fire.Enabled == false then
			Up()
		end

		task.wait(0.1)
	end
end)
parent.Unequipped:Connect(function()
	Down()
	flag = false
end)