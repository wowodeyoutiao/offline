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

local function actor:add_buff(buff)

end

