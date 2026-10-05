local createVector = vector.create
local RunService = game:GetService("RunService")
local import = _G.import("event")
local import2 = _G.import("clientUtil")

if RunService:IsClient() then
	local currentCamera = workspace.CurrentCamera
	local import3 = _G.import("bodyUtil")
	local import4 = _G.import("cameraUtil")
	import.remoteConnect("attack", function(list, p, p2, p3)
		local v2, v3 = unpack(list)
		local table = workspace.Meta.Tables[tostring(p2)]
		local v4 = table.MatchPets[tostring(v2)][tostring(v3)]
		local pet = v4.Pet
		local primaryPart = pet.PrimaryPart or pet.HumanoidRootPart
		local chair = table.Chairs[tostring(p)]
		import.fire("cutscene", function()
			local cFrame = primaryPart.CFrame
			local v5 = chair.CFrame * CFrame.new(0, 1.5, 0)
			local v6 = cFrame.Position - v5.Position
			local v7 = v6.Magnitude < 0.001 and createVector(0, 0, -1) or v6.Unit
			local v8 = v5.Position + v7 * 1.75 + createVector(0, 0.5, 0)
			v4:SetAttribute("PausePetBob", true)
			local petWeld = v4.PetWeld
			local baseCF = v4:GetAttribute("BaseCF")
			local cframe = v4.PetAnchorWeld.Part0.CFrame * v4.PetAnchorWeld.C0
			local C0 = petWeld.C0

			if p3 then
				currentCamera.CameraType = "Scriptable"
				currentCamera.CFrame = CFrame.new((v5 * CFrame.new(7, 7, 7)).p, v5.Position)
			end

			local v9 = CFrame.new(v8, cFrame.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			local v10 = v9 * CFrame.new(0, 0, 0.05)
			local objectSpace = cframe:ToObjectSpace(v9)
			local objectSpace2 = cframe:ToObjectSpace(v10)
			import2.sound("QuickTransition1")
			import3.jump(petWeld, 0.35, C0, objectSpace, 4)

			if p3 then
				import2.sound("NormalHit")
				import.fire("strike", nil, 1, true)
				import4.explosion(v9.p, 15, 1000)
			end

			import3.jump(petWeld, 0.35, objectSpace, objectSpace2, 2)
			import3.jump(petWeld, 0.35, objectSpace2, baseCF, 3)
			task.wait(0.15)
			v4:SetAttribute("PausePetBob", nil)
		end)
	end)
end

return {
	Slime = {
		Info = {
			DisplayName = "Slime",
			Description = "Steal 3s",
			PetDescription = "Every 5 rounds, steal 3s",
			Damage = 3,
			RotationCooldown = 5,
			TurnPlayer = false
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function()
						return true
					end
				}
			}
		end,
		Instance = function(p, _)
			return {
				Damage = p.Damage
			}
		end,
		Execute = function(_, object, p)
			object:attack(p.CatalystId, object.TurnPlayer)
			object:addEffect(object, "TimeModifier", {
				Add = -p.Damage,
				Round = 1
			})
		end
	}
}