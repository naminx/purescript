# Changelog

## Version 2.0 - Enhanced Cache and Visual Feedback

### Major Improvements

#### 1. Per-Customer Height Caching (Performance)
**Problem**: The original index-based cache was cleared on every add/edit/delete operation, making it ineffective.

**Solution**: Store `rowHeight` directly in each Customer record (in memory only).

**Benefits**:
- Cache survives sorting and filtering
- Only invalidated when that specific customer's name is edited
- Significantly smoother scrolling experience
- Each device maintains its own cache appropriate for its viewport width

**Technical Details**:
- Added `rowHeight :: Maybe Number` field to Customer type
- SQL queries return `NULL as row_height` (maps to `Nothing` in PureScript)
- `MeasureRenderedRows` updates customers by ID instead of array index
- Server merge preserves `rowHeight` unless name changed

#### 2. Visual Highlight for Recent Changes (UX)
**Problem**: When adding a customer with a name that sorts to the top (e.g., "Alice"), it's difficult to confirm the addition.

**Solution**: Highlight the most recently added or edited customer with an earth tone background.

**Features**:
- Warm beige/tan background (#f5e6d3) that's readable with black text
- Smooth CSS transition (0.3s ease)
- Persists across scrolling
- Cleared on delete or next add/edit operation

**Technical Details**:
- Added `highlightedCustomerId :: Maybe Int` to State
- Set on `AddCustomer` and `SaveEdit`
- Cleared on `DeleteCustomer`
- Applied via `customer-row-highlighted` CSS class

### Files Changed

**PureScript**:
- `src/Component/CustomerList.purs` - Main component with cache and highlight logic
- `src/Component/CustomerList.js` - FFI functions updated to return customer ID
- `src/Database/Types.purs` - Customer type updated with rowHeight field
- `src/Database/Mock.purs` - Mock data updated with rowHeight field

**Server**:
- `server.js` - All SQL queries updated to include `NULL as row_height`

**Documentation**:
- `IMPLEMENTATION_NOTES.md` - Comprehensive implementation details
- `CHANGELOG.md` - This file

### Performance Impact

**Before**:
- Height cache cleared on every operation
- Frequent re-measurements during scrolling
- Noticeable lag with multi-line rows

**After**:
- Height cache persists across operations
- Measurements only on first render or after name edit
- Smooth scrolling even with variable-height rows

### Breaking Changes

None. The API remains the same. The `rowHeight` field is transparent to the database layer.

### Migration Notes

If you're upgrading from version 1.0:
1. Restart the server to pick up SQL query changes
2. Clear browser cache to load new JavaScript bundle
3. No database schema changes required
4. Existing data works without modification

### Testing Recommendations

1. **Cache Persistence**:
   - Add a customer with long text (multi-line)
   - Scroll away and back
   - Verify smooth scrolling (no re-measurement)
   - Sort the list
   - Verify cache still works

2. **Highlight Feature**:
   - Add customer "Alice" (sorts to top)
   - Verify highlight appears
   - Scroll to find the highlighted row
   - Add another customer
   - Verify first highlight disappears, new one appears
   - Delete any customer
   - Verify highlight disappears

3. **Edit Operations**:
   - Edit a customer's name
   - Verify highlight appears
   - Verify rowHeight is invalidated (re-measured on next render)

### Known Limitations

1. **Highlight Persistence**: Highlight is cleared on any delete, even if deleting a different customer
   - This is intentional to keep the implementation simple
   - Could be enhanced to only clear if deleting the highlighted customer

2. **Cache Invalidation**: Changing viewport width (zoom, responsive design) doesn't invalidate cache
   - Heights remain from previous viewport width
   - Workaround: Refresh page after significant viewport changes
   - Could be enhanced with viewport width tracking

### Future Enhancements

1. Add animation when scrolling to highlighted customer
2. Add option to manually clear highlight (e.g., ESC key)
3. Track viewport width and invalidate cache on significant changes
4. Add highlight color customization via theme system
5. Add accessibility improvements (ARIA labels for highlighted state)

---

## Version 1.0 - Initial Release

### Features

1. Virtual scrolling for large datasets
2. Real-time updates via polling (3 seconds)
3. Optimistic updates for add/edit/delete
4. Sorting by ID or Name
5. Search/filter functionality
6. Auto-scroll to newly added/edited customers
7. Callback-based scroll with height stability checking
8. Internationalization support via text constants

### Technical Highlights

- PureScript + Halogen framework
- PostgreSQL database
- Node.js server
- Virtual scrolling with variable row heights
- Height stability checking via requestAnimationFrame
- Optimistic UI updates with server reconciliation
