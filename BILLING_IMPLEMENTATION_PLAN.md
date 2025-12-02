# Implementation Plan: Bill Editor Module

## Module Name

**Proposed:** "Bill Editor" (บิลลูกค้า)

**Alternative names considered:**
- ~~"Billing Statement"~~ - Too formal, sounds like monthly statement
- ~~"Transaction Module"~~ - Too generic
- ~~"Customer Bill"~~ - Redundant
- **"Bill Editor"** - Clear, concise, matches "Today's Bills" naming pattern

---

## Implementation Phases

### Phase 0: Foundation & Setup (Week 1)

#### 0.1 Database Schema
- [ ] Create migration file for all new tables
- [ ] Add enums: `shape_type`, `balance_type`, `transaction_type`, `group_type`
- [ ] Create tables in order:
  1. `bills` (references `customers`)
  2. `bill_groups` (references `bills`)
  3. `trays` (references `bill_groups`)
  4. `tray_items` (references `trays`, `jewelry_types`)
  5. `packs` (references `bill_groups`)
  6. `pack_items` (references `packs`)
  7. `transactions` (references `bill_groups`)
  8. `transaction_items` (references `transactions`)
- [ ] Add indexes for performance
- [ ] Add CHECK constraints (especially `amount_grams`/`amount_baht` mutual exclusivity)
- [ ] Create `jewelry_types` reference table if not exists
- [ ] Test migration up/down

#### 0.2 Constants Module
- [ ] Create `src/Constants.purs` with numeric constants
- [ ] Create `src/TextConstants/BillEditor.purs` with Thai text
- [ ] Export all constants in a single record
- [ ] Add unit tests for constant values

#### 0.3 Core Types
- [ ] Create `src/Bill/Types.purs`:
  - `Shape`, `Purity`, `GoldType`, `BalanceType`
  - `Customer` (extend existing with balance fields)
  - `Bill`, `BillGroup`, `BillGroupData`
  - `Tray`, `TrayItem`, `TraySettings`
  - `Pack`, `PackItem`
  - `Transaction`, `TransactionItem`, `TransactionType`
  - `Balance` (money + 6 gold fields)
  - `GoldAmount` (Either grams or baht)
- [ ] Add `Eq`, `Show`, `Ord` instances
- [ ] Add JSON encode/decode instances
- [ ] Add validation functions

---

### Phase 1: Backend API (Week 2-3)

#### 1.1 Database Layer
- [ ] Create `src/Bill/Database.purs`:
  - `getBill :: Int -> m (Maybe Bill)`
  - `createBill :: Int -> m Bill` (customer_id → new bill with prev balances)
  - `updateBill :: Bill -> m Bill`
  - `deleteBill :: Int -> m Unit`
  - `getBillsByCustomer :: Int -> m (Array Bill)`
  - `getBillsByDate :: Date -> m (Array Bill)`

#### 1.2 Bill Group Operations
- [ ] Create `src/Bill/Groups.purs`:
  - `addTray :: Int -> TraySettings -> m Tray`
  - `updateTray :: Tray -> m Tray`
  - `deleteTray :: Int -> m Unit`
  - `addPack :: Int -> PackSettings -> m Pack`
  - `updatePack :: Pack -> m Pack`
  - `deletePack :: Int -> m Unit`
  - `addTransaction :: Int -> m Transaction`
  - `updateTransaction :: Transaction -> m Transaction`
  - `deleteTransaction :: Int -> m Unit`
  - `reorderGroups :: Int -> Array { id :: Int, order :: Int } -> m Unit`

#### 1.3 Item Operations
- [ ] Create `src/Bill/Items.purs`:
  - Tray items: `addTrayItem`, `updateTrayItem`, `deleteTrayItem`, `reorderTrayItems`
  - Pack items: `addPackItem`, `updatePackItem`, `deletePackItem`, `reorderPackItems`
  - Transaction items: `addTransactionItem`, `updateTransactionItem`, `deleteTransactionItem`, `reorderTransactionItems`

