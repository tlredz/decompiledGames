local ReplicatedStorage = game:GetService("ReplicatedStorage")
local weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Weapons")
local others = weapons:WaitForChild("Others")
local v = {}

local function GetAnimationFolder(childName: string)
	local v3 = v[childName]
	local parent = v3 and v3.Parent

	if parent and parent ~= others and parent.Parent == weapons and v3.Name == childName then
		return v3
	end

	v[childName] = nil

	for _, configuration in weapons:GetChildren() do
		if not (configuration ~= others and configuration:IsA("Configuration")) then
			continue
		end

		local folder = configuration:FindFirstChild(childName)

		if not (folder and folder:IsA("Folder")) then
			continue
		end

		v[childName] = folder
		return folder
	end
end

local function GetAnimationObject(p: string, childName: string)
	local animationFolder = GetAnimationFolder(p)

	if not animationFolder then
		return
	end

	local child = animationFolder:FindFirstChild(childName)

	if child then
		return child
	end

	local animationSet = animationFolder:GetAttribute("AnimationSet")

	if type(animationSet) ~= "string" then
		return
	end

	local folder = others:FindFirstChild(animationSet)

	if folder and folder:IsA("Folder") then
		return folder:FindFirstChild(childName)
	end
end

local function GetModelAnimationObject(p: string, childName: string)
	local folder = GetAnimationObject(p, "Model")

	if folder and folder:IsA("Folder") then
		return folder:FindFirstChild(childName)
	end
end

return table.freeze({
	GetWeaponAnimation = function(value: string, childName: string, flag: boolean?)
		if type(value) ~= "string" or type(childName) ~= "string" then
			return
		end

		local animation

		if flag then
			local folder = GetAnimationObject(value, "Model")

			if folder and folder:IsA("Folder") then
				animation = folder:FindFirstChild(childName)
			end
		else
			animation = GetAnimationObject(value, childName)
		end

		if animation and animation:IsA("Animation") then
			return animation
		end
	end,
	GetWeaponHitAnimation = function(value: string, value2: number, flag: boolean?)
		if type(value) ~= "string" or type(value2) ~= "number" or (value2 < 1 or value2 % 1 ~= 0) then
			return
		end

		local hits

		if flag then
			local folder = GetAnimationObject(value, "Model")

			if folder and folder:IsA("Folder") then
				hits = folder:FindFirstChild("Hits")
			end
		else
			hits = GetAnimationObject(value, "Hits")
		end

		if not (hits and hits:IsA("Folder")) then
			return
		end

		local animation = hits:FindFirstChild((tostring(value2)))

		if animation and animation:IsA("Animation") then
			return animation
		end
	end
})