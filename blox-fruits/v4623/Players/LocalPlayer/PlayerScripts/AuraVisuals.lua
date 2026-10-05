local createVector = vector.create
local Lighting = game:GetService("Lighting")
local FX = require(game.ReplicatedStorage:WaitForChild("FX"))
local auraAssets = FX:WaitForChild("AuraAssets")

if not auraAssets then
	warn("[AuraVisuals] AuraAssets could not be loaded, aura visuals are disabled")
	return
end

local AuraifyWeapon = require(script:WaitForChild("AuraifyWeapon"))
local DescendantsCountTracker = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("DescendantsCountTracker"))
local v = {}
local v2 = {}
local characterTemplate = auraAssets:WaitForChild("CharacterTemplate")

-- equivalent calls inferred from this helper; original call sites unknown
local function invertCF(C1: CFrame)
	local components, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13 = C1:GetComponents()
	return CFrame.new(components, v3, v4, -v5, v6, v7, v8, v9, v10, v11, v12, v13)
end

local function check(instance)
	local humanoid = instance:WaitForChild("Humanoid", 3)

	if humanoid and humanoid.ClassName == "Humanoid" then
		local v3 = instance:FindFirstChild("HasBuso") ~= nil
		local value = nil

		if instance.Parent == workspace.Enemies then
			local summoner = instance:FindFirstChild("Summoner")

			if summoner then
				value = summoner.Value
			end
		else
			for _ = 1, 10 do
				value = game.Players:GetPlayerFromCharacter(instance)

				if value then
					break
				else
					task.wait()
				end
			end

			if not value then
				return
			end
		end

		v[instance] = {}

		local function enable(child, _, enchant, p)
			if child:GetAttribute("ExpectedDescendants") then
				local descendantsCountTracker = DescendantsCountTracker(child)

				while v[instance] and child:IsDescendantOf(workspace) do
					local expectedDescendants = child:GetAttribute("ExpectedDescendants")

					if not expectedDescendants or expectedDescendants <= descendantsCountTracker.count then
						break
					end

					task.wait()
				end

				descendantsCountTracker:Destroy()
			end

			local v4 = v[instance]

			if not (child:IsDescendantOf(workspace) and v4) then
				return
			end

			if not v[instance][child] then
				v[instance][child] = {
					Parts = {},
					Connections = {},
					Callback = nil,
					Recolor = nil
				}
			end

			local busoColor = value and value:FindFirstChild("BusoColor") or nil
			local value2 = busoColor and busoColor.Value or Color3.new(0, 0, 0)

			if p == false then
				value2 = nil
			end

			local v5

			if value2 then
				if math.floor(value2.R * 255 + 0.5) == 1 and math.floor(value2.G * 255 + 0.5) == 1 then
					v5 = math.floor(value2.B * 255 + 0.5) == 1
				else
					v5 = false
				end

				if v5 then
					value2 = Color3.fromHSV(math.random(), 1, 1)
				end
			else
				v5 = false
			end

			local callback, v7 = AuraifyWeapon(child, value2, enchant, child:GetAttribute("DisableBusoAura") == true)
			v[instance][child].Callback = callback
			v[instance][child].Recolor = v7

			if value2 then
				local fadeTo = busoColor and busoColor:GetAttribute("FadeTo")
				local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

				if (v5 or fadeTo) and humanoidRootPart then
					table.insert(v2, {
						i1_part = humanoidRootPart,
						i2_container = false,
						i3_invertedWeld = false,
						i4_wC0 = false,
						i5_rainbowState = true,
						i6_isHead = false,
						i7_recolor = v7,
						i8_isWeaponHighlight = true,
						i9_fade = fadeTo and ({
							fadeFrom = busoColor and busoColor.Value or Color3.new(),
							fadeTo = fadeTo
						} or nil) or nil
					})
				end
			end
		end

		local function disable(child, _)
			if not v[instance] then
				return
			end

			if value and child:IsDescendantOf(value) or instance and child:IsDescendantOf(instance) or child:IsDescendantOf(Lighting) then
				if v[instance] and v[instance][child] then
					for _, connection in pairs(v[instance][child].Connections) do
						connection:Disconnect()
					end

					v[instance][child].Connections = {}
					local callback = v[instance][child].Callback

					if callback then
						callback()
						v[instance][child].Callback = nil
					end

					v[instance][child].Recolor = nil
				end
			elseif v[instance][child] then
				for _, connection in pairs(v[instance][child].Connections) do
					connection:Disconnect()
				end

				v[instance][child] = nil
			end
		end

		local v4 = {}
		local v5 = {}
		local v6 = {}

		local function busoCheck(parent)
			if parent.Name:find("_BusoLayer1") then
				local child = instance:FindFirstChild((string.match(parent.Name, "(.*)_BusoLayer1")))

				if not child then
					return
				end

				if not v6[child] then
					v6[child] = {
						["1"] = false,
						["2"] = false
					}
				end

				local _1 = v6[child]["1"]

				if typeof(_1) == "RBXScriptConnection" then
					_1:Disconnect()
				end

				parent.Transparency = child.Transparency
				v6[child]["1"] = child:GetPropertyChangedSignal("Transparency"):Connect(function()
					parent.Transparency = child.Transparency
				end)
				local thickness = parent:GetAttribute("Thickness") or 0.05
				local sizeChangedConnection = nil

				local function updateSize(p)
					if parent.Parent then
						if p ~= "alr" then
							local sizeChanged = child:WaitForChild("SizeChanged", 5)

							if not sizeChanged then
								return
							end

							sizeChanged.Name = "Destroyed"
							task.delay(0.016666666666666666, function()
								sizeChanged:Destroy()
							end)
						end

						local manualWeld = parent:FindFirstChild("ManualWeld")

						if manualWeld then
							manualWeld.Enabled = false
						end

						parent.Size = child.Size + createVector(1, 1, 1) * thickness

						if manualWeld then
							task.wait()
							manualWeld.Enabled = true
						end

						local specialMesh = parent:FindFirstChildWhichIsA("SpecialMesh")

						if specialMesh then
							if not v5[specialMesh.MeshId] then
								v5[specialMesh.MeshId] = {}
							end

							if not v5[specialMesh.MeshId][child.Size.Y] then
								v5[specialMesh.MeshId][child.Size.Y] = specialMesh.Scale
							end

							specialMesh.Scale = v5[specialMesh.MeshId][child.Size.Y] or specialMesh.Scale
						end
					else
						if sizeChangedConnection then
							sizeChangedConnection:Disconnect()
							sizeChangedConnection = nil
						end

						parent:Destroy()
					end
				end

				if not child:GetAttribute("VisualConnection") then
					child:SetAttribute("VisualConnection", true)
					sizeChangedConnection = child:GetPropertyChangedSignal("Size"):Connect(updateSize)
				end

				task.spawn(function()
					updateSize("alr")
				end)
			elseif parent.Name:find("_BusoLayer2") then
				local part = instance:FindFirstChild((string.match(parent.Name, "(.*)_BusoLayer2")))

				if not part then
					return
				end

				if not v6[part] then
					v6[part] = {
						["1"] = false,
						["2"] = false
					}
				end

				if v6[part]["2"] then
					v6[part]["2"]:Disconnect()
				end

				parent.Transparency = part.Transparency
				v6[part]["2"] = part:GetPropertyChangedSignal("Transparency"):Connect(function()
					parent.Transparency = part.Transparency
				end)
				local thickness = parent:GetAttribute("Thickness") or 0.05
				local connections = {}

				local function updateSize(p)
					if parent.Parent then
						if p ~= "alr" then
							local sizeChanged2 = part:WaitForChild("SizeChanged2", 5)

							if not sizeChanged2 then
								return
							end

							sizeChanged2.Name = "Destroyed"
							task.delay(0.016666666666666666, function()
								sizeChanged2:Destroy()
							end)
						end

						local invertedWeld = parent:FindFirstChild("InvertedWeld")

						if invertedWeld then
							invertedWeld.Enabled = false
						end

						parent.Size = part.Size + createVector(1, 1, 1) * thickness * 1.8

						if invertedWeld then
							task.wait()
							invertedWeld.Enabled = true
						end

						local specialMesh = parent:FindFirstChildWhichIsA("SpecialMesh")

						if specialMesh then
							if not v4[specialMesh.MeshId] then
								v4[specialMesh.MeshId] = {}
							end

							if not v4[specialMesh.MeshId][part.Size.Y] then
								v4[specialMesh.MeshId][part.Size.Y] = specialMesh.Scale
							end

							specialMesh.Scale = (v4[specialMesh.MeshId][part.Size.Y] or specialMesh.Scale) + createVector(
								1,
								1,
								1
							) * thickness * 1.8
							specialMesh.TextureId = "http://www.roblox.com/asset/?id=5614579544"
							specialMesh.VertexColor = Vector3.new(
								parent.Color.R * 3,
								parent.Color.G * 3,
								parent.Color.B * 3
							) * 1.1

							if not parent:FindFirstChild("Hooked") then
								local folder = Instance.new("Folder")
								folder.Name = "Hooked"
								folder.Parent = parent
								local connections2 = {}
								table.insert(connections2, parent:GetPropertyChangedSignal("Color"):Connect(function()
									specialMesh.VertexColor = Vector3.new(
										parent.Color.R * 3,
										parent.Color.G * 3,
										parent.Color.B * 3
									) * 1.1
								end))
								parent.Parent = workspace._WorldOrigin
								table.insert(connections2, humanoid.Died:Connect(function()
									for _, connection in pairs(connections2) do
										connection:Disconnect()
									end

									connections2 = {}
									pcall(function()
										parent:Destroy()
									end)
								end))
								assert(value, "bad player")
								table.insert(connections2, value.CharacterRemoving:Connect(function()
									for _, connection in pairs(connections2) do
										connection:Disconnect()
									end

									connections2 = {}
									pcall(function()
										parent:Destroy()
									end)
								end))
							end
						end
					else
						for _, connection in pairs(connections) do
							connection:Disconnect()
						end

						connections = {}
						parent:Destroy()
					end
				end

				if not part:GetAttribute("VisualConnection") then
					part:SetAttribute("VisualConnection", true)
					table.insert(connections, part:GetPropertyChangedSignal("Size"):Connect(updateSize))
				end

				local specialMesh = parent:FindFirstChildWhichIsA("SpecialMesh")

				if specialMesh and not specialMesh:GetAttribute("VisualConnection") then
					specialMesh:SetAttribute("VisualConnection", true)
					table.insert(connections, specialMesh:GetPropertyChangedSignal("Scale"):Connect(updateSize))
				end

				task.spawn(function()
					updateSize("alr")
					local invertedWeld = parent:WaitForChild("InvertedWeld", 5)

					if invertedWeld then
						local child = characterTemplate:FindFirstChild(part.Name)
						local colored = invertedWeld.Part0 and invertedWeld.Part0:GetAttribute("Colored")
						local fadeTo = invertedWeld.Part0 and invertedWeld.Part0:GetAttribute("FadeTo")
						local part0

						if invertedWeld.Part0 and invertedWeld.Part0:GetAttribute("Rainbow") or fadeTo then
							part0 = invertedWeld.Part0
						else
							part0 = false
						end

						if part.Name == "Head" or part:IsA("MeshPart") and child and child.MeshId == part.MeshId then
							invertedWeld.C1 = invertCF(invertedWeld.C1)
							table.insert(v2, {
								i1_part = part,
								i2_container = parent,
								i3_invertedWeld = invertedWeld,
								i4_wC0 = invertedWeld.C0,
								i5_rainbowState = true,
								i6_isHead = false,
								i7_recolor = part0,
								i8_isWeaponHighlight = nil,
								i9_fade = fadeTo and {
									fadeFrom = colored,
									fadeTo = fadeTo
								} or nil
							})
						else
							table.insert(v2, {
								i1_part = part,
								i2_container = parent,
								i3_invertedWeld = invertedWeld,
								i4_wC0 = invertedWeld.C0,
								i5_rainbowState = true,
								i6_isHead = true,
								i7_recolor = part0,
								i8_isWeaponHighlight = nil,
								i9_fade = fadeTo and {
									fadeFrom = colored,
									fadeTo = fadeTo
								} or nil
							})
						end
					end
				end)
			end
		end

		local connections = {}
		table.insert(connections, instance.ChildAdded:Connect(function(child)
			if child.Name == "HasBuso" then
				v3 = true

				for _, child2 in pairs(instance:GetChildren()) do
					local CollectionService = game:GetService("CollectionService")

					if not CollectionService:HasTag(child2, "Weapon") then
						continue
					end

					disable(child2, false)
					enable(child2, nil, child2:GetAttribute("Enchant"), true)
				end
			else
				local CollectionService = game:GetService("CollectionService")

				if CollectionService:HasTag(child, "Weapon") then
					local v7 = false

					for _ = 1, 8 do
						if #child:GetChildren() == 0 then
							local RunService = game:GetService("RunService")
							RunService.RenderStepped:Wait()
						else
							v7 = true
							break
						end
					end

					if v7 and child.Parent == instance then
						if v3 then
							disable(child, true)
							enable(child, true, child:GetAttribute("Enchant"), true)
						else
							disable(child, true)

							if child:GetAttribute("Enchant") then
								enable(child, true, child:GetAttribute("Enchant"), false)
							end
						end
					end
				else
					busoCheck(child)
				end
			end
		end))
		local humanoid2 = instance:FindFirstChild("Humanoid")
		table.insert(connections, humanoid2.ChildAdded:Connect(function(child)
			busoCheck(child)
		end))

		local function clear()
			for _, connection in pairs(connections) do
				connection:Disconnect()
			end

			connections = nil

			for k in pairs(v6) do
				local connection = v6[k][tostring(1)]

				if connection then
					connection:Disconnect()
				end

				local connection2 = v6[k][tostring(2)]

				if connection2 then
					connection2:Disconnect()
				end
			end

			v6 = nil
		end

		local humanoid3 = instance:FindFirstChild("Humanoid")
		table.insert(connections, humanoid3.Died:Connect(function()
			clear()

			for _, child in pairs(humanoid3:GetChildren()) do
				if child.Name:find("_BusoLayer") then
					child:Destroy()
				end
			end
		end))
		table.insert(connections, instance.Destroying:Connect(function()
			clear()

			if instance:FindFirstChild("Humanoid") then
				for _, child in pairs(humanoid3:GetChildren()) do
					if child.Name:find("_BusoLayer") then
						child:Destroy()
					end
				end
			end
		end))
		table.insert(connections, instance.ChildRemoved:Connect(function(child)
			if child.Name == "HasBuso" then
				v3 = false

				for _, child2 in pairs(instance:GetChildren()) do
					local CollectionService = game:GetService("CollectionService")

					if not CollectionService:HasTag(child2, "Weapon") then
						continue
					end

					disable(child2, true)

					if child2:GetAttribute("Enchant") then
						enable(child2, false, child2:GetAttribute("Enchant"), false)
					end
				end
			else
				local CollectionService = game:GetService("CollectionService")

				if CollectionService:HasTag(child, "Weapon") then
					disable(child, true)
				end
			end
		end))

		for _, child in pairs(instance:GetChildren()) do
			local CollectionService = game:GetService("CollectionService")

			if not (CollectionService:HasTag(child, "Weapon") and (v3 or child:GetAttribute("Enchant"))) then
				continue
			end

			disable(child, true)
			enable(child, true, child:GetAttribute("Enchant"), v3)
		end

		local humanoid4 = instance:FindFirstChild("Humanoid")

		for _, child in pairs(humanoid4:GetChildren()) do
			busoCheck(child)
		end
	end
