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
    else
        self.mEntityIndexer[e.mUID] = nil
    end
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
---@return boolean
function Group:_MatchEntity(e)
    local pass_all = self.mAnyMode == false
    for _, id in pairs(self.mAllOfContent) do
        if self.mAnyMode == true then
            if e:HasComponent(id) == true then
                pass_all = true
                break
            end
        else
            if e:HasComponent(id) == false then
                return false
            end
        end
    end
    for _, id in pairs(self.mNoneOfContent) do
        if e:HasComponent(id) == true then
            return false
        end
    end
    return pass_all
end

return Group
