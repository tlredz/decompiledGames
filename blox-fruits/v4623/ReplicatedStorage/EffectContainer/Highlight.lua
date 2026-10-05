local createVector = vector.create
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local function checkAncestor(parent, className, p)
	local v

	repeat
		parent = parent.Parent
		v = parent:IsA(className)
	until not v or parent == p or parent == workspace

	return v and parent
end

local v = {}
local v2 = { "arm", "hand" }
local v3 = { "leg", "foot" }

local function collectMeshes(folder)
	local parts = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	return parts
end

local function collectByNames(folder, list)
	local parts = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local name = part.Name:lower()

		for _, v5 in ipairs(list) do
			if not name:find(v5, 1, true) then
				continue
			end

			table.insert(parts, part)
			break
		end
	end

	return parts
end

local function gatherTypeParts(model, type)
	if type == "Weapon" then
		local equippedWeapon = model:FindFirstChild("EquippedWeapon")
		return equippedWeapon and collectMeshes(equippedWeapon) or {}
	elseif type == "None" then
		return (collectByNames(model, v2))
	elseif type == "Leg" then
		return (collectByNames(model, v3))
	end

	return nil
end

return function(data)
	local model = data.Model
	local color = data.Color or Color3.new(1, 0, 0)
	local duration = data.Duration or 0.25
	local transparency = data.Transparency or 0.3
	local mode = data.Mode or Enum.EasingStyle.Linear
	local fadeIn = data.FadeIn or false
	local freezeDuration = data.FreezeDuration or false
	local allowTrails = data.AllowTrails
	local allowTools = data.AllowTools
	local allowArmor = data.AllowArmor
	local destroy = data.Destroy
	local UID = data.UID
	local parts = data.Parts
	local partNames = data.PartNames
	local type = data.Type
	local flash = data.Flash
	local flashColor = data.FlashColor or Color3.new(1, 1, 1)
	local flashSpeed = data.FlashSpeed or 12
	local v4 = false
	local v5 = false

	local function connect(tween, instance, p)
		if not v5 then
			local completedConnection = nil
			v4 = true

			if not p then
				v5 = true
				completedConnection = tween.Completed:Connect(function()
					v[UID] = nil
					v4 = false
					instance:BreakJoints()
					instance:Destroy()
				end)
			end

			v[UID] = {
				Stop = function()
					v[UID] = nil
					v4 = false

					if completedConnection then
						completedConnection:Disconnect()
					end

					tween:Cancel()
				end,
				UID = UID,
				Model = model
			}
		end
	end

	if destroy then
		local v6 = v[UID]

		if v6 then
			v6.Stop()
			local highlight = v6.Model:FindFirstChild("Highlight")

			if highlight then
				highlight:BreakJoints()
				highlight:Destroy()
			end
		end
	else
		local v6 = false

		for _, v8 in pairs(v) do
			if v8.Model ~= model then
				continue
			end

			v6 = v8
			break
		end

		if v6 then
			local highlight = v6.Model:FindFirstChild("Highlight")

			if not highlight then
				v[v6.UID] = nil
			elseif highlight then
				v6.Stop()
				v6.UID = UID
				v[v6.UID] = v6
				model = v6.Model

				for _, child in pairs(highlight:GetChildren()) do
					if child:IsA("BasePart") then
						child.Color = color
						child.Transparency = transparency
						local tween = TweenService:Create(child, TweenInfo.new(duration, mode), {
							Transparency = 1
						})
						connect(tween, highlight)
						tween:Play()
					elseif child:IsA("Trail") then
						child.Transparency = NumberSequence.new(transparency)
						child.Color = ColorSequence.new(color)
					elseif child.Name == "Proxy" then
						local tween = TweenService:Create(child, TweenInfo.new(duration, mode), {
							Value = 1
						})
						connect(tween, highlight)
						tween:Play()
					end
				end
			end
		elseif model then
			if (model:GetModelCFrame().p - workspace.CurrentCamera.CFrame.p).Magnitude > 125 + 10 * model:GetModelSize().Magnitude then
				return
			end

			for k, v8 in pairs(v) do
				if not (v8.Model == nil or v8.Model.Parent == nil) then
					continue
				end

				local v9 = v8
				pcall(function()
					v9.Model.Highlight:BreakJoints()
					v9.Model.Highlight:Destroy()
				end)
				v[k] = nil
			end

			local model2 = Instance.new("Model", model)
			model2.Name = "Highlight"
			local connections = {}
			table.insert(connections, model.ChildRemoved:Connect(function(child)
				if child == model2 then
					for _, connection in pairs(connections) do
						connection:Disconnect()
					end
				end
			end))
			local v8 = CollectionService:HasTag(model, "Tool") or CollectionService:HasTag(model, "Appearance")
			local clone = type and gatherTypeParts(model, type)

			if not clone then
				if parts then
					clone = table.clone(parts)
				elseif partNames then
					clone = {}

					for _, part in pairs(model:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						local name = part.Name:lower()

						for _, partName in ipairs(partNames) do
							if not name:find(partName:lower(), 1, true) then
								continue
							end

							table.insert(clone, part)
							break
						end
					end
				else
					clone = v8 and model:GetDescendants() or model:GetChildren()
				end
			end

			if allowTrails then
				for _, trail in pairs(model:GetDescendants()) do
					if not trail:IsA("Trail") or trail.Name:find("_Highlight") then
						continue
					end

					table.insert(clone, trail)
				end
			elseif not v8 then
				for _, folder in pairs(model:GetChildren()) do
					if not (allowTools and CollectionService:HasTag(folder, "Tool") or allowArmor and CollectionService:HasTag(
						folder,
						"Appearance"
					)) then
						continue
					end

					for _, descendant in pairs(folder:GetDescendants()) do
						if not folder.Name:find("_Highlight") then
							table.insert(clone, descendant)
						end
					end
				end
			end

			local count = 0

			for _, instance in pairs(clone) do
				if instance:IsA("BasePart") and instance.Transparency < 1 and instance.Name ~= "HumanoidRootPart" then
					count += 1
					local clone2 = instance:Clone()

					for _, dataModelMesh in pairs(clone2:GetDescendants()) do
						if dataModelMesh:IsA("DataModelMesh") and dataModelMesh.MeshType == Enum.MeshType.Head then
							clone2:Destroy()
							clone2 = script.HeadMesh:Clone()
							clone2.CFrame = instance.CFrame
							clone2.Size = createVector(1.25, 1.25, 1.25) * instance.Size.Y
						elseif not dataModelMesh:IsA("DataModelMesh") then
							dataModelMesh:Destroy()
						end
					end

					clone2.Name ..= "_Highlight"
					clone2.CastShadow = false
					clone2.Color = color
					clone2.CanCollide = false
					clone2.Massless = true
					clone2.Transparency = fadeIn and 1 or transparency
					clone2.Size += createVector(0.001, 0.001, 0.001)
					clone2.TopSurface = 0
					clone2.BottomSurface = 0
					clone2.Material = "Neon"

					if clone2:IsA("UnionOperation") then
						clone2.UsePartColor = true
					end

					if fadeIn then
						local tween = TweenService:Create(clone2, TweenInfo.new(fadeIn), {
							Transparency = transparency
						})
						tween.Completed:Connect(function()
							if not v4 then
								return
							end

							local function onCompleted()
								if not v4 then
									return
								end

								local tween2 = TweenService:Create(
									clone2,
									TweenInfo.new(duration, mode, Enum.EasingDirection.In),
									{
										Transparency = 1
									}
								)
								connect(tween2, model2)
								tween2:Play()
							end

							if not freezeDuration then
								onCompleted()
								return
							end

							local tween2 = TweenService:Create(clone2, TweenInfo.new(freezeDuration), {})
							tween2.Completed:Connect(onCompleted)

							if not v5 then
								local connection = nil
								v4 = true
								v[UID] = {
									Stop = function()
										v[UID] = nil
										v4 = false

										if connection then
											connection:Disconnect()
										end

										tween2:Cancel()
									end,
									UID = UID,
									Model = model
								}
							end

							tween2:Play()
						end)

						if not v5 then
							local connection = nil
							v4 = true
							local v9 = tween
							v[UID] = {
								Stop = function()
									v[UID] = nil
									v4 = false

									if connection then
										connection:Disconnect()
									end

									v9:Cancel()
								end,
								UID = UID,
								Model = model
							}
						end

						tween:Play()
					else
						local tween = TweenService:Create(
							clone2,
							TweenInfo.new(duration, mode, Enum.EasingDirection.In),
							{
								Transparency = 1
							}
						)
						connect(tween, model2)
						tween:Play()
					end

					local weld = Instance.new("Weld")
					weld.Part0 = clone2
					weld.Part1 = instance
					weld.C0 = clone2.CFrame:ToObjectSpace(instance.CFrame)
					weld.Parent = clone2
					clone2.Parent = model2
				elseif (allowTrails or allowTools) and instance:IsA("Trail") then
					count += 1
					local _ = instance.Color
					local clone2 = instance:Clone()
					clone2.Transparency = fadeIn and NumberSequence.new(1) or NumberSequence.new(transparency)
					clone2.Name ..= "_Highlight"
					clone2.Color = ColorSequence.new(color)
					clone2.Parent = model2
					local v10 = instance
					table.insert(connections, instance.Changed:Connect(function()
						clone2.Enabled = v10.Enabled
					end))
					local numberValue = Instance.new("NumberValue")
					numberValue.Name = "Proxy"
					numberValue.Value = fadeIn and 1 or transparency
					numberValue.Parent = model2
					local v11 = clone2
					numberValue.Changed:Connect(function()
						v11.Transparency = NumberSequence.new(numberValue.Value * 0.75)
					end)

					if fadeIn then
						local tween = TweenService:Create(numberValue, TweenInfo.new(fadeIn), {
							Value = transparency
						})
						local v13 = numberValue
						tween.Completed:Connect(function()
							if not v4 then
								return
							end

							local function onCompleted()
								if not v4 then
									return
								end

								local tween2 = TweenService:Create(
									v13,
									TweenInfo.new(duration, mode, Enum.EasingDirection.In),
									{
										Value = 1
									}
								)
								connect(tween2, model2)
								tween2:Play()
							end

							if not freezeDuration then
								onCompleted()
								return
							end

							local tween2 = TweenService:Create(v13, TweenInfo.new(freezeDuration), {})
							tween2.Completed:Connect(onCompleted)

							if not v5 then
								local connection = nil
								v4 = true
								v[UID] = {
									Stop = function()
										v[UID] = nil
										v4 = false

										if connection then
											connection:Disconnect()
										end

										tween2:Cancel()
									end,
									UID = UID,
									Model = model
								}
							end

							tween2:Play()
						end)

						if not v5 then
							local connection = nil
							v4 = true
							local v14 = tween
							v[UID] = {
								Stop = function()
									v[UID] = nil
									v4 = false

									if connection then
										connection:Disconnect()
									end

									v14:Cancel()
								end,
								UID = UID,
								Model = model
							}
						end

						tween:Play()
					else
						local tween = TweenService:Create(
							numberValue,
							TweenInfo.new(duration, mode, Enum.EasingDirection.In),
							{
								Value = 1
							}
						)
						connect(tween, model2)
						tween:Play()
					end
				end
			end

			if count == 0 then
				model2:Destroy()
			elseif flash then
				task.spawn(function()
					local lastTime = os.clock()

					while model2.Parent do
						local lerped = color:Lerp(
							flashColor,
							math.sin((os.clock() - lastTime) * flashSpeed) * 0.5 + 0.5
						)

						for _, child in ipairs(model2:GetChildren()) do
							if child:IsA("BasePart") then
								child.Color = lerped
							elseif child:IsA("Trail") then
								child.Color = ColorSequence.new(lerped)
							end
						end

						task.wait()
					end
				end)
			end
		end
	end
end