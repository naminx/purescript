# Customer List Component - Implementation Notes

## Overview

This is a production-ready customer management component with virtual scrolling, real-time updates, and automatic scroll-to-customer functionality.

## Features

1. **Virtual Scrolling** - Handles large datasets efficiently by only rendering visible rows
2. **Real-time Updates** - Polls server every 3 seconds for changes
3. **Optimistic Updates** - Immediate UI feedback for add/edit/delete operations
4. **Sorting** - By ID or Name, ascending/descending
5. **Search/Filter** - Real-time filtering by customer name
6. **Auto-scroll** - Automatically scrolls to newly added or edited customers
7. **Visual Highlight** - Newly added or edited customers are highlighted with an earth tone background
8. **Edit Cancellation** - Cancel editing by pressing ESC key or clicking outside the input field
9. **Delete Confirmation** - Requires entering a random 6-digit code to confirm deletion

## Key Implementation Decisions

### Virtual Scrolling

The component only renders rows that are visible in the viewport plus a small overscan buffer. This provides excellent performance even with thousands of customers.

**Height Cache**: We maintain a cache of measured row heights because:
- Rows can have variable heights (multi-line text wrapping)
- We need accurate heights to calculate scroll positions
- Measuring DOM elements is expensive, so we cache the results

### Scroll-to-Customer: The Journey

This was the most challenging part of the implementation. Here's what we tried and why:

#### ❌ Attempt 1: Simple scroll with default heights
```purescript
let yPosition = targetIndex * defaultRowHeight
scrollToPosition yPosition
```
**Problem**: Didn't account for variable row heights. Multi-line rows caused incorrect positioning.

#### ❌ Attempt 2: Scroll with height cache
```purescript
let yPosition = calculateHeightRange heightCache 0 targetIndex
scrollToPosition yPosition
```
**Problem**: Cache was empty or stale after adding/editing customers. Array indices changed but cache didn't.

#### ❌ Attempt 3: Force render specific range
```purescript
H.modify_ _ { renderedRange = { start, end }, forceRenderRange = true }
delay 100ms
measureRows
scrollToPosition
```
**Problem**: Fixed delays were unreliable. Text wrapping takes variable time depending on content length and viewport width. Sometimes measured too early, getting wrong heights.

#### ❌ Attempt 4: Multiple delays and measurements
```purescript
delay 300ms
measureRows
delay 100ms
measureRows again
delay 50ms
scrollToPosition
```
**Problem**: Still unreliable. On slower devices or with very long text, even 450ms total wasn't enough.

#### ✅ Final Solution: Callback-based with stability checking

```purescript
-- Phase 1: Rough scroll to get row into viewport
scrollToPosition roughPosition

-- Phase 2: Wait for row height to stabilize
promise <- waitForRowAndMeasureImpl targetIndex
result <- toAff promise

-- Phase 3: Scroll to exact position
scrollToPosition (result.offsetTop + result.height - containerHeight)
```

The FFI function `waitForRowAndMeasureImpl`:
```javascript
// Continuously measure row height across animation frames
// Height must be stable for 3 consecutive frames before resolving
const checkStability = () => {
  requestAnimationFrame(() => {
    const measurement = measureRow();
    if (measurement.height === lastHeight && lastHeight > 0) {
      stableCount++;
      if (stableCount >= 3) {
        resolve(measurement);  // Height is stable!
        return;
      }
    } else {
      stableCount = 0;  // Height changed, reset counter
      lastHeight = measurement.height;
    }
    checkStability();  // Continue checking
  });
};
```

**Why this works**:
- No arbitrary delays - waits for actual DOM stability
- Handles variable text wrapping times automatically
- Works reliably across different devices and content lengths
- Uses `requestAnimationFrame` for optimal timing with browser rendering

### Height Cache Management

**Problem**: The original implementation used an index-based cache that got cleared on every add/edit/delete operation, making it barely useful as a cache.

**Solution**: Store `rowHeight` directly in each Customer record (in memory only, not in database):

```purescript
type Customer =
  { id :: Int
  , name :: String
  , updated_at :: Maybe String
  , rowHeight :: Maybe Number  -- Cached in memory
  }
```

**Benefits**:
- Cache survives sorting (height moves with customer)
- Cache survives filtering (height stays with customer)
- Only invalidated when that specific customer's name is edited
- Each PC has its own cache appropriate for its viewport width
- No database changes needed

**How it works**:
1. SQL query returns `NULL as row_height` which maps to `Nothing`
2. When row is first rendered, `MeasureRenderedRows` updates `rowHeight = Just 37.0`
3. When name is edited, server returns `NULL` which resets to `Nothing`
4. When merging server updates, we preserve existing `rowHeight` unless name changed

### Container Height Issue

**Problem**: The initial state had `containerHeight: 600.0`, but the actual viewport was 504px (96px difference). This caused the first scroll to be off by 96 pixels.

