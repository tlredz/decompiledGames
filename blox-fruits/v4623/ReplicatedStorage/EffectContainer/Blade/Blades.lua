local Util = require(game.ReplicatedStorage.Util)
local CreateBlade = require(script.Parent.Modules.CreateBlade)
return function(player)
	local character = player.Character or player.Root and player.Root.Parent
	local player2 = player.player
	local enabled = player.Enabled
	local ID = player.ID

	if enabled then
		if not (character and character:FindFirstChild("RightLowerArm") and character:FindFirstChild("LeftLowerArm")) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "BladeVisual" .. ID
		folder.Parent = workspace._WorldOrigin
		local blade = CreateBlade(character.RightLowerArm, folder, CFrame.Angles(0, 3.141592653589793, 0), player2)
		local blade2 = CreateBlade(character.LeftLowerArm, folder, nil, player2)
		folder:GetPropertyChangedSignal("Name"):Wait()
		Util.Debris:AddItem(folder, 2)
		task.spawn(function()
			task.spawn(function()
				blade:Shrink()
			end)
			blade2:Shrink()
		end)
	else
		local child = workspace._WorldOrigin:FindFirstChild("BladeVisual" .. ID)

		if child then
			child.Name = "DESTROYING"
		end
	end
end