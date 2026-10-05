game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local assets = require(ReplicatedStorage.shared.utils.assets)
local InventoryController = require(ReplicatedStorage.client.legacyControllers.InventoryController)
local emit = require(ReplicatedStorage.packages.emit)
local v = {
	["Noxious Catalyst"] = true,
	["Prototype Noxious Catalyst"] = true,
	["Awakening Serum"] = true,
	["Disturbance Catalyst"] = true,
	["Empowered Disturbance Catalyst"] = true
}
local remoteFunction = Net:RemoteFunction("Throwable/Throw", -1)
local remoteEvent = Net:RemoteEvent("Throwable/ThrowAnim", -1)
local ThrowableController = {
	ToolTrove = Trove.new(),
	IsThrowing = false
}

local function playVfx(instance)
	emit.emit(instance)

	for _, sound in instance:GetChildren() do
		if sound:IsA("Sound") then
			sound:Play()
		end
	end
end

function ThrowableController:ToolEquipped(p)
	ThrowableController.ToolTrove:Connect(p.Activated, function()
		if ThrowableController.IsThrowing then
			return
		end

		local mouse = localPlayer:GetMouse()
		task.spawn(function()
			local async = assets.getAsync("item", p.Name)

			if async then
				ContentProvider:PreloadAsync({ async })
			end
		end)
		ThrowableController.IsThrowing = true
		local _, v2 = remoteFunction:InvokeServer(mouse.Hit.Position)

		if v2 then
			ReplicatedStorage.events.anno_localthought:Fire(v2)
		end

		task.wait(1)
		ThrowableController.IsThrowing = false
	end)
end

function ThrowableController:AnimateThrow(childName: string, cframe: CFrame, worldCFrame: CFrame)
	local async = assets.getAsync("item", childName)

	if not async then
		return
	end

	ContentProvider:PreloadAsync({ async })
	local throwableFx = async:FindFirstChild("ThrowableFx")
	local explode = throwableFx and throwableFx:FindFirstChild("Explode")
	local throw = throwableFx and throwableFx:FindFirstChild("Throw")
	local child = async:FindFirstChild(childName)

	if not child then
		return
	end

	local clone = child:Clone()
	clone:PivotTo(cframe)

	if throw then
		throw = throw:Clone()
		throw.Parent = clone.PrimaryPart
	end

	clone.Parent = workspace.active
	local lastTime = tick()

	if throw then
		playVfx(throw)
	end

	local random = Random.new()
	local number = random:NextNumber(-3, 3)
	local number2 = random:NextNumber(-3, 3)
	local number3 = random:NextNumber(-3, 3)

	while tick() - lastTime < 1 do
		local v2 = tick() - lastTime
		clone:PivotTo(cframe:Lerp(worldCFrame, v2) * CFrame.fromOrientation(v2 * number, v2 * number2, v2 * number3) + Vector3.new(
			0,
			(-4 * (v2 - 0.5) ^ 2 + 1) * 10,
			0
		))
		RunService.RenderStepped:Wait()
	end

	clone:Destroy()

	if explode then
		local clone2 = explode:Clone()
		clone2.Parent = workspace.active
		clone2.WorldCFrame = worldCFrame
		playVfx(clone2)
		task.wait(clone2:GetAttribute("Lifetime") or 5)
		clone2:Destroy()
	end
end

function ThrowableController.Start(_)
	InventoryController.EquippedToolChanged:Connect(function(p)
		ThrowableController.ToolTrove:Clean()

		if p and v[p.Name] then
			ThrowableController:ToolEquipped(p)
		end
	end)
	remoteEvent.OnClientEvent:Connect(function(...)
		ThrowableController:AnimateThrow(...)
	end)
end

return ThrowableController