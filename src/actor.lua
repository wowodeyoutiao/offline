local buff = require "buff"

local actor = {
    --[[
    level = 0;
    currentexperience = 0;
    maxexperience = 0;
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
    buff = {},
    skills = {},--技能
    bag = {},--包裹
    equipments = {},--装备
    ]]
}

actor.__index = actor

function actor.new()
    local t = {}
    t.name = 'anmeng'
    t.level = 0
    t.currentexperience = 0
    t.maxexperience = 0
    t.hp = 0--体力值
    t.mp = 0--魔法值
    t.hprate = 0 --每秒回血
    t.mprate = 0 --每秒回蓝
    t.criticaldamage = 0--暴击最高伤害
    t.criticalrate = 0--暴击概率
    t.physicaldamage = 0--物理伤害
    t.spelldamage = 0--魔法伤害
    t.attactspeed = 0--攻击速度
    t.magicalresistance = 0--魔法抗性
    t.armor = 0--护甲
    t.buff = {}
    t.skills = {}--技能
    t.bag = {}--包裹
    t.equipments = {}--装备
    t.death = false
    setmetatable({attri = t}, actor)
    return t
end

function actor:clone(cloner)
    if cloner then
        game_utils.copy_attri(cloner.attri, self.attri, true)
    else
        local t = {}
        game_utils.copy_attri(t.attri, self.attri, true)
        return t
    end
end

function actor:isalive()
    return self.attri.hp > 0
end

function actor:getphysicaldamage()
    local damage = 0
    damage = self.attri.physicaldamage
    local rate = math.random()
    if rate < self.attri.criticalrate then
        damage = damage + damage * self.attri.criticaldamage * rate 
        return true, damage
    end
    return false, damage
end

function actor:beingphysicalattack(damage)
    damage = damge - self.attri.armor
    self.attri.hp = self.attri.hp - damage
    return damage
end

function actor:getspelldamage()
    return self.attri.spelldamage
end

function actor:beingspelldamage(damage)
    damage = damage - self.attri.magicalresistance
    self.attri.hp = self.attri.hp - damage
    return damage
end

function actor:add_buff(buff)
    buff:start()
    buff:add_actor(self)
    table.insert(self.buff, buff)
end

function actor:check_buff(time)
    for i, v in ipairs(self.buff) do
        if v:check_bufftime(time) then
            v:del_buff()
            v = nil
        end
    end 
end 

function actor:add_equipment(equipment)
    equipment:add_attri(self)
    self.equipments[equipment.position] = equipment
end

function actor:del_equipment(equipment)
    equipment.del_attri(self)
    self.equipments[equipment.position] = nil
end

function actor:add_skill(skill)
    table.insert(self.skill, skill)
end

function actor:del_skill(skill)
    for i,v in ipairs(self.skill) do
        if v == skill then table.remove(self.skill, i) end
    end
end

return actor




