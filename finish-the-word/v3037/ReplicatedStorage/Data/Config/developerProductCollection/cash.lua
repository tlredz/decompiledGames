local import = _G.import("iterator")
_G.import("rewardData")
return import.mapArr({
	p3601069119 = "Cash800",
	p3596878075 = "Cash2000",
	p3596878436 = "Cash5000",
	p3596878448 = "Cash15000",
	p3601066646 = "Cash25000",
	p3599608851 = "SecretKey",
	p3599608848 = "SecretKey10",
	p3601067833 = "SecretKey50",
	p3598839294 = "TimeBoost",
	p3598839604 = "TimeBoost10",
	p3598840201 = "TimeBoost80"
}, function(p, p2)
	return p, {
		Server = function(_, _, object, object2)
			object:auto_repl(true)
			object2:auto_repl(true)
			object2:award(p2)
			object:auto_repl(false)
			object2:auto_repl(false)
			return true
		end
	}
end)