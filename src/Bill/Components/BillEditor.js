export const focusInput = function () {
    requestAnimationFrame(() => {
        // Try to find the input with autofocus attribute first
        let input = document.querySelector('input[autofocus], select[autofocus]');

        // If not found, look for our specific edit classes inside the bill editor
        if (!input) {
            // Prioritize tray price input if it exists
            input = document.querySelector('.tray-price-input');

            if (!input) {
                // Then look for edit row inputs
                // We want the one that corresponds to the focused field, but since we only render one edit row at a time,
                // finding the first one might be "okay" but ideally we want the specific one.
                // However, since we added HP.autofocus in the purs file, the querySelector('input[autofocus]') should catch it.
                // If it failed, we fallback to the first input in the edit row.
                input = document.querySelector('.edit-row .edit-input, .edit-row .edit-select');
            }
        }

        if (input) {
            input.focus();
            // For text/number inputs, move cursor to end
            if (input.tagName === 'INPUT' && (input.type === 'text' || input.type === 'number')) {
                try {
                    input.select();
                } catch (e) {
                    // Ignore errors for input types that don't support selection (like number in some browsers)
                }
            }
        }
    });
};

// Check if focus left the edit row
// Returns true if focus moved outside the .edit-row element
// Returns false if focus is still within the .edit-row element
export const checkFocusLeftEditRow = function (focusEvent) {
    return function () {
        // Get the relatedTarget (where focus is moving TO)
        const relatedTarget = focusEvent.relatedTarget;

        // If no relatedTarget (focus went to null/nothing), consider it as leaving
        if (!relatedTarget) {
            return true;
        }

        // Check if relatedTarget is within an .edit-row element
        const editRow = relatedTarget.closest('.edit-row');

        // If no edit-row found, focus left the row
        return !editRow;
    };
};

// Force an input element to have a specific value
// Used to ensure validation blocks are enforced in the DOM
export const forceInputValue = function (selector) {
    return function (value) {
        return function () {
            const input = document.querySelector(selector);
            if (input && input.value !== value) {
                input.value = value;
                // Move cursor to end
                input.selectionStart = input.selectionEnd = value.length;
            }
        };
    };
};
