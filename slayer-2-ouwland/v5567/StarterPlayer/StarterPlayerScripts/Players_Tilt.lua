local createVector = vector.create
game:GetService("CollectionService")
game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local clamp = math.clamp
local _ = math.rad
local C1s = {}

local function getangle(humanoidRootPart, humanoid)
	if localPlayer:FindFirstChild("Transforming_to_mode") ~= nil or not humanoidRootPart or not humanoidRootPart.Parent or humanoidRootPart.Parent:FindFirstChild(humanoidRootPart.Parent.Name .. "'s Wagon") or not (humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0.1 and humanoidRootPart.Velocity.Magnitude > 0.1) then
		return 0
	end

	local v = humanoidRootPart.Velocity * createVector(1, 0, 1)

	if v.Magnitude > 2 then
		return (clamp(v.Unit:Dot(humanoidRootPart.CFrame.rightVector), -0.11, 0.11))
	end

	return 0
end

local function getdefaultc1(p)
	if not C1s[p] then
		C1s[p] = p.C1
	end

	return C1s[p]
end

while true do
	local character = localPlayer.Character

	if character and character.Parent == workspace.Humanoids then
		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local lowerTorso = character:FindFirstChild("LowerTorso")
		local upperTorso = character:FindFirstChild("UpperTorso")

		if humanoid and humanoidRootPart and lowerTorso and upperTorso then
			local root = lowerTorso:FindFirstChild("Root")
			local waist = upperTorso:FindFirstChild("Waist")

			if root and waist then
				if not C1s[root] then
					C1s[root] = root.C1
				end

				local v = C1s[root]

				if not C1s[waist] then
					C1s[waist] = waist.C1
				end

				local v2 = C1s[waist]
				local v3 = getangle(humanoidRootPart, humanoid)
				local cframe = CFrame.Angles(0, 0, v3)
				root.C1 = root.C1:Lerp(v * cframe, 0.11)
				waist.C1 = waist.C1:Lerp(v2 * cframe, 0.11)
			end
		end
	end

	task.wait()
end