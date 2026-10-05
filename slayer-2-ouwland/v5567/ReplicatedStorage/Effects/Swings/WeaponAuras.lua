local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Combat_Swings = require(script.Parent:WaitForChild("Combat_Swings"))
local v = { "Sword_At_A", "Sword_At_C", "Sword_At_D" }
local find = table.find
return function(instance, p: number?, flag: boolean?, data)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 100 then
		return
	end

	local weaponAura = instance:FindFirstChild("WeaponAura", true) or instance:FindFirstChild("Has_Blade", true)

	if weaponAura == nil then
		if data ~= nil and data.skipSound ~= true then
			Combat_Swings(instance, p, flag)
		end
	else
		local effects = script:FindFirstChild("Effects")

		if effects == nil then
			return
		end

		local v2 = (weaponAura.ClassName ~= "StringValue" or effects:FindFirstChild(weaponAura.Value) == nil) and "Default" or weaponAura.Value
		local child = effects:FindFirstChild(v2)

		if child == nil then
			return
		end

		local v3

		if data == nil then
			v3 = false
		else
			v3 = data.skipTrails == true
		end

		local v4

		if data == nil then
			v4 = false
		else
			v4 = data.skipParticles == true
		end

		local v5 = {}

		if data == nil then
			local blade = weaponAura.Parent:FindFirstChild("Blade")

			if blade == nil then
				return
			end

			if blade:FindFirstChild("Sword_At_A") ~= nil then
				table.insert(v5, blade)
			end
		else
			for _, v6 in instance:QueryDescendants("BasePart") do
				if data.anchorParts[v6.Name] == true and v6:FindFirstChild("Sword_At_A", true) ~= nil then
					table.insert(v5, v6)
				end
			end
		end

		for _, parent in v5 do
			local children = {}

			for _, childName in v do
				local child2 = parent:FindFirstChild(childName, true)

				if child2 ~= nil then
					table.insert(children, child2)
				end
			end

			local slash_Color = parent:GetAttribute("Slash_Color")
			local clone = child:Clone()

			for _, child2 in clone:GetChildren() do
				if child2:IsA("BasePart") or child2:IsA("Folder") then
					child2:Destroy()
				elseif child2:IsA("Trail") and v3 then
					child2:Destroy()
				elseif v4 and not child2:IsA("Trail") then
					child2:Destroy()
				end
			end

			local descendants = {}
			local v7 = {}

			for _, descendant in clone:GetDescendants() do
				if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("PointLight")) then
					continue
				end

				table.insert(descendants, descendant)
			end

			for _, attachment in clone:GetChildren() do
				if attachment.ClassName == "Trail" then
					local v8 = string.split(attachment.Name, ",")

					for _, attachment2 in children do
						if find(v8, attachment2.Name) == nil then
							continue
						end

						if v8[1] == attachment2.Name then
							attachment.Attachment0 = attachment2
						else
							attachment.Attachment1 = attachment2
						end
					end

					if slash_Color ~= nil then
						attachment.Color = ColorSequence.new(slash_Color)
					end
				elseif attachment:IsA("Attachment") then
					local anchor = attachment:GetAttribute("Anchor")

					if anchor ~= nil then
						local bone = parent:FindFirstChild(tostring(anchor), true)

						if bone == nil or not bone:IsA("Bone") then
							if bone ~= nil then
								attachment.Position = parent.CFrame:ToObjectSpace(bone.WorldCFrame).Position
							end
						else
							attachment.Parent = bone
							v7[attachment] = true
						end
					end
				end

				if not v7[attachment] then
					attachment.Parent = parent
				end

				DebrisModule:AddItem(attachment, 0.8)
			end

			clone:Destroy()

			for _, v8 in descendants do
				v8.Enabled = true
			end

			task.delay(0.3, function()
				for k, v9 in descendants do
					v9.Enabled = false
				end
			end)
		end

		if data ~= nil and data.skipSound then
			return
		end

		local sounds = script:FindFirstChild("Sounds")

		if sounds == nil then
			return
		end

		local fallbackSound

		if data ~= nil then
			fallbackSound = data.fallbackSound or nil
		end

		if sounds:FindFirstChild(v2) == nil or not v2 then
			v2 = (fallbackSound == nil or sounds:FindFirstChild(fallbackSound) == nil or not fallbackSound) and "SwingSharp" or fallbackSound
		end

		local folder = sounds:FindFirstChild(v2)

		if folder == nil then
			return
		end

		if folder:IsA("Folder") then
			local children = folder:GetChildren()
			folder = children[math.random(1, #children)]
		end

		local clone = folder:Clone()
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, 1)
	end
end