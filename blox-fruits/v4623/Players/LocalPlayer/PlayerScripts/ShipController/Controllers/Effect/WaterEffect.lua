local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local misc = Util.Misc
local effect = script:FindFirstChild("Effect")

local function join(part, p)
	p.Massless = true
	local weld = Instance.new("Weld")
	weld.Part0 = part
	weld.Part1 = p
	weld.C0 = part.CFrame:ToObjectSpace(p.CFrame)
	weld.Parent = p
	return weld
end

return function(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChildOfClass("VehicleSeat")
	local clone = effect:Clone()
	local frontOffset = instance:GetAttribute("FrontOffset") or Vector3.new()
	local backOffset = instance:GetAttribute("BackOffset") or Vector3.new()
	local modelSize = instance:GetModelSize()
	local modelCFrame = instance:GetModelCFrame()
	local _, v = misc.GetSurfaceNormal(modelCFrame, modelCFrame:VectorToWorldSpace(createVector(1, 0, 0)))
	local _, v2 = misc.GetSurfaceNormal(modelCFrame, modelCFrame:VectorToWorldSpace(createVector(0, 1, 0)))
	local _, v3 = misc.GetSurfaceNormal(modelCFrame, modelCFrame:VectorToWorldSpace(createVector(-0, -0, -1)))
	local v4 = modelSize[v[1][3]]
	local v5 = modelSize[v2[1][3]]
	local v6 = modelSize[v3[1][3]]
	local v7 = v4 / 8.7
	local v8 = v5 / 15
	local v9 = v6 / 19.5
	local v10 = math.min((v7 + v8 + v9) / 3, v7)
	local v11 = {
		Back = {
			Left = {},
			Right = {}
		},
		Front = {
			Left = {},
			Right = {}
		}
	}
	local v12 = {
		Back = {},
		Front = {}
	}

	for _, child in pairs(clone:GetChildren()) do
		local v13 = child.Name == "Front" and 1 or -1
		local v14 = child.Name == "Back" and backOffset or frontOffset

		for _, folder in pairs(child:GetChildren()) do
			if folder.ClassName ~= "Model" then
				continue
			end

			local v15 = folder.Name == "Right" and 1 or -1

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant ~= folder.PrimaryPart then
					local objectSpace = folder.PrimaryPart.CFrame:ToObjectSpace(descendant.CFrame)
					descendant.CFrame = folder.PrimaryPart.CFrame * misc.scaleCF(objectSpace, nil, {
						X = v7,
						Y = v8,
						Z = v9
					})
				end

				if not descendant:IsA("ParticleEmitter") then
					continue
				end

				misc.ScaleParticle(descendant, v10)
				table.insert(v11[child.Name][folder.Name], {
					Object = descendant,
					Rate = descendant.Rate
				})
			end

			local objectSpace = child.PrimaryPart.CFrame:ToObjectSpace(folder.PrimaryPart.CFrame)
			folder:SetPrimaryPartCFrame(child.PrimaryPart.CFrame * objectSpace * CFrame.new(v15 * -v4 / 4 * v14.X, 0, 0))
		end

		child:SetPrimaryPartCFrame(modelCFrame * CFrame.new(0, -v5 / 2 * (1 - v14.Y), v13 * -v6 / 2 * (1 - v14.Z)))
	end

	for _, folder in pairs(clone:GetChildren()) do
		for _, part in pairs(folder:GetDescendants()) do
			if not (part:IsA("BasePart") and part ~= folder.PrimaryPart) then
				continue
			end

			local primaryPart2 = folder.PrimaryPart
			part.Massless = true
			local weld = Instance.new("Weld")
			weld.Part0 = primaryPart2
			weld.Part1 = part
			weld.C0 = primaryPart2.CFrame:ToObjectSpace(part.CFrame)
			weld.Parent = part
			part.Anchored = false
			part.CanCollide = false
		end

		local primaryPart2 = folder.PrimaryPart
		primaryPart2.Massless = true
		local weld = Instance.new("Weld")
		weld.Part0 = primaryPart
		weld.Part1 = primaryPart2
		weld.C0 = primaryPart.CFrame:ToObjectSpace(primaryPart2.CFrame)
		weld.Parent = primaryPart2
		folder.PrimaryPart.Anchored = false
		folder.PrimaryPart.CanCollide = false
		v12[folder.Name] = {
			Object = weld,
			C0 = weld.C0
		}
	end

	clone.Parent = _WorldOrigin
	local v13 = {
		SpeedAlpha = 0,
		Model = clone,
		Enable = function(self, value, value2, enabled, callback, value3)
			local v14 = value or "All"
			local v15 = value2 or "All"
			local v16 = 0
			local v17 = value3 or 0

			for k, v18 in pairs(v11) do
				if not (v14 == "All" or v14 == k) then
					continue
				end

				for k2, v19 in pairs(v18) do
					if not (v15 == "All" or v15 == k2) then
						continue
					end

					for _, v20 in pairs(v19) do
						v16 = math.max(v16, v20.Object.Lifetime.Max)

						if v20.Object:GetAttribute("Ignore") then
							continue
						end

						local v21 = math.clamp((self.SpeedAlpha - v17) / (1 - v17), 0, 1)
						v20.Object.Enabled = enabled
						v20.Object.Rate = v20.Rate * v21
					end
				end
			end

			if callback then
				task.delay(v16, callback)
			end
		end,
		Destroy = function(self, p)
			if not p then
				self:Enable("All", "All", false, function()
					self.Model:Destroy()
					v11 = {
						Back = {
							Left = {},
							Right = {}
						},
						Front = {
							Left = {},
							Right = {}
						}
					}
					v12 = {
						Back = {},
						Front = {}
					}
				end)
				return
			end

			self.Model:Destroy()
			v11 = {
				Back = {
					Left = {},
					Right = {}
				},
				Front = {
					Left = {},
					Right = {}
				}
			}
			v12 = {
				Back = {},
				Front = {}
			}
		end,
		UpdateSpeedAlpha = function(p, p2)
			p.SpeedAlpha = p2 or p.SpeedAlpha
		end
	}
	local parentChangedConnection = nil
	parentChangedConnection = instance:GetPropertyChangedSignal("Parent"):Connect(function()
		if instance.Parent == nil then
			parentChangedConnection:Disconnect()
			v13:Destroy(true)
		end
	end)
	v13:Enable("All", "All", false)
	return v13
end