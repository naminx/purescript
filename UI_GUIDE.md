# UI Guide - Customer Management Application

## Application Layout

```
┌─────────────────────────────────────────────────────────┐
│                  Customer Management                     │
├─────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────┐  │
│  │ ID ↕  │  Name ↕  │  Actions                       │  │  ← Header (sortable)
│  ├───────────────────────────────────────────────────┤  │
│  │ 1     │  Alice Johnson  │  [✏️] [🗑️]             │  │
│  │ 2     │  Bob Smith      │  [✏️] [🗑️]             │  │
│  │ 3     │  Charlie Brown  │  [✏️] [🗑️]             │  │
│  │                                                     │  │
│  │                  (scrollable area)                  │  │
│  │                                                     │  │
│  └───────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  [New Customer Name...        ] [➕ Add]                │  ← Sticky form
└─────────────────────────────────────────────────────────┘
```

## Interactive Elements

### 1. Table Header (Sortable Columns)

**ID Column:**
```
┌──────────┐
│ ID ↕     │  ← Click to sort by ID
└──────────┘
```

**Name Column:**
```
┌──────────┐
│ Name ↕   │  ← Click to sort by Name
└──────────┘
```

**Sort States:**
- `↕` = Not sorted (neutral)
- `↑` = Sorted ascending
- `↓` = Sorted descending

**Behavior:**
- First click: Sort ascending
- Second click: Sort descending
- Third click: Sort ascending (cycles)

### 2. Customer Row (Normal State)

```
┌─────────────────────────────────────────────────────┐
│ 1  │  Alice Johnson  │  [✏️ Edit] [🗑️ Delete]     │
└─────────────────────────────────────────────────────┘
```

**Actions:**
- **Edit Icon (✏️)**: Click to enter edit mode
- **Delete Icon (🗑️)**: Click to delete customer (immediate)

### 3. Customer Row (Edit Mode)

```
┌─────────────────────────────────────────────────────┐
│ 1  │  [Alice Johnson___]  │  [✓ Save] [🗑️ Delete] │
└─────────────────────────────────────────────────────┘
```

**Changes:**
- Name becomes editable input field
- Edit icon (✏️) changes to Save icon (✓)
- Delete icon (🗑️) remains available

**Actions:**
- **Save Icon (✓)**: Click to save changes
- **Delete Icon (🗑️)**: Still available during edit

### 4. Add Customer Form (Sticky Bottom)

```
┌─────────────────────────────────────────────────────┐
│  [New Customer Name...        ] [➕ Add]            │
└─────────────────────────────────────────────────────┘
```

**Features:**
- Always visible at bottom (sticky positioning)
- Input field for customer name
- Add button with plus icon
- Form clears after submission

## Icon Reference

### Action Icons (16x16)
- **✏️ Edit**: Pencil icon - Enter edit mode
- **✓ Save**: Checkmark icon - Save changes
- **🗑️ Delete**: Trash can icon - Delete customer
- **➕ Add**: Plus sign icon - Add new customer

### Sort Icons (14x14)
- **↕ Neutral**: Both arrows - Column not sorted
- **↑ Ascending**: Up arrow - Sorted A→Z or 1→9
- **↓ Descending**: Down arrow - Sorted Z→A or 9→1

## User Workflows

### Sorting Customers

**By ID (Ascending):**
1. Click "ID ↕" header
2. Icon changes to "ID ↑"
3. List shows: 1, 2, 3, 4...

**By ID (Descending):**
1. Click "ID ↑" header again
2. Icon changes to "ID ↓"
3. List shows: ...4, 3, 2, 1

**By Name:**
1. Click "Name ↕" header
2. Icon changes to "Name ↑"
3. List shows: Alice, Bob, Charlie...

**Multiple Sort Keys (Stable Sort):**
1. Sort by Name first
2. Then sort by ID
3. Customers with same ID maintain name order

### Editing a Customer

1. **Start Edit:**
   - Click edit icon (✏️) on customer row
   - Name field becomes editable
   - Edit icon changes to save icon (✓)

2. **Make Changes:**
   - Type new name in input field
   - Changes are local (not saved yet)

3. **Save Changes:**
   - Click save icon (✓)
   - Name updates in database
   - Row returns to normal state
   - List refreshes

### Deleting a Customer

1. **Delete:**
   - Click delete icon (🗑️) on customer row
   - Customer is immediately removed
   - List refreshes automatically

2. **During Edit:**
   - Delete icon remains available
   - Can delete while editing
   - No need to save first

### Adding a Customer

1. **Enter Name:**
   - Type name in bottom input field
   - Field shows placeholder "New Customer Name..."

2. **Submit:**
   - Click add button (➕ Add)
   - Or press Enter in input field
   - Customer is added to database

3. **Result:**
   - Input field clears
   - List refreshes with new customer
   - New customer appears in list

## Color Scheme

- **Blue (#007bff)**: Edit actions
- **Green (#28a745)**: Save/Add actions
- **Red (#dc3545)**: Delete actions
- **Gray (#495057)**: Headers and neutral elements

## Responsive Behavior

- **List Container**: Max height 80vh, scrolls vertically
- **Add Form**: Sticky at bottom, always visible
- **Buttons**: Hover effects with subtle animations
- **Icons**: Scale appropriately, maintain aspect ratio

## Accessibility

- **Tooltips**: All icon buttons have title attributes
- **Keyboard**: Form submission works with Enter key
- **Visual Feedback**: Hover states on all interactive elements
- **Clear Icons**: Recognizable symbols for all actions
