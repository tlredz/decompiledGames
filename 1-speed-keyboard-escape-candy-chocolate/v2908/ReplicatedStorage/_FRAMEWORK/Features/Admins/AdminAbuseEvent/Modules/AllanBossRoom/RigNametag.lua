local createVector = vector.create
local RunService = game:GetService("RunService")
local uDim = UDim2.new(36, 0, 5.6, 0)
local color = Color3.fromRGB(0, 0, 0)

local function resolveRigAnchor(instance)
	local head = instance:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		return head
	end

	local primaryPart = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart")

	if primaryPart and primaryPart:IsA("BasePart") then
		return primaryPart
	end

	return nil
end

local function buildBillboard(p)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "AllanBossRoomRigNametag"
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = uDim
	billboardGui.StudsOffset = createVector(0, 3.5, 0)
	billboardGui.MaxDistance = 250
	billboardGui.ResetOnSpawn = false
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Text = p.text
	textLabel.TextColor3 = p.color
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextScaled = true
	textLabel.Parent = billboardGui
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 2.5
	uIStroke.Color = color
	uIStroke.Parent = textLabel
	return billboardGui
end

return {
	start = function(data)
		assert(RunService:IsServer(), "AllanBossRoom.RigNametag.start is server-only")
		local config = data.config
		local logger = data.logger
		local v = true
		local billboards = {}

		local function attach(instance, p)
			local head = instance:FindFirstChild("Head")

			if not (head and head:IsA("BasePart")) then
				head = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart")

				if not (head and head:IsA("BasePart")) then
					head = nil
				end
			end

			if not head then
				logger:warn((`RigNametag: '{instance.Name}' has no Head or root part — the '{p.text}' tag is not shown`))
				return
			end

			local allanBossRoomRigNametag = head:FindFirstChild("AllanBossRoomRigNametag")

			if allanBossRoomRigNametag then
				allanBossRoomRigNametag:Destroy()
			end

			local billboard = buildBillboard(p)
			billboard.Parent = head
			table.insert(billboards, billboard)
		end

		task.spawn(function()
			local v2 = os.clock() + 20
			local v3 = false
			local v4 = false

			while v and not (v3 and v4) and os.clock() < v2 do
				if not v3 then
					local lokiiRig = data.getLokiiRig()

					if lokiiRig then
						attach(lokiiRig, config.rigNametags.lokii)
						v3 = true
					end
				end

				if not v4 then
					local allanRig = data.getAllanRig()

					if allanRig then
						attach(allanRig, config.rigNametags.allan)
						v4 = true
					end
				end

				if not (v3 and v4) then
					task.wait(0.5)
				end
			end

			if v and not (v3 and v4) then
				logger:warn((`RigNametag: gave up resolving a boss rig after {20}s`))
			end
		end)
		return {
			stop = function()
				v = false

				for _, v2 in billboards do
					v2:Destroy()
				end

				table.clear(billboards)
			end
		}
	end
}