local IdMap = require(game.ReplicatedStorage.IdMap)
require(game.ReplicatedStorage.ItemConfig)

function showByName(instance, childName: string, flag: boolean)
	local instance2 = instance:FindFirstChild(childName)

	if instance2 then
		if instance2:IsA("BasePart") then
			instance2.Transparency = flag and 0 or 1
		elseif instance2:IsA("Decal") then
			instance2.Transparency = flag and 0 or 1
		elseif instance2:IsA("Texture") then
			instance2.Transparency = flag and 0 or 1
		end
	else
		warn(childName, "not found in rig", instance)
	end
end

local v = {
	[IdMap.Equipment.EastDragBodyArmor] = {
		BodyArmor = function(p, flag: boolean)
			for _, v2 in { "low poly.005", "low poly.030" } do
				showByName(p, v2, flag)
			end
		end
	},
	[IdMap.Equipment.EastDragCrown] = {
		Crown = function(p, flag: boolean)
			for _, v2 in { "low poly.004" } do
				showByName(p, v2, flag)
			end
		end
	},
	[IdMap.Equipment.EastDragSaddle] = {
		Seats = function(instance, flag: boolean)
			local cube001 = not flag and instance:FindFirstChild("Cube.001")

			if cube001 then
				for _, attachment in pairs(cube001:GetChildren()) do
					if not (attachment:IsA("Attachment") and attachment.Name:sub(1, 4):lower() == "seat") then
						continue
					end

					attachment:Destroy()
				end
			end
		end
	},
	[IdMap.Equipment.WestDragBodyArmor] = {
		BodyArmor = function(p, flag: boolean)
			for _, v2 in { "Armour.006", "Armour.007", "Neon.001" } do
				showByName(p, v2, flag)
			end
		end
	},
	[IdMap.Equipment.WestDragHeadArmor] = {
		Helmet = function(p, flag: boolean)
			for _, v2 in {
				"Armour.005",
				"Plane.001",
				"Cube.003",
				"Eyebrows"
			} do
				showByName(p, v2, flag)
			end
		end
	},
	[IdMap.Equipment.WestDragSaddle] = {
		Seats = function(instance, flag: boolean)
			for _, v2 in { "Spine Spikes (dont join them).002" } do
				showByName(instance, v2, not flag)
			end

			local saddel = instance:FindFirstChild("Saddel")

			if saddel and not flag then
				saddel:Destroy()
			end
		end
	}
}
return {
	setEquip = function(p: number, p2, flag: boolean)
		local v2 = v[p]

		if v2 then
			for _, v3 in v2 do
				v3(p2, flag)
			end
		end
	end
}