**Solution**: Measure actual container height from DOM before scrolling:
```purescript
mbContainer <- H.liftEffect $ getCustomerListElement
actualHeight <- case mbContainer of
  Just element -> H.liftEffect $ getClientHeight element
  Nothing -> pure state.containerHeight
```

### Blank Space After Deletion

**Problem**: After deleting a tall row (e.g., 198px), the viewport had blank space at the bottom because the virtual scrolling didn't recalculate the visible range.

**Solution**: Trigger a re-render after deletion:
```purescript
DeleteCustomer id -> do
  -- ... delete customer ...
  -- Get current scroll position and trigger recalculation
  scrollTop <- H.liftEffect $ getScrollTop element
  H.modify_ _ { scrollTop = scrollTop }  -- Triggers re-render
  handleAction db MeasureRenderedRows
```

### Visual Highlight for Recent Changes

**Problem**: When adding a customer with a name that sorts to the top (e.g., "Alice"), it's difficult to confirm the addition since it doesn't scroll into view at the bottom.

**Solution**: Add a visual highlight to the most recently added or edited customer:

```purescript
type State =
  { ...
  , highlightedCustomerId :: Maybe Int
  }

-- Set highlight on add/edit
AddCustomer -> H.modify_ _ { highlightedCustomerId = Just newCustomer.id }
SaveEdit -> H.modify_ _ { highlightedCustomerId = Just id }

-- Clear highlight on delete or next operation
DeleteCustomer -> H.modify_ _ { highlightedCustomerId = Nothing }
```

**CSS**: Earth tone background that's readable with black text:
```css
.customer-row-highlighted {
  background-color: #f5e6d3;  /* Warm beige/tan */
  transition: background-color 0.3s ease;
}
```

**Behavior**:
- Highlight persists across scrolling
- Cleared when any customer is deleted
- Replaced when another customer is added or edited
- Provides visual confirmation of the most recent change

## Internationalization

All text constants are gathered in one place for easy translation:

```purescript
textConstants :: TextConstants
textConstants =
  { appTitle: "Customer Management"
  , customersCount: \n -> show n <> " customers"
  , columnId: "ID"
  , columnName: "Name"
  , columnActions: "Actions"
  , newCustomerPlaceholder: "New Customer Name"
  }
```

To translate to Thai, simply update these values:
```purescript
textConstants =
  { appTitle: "การจัดการลูกค้า"
  , customersCount: \n -> show n <> " ราย"
  , columnId: "รหัส"
  , columnName: "ชื่อ"
  , columnActions: "การดำเนินการ"
  , newCustomerPlaceholder: "ชื่อลูกค้าใหม่"
  }
```

## Performance Considerations

1. **Virtual Scrolling**: Only ~20-30 rows rendered at any time, regardless of total dataset size
2. **Per-Customer Height Caching**: Each customer caches its own height, survives sorting/filtering
3. **Optimistic Updates**: Immediate UI feedback without waiting for server
4. **Debounced Polling**: 3-second interval prevents excessive server requests
5. **Smooth Transitions**: CSS transitions for highlight effects (0.3s ease)

## Testing Recommendations

1. Test with very long customer names (multi-line wrapping)
2. Test on different screen sizes and zoom levels
3. Test with slow network (polling should handle delays gracefully)
4. Test concurrent edits from multiple users
5. Test with 1000+ customers to verify virtual scrolling performance

## Known Limitations

1. Polling interval is fixed at 3 seconds (could be made configurable)
2. No WebSocket support for real-time updates (uses polling instead)
3. Search is client-side only (could be moved to server for very large datasets)
4. No pagination (relies entirely on virtual scrolling)

## User Experience Features

### Edit Cancellation

Users can cancel editing in two ways:
1. **ESC key**: Press ESC while editing to cancel and revert changes
2. **Click outside**: Click anywhere outside the input field to cancel editing

Implementation uses FFI to detect clicks outside the input element:
```javascript
export const checkClickOutsideInput = function(target) {
  return function() {
    const input = document.querySelector('.customer-name-input');
    if (!input) return true;
    return !input.contains(target);
  };
};
```

### Delete Confirmation

To prevent accidental deletions, the system requires confirmation:
1. Click delete button shows a modal dialog
2. Dialog displays a random 6-digit code (100000-999999)
3. User must type the exact code to confirm deletion
4. Can cancel with ESC key or Cancel button

This provides strong protection against accidental deletions while being more user-friendly than a simple "Are you sure?" dialog.

## Future Enhancements

1. Add WebSocket support for true real-time updates
2. Make polling interval configurable
3. Add server-side search/filter for massive datasets
4. Add bulk operations (delete multiple, export, etc.)
5. Add undo/redo functionality
6. Add keyboard navigation (arrow keys, etc.)
