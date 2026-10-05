local createVector = vector.create

local function alignCF(data, p, p2)
	local p3 = data.p
	local unit = data.LookVector:Cross(p).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(p).Unit.Unit

	if not p2 then
		return CFrame.fromMatrix(p3, unit2, p, unit3)
	end

	local clone = workspace.IDK:Clone()
	clone.Color = Color3.new(0, 1, 0)
	local clone2 = clone:Clone()
	clone2.Color = Color3.new(1, 1, 0)
	local clone3 = clone:Clone()
	clone3.Color = Color3.new(1, 0, 0)
	clone.CFrame = CFrame.new(p3, p3 + unit2)
	clone2.CFrame = CFrame.new(p3, p3 + p)
	clone3.CFrame = CFrame.new(p3, p3 + unit3)
	local _WorldOrigin = workspace._WorldOrigin
	local _WorldOrigin2 = workspace._WorldOrigin
	local _WorldOrigin3 = workspace._WorldOrigin
	clone.Parent = _WorldOrigin
	clone2.Parent = _WorldOrigin2
	clone3.Parent = _WorldOrigin3
	return CFrame.fromMatrix(p3, unit2, p, unit3)
end

local _WorldOrigin = workspace._WorldOrigin
local map = workspace:WaitForChild("Map", 1)
local RayCastWhitelist = require(game.ReplicatedStorage.Util.RayCastWhitelist)
local Tween = require(game.ReplicatedStorage.Util.Tween)
local part = Instance.new("Part")
part.Size = createVector(0.05, 0.05, 0.05)
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.Material = "Neon"
local specialMesh = Instance.new("SpecialMesh")
specialMesh.MeshType = "FileMesh"
specialMesh.TextureId = "rbxassetid://967852042"
specialMesh.Parent = part
local currentCamera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local v = {}
local v2 = {}
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(_)
	local now = tick()
	local count = 0

	for k, v3 in pairs(v) do
		local _ = count > 0

		if v3.Anchor and v3.Anchor.Parent then
			local magnitude = (v3.LastPosition - v3.Anchor.Position).Magnitude

			if magnitude > 15 then
				if (currentCamera.CFrame.p - v3.Anchor.Position).Magnitude < v3.RenderFidelity then
					v3:Add(v3.Anchor.CFrame, magnitude)
				end

				v3.LastPosition = v3.Anchor.Position
			end
		else
			v[k] = nil
			count += 1
		end
	end

	local count2 = 0

	for k, v3 in pairs(v2) do
		local _ = count2 > 0
		local v4 = now - v3.Start

		if v3.FadeIn + v3.FadeOut + v3.Lifetime < v4 then
			v3.Part:Destroy()
			v2[k] = nil
			count2 += 1
		elseif v3.FadeIn + v3.Lifetime < v4 then
			local v5 = (v4 - v3.FadeIn - v3.Lifetime) / v3.FadeOut
			local quad = Tween.ease["in"].quad(v5, 1, -1, 1)
			local quad2 = Tween.ease.inout.quad(v5, 0, 1, 1)
			local lookVector = v3.CFrame.LookVector
			v3.Part.CFrame = v3.CFrame - lookVector * v3.Length / 2
			v3.Mesh.Scale = Vector3.new(v3.Width * quad, 0.1, v3.Length)
			v3.Part.Transparency = quad2
		elseif not (v3.FadeIn < v4) then
			local v5 = v4 / v3.FadeIn
			local quad = Tween.ease.out.quad(v5, 0, 1, 1)
			local lookVector = v3.CFrame.LookVector
			v3.Part.CFrame = v3.CFrame - lookVector * v3.Length / 2
			v3.Mesh.Scale = Vector3.new(v3.Width, 0.1, v3.Length)
			v3.Mesh.VertexColor = Vector3.new(v3.Color.r, v3.Color.g, v3.Color.b):Lerp(Vector3.new(), quad) * 3
		end
	end
end)
return function(data)
	local anchor = data.Anchor
	local color = data.Color or Color3.new(1, 0, 0)
	local fadeIn = data.FadeIn or 0.5
	local lifetime = data.Lifetime or 0.5
	local fadeOut = data.FadeOut or 0.5
	local width = data.Width or 1
	local _ = data.Scale or 10
	local renderFidelity = data.RenderFidelity or 100 + 50 * width
	local hitboxSize = data.HitboxSize or createVector(1, 1, 1)

	if _G.FastMode then
		return
	end

	local lerped = color:Lerp(Color3.new(1, 1, 1), 0.25)
	table.insert(v, {
		Anchor = anchor,
		LastPosition = anchor.Position,
		Color = lerped,
		Width = width,
		RenderFidelity = renderFidelity,
		Add = function(self, data2, length)
			local v3, v4, v5 = RayCastWhitelist(
				data2.p + data2.UpVector * 0.1,
				-data2.UpVector * width * hitboxSize.Y * 1.25,
				{ map }
			)

			if v3 then
				local v6 = CFrame.new(Vector3.new(), data2.LookVector) + v4
				local p3 = v6.p
				local unit = v6.LookVector:Cross(v5).Unit
				local unit2 = (unit.Magnitude > 0.001 and unit or v6.RightVector).Unit
				local unit3 = unit2:Cross(v5).Unit.Unit
				local cframe = CFrame.fromMatrix(p3, unit2, v5, unit3)
				local clone = part:Clone()
				clone.CFrame = cframe
				clone.Mesh.Scale = createVector(0, 0.1, 0)
				clone.Mesh.VertexColor = Vector3.new(lerped.r, lerped.g, lerped.b) * 2
				clone.Parent = _WorldOrigin
				table.insert(v2, {
					CFrame = cframe,
					Color = self.Color,
					Width = self.Width,
					Length = length,
					Part = clone,
					Mesh = clone.Mesh,
					FadeIn = fadeIn,
					Lifetime = lifetime,
					FadeOut = fadeOut,
					Start = tick()
				})
			end
		end
	})
end