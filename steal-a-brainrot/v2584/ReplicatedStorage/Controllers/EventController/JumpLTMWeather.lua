local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlags = require(ReplicatedStorage.Packages.FFlags)

local function collectParts(part)
	local parts = part:QueryDescendants("BasePart")

	if part:IsA("BasePart") then
		table.insert(parts, part)
	end

	return parts
end

local function getTopY(part)
	local parts = part:QueryDescendants("BasePart")

	if part:IsA("BasePart") then
		table.insert(parts, part)
	end

	if #parts == 0 then
		return nil
	end

	local v2 = -1e999

	for _, descendant in parts do
		v2 = math.max(v2, descendant.Position.Y + descendant.Size.Y / 2)
	end

	return v2
end

local function getSpanTopY()
	local track = workspace.Map:FindFirstChild("Track")
	local v2

	if track then
		v2 = getTopY(track)
	end

	if v2 then
		return v2 + 50
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSphere(part)
	if part:IsA("Part") and part.Shape == Enum.PartType.Ball then
		return true
	end

	return part:IsA("MeshPart") and math.min(part.Size.X, part.Size.Y, part.Size.Z) > 500
end

local function stackPartToSpanTop(instance, p: number)
	local Y = instance.Size.Y

	if Y <= 0 then
		return
	end

	for i = 1, math.clamp(math.ceil((p - (instance.Position.Y + Y / 2)) / Y), 0, 20) do
		local clone = instance:Clone()
		clone.CFrame += Vector3.new(0, i * Y, 0)
		clone.Parent = instance.Parent
	end
end

local function enableEmitters(object)
	local count = 0

	for _, v2 in object:QueryDescendants("ParticleEmitter"), nil, nil do
		v2.Enabled = true
		count += 1
	end

	return count
end

return table.freeze({
	StackToTrackTop = function(p)
		local track = workspace.Map:FindFirstChild("Track")
		local v2

		if track then
			v2 = getTopY(track)
		end

		local v3

		if v2 then
			v3 = v2 + 50
		end

		if v3 then
			stackPartToSpanTop(p, v3)
		else
			warn("JumpLTMWeather: workspace.Map.Track not found, part left at authored height")
		end
	end,
	GetTrackTopY = function()
		local track = workspace.Map:FindFirstChild("Track")

		if track then
			return (getTopY(track))
		end

		return nil
	end,
	Cover = function(instance, options)
		local folder = Instance.new("Folder")
		folder.Name = `JumpLTMWeather{instance.Name}`
		local clone = instance:Clone()
		clone.Name = "Layer0"
		local count = 0
		local v2 = options or {}

		for _, v3 in clone:QueryDescendants("ParticleEmitter"), nil, nil do
			v3.Enabled = true
			count += 1
		end

		if count == 0 and #clone:QueryDescendants("Beam") == 0 then
			warn((`JumpLTMWeather: no particle emitters or beams found under {instance:GetFullName()}`))
			folder:Destroy()
			return function() end
		else
			local v3

			if not v2.GroundOnly then
				local track = workspace.Map:FindFirstChild("Track")
				local v4

				if track then
					v4 = getTopY(track)
				end

				if v4 then
					v3 = v4 + 50
				end
			end

			if not (v2.GroundOnly or v3) then
				warn("JumpLTMWeather: workspace.Map.Track not found, authored layer only")
			end

			if v3 then
				local clones = clone:QueryDescendants("BasePart")

				if clone:IsA("BasePart") then
					table.insert(clones, clone)
				end

				for _, part in clones do
					if isSphere(part) then
						part.Transparency = 1
					elseif part.Size.Y > 100 then
						stackPartToSpanTop(part, v3)
					end
				end
			end

			clone.Parent = folder

			if v3 then
				local clone2 = instance:Clone()
				local flag = true
				local clones = clone2:QueryDescendants("BasePart")

				if clone2:IsA("BasePart") then
					table.insert(clones, clone2)
				end

				for _, part in clones do
					if not (isSphere(part) or part.Size.Y > 100) then
						continue
					end

					if part == clone2 then
						flag = false
					else
						part:Destroy()
					end
				end

				local v4

				if flag then
					v4 = getTopY(clone2)
				end

				if v4 then
					local v5 = math.max(FFlags:GetInstant("JumpLTM/WeatherLayerInterval", 250), 50)

					for i = 1, math.clamp(math.ceil((v3 - v4) / v5), 0, 20) do
						local clone3 = clone2:Clone()
						clone3.Name = `Layer{i}`
						local count2 = 0

						for _, v6 in clone3:QueryDescendants("ParticleEmitter"), nil, nil do
							v6.Enabled = true
							count2 += 1
						end

						local vector = Vector3.new(0, i * v5, 0)
						local clones2 = clone3:QueryDescendants("BasePart")

						if clone3:IsA("BasePart") then
							table.insert(clones2, clone3)
						end

						for _, descendant in clones2 do
							descendant.CFrame += vector
						end

						clone3.Parent = folder
					end
				end

				clone2:Destroy()
			end

			folder.Parent = workspace
			local flag = false
			return function()
				if flag then
					return
				end

				flag = true

				for _, v4 in folder:QueryDescendants("ParticleEmitter"), nil, nil do
					v4.Enabled = false
				end

				task.delay(4, function()
					folder:Destroy()
				end)
			end
		end
	end
})