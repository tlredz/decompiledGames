local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "MythicalMutationEffect"
})

function v:Construct()
	self.trove = Trove.new()
	self.Parts = {}
end

function v.Start(data)
	local total = 0
	local v2 = 0
	local v3 = false
	local isA = data.Instance:IsA("Model")
	local extentsSize = isA and data.Instance:GetExtentsSize() or Vector3.new()
	local v4 = math.max(extentsSize.X, extentsSize.Y, extentsSize.Z) / 2 + 150
	data.trove:Add(RunService.RenderStepped:Connect(function(dt: number)
		local now = tick()

		if isA and now - v2 > 0.3333333333333333 then
			v3 = (data.Instance:GetBoundingBox().Position - workspace.CurrentCamera.CFrame.Position).Magnitude < v4
			v2 = now
		end

		if isA and not v3 then
			return
		end

		if total <= 0.08333333333333333 then
			total += dt
			return
		end

		total = 0
		local v5 = now % 20 / 20

		for k, part in data.Parts do
			if not (k.LocalTransparencyModifier >= 1) then
				k.Color = Color3.fromHSV(
					v5,
					math.clamp(math.min(1, part.Saturation + 0.3), 0, 1),
					(math.clamp(math.min(1, part.Value + 0.4), 0, 1))
				)
			end
		end
	end))

	local function initPart(part)
		if not part:IsA("BasePart") or (part.Name == "Eyes" or part:GetAttribute("ColorS") or part.Transparency >= 1) then
			return
		end

		part.Material = Enum.Material.Neon
		local _, saturation, v6 = part.Color:ToHSV()
		part:SetAttribute("ColorS", saturation)
		part:SetAttribute("ColorV", v6)
		data.Parts[part] = {
			Saturation = saturation,
			Value = v6
		}
	end

	data.trove:Add(data.Instance.DescendantAdded:Connect(initPart))
	data.trove:Add(data.Instance.DescendantRemoving:Connect(function(part)
		if not part:IsA("BasePart") then
			return
		end

		data.Parts[part] = nil
	end))

	for _, descendant in data.Instance:GetDescendants() do
		initPart(descendant)
	end
end

function v.Stop(p)
	p.trove:Destroy()
end

return v