#### 1.4 Calculation Engine
- [ ] Create `src/Bill/Calculations.purs`:
  - `calculateTrayTotals :: Tray -> Array TrayItem -> Balance`
  - `calculatePackTotals :: Pack -> Array PackItem -> Balance`
  - `calculateTransactionTotals :: Transaction -> Array TransactionItem -> Balance`
  - `calculateGroupAccumulated :: Array BillGroup -> Array BillGroup`
  - `calculateBillGrandTotal :: Bill -> Balance`
  - `applyPurityConversion :: Number -> Number -> Number` (purity, weight → effective weight)
  - `convertGramsToBaht :: Number -> Number` (grams → baht)
  - `convertBahtToGrams :: Number -> Number` (baht → grams)

#### 1.5 Validation
- [ ] Create `src/Bill/Validation.purs`:
  - `validateTray :: Tray -> Array TrayItem -> Either String Unit`
  - `validatePack :: Pack -> Array PackItem -> Either String Unit`
  - `validateTransaction :: Transaction -> Array TransactionItem -> Either String Unit`
  - `validatePriceRate :: Number -> Number -> Boolean` (rate, announced_price → valid?)
  - `validateBalance :: Customer -> Balance -> Either String Unit` (check sufficient balance)

#### 1.6 HTTP API Endpoints
- [ ] Create `src/Server/BillAPI.purs`:
  - `GET /api/bills/:id` - Get bill with all groups and items
  - `POST /api/bills` - Create new bill for customer
  - `PUT /api/bills/:id` - Update bill
  - `DELETE /api/bills/:id` - Delete bill
  - `GET /api/bills/customer/:id` - Get customer's bills
  - `GET /api/bills/date/:date` - Get bills by date
  - `POST /api/bills/:id/groups` - Add group (tray/pack/transaction)
  - `PUT /api/bills/:id/groups/:gid` - Update group
  - `DELETE /api/bills/:id/groups/:gid` - Delete group
  - `PUT /api/bills/:id/groups/reorder` - Reorder groups
  - `POST /api/bills/:id/groups/:gid/items` - Add item
  - `PUT /api/bills/:id/groups/:gid/items/:iid` - Update item
  - `DELETE /api/bills/:id/groups/:gid/items/:iid` - Delete item
  - `PUT /api/bills/:id/groups/:gid/items/reorder` - Reorder items

---

### Phase 2: Frontend Core Components (Week 4-5)

#### 2.1 Bill State Management
- [ ] Create `src/Component/BillEditor/State.purs`:
  - `State` type with bill, groups, items, UI state
  - `Action` type for all user actions
  - `initialState :: State`
  - `reducer :: State -> Action -> State`

#### 2.2 Main Bill Editor Component
- [ ] Create `src/Component/BillEditor.purs`:
  - Main container component
  - Customer info header
  - Previous balance display
  - Groups list (drag-and-drop container)
  - Grand total footer
  - Action buttons (Save, Cancel, Print)

#### 2.3 Group Components
- [ ] Create `src/Component/BillEditor/TrayGroup.purs`:
  - Tray settings form
  - Tray items list
  - Add/edit/delete item buttons
  - Tray totals display
  - Accumulated totals display

- [ ] Create `src/Component/BillEditor/PackGroup.purs`:
  - Pack settings (internal_id, user_number)
  - Pack items list
  - Add/edit/delete item buttons
  - Pack totals display
  - Accumulated totals display

- [ ] Create `src/Component/BillEditor/TransactionGroup.purs`:
  - Transaction items list
  - Add transaction button with type selector
  - Edit/delete item buttons
  - Transaction totals display
  - Accumulated totals display (checkpoint)

#### 2.4 Item Components
- [ ] Create `src/Component/BillEditor/TrayItem.purs`:
  - Making charge input
  - Jewelry type dropdown
  - Design name input
  - Nominal weight dropdown (½ส, 1ส, 2ส, etc.)
  - Quantity input
  - Amount display (auto-calculated)

