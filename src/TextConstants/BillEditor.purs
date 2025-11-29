module TextConstants.BillEditor where

-- Simple string exports for easy import
billEditor :: String
billEditor = "แก้ไขบิล"

newBill :: String
newBill = "บิลใหม่"

billsFor :: String
billsFor = "บิลของ"

reload :: String
reload = "โหลดใหม่"

loading :: String
loading = "กำลังโหลด..."

errorPrefix :: String
errorPrefix = "ข้อผิดพลาด: "

noBillsFound :: String
noBillsFound = "ไม่พบบิล"

billId :: String
billId = "เลขบิล"

date :: String
date = "วันที่"

status :: String
status = "สถานะ"

actions :: String
actions = "จัดการ"

finalized :: String
finalized = "ปิดแล้ว"

draft :: String
draft = "ร่าง"

edit :: String
edit = "แก้ไข"

nominalWeightLabel :: String
nominalWeightLabel = "น้ำหนักนาม"

unitBaht :: String
unitBaht = "บาท"

unitGrams :: String
unitGrams = "กรัม"

unitTHB :: String
unitTHB = "บาท"

addItemButton :: String
addItemButton = "+ เพิ่ม"

previousBalanceLabel :: String
previousBalanceLabel = "ยอดเก่า"

trayLabel :: String
trayLabel = "ถาด"

packLabel :: String
packLabel = "แพ็ค"

transactionLabel :: String
transactionLabel = "รายการ"

purityLabel :: String
purityLabel = "ความบริสุทธิ์"

shapeLabel :: String
shapeLabel = "รูปแบบ"

discountLabel :: String
discountLabel = "ส่วนลด"

actualWeightLabel :: String
actualWeightLabel = "น้ำหนักจริง"

priceRateLabel :: String
priceRateLabel = "ราคา"

quantityLabel :: String
quantityLabel = "จำนวน"

makingChargeLabel :: String
makingChargeLabel = "ค่าทำ"

amountLabel :: String
amountLabel = "รวม"

deleteButton :: String
deleteButton = "ลบ"

packIdLabel :: String
packIdLabel = "เลขแพ็ค"

userNumberLabel :: String
userNumberLabel = "เลขที่ผู้ใช้"

weightLabel :: String
weightLabel = "น้ำหนัก"

deductionRateLabel :: String
deductionRateLabel = "อัตราหัก"

calculationAmountLabel :: String
calculationAmountLabel = "คำนวณ"

prevDebitMoney :: String
prevDebitMoney = "เก่าค้างเงิน"

prevCreditMoney :: String
prevCreditMoney = "เก่าเหลือเงิน"

prevDebitJewel :: String
prevDebitJewel = "เก่าค้างทอง"

prevCreditJewel :: String
prevCreditJewel = "เก่าเหลือทอง"

prevDebitBar96 :: String
prevDebitBar96 = "เก่าค้างแท่ง 96.5%"

prevCreditBar96 :: String
prevCreditBar96 = "เก่าเหลือแท่ง 96.5%"

prevDebitBar99 :: String
prevDebitBar99 = "เก่าค้างแท่ง 99.99%"

prevCreditBar99 :: String
prevCreditBar99 = "เก่าเหลือแท่ง 99.99%"

moneyIn :: String
moneyIn = "มาเงิน"

moneyOut :: String
moneyOut = "ไปเงิน"

jewelIn :: String
jewelIn = "มาทอง"

jewelOut :: String
jewelOut = "ไปทอง"

bar96In :: String
bar96In = "มาแท่ง 96.5%"

bar96Out :: String
bar96Out = "ไปแท่ง 96.5%"

bar99In :: String
bar99In = "มาแท่ง 99.99%"

bar99Out :: String
bar99Out = "ไปแท่ง 99.99%"

buyJewel :: String
buyJewel = "ตัดซื้อทอง"

sellJewel :: String
sellJewel = "ตัดขายทอง"

buyBar96 :: String
buyBar96 = "ซื้อแท่ง 96.5%"

sellBar96 :: String
sellBar96 = "ขายแท่ง 96.5%"

buyBar99 :: String
buyBar99 = "ซื้อแท่ง 99.99%"

sellBar99 :: String
sellBar99 = "ขายแท่ง 99.99%"

convertJewelToBar96 :: String
convertJewelToBar96 = "แปลงรูปพรรณเป็นแท่ง"

convertBar96ToJewel :: String
convertBar96ToJewel = "แปลงแท่งเป็นรูปพรรณ"

