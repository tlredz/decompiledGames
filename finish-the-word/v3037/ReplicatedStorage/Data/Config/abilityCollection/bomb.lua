local RunService = game:GetService("RunService")
local import = _G.import("event")
local v = nil
local v2 = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z"
}

local function hasSequentialLetters(value)
	v = v or _G.import("bank")
	local word = v:normalizeWord(value or "")

	for i = 1, #word - 1 do
		local v3 = word:sub(i, i)
		local v4 = word:sub(i + 1, i + 1)
		local index = table.find(v2, v3)
		local index2 = table.find(v2, v4)

		if index and index2 then
			if math.abs(index - index2) == 1 then
				return true
			end
		else
			break
		end
	end
end

if RunService:IsClient() then
	local currentCamera = workspace.CurrentCamera
	local Debris = game:GetService("Debris")
	local TweenService = game:GetService("TweenService")
	local import2 = _G.import("animUtil")
	local import3 = _G.import("cameraUtil")
	local import4 = _G.import("clientUtil")
	local import5 = _G.import("effectUtil")
	import.remoteConnect("bombExplosion", function(list, p)
		local v5, v6 = unpack(list)
		local table2 = workspace.Meta.Tables[tostring(p)]
		local v7 = table2.MatchPets[tostring(v5)][tostring(v6)]
		local pet = v7.Pet
		local primaryPart = pet.PrimaryPart
		local petWeld = v7.PetWeld
		local top = table2.Table.Top
		local v8 = top.Position + Vector3.new(0, top.Size.Y / 2 + pet:GetExtentsSize().Y / 2, 0)
		local v9 = primaryPart.CFrame - primaryPart.Position + v8
		local objectSpace = (v7.PetAnchorWeld.Part0.CFrame * v7.PetAnchorWeld.C0):ToObjectSpace(v9)
		local cframe = CFrame.new((v9 * CFrame.new(7, 7, 7)).Position, v9.Position)
		local cframe2 = CFrame.new((v9 * CFrame.new(5.5, 5.5, 5.5)).Position, v9.Position)
		import.fire("cutscene", function()
			v7:SetAttribute("PausePetBob", true)
			petWeld.C0 = objectSpace
			currentCamera.CameraType = "Scriptable"
			currentCamera.CFrame = cframe
			import2.animate(0.2, function(p2)
				local v10 = -0.5235987755982988 * TweenService:GetValue(
					p2,
					Enum.EasingStyle.Back,
					Enum.EasingDirection.Out
				)
				petWeld.C0 = objectSpace * CFrame.Angles(0, v10, 0)
			end)
			import2.animate(0.35, function(p2)
				local v10 = -0.5235987755982988 + 19.373154697137057 * TweenService:GetValue(
					p2,
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.In
				)
				petWeld.C0 = objectSpace * CFrame.Angles(0, v10, 0)
				currentCamera.CFrame = cframe:Lerp(cframe2, p2)
			end)
			local clone = workspace.Meta.Stations.Ranked.Cannon.Main.Explosion:Clone()
			clone.CFrame = primaryPart.CFrame
			clone.Parent = workspace
			import4.sound("CannonExplosion", clone)
			import3.explosion(clone.Position, 40, 1000)
			Debris:AddItem(clone, (math.max(5, import5.emitObject(clone))))
			pet:Destroy()
			task.wait(1)
		end)
	end)
end

return {
	Explosion = {
		Info = {
			DisplayName = "Explode",
			Description = "Deal damage to all enemies",
			PetDescription = "Deal damage to all enemies"
		},
		Triggers = function(_)
			return {}
		end,
		Execute = function(_, object, p, p2)
			import.firePlayers(object:players(), "bombExplosion", p.CatalystId, object.TableModel.Name)
			task.wait(1.55)
			local v5 = {}

			for k in pairs(object:players()) do
				if k == p2.PlayerIndex then
					continue
				end

				object:takeDamage(k)

				if object.HP[k] <= 0 then
					table.insert(v5, k)
				end
			end

			local v6 = object:playerCount() - #v5 <= (object.PlayersRequired == 1 and 0 or 1)

			for _, v7 in ipairs(v5) do
				object:eliminate(v7, nil, v6)
			end

			object:addEffect(p.CatalystId, "PetDisabled", {
				Round = 1e999
			})
		end
	},
	Match = {
		Info = {
			DisplayName = "Fuse",
			Description = "Gain a match!",
			PetDescription = "Words with consecutive letters gain a stack. After 30 stacks, explode.",
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, _, _, _, _, _, _, p)
						return hasSequentialLetters(p)
					end
				}
			}
		end,
		Execute = function(_, object, _, p)
			p.Matches = (p.Matches or 0) + 1

			if p.Matches < 30 then
				return
			end

			p.Matches = 0
			object:executeAbility(p, "Explosion")
		end
	}
}