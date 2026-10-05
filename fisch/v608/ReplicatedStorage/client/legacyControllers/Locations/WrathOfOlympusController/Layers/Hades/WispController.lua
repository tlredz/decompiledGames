local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("Hades/WispSnapshot")
local wisp = script:WaitForChild("Wisp")
local v = {}

local function createVisual(i: number, folder)
	local clone = wisp:Clone()
	clone.Name = `Wisp_{i}`
	clone.Anchored = true
	clone.CanCollide = false
	clone.CastShadow = false
	clone.Parent = folder
	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(50, 220, 130)
	pointLight.Brightness = 0.8
	pointLight.Range = 8
	pointLight.Parent = clone
	return {
		Index = i,
		Part = clone,
		TargetPos = createVector(0, 0, 0),
		TargetAngle = 0,
		CurrentPos = createVector(0, 0, 0),
		CurrentAngle = 0,
		Initialized = false,
		PrevSnapshotPos = createVector(0, 0, 0),
		ServerVelocity = createVector(0, 0, 0),
		StateId = 0
	}
end

return {
	Start = function(_)
		if not Workspace:WaitForChild("HadesWisps", 30) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "HadesWispsVisual"
		folder.Parent = Workspace
		remoteEvent.OnClientEvent:Connect(function(buf: buffer)
			for i = 1, buffer.len(buf) / 17 do
				local v2 = (i - 1) * 17
				local v3 = v[i]

				if not v3 then
					v3 = createVisual(i, folder)
					v[i] = v3
				end

				local vector2 = Vector3.new(
					buffer.readf32(buf, v2),
					buffer.readf32(buf, v2 + 4),
					(buffer.readf32(buf, v2 + 8))
				)
				local v4 = buffer.readf32(buf, v2 + 12)
				local stateId = buffer.readu8(buf, v2 + 16)

				if not v3.Initialized then
					v3.CurrentPos = vector2
					v3.CurrentAngle = v4
					v3.PrevSnapshotPos = vector2
					v3.ServerVelocity = createVector(0, 0, 0)
					v3.Initialized = true
				end

				if (vector2 - v3.CurrentPos).Magnitude > 20 then
					v3.CurrentPos = vector2
					v3.PrevSnapshotPos = vector2
					v3.ServerVelocity = createVector(0, 0, 0)
				end

				v3.ServerVelocity = (vector2 - v3.PrevSnapshotPos) * 10
				v3.PrevSnapshotPos = vector2
				v3.TargetPos = vector2
				v3.TargetAngle = v4
				v3.StateId = stateId
			end
		end)
		RunService.RenderStepped:Connect(function(dt)
			for _, v2 in pairs(v) do
				if not (v2.Initialized and v2.Part and v2.Part.Parent) then
					continue
				end

				local v3 = v2.TargetPos - v2.CurrentPos
				local magnitude = v3.Magnitude
				local magnitude2 = v2.ServerVelocity.Magnitude

				if magnitude >= 0.01 then
					if magnitude2 < 0.01 then
						v2.CurrentPos = v2.CurrentPos:Lerp(v2.TargetPos, 1 - math.exp(-6 * dt))
					else
						local v4 = magnitude2 * dt
						local currentPos

						if magnitude <= v4 then
							currentPos = v2.TargetPos
						else
							currentPos = v2.CurrentPos + v3 / magnitude * v4
						end

						v2.CurrentPos = currentPos
					end
				end

				local v4 = (v2.TargetAngle - v2.CurrentAngle) % 6.283185307179586

				if v4 > 3.141592653589793 then
					v4 -= 6.283185307179586
				end

				v2.CurrentAngle += v4 * math.min(1, 6 * dt)
				v2.Part.CFrame = CFrame.new(v2.CurrentPos) * CFrame.Angles(0, v2.CurrentAngle, 0)
			end
		end)
	end
}