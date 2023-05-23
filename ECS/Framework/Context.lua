-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- ECS Context ECS运行环境
-- Date - 2023-5-22
-- by - 良人
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local Entity = require("ECS.Framework.Entity")
local Matcher = require("ECS.Framework.Matcher")
local Group = require("ECS.Framework.Group")

Context = {}


-----------------------------------------------------------------------------------------------------------------------
-- Context API
-----------------------------------------------------------------------------------------------------------------------

function Context:Init()
    --- 实体对象回收池
    self.mEntityList_Recycle = {}
    --- 组件对象回收池
    self.mComponentList_Recycle = {}
    --- 实体列表
    self.mEntityList = {}
    --- 过滤组列表
    self.mGroupMap_Comp = {} -- 由组件id索引
    self.mGroupMap_Key = {}  -- 由Added、Removed动作和数字id索引
    --[[
        mGroupMap_Key = {
            [onAdd:true] = {
                [onRemove:true] = {
                    [56] = {...},
                    [105] = {...},
                    ...
                }
            },
            [onAdd:false] = {
                [onRemove:true] = { ... }
            }
        }
    ]]
    --- 实体UID，自增
    self.mEntityUID = 0
    --- 匹配器实例，只需要一个
    self.mMatcher = Matcher.new()

    self:_InitGroupData()
end


-----------------------------------------------------------------------------------------------------------------------
-- Context 私有方法
-----------------------------------------------------------------------------------------------------------------------

---获取实体uid
---@return integer UID
function Context:_GetEntityUID()
    self.mEntityUID = self.mEntityUID + 1
    return self.mEntityUID
end

function Context:_InitGroupData()
    for key, value in pairs(GameComponentLookUp) do
        self.mGroupMap_Comp[value] = {}
    end

    self.mGroupMap_Key[true] = {}
    self.mGroupMap_Key[false] = {}
    self.mGroupMap_Key[true][true] = {}
    self.mGroupMap_Key[true][false] = {}
    self.mGroupMap_Key[false][false] = {}
    self.mGroupMap_Key[false][true] = {}
end

-----------------------------------------------------------------------------------------------------------------------
-- Entity 实体相关
-----------------------------------------------------------------------------------------------------------------------

--- 创建Entity
---@return Entity 实体
function Context:CreateEntity()
    local entity = nil
    if #self.mEntityList_Recycle > 0 then
        entity = table.remove(self.mEntityList_Recycle, #self.mEntityList_Recycle)
    else
        entity = Entity.new()
    end
    entity.mUID = self:_GetEntityUID()
    self.mEntityList[entity.mUID] = entity
    return entity
end

-----------------------------------------------------------------------------------------------------------------------
-- Component 组件相关
-----------------------------------------------------------------------------------------------------------------------

---获取组件实例，优先取回收的组件，不够时创建新的
---@param component_id integer 组件id
---@return Component 组件实例
function Context:_GetComponent(component_id)
    if self.mComponentList_Recycle[component_id] and
        #self.mComponentList_Recycle[component_id] > 0 then
        return table.remove(self.mComponentList_Recycle[component_id], 1)
    end
    local comp = GameComponentScript[component_id].new()
    comp.__id = component_id
    return comp
end


function Context:_OnAddComponent(e, component)
    local id = component.__id
    for key, group in pairs(self.mGroupMap_Comp[id]) do
        group:_OnAddComponent(e, id)
    end
end

function Context:_OnRemoveComponent(e, component)
    local id = component.__id
    for key, group in pairs(self.mGroupMap_Comp[id]) do
        group:_OnRemoveComponent(e, id)
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- System 系统相关
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Group 过滤组相关
-----------------------------------------------------------------------------------------------------------------------

function Context:GetMatcher()
    return self.mMatcher:Reset()
end

function Context:GetGroup(matcher)
    local group = nil
    local id = Context:_GenerateGroupID(matcher)

    if self.mGroupMap_Key[matcher.mAdded][matcher.mRemoved] then
        local _set = self.mGroupMap_Key[matcher.mAdded][matcher.mRemoved][id]
        if _set then
            for _, value in pairs(_set) do
                if value:_Match(matcher) then
                    group = value
                    break
                end
            end
        end
    end

    if nil == group then
        group = Group.new(id, matcher)
        if nil == self.mGroupMap_Key[group.mAdded][group.mRemoved][id] then
            self.mGroupMap_Key[group.mAdded][group.mRemoved][id] = {}
        end
        table.insert(self.mGroupMap_Key[group.mAdded][group.mRemoved][id], group)
        for _, comp_id in pairs(matcher.mAllOfContent) do
            table.insert(self.mGroupMap_Comp[comp_id], group)
        end
        for _, comp_id in pairs(matcher.mNoneOfContent) do
            table.insert(self.mGroupMap_Comp[comp_id], group)
        end
    end

    return group
end

function Context:_GenerateGroupID(group)
    local id = 0
    for index, value in ipairs(group.mAllOfContent) do
        id = id + value
    end
    for index, value in ipairs(group.mNoneOfContent) do
        id = id + value
    end
    
    return id
end