- [ ] Create `src/Component/BillEditor/PackItem.purs`:
  - Deduction rate input (with validation)
  - Shape selector (Jewelry/Bar)
  - Purity input (NULL/100/custom)
  - Description input
  - Weight input (with unit: g or บ)
  - Calculation amount display

- [ ] Create `src/Component/BillEditor/TransactionItem.purs`:
  - Transaction type selector
  - Dynamic fields based on type:
    - Money: amount input
    - Gold In/Out: amount + unit selector (grams/baht)
    - Buy/Sell: amount + unit + price rate
    - Convert: source amount + source unit + dest amount + dest unit + charge rate
    - Convert Grams↔Baht: balance type + amount
    - Split Bar: balance type + amount + charge rate

---

### Phase 3: Drag-and-Drop & Interactions (Week 6)

#### 3.1 Drag-and-Drop Setup
- [ ] Research PureScript drag-and-drop libraries or FFI options
- [ ] Create `src/Component/BillEditor/DragDrop.purs`:
  - FFI bindings to JavaScript drag-and-drop
  - `DragDropState` type
  - `onDragStart`, `onDragOver`, `onDrop` handlers
  - Visual feedback during drag

#### 3.2 Group Reordering
- [ ] Implement drag handle for groups
- [ ] Update `display_order` on drop
- [ ] Recalculate accumulated totals after reorder
- [ ] Animate reordering

#### 3.3 Item Reordering
- [ ] Implement drag handle for items within groups
- [ ] Update `display_order` on drop
- [ ] Recalculate group totals after reorder
- [ ] Animate reordering

#### 3.4 Inline Editing
- [ ] Click-to-edit for all editable fields
- [ ] Auto-save on blur or Enter key
- [ ] Cancel on Escape key
- [ ] Validation feedback
- [ ] Optimistic updates

---

### Phase 4: Calculations & Validation (Week 7)

#### 4.1 Real-time Calculations
- [ ] Implement calculation pipeline:
  1. Item changes → Group totals
  2. Group totals → Accumulated totals
  3. All groups → Grand total
- [ ] Debounce calculations (avoid excessive recalc)
- [ ] Show loading state during calculation
- [ ] Display calculation breakdown on hover

#### 4.2 Validation Rules
- [ ] Implement all validation rules from specs:
  - Price rate within threshold of announced price
  - Sufficient customer balance for debits
  - Valid purity values
  - Valid weight values
  - Valid deduction rate format
  - Mutual exclusivity of grams/baht
- [ ] Show validation errors inline
- [ ] Prevent save if validation fails
- [ ] Highlight invalid fields

#### 4.3 Balance Updates
- [ ] Calculate final balances from bill
- [ ] Show balance changes (before → after)
- [ ] Warn if balance goes negative
- [ ] Update customer balances on bill save

---

### Phase 5: UI Polish & UX (Week 8)

#### 5.1 Styling
- [ ] Design consistent with existing pages
- [ ] Responsive layout (desktop-first, gold shop context)
- [ ] Color coding:
  - Debit (red/negative)
  - Credit (green/positive)
  - Neutral (gray)
- [ ] Typography hierarchy
- [ ] Spacing and alignment

#### 5.2 Visual Feedback
- [ ] Loading states for all async operations
- [ ] Success/error toasts
- [ ] Confirmation dialogs for destructive actions
- [ ] Highlight newly added items
- [ ] Fade out deleted items
- [ ] Smooth transitions

#### 5.3 Keyboard Shortcuts
- [ ] Tab navigation through fields
- [ ] Enter to save/add
- [ ] Escape to cancel
- [ ] Ctrl+S to save bill
- [ ] Ctrl+Z to undo (if feasible)

#### 5.4 Accessibility
- [ ] Proper ARIA labels
- [ ] Focus management
- [ ] Screen reader support
- [ ] Keyboard-only navigation

