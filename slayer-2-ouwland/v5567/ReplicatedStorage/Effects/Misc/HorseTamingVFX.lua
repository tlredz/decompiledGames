local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local nays = script:FindFirstChild("Nays")

-- equivalent calls inferred from this helper; original call sites unknown
local function tamingFolderName(p: string)
	return (`HorseTaming-{p}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(parent)
	local raycastResult = workspace:Raycast(
		parent.Position + createVector(0, 3, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local function stopTaming(p: string, instance)
	local dustRaycast = instance and instance:FindFirstChild("DustRaycast")

	if dustRaycast then
		dustRaycast.Name = "--"
		Ouwmit.Enable(dustRaycast, false)
		DebrisModule:AddItem(dustRaycast, 1.3)
	end

	local pS2horsetameSTRUGGLEloop = instance and instance:FindFirstChild("PS2horsetameSTRUGGLEloop")

	if pS2horsetameSTRUGGLEloop then
		pS2horsetameSTRUGGLEloop:Stop()
		pS2horsetameSTRUGGLEloop:Destroy()
	end

	local child = workspace.Debree:FindFirstChild((`HorseTaming-{p}`))

	if child then
		child.Name = "--"
		Ouwmit.Enable(child, false)
		DebrisModule:AddItem(child, 1.3)
	end
end

local function startTaming(p: string, humanoidRootPart, p2)
	stopTaming(p, humanoidRootPart)
	local name = tamingFolderName(p) -- equivalent call inferred; original call site unknown
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = workspace.Debree
	DebrisModule:AddItem(folder, 30)
	local clone = script.DustRaycast:Clone()
	clone.Parent = humanoidRootPart
	Ouwmit.Enable(clone, true, Ouwmit.Owned(p2, groundDust(humanoidRootPart)))
	DebrisModule:AddItem(clone, 30)
	local v2 = vfxUtility.PlaySound(script, "PS2horsetameSTRUGGLEloop", humanoidRootPart)

	if v2 then
		v2.Looped = true
		DebrisModule:AddItem(v2, 30)
	end

	local v3 = assets and vfxUtility.cloneAsset(assets, folder, "Taming", humanoidRootPart.CFrame)
	local v4 = not nays and {} or nays:GetChildren()
	task.spawn(function()
		local v5 = nil

		while folder.Name == name and folder.Parent ~= nil and humanoidRootPart.Parent ~= nil do
			if v3 then
				v3:PivotTo(humanoidRootPart.CFrame)
				Ouwmit.Emit(v3, Ouwmit.Owned(p2))
			end

			if #v4 > 0 and (v5 == nil or not v5.IsPlaying) then
				v5 = vfxUtility.PlaySound(nays, v4[math.random(#v4)].Name, humanoidRootPart, true)
			end

			task.wait(0.5)
		end

		if folder.Name == name then
			stopTaming(p, humanoidRootPart)
		end
	end)
end

return function(p, instance, p2: string?, p3: string, flag: boolean?)
	if instance == nil and p2 ~= nil then
		instance = workspace.Debree:QueryDescendants((`Model[$UniqueName="{p2}"]`))[1]
	end

	local humanoidRootPart = instance and (instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart)

	if p3 == "Taming" then
		if p2 == nil then
			return
		end

		if flag == true then
			if humanoidRootPart then
				startTaming(p2, humanoidRootPart, p)
			end
		else
			stopTaming(p2, humanoidRootPart)
		end
	else
		if humanoidRootPart == nil then
			return
		end

		local v = assets and vfxUtility.cloneAsset(assets, workspace.Debree, p3, humanoidRootPart.CFrame, 4)

		if v then
			Ouwmit.Emit(v, Ouwmit.Owned(p))
		end

		if sounds then
			vfxUtility.PlaySound(sounds, p3, humanoidRootPart, true)
		end
	end
end