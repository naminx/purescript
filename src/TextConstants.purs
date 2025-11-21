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
