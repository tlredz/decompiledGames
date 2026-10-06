local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local uDim = UDim2.fromScale(0, 0)
local Card = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsSettled(p)
	local sizeSpring = p.Scope.peek(p.SizeSpring)
	return math.abs(sizeSpring.X.Scale) + math.abs(sizeSpring.Y.Scale) < 0.001
end

function Card:Attach(p: string, p2: number, value: number?)
	local instance = (p == "Drop" or p == "Gamemode") and self.Instance or self.Instance.Main
	local scope = fusion.scoped(fusion)
	self.Scope = scope
	self.Size = scope:Value(uDim)
	self.SizeSpring = scope:Spring(self.Size, 10, 1)
	self.TargetSize = instance.Size
	scope:Hydrate(instance)({
		Size = self.SizeSpring
	})
	table.insert(scope, self.Instance.Destroying:Connect(function()
		Card.Destroy(self)
	end))
	table.insert(scope, module.Services.RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if self.Suspended then
			if not self.Hidden and (IsSettled(self) or now - self.Suspended >= 1.5) then
				self.Hidden = true
				self.Instance.Visible = false

				if self.OnHidden then
					self.OnHidden()
				end
			end
		elseif self.Closing then
			if IsSettled(self) or now - self.Closing >= 1.5 then
				Card.Destroy(self)
			end
		elseif self.ExpiresAt <= now then
			Card.Close(self)
		elseif self.StartsAt and self.StartsAt <= now then
			self.StartsAt = nil
			self.Size:set(self.TargetSize)
			local v = p == "Drop" and "Default" or "Info"
			module.Sound:PlayEffect("Notifications." .. v, {
				Group = "Notifications",
				Cooldown = 0.1
			})
		end
	end))
	self.StartsAt = os.clock() + (value or 0)
	self.ExpiresAt = self.StartsAt + p2
	module.NotificationList.Add(self.Instance, p)
end

function Card:Refresh(p: number)
	if self.Destroyed or self.Suspended then
		return
	end

	self.ExpiresAt = os.clock() + p

	if self.Closing then
		self.Closing = nil
		self.StartsAt = nil
		self.Size:set(self.TargetSize)
	end
end

function Card:Close()
	if self.Destroyed or self.Closing then
		return
	end

	self.Closing = os.clock()
	self.StartsAt = nil
	self.Size:set(uDim)
end

function Card:Suspend()
	if self.Destroyed or self.Closing or self.Suspended then
		return
	end

	self.Suspended = os.clock()
	self.StartsAt = nil
	self.Size:set(uDim)
end

function Card:Resume(p: number, value: number?)
	if self.Destroyed or not self.Suspended then
		return
	end

	self.StartsAt = os.clock() + (value or 0)
	self.ExpiresAt = self.StartsAt + p
	self.Suspended = nil

	if not self.Hidden then
		return
	end

	self.Hidden = nil
	self.Instance.Visible = true

	if self.OnShown then
		task.spawn(self.OnShown)
	end
end

function Card:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true

	if self.OnCleanup then
		self.OnCleanup()
	end

	if self.Scope then
		self.Scope:doCleanup()
	end

	if self.Instance then
		module.NotificationList.Remove(self.Instance)
		self.Instance:Destroy()
	end

	if self.OnDestroyed then
		self.OnDestroyed()
	end
end

return Card