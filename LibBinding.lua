--[[ 
LibBinding
Copyright (c) 2024 zeptognome
Functions to determine current binding or items 
]]--

assert(LibStub, "LibStub not found.");
local major, minor = "LibBinding", 1;

---@class LibBinding
local LibBinding = LibStub:NewLibrary(major, minor);

if not LibBinding then return end;

---@enum BindingType -- note these are similar, but NOT the same as Enum.ItemBind
LibBinding.BindingType = {
  NONE = 0,
  SOULBOUND = 1,
  BOE = 2,
  BOU = 3,
  QUEST = 4,
  NOBANK = 5,
  UNKNOWN = 6,
  ACCOUNT = 7,
  BNET = 8,
  WUE = 9,
}

---@enum BindingString
LibBinding.BindingString = {
 [LibBinding.BindingType.NONE] = "None",
 [LibBinding.BindingType.SOULBOUND] = "Soulbound",
 [LibBinding.BindingType.BOE] = "BoE",
 [LibBinding.BindingType.BOU] = "BoU",
 [LibBinding.BindingType.QUEST] = "Quest",
 [LibBinding.BindingType.NOBANK] = "NoBank",
 [LibBinding.BindingType.UNKNOWN] = "Unknown",
 [LibBinding.BindingType.ACCOUNT] = "Warbound",
 [LibBinding.BindingType.BNET] = "BNet",
 [LibBinding.BindingType.WUE] = "WuE",
}

---@enum GlobalString
LibBinding.GlobalString = {
  [LibBinding.BindingType.NONE] = "",
  [LibBinding.BindingType.SOULBOUND] = ITEM_SOULBOUND,
  [LibBinding.BindingType.BOE] = ITEM_BIND_ON_EQUIP,
  [LibBinding.BindingType.BOU] = ITEM_BIND_ON_USE,
  [LibBinding.BindingType.QUEST] = ITEM_BIND_QUEST,
  [LibBinding.BindingType.NOBANK] = ERROR_CAPS,
  [LibBinding.BindingType.UNKNOWN] = ERROR_CAPS,
  [LibBinding.BindingType.ACCOUNT] = ITEM_ACCOUNTBOUND,
  [LibBinding.BindingType.BNET] = ITEM_BNETACCOUNTBOUND,
  [LibBinding.BindingType.WUE] = ITEM_ACCOUNTBOUND_UNTIL_EQUIP,
}

---@func LibBinding.FetchBindType(itemLocation)
---@param itemLocation ItemLocationMixin
---@return Enum.ItemBind
function LibBinding.FetchBindType(itemLocation)
  local bindType
  local item = Item:CreateFromItemLocation(itemLocation)
  local itemCallback = function()
    bindType,_,_,_ = select(14, C_Item.GetItemInfo(item:GetItemID()))
  end
  item:ContinueOnItemLoad(itemCallback)
  return bindType
end

---@func LibBinding.isNonBinding(itemLocation)
---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isNonbinding(itemLocation, bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return (type == 0)
end

---@func LibBinding.isBound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isUntradable(itemLocation)
  return C_Item.IsBound(itemLocation) or C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@func LibBinding.isUnbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isTradeable(itemLocation)
  return not C_Item.IsBound(itemLocation) and not C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@func LibBinding.Questbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isQuestbound(itemLocation,bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return (type == 4)
end

---@func LibBinding.isBindOnEquip(itemLocation)
---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isBindOnEquip(itemLocation,bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return (type == 2) and LibBinding.isTradeable(itemLocation)
end

---@func LibBinding.isBindOnUse(itemLocation)
---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isBindOnUse(itemLocation, bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return (type == 3) and LibBinding.isTradeable(itemLocation)
end

---@func LibBinding.isSoulbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isSoulbound(itemLocation)
  return C_Item.IsBound(itemLocation) and not C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)
end

---@func LibBinding.isWarbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isWarbound(itemLocation)
  return C_Item.IsBound(itemLocation) and C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)
end

---@func LibBinding.isWarboundUntilEquipped(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isWarboundUntilEquipped(itemLocation)
  return C_Item.IsBoundToAccountUntilEquip(itemLocation) and not C_Item.IsBound(itemLocation)
end

---@func LibBinding.GetItemBinding(itemLocation)
---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return BindingType
function LibBinding.GetItemBinding(itemLocation, bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)

  if type == 0 then
    return LibBinding.BindingType.NONE
  end

  if type == 4 then
    return LibBinding.BindingType.QUEST
  end

  local isbound = C_Item.IsBound(itemLocation)
  local warbank = C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)

  if LibBinding.isWarbound(itemLocation) then
    return LibBinding.BindingType.ACCOUNT
  elseif LibBinding.isSoulbound(itemLocation) then
    return LibBinding.BindingType.SOULBOUND
  end

  if not isbound and not warbank then
    return LibBinding.BindingType.NOBANK
  end

  if C_Item.IsBoundToAccountUntilEquip(itemLocation) then
    return LibBinding.BindingType.WUE
  end

  if type == 2 then
    return LibBinding.BindingType.BOE
  end

  if type == 3 then
    return LibBinding.BindingType.BOU
  end

 return LibBinding.BindingType.UNKNOWN
end