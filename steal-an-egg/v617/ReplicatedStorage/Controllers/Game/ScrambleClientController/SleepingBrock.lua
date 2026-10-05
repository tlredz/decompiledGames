return {
	new = function()
		local v = nil
		local v2 = nil
		local v3 = false
		local v4 = false
		local v5 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clear()
			if v2 then
				v2:Stop(0)
				v2:Destroy()
				v2 = nil
			end

			v = nil
			v3 = false
			v5 = false
		end

		return {
			Tick = function(flag: boolean)
				local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
				local brock = drScrambleEvent and drScrambleEvent:FindFirstChild("Brock")

				if brock ~= v then
					clear() -- equivalent call inferred; original call site unknown

					if not (brock and brock:IsA("Model")) then
						brock = nil
					end

					v = brock
				end

				local v6 = v

				if not (v6 and v6.PrimaryPart) then
					return
				end

				local humanoid = v6:FindFirstChildOfClass("Humanoid")
				local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
				local scrambleSleeping = humanoid and humanoid:FindFirstChild("ScrambleSleeping")

				if not v2 and not v4 and not v5 and animator and scrambleSleeping and scrambleSleeping:IsA("Animation") then
					v4 = true
					task.spawn(function()
						local success, result = pcall(animator.LoadAnimation, animator, scrambleSleeping)
						v4 = false

						if success then
							if v ~= v6 or not v6:IsDescendantOf(workspace) then
								result:Destroy()
								return
							end

							result.Looped = true
							result.Priority = Enum.AnimationPriority.Action
							v2 = result
						else
							v5 = v == v6
							warn("[Scramble] Brock sleeping animation failed:", result)
						end
					end)
				end

				local currentCamera = workspace.CurrentCamera

				if flag then
					if currentCamera == nil then
						flag = false
					else
						flag = (currentCamera.CFrame.Position - v6:GetPivot().Position).Magnitude <= 160
					end
				end

				if v2 and flag ~= v3 then
					v3 = flag

					if flag then
						v2:Play(0.2)
					else
						v2:Stop(0.2)
					end
				end
			end,
			Destroy = function()
				clear() -- equivalent call inferred; original call site unknown
			end
		}
	end
}