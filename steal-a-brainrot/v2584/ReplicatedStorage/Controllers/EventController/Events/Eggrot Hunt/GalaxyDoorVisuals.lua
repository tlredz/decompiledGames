local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local TweenPivot = require(ReplicatedStorage.Shared.TweenPivot)
local Trove = require(ReplicatedStorage.Packages.Trove)
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local color = Color3.fromRGB(0, 255, 0)
local color2 = Color3.fromRGB(255, 255, 255)
return table.freeze({
	Start = function(_)
		local maid = Trove.new()
		maid:Add(Observers.observeTag("EggrotGalaxyDoor", function(model)
			if not model:IsA("Model") then
				return nil
			end

			local maid2 = Trove.new()
			local pivot = model:GetPivot()
			local v = pivot - Vector3.new(0, model:GetExtentsSize().Y * 1.5, 0)
			local v2 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function animateTo(cframe: CFrame)
				local v3 = v2

				if v3 then
					v3:Cancel()
				end

				local tweenPivot = TweenPivot(model, tweenInfo, cframe)
				v2 = tweenPivot
				tweenPivot:Play()
			end

			local function onChanged()
				local v3

				if model:GetAttribute("GalaxyDoorOpen") == true then
					v3 = v
				else
					v3 = pivot
				end

				animateTo(v3) -- equivalent call inferred; original call site unknown
			end

			if model:GetAttribute("GalaxyDoorOpen") == true then
				model:PivotTo(v)
			end

			maid2:Add(model:GetAttributeChangedSignal("GalaxyDoorOpen"):Connect(onChanged))
			return function()
				local v3 = v2

				if v3 then
					v3:Cancel()
				end

				model:PivotTo(pivot)
				maid2:Destroy()
			end
		end, { workspace }))
		maid:Add(Observers.observeTag("EggrotGalaxyNeon", function(part)
			if not part:IsA("BasePart") then
				return nil
			end

			local maid2 = Trove.new()
			local v = nil

			local function onChanged()
				local v2 = v

				if v2 then
					v2:Cancel()
				end

				local color3

				if part:GetAttribute("GalaxyPadOccupied") == true then
					color3 = color
				else
					color3 = color2
				end

				local tween = TweenService:Create(part, tweenInfo2, {
					Color = color3
				})
				v = tween
				tween:Play()
			end

			local color4

			if part:GetAttribute("GalaxyPadOccupied") == true then
				color4 = color
			else
				color4 = color2
			end

			part.Color = color4
			maid2:Add(part:GetAttributeChangedSignal("GalaxyPadOccupied"):Connect(onChanged))
			return function()
				local v3 = v

				if v3 then
					v3:Cancel()
				end

				part.Color = color2
				maid2:Destroy()
			end
		end, { workspace }))
		return function()
			maid:Destroy()
		end
	end
})