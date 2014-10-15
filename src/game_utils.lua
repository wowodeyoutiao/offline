local game_utils = {
	
}

function game_utils.add_attri(actor, attri)
	if attri.hp then actor.hp = actor.hp + attri.hp end--体力值
    if attri.mp then actor.mp = actor.mp + attri.mp end--魔法值
   	if attri.hprate then actor.hprate = actor.hprate + attri.hprate end --每秒回血
    if attri.mprate then actor.mprate = actor.mprate + attri.mprate end --每秒回蓝
    if attri.criticaldamage then actor.criticaldamage = actor.criticaldamage + attri.criticaldamage end--暴击最高伤害
    if attri.criticalrate then actor.criticalrate = actor.criticalrate + attri.criticalrate end--暴击概率
    if attri.physicaldamage then actor.physicaldamage = actor.physicaldamage + attri.physicaldamage end--物理伤害
    if attri.spelldamage then actor.spelldamage = actor.spelldamage + attri.spelldamage end--魔法伤害
    if attri.attactspeed then actor.attactspeed = actor.attactspeed + attri.attactspeed end--攻击速度
    if attri.magicalresistance then actor.magicalresistance = actor.magicalresistance + attri.magicalresistance end--魔法抗性
    if attri.armor then actor.armor = actor.armor + attri.armor end--护甲  
end

function game_utils.del_attri(actor, attri)
	if attri.hp then actor.hp = actor.hp - attri.hp end--体力值
    if attri.mp then actor.mp = actor.mp - attri.mp end--魔法值
   	if attri.hprate then actor.hprate = actor.hprate - attri.hprate end --每秒回血
    if attri.mprate then actor.mprate = actor.mprate - attri.mprate end --每秒回蓝
    if attri.criticaldamage then actor.criticaldamage = actor.criticaldamage - attri.criticaldamage end--暴击最高伤害
    if attri.criticalrate then actor.criticalrate = actor.criticalrate - attri.criticalrate end--暴击概率
    if attri.physicaldamage then actor.physicaldamage = actor.physicaldamage - attri.physicaldamage end--物理伤害
    if attri.spelldamage then actor.spelldamage = actor.spelldamage - attri.spelldamage end--魔法伤害
    if attri.attactspeed then actor.attactspeed = actor.attactspeed - attri.attactspeed end--攻击速度
    if attri.magicalresistance then actor.magicalresistance = actor.magicalresistance - attri.magicalresistance end--魔法抗性
    if attri.armor then actor.armor = actor.armor - attri.armor end--护甲  
end

function game_utils.copy_attri(di, si)
	if si.level then di.level = si.level end--级别
    if si.hp then di.hp = si.hp end--体力值
    if si.mp then di.mp = si.mp end--魔法值
    if si.hprate then di.hprate = si.hprate end --每秒回血
    if si.mprate then di.mprate = si.mprate end --每秒回蓝
    if si.criticaldamage then di.criticaldamage = si.criticaldamage end--暴击最高伤害
    if si.criticalrate then di.criticalrate = si.criticalrate end--暴击概率
    if si.physicaldamage then di.physicaldamage = si.physicaldamage end--物理伤害
    if si.spelldamage then di.spelldamage = si.spelldamage end--魔法伤害
    if si.attactspeed then di.attactspeed = si.attactspeed end--攻击速度
    if si.magicalresistance then di.magicalresistance = si.magicalresistance end--魔法抗性
    if si.armor then di.armor = si.armor end--护甲  
end

return game_utils