local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
local localPlayer = Players.LocalPlayer
local v2 = {}
local v3 = {}

local function IsInsideBrick(instance, vector2: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector2)
	return math.abs(pointToObjectSpace.X) <= instance.Size.X / 2 and math.abs(pointToObjectSpace.Y) <= instance.Size.Y / 2 and math.abs(pointToObjectSpace.Z) <= instance.Size.Z / 2
end

if not script:GetAttribute("__INITIALIZED") then
	script:SetAttribute("__INITIALIZED", true)

	local function applyForce(character, instance)
		if character:GetAttribute("Dead") then
			return
		end

		local v4 = v3[character]

		if not v4 then
			local maid = v.new()
			local dash = maid:Add(Instance.new("LinearVelocity"))
			dash.Name = "PlayerMover"
			dash.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
			dash.RelativeTo = Enum.ActuatorRelativeTo.World
			dash.ForceLimitsEnabled = false
			dash.LineVelocity = 50
			local humanoidRootPart = character.HumanoidRootPart
			dash.Attachment0 = humanoidRootPart.RootAttachment
			dash.Parent = humanoidRootPart
			v4 = {
				Trove = v.new(),
				Dash = dash
			}
			maid:Add(character:GetAttributeChangedSignal("Dead"):Connect(function()
				maid:Destroy()
				v3[character] = nil
			end))
			maid:Add(character.AncestryChanged:Connect(function()
				if character:IsDescendantOf(workspace.Alive) then
					return
				end

				maid:Destroy()
				v3[character] = nil
			end))
			v3[character] = v4
		end

		v4.Dash.Enabled = true
		v4.Dash.LineDirection = instance:GetPivot().LookVector
	end

	local function clientStep(_: number)
		if #v2 == 0 then
			return
		end

		local character = localPlayer.Character

		if not character then
			return
		end

		local primaryPart = character.PrimaryPart

		if not primaryPart then
			return
		end

		local scale = character:GetScale()
		local v4 = primaryPart.Position - createVector(0, 1, 0) * (2.9 * scale)
		local flag = false
		local v5 = nil

		for _, v7 in ipairs(v2) do
			if not IsInsideBrick(v7, v4) then
				continue
			end

			v5 = v7
			flag = true
			break
		end

		if flag then
			applyForce(character, v5)
			return
		end

		local v7 = v3[character]

		if v7 then
			v7.Dash.Enabled = false
		end
	end

	task.spawn(function()
		while true do
			clientStep(task.wait(0.05))
		end
	end)
end

return {
	Tags = { "Component_PlayerMover" },
	Callback = function(p)
		table.insert(v2, p)
		return function()
			local index = table.find(v2, p)

			if index then
				table.remove(v2, index)
			end
		end
	end
}