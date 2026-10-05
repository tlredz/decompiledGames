local createVector = vector.create
game:GetService("TweenService")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Util"))

function a(data)
	local rig = data.Rig
	local ownerRoot = data.OwnerRoot
	local seat = data.Seat
	task.defer(function()
		local v = nil

		while rig and rig:IsDescendantOf(workspace) do
			local passengerObject = ownerRoot:FindFirstChild("PassengerObject")
			local value = passengerObject and passengerObject.Value

			if value and ownerRoot.Parent:GetAttribute("HasPassenger") then
				local humanoidRootPart = value:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					humanoidRootPart.CFrame = CFrame.new(
						seat.Position,
						seat.Position + ownerRoot.CFrame.LookVector * createVector(1, 0, 1)
					) * CFrame.new(0, 1.5, -3)
					humanoidRootPart.Velocity = createVector(0, 0, 0)
				end

				v = v or value:FindFirstChild("Humanoid")
			end

			task.wait()
		end

		if v then
			v:SetAttribute("IsPassenger", false)
		end
	end)
end

return a