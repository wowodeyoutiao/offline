local buff_conf = require "buff_conf"
local buff {
	--[[
	hp = 0,--体力值
    mp = 0,--魔法值
    hprate = 0, --每秒回血
    mprate = 0, --每秒回蓝
    criticaldamage = 0,--暴击最高伤害
    criticalrate = 0,--暴击概率
    physicaldamage = 0,--物理伤害
    spelldamage = 0,--魔法伤害
    attactspeed = 0,--攻击速度
    magicalresistance = 0,--魔法抗性
    armor = 0,--护甲  
    time = 0--持续时间
	]]
}

local bufflist =  {}

local buff.new(buff1)
	if not buff1 then return nil end
	local t = {
	buff = buff1,--buff 
    starttime = 0,--开始时间
    actor = nil
    }
	setmetatable(t, buff)
	return t
end

local buff:start(time)
	self.starttime = time
end

local buff:check_bufftime(time)
	if self.starttime + self.buff.time >= time then
		return true
	else
		return false
	end
end

local buff:add_buff(actor)
	self.actor = actor
	actor.hp = actor.hp + self.buff.hp--体力值
    actor.mp = actor.mp + self.buff.mp--魔法值
   	actor.hprate = actor.hprate + self.buff.hprate --每秒回血
    actor.mprate = actor.mprate + self.buff.mprate --每秒回蓝
    actor.criticaldamage = actor.criticaldamage + self.buff.criticaldamage--暴击最高伤害
    actor.criticalrate = actor.criticalrate + self.buff.criticalrate--暴击概率
    actor.physicaldamage = actor.physicaldamage + self.buff.physicaldamage--物理伤害
    actor.spelldamage = actor.spelldamage + self.buff.spelldamage--魔法伤害
    actor.attactspeed = actor.attactspeed + self.buff.attactspeed--攻击速度
    actor.magicalresistance = actor.magicalresistance + self.buff.magicalresistance--魔法抗性
    actor.armor = actor.armor + self.buff.armor--护甲  
end

local buff:del_buff()
	local actor = self.actor
	actor.hp = actor.hp - self.buff.hp--体力值
    actor.mp = actor.mp - self.buff.mp--魔法值
   	actor.hprate = actor.hprate - self.buff.hprate --每秒回血
    actor.mprate = actor.mprate - self.buff.mprate --每秒回蓝
    actor.criticaldamage = actor.criticaldamage - self.buff.criticaldamage--暴击最高伤害
    actor.criticalrate = actor.criticalrate - self.buff.criticalrate--暴击概率
    actor.physicaldamage = actor.physicaldamage - self.buff.physicaldamage--物理伤害
    actor.spelldamage = actor.spelldamage - self.buff.spelldamage--魔法伤害
    actor.attactspeed = actor.attactspeed - self.buff.attactspeed--攻击速度
    actor.magicalresistance = actor.magicalresistance - self.buff.magicalresistance--魔法抗性
    actor.armor = actor.armor - self.buff.armor--护甲  
end

local buff.checkbufflist(time)
	for i, v in ipairs(bufflist) do
		if v:check_bufftime(time) then
			v:del_buff()
			v = nil
		end
	end	
end

return buff


