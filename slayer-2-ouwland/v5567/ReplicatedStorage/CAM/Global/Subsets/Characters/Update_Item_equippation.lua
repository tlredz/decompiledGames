local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local Items = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Collectibles"):WaitForChild("Items"))
local ItemModels = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Collectibles"):WaitForChild("ItemModels"))
local Series = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Series"))
local Resolve = require(game.ReplicatedStorage.CAM.Global.Powers.Resolve)

function handleWeld(instance, instance2, parent)
	if instance2:FindFirstChild("WeldTo") and instance:FindFirstChild(instance2.WeldTo.Value) then
		local clone = instance2:Clone()
		local motor6D = clone:FindFirstChildOfClass("Motor6D") or clone:FindFirstChildOfClass("Weld")

		if motor6D == nil then
			clone:Destroy()
		else
			motor6D.Part0 = instance:FindFirstChild(clone.WeldTo.Value)
			local bodyColors = instance:FindFirstChildOfClass("BodyColors")

			if bodyColors then
				for _, v in clone:QueryDescendants("BasePart[$Color=bc],SurfaceAppearance[$Color=bc]") do
					v.Color = bodyColors.TorsoColor3
				end
			end

			clone.Parent = parent
		end
	end
end

local function bare(p, instance)
	if Series.SetOf(p.Name) == nil or Series.TierOf(p) >= Series.VfxTier then
		return
	end

	for _, folder in instance:GetChildren() do
		if folder:GetAttribute("_ClanAccessory") == true then
			continue
		end

		local chain = folder:FindFirstChild("Chain")

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Light") then
				if descendant.Parent ~= chain then
					descendant.Enabled = false
				end
			elseif descendant.Name == "Has_Blade" and descendant:IsA("StringValue") then
				descendant.Value = "Default"
			end
		end
	end
end

return function(parent)
	if parent == nil then
		return
	end

	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil and humanoid.Health <= 0 or game.ReplicatedStorage:FindFirstChild("ItemAssets") == nil then
		return
	end

	local name = ""
	local v = nil
	local v2 = nil
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(parent)

	if playerFromCharacter then
		local child = game.ReplicatedStorage.Player_Service.Data:FindFirstChild(playerFromCharacter.Name)
		local child2 = child.slots:FindFirstChild("Slot" .. child.slotEquipped.Value)
		local get_equipped_tool = Character_info_provider.Get_equipped_tool(playerFromCharacter)

		if get_equipped_tool ~= nil then
			name = get_equipped_tool.Name
			v = get_equipped_tool
		end

		if name ~= nil then
			local equippedPowers = Character_info_provider.GetEquippedPowers(playerFromCharacter)
			local item = Items[name]

			if item ~= nil then
				local v3 = item.Breathing and "Breathing" or item.DemonArt and "DemonArt" or nil

				if v3 ~= nil and Resolve.LaneCarries(item[v3], child2.Powers[v3].Value) then
					local value = child2.Powers:FindFirstChild(v3).Value

					if value ~= nil and table.find(equippedPowers, value) ~= nil then
						local v4 = name .. "-" .. value

						if ItemModels.FindTool(v4) == nil then
							if name ~= "Combat" then
								v2 = ItemModels.FindTool("Combat-" .. value)
							end
						else
							name = v4
						end
					end
				end
			end
		end

		local v3 = ""
		local parent2 = parent:FindFirstChild("Weapon_Unequipped_Config")

		if parent2 == nil then
			parent2 = Instance.new("Configuration")
			parent2.Name = "Weapon_Unequipped_Config"
			parent2.Parent = parent
		end

		for _, child3 in child2.Inventory.Toolbar:GetChildren(), nil, nil do
			local value = child3.Value
			local item = Character_info_provider.GetItemFromId(playerFromCharacter, value)

			if not (item and item ~= get_equipped_tool) then
				continue
			end

			local tool = ItemModels.FindTool(item.Name)

			if tool == nil then
				continue
			end

			local name2 = item.Name .. "UnEquipped"

			if not (string.find(v3, name2) == nil and tool:FindFirstChild("UnEquipped")) then
				continue
			end

			if #v3 > 0 then
				v3 ..= "," .. name2
			else
				v3 ..= name2
			end

			local child4 = parent2:FindFirstChild(name2)

			if child4 ~= nil and child4:GetAttribute("Tier") ~= Series.TierOf(item) then
				child4:Destroy()
				child4 = nil
			end

			if child4 ~= nil then
				continue
			end

			local clone = tool.UnEquipped:Clone()

			if not clone then
				continue
			end

			clone.Name = name2
			clone:SetAttribute("Tier", Series.TierOf(item))

			for _, child5 in clone:GetChildren(), nil, nil do
				if not (child5:FindFirstChild("WeldTo") and parent:FindFirstChild(child5.WeldTo.Value)) then
					continue
				end

				local motor6D = child5:FindFirstChildOfClass("Motor6D") or child5:FindFirstChildOfClass("Weld")

				if motor6D ~= nil then
					motor6D.Part0 = parent:FindFirstChild(child5.WeldTo.Value)
				end
			end

			bare(item, clone)
			clone.Parent = parent2
		end

		for _, child3 in parent2:GetChildren(), nil, nil do
			if string.find(v3, child3.Name) == nil then
				child3:Destroy()
			end
		end
	end

	local tool = ItemModels.FindTool(name)

	if tool then
		if parent:FindFirstChild("Tool_Accessories") == nil then
			local folder = Instance.new("Folder")
			folder.Name = "Tool_Accessories"
			folder.Parent = parent
		end

		local tool_Accessories = parent.Tool_Accessories
		local value = tool_Accessories:GetAttribute("Value")
		local v3 = tool.Name .. "Equipped" .. (v2 == nil and "" or "+" .. v2.Name)

		if value ~= v3 then
			for _, child in ipairs(tool_Accessories:GetChildren()) do
				if child:GetAttribute("_ClanAccessory") ~= true then
					child:Destroy()
				end
			end

			tool_Accessories:SetAttribute("Value", v3)
			local equipped = tool:FindFirstChild("Equipped") or tool

			if equipped then
				if tool == equipped then
					handleWeld(parent, equipped, tool_Accessories)
				else
					for _, child in ipairs(equipped:GetChildren()) do
						handleWeld(parent, child, tool_Accessories)
					end
				end
			end

			local equipped2

			if v2 ~= nil then
				equipped2 = v2:FindFirstChild("Equipped") or nil
			end

			if equipped2 ~= nil then
				for _, child in ipairs(equipped2:GetChildren()) do
					handleWeld(parent, child, tool_Accessories)
				end
			end

			if v ~= nil then
				bare(v, tool_Accessories)
			end
		end
	else
		local tool_Accessories = parent:FindFirstChild("Tool_Accessories")

		if tool_Accessories then
			tool_Accessories:SetAttribute("Value", nil)

			for _, child in ipairs(tool_Accessories:GetChildren()) do
				if child:GetAttribute("_ClanAccessory") ~= true then
					child:Destroy()
				end
			end
		end
	end
end