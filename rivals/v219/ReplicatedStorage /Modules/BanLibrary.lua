local BanLibrary = {}
BanLibrary.UNBANNED_TOKEN = "Unbanned"
BanLibrary.PERMANENT_BAN_DURATION = 999999999

function BanLibrary:IsBanLogANote(p)
	return p.IsNote
end

function BanLibrary:IsBanLogABan(p)
	return not self:IsBanLogANote(p) and p.Reason ~= self.UNBANNED_TOKEN
end

function BanLibrary:IsBanLogAnActiveBan(p)
	return self:IsBanLogABan(p) and p.EndTime and os.time() < p.EndTime
end

function BanLibrary:IsBanLogAWarning(p)
	return self:IsBanLogANote(p) and p.Reason and string.sub(p.Reason, 1, 9) == "Warned - "
end

function BanLibrary:IsBanned(p)
	for _, v in pairs(p.BanHistory) do
		if self:IsBanLogANote(v) then
			continue
		end

		if self:IsBanLogAnActiveBan(v) then
			return v
		else
			break
		end
	end

	return nil
end

return BanLibrary