local actor_utils = {
	
}

local function actor_utils.add_attri(actor, attri)
	actor.hp = actor.hp + attri.hp--体力值
    actor.mp = actor.mp + attri.mp--魔法值
   	actor.hprate = actor.hprate + attri.hprate --每秒回血
    actor.mprate = actor.mprate + attri.mprate --每秒回蓝
    actor.criticaldamage = actor.criticaldamage + attri.criticaldamage--暴击最高伤害
    actor.criticalrate = actor.criticalrate + attri.criticalrate--暴击概率
    actor.physicaldamage = actor.physicaldamage + attri.physicaldamage--物理伤害
    actor.spelldamage = actor.spelldamage + attri.spelldamage--魔法伤害
    actor.attactspeed = actor.attactspeed + attri.attactspeed--攻击速度
    actor.magicalresistance = actor.magicalresistance + attri.magicalresistance--魔法抗性
    actor.armor = actor.armor + attri.armor--护甲  
end

local function actor_utils.del_attri(actor, attri)
	actor.hp = actor.hp - attri.hp--体力值
    actor.mp = actor.mp - attri.mp--魔法值
   	actor.hprate = actor.hprate - attri.hprate --每秒回血
    actor.mprate = actor.mprate - attri.mprate --每秒回蓝
    actor.criticaldamage = actor.criticaldamage - attri.criticaldamage--暴击最高伤害
    actor.criticalrate = actor.criticalrate - attri.criticalrate--暴击概率
    actor.physicaldamage = actor.physicaldamage - attri.physicaldamage--物理伤害
    actor.spelldamage = actor.spelldamage - attri.spelldamage--魔法伤害
    actor.attactspeed = actor.attactspeed - attri.attactspeed--攻击速度
    actor.magicalresistance = actor.magicalresistance - attri.magicalresistance--魔法抗性
    actor.armor = actor.armor - attri.armor--护甲  
end