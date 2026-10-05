local CollectionService = game:GetService("CollectionService")
local flag = false
local reoptimize
local wait2 = task.wait
local clock = os.clock
local now = clock()
local v = false
script.Parent:BindToMessage("Optimize", function(p)
	if p then
		local Global = require(game.ReplicatedStorage.Global)
		Global.FastMode = true

		if not v then
			v = true
			workspace.Map.DescendantAdded:ConnectParallel(function(part)
				if part:IsA("BasePart") then
					task.synchronize()
					part.Material = "SmoothPlastic"
				end
			end)
		end
	end

	reoptimize(CollectionService:GetTagged("Optimized2"))

	if flag then
		return
	end

	flag = true

	for _, v2 in pairs(CollectionService:GetTagged("Emitters")) do
		local emitCount = v2:GetAttribute("EmitCount")

		if emitCount then
			v2:SetAttribute("EmitCount", (math.ceil(emitCount * 0.5)))
		end

		if not (clock() - now > 0.016666666666666666) then
			continue
		end

		wait2()
		wait2()
		now = clock()
	end
end)
script.Parent:BindToMessageParallel("SetParent", function(p, parent)
	task.synchronize()
	pcall(function()
		p.Parent = parent
	end)
end)

repeat
	wait(0.1)
until game.Players.LocalPlayer:FindFirstChild("DataLoaded")

wait(1)
task.spawn(function()
	local sky = game.Lighting:FindFirstChildWhichIsA("Sky")

	if not sky then
		repeat
			sky = game.Lighting:FindFirstChildWhichIsA("Sky")
			wait(1)
		until sky
	end

	for k in pairs({
		SkyboxBk = true,
		SkyboxDn = true,
		SkyboxFt = true,
		SkyboxLf = true,
		SkyboxRt = true,
		SkyboxUp = true
	}) do
		sky[k] = sky:GetAttribute(k .. "_Proxy")
	end
end)
local Graphics = require(game.ReplicatedStorage.Util.Graphics)
local v2 = {
	ParticleEmitter = "Texture",
	Trail = "Texture",
	Decal = "Texture",
	Texture = "Texture",
	MeshPart = "TextureID",
	SpecialMesh = "TextureId"
}
tick()
local _ = Graphics.SmartScale
local scaleDown = Graphics.ScaleDown
local tagged = CollectionService:GetTagged("Optimized2")
local getAttribute = workspace.GetAttribute

local function fixupParticle(instance, proxyTexture)
	if instance.ClassName ~= "ParticleEmitter" then
		return
	end

	if instance.FlipbookLayout == Enum.ParticleFlipbookLayout.None then
		instance:SetAttribute("ProxyTexture", scaleDown(proxyTexture))
	else
		instance:SetAttribute("ProxyTexture", proxyTexture)
	end

	if instance.Enabled then
		instance.Enabled = false
		task.delay(0.1, function()
			instance.Enabled = true
		end)
	end

	return true
end

CollectionService:GetInstanceAddedSignal("Optimized2"):Connect(function(instance)
	local v3 = v2[instance.ClassName]

	if v3 then
		if typeof(v3) == "table" then
			for _, v4 in pairs(v3) do
				local attribute = getAttribute(instance, "Proxy" .. v4)
				instance:SetAttribute("Proxy" .. v4, scaleDown(attribute))

				if fixupParticle(instance, attribute) then
					return
				end
			end
		else
			local attribute = getAttribute(instance, "Proxy" .. v3)

			if fixupParticle(instance, attribute) then
				return
			else
				instance:SetAttribute("Proxy" .. v3, scaleDown(attribute))
			end
		end
	end
end)

reoptimize = function(tagged2)
	for _, item in pairs(tagged2) do
		local v3 = v2[item.ClassName]

		if v3 then
			if typeof(v3) == "table" then
				for _, v4 in pairs(v3) do
					item:SetAttribute("Proxy" .. v3, scaleDown(getAttribute(item, "Proxy" .. v4)))
					fixupParticle(item, getAttribute(item, "Proxy" .. v4))
				end
			elseif fixupParticle(item, getAttribute(item, "Proxy" .. v3)) then
				continue
			else
				item:SetAttribute("Proxy" .. v3, scaleDown(getAttribute(item, "Proxy" .. v3)))
			end
		end

		if not (clock() - now > 0.016666666666666666) then
			continue
		end

		wait2()
		wait2()
		now = clock()
	end
end

reoptimize(tagged)
table.clear(tagged)
local UserInputService = game:GetService("UserInputService")

if UserInputService.MouseEnabled == false then
	local GuiService = game:GetService("GuiService")

	if GuiService:IsTenFootInterface() == false then
		task.spawn(function()
			script.Parent:SendMessage("Optimize")
		end)
	end
end