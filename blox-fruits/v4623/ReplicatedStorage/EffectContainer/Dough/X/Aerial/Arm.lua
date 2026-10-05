local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
FX:WaitForChild("Dough")
local Util = require(ReplicatedStorage.Util)
local Effect = require(ReplicatedStorage.Effect)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local doughMiscArmsExtend = Effect.new("Dough.Misc.Arms.Extend")
local currentCamera = workspace.CurrentCamera
local part = Instance.new("Part")
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.CastShadow = false
part.CanTouch = false
part.CanQuery = false
part.Size = createVector(1, 1, 1)
part.CFrame = CFrame.identity
return function(data)
	if not data.Root then
		local _ = data.HRP
	end

	local anchor = data.Anchor
	local anchorJoint = data.AnchorJoint
	local anchorJoint2 = data.AnchorJoint2
	local anchorJoint3 = data.AnchorJoint3
	local point = data.Point
	local length = data.Length or 10
	local _ = data.Size or createVector(1, 1, 1)
	local extendDuration = data.ExtendDuration or 1
	local retractDuration = data.RetractDuration or 1
	local v = extendDuration + retractDuration
	local size = anchor.Size
	local v2 = math.max(size.X, size.Y, size.Z)
	local Y = size.X == v2 and size.Y or size.Y == v2 and size.X or size.X
	local Z = size.X == v2 and size.Z or size.Y == v2 and size.Z or size.Y
	local v3 = math.sqrt(Y * Y + Z * Z) / 2.25

	if 200 + (length + v3) * 3 < (currentCamera.CFrame.p - anchor.CFrame.p).Magnitude then
		return
	end

	local random = Random.new()
	local clone = part:Clone()
	clone.Transparency = 1
	clone.Color = Color3.new(0, 1, 0)
	clone.Material = "Neon"
	clone.Size = createVector(1.5, 1.5, 1.5)
	clone.CFrame = CFrame.new(anchor.Position, point)
	clone.Parent = _WorldOrigin
	Util.Debris:AddItem(clone, v + 1)
	local C0 = anchorJoint.C0
	local C1 = anchorJoint.C1
	local C02 = anchorJoint2.C0
	local C12 = anchorJoint2.C1
	local C03 = anchorJoint3.C0
	local _ = anchorJoint3.C1
	Util.DistributedLoop:add(function(p, _)
		local cframe = anchorJoint.Part0.CFrame * C0
		local pointToObjectSpace = cframe:PointToObjectSpace(point)
		local v4 = math.acos(-pointToObjectSpace.Unit.Z)
		local cross = (createVector(0, 0, -1)):Cross(pointToObjectSpace.Unit)

		if cross == Vector3.new() then
			cross = v4 == 3.141592653589793 and createVector(-1, 0, 0) or createVector(0, 0, -1)
		end

		local v5 = cframe * CFrame.fromAxisAngle(cross, v4)
		local v6 = math.abs(C1.Y) + math.abs(C02.Y)
		local v7 = math.abs(C12.Y) + math.abs(C03.Y)
		local magnitude = pointToObjectSpace.Magnitude
		local v8

		if magnitude < math.max(v7, v6) - math.min(v7, v6) then
			v8 = -1.5707963267948966
		elseif v6 + v7 < magnitude then
			v8 = 1.5707963267948966
		else
			local v9 = -math.acos((-(v7 * v7) + v6 * v6 + magnitude * magnitude) / (v6 * 2 * magnitude))
			local v10 = math.acos((v7 * v7 - v6 * v6 + magnitude * magnitude) / (v7 * 2 * magnitude))
			v8 = v9 + 1.5707963267948966
			local _ = v10 - v9
		end

		anchorJoint.C0 = anchorJoint.Part0.CFrame:ToObjectSpace(v5) * CFrame.Angles(v8, 0, 0)
		anchorJoint.C1 = C1
		anchorJoint.Transform = CFrame.identity
		clone.CFrame = anchorJoint.Part0.CFrame * anchorJoint.C0 * anchorJoint.C1:inverse() * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)

		if not (v < p) and anchor:IsDescendantOf(workspace) then
			return
		end

		anchorJoint.C0 = C0
		anchorJoint.C1 = C1
		anchorJoint.Transform = CFrame.identity
		clone:Destroy()
		return true
	end)
	doughMiscArmsExtend:replicate({
		Anchor = clone,
		CFrame = CFrame.new(0, 0, -math.max(anchor.Size.X, anchor.Size.Y, anchor.Size.Z) / 4),
		Scale = Vector2.new(v3 / 2, length),
		ExtendDuration = extendDuration,
		RetractDuration = retractDuration,
		OnExtend = function(object, duration)
			Effect.new("Dough.Explosions.DripScatter"):replicate({
				CFrame = object:__getCFrame(),
				Scale = anchor.Size.Magnitude / 2,
				Spread = Vector2.new(45, 45),
				Drag = 4,
				Distance = 2.5 + anchor.Size.Magnitude / 2 * 2,
				Rate = 12,
				Gravity = 0.75,
				Time = 0.15,
				Influence = { 0.5, 1.5 }
			})
			Effect.new("Dough.Misc.Arms.Extend.Effects.Extend"):replicate({
				CFrame = object:__getCFrame(),
				Width = object.Width,
				Length = object.Length,
				Buso = object.Buso,
				Duration = duration
			})

			if data.RayCastResult then
				task.delay(duration * 0.3, function()
					local alignCFrame = Util.Misc.AlignCFrame(
						CFrame.new(data.RayCastResult.Position) * CFrame.Angles(
							0,
							random:NextNumber(-1, 1) * 3.141592653589793,
							0
						),
						data.RayCastResult.Normal
					)
					Util.Sound:Play("Dough.DoughGroundBreaking", alignCFrame.p, nil, 1.326)
					Effect.new("Dough.Misc.Hit.Floor"):replicate({
						CFrame = alignCFrame,
						Scale = object.Width * 4 * 2.25
					})
				end)
			end
		end,
		OnRetract = function(object, duration)
			Effect.new("Dough.Misc.Arms.Extend.Effects.Retract"):replicate({
				CFrame = object:__getCFrame() * CFrame.new(0, 0, -object.Length),
				Width = object.Width,
				Length = object.Length,
				Buso = object.Buso,
				Duration = duration
			})
		end
	})
end