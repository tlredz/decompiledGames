-- failed to load script (decompiled with syntax error):
-- rMaJBVYPyVJPVVgvfshKNoLGb:107: Expected identifier when parsing expression, got ';'

local TransformationAccessories = {
	isAccessoryModel = function(model, instance)
		if not model:IsA("Model") or model:GetAttribute("Owner") ~= instance.Name then
			return false
		end

		for _, accessory in instance:GetChildren() do
			if accessory:IsA("Accessory") and accessory.Name == model.Name then
				return true
			end
		end

		return false
	end
}

function TransformationAccessories.attach(instance, p, p2)
	local folder = Instance.new("Folder")
	folder.Name = "AccessoriesFolder"
	folder.Parent = p.Parent
	local v = {}
	local connections = {}

	local function copyAccessory(accessory)
		if v[accessory] or accessory == p.Parent then
			return
		end

		local accessoryModel = TransformationAccessories.isAccessoryModel(accessory, instance)

		if not (accessory:IsA("Accessory") or accessoryModel) then
			return
		end

		local clone = accessory:Clone()
		local v2 = false

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("LuaSourceContainer") then
				descendant:Destroy()
			elseif descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
				for _, v3 in { "Part0", "Part1" } do
					local v4 = descendant[v3]

					if not (v4 and v4.Parent == instance) then
						continue
					end

					if v4.Name == "Head" then
						descendant[v3] = p
						v2 = true
					else
						clone:Destroy()
						return
					end
				end
			elseif descendant:IsA("BasePart") then
				descendant:SetAttribute("TigerAccessory", true)
				descendant.Anchored = false
				descendant.Massless = true
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = false
			end
		end

		if not v2 then
			clone:Destroy()
			return
		end

		if accessoryModel then
			local child = game.ServerStorage.Models:FindFirstChild(accessory.Name)

			if child then
				for _, part in clone:GetDescendants() do
					if not part:IsA("BasePart") then
						continue
					end

					local part2 = child:FindFirstChild(part.Name, true)

					if part2 and part2:IsA("BasePart") then
						part.Transparency = part2.Transparency
					end
				end
			end
		end

		v[accessory] = clone
		clone.Parent = folder

		for _, part in clone:GetDescendants() do
			if part:IsA("BasePart") then
				part:SetNetworkOwner(p2)
			end
		end

		local animationController = clone:FindFirstChildOfClass("AnimationController")
		local idle = clone:FindFirstChild("Idle")

		if animationController and idle and idle:IsA("Animation") then
			;(animationController:FindFirstChildOfClass("Animator") or Instance.new("Animator", animationController)):LoadAnimation(idle):Play()
		end

		table.insert(connections, accessory.Destroying:Connect(function()
			clone:Destroy()
			v[accessory] = nil
		end))
	end

	table.insert(connections, instance.ChildAdded:Connect(copyAccessory))

	for _, child in instance:GetChildren() do
		copyAccessory(child)
	end

	folder.Destroying:Once(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

return TransformationAccessories