local MonsterFreeze = {}
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})

local function bumpFreezeGeneration(instance)
	local v = (object[instance] or 0) + 1
	object[instance] = v

	if not object2[instance] then
		object2[instance] = instance.AncestryChanged:Connect(function(_, parent)
			if not parent then
				object[instance] = nil
				local connection = object2[instance]
				object2[instance] = nil

				if connection then
					connection:Disconnect()
				end
			end
		end)
	end

	return v
end

local v = nil

local function getAIModule()
	if v then
		return v
	end

	local success, result = pcall(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		return require(ReplicatedStorage.Forbidden:FindFirstChild("AINew"))
	end)

	if success and result then
		v = result
	end

	return v
end

function MonsterFreeze.Freeze(folder)
	if not (folder and folder.Parent) then
		return nil
	end

	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		warn("[MonsterFreeze] No HumanoidRootPart on", folder.Name)
		return nil
	end

	local humanoid = folder:FindFirstChild("Humanoid")
	local v2 = {
		character = folder,
		hrp = humanoidRootPart,
		humanoid = humanoid,
		disabledScripts = {},
		wasAutoRotate = not humanoid or (humanoid.AutoRotate or true),
		wasWalkSpeed = not humanoid and 16 or humanoid.WalkSpeed or 16
	}
	pcall(function()
		humanoidRootPart:SetNetworkOwner(nil)
	end)

	if not v then
		local success, result = pcall(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			return require(ReplicatedStorage.Forbidden:FindFirstChild("AINew"))
		end)

		if success and result then
			v = result
		end
	end

	local v3 = v

	if v3 and v3.Stop then
		v3.Stop(folder)
	end

	if humanoid then
		humanoid.WalkSpeed = 0
	end

	task.wait()

	if humanoid and humanoidRootPart and humanoidRootPart.Parent then
		humanoid:MoveTo(humanoidRootPart.Position)
	end

	task.wait()

	if humanoid then
		humanoid.AutoRotate = false
	end

	v2.previousChaseState = folder:GetAttribute("ChaseState")
	folder:SetAttribute("ChaseState", nil)

	for _, script in ipairs(folder:GetDescendants()) do
		if not (script:IsA("Script") or script:IsA("LocalScript")) or script.Disabled then
			continue
		end

		local name = script.Name:lower()

		if not (name == "animate" or name == "playanimation" or name == "animationscript" or name:find("animation")) then
			continue
		end

		script.Disabled = true
		table.insert(v2.disabledScripts, script)
		print("[MonsterFreeze] Disabled script:", script.Name, script.ClassName)
	end

	if humanoid then
		local animator = humanoid:FindFirstChild("Animator")

		if animator then
			for _, v4 in ipairs(animator:GetPlayingAnimationTracks()) do
				v4:Stop(0)
			end
		end
	end

	folder:SetAttribute("_MonsterAbilityFrozen", true)
	folder:SetAttribute("_MonsterAbilityFrozenAt", os.clock())
	local v4 = (object[folder] or 0) + 1
	object[folder] = v4

	if not object2[folder] then
		object2[folder] = folder.AncestryChanged:Connect(function(_, parent)
			if not parent then
				object[folder] = nil
				local connection = object2[folder]
				object2[folder] = nil

				if connection then
					connection:Disconnect()
				end
			end
		end)
	end

	task.delay(30, function()
		if not (object[folder] == v4 and (folder and folder.Parent) and folder:GetAttribute("_MonsterAbilityFrozen") == true) then
			return
		end

		warn("[MonsterFreeze] safety unfreeze (30s) — ability never released:", folder.Name)
		MonsterFreeze.Unfreeze(v2)
	end)
	print("[MonsterFreeze] Frozen:", folder.Name, "at", (tostring(humanoidRootPart.Position)))
	return v2
end

function MonsterFreeze.FaceTarget(p, p2)
	if not p then
		return
	end

	local hrp = p.hrp

	if not (hrp and hrp.Parent and p2) then
		return
	end

	local vector = Vector3.new(p2.X - hrp.Position.X, 0, p2.Z - hrp.Position.Z)

	if vector.Magnitude < 0.5 then
		return
	end

	hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + vector)
end

function MonsterFreeze:Unfreeze()
	if not self then
		return
	end

	local character = self.character

	if character and character.Parent then
		character:SetAttribute("_MonsterAbilityFrozen", nil)
		character:SetAttribute("_MonsterAbilityFrozenAt", nil)
	end

	for _, disabledScript in ipairs(self.disabledScripts) do
		if disabledScript and disabledScript.Parent then
			disabledScript.Disabled = false
		end
	end

	self.disabledScripts = {}

	if self.humanoid and self.humanoid.Parent then
		self.humanoid.WalkSpeed = self.wasWalkSpeed
	end

	if self.humanoid and self.humanoid.Parent then
		self.humanoid.AutoRotate = self.wasAutoRotate
	end

	if character and character.Parent then
		character:SetAttribute("ChaseState", self.previousChaseState or "idle")
	end

	print("[MonsterFreeze] Unfrozen:", character and character.Name or "?")
end

function MonsterFreeze.IsFrozen(instance)
	if instance then
		return instance:GetAttribute("_MonsterAbilityFrozen") == true
	end

	return false
end

return MonsterFreeze