--[[ 
LibBinding
Copyright (c) 2024 zeptognome
Functions to determine current binding or items 
Please note bindType=2
]]--

assert(LibStub, "LibStub not found.");
local major, minor = "LibBinding", 1;

---@class LibBinding
local LibBinding = LibStub:NewLibrary(major, minor);

if not LibBinding then return end;

---@enum BindingType
LibBinding.BindingType = {
  NONE = 0,
  ACCOUNT = 1,
  SOULBOUND = 2,
  QUEST = 3,
  BOE = 4,
  BOU = 5,
  WUE = 6,
  NOBANK= 98,
  UNKNOWN = 99
}

---@enum BindingString
LibBinding.BindingString = {
 [LibBinding.BindingType.NONE] = "None",
 [LibBinding.BindingType.ACCOUNT] = "Warbound",
 [LibBinding.BindingType.SOULBOUND] = "Soulbound",
 [LibBinding.BindingType.QUEST] = "Quest",
 [LibBinding.BindingType.BOE] = "BoE",
 [LibBinding.BindingType.BOU] = "BoU",
 [LibBinding.BindingType.WUE] = "WuE",
 [LibBinding.BindingType.NOBANK] = "NoBank",
 [LibBinding.BindingType.UNKNOWN] = "Unknown",
}

---@func LibBinding.isNonBinding(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isNonbinding(itemLocation)
  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  return (bindType == 0)
end

---@func LibBinding.isBound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isBound(itemLocation)
  return C_Item.IsBound(itemLocation) or C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@func LibBinding.isUnbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isUnbound(itemLocation)
  return not C_Item.IsBound(itemLocation) and not C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@func LibBinding.Questbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isQuestbound(itemLocation)
  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  return (bindType == 4)
end

---@func LibBinding.isBindOnEquip(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isBindOnEquip(itemLocation)
  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  return not LibBinding.isBound(itemLocation) and (bindType == 2)
end

---@func LibBinding.isBindOnUse(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isBindOnUse(itemLocation)
  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  return not LibBinding.isBound(itemLocation) and (bindType == 3)
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
  return not C_Item.IsBound(itemLocation) and C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@func LibBinding.GetItemBinding(itemLocation)
---@param itemLocation ItemLocationMixin
---@return BindingType
function LibBinding.GetItemBinding(itemLocation)
  assert (C_Item.IsItemDataCached(itemLocation), "LibBinding request on unloaded item")

  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  if bindType == 0 then
    return LibBinding.BindingType.NONE
  end

  if bindType == 4 then
    return LibBinding.BindingType.QUEST
  end

  local isbound = C_Item.IsBound(itemLocation)
  local warbank = C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)

  if isbound and warbank then
    return LibBinding.BindingType.ACCOUNT
  elseif isbound and not warbank then
    return LibBinding.BindingType.SOULBOUND
  end

  if not isbound and not warbank then
    return LibBinding.BindingType.NOBANK
  end

  if C_Item.IsBoundToAccountUntilEquip(itemLocation) then
    return LibBinding.BindingType.WUE
  end

  if bindType == 2 then
    return LibBinding.BindingType.BOE
  end

  if bindType == 3 then
    return LibBinding.BindingType.BOU
  end

 return LibBinding.BindingType.UNKNOWN
end