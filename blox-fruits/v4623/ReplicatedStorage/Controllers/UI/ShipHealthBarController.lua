local Realm = require(game.ReplicatedStorage.Util.Realm)
local localPlayer = game.Players.LocalPlayer
return {
	OnStart = function(_)
		local PlayerUtil = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtil"))
		PlayerUtil.ScreenReady({ "Main" }, function(p)
			local v = assert(p.Main, "bad mainScreenGui")
			local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
			local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
			local HealthBar = require(game.ReplicatedStorage:WaitForChild("ClientComponents").HealthBar)
			local IsPointInsideShipBounds = require(game.ReplicatedStorage:WaitForChild("IsPointInsideShipBounds"))
			local shipHealthBar = v.BottomHUDList.ShipHealthBar
			local _, v2 = HealthBar:WaitForInstance(shipHealthBar):await()
			local mobileShipHealthBar, v3

			if LastInput:IsMobile() then
				mobileShipHealthBar = v:WaitForChild("MobileShipHealthBar")
				local v4
				v4, v3 = HealthBar:WaitForInstance(mobileShipHealthBar):await()
			else
				v3 = nil
				mobileShipHealthBar = nil
			end

			task.defer(function()
				local boats = workspace.Boats

				while true do
					task.wait()
					task.wait()
					task.wait()
					task.wait()
					task.wait()
					local character = localPlayer.Character

					if not character then
						continue
					end

					local position = character:GetPivot().Position
					local v4 = nil

					for _, child in boats:GetChildren() do
						local humanoid = child:FindFirstChild("Humanoid")

						if not humanoid or humanoid.Value <= 0 or not IsPointInsideShipBounds(position, child) then
							continue
						end

						local Global = require(game.ReplicatedStorage.Global)
						Global.LocalOnboardShip = child
						v4 = child
						break
					end

					local humanoid = v4 and v4:FindFirstChild("Humanoid")

					if humanoid then
						v2:SetHumanoid(humanoid)

						if v3 then
							v3:SetHumanoid(humanoid)
						end

						local isNewUIEnabled = MobileUIController:IsNewUIEnabled()

						if Realm.getIfCurrentRealmHasTagAsync("HasSeaEvents") == false then
							local health, v6 = v2:GetHealth()
							shipHealthBar.Visible = health < v6

							if v3 then
								mobileShipHealthBar.Visible = health < v6
							end
						end

						if v3 and not isNewUIEnabled then
							mobileShipHealthBar.Visible = false
						end

						if isNewUIEnabled then
							shipHealthBar.Visible = false
						end
					else
						v2:SetHumanoid(nil)

						if v3 then
							v3:SetHumanoid(nil)
						end
					end

					for _, child in boats:GetChildren() do
						local humanoid2 = child:FindFirstChild("Humanoid")

						if not humanoid2 or humanoid2.Value <= 0 then
							continue
						end

						local shipHealthBBG = child:FindFirstChild("ShipHealthBBG")
						local v6 = shipHealthBBG and HealthBar:FromInstance(shipHealthBBG:FindFirstChild("ShipHealthBar"))

						if not v6 or v6.humanoid then
							continue
						end

						v6:SetHumanoid(humanoid2)
					end
				end
			end)
		end, (`Init {script.Name}`))
	end
}