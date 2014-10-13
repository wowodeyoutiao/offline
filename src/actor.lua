local buff = require "buff"

local actor {
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
    equipment = {},--装备
}

local function actor:getphysicaldamage()
    local damage = 0
    damage = self.physicaldamage
    local rate = math.random()
    if rate < self.criticalrate then
        damage =damage + damage * self.criticaldamage * rate 
    end
    return damage
end 
local function actor:beingphysicalattack(damage)
    damage = damge - self.armor
    self.hp = self.hp - damage
end

local function actor:getspelldamage()
    return self.spelldamage
end

local function actor:beingspelldamage(damage)
    damage = damage - self.magicalresistance
    self.hp = self.hp - damage
end

local function actor:add_buff(buff)
    buff:start()
    buff:add_actor(self)
    table.insert(self.buff, buff)

end

local function actor:check_buff(time)
    for i, v in ipairs(self.buff) do
        if v:check_bufftime(time) then
            v:del_buff()
            v = nil
        end
    end 
end 

local function actor:add_equipment(equipment)
    equipment:add_actor(self)
    table.insert(self.equipment, equipment)
end

local function actor:del_equipment(equipment)
    table
end

local function actor:add_skill(skill)
end

local function actor:del_skill(skill)
end