---

### Phase 6: Advanced Features (Week 9-10)

#### 6.1 Templates & Presets
- [ ] Save tray settings as template
- [ ] Quick-add common transactions
- [ ] Recent jewelry types dropdown
- [ ] Common deduction rates dropdown

#### 6.2 Printing
- [ ] Create print layout component
- [ ] Format bill for thermal printer
- [ ] Include all groups and items
- [ ] Show totals and balances
- [ ] Print preview

#### 6.3 History & Audit
- [ ] Track all changes to bill
- [ ] Show edit history
- [ ] Who edited what and when
- [ ] Revert to previous version (if needed)

#### 6.4 Multi-clerk Collaboration (WebSocket)
- [ ] Real-time updates when other clerk edits same bill
- [ ] Lock mechanism to prevent conflicts
- [ ] Show who's currently editing
- [ ] Merge changes intelligently

---

### Phase 7: Testing (Week 11)

#### 7.1 Unit Tests
- [ ] Test all calculation functions
- [ ] Test validation functions
- [ ] Test type conversions
- [ ] Test balance updates
- [ ] Test edge cases (negative balances, zero values, etc.)

#### 7.2 Integration Tests
- [ ] Test API endpoints
- [ ] Test database operations
- [ ] Test transaction rollback
- [ ] Test concurrent updates

#### 7.3 E2E Tests
- [ ] Test complete bill creation flow
- [ ] Test drag-and-drop
- [ ] Test inline editing
- [ ] Test calculations
- [ ] Test printing

#### 7.4 Manual Testing
- [ ] Test with real data
- [ ] Test with edge cases from specs
- [ ] Test performance with large bills
- [ ] Test on different browsers
- [ ] Test keyboard navigation

---

### Phase 8: Deployment & Documentation (Week 12)

#### 8.1 Documentation
- [ ] API documentation
- [ ] Component documentation
- [ ] User guide (Thai language)
- [ ] Developer guide
- [ ] Calculation examples

#### 8.2 Deployment
- [ ] Database migration in production
- [ ] Deploy backend API
- [ ] Deploy frontend
- [ ] Monitor for errors
- [ ] Performance monitoring

#### 8.3 Training
- [ ] Train clerks on new module
- [ ] Create video tutorials
- [ ] Create quick reference guide
- [ ] Gather feedback

---

## Technical Decisions

### Architecture

**Pattern:** Halogen component hierarchy with centralized state management

```
BillEditor (main container)
├── CustomerHeader
├── PreviousBalanceDisplay
├── GroupsList (drag-drop container)
│   ├── TrayGroup (draggable)
│   │   ├── TraySettings
│   │   └── TrayItemsList
│   │       └── TrayItem (draggable)
│   ├── PackGroup (draggable)
│   │   ├── PackSettings
│   │   └── PackItemsList
│   │       └── PackItem (draggable)
│   └── TransactionGroup (draggable)
│       └── TransactionItemsList
│           └── TransactionItem (draggable)
├── GrandTotalFooter
└── ActionButtons
```

### State Management

**Approach:** Single source of truth in parent component, pass down via props

```purescript
type State =
  { bill :: Bill
  , groups :: Array BillGroup
  , items :: Map Int (Array Item)  -- groupId -> items
  , editingItem :: Maybe { groupId :: Int, itemId :: Int }
  , dragState :: Maybe DragState
  , validationErrors :: Map String String
  , isDirty :: Boolean
  , isSaving :: Boolean
  }
```

### API Communication

**Pattern:** Optimistic updates with rollback on error

```purescript
updateItem item = do
  -- 1. Update local state immediately
  H.modify_ _ { items = updateItemInMap item }
  
  -- 2. Send to server
  result <- H.lift $ api.updateItem item
  
  -- 3. Rollback on error
  case result of
    Left err -> do
      H.modify_ _ { items = revertItemInMap item }
      showError err
    Right updated -> do
      H.modify_ _ { items = updateItemInMap updated }
```

