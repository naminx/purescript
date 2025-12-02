module TextConstants where

import Prelude

-- Text constants for the entire application
-- All Thai translations are centralized here

-- Router / Navigation
type RouterConstants =
  { routePOS :: String
  , routeCustomers :: String
  }

routerConstants :: RouterConstants
routerConstants =
  { routePOS: "บิลวันนี้"
  , routeCustomers: "รายชื่อลูกค้า"
  }

-- POS Page
type POSConstants =
  { searchPlaceholder :: String
  , todaysBillsTitle :: Int -> String
  , columnTime :: String
  , columnCustomerName :: String
  , noCustomersFound :: String
  }

posConstants :: POSConstants
posConstants =
  { searchPlaceholder: "ค้นหาลูกค้า"
  , todaysBillsTitle: \n -> "บิลวันนี้ (" <> show n <> ")"
  , columnTime: "เวลา"
  , columnCustomerName: "ชื่อลูกค้า"
  , noCustomersFound: "ไม่พบลูกค้า"
  }

-- Customer List Page
type CustomerListConstants =
  { appTitle :: String
  , customersCount :: Int -> String
  , columnId :: String
  , columnName :: String
  , columnMoney :: String
  , columnGoldJewelry :: String
  , columnGoldBar96 :: String
  , columnGoldBar99 :: String
  , columnUpdated :: String
  , columnActions :: String
  , headerDebit :: String
  , headerCredit :: String
  , newCustomerPlaceholder :: String
  , searchPlaceholder :: String
  , deleteConfirmTitle :: String
  , deleteConfirmPrompt :: String
  , buttonConfirm :: String
  , buttonCancel :: String
  , unitGrams :: String
  , unitBaht :: String
  }

customerListConstants :: CustomerListConstants
customerListConstants =
  { appTitle: "รายชื่อลูกค้า"
  , customersCount: \n -> show n <> " ราย"
  , columnId: "รหัส"
  , columnName: "ชื่อ"
  , columnMoney: "เงิน"
  , columnGoldJewelry: "รูปพรรณ"
  , columnGoldBar96: "แท่ง 96.5%"
  , columnGoldBar99: "แท่ง 99.99%"
  , columnUpdated: "ปรับปรุง"
  , columnActions: "ลบ"
  , headerDebit: "ค้าง"
  , headerCredit: "เหลือ"
  , newCustomerPlaceholder: "ชื่อลูกค้ารายใหม่"
  , searchPlaceholder: "ค้นหาชื่อลูกค้า ..."
  , deleteConfirmTitle: "ยืนยันการลบ"
  , deleteConfirmPrompt: "โปรดใส่รหัสเพื่อยืนยัน:"
  , buttonConfirm: "ยืนยัน"
  , buttonCancel: "ยกเลิก"
  , unitGrams: "g"
  , unitBaht: "บ"
  }

-- Formatting Constants
type FormatConstants =
  { unitGrams :: String
  , unitBaht :: String
  , unitBahtFull :: String
  , unitPrice :: String
  , unitPercent :: String
  , unitSalung :: String
  , unitSalungShort :: String
  , gramsPerBaht :: Number
  , gramsPerSalung :: Number
  , subscript00 :: String
  , subscript0 :: String
  , subscript1 :: String
  , subscript2 :: String
  , subscript3 :: String
  , subscript4 :: String
  , subscript5 :: String
  , subscript6 :: String
  , subscript7 :: String
  , subscript8 :: String
  , subscript9 :: String
  , superscript0 :: String
  , superscript1 :: String
  , superscript2 :: String
  , superscript3 :: String
  , superscript4 :: String
  , superscript5 :: String
  , superscript6 :: String
  , superscript7 :: String
  , superscript8 :: String
  , superscript9 :: String
  }

formatConstants :: FormatConstants
formatConstants =
  { unitGrams: "g"
  , unitBaht: "บ"
  , unitBahtFull: "บาท"
  , unitPrice: "฿/บ"
  , unitPercent: "%"
  , unitSalung: "สลึง"
  , unitSalungShort: "ส"
  , gramsPerBaht: 15.200
  , gramsPerSalung: 3.800
  , subscript00: "₀₀"
  , subscript0: "₀"
  , subscript1: "₁"
  , subscript2: "₂"
  , subscript3: "₃"
  , subscript4: "₄"
  , subscript5: "₅"
  , subscript6: "₆"
  , subscript7: "₇"
  , subscript8: "₈"
  , subscript9: "₉"
  , superscript0: "⁰"
  , superscript1: "¹"
  , superscript2: "²"
  , superscript3: "³"
  , superscript4: "⁴"
  , superscript5: "⁵"
  , superscript6: "⁶"
  , superscript7: "⁷"
  , superscript8: "⁸"
  , superscript9: "⁹"
  }

-- Balance Constants
type BalanceConstants =
  { prefixPrevious :: String
  , statusCredit :: String
  , statusDebit :: String
  , typeMoney :: String
  , typeGoldJewelry :: String
  , typeGoldBar96 :: String
  , typeGoldBar99 :: String
  }

balanceConstants :: BalanceConstants
balanceConstants =
  { prefixPrevious: "เก่า"
  , statusCredit: "เหลือ"
  , statusDebit: "ค้าง"
  , typeMoney: "เงิน"
  , typeGoldJewelry: "ทอง"
  , typeGoldBar96: "แท่ง ⁹⁶⋅₅﹪"
  , typeGoldBar99: "แท่ง ⁹⁹⋅₉₉﹪"
  }