convertGramsToBaht :: String
convertGramsToBaht = "แปลงกรัมเป็นบาท"

convertBahtToGrams :: String
convertBahtToGrams = "แปลงบาทเป็นกรัม"

splitBar :: String
splitBar = "แบ่งแท่ง"

grandTotalLabel :: String
grandTotalLabel = "รวมทั้งหมด"

saveButton :: String
saveButton = "บันทึก"

cancelButton :: String
cancelButton = "ยกเลิก"

finalizeButton :: String
finalizeButton = "ปิดบิล"

savingMessage :: String
savingMessage = "กำลังบันทึก..."

addTrayButton :: String
addTrayButton = "+ เพิ่มถาด"

addPackButton :: String
addPackButton = "+ เพิ่มแพ็ค"

addTransactionButton :: String
addTransactionButton = "+ เพิ่มรายการ"

-- Tray display labels
jewelryTypeLabel :: String
jewelryTypeLabel = "ประเภท"

designLabel :: String
designLabel = "แบบ"

totalWeightLabel :: String
totalWeightLabel = "รวมทองหนัก"

totalMakingChargeLabel :: String
totalMakingChargeLabel = "รวมค่าแรง"

discountAmountLabel :: String
discountAmountLabel = "ส่วนลด"

owedGoldLabel :: String
owedGoldLabel = "ค้างทอง"

owedMoneyLabel :: String
owedMoneyLabel = "ค้างเงิน"

type BillEditorConstants =
  { -- Module title
    moduleTitle :: String
  
  -- Customer info
  , customerLabel :: String
  , previousBalanceLabel :: String
  
  -- Group types
  , trayLabel :: String
  , packLabel :: String
  , transactionLabel :: String
  
  -- Tray fields
  , trayNumberLabel :: String
  , returnLabel :: String
  , purityLabel :: String
  , shapeLabel :: String
  , discountLabel :: String
  , actualWeightLabel :: String
  , priceRateLabel :: String
  , premiumRateLabel :: String
  
  -- Tray item fields
  , makingChargeLabel :: String
  , jewelryTypeLabel :: String
  , designNameLabel :: String
  , nominalWeightLabel :: String
  , quantityLabel :: String
  , amountLabel :: String
  
  -- Pack fields
  , packIdLabel :: String
  , userNumberLabel :: String
  
  -- Pack item fields
  , deductionRateLabel :: String
  , descriptionLabel :: String
  , weightLabel :: String
  , calculationAmountLabel :: String
  
  -- Transaction types
  , prevDebitMoney :: String
  , prevCreditMoney :: String
  , prevDebitJewel :: String
  , prevCreditJewel :: String
  , prevDebitBar96 :: String
  , prevCreditBar96 :: String
  , prevDebitBar99 :: String
  , prevCreditBar99 :: String
  , moneyIn :: String
  , moneyOut :: String
  , jewelIn :: String
  , jewelOut :: String
  , bar96In :: String
  , bar96Out :: String
  , bar99In :: String
  , bar99Out :: String
  , buyJewel :: String
  , sellJewel :: String
  , buyBar96 :: String
  , sellBar96 :: String
  , buyBar99 :: String
  , sellBar99 :: String
  , convertJewelToBar96 :: String
  , convertBar96ToJewel :: String
  , convertGramsToBaht :: String
  , convertBahtToGrams :: String
  , splitBar :: String
  
  -- VAT
  , vatLabel :: String
  , vatDeferredLabel :: String
  , marketBuyingPriceLabel :: String
  , taxableAmountLabel :: String
  , vatAmountLabel :: String
  
  -- Totals
  , groupTotalLabel :: String
  , accumulatedTotalLabel :: String
  , grandTotalLabel :: String
  
  -- Actions
  , addTrayButton :: String
  , addPackButton :: String
  , addTransactionButton :: String
  , addItemButton :: String
  , deleteButton :: String
  , saveButton :: String
  , cancelButton :: String
  , finalizeButton :: String
  , printButton :: String
  
  -- Units
  , unitGrams :: String
  , unitBaht :: String
  , unitTHB :: String
  , unitPercent :: String
  
  -- Messages
  , confirmDelete :: String
  , confirmFinalize :: String
  , savingMessage :: String
  , savedMessage :: String
  , errorMessage :: String
  }

