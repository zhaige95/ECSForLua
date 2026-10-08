-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 过滤组
-- Date - 2023-5-22
-- by - 良人
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local Group = class("Group")

function Group:ctor(id, matcher)
    self:Reset()

    self.mIsDirty = true
    self.mAdded = matcher.mAdded
    self.mRemoved = matcher.mRemoved
    self.mUpdated = matcher.mUpdated
    self.mAnyMode = matcher.mAnyMode

    for key, value in pairs(matcher.mAllOfContent) do
        self.mAllOfIndexer[value] = true
        table.insert(self.mAllOfContent, value)
    end
    for key, value in pairs(matcher.mNoneOfContent) do
        self.mNoneOfIndexer[value] = true
        table.insert(self.mNoneOfContent, value)
    end
    self.mID = id
    --- 实体对象缓存
    self.__entities = {}
    --[[
        self.__entities = {
            [uid] = entity,
            [uid] = entity,
            ...
        }
    ]]
    self.__test_id = string.format("Group-%d:%s:%s:%s —> ", self.mID, self.mAdded and 'add' or '_', self.mRemoved and 'removed' or '_',
        self.mUpdated and 'updated' or '_')
end

function Group:OnDispose()

end

function Group:Reset()
    self.mAllOfContent = {}
    self.mNoneOfContent = {}

    self.mAllOfIndexer = {}
    self.mNoneOfIndexer = {}

    self.mAdded = false
    self.mRemoved = false
    self.mUpdated = false
    self.mAnyMode = false

    self.mEntityIndexer = {}
    --- 实体对象缓存
    self.__entities = {}
end

function Group:ClearEntity()
    for key, value in pairs(self.mEntityIndexer) do
        self.mEntityIndexer[key] = nil
        if self.__entities[key] then
            self.__entities[key] = nil
        end
    end
    self.mIsDirty = true
end

---获取实体列表
function Group:GetEntities()
    if self.mIsDirty == true then
        for key, value in pairs(self.mEntityIndexer) do
            if nil == self.__entities[key] then
                self.__entities[key] = Context:GetEntity(key)
            end
        end

        self.mIsDirty = false
    end

    return self.__entities
end

function Group:Test_GetEntities()
    for key, value in pairs(self:GetEntities()) do
        print(self.__test_id, key)
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- Group 私有方法
-----------------------------------------------------------------------------------------------------------------------

function Group:_OnDestroyEntity(e)
    if self.mEntityIndexer[e.mUID] then
        self.mEntityIndexer[e.mUID] = nil
    end
    if self.__entities[e.mUID] then
        self.__entities[e.mUID] = nil
    end
    self.mIsDirty = true
end

---添加组件
---@param e Entity
---@param comp_id integer
function Group:_OnAddComponent(e, comp_id)
    if self.mUpdated == true or self.mRemoved == true then
        return
    end
    if self:_MatchEntity(e) then
        self.mEntityIndexer[e.mUID] = true
        self.mIsDirty = true
    elseif self.mAdded == false then
        -- 普通组：新增组件导致不再匹配（如命中 NoneOf）时，移除残留成员
        self:_RemoveEntityCache(e.mUID)
    end
end

---移除组件
---@param e Entity
---@param comp_id integer
function Group:_OnRemoveComponent(e, comp_id)
    if self.mRemoved == true then
        if self:_MatchEntity(e) then
            self.mEntityIndexer[e.mUID] = true
            self.mIsDirty = true
        end
    elseif self.mAdded == false then
        -- 普通组：重新评估成员。生成代码先通知后摘除组件，
        -- 匹配时需把 comp_id 视为已移除（移除 NoneOf 组件后实体可能重新匹配）
        if self:_MatchEntity(e, comp_id) then
            if self.mEntityIndexer[e.mUID] ~= true then
                self.mEntityIndexer[e.mUID] = true
                self.mIsDirty = true
            end
        else
            self:_RemoveEntityCache(e.mUID)
        end
    else
        self:_RemoveEntityCache(e.mUID)
    end
end

---从组内移除实体，索引和实体对象缓存都要清理，并标记脏
---@param uid integer
function Group:_RemoveEntityCache(uid)
    if self.mEntityIndexer[uid] then
        self.mEntityIndexer[uid] = nil
    end
    if self.__entities[uid] then
        self.__entities[uid] = nil
    end
    self.mIsDirty = true
end

---更新组件
---@param e Entity
---@param comp_id integer
function Group:_OnUpdateComponent(e, comp_id)
    if self.mUpdated == true then
        if self:_MatchEntity(e) then
            self.mEntityIndexer[e.mUID] = true
            self.mIsDirty = true
        end
    end
end

---匹配匹配器
---@param matcher Matcher
---@return boolean
function Group:_Match(matcher)
    if self.mAdded ~= matcher.mAdded or
        self.mRemoved ~= matcher.mRemoved or
        self.mAnyMode ~= matcher.mAnyMode or
        self.mUpdated ~= matcher.mUpdated
    then
        return false
    end
    if #matcher.mAllOfContent ~= #self.mAllOfContent or #matcher.mNoneOfContent ~= #self.mNoneOfContent then
        return false
    end
    for _, value in pairs(matcher.mAllOfContent) do
        if not self.mAllOfIndexer[value] then
            return false
        end
    end
    for _, value in pairs(matcher.mNoneOfContent) do
        if not self.mNoneOfIndexer[value] then
            return false
        end
    end
    return true
end

---匹配实体
---@param e Entity
---@param except_comp_id integer|nil 视为已移除的组件id（移除通知时组件尚未从实体摘除）
---@return boolean
function Group:_MatchEntity(e, except_comp_id)
    local pass_all = self.mAnyMode == false
    for _, id in pairs(self.mAllOfContent) do
        -- 被移除的组件视为不存在
        local has = id ~= except_comp_id and e:HasComponent(id) == true
        if self.mAnyMode == true then
            if has == true then
                pass_all = true
                break
            end
        else
            if has == false then
                return false
            end
        end
    end
    for _, id in pairs(self.mNoneOfContent) do
        if id ~= except_comp_id and e:HasComponent(id) == true then
            return false
        end
    end
    return pass_all
end

return Group
