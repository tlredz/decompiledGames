local DroppingTileClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local v = false

local function isPlayerTouching(touchZone)
	local partBoundsInBox = workspace:GetPartBoundsInBox(touchZone.CFrame, touchZone.Size)

	for _, v2 in pairs(partBoundsInBox) do
		if game.Players:GetPlayerFromCharacter(v2.Parent) then
			return true
		end
	end
end

function OnTileFullyDropped(p)
	print("TILE FULLY DROPPED")
	local parent = p.Parent
	Client.Events.StopSound:Fire("StoneSliding", {
		FadeTime = 0.15
	})

	if parent:FindFirstChild("ArrowTrapFolder") then
		Client.ArrowTrapClient.FireArrows(parent)
	end
end

function DroppingTileAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local tile = instance:WaitForChild("Tile")
	local touchZone = instance:WaitForChild("TouchZone")
	local flag = false
	local dropTime = instance:GetAttribute("DropTime") or 1
	local dropDistance = instance:GetAttribute("DropDistance") or 2
	local v2 = false
	local pivot = tile:GetPivot()
	local v3 = dropDistance / dropTime
	local v4 = 0
	touchZone.Touched:Connect(function(otherPart)
		if flag then
			return
		end

		if game.Players:GetPlayerFromCharacter(otherPart.Parent) then
			flag = true
			v = instance
			Client.Sound.Play("StoneSliding", {
				Volume = 0.3
			})

			while true do
				local v5 = RunService.PreRender:Wait()
				local playerTouching = isPlayerTouching(touchZone)

				if v4 == 0 and not playerTouching then
					break
				end

				if playerTouching then
					v4 += v3 * v5
				else
					v4 -= v3 * v5
				end

				if dropDistance <= v4 and not v2 then
					v2 = true
					OnTileFullyDropped(instance)
				end

				v4 = math.clamp(v4, 0, dropDistance)
				tile:PivotTo(pivot - Vector3.new(0, v4, 0))
			end

			v2 = false
			flag = false

			if v == instance then
				Client.Events.StopSound:Fire("StoneSliding", {
					FadeTime = 0.15
				})
			end
		end
	end)
end

function DroppingTileClient.Init()
	Client.Utility.ForAllTagged("DroppingTile", DroppingTileAdded)
end

return DroppingTileClient