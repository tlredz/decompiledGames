local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
require(script:FindFirstAncestor("Effects").Parent.Types)
local Space = {}
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Net)
local isJumpLTMServer = ServerData.IsJumpLTMServer()
local _ = script.Name
local maid = Trove.new()
local _ = workspace.CurrentCamera

function Space.OnStart(_)
	ReplicatedStorage:SetAttribute("Effect_Space", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("Effect_Space", nil)
	end)
	SoundController:UpdateOST()
	CycleController:Update()
	local maid2 = maid:Extend()
	local v = true
	maid:Add(function()
		v = false
	end)
	local v2 = nil

	local function runUpdate()
		local nyanCatsEvent = ReplicatedStorage:GetAttribute("NyanCatsEvent")
		local v3 = ServerData.IsTsunamiServer() and not isJumpLTMServer
		local nyanTsunami

		if v and not ReplicatedStorage:GetAttribute("EggrotHuntEvent") then
			if nyanCatsEvent then
				if v3 then
					nyanTsunami = script.NyanTsunami
				else
					nyanTsunami = script.Nyan
				end
			elseif v3 then
				nyanTsunami = script.SpaceTsunami
			else
				nyanTsunami = script.Space
			end
		end

		if nyanTsunami == v2 then
			return
		end

		v2 = nyanTsunami
		EffectController:Activate("Blink")
		SoundController:UpdateOST()
		CycleController:Update()
		maid2:Destroy()

		if nyanTsunami then
			local clone = maid2:Clone(nyanTsunami)
			clone.Parent = workspace

			if ServerData.IsBiggerServer() and not isJumpLTMServer then
				ClientEventUtils.resizeEffects(clone, 2)
			end

			clone.spacemeshbg.Transparency = 0

			for _, effect in clone:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = true
				end
			end

			if isJumpLTMServer then
				clone.spacemeshbg.Transparency = 1
				local spacebg = clone:FindFirstChild("spacebg")

				if spacebg and spacebg:IsA("BasePart") then
					JumpLTMWeather.StackToTrackTop(spacebg)
				end

				local trackTopY = JumpLTMWeather.GetTrackTopY()
				local spacerift = clone:FindFirstChild("spacerift")

				if trackTopY and spacerift and spacerift:IsA("BasePart") then
					local vector = Vector3.new(0, trackTopY - spacerift.Position.Y, 0)
					spacerift.CFrame += vector
					local spaceriftglaresky = clone:FindFirstChild("spaceriftglaresky")

					if spaceriftglaresky and spaceriftglaresky:IsA("BasePart") then
						spaceriftglaresky.CFrame += vector
					end
				end

				local model = Instance.new("Model")
				model.Name = "SpaceSheets"

				for _, v4 in clone:QueryDescendants("BasePart#spacefloorparticles"), nil, nil do
					v4.Parent = model
				end

				if model:FindFirstChildWhichIsA("BasePart") then
					maid2:Add(JumpLTMWeather.Cover(model))
				end

				model:Destroy()
			end
		end
	end

	maid:Add(ReplicatedStorage:GetAttributeChangedSignal("EggrotHuntEvent"):Connect(runUpdate))
	maid:Add(ReplicatedStorage:GetAttributeChangedSignal("NyanCatsEvent"):Connect(runUpdate))
	maid:Add(task.spawn(runUpdate))
	maid:Add(runUpdate)
end

function Space.OnStop(_)
	maid:Destroy()
end

function Space.OnLoad(_) end

return Space