end

workspace:WaitForChild("Characters")
workspace:WaitForChild("Enemies")
workspace.Enemies.ChildAdded:Connect(function(child)
	check(child)
end)
workspace.Characters.ChildAdded:Connect(function(child)
	check(child)
end)
workspace.Characters.ChildRemoved:Connect(function(child)
	v[child] = nil
end)
workspace.Enemies.ChildRemoved:Connect(function(child)
	v[child] = nil
end)

for _, child in pairs(workspace.Characters:GetChildren()) do
	local v3 = child
	task.spawn(function()
		check(v3)
	end)
end

for _, child in pairs(workspace.Enemies:GetChildren()) do
	local v3 = child
	task.spawn(function()
		check(v3)
	end)
end

local RunService = game:GetService("RunService")
RunService.Stepped:Connect(function()
	local now = tick()
	local v3 = now * 0.06 % 1
	local v4 = math.sin(now * 0.15 % 1 * 3.141592653589793 * 2) * 0.5 + 0.5
	local color = Color3.fromHSV(v3, 1, 1)
	local lookVector = workspace.CurrentCamera.CFrame.LookVector

	for k, v5 in pairs(v2) do
		local i1_part = v5.i1_part
		local i2_container = v5.i2_container
		local i3_invertedWeld = v5.i3_invertedWeld
		local i4_wC0 = v5.i4_wC0
		local i7_recolor = v5.i7_recolor
		local i9_fade = v5.i9_fade
		local color2

		if i9_fade then
			color2 = i9_fade.fadeFrom:Lerp(i9_fade.fadeTo, v4)
		else
			color2 = color
		end

		local v7

		if v5.i8_isWeaponHighlight then
			assert(typeof(i7_recolor) == "Instance", "bad rain")
			v7 = i7_recolor:IsDescendantOf(workspace)
		else
			v7 = i1_part:IsDescendantOf(workspace)
		end

		if v7 then
			if v5.i5_rainbowState then
				if v5.i6_isHead then
					local objectSpace = (i1_part.CFrame + lookVector * 0.075):ToObjectSpace(i1_part.CFrame)
					assert(typeof(i3_invertedWeld) == "Instance", "bad w")
					assert(typeof(i4_wC0) == "CFrame", "bad og")
					i3_invertedWeld.C0 = i4_wC0 * objectSpace
				end

				if i7_recolor and v5.i5_rainbowState == 2 then
					v5.i5_rainbowState = 1

					if v5.i8_isWeaponHighlight then
						i7_recolor.Value = color2
					else
						i7_recolor.Color = color2
					end
				end
			end
		else
			if typeof(i2_container) == "Instance" then
				local i2_container2 = i2_container
				pcall(function()
					i2_container2:Destroy()
				end)
			end

			v2[k] = nil
		end
	end
end)

while task.wait(0.3) do
	local position = workspace.CurrentCamera.CFrame.Position

	for _, v3 in pairs(v2) do
		local v4 = not v3.i1_part and 1e999 or (v3.i1_part.Position - position).Magnitude or 1e999

		if v4 < 1000 then
			if v4 < 150 then
				v3.i5_rainbowState = 2
			else
				v3.i5_rainbowState = 1
			end
		else
			v3.i5_rainbowState = false
		end
	end
end