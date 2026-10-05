local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local color = Color3.fromRGB(255, 196, 92)
local color2 = Color3.fromRGB(120, 255, 140)
local color3 = Color3.fromRGB(255, 70, 70)
local clonesBySimonIndex = {}

local function refresh()
	for _, parent in CollectionService:GetTagged("SimonPlate") do
		local simonIndex = parent:GetAttribute("SimonIndex")

		if type(simonIndex) ~= "number" then
			continue
		end

		local v2 = clonesBySimonIndex[simonIndex]

		if not (v2 == nil or v2.Parent == nil) then
			continue
		end

		for _, part in parent:GetChildren() do
			if not (part:IsA("BasePart") and part.Name ~= "Base") then
				continue
			end

			local clone = part:Clone()
			clone:ClearAllChildren()
			clone.Name = "Glow"
			clone.Material = Enum.Material.Neon
			clone.Transparency = 1
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Size = Vector3.new(part.Size.X, 0.1, part.Size.Z)
			clone.CFrame = part.CFrame * CFrame.new(0, (part.Size.Y + 0.1) / 2 + 0.01, 0)
			clone.Parent = parent
			clonesBySimonIndex[simonIndex] = clone
			break
		end
	end
end

local function glow(p: number, color4: Color3)
	local v = clonesBySimonIndex[p]

	if v == nil then
		return
	end

	TweenService:Create(v, TweenInfo.new(0.2), {
		Transparency = 0,
		Color = color4
	}):Play()
end

local function dim(p: number)
	local v = clonesBySimonIndex[p]

	if v == nil then
		return
	end

	TweenService:Create(v, TweenInfo.new(0.2), {
		Transparency = 1
	}):Play()
end

local function sound(childName: string, p: number)
	local child = script:FindFirstChild(childName)
	local parent = clonesBySimonIndex[p]

	if child == nil or parent == nil then
		return
	end

	local clone = child:Clone()
	clone.Parent = parent
	clone:Play()
	Debris:AddItem(clone, clone.TimeLength + 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function glowAll(color4: Color3)
	for k in clonesBySimonIndex do
		glow(k, color4)
	end
end

local function dimAll()
	for k in clonesBySimonIndex do
		dim(k)
	end
end

return {
	handle = function(data)
		local action = data.Action

		if action == "Show" then
			refresh()
			task.spawn(function()
				task.wait(data.Lead)

				for _, plate in data.Plates do
					glow(plate, color)
					local padAppear = script:FindFirstChild("PadAppear")
					local parent = clonesBySimonIndex[plate]

					if padAppear ~= nil and parent ~= nil then
						local clone = padAppear:Clone()
						clone.Parent = parent
						clone:Play()
						Debris:AddItem(clone, clone.TimeLength + 1)
					end

					task.wait(data.Step * 0.6)
					dim(plate)
					task.wait(data.Step * 0.4)
				end
			end)
		elseif action == "Step" then
			glow(data.Plate, color2)
			local plate = data.Plate
			local padStep = script:FindFirstChild("PadStep")
			local parent = clonesBySimonIndex[plate]

			if padStep ~= nil and parent ~= nil then
				local clone = padStep:Clone()
				clone.Parent = parent
				clone:Play()
				Debris:AddItem(clone, clone.TimeLength + 1)
			end

			task.delay(0.25, dim, data.Plate)
		elseif action == "Fail" then
			glowAll(color3) -- equivalent call inferred; original call site unknown
			local plate = data.Plate
			local fail = script:FindFirstChild("Fail")
			local parent = clonesBySimonIndex[plate]

			if fail ~= nil and parent ~= nil then
				local clone = fail:Clone()
				clone.Parent = parent
				clone:Play()
				Debris:AddItem(clone, clone.TimeLength + 1)
			end

			task.delay(0.8, dimAll)
		elseif action == "Win" then
			glowAll(color2) -- equivalent call inferred; original call site unknown
			local plate = data.Plate
			local win = script:FindFirstChild("Win")
			local parent = clonesBySimonIndex[plate]

			if win ~= nil and parent ~= nil then
				local clone = win:Clone()
				clone.Parent = parent
				clone:Play()
				Debris:AddItem(clone, clone.TimeLength + 1)
			end

			task.delay(1.5, dimAll)
		end
	end
}