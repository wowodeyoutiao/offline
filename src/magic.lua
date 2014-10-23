local magic = {}
local magic_conf = require "magic_conf"

function magic.new(name)
	local tmagic = magic_conf[name]
	if tmagic then
		local t = setmetatable({}, magic)
		for k,v in pairs(tmagic) do
			t[k] = v
		end
		return t
	end
	return nil
end

function magic:spell()
	return self.damage(self, self.level)
end

return magic