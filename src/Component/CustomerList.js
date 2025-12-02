export const getScrollTop = function (element) {
  return function () {
    return element.scrollTop;
  };
};

export const getClientHeight = function (element) {
  return function () {
    return element.clientHeight;
  };
};

export const scrollToPosition = function (scrollTop) {
  return function () {
    const listElement = document.querySelector('.customer-list');
    if (listElement) {
      listElement.scrollTo({
        top: scrollTop,
        behavior: 'smooth'
      });
    }
  };
};

export const getCustomerListElementImpl = function () {
  const element = document.querySelector('.customer-list');
  return element;
};

export const measureRowHeights = function () {
  const rows = document.querySelectorAll('.customer-row[data-row-index]');
  const measurements = [];

  rows.forEach(row => {
    const index = parseInt(row.getAttribute('data-row-index'), 10);
    const customerId = parseInt(row.getAttribute('data-customer-id'), 10);
    const height = row.offsetHeight;
    measurements.push({ index, customerId, height });
  });

  return measurements;
};

export const requestAnimationFrameAction = function () {
  return new Promise((resolve) => {
    requestAnimationFrame(() => {
      resolve();
    });
  });
};



export const waitForRowAndMeasureImpl = function (rowIndex) {
  return function () {
    return new Promise((resolve, reject) => {
      const container = document.querySelector('.visible-rows');
      if (!container) {
        reject(new Error('Container not found'));
        return;
      }

      let lastHeight = 0;
      let stableCount = 0;
      const requiredStableCount = 3; // Height must be stable for 3 consecutive frames
      let timeoutId = null;

      const measureRow = function () {
        const row = document.querySelector(`.customer-row[data-row-index="${rowIndex}"]`);
        if (!row) {
          return null;
        }

        // Force layout
        void row.offsetHeight;
        void container.offsetHeight;

        let offsetTop = row.offsetTop;
        const visibleRowsStyle = window.getComputedStyle(container);
        const transform = visibleRowsStyle.transform;
        if (transform && transform !== 'none') {
          const matrix = new DOMMatrix(transform);
          offsetTop += matrix.m42;
        }

        return { offsetTop, height: row.offsetHeight };
      };

      const checkStability = function () {
        requestAnimationFrame(() => {
          const measurement = measureRow();

          if (!measurement) {
            // Row not found yet, try again
            checkStability();
            return;
          }

          // Check if height is stable
          if (measurement.height === lastHeight && lastHeight > 0) {
            stableCount++;
            if (stableCount >= requiredStableCount) {
              // Height is stable, resolve
              if (timeoutId) clearTimeout(timeoutId);
              resolve(measurement);
              return;
            }
          } else {
            // Height changed, reset counter
            stableCount = 0;
            lastHeight = measurement.height;
          }

          // Continue checking
          checkStability();
        });
      };

      // Start checking
      checkStability();

      // Timeout after 5 seconds
      timeoutId = setTimeout(() => {
        reject(new Error(`Timeout waiting for row ${rowIndex} to stabilize`));
      }, 5000);
    });
  };
};

export const checkClickOutsideInput = function (target) {
  return function () {
    // Check if any input field is active
    const nameInput = document.querySelector('.customer-name-input');
    const moneyInput = document.querySelector('.money-input');
    const goldInput = document.querySelector('.gold-input');
    const activeInput = nameInput || moneyInput || goldInput;

    if (!activeInput) {
      return true; // No input found, consider it outside
    }

    // Don't cancel if clicking any input itself
    if (activeInput.contains(target)) {
      return false;
    }

    // Don't cancel if clicking an editable field (to start editing another field)
    const editableField = target.closest('.editable-field');
    if (editableField) {
      return false;
    }

    // Cancel for everything else (delete button, outside table, etc.)
    return true;
  };
};

export const generateRandomCode = function () {
  // Generate random 6-digit number (100000 to 999999)
  return Math.floor(Math.random() * 900000) + 100000;
};

export const focusDeleteConfirmInput = function () {
  // Use requestAnimationFrame to ensure DOM is ready
  requestAnimationFrame(() => {
    const input = document.querySelector('.modal-input');
    if (input) {
      input.focus();
    }
  });
};

export const focusEditInput = function () {
  // Use requestAnimationFrame to ensure DOM is ready
  requestAnimationFrame(() => {
    // Find any active input field
    const nameInput = document.querySelector('.customer-name-input');
    const moneyInput = document.querySelector('.money-input');
    const goldInput = document.querySelector('.gold-input');
    const input = nameInput || moneyInput || goldInput;

    if (input) {
      input.focus();
      // Select all text for easy replacement
      input.select();
    }
  });
};

export const formatDateString = function (dateStr) {
  if (!dateStr) return "";

  const date = new Date(dateStr);
  const now = new Date();
  const currentYear = now.getFullYear();
  const dateYear = date.getFullYear();

  const day = date.getDate();
  const month = date.getMonth() + 1;

  if (dateYear === currentYear) {
    return `${day}/${month}`;
  } else {
    return `${day}/${month}/${dateYear}`;
  }
};

export const formatMoneyValue = function (n) {
  const absN = Math.abs(n);
  const intPart = Math.floor(absN);
  const fracPart = Math.round((absN - intPart) * 100);
  const fracStr = fracPart < 10 ? '0' + fracPart : fracPart.toString();
  return {
    integer: intPart.toLocaleString(),
    fraction: fracStr
  };
};

export const formatGramsValue = function (n) {
  const absN = Math.abs(n);
  if (absN === 0) return { integer: "", fraction: "" };

  const intPart = Math.floor(absN);
  const fracPart = Math.round((absN - intPart) * 1000);
  const fracStr = fracPart.toString().padStart(3, '0');

  return {
    integer: intPart.toLocaleString(),
    fraction: fracStr
  };
};

export const formatBahtValue = function (n) {
  const absN = Math.abs(n);
  if (absN === 0) return { integer: "", fraction: "", hasFraction: false };

  const intPart = Math.floor(absN);
  const fracPart = absN - intPart;

  if (fracPart === 0) {
    return { integer: intPart.toLocaleString(), fraction: "", hasFraction: false };
  } else {
    // Format fraction with up to 3 decimals, removing trailing zeros
    const fracStr = fracPart.toFixed(3).substring(1).replace(/0+$/, '');
    return { integer: intPart.toLocaleString(), fraction: fracStr, hasFraction: true };
  }
};
