local enemies = workspace:WaitForChild("Enemies", 10000)

function ChildAdded(folder)
	local function MotorAdded(descendant)
		if not descendant:IsA("Motor6D") or descendant:IsA("Bone") or (not descendant.Parent or descendant.Parent.Parent ~= folder) then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function checkafter()
			local idleTransform = descendant:GetAttribute("IdleTransform")
			task.spawn(function()
				for _ = 1, 4 do
					if descendant.Transform:FuzzyEq(CFrame.new()) then
						descendant.Transform = idleTransform
					end

					task.wait(1)
				end
			end)
		end

		if not descendant:GetAttribute("IdleTransform") then
			task.spawn(function()
				local total = 0

				while not descendant:GetAttribute("IdleTransform") and total < 10 do
					total += task.wait(0.1)
				end

				if descendant:GetAttribute("IdleTransform") then
					checkafter() -- equivalent call inferred; original call site unknown
				end
			end)
			return
		end

		local idleTransform = descendant:GetAttribute("IdleTransform")
		task.spawn(function()
			for _ = 1, 4 do
				if descendant.Transform:FuzzyEq(CFrame.new()) then
					descendant.Transform = idleTransform
				end

				task.wait(1)
			end
		end)
	end

	for _, descendant in pairs(folder:GetDescendants()) do
		MotorAdded(descendant)
	end

	local descendantAddedConnection = folder.DescendantAdded:Connect(MotorAdded)
	task.delay(10, descendantAddedConnection.Disconnect, descendantAddedConnection)
end

for _, child in pairs(enemies:GetChildren()) do
	task.spawn(ChildAdded, child)
end

enemies.ChildAdded:Connect(ChildAdded)