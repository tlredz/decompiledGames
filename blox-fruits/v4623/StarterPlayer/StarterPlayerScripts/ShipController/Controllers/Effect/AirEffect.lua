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
	local v7 = v4 / 18
	local v8 = v5 / 5
	local v9 = v6 / 18
	local v10 = math.min((v7 + v8 + v9) / 3, v7)
	local v11 = {
		Back = {},
		Front = {}
	}
	local v12 = {
		Back = {},
		Front = {}
	}

	for _, folder in pairs(clone:GetChildren()) do
		local v13 = folder.Name == "Front" and 1 or -1
		local v14 = folder.Name == "Back" and backOffset or frontOffset

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
			table.insert(v11[folder.Name], {
				Object = descendant,
				Rate = descendant.Rate
			})
		end

		folder:SetPrimaryPartCFrame(modelCFrame * CFrame.new(0, -v5 / 2 * (1 - v14.Y), v13 * -v6 / 4 * (1 - v14.Z)))
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
		PositionOffset = createVector(0, 0, 0),
		SpeedAlpha = 0,
		Model = clone,
		Enable = function(self, value, enabled, callback, value2)
			local v14 = value or "All"
			local v15 = 0
			local v16 = value2 or 0

			for _, v17 in pairs(v12) do
				if v17.C0 then
					v17.Object.C0 = v17.C0 * CFrame.new(-self.PositionOffset + createVector(0, 1, 0) * v8 * 0.1)
				end
			end

			for k, v17 in pairs(v11) do
				if not (v14 == "All" or v14 == k) then
					continue
				end

				for _, v18 in pairs(v17) do
					if not v18.Object then
						continue
					end

					v15 = math.max(v15, v18.Object.Lifetime.Max)

					if v18.Object:GetAttribute("Ignore") then
						continue
					end

					local v19 = math.clamp((self.SpeedAlpha - v16) / (1 - v16), 0, 1)
					v18.Object.Enabled = enabled
					v18.Object.Rate = v18.Rate * v19
				end
			end

			if callback then
				task.delay(v15, callback)
			end
		end,
		Destroy = function(self, p)
			if not p then
				self:Enable("All", false, function()
					self.Model:Destroy()
					v11 = {
						Back = {},
						Front = {}
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
				Back = {},
				Front = {}
			}
			v12 = {
				Back = {},
				Front = {}
			}
		end,
		UpdateSpeedAlpha = function(p, p2)
			p.SpeedAlpha = p2 or p.SpeedAlpha
			p.PositionOffset = instance.VehicleSeat.BodyPosition:GetAttribute("PositionOffset")
		end
	}
	local parentChangedConnection = nil
	parentChangedConnection = instance:GetPropertyChangedSignal("Parent"):Connect(function()
		if instance.Parent == nil then
			parentChangedConnection:Disconnect()
			v13:Destroy(true)
		end
	end)
	v13:Enable("All", false)
	return v13
end