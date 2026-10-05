local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarkerHandler = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
return {
	Tasks = {
		["Deliver Dr. Higoshima"] = {
			Do = function(instance, _, object)
				local v = false
				local flag = false
				local v2 = nil

				-- equivalent calls inferred from this helper; original call sites unknown
				local function clearZone()
					if flag then
						flag = false
						MarkerHandler.removeMarker("Muzan Quest - Deliver Dr. Higoshima")
					end

					if v2 ~= nil then
						v2:Destroy()
						v2 = nil
					end
				end

				object:Add(clearZone)

				local function sync()
					local higoshimaDeliverTo = instance:GetAttribute("HigoshimaDeliverTo")
					local v3 = typeof(higoshimaDeliverTo) == "CFrame"

					if v3 or v then
						if v3 and v then
							v = false
							MarkerHandler.removeMarker("Muzan Quest - Dr. Higoshima")
						end
					else
						v = true
						MarkerHandler.addMarker("Muzan Quest - Dr. Higoshima", {
							position = MuzanSettings.HigoshimaSpawn.Position + createVector(0, 3, 0),
							img = BunchaIcons.Combat,
							minDistance = 35,
							margin = 10
						})
					end

					if v3 and not flag then
						flag = true
						MarkerHandler.addMarker("Muzan Quest - Deliver Dr. Higoshima", {
							markerType = MarkerHandler.markerType.Regular,
							style = "Simple",
							img = "rbxassetid://78675452486649",
							position = higoshimaDeliverTo.Position + createVector(0, 3, 0),
							tag = "HigoshimaZoneMarker"
						})
						local higoshimaSafeZone = script:FindFirstChild("HigoshimaSafeZone")

						if higoshimaSafeZone ~= nil and higoshimaSafeZone:IsA("Model") and v2 == nil then
							local clone = higoshimaSafeZone:Clone()

							for _, part in clone:GetDescendants() do
								if part:IsA("BasePart") then
									part.Anchored = true
								end
							end

							clone:PivotTo(higoshimaDeliverTo)
							clone.Parent = workspace.Debree
							v2 = clone
						end
					elseif not v3 and flag then
						clearZone() -- equivalent call inferred; original call site unknown
					end
				end

				object:Connect(instance:GetAttributeChangedSignal("HigoshimaDeliverTo"), sync)
				sync()
			end,
			Stop = function(_, _, _)
				MarkerHandler.removeMarker("Muzan Quest - Dr. Higoshima")
			end
		}
	}
}