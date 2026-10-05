local DinoEasterEggsClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local UserInputService = game:GetService("UserInputService")
local mouse = localPlayer:GetMouse()

function GetEasterEggTarget(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	local raycastResult = workspace:Raycast(p.Origin, p.Direction * 100, raycastParams)

	if not raycastResult then
		return nil
	end

	local instance = raycastResult.Instance
	local jailCellar1 = instance:FindFirstAncestor("Jail Cellar1")

	if not jailCellar1 then
		return nil
	end

	local functional = jailCellar1:FindFirstChild("Functional")

	if not functional then
		return nil
	end

	local dinoEasterEggStage = jailCellar1:GetAttribute("DinoEasterEggStage") or 0

	if dinoEasterEggStage == 0 and instance == functional:FindFirstChild("Dino") then
		return instance
	end

	local book = functional:FindFirstChild("Book")

	if dinoEasterEggStage ~= 1 or not (book and instance:IsDescendantOf(book)) then
		return nil
	end

	task.spawn(function()
		Client.Sound.Play("DinoRoomBookPull", {
			Volume = 0.4,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.4
			}
		})
		wait(1)
		Client.Sound.Play("DinoRoomHatch", {
			Volume = 0.3,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.4
			}
		})
	end)
	return book
end

function CheckEasterEggClick(p)
	local v = GetEasterEggTarget(p)

	if v then
		Client.Events.DinoEasterEggClick:FireServer(v)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		CheckEasterEggClick(mouse.UnitRay)
	end
end)
UserInputService.TouchTapInWorld:Connect(function(p, p2)
	if p2 then
		return
	end

	CheckEasterEggClick(workspace.CurrentCamera:ViewportPointToRay(p.X, p.Y))
end)

function DinoEasterEggsClient.Init() end

return DinoEasterEggsClient