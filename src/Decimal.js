import Decimal from 'decimal.js';

// Configure decimal.js for financial calculations
Decimal.set({
  precision: 20,                    // 20 significant digits
  rounding: Decimal.ROUND_HALF_UP,  // Standard rounding (0.5 rounds up)
  toExpNeg: -7,                     // No exponential notation for small numbers
  toExpPos: 20,                     // No exponential notation for large numbers
  minE: -9e15,
  maxE: 9e15
});

// Construction
// Returns null for invalid strings, Decimal object for valid strings
// The PureScript side will wrap this in Maybe
export const fromStringImpl = function(str) {
  try {
    const d = new Decimal(str);
    if (d.isNaN()) {
      return null;
    }
    return d;
  } catch (e) {
    return null;
  }
};

export const fromInt = function(n) {
  return new Decimal(n);
};

export const fromNumber = function(n) {
  return new Decimal(n);
};

export const unsafeFromString = function(str) {
  return new Decimal(str);
};

// Conversion
export const toString = function(d) {
  return d.toString();
};

export const toNumber = function(d) {
  return d.toNumber();
};

export const toFixed = function(decimals) {
  return function(d) {
    return d.toFixed(decimals);
  };
};

// Arithmetic
export const add = function(a) {
  return function(b) {
    return a.plus(b);
  };
};

export const subtract = function(a) {
  return function(b) {
    return a.minus(b);
  };
};

export const multiply = function(a) {
  return function(b) {
    return a.times(b);
  };
};

export const divide = function(a) {
  return function(b) {
    return a.dividedBy(b);
  };
};

export const modulo = function(a) {
  return function(b) {
    return a.modulo(b);
  };
};

export const negate = function(d) {
  return d.negated();
};

export const abs = function(d) {
  return d.abs();
};

// Comparison
export const _compare = function(a) {
  return function(b) {
    return a.comparedTo(b);
  };
};

export const eq = function(a) {
  return function(b) {
    return a.equals(b);
  };
};

export const lt = function(a) {
  return function(b) {
    return a.lessThan(b);
  };
};

export const lte = function(a) {
  return function(b) {
    return a.lessThanOrEqualTo(b);
  };
};

export const gt = function(a) {
  return function(b) {
    return a.greaterThan(b);
  };
};

export const gte = function(a) {
  return function(b) {
    return a.greaterThanOrEqualTo(b);
  };
};

// Predicates
export const isZero = function(d) {
  return d.isZero();
};

export const isNegative = function(d) {
  return d.isNegative();
};

export const isPositive = function(d) {
  return d.isPositive();
};

// Rounding
export const round = function(d) {
  return d.round();
};

export const floor = function(d) {
  return d.floor();
};

export const ceil = function(d) {
  return d.ceil();
};
