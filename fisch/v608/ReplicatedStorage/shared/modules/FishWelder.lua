local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local assets = require(ReplicatedStorage.shared.utils.assets)
local logger = require(ReplicatedStorage.shared.utils.logger)

-- equivalent calls inferred from this helper; original call sites unknown
local function weld(p, part)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p
	weldConstraint.Part1 = part
	weldConstraint.Name = string.format("Weld_%*", part.Name)
	weldConstraint.Parent = p
end

local function clearAllWelds(folder)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint")) or descendant:IsA("Motor6D") then
			continue
		end

		descendant:Destroy()
	end
end

return {
	WeldAll = function(_)
		assert(RunService:IsServer(), "FishWelder functions can only be called by the server.")
		local serverTimeNow = workspace:GetServerTimeNow()
		local allOfType = assets.getAllOfType("fish")
		local v = #allOfType * 2
		local count = 0

		for _, model in allOfType do
			if not model:IsA("Model") then
				continue
			end

			if not model.PrimaryPart then
				if not model:FindFirstChild("Center") then
					continue
				end

				model.PrimaryPart = model.Center
			end

			clearAllWelds(model)

			for _, part in ipairs(model:GetDescendants()) do
				if not (part:IsA("BasePart") and part ~= model.Center and (part.Parent ~= model or part.Name ~= "handle" and part.Name ~= "Center")) then
					continue
				end

				weld(model.Center, part) -- equivalent call inferred; original call site unknown
			end

			if not model:FindFirstChild("handle") then
				continue
			end

			weld(model.handle, model.Center) -- equivalent call inferred; original call site unknown
			local mouth = model:FindFirstChild("Hitbox") and model.Center:FindFirstChild("mouth")

			if mouth then
				model.Hitbox.PivotOffset = model.Hitbox.CFrame:ToObjectSpace(model.Center.CFrame) * mouth.CFrame.Rotation

				if model:GetAttribute("FlipForward") then
					model.Hitbox.PivotOffset *= CFrame.fromOrientation(0, 3.141592653589793, 0)
				end
			end

			count += 1
		end

		local serverTimeNow2 = workspace:GetServerTimeNow()
		logger.printLive("Successfully welded " .. count .. "/" .. v .. " fish models in " .. serverTimeNow2 - serverTimeNow .. "s.")
		ServerStorage.resources.fishModels:SetAttribute("WeldFinished", true)
	end
}