billEditorConstants :: BillEditorConstants
billEditorConstants =
  { moduleTitle: "บิลลูกค้า"
  
  , customerLabel: "ลูกค้า"
  , previousBalanceLabel: "ยอดเก่า"
  
  , trayLabel: "ถาด"
  , packLabel: "แพ็ค"
  , transactionLabel: "รายการ"
  
  , trayNumberLabel: "ถาดที่"
  , returnLabel: "คืน"
  , purityLabel: "ความบริสุทธิ์"
  , shapeLabel: "รูปแบบ"
  , discountLabel: "ส่วนลด"
  , actualWeightLabel: "น้ำหนักจริง"
  , priceRateLabel: "ราคา"
  , premiumRateLabel: "ค่าพิเศษ 99.99%"
  
  , makingChargeLabel: "ค่าทำ"
  , jewelryTypeLabel: "ประเภท"
  , designNameLabel: "ชื่อลาย"
  , nominalWeightLabel: "น้ำหนักนาม"
  , quantityLabel: "จำนวน"
  , amountLabel: "รวม"
  
  , packIdLabel: "เลขแพ็ค"
  , userNumberLabel: "เลขที่ผู้ใช้"
  
  , deductionRateLabel: "อัตราหัก"
  , descriptionLabel: "รายละเอียด"
  , weightLabel: "น้ำหนัก"
  , calculationAmountLabel: "คำนวณ"
  
  , prevDebitMoney: "เก่าค้างเงิน"
  , prevCreditMoney: "เก่าเหลือเงิน"
  , prevDebitJewel: "เก่าค้างทอง"
  , prevCreditJewel: "เก่าเหลือทอง"
  , prevDebitBar96: "เก่าค้างแท่ง 96.5%"
  , prevCreditBar96: "เก่าเหลือแท่ง 96.5%"
  , prevDebitBar99: "เก่าค้างแท่ง 99.99%"
  , prevCreditBar99: "เก่าเหลือแท่ง 99.99%"
  , moneyIn: "มาเงิน"
  , moneyOut: "ไปเงิน"
  , jewelIn: "มาทอง"
  , jewelOut: "ไปทอง"
  , bar96In: "มาแท่ง 96.5%"
  , bar96Out: "ไปแท่ง 96.5%"
  , bar99In: "มาแท่ง 99.99%"
  , bar99Out: "ไปแท่ง 99.99%"
  , buyJewel: "ตัดซื้อทอง"
  , sellJewel: "ตัดขายทอง"
  , buyBar96: "ซื้อแท่ง 96.5%"
  , sellBar96: "ขายแท่ง 96.5%"
  , buyBar99: "ซื้อแท่ง 99.99%"
  , sellBar99: "ขายแท่ง 99.99%"
  , convertJewelToBar96: "แปลงรูปพรรณเป็นแท่ง"
  , convertBar96ToJewel: "แปลงแท่งเป็นรูปพรรณ"
  , convertGramsToBaht: "แปลงกรัมเป็นบาท"
  , convertBahtToGrams: "แปลงบาทเป็นกรัม"
  , splitBar: "แบ่งแท่ง"
  
  , vatLabel: "ภาษีมูลค่าเพิ่ม"
  , vatDeferredLabel: "เลื่อนภาษี"
  , marketBuyingPriceLabel: "ราคารับซื้อตลาด"
  , taxableAmountLabel: "มูลค่าที่ต้องเสียภาษี"
  , vatAmountLabel: "ภาษี"
  
  , groupTotalLabel: "รวมกลุ่ม"
  , accumulatedTotalLabel: "รวมสะสม"
  , grandTotalLabel: "รวมทั้งหมด"
  
  , addTrayButton: "+ เพิ่มถาด"
  , addPackButton: "+ เพิ่มแพ็ค"
  , addTransactionButton: "+ เพิ่มรายการ"
  , addItemButton: "+ เพิ่ม"
  , deleteButton: "ลบ"
  , saveButton: "บันทึก"
  , cancelButton: "ยกเลิก"
  , finalizeButton: "ปิดบิล"
  , printButton: "พิมพ์"
  
  , unitGrams: "กรัม"
  , unitBaht: "บาท"
  , unitTHB: "บาท"
  , unitPercent: "%"
  
  , confirmDelete: "ยืนยันการลบ?"
  , confirmFinalize: "ยืนยันการปิดบิล?"
  , savingMessage: "กำลังบันทึก..."
  , savedMessage: "บันทึกเรียบร้อย"
  , errorMessage: "เกิดข้อผิดพลาด"
  }
