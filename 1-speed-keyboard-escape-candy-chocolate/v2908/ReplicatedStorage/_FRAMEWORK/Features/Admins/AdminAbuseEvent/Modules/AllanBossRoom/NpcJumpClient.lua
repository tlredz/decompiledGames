local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function verticalArc(p: number, p2: number, p3: number, p4: number)
	return p + (p3 - p) * p4 + (p2 - math.max(p, p3)) * (p4 * 4 * (1 - p4))
end

return {
	start = function(p)
		assert(RunService:IsClient(), "AllanBossRoom.NpcJumpClient.start is client-only")
		local v = false
		local renderSteppedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function endArc()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			v = false
		end

		return {
			isJumping = function()
				return v
			end,
			playJump = function(vector: Vector3, position: Vector3, p2: number, p3: number, callback)
				endArc() -- equivalent call inferred; original call site unknown

				if p.getRig() then
					v = true
					local rotation = CFrame.lookAt(vector, (Vector3.new(position.X, vector.Y, position.Z))).Rotation
					local v2 = math.max(vector.Y, position.Y) + p3
					local total = 0
					renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
						local rig = p.getRig()

						if rig then
							total += dt
							local v3 = not (p2 > 0) and 1 or math.min(1, total / p2)
							local v4 = vector.X + (position.X - vector.X) * v3
							local v5 = vector.Z + (position.Z - vector.Z) * v3
							rig:PivotTo(CFrame.new(v4, verticalArc(vector.Y, v2, position.Y, v3), v5) * rotation)

							if v3 >= 1 then
								endArc() -- equivalent call inferred; original call site unknown
								rig:PivotTo(CFrame.new(position) * rotation)

								if callback then
									callback()
								end
							end
						else
							endArc() -- equivalent call inferred; original call site unknown

							if callback then
								callback()
							end
						end
					end)
				elseif callback then
					callback()
				end
			end,
			stop = endArc
		}
	end
}