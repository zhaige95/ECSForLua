require("Core.functions")

require("ECS.Framework.Context")

require("ECS.Generated.GameContext")

Context:Init()

local group = Context:GetGroup(NewMatcher():AllOf(EMatcher.Test):NoneOf(EMatcher.Move))
local group2 = Context:GetGroup(NewMatcher():AllOf(1, 2))

local e = Context:CreateEntity()
e:AddTest("new  test", { 523 })

print("-------------------")
for key, value in pairs(group:GetEntities()) do
    print("group1  a", key)
end
for key, value in pairs(group2:GetEntities()) do
    print("group2  a", key)
end

local move = Context:CreateEntity()
move:AddMove(10)
move:AddTest("move  test", { 1995 })

print("-------------------")
for key, value in pairs(group:GetEntities()) do
    print("group1  b", key)
end
for key, value in pairs(group2:GetEntities()) do
    print("group2  b", key)
end

e:Destroy()

print("-------------------")
for key, value in pairs(group:GetEntities()) do
    print("group1  c", key)
end
for key, value in pairs(group2:GetEntities()) do
    print("group2  c", key)
end




















-- 键值碰撞测试

-- local random = math.random
-- local a = 0
-- local b = 0

-- local trueTime = 0
-- local falseTime = 0
-- for j = 1, 30000 do
--     a = 0
--     b = 0

--     for i = 1, 10, 1 do
--         a = a + random(100)
--     end

--     for i = 1, 10, 1 do
--         b = b + random(100)
--     end
--     if a == b then
--         trueTime = trueTime + 1
--     else
--         falseTime = falseTime + 1
--     end

-- end

-- print("trueTime", trueTime)
-- print("falseTime", falseTime)
-- print("碰撞率", trueTime / falseTime)

-- trueTime	100
-- falseTime	29900
-- 碰撞率	0.0033444816053512

-- trueTime	83
-- falseTime	29917
-- 碰撞率	0.0027743423471605

-- trueTime	117
-- falseTime	29883
-- 碰撞率	0.0039152695512499
