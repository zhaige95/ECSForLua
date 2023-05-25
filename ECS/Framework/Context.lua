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

---初始化
function Context:Init()
    --- 实体对象回收池
    self.mEntityList_Recycle = {}
    --- 组件对象回收池
    self.mComponentList_Recycle = {}
    --- 实体列表
    self.mEntityList = {}
    --- 过滤组列表
    self.mGroupList = {}     -- 由group id索引
    self.mGroupMap_Comp = {} -- 由组件id索引，有重复
    --[[
        mGroupMap_Comp = {
            [1] = {...},
            [10] = {...}
        }
    ]]
    -- self.mGroupMap_Act = {} -- 由Added、Removed动作和数字id索引，有重复
    --[[
        mGroupMap_Act = {
            OnAdd = {
                [5612] = { ... }
            },
            OnRemoved = {},
            OnUpdate = {}
        }
    ]]
    --- 实体UID，自增
    self.mEntityUID = 0
    --- 匹配器实例，只需要一个
    self.mMatcher = Matcher.new()

    self:_InitGroupData()
end

function Context:OnDispose()

end

function Context:Clear()
    for _, set in pairs(self.mGroupList) do
        for _, group in pairs(set) do
            if group.mAdded == true or
                group.mRemoved == true or
                group.mUpdated == true
            then
                group:ClearEntity()
            end
        end
    end
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

    -- self.mGroupMap_Act.Globle = {}
    -- self.mGroupMap_Act.Added = {}
    -- self.mGroupMap_Act.Removed = {}
    -- self.mGroupMap_Act.Updated = {}
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

---根据uid获取实体
---@param uid integer
---@return Entity entity对象
function Context:GetEntity(uid)
    if self.mEntityList[uid] then
        return self.mEntityList[uid]
    end
    return nil
end

function Context:_OnDestroyEntity(e)
    if nil == e then
        return
    end
    for comp_id, comp in pairs(e.__component_indexer) do
        -- 先处理group
        for key, group in pairs(self.mGroupMap_Comp[comp_id]) do
            group:_OnDestroyEntity(e)
        end
        -- 回收entity组件
        if nil == self.mComponentList_Recycle[comp_id] then
            self.mComponentList_Recycle[comp_id] = {}
        end
        table.insert(self.mComponentList_Recycle[comp_id], comp)
        e:_OnRemoveComponent(comp)
    end
    -- 清理组件数据
    e:ClearComponents()
    -- 回收entity
    table.insert(self.mEntityList_Recycle, e)
    if self.mEntityList[e.mUID] then
        self.mEntityList[e.mUID] = nil
    end
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

---实体添加组件
---@param e Entity 实体对象
---@param component Component 组件对象
function Context:_OnAddComponent(e, component)
    local id = component.__id
    for key, group in pairs(self.mGroupMap_Comp[id]) do
        group:_OnAddComponent(e, id)
    end
end

---实体移除组件
---@param e Entity 实体对象
---@param component Component 组件对象
function Context:_OnRemoveComponent(e, component)
    local id = component.__id
    for key, group in pairs(self.mGroupMap_Comp[id]) do
        group:_OnRemoveComponent(e, id)
    end
end

function Context:_OnUpdateComponent(e, component)
    local id = component.__id
    for key, group in pairs(self.mGroupMap_Comp[id]) do
        group:_OnUpdateComponent(e, id)
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- System 系统相关
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Group 过滤组相关
-----------------------------------------------------------------------------------------------------------------------

---获取匹配器
---@return Matcher 匹配器实例
function Context:GetMatcher()
    return self.mMatcher:Reset()
end

---获取过滤组
---@param matcher Matcher 匹配器
---@return Group 过滤组实例
function Context:GetGroup(matcher)
    if nil == matcher then return nil end
    local group = nil
    local id = Context:_GenerateGroupID(matcher)

    -- 找出已有的group
    if self.mGroupList[id] then
        for key, g in pairs(self.mGroupList[id]) do
            if g:_Match(matcher) == true then
                group = g
                break
            end
        end
    end

    -- 创建新的group
    if nil == group then
        group = Group.new(id, matcher)
        -- 加入id索引列表
        if nil == self.mGroupList[id] then
            self.mGroupList[id] = {}
        end
        table.insert(self.mGroupList[id], group)

        -- 加入组件索引列表
        for _, comp_id in pairs(matcher.mAllOfContent) do
            table.insert(self.mGroupMap_Comp[comp_id], group)
        end
        for _, comp_id in pairs(matcher.mNoneOfContent) do
            table.insert(self.mGroupMap_Comp[comp_id], group)
        end

        -- 加入事件索引列表
        -- if group.mAdded == false and group.mRemoved == false and group.mUpdated == false then
        --     if nil == self.mGroupMap_Act.Globle[id] then
        --         self.mGroupMap_Act.Globle[id] = {}
        --     end
        --     table.insert(self.mGroupMap_Act.Globle[id], group)
        -- else
        --     if group.mAdded == true then
        --         if nil == self.mGroupMap_Act.Added[id] then
        --             self.mGroupMap_Act.Added[id] = {}
        --         end
        --         table.insert(self.mGroupMap_Act.Added[id], group)
        --     end
        --     if group.mRemoved == true then
        --         if nil == self.mGroupMap_Act.Removed[id] then
        --             self.mGroupMap_Act.Removed[id] = {}
        --         end
        --         table.insert(self.mGroupMap_Act.Removed[id], group)
        --     end
        --     if group.mUpdated == true then
        --         if nil == self.mGroupMap_Act.Updated[id] then
        --             self.mGroupMap_Act.Updated[id] = {}
        --         end
        --         table.insert(self.mGroupMap_Act.Updated[id], group)
        --     end
        -- end
    end

    return group
end

---生成过滤组id，组件id简单求和做id有大概0.3%的碰撞概率，所以不是唯一id，但是可以大幅减少无用的遍历
---@param matcher Matcher 匹配器实例
---@return integer id
function Context:_GenerateGroupID(matcher)
    local id = 0
    for index, value in ipairs(matcher.mAllOfContent) do
        id = id + value
    end
    for index, value in ipairs(matcher.mNoneOfContent) do
        id = id + value
    end

    return id
end
