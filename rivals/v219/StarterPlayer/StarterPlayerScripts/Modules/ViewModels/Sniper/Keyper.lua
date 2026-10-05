local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local Sniper = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels:WaitForChild("Sniper"))
local object = setmetatable({}, Sniper)
object.__index = object

function object.new(...)
	local self = setmetatable(Sniper.new(...), object)
	self.BulletTrail = self.ItemModel:WaitForChild("Bullet"):WaitForChild("MeshPart"):WaitForChild("TrailA0"):WaitForChild("Trail")
	self:_Init()
	return self
end

function object.CustomTracers(object2, p, _)
	local wrap = object2:GetWrap()

	local function play()
		local muzzlePosition = object2:GetMuzzlePosition()

		if not muzzlePosition then
			return
		end

		local v = muzzlePosition + workspace.CurrentCamera.CFrame.RightVector * 0.1

		for _, raycastResult in pairs(p.RaycastResults) do
			local startPosition = raycastResult.StartPosition or v
			local magnitude = (startPosition - raycastResult.Position).Magnitude
			local part = Instance.new("Part")
			part.CastShadow = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Anchored = true
			part.Color = Color3.fromRGB(255, 176, 112)
			part:SetAttribute("IgnoreTransparency", true)
			part:AddTag("Wrappable")
			part:SetAttribute("WrapGroup", 3)
			part.Parent = workspace
			BetterDebris:AddItem(part, 10)
			WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(part), wrap)
			part.Material = Enum.Material.Neon
			part.MaterialVariant = ""
			local v4 = raycastResult
			task.spawn(function()
				Utility:RenderstepForLoop(0, 100, 2, function(p2)
					local v6 = p2 / 100
					local v7 = (1 - v6) ^ 4
					local v8 = 1 - v6 ^ 4
					part.Size = Vector3.new(0.01 + 1 * v7, 0.01 + 1 * v7, magnitude * v8 - 5)
					part.CFrame = CFrame.new(v4.Position, startPosition) * CFrame.new(0, 0, -part.Size.Z / 2)
				end)
				part:Destroy()
			end)
		end
	end

	if object2.ClientItem:Get("IsAiming") then
		object2.ClientItem:GetDataChangedSignal("IsAiming"):ConnectOnce(function()
			task.delay(0.06, task.defer, play)
		end)
	else
		play()
	end
end

function object:_UpdateBulletTrail()
	self.BulletTrail.Enabled = self:IsAnimationPlaying("Shoot1") or self:IsAnimationPlaying("EmptyReload")
end

function object:_Init()
	self.AnimationPlayed:Connect(function(p)
		if p == "Shoot1" or p == "EmptyReload" then
			self:_UpdateBulletTrail()
		end
	end)
	self.AnimationStopped:Connect(function(p)
		if p == "Shoot1" or p == "EmptyReload" then
			self:_UpdateBulletTrail()
		end
	end)
	self:_UpdateBulletTrail()
end

return object