### Calculations

**Pattern:** Pure functions with memoization

```purescript
-- Calculate once, cache result
calculateGroupTotals :: BillGroup -> Balance
calculateGroupTotals group = 
  case group of
    TrayGroupData tray -> calculateTrayTotals tray
    PackGroupData pack -> calculatePackTotals pack
    TransactionGroupData tx -> calculateTransactionTotals tx

-- Recalculate only when dependencies change
calculateAccumulated :: Array BillGroup -> Array BillGroup
calculateAccumulated = foldl accumulate []
  where
    accumulate acc group = 
      let prevTotal = maybe emptyBalance _.accumulated (last acc)
          newTotal = prevTotal + group.totals
      in acc <> [group { accumulated = newTotal }]
```

---

## Risk Mitigation

### High-Risk Areas

1. **Drag-and-Drop Complexity**
   - Risk: FFI bugs, browser compatibility
   - Mitigation: Use well-tested library, extensive testing, fallback to buttons

2. **Calculation Errors**
   - Risk: Rounding errors, incorrect formulas
   - Mitigation: Extensive unit tests, manual verification with accountant

3. **Concurrent Edits**
   - Risk: Data loss, conflicts
   - Mitigation: Optimistic locking, WebSocket updates, conflict resolution UI

4. **Performance with Large Bills**
   - Risk: Slow rendering, laggy interactions
   - Mitigation: Memoization, virtual scrolling if needed, debouncing

5. **Data Migration**
   - Risk: Data loss, corruption
   - Mitigation: Backup before migration, test on staging, rollback plan

---

## Success Metrics

- [ ] Bill creation time < 5 minutes (vs. 15 minutes with paper)
- [ ] Zero calculation errors in production
- [ ] 95% clerk satisfaction rate
- [ ] < 1 second response time for all operations
- [ ] Zero data loss incidents
- [ ] < 5% error rate in first month

---

## Dependencies

### External Libraries
- `purescript-halogen` - UI framework
- `purescript-affjax` - HTTP client
- `purescript-argonaut` - JSON encoding/decoding
- `purescript-postgresql-client` - Database access
- Drag-and-drop library (TBD - research needed)

### Internal Modules
- Existing `Customer` module
- Existing `Database` connection
- Existing `TextConstants` pattern
- Existing virtual scrolling (reference, not used here)

---

## Open Questions

1. **Drag-and-Drop Library:** Which library to use? Pure PureScript or FFI to JS library?
2. **WebSocket:** Use existing WebSocket infrastructure or create new?
3. **Printing:** Thermal printer API? PDF generation?
4. **Undo/Redo:** Worth implementing or too complex?
5. **Mobile Support:** Needed? Gold shops typically use desktop.
6. **Offline Mode:** Needed? Or always online?

---

## Next Steps

1. Review this plan with team
2. Clarify open questions
3. Set up project tracking (issues, milestones)
4. Begin Phase 0: Foundation & Setup
5. Weekly progress reviews
6. Adjust timeline based on actual progress

---

## Estimated Timeline

- **Phase 0:** 1 week (Foundation)
- **Phase 1:** 2 weeks (Backend)
- **Phase 2:** 2 weeks (Frontend Core)
- **Phase 3:** 1 week (Drag-and-Drop)
- **Phase 4:** 1 week (Calculations)
- **Phase 5:** 1 week (UI Polish)
- **Phase 6:** 2 weeks (Advanced Features)
- **Phase 7:** 1 week (Testing)
- **Phase 8:** 1 week (Deployment)

**Total:** 12 weeks (3 months)

**Buffer:** Add 20% for unknowns = ~14 weeks total

---

## Notes

- This is a complex module - don't rush
- Calculation accuracy is CRITICAL - test extensively
- User experience is important - clerks use this all day
- Performance matters - bills can have many items
- Data integrity is paramount - no data loss tolerated
