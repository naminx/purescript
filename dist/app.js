(() => {
  // output/Component.CustomerList/foreign.js
  var getScrollTop = function(element4) {
    return function() {
      return element4.scrollTop;
    };
  };
  var getClientHeight = function(element4) {
    return function() {
      return element4.clientHeight;
    };
  };
  var scrollToPosition = function(scrollTop2) {
    return function() {
      const listElement = document.querySelector(".customer-list");
      if (listElement) {
        listElement.scrollTo({
          top: scrollTop2,
          behavior: "smooth"
        });
      }
    };
  };
  var getCustomerListElementImpl = function() {
    const element4 = document.querySelector(".customer-list");
    return element4;
  };
  var measureRowHeights = function() {
    const rows4 = document.querySelectorAll(".customer-row[data-row-index]");
    const measurements = [];
    rows4.forEach((row) => {
      const index4 = parseInt(row.getAttribute("data-row-index"), 10);
      const customerId = parseInt(row.getAttribute("data-customer-id"), 10);
      const height9 = row.offsetHeight;
      measurements.push({ index: index4, customerId, height: height9 });
    });
    return measurements;
  };
  var requestAnimationFrameAction = function() {
    return new Promise((resolve) => {
      requestAnimationFrame(() => {
        resolve();
      });
    });
  };
  var waitForRowAndMeasureImpl = function(rowIndex2) {
    return function() {
      return new Promise((resolve, reject) => {
        const container = document.querySelector(".visible-rows");
        if (!container) {
          reject(new Error("Container not found"));
          return;
        }
        let lastHeight = 0;
        let stableCount = 0;
        const requiredStableCount = 3;
        let timeoutId = null;
        const measureRow = function() {
          const row = document.querySelector(`.customer-row[data-row-index="${rowIndex2}"]`);
          if (!row) {
            return null;
          }
          void row.offsetHeight;
          void container.offsetHeight;
          let offsetTop2 = row.offsetTop;
          const visibleRowsStyle = window.getComputedStyle(container);
          const transform = visibleRowsStyle.transform;
          if (transform && transform !== "none") {
            const matrix = new DOMMatrix(transform);
            offsetTop2 += matrix.m42;
          }
          return { offsetTop: offsetTop2, height: row.offsetHeight };
        };
        const checkStability = function() {
          requestAnimationFrame(() => {
            const measurement = measureRow();
            if (!measurement) {
              checkStability();
              return;
            }
            if (measurement.height === lastHeight && lastHeight > 0) {
              stableCount++;
              if (stableCount >= requiredStableCount) {
                if (timeoutId) clearTimeout(timeoutId);
                resolve(measurement);
                return;
              }
            } else {
              stableCount = 0;
              lastHeight = measurement.height;
            }
            checkStability();
          });
        };
        checkStability();
        timeoutId = setTimeout(() => {
          reject(new Error(`Timeout waiting for row ${rowIndex2} to stabilize`));
        }, 5e3);
      });
    };
  };
  var checkClickOutsideInput = function(target6) {
    return function() {
      const nameInput = document.querySelector(".customer-name-input");
      const moneyInput = document.querySelector(".money-input");
      const goldInput = document.querySelector(".gold-input");
      const activeInput = nameInput || moneyInput || goldInput;
      if (!activeInput) {
        return true;
      }
      if (activeInput.contains(target6)) {
        return false;
      }
      const editableField = target6.closest(".editable-field");
      if (editableField) {
        return false;
      }
      return true;
    };
  };
  var generateRandomCode = function() {
    return Math.floor(Math.random() * 9e5) + 1e5;
  };
  var focusDeleteConfirmInput = function() {
    requestAnimationFrame(() => {
      const input3 = document.querySelector(".modal-input");
      if (input3) {
        input3.focus();
      }
    });
  };
  var focusEditInput = function() {
    requestAnimationFrame(() => {
      const nameInput = document.querySelector(".customer-name-input");
      const moneyInput = document.querySelector(".money-input");
      const goldInput = document.querySelector(".gold-input");
      const input3 = nameInput || moneyInput || goldInput;
      if (input3) {
        input3.focus();
        const length9 = input3.value.length;
        input3.setSelectionRange(length9, length9);
      }
    });
  };
  var formatDateString = function(dateStr) {
    if (!dateStr) return "";
    const date = new Date(dateStr);
    const now = /* @__PURE__ */ new Date();
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
  var formatMoneyValue = function(d) {
    const n = d.toNumber();
    const absN = Math.abs(n);
    const intPart = Math.floor(absN);
    const fracPart = Math.round((absN - intPart) * 100);
    const fracStr = fracPart < 10 ? "0" + fracPart : fracPart.toString();
    return {
      integer: intPart.toLocaleString(),
      fraction: fracStr
    };
  };
  var formatGramsValue = function(d) {
    const n = d.toNumber();
    const absN = Math.abs(n);
    if (absN === 0) return { integer: "", fraction: "" };
    const intPart = Math.floor(absN);
    const fracPart = Math.round((absN - intPart) * 1e3);
    const fracStr = fracPart.toString().padStart(3, "0");
    return {
      integer: intPart.toLocaleString(),
      fraction: fracStr
    };
  };
  var formatBahtValue = function(d) {
    const n = d.toNumber();
    const absN = Math.abs(n);
    if (absN === 0) return { integer: "", fraction: "", hasFraction: false };
    const intPart = Math.floor(absN);
    const fracPart = absN - intPart;
    if (fracPart === 0) {
      return { integer: intPart.toLocaleString(), fraction: "", hasFraction: false };
    } else {
      const fracStr = fracPart.toFixed(3).substring(1).replace(/0+$/, "");
      return { integer: intPart.toLocaleString(), fraction: fracStr, hasFraction: true };
    }
  };

  // output/Control.Apply/foreign.js
  var arrayApply = function(fs) {
    return function(xs) {
      var l2 = fs.length;
      var k = xs.length;
      var result = new Array(l2 * k);
      var n = 0;
      for (var i2 = 0; i2 < l2; i2++) {
        var f = fs[i2];
        for (var j = 0; j < k; j++) {
          result[n++] = f(xs[j]);
        }
      }
      return result;
    };
  };

  // output/Control.Semigroupoid/index.js
  var semigroupoidFn = {
    compose: function(f) {
      return function(g) {
        return function(x) {
          return f(g(x));
        };
      };
    }
  };

  // output/Control.Category/index.js
  var identity = function(dict) {
    return dict.identity;
  };
  var categoryFn = {
    identity: function(x) {
      return x;
    },
    Semigroupoid0: function() {
      return semigroupoidFn;
    }
  };

  // output/Data.Boolean/index.js
  var otherwise = true;

  // output/Data.Function/index.js
  var on = function(f) {
    return function(g) {
      return function(x) {
        return function(y) {
          return f(g(x))(g(y));
        };
      };
    };
  };
  var flip = function(f) {
    return function(b2) {
      return function(a3) {
        return f(a3)(b2);
      };
    };
  };
  var $$const = function(a3) {
    return function(v2) {
      return a3;
    };
  };
  var applyFlipped = function(x) {
    return function(f) {
      return f(x);
    };
  };

  // output/Data.Functor/foreign.js
  var arrayMap = function(f) {
    return function(arr) {
      var l2 = arr.length;
      var result = new Array(l2);
      for (var i2 = 0; i2 < l2; i2++) {
        result[i2] = f(arr[i2]);
      }
      return result;
    };
  };

  // output/Data.Unit/foreign.js
  var unit = void 0;

  // output/Type.Proxy/index.js
  var $$Proxy = /* @__PURE__ */ (function() {
    function $$Proxy2() {
    }
    ;
    $$Proxy2.value = new $$Proxy2();
    return $$Proxy2;
  })();

  // output/Data.Functor/index.js
  var map = function(dict) {
    return dict.map;
  };
  var mapFlipped = function(dictFunctor) {
    var map112 = map(dictFunctor);
    return function(fa) {
      return function(f) {
        return map112(f)(fa);
      };
    };
  };
  var $$void = function(dictFunctor) {
    return map(dictFunctor)($$const(unit));
  };
  var voidLeft = function(dictFunctor) {
    var map112 = map(dictFunctor);
    return function(f) {
      return function(x) {
        return map112($$const(x))(f);
      };
    };
  };
  var voidRight = function(dictFunctor) {
    var map112 = map(dictFunctor);
    return function(x) {
      return map112($$const(x));
    };
  };
  var functorArray = {
    map: arrayMap
  };

  // output/Control.Apply/index.js
  var identity2 = /* @__PURE__ */ identity(categoryFn);
  var applyArray = {
    apply: arrayApply,
    Functor0: function() {
      return functorArray;
    }
  };
  var apply = function(dict) {
    return dict.apply;
  };
  var applySecond = function(dictApply) {
    var apply1 = apply(dictApply);
    var map31 = map(dictApply.Functor0());
    return function(a3) {
      return function(b2) {
        return apply1(map31($$const(identity2))(a3))(b2);
      };
    };
  };

  // output/Control.Applicative/index.js
  var pure = function(dict) {
    return dict.pure;
  };
  var unless = function(dictApplicative) {
    var pure18 = pure(dictApplicative);
    return function(v2) {
      return function(v1) {
        if (!v2) {
          return v1;
        }
        ;
        if (v2) {
          return pure18(unit);
        }
        ;
        throw new Error("Failed pattern match at Control.Applicative (line 68, column 1 - line 68, column 65): " + [v2.constructor.name, v1.constructor.name]);
      };
    };
  };
  var when = function(dictApplicative) {
    var pure18 = pure(dictApplicative);
    return function(v2) {
      return function(v1) {
        if (v2) {
          return v1;
        }
        ;
        if (!v2) {
          return pure18(unit);
        }
        ;
        throw new Error("Failed pattern match at Control.Applicative (line 63, column 1 - line 63, column 63): " + [v2.constructor.name, v1.constructor.name]);
      };
    };
  };
  var liftA1 = function(dictApplicative) {
    var apply3 = apply(dictApplicative.Apply0());
    var pure18 = pure(dictApplicative);
    return function(f) {
      return function(a3) {
        return apply3(pure18(f))(a3);
      };
    };
  };

  // output/Data.Ordering/index.js
  var LT = /* @__PURE__ */ (function() {
    function LT2() {
    }
    ;
    LT2.value = new LT2();
    return LT2;
  })();
  var GT = /* @__PURE__ */ (function() {
    function GT2() {
    }
    ;
    GT2.value = new GT2();
    return GT2;
  })();
  var EQ = /* @__PURE__ */ (function() {
    function EQ2() {
    }
    ;
    EQ2.value = new EQ2();
    return EQ2;
  })();

  // output/DOM.HTML.Indexed.ButtonType/index.js
  var ButtonButton = /* @__PURE__ */ (function() {
    function ButtonButton2() {
    }
    ;
    ButtonButton2.value = new ButtonButton2();
    return ButtonButton2;
  })();
  var ButtonSubmit = /* @__PURE__ */ (function() {
    function ButtonSubmit2() {
    }
    ;
    ButtonSubmit2.value = new ButtonSubmit2();
    return ButtonSubmit2;
  })();
  var ButtonReset = /* @__PURE__ */ (function() {
    function ButtonReset2() {
    }
    ;
    ButtonReset2.value = new ButtonReset2();
    return ButtonReset2;
  })();
  var renderButtonType = function(v2) {
    if (v2 instanceof ButtonButton) {
      return "button";
    }
    ;
    if (v2 instanceof ButtonSubmit) {
      return "submit";
    }
    ;
    if (v2 instanceof ButtonReset) {
      return "reset";
    }
    ;
    throw new Error("Failed pattern match at DOM.HTML.Indexed.ButtonType (line 14, column 20 - line 17, column 25): " + [v2.constructor.name]);
  };

  // output/Data.Eq/foreign.js
  var refEq = function(r1) {
    return function(r2) {
      return r1 === r2;
    };
  };
  var eqBooleanImpl = refEq;
  var eqIntImpl = refEq;
  var eqNumberImpl = refEq;
  var eqCharImpl = refEq;
  var eqStringImpl = refEq;

  // output/Data.Symbol/index.js
  var reflectSymbol = function(dict) {
    return dict.reflectSymbol;
  };

  // output/Record.Unsafe/foreign.js
  var unsafeGet = function(label5) {
    return function(rec) {
      return rec[label5];
    };
  };

  // output/Data.Eq/index.js
  var eqUnit = {
    eq: function(v2) {
      return function(v1) {
        return true;
      };
    }
  };
  var eqString = {
    eq: eqStringImpl
  };
  var eqNumber = {
    eq: eqNumberImpl
  };
  var eqInt = {
    eq: eqIntImpl
  };
  var eqChar = {
    eq: eqCharImpl
  };
  var eqBoolean = {
    eq: eqBooleanImpl
  };
  var eq = function(dict) {
    return dict.eq;
  };
  var eq2 = /* @__PURE__ */ eq(eqBoolean);
  var notEq = function(dictEq) {
    var eq33 = eq(dictEq);
    return function(x) {
      return function(y) {
        return eq2(eq33(x)(y))(false);
      };
    };
  };

  // output/Data.Ord/foreign.js
  var unsafeCompareImpl = function(lt2) {
    return function(eq8) {
      return function(gt2) {
        return function(x) {
          return function(y) {
            return x < y ? lt2 : x === y ? eq8 : gt2;
          };
        };
      };
    };
  };
  var ordIntImpl = unsafeCompareImpl;
  var ordNumberImpl = unsafeCompareImpl;
  var ordStringImpl = unsafeCompareImpl;
  var ordCharImpl = unsafeCompareImpl;

  // output/Data.Ring/foreign.js
  var intSub = function(x) {
    return function(y) {
      return x - y | 0;
    };
  };

  // output/Data.Semiring/foreign.js
  var intAdd = function(x) {
    return function(y) {
      return x + y | 0;
    };
  };
  var intMul = function(x) {
    return function(y) {
      return x * y | 0;
    };
  };

  // output/Data.Semiring/index.js
  var semiringInt = {
    add: intAdd,
    zero: 0,
    mul: intMul,
    one: 1
  };

  // output/Data.Ring/index.js
  var ringInt = {
    sub: intSub,
    Semiring0: function() {
      return semiringInt;
    }
  };

  // output/Data.Ord/index.js
  var ordUnit = {
    compare: function(v2) {
      return function(v1) {
        return EQ.value;
      };
    },
    Eq0: function() {
      return eqUnit;
    }
  };
  var ordString = /* @__PURE__ */ (function() {
    return {
      compare: ordStringImpl(LT.value)(EQ.value)(GT.value),
      Eq0: function() {
        return eqString;
      }
    };
  })();
  var ordNumber = /* @__PURE__ */ (function() {
    return {
      compare: ordNumberImpl(LT.value)(EQ.value)(GT.value),
      Eq0: function() {
        return eqNumber;
      }
    };
  })();
  var ordInt = /* @__PURE__ */ (function() {
    return {
      compare: ordIntImpl(LT.value)(EQ.value)(GT.value),
      Eq0: function() {
        return eqInt;
      }
    };
  })();
  var ordChar = /* @__PURE__ */ (function() {
    return {
      compare: ordCharImpl(LT.value)(EQ.value)(GT.value),
      Eq0: function() {
        return eqChar;
      }
    };
  })();
  var compare = function(dict) {
    return dict.compare;
  };
  var max = function(dictOrd) {
    var compare32 = compare(dictOrd);
    return function(x) {
      return function(y) {
        var v2 = compare32(x)(y);
        if (v2 instanceof LT) {
          return y;
        }
        ;
        if (v2 instanceof EQ) {
          return x;
        }
        ;
        if (v2 instanceof GT) {
          return x;
        }
        ;
        throw new Error("Failed pattern match at Data.Ord (line 181, column 3 - line 184, column 12): " + [v2.constructor.name]);
      };
    };
  };
  var min = function(dictOrd) {
    var compare32 = compare(dictOrd);
    return function(x) {
      return function(y) {
        var v2 = compare32(x)(y);
        if (v2 instanceof LT) {
          return x;
        }
        ;
        if (v2 instanceof EQ) {
          return x;
        }
        ;
        if (v2 instanceof GT) {
          return y;
        }
        ;
        throw new Error("Failed pattern match at Data.Ord (line 172, column 3 - line 175, column 12): " + [v2.constructor.name]);
      };
    };
  };

  // output/Data.Show/foreign.js
  var showIntImpl = function(n) {
    return n.toString();
  };
  var showNumberImpl = function(n) {
    var str = n.toString();
    return isNaN(str + ".0") ? str : str + ".0";
  };
  var showStringImpl = function(s2) {
    var l2 = s2.length;
    return '"' + s2.replace(
      /[\0-\x1F\x7F"\\]/g,
      // eslint-disable-line no-control-regex
      function(c2, i2) {
        switch (c2) {
          case '"':
          case "\\":
            return "\\" + c2;
          case "\x07":
            return "\\a";
          case "\b":
            return "\\b";
          case "\f":
            return "\\f";
          case "\n":
            return "\\n";
          case "\r":
            return "\\r";
          case "	":
            return "\\t";
          case "\v":
            return "\\v";
        }
        var k = i2 + 1;
        var empty7 = k < l2 && s2[k] >= "0" && s2[k] <= "9" ? "\\&" : "";
        return "\\" + c2.charCodeAt(0).toString(10) + empty7;
      }
    ) + '"';
  };

  // output/Data.Show/index.js
  var showString = {
    show: showStringImpl
  };
  var showNumber = {
    show: showNumberImpl
  };
  var showInt = {
    show: showIntImpl
  };
  var showBoolean = {
    show: function(v2) {
      if (v2) {
        return "true";
      }
      ;
      if (!v2) {
        return "false";
      }
      ;
      throw new Error("Failed pattern match at Data.Show (line 29, column 1 - line 31, column 23): " + [v2.constructor.name]);
    }
  };
  var show = function(dict) {
    return dict.show;
  };

  // output/Data.Semigroup/foreign.js
  var concatArray = function(xs) {
    return function(ys) {
      if (xs.length === 0) return ys;
      if (ys.length === 0) return xs;
      return xs.concat(ys);
    };
  };

  // output/Data.Semigroup/index.js
  var semigroupArray = {
    append: concatArray
  };
  var append = function(dict) {
    return dict.append;
  };

  // output/Data.String.Common/foreign.js
  var split = function(sep) {
    return function(s2) {
      return s2.split(sep);
    };
  };
  var toLower = function(s2) {
    return s2.toLowerCase();
  };
  var joinWith = function(s2) {
    return function(xs) {
      return xs.join(s2);
    };
  };

  // output/DOM.HTML.Indexed.InputType/index.js
  var InputButton = /* @__PURE__ */ (function() {
    function InputButton2() {
    }
    ;
    InputButton2.value = new InputButton2();
    return InputButton2;
  })();
  var InputCheckbox = /* @__PURE__ */ (function() {
    function InputCheckbox2() {
    }
    ;
    InputCheckbox2.value = new InputCheckbox2();
    return InputCheckbox2;
  })();
  var InputColor = /* @__PURE__ */ (function() {
    function InputColor2() {
    }
    ;
    InputColor2.value = new InputColor2();
    return InputColor2;
  })();
  var InputDate = /* @__PURE__ */ (function() {
    function InputDate2() {
    }
    ;
    InputDate2.value = new InputDate2();
    return InputDate2;
  })();
  var InputDatetimeLocal = /* @__PURE__ */ (function() {
    function InputDatetimeLocal2() {
    }
    ;
    InputDatetimeLocal2.value = new InputDatetimeLocal2();
    return InputDatetimeLocal2;
  })();
  var InputEmail = /* @__PURE__ */ (function() {
    function InputEmail2() {
    }
    ;
    InputEmail2.value = new InputEmail2();
    return InputEmail2;
  })();
  var InputFile = /* @__PURE__ */ (function() {
    function InputFile2() {
    }
    ;
    InputFile2.value = new InputFile2();
    return InputFile2;
  })();
  var InputHidden = /* @__PURE__ */ (function() {
    function InputHidden2() {
    }
    ;
    InputHidden2.value = new InputHidden2();
    return InputHidden2;
  })();
  var InputImage = /* @__PURE__ */ (function() {
    function InputImage2() {
    }
    ;
    InputImage2.value = new InputImage2();
    return InputImage2;
  })();
  var InputMonth = /* @__PURE__ */ (function() {
    function InputMonth2() {
    }
    ;
    InputMonth2.value = new InputMonth2();
    return InputMonth2;
  })();
  var InputNumber = /* @__PURE__ */ (function() {
    function InputNumber2() {
    }
    ;
    InputNumber2.value = new InputNumber2();
    return InputNumber2;
  })();
  var InputPassword = /* @__PURE__ */ (function() {
    function InputPassword2() {
    }
    ;
    InputPassword2.value = new InputPassword2();
    return InputPassword2;
  })();
  var InputRadio = /* @__PURE__ */ (function() {
    function InputRadio2() {
    }
    ;
    InputRadio2.value = new InputRadio2();
    return InputRadio2;
  })();
  var InputRange = /* @__PURE__ */ (function() {
    function InputRange2() {
    }
    ;
    InputRange2.value = new InputRange2();
    return InputRange2;
  })();
  var InputReset = /* @__PURE__ */ (function() {
    function InputReset2() {
    }
    ;
    InputReset2.value = new InputReset2();
    return InputReset2;
  })();
  var InputSearch = /* @__PURE__ */ (function() {
    function InputSearch2() {
    }
    ;
    InputSearch2.value = new InputSearch2();
    return InputSearch2;
  })();
  var InputSubmit = /* @__PURE__ */ (function() {
    function InputSubmit2() {
    }
    ;
    InputSubmit2.value = new InputSubmit2();
    return InputSubmit2;
  })();
  var InputTel = /* @__PURE__ */ (function() {
    function InputTel2() {
    }
    ;
    InputTel2.value = new InputTel2();
    return InputTel2;
  })();
  var InputText = /* @__PURE__ */ (function() {
    function InputText2() {
    }
    ;
    InputText2.value = new InputText2();
    return InputText2;
  })();
  var InputTime = /* @__PURE__ */ (function() {
    function InputTime2() {
    }
    ;
    InputTime2.value = new InputTime2();
    return InputTime2;
  })();
  var InputUrl = /* @__PURE__ */ (function() {
    function InputUrl2() {
    }
    ;
    InputUrl2.value = new InputUrl2();
    return InputUrl2;
  })();
  var InputWeek = /* @__PURE__ */ (function() {
    function InputWeek2() {
    }
    ;
    InputWeek2.value = new InputWeek2();
    return InputWeek2;
  })();
  var renderInputType = function(v2) {
    if (v2 instanceof InputButton) {
      return "button";
    }
    ;
    if (v2 instanceof InputCheckbox) {
      return "checkbox";
    }
    ;
    if (v2 instanceof InputColor) {
      return "color";
    }
    ;
    if (v2 instanceof InputDate) {
      return "date";
    }
    ;
    if (v2 instanceof InputDatetimeLocal) {
      return "datetime-local";
    }
    ;
    if (v2 instanceof InputEmail) {
      return "email";
    }
    ;
    if (v2 instanceof InputFile) {
      return "file";
    }
    ;
    if (v2 instanceof InputHidden) {
      return "hidden";
    }
    ;
    if (v2 instanceof InputImage) {
      return "image";
    }
    ;
    if (v2 instanceof InputMonth) {
      return "month";
    }
    ;
    if (v2 instanceof InputNumber) {
      return "number";
    }
    ;
    if (v2 instanceof InputPassword) {
      return "password";
    }
    ;
    if (v2 instanceof InputRadio) {
      return "radio";
    }
    ;
    if (v2 instanceof InputRange) {
      return "range";
    }
    ;
    if (v2 instanceof InputReset) {
      return "reset";
    }
    ;
    if (v2 instanceof InputSearch) {
      return "search";
    }
    ;
    if (v2 instanceof InputSubmit) {
      return "submit";
    }
    ;
    if (v2 instanceof InputTel) {
      return "tel";
    }
    ;
    if (v2 instanceof InputText) {
      return "text";
    }
    ;
    if (v2 instanceof InputTime) {
      return "time";
    }
    ;
    if (v2 instanceof InputUrl) {
      return "url";
    }
    ;
    if (v2 instanceof InputWeek) {
      return "week";
    }
    ;
    throw new Error("Failed pattern match at DOM.HTML.Indexed.InputType (line 33, column 19 - line 55, column 22): " + [v2.constructor.name]);
  };

  // output/Data.HeytingAlgebra/foreign.js
  var boolConj = function(b1) {
    return function(b2) {
      return b1 && b2;
    };
  };
  var boolDisj = function(b1) {
    return function(b2) {
      return b1 || b2;
    };
  };
  var boolNot = function(b2) {
    return !b2;
  };

  // output/Data.HeytingAlgebra/index.js
  var tt = function(dict) {
    return dict.tt;
  };
  var not = function(dict) {
    return dict.not;
  };
  var implies = function(dict) {
    return dict.implies;
  };
  var ff = function(dict) {
    return dict.ff;
  };
  var disj = function(dict) {
    return dict.disj;
  };
  var heytingAlgebraBoolean = {
    ff: false,
    tt: true,
    implies: function(a3) {
      return function(b2) {
        return disj(heytingAlgebraBoolean)(not(heytingAlgebraBoolean)(a3))(b2);
      };
    },
    conj: boolConj,
    disj: boolDisj,
    not: boolNot
  };
  var conj = function(dict) {
    return dict.conj;
  };
  var heytingAlgebraFunction = function(dictHeytingAlgebra) {
    var ff1 = ff(dictHeytingAlgebra);
    var tt1 = tt(dictHeytingAlgebra);
    var implies1 = implies(dictHeytingAlgebra);
    var conj1 = conj(dictHeytingAlgebra);
    var disj1 = disj(dictHeytingAlgebra);
    var not1 = not(dictHeytingAlgebra);
    return {
      ff: function(v2) {
        return ff1;
      },
      tt: function(v2) {
        return tt1;
      },
      implies: function(f) {
        return function(g) {
          return function(a3) {
            return implies1(f(a3))(g(a3));
          };
        };
      },
      conj: function(f) {
        return function(g) {
          return function(a3) {
            return conj1(f(a3))(g(a3));
          };
        };
      },
      disj: function(f) {
        return function(g) {
          return function(a3) {
            return disj1(f(a3))(g(a3));
          };
        };
      },
      not: function(f) {
        return function(a3) {
          return not1(f(a3));
        };
      }
    };
  };

  // output/Control.Alt/index.js
  var alt = function(dict) {
    return dict.alt;
  };

  // output/Data.Bounded/foreign.js
  var topChar = String.fromCharCode(65535);
  var bottomChar = String.fromCharCode(0);
  var topNumber = Number.POSITIVE_INFINITY;
  var bottomNumber = Number.NEGATIVE_INFINITY;

  // output/Data.Bounded/index.js
  var top = function(dict) {
    return dict.top;
  };
  var boundedChar = {
    top: topChar,
    bottom: bottomChar,
    Ord0: function() {
      return ordChar;
    }
  };
  var bottom = function(dict) {
    return dict.bottom;
  };

  // output/Data.Maybe/index.js
  var identity3 = /* @__PURE__ */ identity(categoryFn);
  var Nothing = /* @__PURE__ */ (function() {
    function Nothing2() {
    }
    ;
    Nothing2.value = new Nothing2();
    return Nothing2;
  })();
  var Just = /* @__PURE__ */ (function() {
    function Just2(value0) {
      this.value0 = value0;
    }
    ;
    Just2.create = function(value0) {
      return new Just2(value0);
    };
    return Just2;
  })();
  var maybe = function(v2) {
    return function(v1) {
      return function(v22) {
        if (v22 instanceof Nothing) {
          return v2;
        }
        ;
        if (v22 instanceof Just) {
          return v1(v22.value0);
        }
        ;
        throw new Error("Failed pattern match at Data.Maybe (line 237, column 1 - line 237, column 51): " + [v2.constructor.name, v1.constructor.name, v22.constructor.name]);
      };
    };
  };
  var isNothing = /* @__PURE__ */ maybe(true)(/* @__PURE__ */ $$const(false));
  var isJust = /* @__PURE__ */ maybe(false)(/* @__PURE__ */ $$const(true));
  var functorMaybe = {
    map: function(v2) {
      return function(v1) {
        if (v1 instanceof Just) {
          return new Just(v2(v1.value0));
        }
        ;
        return Nothing.value;
      };
    }
  };
  var map2 = /* @__PURE__ */ map(functorMaybe);
  var fromMaybe = function(a3) {
    return maybe(a3)(identity3);
  };
  var fromJust = function() {
    return function(v2) {
      if (v2 instanceof Just) {
        return v2.value0;
      }
      ;
      throw new Error("Failed pattern match at Data.Maybe (line 288, column 1 - line 288, column 46): " + [v2.constructor.name]);
    };
  };
  var eqMaybe = function(dictEq) {
    var eq8 = eq(dictEq);
    return {
      eq: function(x) {
        return function(y) {
          if (x instanceof Nothing && y instanceof Nothing) {
            return true;
          }
          ;
          if (x instanceof Just && y instanceof Just) {
            return eq8(x.value0)(y.value0);
          }
          ;
          return false;
        };
      }
    };
  };
  var applyMaybe = {
    apply: function(v2) {
      return function(v1) {
        if (v2 instanceof Just) {
          return map2(v2.value0)(v1);
        }
        ;
        if (v2 instanceof Nothing) {
          return Nothing.value;
        }
        ;
        throw new Error("Failed pattern match at Data.Maybe (line 67, column 1 - line 69, column 30): " + [v2.constructor.name, v1.constructor.name]);
      };
    },
    Functor0: function() {
      return functorMaybe;
    }
  };
  var bindMaybe = {
    bind: function(v2) {
      return function(v1) {
        if (v2 instanceof Just) {
          return v1(v2.value0);
        }
        ;
        if (v2 instanceof Nothing) {
          return Nothing.value;
        }
        ;
        throw new Error("Failed pattern match at Data.Maybe (line 125, column 1 - line 127, column 28): " + [v2.constructor.name, v1.constructor.name]);
      };
    },
    Apply0: function() {
      return applyMaybe;
    }
  };
  var applicativeMaybe = /* @__PURE__ */ (function() {
    return {
      pure: Just.create,
      Apply0: function() {
        return applyMaybe;
      }
    };
  })();

  // output/Unsafe.Coerce/foreign.js
  var unsafeCoerce2 = function(x) {
    return x;
  };

  // output/Safe.Coerce/index.js
  var coerce = function() {
    return unsafeCoerce2;
  };

  // output/Data.Newtype/index.js
  var coerce2 = /* @__PURE__ */ coerce();
  var unwrap = function() {
    return coerce2;
  };
  var alaF = function() {
    return function() {
      return function() {
        return function() {
          return function(v2) {
            return coerce2;
          };
        };
      };
    };
  };

  // output/Data.Either/index.js
  var Left = /* @__PURE__ */ (function() {
    function Left2(value0) {
      this.value0 = value0;
    }
    ;
    Left2.create = function(value0) {
      return new Left2(value0);
    };
    return Left2;
  })();
  var Right = /* @__PURE__ */ (function() {
    function Right2(value0) {
      this.value0 = value0;
    }
    ;
    Right2.create = function(value0) {
      return new Right2(value0);
    };
    return Right2;
  })();
  var note = function(a3) {
    return maybe(new Left(a3))(Right.create);
  };
  var functorEither = {
    map: function(f) {
      return function(m2) {
        if (m2 instanceof Left) {
          return new Left(m2.value0);
        }
        ;
        if (m2 instanceof Right) {
          return new Right(f(m2.value0));
        }
        ;
        throw new Error("Failed pattern match at Data.Either (line 0, column 0 - line 0, column 0): " + [m2.constructor.name]);
      };
    }
  };
  var map3 = /* @__PURE__ */ map(functorEither);
  var either = function(v2) {
    return function(v1) {
      return function(v22) {
        if (v22 instanceof Left) {
          return v2(v22.value0);
        }
        ;
        if (v22 instanceof Right) {
          return v1(v22.value0);
        }
        ;
        throw new Error("Failed pattern match at Data.Either (line 208, column 1 - line 208, column 64): " + [v2.constructor.name, v1.constructor.name, v22.constructor.name]);
      };
    };
  };
  var applyEither = {
    apply: function(v2) {
      return function(v1) {
        if (v2 instanceof Left) {
          return new Left(v2.value0);
        }
        ;
        if (v2 instanceof Right) {
          return map3(v2.value0)(v1);
        }
        ;
        throw new Error("Failed pattern match at Data.Either (line 70, column 1 - line 72, column 30): " + [v2.constructor.name, v1.constructor.name]);
      };
    },
    Functor0: function() {
      return functorEither;
    }
  };
  var bindEither = {
    bind: /* @__PURE__ */ either(function(e) {
      return function(v2) {
        return new Left(e);
      };
    })(function(a3) {
      return function(f) {
        return f(a3);
      };
    }),
    Apply0: function() {
      return applyEither;
    }
  };
  var applicativeEither = /* @__PURE__ */ (function() {
    return {
      pure: Right.create,
      Apply0: function() {
        return applyEither;
      }
    };
  })();

  // output/Data.EuclideanRing/foreign.js
  var intDegree = function(x) {
    return Math.min(Math.abs(x), 2147483647);
  };
  var intDiv = function(x) {
    return function(y) {
      if (y === 0) return 0;
      return y > 0 ? Math.floor(x / y) : -Math.floor(x / -y);
    };
  };
  var intMod = function(x) {
    return function(y) {
      if (y === 0) return 0;
      var yy = Math.abs(y);
      return (x % yy + yy) % yy;
    };
  };

  // output/Data.CommutativeRing/index.js
  var commutativeRingInt = {
    Ring0: function() {
      return ringInt;
    }
  };

  // output/Data.EuclideanRing/index.js
  var mod = function(dict) {
    return dict.mod;
  };
  var euclideanRingInt = {
    degree: intDegree,
    div: intDiv,
    mod: intMod,
    CommutativeRing0: function() {
      return commutativeRingInt;
    }
  };

  // output/Data.Monoid/index.js
  var mempty = function(dict) {
    return dict.mempty;
  };

  // output/Data.Tuple/index.js
  var Tuple = /* @__PURE__ */ (function() {
    function Tuple2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Tuple2.create = function(value0) {
      return function(value1) {
        return new Tuple2(value0, value1);
      };
    };
    return Tuple2;
  })();
  var uncurry = function(f) {
    return function(v2) {
      return f(v2.value0)(v2.value1);
    };
  };
  var snd = function(v2) {
    return v2.value1;
  };
  var functorTuple = {
    map: function(f) {
      return function(m2) {
        return new Tuple(m2.value0, f(m2.value1));
      };
    }
  };
  var fst = function(v2) {
    return v2.value0;
  };
  var eqTuple = function(dictEq) {
    var eq8 = eq(dictEq);
    return function(dictEq1) {
      var eq12 = eq(dictEq1);
      return {
        eq: function(x) {
          return function(y) {
            return eq8(x.value0)(y.value0) && eq12(x.value1)(y.value1);
          };
        }
      };
    };
  };
  var ordTuple = function(dictOrd) {
    var compare4 = compare(dictOrd);
    var eqTuple1 = eqTuple(dictOrd.Eq0());
    return function(dictOrd1) {
      var compare13 = compare(dictOrd1);
      var eqTuple2 = eqTuple1(dictOrd1.Eq0());
      return {
        compare: function(x) {
          return function(y) {
            var v2 = compare4(x.value0)(y.value0);
            if (v2 instanceof LT) {
              return LT.value;
            }
            ;
            if (v2 instanceof GT) {
              return GT.value;
            }
            ;
            return compare13(x.value1)(y.value1);
          };
        },
        Eq0: function() {
          return eqTuple2;
        }
      };
    };
  };

  // output/Data.Bifunctor/index.js
  var identity4 = /* @__PURE__ */ identity(categoryFn);
  var bimap = function(dict) {
    return dict.bimap;
  };
  var lmap = function(dictBifunctor) {
    var bimap1 = bimap(dictBifunctor);
    return function(f) {
      return bimap1(f)(identity4);
    };
  };
  var bifunctorEither = {
    bimap: function(v2) {
      return function(v1) {
        return function(v22) {
          if (v22 instanceof Left) {
            return new Left(v2(v22.value0));
          }
          ;
          if (v22 instanceof Right) {
            return new Right(v1(v22.value0));
          }
          ;
          throw new Error("Failed pattern match at Data.Bifunctor (line 32, column 1 - line 34, column 36): " + [v2.constructor.name, v1.constructor.name, v22.constructor.name]);
        };
      };
    }
  };

  // output/Halogen.Query.Input/index.js
  var RefUpdate = /* @__PURE__ */ (function() {
    function RefUpdate2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    RefUpdate2.create = function(value0) {
      return function(value1) {
        return new RefUpdate2(value0, value1);
      };
    };
    return RefUpdate2;
  })();
  var Action = /* @__PURE__ */ (function() {
    function Action3(value0) {
      this.value0 = value0;
    }
    ;
    Action3.create = function(value0) {
      return new Action3(value0);
    };
    return Action3;
  })();

  // output/Data.Array/foreign.js
  var replicateFill = function(count, value16) {
    if (count < 1) {
      return [];
    }
    var result = new Array(count);
    return result.fill(value16);
  };
  var replicatePolyfill = function(count, value16) {
    var result = [];
    var n = 0;
    for (var i2 = 0; i2 < count; i2++) {
      result[n++] = value16;
    }
    return result;
  };
  var replicateImpl = typeof Array.prototype.fill === "function" ? replicateFill : replicatePolyfill;
  var length = function(xs) {
    return xs.length;
  };
  var indexImpl = function(just, nothing, xs, i2) {
    return i2 < 0 || i2 >= xs.length ? nothing : just(xs[i2]);
  };
  var findIndexImpl = function(just, nothing, f, xs) {
    for (var i2 = 0, l2 = xs.length; i2 < l2; i2++) {
      if (f(xs[i2])) return just(i2);
    }
    return nothing;
  };
  var _deleteAt = function(just, nothing, i2, l2) {
    if (i2 < 0 || i2 >= l2.length) return nothing;
    var l1 = l2.slice();
    l1.splice(i2, 1);
    return just(l1);
  };
  var filterImpl = function(f, xs) {
    return xs.filter(f);
  };
  var sortByImpl = /* @__PURE__ */ (function() {
    function mergeFromTo(compare4, fromOrdering, xs1, xs2, from2, to) {
      var mid;
      var i2;
      var j;
      var k;
      var x;
      var y;
      var c2;
      mid = from2 + (to - from2 >> 1);
      if (mid - from2 > 1) mergeFromTo(compare4, fromOrdering, xs2, xs1, from2, mid);
      if (to - mid > 1) mergeFromTo(compare4, fromOrdering, xs2, xs1, mid, to);
      i2 = from2;
      j = mid;
      k = from2;
      while (i2 < mid && j < to) {
        x = xs2[i2];
        y = xs2[j];
        c2 = fromOrdering(compare4(x)(y));
        if (c2 > 0) {
          xs1[k++] = y;
          ++j;
        } else {
          xs1[k++] = x;
          ++i2;
        }
      }
      while (i2 < mid) {
        xs1[k++] = xs2[i2++];
      }
      while (j < to) {
        xs1[k++] = xs2[j++];
      }
    }
    return function(compare4, fromOrdering, xs) {
      var out;
      if (xs.length < 2) return xs;
      out = xs.slice(0);
      mergeFromTo(compare4, fromOrdering, out, xs.slice(0), 0, xs.length);
      return out;
    };
  })();
  var sliceImpl = function(s2, e, l2) {
    return l2.slice(s2, e);
  };
  var unsafeIndexImpl = function(xs, n) {
    return xs[n];
  };

  // output/Control.Bind/foreign.js
  var arrayBind = function(arr) {
    return function(f) {
      var result = [];
      for (var i2 = 0, l2 = arr.length; i2 < l2; i2++) {
        Array.prototype.push.apply(result, f(arr[i2]));
      }
      return result;
    };
  };

  // output/Control.Bind/index.js
  var discard = function(dict) {
    return dict.discard;
  };
  var bindArray = {
    bind: arrayBind,
    Apply0: function() {
      return applyArray;
    }
  };
  var bind = function(dict) {
    return dict.bind;
  };
  var bindFlipped = function(dictBind) {
    return flip(bind(dictBind));
  };
  var composeKleisliFlipped = function(dictBind) {
    var bindFlipped12 = bindFlipped(dictBind);
    return function(f) {
      return function(g) {
        return function(a3) {
          return bindFlipped12(f)(g(a3));
        };
      };
    };
  };
  var composeKleisli = function(dictBind) {
    var bind16 = bind(dictBind);
    return function(f) {
      return function(g) {
        return function(a3) {
          return bind16(f(a3))(g);
        };
      };
    };
  };
  var discardUnit = {
    discard: function(dictBind) {
      return bind(dictBind);
    }
  };

  // output/Control.Monad/index.js
  var unlessM = function(dictMonad) {
    var bind10 = bind(dictMonad.Bind1());
    var unless2 = unless(dictMonad.Applicative0());
    return function(mb) {
      return function(m2) {
        return bind10(mb)(function(b2) {
          return unless2(b2)(m2);
        });
      };
    };
  };
  var ap = function(dictMonad) {
    var bind10 = bind(dictMonad.Bind1());
    var pure18 = pure(dictMonad.Applicative0());
    return function(f) {
      return function(a3) {
        return bind10(f)(function(f$prime) {
          return bind10(a3)(function(a$prime) {
            return pure18(f$prime(a$prime));
          });
        });
      };
    };
  };

  // output/Data.Identity/index.js
  var Identity = function(x) {
    return x;
  };
  var functorIdentity = {
    map: function(f) {
      return function(m2) {
        return f(m2);
      };
    }
  };
  var applyIdentity = {
    apply: function(v2) {
      return function(v1) {
        return v2(v1);
      };
    },
    Functor0: function() {
      return functorIdentity;
    }
  };
  var bindIdentity = {
    bind: function(v2) {
      return function(f) {
        return f(v2);
      };
    },
    Apply0: function() {
      return applyIdentity;
    }
  };
  var applicativeIdentity = {
    pure: Identity,
    Apply0: function() {
      return applyIdentity;
    }
  };
  var monadIdentity = {
    Applicative0: function() {
      return applicativeIdentity;
    },
    Bind1: function() {
      return bindIdentity;
    }
  };

  // output/Effect/foreign.js
  var pureE = function(a3) {
    return function() {
      return a3;
    };
  };
  var bindE = function(a3) {
    return function(f) {
      return function() {
        return f(a3())();
      };
    };
  };

  // output/Effect/index.js
  var $runtime_lazy = function(name16, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name16 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var monadEffect = {
    Applicative0: function() {
      return applicativeEffect;
    },
    Bind1: function() {
      return bindEffect;
    }
  };
  var bindEffect = {
    bind: bindE,
    Apply0: function() {
      return $lazy_applyEffect(0);
    }
  };
  var applicativeEffect = {
    pure: pureE,
    Apply0: function() {
      return $lazy_applyEffect(0);
    }
  };
  var $lazy_functorEffect = /* @__PURE__ */ $runtime_lazy("functorEffect", "Effect", function() {
    return {
      map: liftA1(applicativeEffect)
    };
  });
  var $lazy_applyEffect = /* @__PURE__ */ $runtime_lazy("applyEffect", "Effect", function() {
    return {
      apply: ap(monadEffect),
      Functor0: function() {
        return $lazy_functorEffect(0);
      }
    };
  });
  var functorEffect = /* @__PURE__ */ $lazy_functorEffect(20);

  // output/Effect.Ref/foreign.js
  var _new = function(val) {
    return function() {
      return { value: val };
    };
  };
  var read = function(ref2) {
    return function() {
      return ref2.value;
    };
  };
  var modifyImpl = function(f) {
    return function(ref2) {
      return function() {
        var t2 = f(ref2.value);
        ref2.value = t2.state;
        return t2.value;
      };
    };
  };
  var write = function(val) {
    return function(ref2) {
      return function() {
        ref2.value = val;
      };
    };
  };

  // output/Effect.Ref/index.js
  var $$void2 = /* @__PURE__ */ $$void(functorEffect);
  var $$new = _new;
  var modify$prime = modifyImpl;
  var modify = function(f) {
    return modify$prime(function(s2) {
      var s$prime = f(s2);
      return {
        state: s$prime,
        value: s$prime
      };
    });
  };
  var modify_ = function(f) {
    return function(s2) {
      return $$void2(modify(f)(s2));
    };
  };

  // output/Control.Monad.Rec.Class/index.js
  var bindFlipped2 = /* @__PURE__ */ bindFlipped(bindEffect);
  var map4 = /* @__PURE__ */ map(functorEffect);
  var Loop = /* @__PURE__ */ (function() {
    function Loop2(value0) {
      this.value0 = value0;
    }
    ;
    Loop2.create = function(value0) {
      return new Loop2(value0);
    };
    return Loop2;
  })();
  var Done = /* @__PURE__ */ (function() {
    function Done2(value0) {
      this.value0 = value0;
    }
    ;
    Done2.create = function(value0) {
      return new Done2(value0);
    };
    return Done2;
  })();
  var tailRecM = function(dict) {
    return dict.tailRecM;
  };
  var monadRecEffect = {
    tailRecM: function(f) {
      return function(a3) {
        var fromDone = function(v2) {
          if (v2 instanceof Done) {
            return v2.value0;
          }
          ;
          throw new Error("Failed pattern match at Control.Monad.Rec.Class (line 137, column 30 - line 137, column 44): " + [v2.constructor.name]);
        };
        return function __do3() {
          var r = bindFlipped2($$new)(f(a3))();
          (function() {
            while (!(function __do4() {
              var v2 = read(r)();
              if (v2 instanceof Loop) {
                var e = f(v2.value0)();
                write(e)(r)();
                return false;
              }
              ;
              if (v2 instanceof Done) {
                return true;
              }
              ;
              throw new Error("Failed pattern match at Control.Monad.Rec.Class (line 128, column 22 - line 133, column 28): " + [v2.constructor.name]);
            })()) {
            }
            ;
            return {};
          })();
          return map4(fromDone)(read(r))();
        };
      };
    },
    Monad0: function() {
      return monadEffect;
    }
  };

  // output/Data.Array.ST/foreign.js
  function unsafeFreezeThawImpl(xs) {
    return xs;
  }
  var unsafeFreezeImpl = unsafeFreezeThawImpl;
  function copyImpl(xs) {
    return xs.slice();
  }
  var thawImpl = copyImpl;
  var pushImpl = function(a3, xs) {
    return xs.push(a3);
  };

  // output/Control.Monad.ST.Uncurried/foreign.js
  var runSTFn1 = function runSTFn12(fn) {
    return function(a3) {
      return function() {
        return fn(a3);
      };
    };
  };
  var runSTFn2 = function runSTFn22(fn) {
    return function(a3) {
      return function(b2) {
        return function() {
          return fn(a3, b2);
        };
      };
    };
  };

  // output/Data.Array.ST/index.js
  var unsafeFreeze = /* @__PURE__ */ runSTFn1(unsafeFreezeImpl);
  var thaw = /* @__PURE__ */ runSTFn1(thawImpl);
  var withArray = function(f) {
    return function(xs) {
      return function __do3() {
        var result = thaw(xs)();
        f(result)();
        return unsafeFreeze(result)();
      };
    };
  };
  var push = /* @__PURE__ */ runSTFn2(pushImpl);

  // output/Data.Foldable/foreign.js
  var foldrArray = function(f) {
    return function(init3) {
      return function(xs) {
        var acc = init3;
        var len = xs.length;
        for (var i2 = len - 1; i2 >= 0; i2--) {
          acc = f(xs[i2])(acc);
        }
        return acc;
      };
    };
  };
  var foldlArray = function(f) {
    return function(init3) {
      return function(xs) {
        var acc = init3;
        var len = xs.length;
        for (var i2 = 0; i2 < len; i2++) {
          acc = f(acc)(xs[i2]);
        }
        return acc;
      };
    };
  };

  // output/Control.Plus/index.js
  var empty = function(dict) {
    return dict.empty;
  };

  // output/Data.Monoid.Disj/index.js
  var Disj = function(x) {
    return x;
  };
  var semigroupDisj = function(dictHeytingAlgebra) {
    var disj2 = disj(dictHeytingAlgebra);
    return {
      append: function(v2) {
        return function(v1) {
          return disj2(v2)(v1);
        };
      }
    };
  };
  var monoidDisj = function(dictHeytingAlgebra) {
    var semigroupDisj1 = semigroupDisj(dictHeytingAlgebra);
    return {
      mempty: ff(dictHeytingAlgebra),
      Semigroup0: function() {
        return semigroupDisj1;
      }
    };
  };

  // output/Data.Foldable/index.js
  var alaF2 = /* @__PURE__ */ alaF()()()();
  var foldr = function(dict) {
    return dict.foldr;
  };
  var traverse_ = function(dictApplicative) {
    var applySecond2 = applySecond(dictApplicative.Apply0());
    var pure18 = pure(dictApplicative);
    return function(dictFoldable) {
      var foldr22 = foldr(dictFoldable);
      return function(f) {
        return foldr22(function($454) {
          return applySecond2(f($454));
        })(pure18(unit));
      };
    };
  };
  var for_ = function(dictApplicative) {
    var traverse_14 = traverse_(dictApplicative);
    return function(dictFoldable) {
      return flip(traverse_14(dictFoldable));
    };
  };
  var foldl = function(dict) {
    return dict.foldl;
  };
  var foldableMaybe = {
    foldr: function(v2) {
      return function(v1) {
        return function(v22) {
          if (v22 instanceof Nothing) {
            return v1;
          }
          ;
          if (v22 instanceof Just) {
            return v2(v22.value0)(v1);
          }
          ;
          throw new Error("Failed pattern match at Data.Foldable (line 138, column 1 - line 144, column 27): " + [v2.constructor.name, v1.constructor.name, v22.constructor.name]);
        };
      };
    },
    foldl: function(v2) {
      return function(v1) {
        return function(v22) {
          if (v22 instanceof Nothing) {
            return v1;
          }
          ;
          if (v22 instanceof Just) {
            return v2(v1)(v22.value0);
          }
          ;
          throw new Error("Failed pattern match at Data.Foldable (line 138, column 1 - line 144, column 27): " + [v2.constructor.name, v1.constructor.name, v22.constructor.name]);
        };
      };
    },
    foldMap: function(dictMonoid) {
      var mempty3 = mempty(dictMonoid);
      return function(v2) {
        return function(v1) {
          if (v1 instanceof Nothing) {
            return mempty3;
          }
          ;
          if (v1 instanceof Just) {
            return v2(v1.value0);
          }
          ;
          throw new Error("Failed pattern match at Data.Foldable (line 138, column 1 - line 144, column 27): " + [v2.constructor.name, v1.constructor.name]);
        };
      };
    }
  };
  var foldMapDefaultR = function(dictFoldable) {
    var foldr22 = foldr(dictFoldable);
    return function(dictMonoid) {
      var append6 = append(dictMonoid.Semigroup0());
      var mempty3 = mempty(dictMonoid);
      return function(f) {
        return foldr22(function(x) {
          return function(acc) {
            return append6(f(x))(acc);
          };
        })(mempty3);
      };
    };
  };
  var foldableArray = {
    foldr: foldrArray,
    foldl: foldlArray,
    foldMap: function(dictMonoid) {
      return foldMapDefaultR(foldableArray)(dictMonoid);
    }
  };
  var foldMap = function(dict) {
    return dict.foldMap;
  };
  var any = function(dictFoldable) {
    var foldMap22 = foldMap(dictFoldable);
    return function(dictHeytingAlgebra) {
      return alaF2(Disj)(foldMap22(monoidDisj(dictHeytingAlgebra)));
    };
  };

  // output/Data.Function.Uncurried/foreign.js
  var runFn2 = function(fn) {
    return function(a3) {
      return function(b2) {
        return fn(a3, b2);
      };
    };
  };
  var runFn3 = function(fn) {
    return function(a3) {
      return function(b2) {
        return function(c2) {
          return fn(a3, b2, c2);
        };
      };
    };
  };
  var runFn4 = function(fn) {
    return function(a3) {
      return function(b2) {
        return function(c2) {
          return function(d) {
            return fn(a3, b2, c2, d);
          };
        };
      };
    };
  };

  // output/Data.FunctorWithIndex/foreign.js
  var mapWithIndexArray = function(f) {
    return function(xs) {
      var l2 = xs.length;
      var result = Array(l2);
      for (var i2 = 0; i2 < l2; i2++) {
        result[i2] = f(i2)(xs[i2]);
      }
      return result;
    };
  };

  // output/Data.FunctorWithIndex/index.js
  var mapWithIndex = function(dict) {
    return dict.mapWithIndex;
  };
  var functorWithIndexArray = {
    mapWithIndex: mapWithIndexArray,
    Functor0: function() {
      return functorArray;
    }
  };

  // output/Data.Traversable/foreign.js
  var traverseArrayImpl = /* @__PURE__ */ (function() {
    function array1(a3) {
      return [a3];
    }
    function array2(a3) {
      return function(b2) {
        return [a3, b2];
      };
    }
    function array3(a3) {
      return function(b2) {
        return function(c2) {
          return [a3, b2, c2];
        };
      };
    }
    function concat2(xs) {
      return function(ys) {
        return xs.concat(ys);
      };
    }
    return function(apply3) {
      return function(map31) {
        return function(pure18) {
          return function(f) {
            return function(array) {
              function go2(bot, top2) {
                switch (top2 - bot) {
                  case 0:
                    return pure18([]);
                  case 1:
                    return map31(array1)(f(array[bot]));
                  case 2:
                    return apply3(map31(array2)(f(array[bot])))(f(array[bot + 1]));
                  case 3:
                    return apply3(apply3(map31(array3)(f(array[bot])))(f(array[bot + 1])))(f(array[bot + 2]));
                  default:
                    var pivot = bot + Math.floor((top2 - bot) / 4) * 2;
                    return apply3(map31(concat2)(go2(bot, pivot)))(go2(pivot, top2));
                }
              }
              return go2(0, array.length);
            };
          };
        };
      };
    };
  })();

  // output/Data.Traversable/index.js
  var identity5 = /* @__PURE__ */ identity(categoryFn);
  var traverse = function(dict) {
    return dict.traverse;
  };
  var sequenceDefault = function(dictTraversable) {
    var traverse22 = traverse(dictTraversable);
    return function(dictApplicative) {
      return traverse22(dictApplicative)(identity5);
    };
  };
  var traversableArray = {
    traverse: function(dictApplicative) {
      var Apply0 = dictApplicative.Apply0();
      return traverseArrayImpl(apply(Apply0))(map(Apply0.Functor0()))(pure(dictApplicative));
    },
    sequence: function(dictApplicative) {
      return sequenceDefault(traversableArray)(dictApplicative);
    },
    Functor0: function() {
      return functorArray;
    },
    Foldable1: function() {
      return foldableArray;
    }
  };
  var sequence = function(dict) {
    return dict.sequence;
  };

  // output/Data.Unfoldable/foreign.js
  var unfoldrArrayImpl = function(isNothing2) {
    return function(fromJust5) {
      return function(fst2) {
        return function(snd2) {
          return function(f) {
            return function(b2) {
              var result = [];
              var value16 = b2;
              while (true) {
                var maybe2 = f(value16);
                if (isNothing2(maybe2)) return result;
                var tuple = fromJust5(maybe2);
                result.push(fst2(tuple));
                value16 = snd2(tuple);
              }
            };
          };
        };
      };
    };
  };

  // output/Data.Unfoldable1/foreign.js
  var unfoldr1ArrayImpl = function(isNothing2) {
    return function(fromJust5) {
      return function(fst2) {
        return function(snd2) {
          return function(f) {
            return function(b2) {
              var result = [];
              var value16 = b2;
              while (true) {
                var tuple = f(value16);
                result.push(fst2(tuple));
                var maybe2 = snd2(tuple);
                if (isNothing2(maybe2)) return result;
                value16 = fromJust5(maybe2);
              }
            };
          };
        };
      };
    };
  };

  // output/Data.Unfoldable1/index.js
  var fromJust2 = /* @__PURE__ */ fromJust();
  var unfoldable1Array = {
    unfoldr1: /* @__PURE__ */ unfoldr1ArrayImpl(isNothing)(fromJust2)(fst)(snd)
  };

  // output/Data.Unfoldable/index.js
  var fromJust3 = /* @__PURE__ */ fromJust();
  var unfoldr = function(dict) {
    return dict.unfoldr;
  };
  var unfoldableArray = {
    unfoldr: /* @__PURE__ */ unfoldrArrayImpl(isNothing)(fromJust3)(fst)(snd),
    Unfoldable10: function() {
      return unfoldable1Array;
    }
  };

  // output/Data.Array/index.js
  var map5 = /* @__PURE__ */ map(functorMaybe);
  var fromJust4 = /* @__PURE__ */ fromJust();
  var unsafeIndex = function() {
    return runFn2(unsafeIndexImpl);
  };
  var unsafeIndex1 = /* @__PURE__ */ unsafeIndex();
  var sortBy = function(comp) {
    return runFn3(sortByImpl)(comp)(function(v2) {
      if (v2 instanceof GT) {
        return 1;
      }
      ;
      if (v2 instanceof EQ) {
        return 0;
      }
      ;
      if (v2 instanceof LT) {
        return -1 | 0;
      }
      ;
      throw new Error("Failed pattern match at Data.Array (line 897, column 38 - line 900, column 11): " + [v2.constructor.name]);
    });
  };
  var snoc = function(xs) {
    return function(x) {
      return withArray(push(x))(xs)();
    };
  };
  var slice = /* @__PURE__ */ runFn3(sliceImpl);
  var singleton2 = function(a3) {
    return [a3];
  };
  var index = /* @__PURE__ */ (function() {
    return runFn4(indexImpl)(Just.create)(Nothing.value);
  })();
  var last = function(xs) {
    return index(xs)(length(xs) - 1 | 0);
  };
  var foldl2 = /* @__PURE__ */ foldl(foldableArray);
  var findIndex = /* @__PURE__ */ (function() {
    return runFn4(findIndexImpl)(Just.create)(Nothing.value);
  })();
  var find2 = function(f) {
    return function(xs) {
      return map5(unsafeIndex1(xs))(findIndex(f)(xs));
    };
  };
  var filter = /* @__PURE__ */ runFn2(filterImpl);
  var deleteAt = /* @__PURE__ */ (function() {
    return runFn4(_deleteAt)(Just.create)(Nothing.value);
  })();
  var deleteBy = function(v2) {
    return function(v1) {
      return function(v22) {
        if (v22.length === 0) {
          return [];
        }
        ;
        return maybe(v22)(function(i2) {
          return fromJust4(deleteAt(i2)(v22));
        })(findIndex(v2(v1))(v22));
      };
    };
  };
  var concatMap = /* @__PURE__ */ flip(/* @__PURE__ */ bind(bindArray));
  var mapMaybe = function(f) {
    return concatMap((function() {
      var $189 = maybe([])(singleton2);
      return function($190) {
        return $189(f($190));
      };
    })());
  };
  var catMaybes = /* @__PURE__ */ mapMaybe(/* @__PURE__ */ identity(categoryFn));

  // output/Data.Nullable/foreign.js
  var nullImpl = null;
  function nullable(a3, r, f) {
    return a3 == null ? r : f(a3);
  }
  function notNull(x) {
    return x;
  }

  // output/Data.Nullable/index.js
  var toNullable = /* @__PURE__ */ maybe(nullImpl)(notNull);
  var toMaybe = function(n) {
    return nullable(n, Nothing.value, Just.create);
  };

  // output/Halogen.VDom.Machine/index.js
  var Step = /* @__PURE__ */ (function() {
    function Step3(value0, value1, value22, value32) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
      this.value3 = value32;
    }
    ;
    Step3.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return function(value32) {
            return new Step3(value0, value1, value22, value32);
          };
        };
      };
    };
    return Step3;
  })();
  var unStep = unsafeCoerce2;
  var step = function(v2, a3) {
    return v2.value2(v2.value1, a3);
  };
  var mkStep = unsafeCoerce2;
  var halt = function(v2) {
    return v2.value3(v2.value1);
  };
  var extract2 = /* @__PURE__ */ unStep(function(v2) {
    return v2.value0;
  });

  // output/Halogen.VDom.Types/index.js
  var map6 = /* @__PURE__ */ map(functorArray);
  var map1 = /* @__PURE__ */ map(functorTuple);
  var Text = /* @__PURE__ */ (function() {
    function Text2(value0) {
      this.value0 = value0;
    }
    ;
    Text2.create = function(value0) {
      return new Text2(value0);
    };
    return Text2;
  })();
  var Elem = /* @__PURE__ */ (function() {
    function Elem2(value0, value1, value22, value32) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
      this.value3 = value32;
    }
    ;
    Elem2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return function(value32) {
            return new Elem2(value0, value1, value22, value32);
          };
        };
      };
    };
    return Elem2;
  })();
  var Keyed = /* @__PURE__ */ (function() {
    function Keyed2(value0, value1, value22, value32) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
      this.value3 = value32;
    }
    ;
    Keyed2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return function(value32) {
            return new Keyed2(value0, value1, value22, value32);
          };
        };
      };
    };
    return Keyed2;
  })();
  var Widget = /* @__PURE__ */ (function() {
    function Widget2(value0) {
      this.value0 = value0;
    }
    ;
    Widget2.create = function(value0) {
      return new Widget2(value0);
    };
    return Widget2;
  })();
  var Grafted = /* @__PURE__ */ (function() {
    function Grafted2(value0) {
      this.value0 = value0;
    }
    ;
    Grafted2.create = function(value0) {
      return new Grafted2(value0);
    };
    return Grafted2;
  })();
  var Graft = /* @__PURE__ */ (function() {
    function Graft2(value0, value1, value22) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
    }
    ;
    Graft2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return new Graft2(value0, value1, value22);
        };
      };
    };
    return Graft2;
  })();
  var unGraft = function(f) {
    return function($61) {
      return f($61);
    };
  };
  var graft = unsafeCoerce2;
  var bifunctorGraft = {
    bimap: function(f) {
      return function(g) {
        return unGraft(function(v2) {
          return graft(new Graft(function($63) {
            return f(v2.value0($63));
          }, function($64) {
            return g(v2.value1($64));
          }, v2.value2));
        });
      };
    }
  };
  var bimap2 = /* @__PURE__ */ bimap(bifunctorGraft);
  var runGraft = /* @__PURE__ */ unGraft(function(v2) {
    var go2 = function(v22) {
      if (v22 instanceof Text) {
        return new Text(v22.value0);
      }
      ;
      if (v22 instanceof Elem) {
        return new Elem(v22.value0, v22.value1, v2.value0(v22.value2), map6(go2)(v22.value3));
      }
      ;
      if (v22 instanceof Keyed) {
        return new Keyed(v22.value0, v22.value1, v2.value0(v22.value2), map6(map1(go2))(v22.value3));
      }
      ;
      if (v22 instanceof Widget) {
        return new Widget(v2.value1(v22.value0));
      }
      ;
      if (v22 instanceof Grafted) {
        return new Grafted(bimap2(v2.value0)(v2.value1)(v22.value0));
      }
      ;
      throw new Error("Failed pattern match at Halogen.VDom.Types (line 86, column 7 - line 86, column 27): " + [v22.constructor.name]);
    };
    return go2(v2.value2);
  });

  // output/Halogen.VDom.Util/foreign.js
  function unsafeGetAny(key2, obj) {
    return obj[key2];
  }
  function unsafeHasAny(key2, obj) {
    return obj.hasOwnProperty(key2);
  }
  function unsafeSetAny(key2, val, obj) {
    obj[key2] = val;
  }
  function forE2(a3, f) {
    var b2 = [];
    for (var i2 = 0; i2 < a3.length; i2++) {
      b2.push(f(i2, a3[i2]));
    }
    return b2;
  }
  function forEachE(a3, f) {
    for (var i2 = 0; i2 < a3.length; i2++) {
      f(a3[i2]);
    }
  }
  function forInE(o, f) {
    var ks = Object.keys(o);
    for (var i2 = 0; i2 < ks.length; i2++) {
      var k = ks[i2];
      f(k, o[k]);
    }
  }
  function diffWithIxE(a1, a22, f1, f2, f3) {
    var a3 = [];
    var l1 = a1.length;
    var l2 = a22.length;
    var i2 = 0;
    while (1) {
      if (i2 < l1) {
        if (i2 < l2) {
          a3.push(f1(i2, a1[i2], a22[i2]));
        } else {
          f2(i2, a1[i2]);
        }
      } else if (i2 < l2) {
        a3.push(f3(i2, a22[i2]));
      } else {
        break;
      }
      i2++;
    }
    return a3;
  }
  function strMapWithIxE(as, fk, f) {
    var o = {};
    for (var i2 = 0; i2 < as.length; i2++) {
      var a3 = as[i2];
      var k = fk(a3);
      o[k] = f(k, i2, a3);
    }
    return o;
  }
  function diffWithKeyAndIxE(o1, as, fk, f1, f2, f3) {
    var o2 = {};
    for (var i2 = 0; i2 < as.length; i2++) {
      var a3 = as[i2];
      var k = fk(a3);
      if (o1.hasOwnProperty(k)) {
        o2[k] = f1(k, i2, o1[k], a3);
      } else {
        o2[k] = f3(k, i2, a3);
      }
    }
    for (var k in o1) {
      if (k in o2) {
        continue;
      }
      f2(k, o1[k]);
    }
    return o2;
  }
  function refEq2(a3, b2) {
    return a3 === b2;
  }
  function createTextNode(s2, doc) {
    return doc.createTextNode(s2);
  }
  function setTextContent(s2, n) {
    n.textContent = s2;
  }
  function createElement(ns, name16, doc) {
    if (ns != null) {
      return doc.createElementNS(ns, name16);
    } else {
      return doc.createElement(name16);
    }
  }
  function insertChildIx(i2, a3, b2) {
    var n = b2.childNodes.item(i2) || null;
    if (n !== a3) {
      b2.insertBefore(a3, n);
    }
  }
  function removeChild(a3, b2) {
    if (b2 && a3.parentNode === b2) {
      b2.removeChild(a3);
    }
  }
  function parentNode(a3) {
    return a3.parentNode;
  }
  function setAttribute(ns, attr3, val, el) {
    if (ns != null) {
      el.setAttributeNS(ns, attr3, val);
    } else {
      el.setAttribute(attr3, val);
    }
  }
  function removeAttribute(ns, attr3, el) {
    if (ns != null) {
      el.removeAttributeNS(ns, attr3);
    } else {
      el.removeAttribute(attr3);
    }
  }
  function hasAttribute(ns, attr3, el) {
    if (ns != null) {
      return el.hasAttributeNS(ns, attr3);
    } else {
      return el.hasAttribute(attr3);
    }
  }
  function addEventListener(ev, listener, el) {
    el.addEventListener(ev, listener, false);
  }
  function removeEventListener(ev, listener, el) {
    el.removeEventListener(ev, listener, false);
  }
  var jsUndefined = void 0;

  // output/Foreign.Object.ST/foreign.js
  var newImpl = function() {
    return {};
  };
  function poke2(k) {
    return function(v2) {
      return function(m2) {
        return function() {
          m2[k] = v2;
          return m2;
        };
      };
    };
  }

  // output/Halogen.VDom.Util/index.js
  var unsafeLookup = unsafeGetAny;
  var unsafeFreeze2 = unsafeCoerce2;
  var pokeMutMap = unsafeSetAny;
  var newMutMap = newImpl;

  // output/Web.DOM.Element/foreign.js
  var getProp = function(name16) {
    return function(doctype) {
      return doctype[name16];
    };
  };
  var _namespaceURI = getProp("namespaceURI");
  var _prefix = getProp("prefix");
  var localName = getProp("localName");
  var tagName = getProp("tagName");

  // output/Web.DOM.ParentNode/foreign.js
  var getEffProp = function(name16) {
    return function(node) {
      return function() {
        return node[name16];
      };
    };
  };
  var children = getEffProp("children");
  var _firstElementChild = getEffProp("firstElementChild");
  var _lastElementChild = getEffProp("lastElementChild");
  var childElementCount = getEffProp("childElementCount");
  function _querySelector(selector) {
    return function(node) {
      return function() {
        return node.querySelector(selector);
      };
    };
  }

  // output/Web.DOM.ParentNode/index.js
  var map7 = /* @__PURE__ */ map(functorEffect);
  var querySelector = function(qs) {
    var $2 = map7(toMaybe);
    var $3 = _querySelector(qs);
    return function($4) {
      return $2($3($4));
    };
  };

  // output/Web.DOM.Element/index.js
  var toNode = unsafeCoerce2;

  // output/Halogen.VDom.DOM/index.js
  var $runtime_lazy2 = function(name16, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name16 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var haltWidget = function(v2) {
    return halt(v2.widget);
  };
  var $lazy_patchWidget = /* @__PURE__ */ $runtime_lazy2("patchWidget", "Halogen.VDom.DOM", function() {
    return function(state3, vdom) {
      if (vdom instanceof Grafted) {
        return $lazy_patchWidget(291)(state3, runGraft(vdom.value0));
      }
      ;
      if (vdom instanceof Widget) {
        var res = step(state3.widget, vdom.value0);
        var res$prime = unStep(function(v2) {
          return mkStep(new Step(v2.value0, {
            build: state3.build,
            widget: res
          }, $lazy_patchWidget(296), haltWidget));
        })(res);
        return res$prime;
      }
      ;
      haltWidget(state3);
      return state3.build(vdom);
    };
  });
  var patchWidget = /* @__PURE__ */ $lazy_patchWidget(286);
  var haltText = function(v2) {
    var parent2 = parentNode(v2.node);
    return removeChild(v2.node, parent2);
  };
  var $lazy_patchText = /* @__PURE__ */ $runtime_lazy2("patchText", "Halogen.VDom.DOM", function() {
    return function(state3, vdom) {
      if (vdom instanceof Grafted) {
        return $lazy_patchText(82)(state3, runGraft(vdom.value0));
      }
      ;
      if (vdom instanceof Text) {
        if (state3.value === vdom.value0) {
          return mkStep(new Step(state3.node, state3, $lazy_patchText(85), haltText));
        }
        ;
        if (otherwise) {
          var nextState = {
            build: state3.build,
            node: state3.node,
            value: vdom.value0
          };
          setTextContent(vdom.value0, state3.node);
          return mkStep(new Step(state3.node, nextState, $lazy_patchText(89), haltText));
        }
        ;
      }
      ;
      haltText(state3);
      return state3.build(vdom);
    };
  });
  var patchText = /* @__PURE__ */ $lazy_patchText(77);
  var haltKeyed = function(v2) {
    var parent2 = parentNode(v2.node);
    removeChild(v2.node, parent2);
    forInE(v2.children, function(v1, s2) {
      return halt(s2);
    });
    return halt(v2.attrs);
  };
  var haltElem = function(v2) {
    var parent2 = parentNode(v2.node);
    removeChild(v2.node, parent2);
    forEachE(v2.children, halt);
    return halt(v2.attrs);
  };
  var eqElemSpec = function(ns1, v2, ns2, v1) {
    var $63 = v2 === v1;
    if ($63) {
      if (ns1 instanceof Just && (ns2 instanceof Just && ns1.value0 === ns2.value0)) {
        return true;
      }
      ;
      if (ns1 instanceof Nothing && ns2 instanceof Nothing) {
        return true;
      }
      ;
      return false;
    }
    ;
    return false;
  };
  var $lazy_patchElem = /* @__PURE__ */ $runtime_lazy2("patchElem", "Halogen.VDom.DOM", function() {
    return function(state3, vdom) {
      if (vdom instanceof Grafted) {
        return $lazy_patchElem(135)(state3, runGraft(vdom.value0));
      }
      ;
      if (vdom instanceof Elem && eqElemSpec(state3.ns, state3.name, vdom.value0, vdom.value1)) {
        var v2 = length(vdom.value3);
        var v1 = length(state3.children);
        if (v1 === 0 && v2 === 0) {
          var attrs2 = step(state3.attrs, vdom.value2);
          var nextState = {
            build: state3.build,
            node: state3.node,
            attrs: attrs2,
            ns: vdom.value0,
            name: vdom.value1,
            children: state3.children
          };
          return mkStep(new Step(state3.node, nextState, $lazy_patchElem(149), haltElem));
        }
        ;
        var onThis = function(v22, s2) {
          return halt(s2);
        };
        var onThese = function(ix, s2, v22) {
          var res = step(s2, v22);
          insertChildIx(ix, extract2(res), state3.node);
          return res;
        };
        var onThat = function(ix, v22) {
          var res = state3.build(v22);
          insertChildIx(ix, extract2(res), state3.node);
          return res;
        };
        var children2 = diffWithIxE(state3.children, vdom.value3, onThese, onThis, onThat);
        var attrs2 = step(state3.attrs, vdom.value2);
        var nextState = {
          build: state3.build,
          node: state3.node,
          attrs: attrs2,
          ns: vdom.value0,
          name: vdom.value1,
          children: children2
        };
        return mkStep(new Step(state3.node, nextState, $lazy_patchElem(172), haltElem));
      }
      ;
      haltElem(state3);
      return state3.build(vdom);
    };
  });
  var patchElem = /* @__PURE__ */ $lazy_patchElem(130);
  var $lazy_patchKeyed = /* @__PURE__ */ $runtime_lazy2("patchKeyed", "Halogen.VDom.DOM", function() {
    return function(state3, vdom) {
      if (vdom instanceof Grafted) {
        return $lazy_patchKeyed(222)(state3, runGraft(vdom.value0));
      }
      ;
      if (vdom instanceof Keyed && eqElemSpec(state3.ns, state3.name, vdom.value0, vdom.value1)) {
        var v2 = length(vdom.value3);
        if (state3.length === 0 && v2 === 0) {
          var attrs2 = step(state3.attrs, vdom.value2);
          var nextState = {
            build: state3.build,
            node: state3.node,
            attrs: attrs2,
            ns: vdom.value0,
            name: vdom.value1,
            children: state3.children,
            length: 0
          };
          return mkStep(new Step(state3.node, nextState, $lazy_patchKeyed(237), haltKeyed));
        }
        ;
        var onThis = function(v22, s2) {
          return halt(s2);
        };
        var onThese = function(v22, ix$prime, s2, v3) {
          var res = step(s2, v3.value1);
          insertChildIx(ix$prime, extract2(res), state3.node);
          return res;
        };
        var onThat = function(v22, ix, v3) {
          var res = state3.build(v3.value1);
          insertChildIx(ix, extract2(res), state3.node);
          return res;
        };
        var children2 = diffWithKeyAndIxE(state3.children, vdom.value3, fst, onThese, onThis, onThat);
        var attrs2 = step(state3.attrs, vdom.value2);
        var nextState = {
          build: state3.build,
          node: state3.node,
          attrs: attrs2,
          ns: vdom.value0,
          name: vdom.value1,
          children: children2,
          length: v2
        };
        return mkStep(new Step(state3.node, nextState, $lazy_patchKeyed(261), haltKeyed));
      }
      ;
      haltKeyed(state3);
      return state3.build(vdom);
    };
  });
  var patchKeyed = /* @__PURE__ */ $lazy_patchKeyed(217);
  var buildWidget = function(v2, build, w) {
    var res = v2.buildWidget(v2)(w);
    var res$prime = unStep(function(v1) {
      return mkStep(new Step(v1.value0, {
        build,
        widget: res
      }, patchWidget, haltWidget));
    })(res);
    return res$prime;
  };
  var buildText = function(v2, build, s2) {
    var node = createTextNode(s2, v2.document);
    var state3 = {
      build,
      node,
      value: s2
    };
    return mkStep(new Step(node, state3, patchText, haltText));
  };
  var buildKeyed = function(v2, build, ns1, name1, as1, ch1) {
    var el = createElement(toNullable(ns1), name1, v2.document);
    var node = toNode(el);
    var onChild = function(v1, ix, v22) {
      var res = build(v22.value1);
      insertChildIx(ix, extract2(res), node);
      return res;
    };
    var children2 = strMapWithIxE(ch1, fst, onChild);
    var attrs = v2.buildAttributes(el)(as1);
    var state3 = {
      build,
      node,
      attrs,
      ns: ns1,
      name: name1,
      children: children2,
      length: length(ch1)
    };
    return mkStep(new Step(node, state3, patchKeyed, haltKeyed));
  };
  var buildElem = function(v2, build, ns1, name1, as1, ch1) {
    var el = createElement(toNullable(ns1), name1, v2.document);
    var node = toNode(el);
    var onChild = function(ix, child) {
      var res = build(child);
      insertChildIx(ix, extract2(res), node);
      return res;
    };
    var children2 = forE2(ch1, onChild);
    var attrs = v2.buildAttributes(el)(as1);
    var state3 = {
      build,
      node,
      attrs,
      ns: ns1,
      name: name1,
      children: children2
    };
    return mkStep(new Step(node, state3, patchElem, haltElem));
  };
  var buildVDom = function(spec) {
    var $lazy_build = $runtime_lazy2("build", "Halogen.VDom.DOM", function() {
      return function(v2) {
        if (v2 instanceof Text) {
          return buildText(spec, $lazy_build(59), v2.value0);
        }
        ;
        if (v2 instanceof Elem) {
          return buildElem(spec, $lazy_build(60), v2.value0, v2.value1, v2.value2, v2.value3);
        }
        ;
        if (v2 instanceof Keyed) {
          return buildKeyed(spec, $lazy_build(61), v2.value0, v2.value1, v2.value2, v2.value3);
        }
        ;
        if (v2 instanceof Widget) {
          return buildWidget(spec, $lazy_build(62), v2.value0);
        }
        ;
        if (v2 instanceof Grafted) {
          return $lazy_build(63)(runGraft(v2.value0));
        }
        ;
        throw new Error("Failed pattern match at Halogen.VDom.DOM (line 58, column 27 - line 63, column 52): " + [v2.constructor.name]);
      };
    });
    var build = $lazy_build(58);
    return build;
  };

  // output/Foreign/foreign.js
  function typeOf(value16) {
    return typeof value16;
  }
  function tagOf(value16) {
    return Object.prototype.toString.call(value16).slice(8, -1);
  }

  // output/Effect.Exception/foreign.js
  function error(msg) {
    return new Error(msg);
  }
  function message(e) {
    return e.message;
  }
  function throwException(e) {
    return function() {
      throw e;
    };
  }

  // output/Effect.Exception/index.js
  var $$throw = function($4) {
    return throwException(error($4));
  };

  // output/Control.Monad.Error.Class/index.js
  var throwError = function(dict) {
    return dict.throwError;
  };
  var catchError = function(dict) {
    return dict.catchError;
  };
  var $$try = function(dictMonadError) {
    var catchError1 = catchError(dictMonadError);
    var Monad0 = dictMonadError.MonadThrow0().Monad0();
    var map31 = map(Monad0.Bind1().Apply0().Functor0());
    var pure18 = pure(Monad0.Applicative0());
    return function(a3) {
      return catchError1(map31(Right.create)(a3))(function($52) {
        return pure18(Left.create($52));
      });
    };
  };

  // output/Control.Monad.State.Class/index.js
  var state = function(dict) {
    return dict.state;
  };
  var modify_2 = function(dictMonadState) {
    var state1 = state(dictMonadState);
    return function(f) {
      return state1(function(s2) {
        return new Tuple(unit, f(s2));
      });
    };
  };
  var get = function(dictMonadState) {
    return state(dictMonadState)(function(s2) {
      return new Tuple(s2, s2);
    });
  };

  // output/Control.Monad.Trans.Class/index.js
  var lift = function(dict) {
    return dict.lift;
  };

  // output/Effect.Class/index.js
  var monadEffectEffect = {
    liftEffect: /* @__PURE__ */ identity(categoryFn),
    Monad0: function() {
      return monadEffect;
    }
  };
  var liftEffect = function(dict) {
    return dict.liftEffect;
  };

  // output/Control.Monad.Except.Trans/index.js
  var map8 = /* @__PURE__ */ map(functorEither);
  var ExceptT = function(x) {
    return x;
  };
  var runExceptT = function(v2) {
    return v2;
  };
  var mapExceptT = function(f) {
    return function(v2) {
      return f(v2);
    };
  };
  var functorExceptT = function(dictFunctor) {
    var map112 = map(dictFunctor);
    return {
      map: function(f) {
        return mapExceptT(map112(map8(f)));
      }
    };
  };
  var monadExceptT = function(dictMonad) {
    return {
      Applicative0: function() {
        return applicativeExceptT(dictMonad);
      },
      Bind1: function() {
        return bindExceptT(dictMonad);
      }
    };
  };
  var bindExceptT = function(dictMonad) {
    var bind10 = bind(dictMonad.Bind1());
    var pure18 = pure(dictMonad.Applicative0());
    return {
      bind: function(v2) {
        return function(k) {
          return bind10(v2)(either(function($187) {
            return pure18(Left.create($187));
          })(function(a3) {
            var v1 = k(a3);
            return v1;
          }));
        };
      },
      Apply0: function() {
        return applyExceptT(dictMonad);
      }
    };
  };
  var applyExceptT = function(dictMonad) {
    var functorExceptT1 = functorExceptT(dictMonad.Bind1().Apply0().Functor0());
    return {
      apply: ap(monadExceptT(dictMonad)),
      Functor0: function() {
        return functorExceptT1;
      }
    };
  };
  var applicativeExceptT = function(dictMonad) {
    return {
      pure: (function() {
        var $188 = pure(dictMonad.Applicative0());
        return function($189) {
          return ExceptT($188(Right.create($189)));
        };
      })(),
      Apply0: function() {
        return applyExceptT(dictMonad);
      }
    };
  };
  var monadThrowExceptT = function(dictMonad) {
    var monadExceptT1 = monadExceptT(dictMonad);
    return {
      throwError: (function() {
        var $198 = pure(dictMonad.Applicative0());
        return function($199) {
          return ExceptT($198(Left.create($199)));
        };
      })(),
      Monad0: function() {
        return monadExceptT1;
      }
    };
  };
  var altExceptT = function(dictSemigroup) {
    var append6 = append(dictSemigroup);
    return function(dictMonad) {
      var Bind1 = dictMonad.Bind1();
      var bind10 = bind(Bind1);
      var pure18 = pure(dictMonad.Applicative0());
      var functorExceptT1 = functorExceptT(Bind1.Apply0().Functor0());
      return {
        alt: function(v2) {
          return function(v1) {
            return bind10(v2)(function(rm) {
              if (rm instanceof Right) {
                return pure18(new Right(rm.value0));
              }
              ;
              if (rm instanceof Left) {
                return bind10(v1)(function(rn) {
                  if (rn instanceof Right) {
                    return pure18(new Right(rn.value0));
                  }
                  ;
                  if (rn instanceof Left) {
                    return pure18(new Left(append6(rm.value0)(rn.value0)));
                  }
                  ;
                  throw new Error("Failed pattern match at Control.Monad.Except.Trans (line 86, column 9 - line 88, column 49): " + [rn.constructor.name]);
                });
              }
              ;
              throw new Error("Failed pattern match at Control.Monad.Except.Trans (line 82, column 5 - line 88, column 49): " + [rm.constructor.name]);
            });
          };
        },
        Functor0: function() {
          return functorExceptT1;
        }
      };
    };
  };

  // output/Data.Int/foreign.js
  var fromNumberImpl = function(just) {
    return function(nothing) {
      return function(n) {
        return (n | 0) === n ? just(n) : nothing;
      };
    };
  };

  // output/Data.Int/index.js
  var fromNumber = /* @__PURE__ */ (function() {
    return fromNumberImpl(Just.create)(Nothing.value);
  })();

  // output/Data.FoldableWithIndex/index.js
  var foldr8 = /* @__PURE__ */ foldr(foldableArray);
  var mapWithIndex2 = /* @__PURE__ */ mapWithIndex(functorWithIndexArray);
  var foldl8 = /* @__PURE__ */ foldl(foldableArray);
  var foldrWithIndex = function(dict) {
    return dict.foldrWithIndex;
  };
  var foldMapWithIndexDefaultR = function(dictFoldableWithIndex) {
    var foldrWithIndex1 = foldrWithIndex(dictFoldableWithIndex);
    return function(dictMonoid) {
      var append6 = append(dictMonoid.Semigroup0());
      var mempty3 = mempty(dictMonoid);
      return function(f) {
        return foldrWithIndex1(function(i2) {
          return function(x) {
            return function(acc) {
              return append6(f(i2)(x))(acc);
            };
          };
        })(mempty3);
      };
    };
  };
  var foldableWithIndexArray = {
    foldrWithIndex: function(f) {
      return function(z2) {
        var $291 = foldr8(function(v2) {
          return function(y) {
            return f(v2.value0)(v2.value1)(y);
          };
        })(z2);
        var $292 = mapWithIndex2(Tuple.create);
        return function($293) {
          return $291($292($293));
        };
      };
    },
    foldlWithIndex: function(f) {
      return function(z2) {
        var $294 = foldl8(function(y) {
          return function(v2) {
            return f(v2.value0)(y)(v2.value1);
          };
        })(z2);
        var $295 = mapWithIndex2(Tuple.create);
        return function($296) {
          return $294($295($296));
        };
      };
    },
    foldMapWithIndex: function(dictMonoid) {
      return foldMapWithIndexDefaultR(foldableWithIndexArray)(dictMonoid);
    },
    Foldable0: function() {
      return foldableArray;
    }
  };

  // output/Data.TraversableWithIndex/index.js
  var traverseWithIndexDefault = function(dictTraversableWithIndex) {
    var sequence2 = sequence(dictTraversableWithIndex.Traversable2());
    var mapWithIndex4 = mapWithIndex(dictTraversableWithIndex.FunctorWithIndex0());
    return function(dictApplicative) {
      var sequence12 = sequence2(dictApplicative);
      return function(f) {
        var $174 = mapWithIndex4(f);
        return function($175) {
          return sequence12($174($175));
        };
      };
    };
  };
  var traverseWithIndex = function(dict) {
    return dict.traverseWithIndex;
  };
  var traversableWithIndexArray = {
    traverseWithIndex: function(dictApplicative) {
      return traverseWithIndexDefault(traversableWithIndexArray)(dictApplicative);
    },
    FunctorWithIndex0: function() {
      return functorWithIndexArray;
    },
    FoldableWithIndex1: function() {
      return foldableWithIndexArray;
    },
    Traversable2: function() {
      return traversableArray;
    }
  };

  // output/Data.NonEmpty/index.js
  var NonEmpty = /* @__PURE__ */ (function() {
    function NonEmpty2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    NonEmpty2.create = function(value0) {
      return function(value1) {
        return new NonEmpty2(value0, value1);
      };
    };
    return NonEmpty2;
  })();
  var singleton3 = function(dictPlus) {
    var empty7 = empty(dictPlus);
    return function(a3) {
      return new NonEmpty(a3, empty7);
    };
  };

  // output/Data.List.Types/index.js
  var Nil = /* @__PURE__ */ (function() {
    function Nil2() {
    }
    ;
    Nil2.value = new Nil2();
    return Nil2;
  })();
  var Cons = /* @__PURE__ */ (function() {
    function Cons2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Cons2.create = function(value0) {
      return function(value1) {
        return new Cons2(value0, value1);
      };
    };
    return Cons2;
  })();
  var NonEmptyList = function(x) {
    return x;
  };
  var toList = function(v2) {
    return new Cons(v2.value0, v2.value1);
  };
  var listMap = function(f) {
    var chunkedRevMap = function($copy_v) {
      return function($copy_v1) {
        var $tco_var_v = $copy_v;
        var $tco_done = false;
        var $tco_result;
        function $tco_loop(v2, v1) {
          if (v1 instanceof Cons && (v1.value1 instanceof Cons && v1.value1.value1 instanceof Cons)) {
            $tco_var_v = new Cons(v1, v2);
            $copy_v1 = v1.value1.value1.value1;
            return;
          }
          ;
          var unrolledMap = function(v22) {
            if (v22 instanceof Cons && (v22.value1 instanceof Cons && v22.value1.value1 instanceof Nil)) {
              return new Cons(f(v22.value0), new Cons(f(v22.value1.value0), Nil.value));
            }
            ;
            if (v22 instanceof Cons && v22.value1 instanceof Nil) {
              return new Cons(f(v22.value0), Nil.value);
            }
            ;
            return Nil.value;
          };
          var reverseUnrolledMap = function($copy_v2) {
            return function($copy_v3) {
              var $tco_var_v2 = $copy_v2;
              var $tco_done1 = false;
              var $tco_result2;
              function $tco_loop2(v22, v3) {
                if (v22 instanceof Cons && (v22.value0 instanceof Cons && (v22.value0.value1 instanceof Cons && v22.value0.value1.value1 instanceof Cons))) {
                  $tco_var_v2 = v22.value1;
                  $copy_v3 = new Cons(f(v22.value0.value0), new Cons(f(v22.value0.value1.value0), new Cons(f(v22.value0.value1.value1.value0), v3)));
                  return;
                }
                ;
                $tco_done1 = true;
                return v3;
              }
              ;
              while (!$tco_done1) {
                $tco_result2 = $tco_loop2($tco_var_v2, $copy_v3);
              }
              ;
              return $tco_result2;
            };
          };
          $tco_done = true;
          return reverseUnrolledMap(v2)(unrolledMap(v1));
        }
        ;
        while (!$tco_done) {
          $tco_result = $tco_loop($tco_var_v, $copy_v1);
        }
        ;
        return $tco_result;
      };
    };
    return chunkedRevMap(Nil.value);
  };
  var functorList = {
    map: listMap
  };
  var foldableList = {
    foldr: function(f) {
      return function(b2) {
        var rev3 = (function() {
          var go2 = function($copy_v) {
            return function($copy_v1) {
              var $tco_var_v = $copy_v;
              var $tco_done = false;
              var $tco_result;
              function $tco_loop(v2, v1) {
                if (v1 instanceof Nil) {
                  $tco_done = true;
                  return v2;
                }
                ;
                if (v1 instanceof Cons) {
                  $tco_var_v = new Cons(v1.value0, v2);
                  $copy_v1 = v1.value1;
                  return;
                }
                ;
                throw new Error("Failed pattern match at Data.List.Types (line 107, column 7 - line 107, column 23): " + [v2.constructor.name, v1.constructor.name]);
              }
              ;
              while (!$tco_done) {
                $tco_result = $tco_loop($tco_var_v, $copy_v1);
              }
              ;
              return $tco_result;
            };
          };
          return go2(Nil.value);
        })();
        var $284 = foldl(foldableList)(flip(f))(b2);
        return function($285) {
          return $284(rev3($285));
        };
      };
    },
    foldl: function(f) {
      var go2 = function($copy_b) {
        return function($copy_v) {
          var $tco_var_b = $copy_b;
          var $tco_done1 = false;
          var $tco_result;
          function $tco_loop(b2, v2) {
            if (v2 instanceof Nil) {
              $tco_done1 = true;
              return b2;
            }
            ;
            if (v2 instanceof Cons) {
              $tco_var_b = f(b2)(v2.value0);
              $copy_v = v2.value1;
              return;
            }
            ;
            throw new Error("Failed pattern match at Data.List.Types (line 111, column 12 - line 113, column 30): " + [v2.constructor.name]);
          }
          ;
          while (!$tco_done1) {
            $tco_result = $tco_loop($tco_var_b, $copy_v);
          }
          ;
          return $tco_result;
        };
      };
      return go2;
    },
    foldMap: function(dictMonoid) {
      var append22 = append(dictMonoid.Semigroup0());
      var mempty3 = mempty(dictMonoid);
      return function(f) {
        return foldl(foldableList)(function(acc) {
          var $286 = append22(acc);
          return function($287) {
            return $286(f($287));
          };
        })(mempty3);
      };
    }
  };
  var foldr2 = /* @__PURE__ */ foldr(foldableList);
  var semigroupList = {
    append: function(xs) {
      return function(ys) {
        return foldr2(Cons.create)(ys)(xs);
      };
    }
  };
  var append1 = /* @__PURE__ */ append(semigroupList);
  var semigroupNonEmptyList = {
    append: function(v2) {
      return function(as$prime) {
        return new NonEmpty(v2.value0, append1(v2.value1)(toList(as$prime)));
      };
    }
  };
  var altList = {
    alt: append1,
    Functor0: function() {
      return functorList;
    }
  };
  var plusList = /* @__PURE__ */ (function() {
    return {
      empty: Nil.value,
      Alt0: function() {
        return altList;
      }
    };
  })();

  // output/Data.List/index.js
  var reverse2 = /* @__PURE__ */ (function() {
    var go2 = function($copy_v) {
      return function($copy_v1) {
        var $tco_var_v = $copy_v;
        var $tco_done = false;
        var $tco_result;
        function $tco_loop(v2, v1) {
          if (v1 instanceof Nil) {
            $tco_done = true;
            return v2;
          }
          ;
          if (v1 instanceof Cons) {
            $tco_var_v = new Cons(v1.value0, v2);
            $copy_v1 = v1.value1;
            return;
          }
          ;
          throw new Error("Failed pattern match at Data.List (line 368, column 3 - line 368, column 19): " + [v2.constructor.name, v1.constructor.name]);
        }
        ;
        while (!$tco_done) {
          $tco_result = $tco_loop($tco_var_v, $copy_v1);
        }
        ;
        return $tco_result;
      };
    };
    return go2(Nil.value);
  })();
  var $$null = function(v2) {
    if (v2 instanceof Nil) {
      return true;
    }
    ;
    return false;
  };

  // output/Partial.Unsafe/foreign.js
  var _unsafePartial = function(f) {
    return f();
  };

  // output/Partial/foreign.js
  var _crashWith = function(msg) {
    throw new Error(msg);
  };

  // output/Partial/index.js
  var crashWith = function() {
    return _crashWith;
  };

  // output/Partial.Unsafe/index.js
  var crashWith2 = /* @__PURE__ */ crashWith();
  var unsafePartial = _unsafePartial;
  var unsafeCrashWith = function(msg) {
    return unsafePartial(function() {
      return crashWith2(msg);
    });
  };

  // output/Data.List.NonEmpty/index.js
  var singleton4 = /* @__PURE__ */ (function() {
    var $200 = singleton3(plusList);
    return function($201) {
      return NonEmptyList($200($201));
    };
  })();
  var head = function(v2) {
    return v2.value0;
  };
  var cons = function(y) {
    return function(v2) {
      return new NonEmpty(y, new Cons(v2.value0, v2.value1));
    };
  };

  // output/Data.String.CodeUnits/foreign.js
  var length3 = function(s2) {
    return s2.length;
  };
  var _indexOf = function(just) {
    return function(nothing) {
      return function(x) {
        return function(s2) {
          var i2 = s2.indexOf(x);
          return i2 === -1 ? nothing : just(i2);
        };
      };
    };
  };
  var take2 = function(n) {
    return function(s2) {
      return s2.substr(0, n);
    };
  };
  var drop2 = function(n) {
    return function(s2) {
      return s2.substring(n);
    };
  };

  // output/Data.String.Unsafe/foreign.js
  var charAt = function(i2) {
    return function(s2) {
      if (i2 >= 0 && i2 < s2.length) return s2.charAt(i2);
      throw new Error("Data.String.Unsafe.charAt: Invalid index.");
    };
  };

  // output/Data.String.CodeUnits/index.js
  var takeRight = function(i2) {
    return function(s2) {
      return drop2(length3(s2) - i2 | 0)(s2);
    };
  };
  var indexOf = /* @__PURE__ */ (function() {
    return _indexOf(Just.create)(Nothing.value);
  })();
  var dropRight = function(i2) {
    return function(s2) {
      return take2(length3(s2) - i2 | 0)(s2);
    };
  };
  var contains = function(pat) {
    var $23 = indexOf(pat);
    return function($24) {
      return isJust($23($24));
    };
  };

  // output/Foreign/index.js
  var show2 = /* @__PURE__ */ show(showString);
  var show1 = /* @__PURE__ */ show(showInt);
  var ForeignError = /* @__PURE__ */ (function() {
    function ForeignError2(value0) {
      this.value0 = value0;
    }
    ;
    ForeignError2.create = function(value0) {
      return new ForeignError2(value0);
    };
    return ForeignError2;
  })();
  var TypeMismatch = /* @__PURE__ */ (function() {
    function TypeMismatch3(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    TypeMismatch3.create = function(value0) {
      return function(value1) {
        return new TypeMismatch3(value0, value1);
      };
    };
    return TypeMismatch3;
  })();
  var ErrorAtIndex = /* @__PURE__ */ (function() {
    function ErrorAtIndex2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    ErrorAtIndex2.create = function(value0) {
      return function(value1) {
        return new ErrorAtIndex2(value0, value1);
      };
    };
    return ErrorAtIndex2;
  })();
  var ErrorAtProperty = /* @__PURE__ */ (function() {
    function ErrorAtProperty2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    ErrorAtProperty2.create = function(value0) {
      return function(value1) {
        return new ErrorAtProperty2(value0, value1);
      };
    };
    return ErrorAtProperty2;
  })();
  var unsafeToForeign = unsafeCoerce2;
  var unsafeFromForeign = unsafeCoerce2;
  var renderForeignError = function(v2) {
    if (v2 instanceof ForeignError) {
      return v2.value0;
    }
    ;
    if (v2 instanceof ErrorAtIndex) {
      return "Error at array index " + (show1(v2.value0) + (": " + renderForeignError(v2.value1)));
    }
    ;
    if (v2 instanceof ErrorAtProperty) {
      return "Error at property " + (show2(v2.value0) + (": " + renderForeignError(v2.value1)));
    }
    ;
    if (v2 instanceof TypeMismatch) {
      return "Type mismatch: expected " + (v2.value0 + (", found " + v2.value1));
    }
    ;
    throw new Error("Failed pattern match at Foreign (line 78, column 1 - line 78, column 45): " + [v2.constructor.name]);
  };
  var fail = function(dictMonad) {
    var $153 = throwError(monadThrowExceptT(dictMonad));
    return function($154) {
      return $153(singleton4($154));
    };
  };
  var unsafeReadTagged = function(dictMonad) {
    var pure18 = pure(applicativeExceptT(dictMonad));
    var fail1 = fail(dictMonad);
    return function(tag2) {
      return function(value16) {
        if (tagOf(value16) === tag2) {
          return pure18(unsafeFromForeign(value16));
        }
        ;
        if (otherwise) {
          return fail1(new TypeMismatch(tag2, tagOf(value16)));
        }
        ;
        throw new Error("Failed pattern match at Foreign (line 123, column 1 - line 123, column 104): " + [tag2.constructor.name, value16.constructor.name]);
      };
    };
  };
  var readString = function(dictMonad) {
    return unsafeReadTagged(dictMonad)("String");
  };

  // output/Foreign.Object/foreign.js
  function _copyST(m2) {
    return function() {
      var r = {};
      for (var k in m2) {
        if (hasOwnProperty.call(m2, k)) {
          r[k] = m2[k];
        }
      }
      return r;
    };
  }
  var empty2 = {};
  function runST(f) {
    return f();
  }
  function _fmapObject(m0, f) {
    var m2 = {};
    for (var k in m0) {
      if (hasOwnProperty.call(m0, k)) {
        m2[k] = f(m0[k]);
      }
    }
    return m2;
  }
  function _mapWithKey(m0, f) {
    var m2 = {};
    for (var k in m0) {
      if (hasOwnProperty.call(m0, k)) {
        m2[k] = f(k)(m0[k]);
      }
    }
    return m2;
  }
  function _foldM(bind10) {
    return function(f) {
      return function(mz) {
        return function(m2) {
          var acc = mz;
          function g(k2) {
            return function(z2) {
              return f(z2)(k2)(m2[k2]);
            };
          }
          for (var k in m2) {
            if (hasOwnProperty.call(m2, k)) {
              acc = bind10(acc)(g(k));
            }
          }
          return acc;
        };
      };
    };
  }
  function _lookup(no, yes, k, m2) {
    return k in m2 ? yes(m2[k]) : no;
  }
  function toArrayWithKey(f) {
    return function(m2) {
      var r = [];
      for (var k in m2) {
        if (hasOwnProperty.call(m2, k)) {
          r.push(f(k)(m2[k]));
        }
      }
      return r;
    };
  }
  var keys = Object.keys || toArrayWithKey(function(k) {
    return function() {
      return k;
    };
  });

  // output/Foreign.Object/index.js
  var foldr3 = /* @__PURE__ */ foldr(foldableArray);
  var identity6 = /* @__PURE__ */ identity(categoryFn);
  var values = /* @__PURE__ */ toArrayWithKey(function(v2) {
    return function(v1) {
      return v1;
    };
  });
  var thawST = _copyST;
  var mutate = function(f) {
    return function(m2) {
      return runST(function __do3() {
        var s2 = thawST(m2)();
        f(s2)();
        return s2;
      });
    };
  };
  var mapWithKey = function(f) {
    return function(m2) {
      return _mapWithKey(m2, f);
    };
  };
  var lookup = /* @__PURE__ */ (function() {
    return runFn4(_lookup)(Nothing.value)(Just.create);
  })();
  var insert = function(k) {
    return function(v2) {
      return mutate(poke2(k)(v2));
    };
  };
  var functorObject = {
    map: function(f) {
      return function(m2) {
        return _fmapObject(m2, f);
      };
    }
  };
  var functorWithIndexObject = {
    mapWithIndex: mapWithKey,
    Functor0: function() {
      return functorObject;
    }
  };
  var fold2 = /* @__PURE__ */ _foldM(applyFlipped);
  var foldMap2 = function(dictMonoid) {
    var append12 = append(dictMonoid.Semigroup0());
    var mempty3 = mempty(dictMonoid);
    return function(f) {
      return fold2(function(acc) {
        return function(k) {
          return function(v2) {
            return append12(acc)(f(k)(v2));
          };
        };
      })(mempty3);
    };
  };
  var foldableObject = {
    foldl: function(f) {
      return fold2(function(z2) {
        return function(v2) {
          return f(z2);
        };
      });
    },
    foldr: function(f) {
      return function(z2) {
        return function(m2) {
          return foldr3(f)(z2)(values(m2));
        };
      };
    },
    foldMap: function(dictMonoid) {
      var foldMap12 = foldMap2(dictMonoid);
      return function(f) {
        return foldMap12($$const(f));
      };
    }
  };
  var foldableWithIndexObject = {
    foldlWithIndex: function(f) {
      return fold2(flip(f));
    },
    foldrWithIndex: function(f) {
      return function(z2) {
        return function(m2) {
          return foldr3(uncurry(f))(z2)(toArrayWithKey(Tuple.create)(m2));
        };
      };
    },
    foldMapWithIndex: function(dictMonoid) {
      return foldMap2(dictMonoid);
    },
    Foldable0: function() {
      return foldableObject;
    }
  };
  var traversableWithIndexObject = {
    traverseWithIndex: function(dictApplicative) {
      var Apply0 = dictApplicative.Apply0();
      var apply3 = apply(Apply0);
      var map31 = map(Apply0.Functor0());
      var pure18 = pure(dictApplicative);
      return function(f) {
        return function(ms) {
          return fold2(function(acc) {
            return function(k) {
              return function(v2) {
                return apply3(map31(flip(insert(k)))(acc))(f(k)(v2));
              };
            };
          })(pure18(empty2))(ms);
        };
      };
    },
    FunctorWithIndex0: function() {
      return functorWithIndexObject;
    },
    FoldableWithIndex1: function() {
      return foldableWithIndexObject;
    },
    Traversable2: function() {
      return traversableObject;
    }
  };
  var traversableObject = {
    traverse: function(dictApplicative) {
      var $96 = traverseWithIndex(traversableWithIndexObject)(dictApplicative);
      return function($97) {
        return $96($$const($97));
      };
    },
    sequence: function(dictApplicative) {
      return traverse(traversableObject)(dictApplicative)(identity6);
    },
    Functor0: function() {
      return functorObject;
    },
    Foldable1: function() {
      return foldableObject;
    }
  };

  // output/Web.Event.EventTarget/foreign.js
  function eventListener(fn) {
    return function() {
      return function(event) {
        return fn(event)();
      };
    };
  }
  function addEventListener2(type) {
    return function(listener) {
      return function(useCapture) {
        return function(target6) {
          return function() {
            return target6.addEventListener(type, listener, useCapture);
          };
        };
      };
    };
  }
  function removeEventListener2(type) {
    return function(listener) {
      return function(useCapture) {
        return function(target6) {
          return function() {
            return target6.removeEventListener(type, listener, useCapture);
          };
        };
      };
    };
  }

  // output/Halogen.VDom.DOM.Prop/index.js
  var $runtime_lazy3 = function(name16, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name16 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var Created = /* @__PURE__ */ (function() {
    function Created2(value0) {
      this.value0 = value0;
    }
    ;
    Created2.create = function(value0) {
      return new Created2(value0);
    };
    return Created2;
  })();
  var Removed = /* @__PURE__ */ (function() {
    function Removed2(value0) {
      this.value0 = value0;
    }
    ;
    Removed2.create = function(value0) {
      return new Removed2(value0);
    };
    return Removed2;
  })();
  var Attribute = /* @__PURE__ */ (function() {
    function Attribute2(value0, value1, value22) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
    }
    ;
    Attribute2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return new Attribute2(value0, value1, value22);
        };
      };
    };
    return Attribute2;
  })();
  var Property = /* @__PURE__ */ (function() {
    function Property2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Property2.create = function(value0) {
      return function(value1) {
        return new Property2(value0, value1);
      };
    };
    return Property2;
  })();
  var Handler = /* @__PURE__ */ (function() {
    function Handler2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Handler2.create = function(value0) {
      return function(value1) {
        return new Handler2(value0, value1);
      };
    };
    return Handler2;
  })();
  var Ref = /* @__PURE__ */ (function() {
    function Ref2(value0) {
      this.value0 = value0;
    }
    ;
    Ref2.create = function(value0) {
      return new Ref2(value0);
    };
    return Ref2;
  })();
  var unsafeGetProperty = unsafeGetAny;
  var setProperty = unsafeSetAny;
  var removeProperty = function(key2, el) {
    var v2 = hasAttribute(nullImpl, key2, el);
    if (v2) {
      return removeAttribute(nullImpl, key2, el);
    }
    ;
    var v1 = typeOf(unsafeGetAny(key2, el));
    if (v1 === "string") {
      return unsafeSetAny(key2, "", el);
    }
    ;
    if (key2 === "rowSpan") {
      return unsafeSetAny(key2, 1, el);
    }
    ;
    if (key2 === "colSpan") {
      return unsafeSetAny(key2, 1, el);
    }
    ;
    return unsafeSetAny(key2, jsUndefined, el);
  };
  var propToStrKey = function(v2) {
    if (v2 instanceof Attribute && v2.value0 instanceof Just) {
      return "attr/" + (v2.value0.value0 + (":" + v2.value1));
    }
    ;
    if (v2 instanceof Attribute) {
      return "attr/:" + v2.value1;
    }
    ;
    if (v2 instanceof Property) {
      return "prop/" + v2.value0;
    }
    ;
    if (v2 instanceof Handler) {
      return "handler/" + v2.value0;
    }
    ;
    if (v2 instanceof Ref) {
      return "ref";
    }
    ;
    throw new Error("Failed pattern match at Halogen.VDom.DOM.Prop (line 182, column 16 - line 187, column 16): " + [v2.constructor.name]);
  };
  var propFromString = unsafeCoerce2;
  var propFromInt = unsafeCoerce2;
  var buildProp = function(emit) {
    return function(el) {
      var removeProp = function(prevEvents) {
        return function(v2, v1) {
          if (v1 instanceof Attribute) {
            return removeAttribute(toNullable(v1.value0), v1.value1, el);
          }
          ;
          if (v1 instanceof Property) {
            return removeProperty(v1.value0, el);
          }
          ;
          if (v1 instanceof Handler) {
            var handler3 = unsafeLookup(v1.value0, prevEvents);
            return removeEventListener(v1.value0, fst(handler3), el);
          }
          ;
          if (v1 instanceof Ref) {
            return unit;
          }
          ;
          throw new Error("Failed pattern match at Halogen.VDom.DOM.Prop (line 169, column 5 - line 179, column 18): " + [v1.constructor.name]);
        };
      };
      var mbEmit = function(v2) {
        if (v2 instanceof Just) {
          return emit(v2.value0)();
        }
        ;
        return unit;
      };
      var haltProp = function(state3) {
        var v2 = lookup("ref")(state3.props);
        if (v2 instanceof Just && v2.value0 instanceof Ref) {
          return mbEmit(v2.value0.value0(new Removed(el)));
        }
        ;
        return unit;
      };
      var diffProp = function(prevEvents, events) {
        return function(v2, v1, v11, v22) {
          if (v11 instanceof Attribute && v22 instanceof Attribute) {
            var $66 = v11.value2 === v22.value2;
            if ($66) {
              return v22;
            }
            ;
            setAttribute(toNullable(v22.value0), v22.value1, v22.value2, el);
            return v22;
          }
          ;
          if (v11 instanceof Property && v22 instanceof Property) {
            var v4 = refEq2(v11.value1, v22.value1);
            if (v4) {
              return v22;
            }
            ;
            if (v22.value0 === "value") {
              var elVal = unsafeGetProperty("value", el);
              var $75 = refEq2(elVal, v22.value1);
              if ($75) {
                return v22;
              }
              ;
              setProperty(v22.value0, v22.value1, el);
              return v22;
            }
            ;
            setProperty(v22.value0, v22.value1, el);
            return v22;
          }
          ;
          if (v11 instanceof Handler && v22 instanceof Handler) {
            var handler3 = unsafeLookup(v22.value0, prevEvents);
            write(v22.value1)(snd(handler3))();
            pokeMutMap(v22.value0, handler3, events);
            return v22;
          }
          ;
          return v22;
        };
      };
      var applyProp = function(events) {
        return function(v2, v1, v22) {
          if (v22 instanceof Attribute) {
            setAttribute(toNullable(v22.value0), v22.value1, v22.value2, el);
            return v22;
          }
          ;
          if (v22 instanceof Property) {
            setProperty(v22.value0, v22.value1, el);
            return v22;
          }
          ;
          if (v22 instanceof Handler) {
            var v3 = unsafeGetAny(v22.value0, events);
            if (unsafeHasAny(v22.value0, events)) {
              write(v22.value1)(snd(v3))();
              return v22;
            }
            ;
            var ref2 = $$new(v22.value1)();
            var listener = eventListener(function(ev) {
              return function __do3() {
                var f$prime = read(ref2)();
                return mbEmit(f$prime(ev));
              };
            })();
            pokeMutMap(v22.value0, new Tuple(listener, ref2), events);
            addEventListener(v22.value0, listener, el);
            return v22;
          }
          ;
          if (v22 instanceof Ref) {
            mbEmit(v22.value0(new Created(el)));
            return v22;
          }
          ;
          throw new Error("Failed pattern match at Halogen.VDom.DOM.Prop (line 113, column 5 - line 135, column 15): " + [v22.constructor.name]);
        };
      };
      var $lazy_patchProp = $runtime_lazy3("patchProp", "Halogen.VDom.DOM.Prop", function() {
        return function(state3, ps2) {
          var events = newMutMap();
          var onThis = removeProp(state3.events);
          var onThese = diffProp(state3.events, events);
          var onThat = applyProp(events);
          var props = diffWithKeyAndIxE(state3.props, ps2, propToStrKey, onThese, onThis, onThat);
          var nextState = {
            events: unsafeFreeze2(events),
            props
          };
          return mkStep(new Step(unit, nextState, $lazy_patchProp(100), haltProp));
        };
      });
      var patchProp = $lazy_patchProp(87);
      var renderProp = function(ps1) {
        var events = newMutMap();
        var ps1$prime = strMapWithIxE(ps1, propToStrKey, applyProp(events));
        var state3 = {
          events: unsafeFreeze2(events),
          props: ps1$prime
        };
        return mkStep(new Step(unit, state3, patchProp, haltProp));
      };
      return renderProp;
    };
  };

  // output/Halogen.HTML.Core/index.js
  var HTML = function(x) {
    return x;
  };
  var widget = function($28) {
    return HTML(Widget.create($28));
  };
  var toPropValue = function(dict) {
    return dict.toPropValue;
  };
  var text = function($29) {
    return HTML(Text.create($29));
  };
  var prop = function(dictIsProp) {
    var toPropValue1 = toPropValue(dictIsProp);
    return function(v2) {
      var $31 = Property.create(v2);
      return function($32) {
        return $31(toPropValue1($32));
      };
    };
  };
  var isPropString = {
    toPropValue: propFromString
  };
  var isPropInt = {
    toPropValue: propFromInt
  };
  var isPropInputType = {
    toPropValue: function($45) {
      return propFromString(renderInputType($45));
    }
  };
  var isPropButtonType = {
    toPropValue: function($50) {
      return propFromString(renderButtonType($50));
    }
  };
  var handler = /* @__PURE__ */ (function() {
    return Handler.create;
  })();
  var element = function(ns) {
    return function(name16) {
      return function(props) {
        return function(children2) {
          return new Elem(ns, name16, props, children2);
        };
      };
    };
  };
  var attr = function(ns) {
    return function(v2) {
      return Attribute.create(ns)(v2);
    };
  };

  // output/Halogen.HTML.Properties/index.js
  var unwrap2 = /* @__PURE__ */ unwrap();
  var prop2 = function(dictIsProp) {
    return prop(dictIsProp);
  };
  var prop22 = /* @__PURE__ */ prop2(isPropString);
  var prop3 = /* @__PURE__ */ prop2(isPropInt);
  var title = /* @__PURE__ */ prop22("title");
  var type_ = function(dictIsProp) {
    return prop2(dictIsProp)("type");
  };
  var value = function(dictIsProp) {
    return prop2(dictIsProp)("value");
  };
  var placeholder = /* @__PURE__ */ prop22("placeholder");
  var id2 = /* @__PURE__ */ prop22("id");
  var colSpan = /* @__PURE__ */ prop3("colSpan");
  var class_ = /* @__PURE__ */ (function() {
    var $36 = prop22("className");
    return function($37) {
      return $36(unwrap2($37));
    };
  })();
  var attr2 = /* @__PURE__ */ (function() {
    return attr(Nothing.value);
  })();

  // output/Halogen.Svg.Attributes/index.js
  var show3 = /* @__PURE__ */ show(showNumber);
  var map9 = /* @__PURE__ */ map(functorArray);
  var width = /* @__PURE__ */ (function() {
    var $34 = attr2("width");
    return function($35) {
      return $34(show3($35));
    };
  })();
  var viewBox = function(x_) {
    return function(y_) {
      return function(w) {
        return function(h_) {
          return attr2("viewBox")(joinWith(" ")(map9(show3)([x_, y_, w, h_])));
        };
      };
    };
  };
  var height = /* @__PURE__ */ (function() {
    var $92 = attr2("height");
    return function($93) {
      return $92(show3($93));
    };
  })();

  // output/Halogen.HTML.Elements/index.js
  var pure2 = /* @__PURE__ */ pure(applicativeMaybe);
  var elementNS = function($15) {
    return element(pure2($15));
  };
  var element2 = /* @__PURE__ */ (function() {
    return element(Nothing.value);
  })();
  var form = /* @__PURE__ */ element2("form");
  var h2 = /* @__PURE__ */ element2("h2");
  var h2_ = /* @__PURE__ */ h2([]);
  var input = function(props) {
    return element2("input")(props)([]);
  };
  var p = /* @__PURE__ */ element2("p");
  var span2 = /* @__PURE__ */ element2("span");
  var style = /* @__PURE__ */ element2("style");
  var style_ = /* @__PURE__ */ style([]);
  var table = /* @__PURE__ */ element2("table");
  var tbody = /* @__PURE__ */ element2("tbody");
  var tbody_ = /* @__PURE__ */ tbody([]);
  var td = /* @__PURE__ */ element2("td");
  var th = /* @__PURE__ */ element2("th");
  var th_ = /* @__PURE__ */ th([]);
  var thead = /* @__PURE__ */ element2("thead");
  var thead_ = /* @__PURE__ */ thead([]);
  var tr = /* @__PURE__ */ element2("tr");
  var tr_ = /* @__PURE__ */ tr([]);
  var div2 = /* @__PURE__ */ element2("div");
  var div_ = /* @__PURE__ */ div2([]);
  var button = /* @__PURE__ */ element2("button");

  // output/Halogen.Svg.Elements/index.js
  var element3 = /* @__PURE__ */ elementNS("http://www.w3.org/2000/svg");
  var line = function(props) {
    return element3("line")(props)([]);
  };
  var path = function(props) {
    return element3("path")(props)([]);
  };
  var polyline = function(props) {
    return element3("polyline")(props)([]);
  };
  var svg = /* @__PURE__ */ element3("svg");

  // output/Component.Icons/index.js
  var sortNeutralIcon = /* @__PURE__ */ svg([/* @__PURE__ */ viewBox(0)(0)(24)(24), /* @__PURE__ */ width(14), /* @__PURE__ */ height(14), /* @__PURE__ */ attr2("fill")("none"), /* @__PURE__ */ attr2("stroke")("currentColor"), /* @__PURE__ */ attr2("stroke-width")("2"), /* @__PURE__ */ attr2("stroke-linecap")("round"), /* @__PURE__ */ attr2("stroke-linejoin")("round")])([/* @__PURE__ */ polyline([/* @__PURE__ */ attr2("points")("7 15 12 20 17 15")]), /* @__PURE__ */ polyline([/* @__PURE__ */ attr2("points")("7 9 12 4 17 9")])]);
  var sortDescIcon = /* @__PURE__ */ svg([/* @__PURE__ */ viewBox(0)(0)(24)(24), /* @__PURE__ */ width(14), /* @__PURE__ */ height(14), /* @__PURE__ */ attr2("fill")("none"), /* @__PURE__ */ attr2("stroke")("currentColor"), /* @__PURE__ */ attr2("stroke-width")("2"), /* @__PURE__ */ attr2("stroke-linecap")("round"), /* @__PURE__ */ attr2("stroke-linejoin")("round")])([/* @__PURE__ */ line([/* @__PURE__ */ attr2("x1")("12"), /* @__PURE__ */ attr2("y1")("5"), /* @__PURE__ */ attr2("x2")("12"), /* @__PURE__ */ attr2("y2")("19")]), /* @__PURE__ */ polyline([/* @__PURE__ */ attr2("points")("19 12 12 19 5 12")])]);
  var sortAscIcon = /* @__PURE__ */ svg([/* @__PURE__ */ viewBox(0)(0)(24)(24), /* @__PURE__ */ width(14), /* @__PURE__ */ height(14), /* @__PURE__ */ attr2("fill")("none"), /* @__PURE__ */ attr2("stroke")("currentColor"), /* @__PURE__ */ attr2("stroke-width")("2"), /* @__PURE__ */ attr2("stroke-linecap")("round"), /* @__PURE__ */ attr2("stroke-linejoin")("round")])([/* @__PURE__ */ line([/* @__PURE__ */ attr2("x1")("12"), /* @__PURE__ */ attr2("y1")("19"), /* @__PURE__ */ attr2("x2")("12"), /* @__PURE__ */ attr2("y2")("5")]), /* @__PURE__ */ polyline([/* @__PURE__ */ attr2("points")("5 12 12 5 19 12")])]);
  var deleteIcon = /* @__PURE__ */ svg([/* @__PURE__ */ viewBox(0)(0)(24)(24), /* @__PURE__ */ width(16), /* @__PURE__ */ height(16), /* @__PURE__ */ attr2("fill")("none"), /* @__PURE__ */ attr2("stroke")("currentColor"), /* @__PURE__ */ attr2("stroke-width")("2"), /* @__PURE__ */ attr2("stroke-linecap")("round"), /* @__PURE__ */ attr2("stroke-linejoin")("round")])([/* @__PURE__ */ polyline([/* @__PURE__ */ attr2("points")("3 6 5 6 21 6")]), /* @__PURE__ */ path([/* @__PURE__ */ attr2("d")("M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2")]), /* @__PURE__ */ line([/* @__PURE__ */ attr2("x1")("10"), /* @__PURE__ */ attr2("y1")("11"), /* @__PURE__ */ attr2("x2")("10"), /* @__PURE__ */ attr2("y2")("17")]), /* @__PURE__ */ line([/* @__PURE__ */ attr2("x1")("14"), /* @__PURE__ */ attr2("y1")("11"), /* @__PURE__ */ attr2("x2")("14"), /* @__PURE__ */ attr2("y2")("17")])]);
  var addIcon = /* @__PURE__ */ svg([/* @__PURE__ */ viewBox(0)(0)(24)(24), /* @__PURE__ */ width(16), /* @__PURE__ */ height(16), /* @__PURE__ */ attr2("fill")("none"), /* @__PURE__ */ attr2("stroke")("currentColor"), /* @__PURE__ */ attr2("stroke-width")("2"), /* @__PURE__ */ attr2("stroke-linecap")("round"), /* @__PURE__ */ attr2("stroke-linejoin")("round")])([/* @__PURE__ */ line([/* @__PURE__ */ attr2("x1")("12"), /* @__PURE__ */ attr2("y1")("5"), /* @__PURE__ */ attr2("x2")("12"), /* @__PURE__ */ attr2("y2")("19")]), /* @__PURE__ */ line([/* @__PURE__ */ attr2("x1")("5"), /* @__PURE__ */ attr2("y1")("12"), /* @__PURE__ */ attr2("x2")("19"), /* @__PURE__ */ attr2("y2")("12")])]);

  // output/Control.Promise/foreign.js
  function thenImpl(promise2) {
    return function(errCB) {
      return function(succCB) {
        return function() {
          promise2.then(succCB, errCB);
        };
      };
    };
  }

  // output/Control.Monad.Except/index.js
  var unwrap3 = /* @__PURE__ */ unwrap();
  var runExcept = function($3) {
    return unwrap3(runExceptT($3));
  };

  // output/Effect.Aff/foreign.js
  var Aff = (function() {
    var EMPTY = {};
    var PURE = "Pure";
    var THROW = "Throw";
    var CATCH = "Catch";
    var SYNC = "Sync";
    var ASYNC = "Async";
    var BIND = "Bind";
    var BRACKET = "Bracket";
    var FORK = "Fork";
    var SEQ = "Sequential";
    var MAP = "Map";
    var APPLY = "Apply";
    var ALT = "Alt";
    var CONS = "Cons";
    var RESUME = "Resume";
    var RELEASE = "Release";
    var FINALIZER = "Finalizer";
    var FINALIZED = "Finalized";
    var FORKED = "Forked";
    var FIBER = "Fiber";
    var THUNK = "Thunk";
    function Aff2(tag2, _1, _2, _3) {
      this.tag = tag2;
      this._1 = _1;
      this._2 = _2;
      this._3 = _3;
    }
    function AffCtr(tag2) {
      var fn = function(_1, _2, _3) {
        return new Aff2(tag2, _1, _2, _3);
      };
      fn.tag = tag2;
      return fn;
    }
    function nonCanceler2(error4) {
      return new Aff2(PURE, void 0);
    }
    function runEff(eff) {
      try {
        eff();
      } catch (error4) {
        setTimeout(function() {
          throw error4;
        }, 0);
      }
    }
    function runSync(left, right, eff) {
      try {
        return right(eff());
      } catch (error4) {
        return left(error4);
      }
    }
    function runAsync(left, eff, k) {
      try {
        return eff(k)();
      } catch (error4) {
        k(left(error4))();
        return nonCanceler2;
      }
    }
    var Scheduler = (function() {
      var limit = 1024;
      var size5 = 0;
      var ix = 0;
      var queue = new Array(limit);
      var draining = false;
      function drain() {
        var thunk;
        draining = true;
        while (size5 !== 0) {
          size5--;
          thunk = queue[ix];
          queue[ix] = void 0;
          ix = (ix + 1) % limit;
          thunk();
        }
        draining = false;
      }
      return {
        isDraining: function() {
          return draining;
        },
        enqueue: function(cb) {
          var i2, tmp;
          if (size5 === limit) {
            tmp = draining;
            drain();
            draining = tmp;
          }
          queue[(ix + size5) % limit] = cb;
          size5++;
          if (!draining) {
            drain();
          }
        }
      };
    })();
    function Supervisor(util) {
      var fibers = {};
      var fiberId = 0;
      var count = 0;
      return {
        register: function(fiber) {
          var fid = fiberId++;
          fiber.onComplete({
            rethrow: true,
            handler: function(result) {
              return function() {
                count--;
                delete fibers[fid];
              };
            }
          })();
          fibers[fid] = fiber;
          count++;
        },
        isEmpty: function() {
          return count === 0;
        },
        killAll: function(killError, cb) {
          return function() {
            if (count === 0) {
              return cb();
            }
            var killCount = 0;
            var kills = {};
            function kill2(fid) {
              kills[fid] = fibers[fid].kill(killError, function(result) {
                return function() {
                  delete kills[fid];
                  killCount--;
                  if (util.isLeft(result) && util.fromLeft(result)) {
                    setTimeout(function() {
                      throw util.fromLeft(result);
                    }, 0);
                  }
                  if (killCount === 0) {
                    cb();
                  }
                };
              })();
            }
            for (var k in fibers) {
              if (fibers.hasOwnProperty(k)) {
                killCount++;
                kill2(k);
              }
            }
            fibers = {};
            fiberId = 0;
            count = 0;
            return function(error4) {
              return new Aff2(SYNC, function() {
                for (var k2 in kills) {
                  if (kills.hasOwnProperty(k2)) {
                    kills[k2]();
                  }
                }
              });
            };
          };
        }
      };
    }
    var SUSPENDED = 0;
    var CONTINUE = 1;
    var STEP_BIND = 2;
    var STEP_RESULT = 3;
    var PENDING = 4;
    var RETURN = 5;
    var COMPLETED = 6;
    function Fiber(util, supervisor, aff) {
      var runTick = 0;
      var status = SUSPENDED;
      var step3 = aff;
      var fail3 = null;
      var interrupt = null;
      var bhead = null;
      var btail = null;
      var attempts = null;
      var bracketCount = 0;
      var joinId = 0;
      var joins = null;
      var rethrow = true;
      function run3(localRunTick) {
        var tmp, result, attempt;
        while (true) {
          tmp = null;
          result = null;
          attempt = null;
          switch (status) {
            case STEP_BIND:
              status = CONTINUE;
              try {
                step3 = bhead(step3);
                if (btail === null) {
                  bhead = null;
                } else {
                  bhead = btail._1;
                  btail = btail._2;
                }
              } catch (e) {
                status = RETURN;
                fail3 = util.left(e);
                step3 = null;
              }
              break;
            case STEP_RESULT:
              if (util.isLeft(step3)) {
                status = RETURN;
                fail3 = step3;
                step3 = null;
              } else if (bhead === null) {
                status = RETURN;
              } else {
                status = STEP_BIND;
                step3 = util.fromRight(step3);
              }
              break;
            case CONTINUE:
              switch (step3.tag) {
                case BIND:
                  if (bhead) {
                    btail = new Aff2(CONS, bhead, btail);
                  }
                  bhead = step3._2;
                  status = CONTINUE;
                  step3 = step3._1;
                  break;
                case PURE:
                  if (bhead === null) {
                    status = RETURN;
                    step3 = util.right(step3._1);
                  } else {
                    status = STEP_BIND;
                    step3 = step3._1;
                  }
                  break;
                case SYNC:
                  status = STEP_RESULT;
                  step3 = runSync(util.left, util.right, step3._1);
                  break;
                case ASYNC:
                  status = PENDING;
                  step3 = runAsync(util.left, step3._1, function(result2) {
                    return function() {
                      if (runTick !== localRunTick) {
                        return;
                      }
                      runTick++;
                      Scheduler.enqueue(function() {
                        if (runTick !== localRunTick + 1) {
                          return;
                        }
                        status = STEP_RESULT;
                        step3 = result2;
                        run3(runTick);
                      });
                    };
                  });
                  return;
                case THROW:
                  status = RETURN;
                  fail3 = util.left(step3._1);
                  step3 = null;
                  break;
                // Enqueue the Catch so that we can call the error handler later on
                // in case of an exception.
                case CATCH:
                  if (bhead === null) {
                    attempts = new Aff2(CONS, step3, attempts, interrupt);
                  } else {
                    attempts = new Aff2(CONS, step3, new Aff2(CONS, new Aff2(RESUME, bhead, btail), attempts, interrupt), interrupt);
                  }
                  bhead = null;
                  btail = null;
                  status = CONTINUE;
                  step3 = step3._1;
                  break;
                // Enqueue the Bracket so that we can call the appropriate handlers
                // after resource acquisition.
                case BRACKET:
                  bracketCount++;
                  if (bhead === null) {
                    attempts = new Aff2(CONS, step3, attempts, interrupt);
                  } else {
                    attempts = new Aff2(CONS, step3, new Aff2(CONS, new Aff2(RESUME, bhead, btail), attempts, interrupt), interrupt);
                  }
                  bhead = null;
                  btail = null;
                  status = CONTINUE;
                  step3 = step3._1;
                  break;
                case FORK:
                  status = STEP_RESULT;
                  tmp = Fiber(util, supervisor, step3._2);
                  if (supervisor) {
                    supervisor.register(tmp);
                  }
                  if (step3._1) {
                    tmp.run();
                  }
                  step3 = util.right(tmp);
                  break;
                case SEQ:
                  status = CONTINUE;
                  step3 = sequential3(util, supervisor, step3._1);
                  break;
              }
              break;
            case RETURN:
              bhead = null;
              btail = null;
              if (attempts === null) {
                status = COMPLETED;
                step3 = interrupt || fail3 || step3;
              } else {
                tmp = attempts._3;
                attempt = attempts._1;
                attempts = attempts._2;
                switch (attempt.tag) {
                  // We cannot recover from an unmasked interrupt. Otherwise we should
                  // continue stepping, or run the exception handler if an exception
                  // was raised.
                  case CATCH:
                    if (interrupt && interrupt !== tmp && bracketCount === 0) {
                      status = RETURN;
                    } else if (fail3) {
                      status = CONTINUE;
                      step3 = attempt._2(util.fromLeft(fail3));
                      fail3 = null;
                    }
                    break;
                  // We cannot resume from an unmasked interrupt or exception.
                  case RESUME:
                    if (interrupt && interrupt !== tmp && bracketCount === 0 || fail3) {
                      status = RETURN;
                    } else {
                      bhead = attempt._1;
                      btail = attempt._2;
                      status = STEP_BIND;
                      step3 = util.fromRight(step3);
                    }
                    break;
                  // If we have a bracket, we should enqueue the handlers,
                  // and continue with the success branch only if the fiber has
                  // not been interrupted. If the bracket acquisition failed, we
                  // should not run either.
                  case BRACKET:
                    bracketCount--;
                    if (fail3 === null) {
                      result = util.fromRight(step3);
                      attempts = new Aff2(CONS, new Aff2(RELEASE, attempt._2, result), attempts, tmp);
                      if (interrupt === tmp || bracketCount > 0) {
                        status = CONTINUE;
                        step3 = attempt._3(result);
                      }
                    }
                    break;
                  // Enqueue the appropriate handler. We increase the bracket count
                  // because it should not be cancelled.
                  case RELEASE:
                    attempts = new Aff2(CONS, new Aff2(FINALIZED, step3, fail3), attempts, interrupt);
                    status = CONTINUE;
                    if (interrupt && interrupt !== tmp && bracketCount === 0) {
                      step3 = attempt._1.killed(util.fromLeft(interrupt))(attempt._2);
                    } else if (fail3) {
                      step3 = attempt._1.failed(util.fromLeft(fail3))(attempt._2);
                    } else {
                      step3 = attempt._1.completed(util.fromRight(step3))(attempt._2);
                    }
                    fail3 = null;
                    bracketCount++;
                    break;
                  case FINALIZER:
                    bracketCount++;
                    attempts = new Aff2(CONS, new Aff2(FINALIZED, step3, fail3), attempts, interrupt);
                    status = CONTINUE;
                    step3 = attempt._1;
                    break;
                  case FINALIZED:
                    bracketCount--;
                    status = RETURN;
                    step3 = attempt._1;
                    fail3 = attempt._2;
                    break;
                }
              }
              break;
            case COMPLETED:
              for (var k in joins) {
                if (joins.hasOwnProperty(k)) {
                  rethrow = rethrow && joins[k].rethrow;
                  runEff(joins[k].handler(step3));
                }
              }
              joins = null;
              if (interrupt && fail3) {
                setTimeout(function() {
                  throw util.fromLeft(fail3);
                }, 0);
              } else if (util.isLeft(step3) && rethrow) {
                setTimeout(function() {
                  if (rethrow) {
                    throw util.fromLeft(step3);
                  }
                }, 0);
              }
              return;
            case SUSPENDED:
              status = CONTINUE;
              break;
            case PENDING:
              return;
          }
        }
      }
      function onComplete(join4) {
        return function() {
          if (status === COMPLETED) {
            rethrow = rethrow && join4.rethrow;
            join4.handler(step3)();
            return function() {
            };
          }
          var jid = joinId++;
          joins = joins || {};
          joins[jid] = join4;
          return function() {
            if (joins !== null) {
              delete joins[jid];
            }
          };
        };
      }
      function kill2(error4, cb) {
        return function() {
          if (status === COMPLETED) {
            cb(util.right(void 0))();
            return function() {
            };
          }
          var canceler = onComplete({
            rethrow: false,
            handler: function() {
              return cb(util.right(void 0));
            }
          })();
          switch (status) {
            case SUSPENDED:
              interrupt = util.left(error4);
              status = COMPLETED;
              step3 = interrupt;
              run3(runTick);
              break;
            case PENDING:
              if (interrupt === null) {
                interrupt = util.left(error4);
              }
              if (bracketCount === 0) {
                if (status === PENDING) {
                  attempts = new Aff2(CONS, new Aff2(FINALIZER, step3(error4)), attempts, interrupt);
                }
                status = RETURN;
                step3 = null;
                fail3 = null;
                run3(++runTick);
              }
              break;
            default:
              if (interrupt === null) {
                interrupt = util.left(error4);
              }
              if (bracketCount === 0) {
                status = RETURN;
                step3 = null;
                fail3 = null;
              }
          }
          return canceler;
        };
      }
      function join3(cb) {
        return function() {
          var canceler = onComplete({
            rethrow: false,
            handler: cb
          })();
          if (status === SUSPENDED) {
            run3(runTick);
          }
          return canceler;
        };
      }
      return {
        kill: kill2,
        join: join3,
        onComplete,
        isSuspended: function() {
          return status === SUSPENDED;
        },
        run: function() {
          if (status === SUSPENDED) {
            if (!Scheduler.isDraining()) {
              Scheduler.enqueue(function() {
                run3(runTick);
              });
            } else {
              run3(runTick);
            }
          }
        }
      };
    }
    function runPar(util, supervisor, par, cb) {
      var fiberId = 0;
      var fibers = {};
      var killId = 0;
      var kills = {};
      var early = new Error("[ParAff] Early exit");
      var interrupt = null;
      var root = EMPTY;
      function kill2(error4, par2, cb2) {
        var step3 = par2;
        var head4 = null;
        var tail2 = null;
        var count = 0;
        var kills2 = {};
        var tmp, kid;
        loop: while (true) {
          tmp = null;
          switch (step3.tag) {
            case FORKED:
              if (step3._3 === EMPTY) {
                tmp = fibers[step3._1];
                kills2[count++] = tmp.kill(error4, function(result) {
                  return function() {
                    count--;
                    if (count === 0) {
                      cb2(result)();
                    }
                  };
                });
              }
              if (head4 === null) {
                break loop;
              }
              step3 = head4._2;
              if (tail2 === null) {
                head4 = null;
              } else {
                head4 = tail2._1;
                tail2 = tail2._2;
              }
              break;
            case MAP:
              step3 = step3._2;
              break;
            case APPLY:
            case ALT:
              if (head4) {
                tail2 = new Aff2(CONS, head4, tail2);
              }
              head4 = step3;
              step3 = step3._1;
              break;
          }
        }
        if (count === 0) {
          cb2(util.right(void 0))();
        } else {
          kid = 0;
          tmp = count;
          for (; kid < tmp; kid++) {
            kills2[kid] = kills2[kid]();
          }
        }
        return kills2;
      }
      function join3(result, head4, tail2) {
        var fail3, step3, lhs, rhs, tmp, kid;
        if (util.isLeft(result)) {
          fail3 = result;
          step3 = null;
        } else {
          step3 = result;
          fail3 = null;
        }
        loop: while (true) {
          lhs = null;
          rhs = null;
          tmp = null;
          kid = null;
          if (interrupt !== null) {
            return;
          }
          if (head4 === null) {
            cb(fail3 || step3)();
            return;
          }
          if (head4._3 !== EMPTY) {
            return;
          }
          switch (head4.tag) {
            case MAP:
              if (fail3 === null) {
                head4._3 = util.right(head4._1(util.fromRight(step3)));
                step3 = head4._3;
              } else {
                head4._3 = fail3;
              }
              break;
            case APPLY:
              lhs = head4._1._3;
              rhs = head4._2._3;
              if (fail3) {
                head4._3 = fail3;
                tmp = true;
                kid = killId++;
                kills[kid] = kill2(early, fail3 === lhs ? head4._2 : head4._1, function() {
                  return function() {
                    delete kills[kid];
                    if (tmp) {
                      tmp = false;
                    } else if (tail2 === null) {
                      join3(fail3, null, null);
                    } else {
                      join3(fail3, tail2._1, tail2._2);
                    }
                  };
                });
                if (tmp) {
                  tmp = false;
                  return;
                }
              } else if (lhs === EMPTY || rhs === EMPTY) {
                return;
              } else {
                step3 = util.right(util.fromRight(lhs)(util.fromRight(rhs)));
                head4._3 = step3;
              }
              break;
            case ALT:
              lhs = head4._1._3;
              rhs = head4._2._3;
              if (lhs === EMPTY && util.isLeft(rhs) || rhs === EMPTY && util.isLeft(lhs)) {
                return;
              }
              if (lhs !== EMPTY && util.isLeft(lhs) && rhs !== EMPTY && util.isLeft(rhs)) {
                fail3 = step3 === lhs ? rhs : lhs;
                step3 = null;
                head4._3 = fail3;
              } else {
                head4._3 = step3;
                tmp = true;
                kid = killId++;
                kills[kid] = kill2(early, step3 === lhs ? head4._2 : head4._1, function() {
                  return function() {
                    delete kills[kid];
                    if (tmp) {
                      tmp = false;
                    } else if (tail2 === null) {
                      join3(step3, null, null);
                    } else {
                      join3(step3, tail2._1, tail2._2);
                    }
                  };
                });
                if (tmp) {
                  tmp = false;
                  return;
                }
              }
              break;
          }
          if (tail2 === null) {
            head4 = null;
          } else {
            head4 = tail2._1;
            tail2 = tail2._2;
          }
        }
      }
      function resolve(fiber) {
        return function(result) {
          return function() {
            delete fibers[fiber._1];
            fiber._3 = result;
            join3(result, fiber._2._1, fiber._2._2);
          };
        };
      }
      function run3() {
        var status = CONTINUE;
        var step3 = par;
        var head4 = null;
        var tail2 = null;
        var tmp, fid;
        loop: while (true) {
          tmp = null;
          fid = null;
          switch (status) {
            case CONTINUE:
              switch (step3.tag) {
                case MAP:
                  if (head4) {
                    tail2 = new Aff2(CONS, head4, tail2);
                  }
                  head4 = new Aff2(MAP, step3._1, EMPTY, EMPTY);
                  step3 = step3._2;
                  break;
                case APPLY:
                  if (head4) {
                    tail2 = new Aff2(CONS, head4, tail2);
                  }
                  head4 = new Aff2(APPLY, EMPTY, step3._2, EMPTY);
                  step3 = step3._1;
                  break;
                case ALT:
                  if (head4) {
                    tail2 = new Aff2(CONS, head4, tail2);
                  }
                  head4 = new Aff2(ALT, EMPTY, step3._2, EMPTY);
                  step3 = step3._1;
                  break;
                default:
                  fid = fiberId++;
                  status = RETURN;
                  tmp = step3;
                  step3 = new Aff2(FORKED, fid, new Aff2(CONS, head4, tail2), EMPTY);
                  tmp = Fiber(util, supervisor, tmp);
                  tmp.onComplete({
                    rethrow: false,
                    handler: resolve(step3)
                  })();
                  fibers[fid] = tmp;
                  if (supervisor) {
                    supervisor.register(tmp);
                  }
              }
              break;
            case RETURN:
              if (head4 === null) {
                break loop;
              }
              if (head4._1 === EMPTY) {
                head4._1 = step3;
                status = CONTINUE;
                step3 = head4._2;
                head4._2 = EMPTY;
              } else {
                head4._2 = step3;
                step3 = head4;
                if (tail2 === null) {
                  head4 = null;
                } else {
                  head4 = tail2._1;
                  tail2 = tail2._2;
                }
              }
          }
        }
        root = step3;
        for (fid = 0; fid < fiberId; fid++) {
          fibers[fid].run();
        }
      }
      function cancel(error4, cb2) {
        interrupt = util.left(error4);
        var innerKills;
        for (var kid in kills) {
          if (kills.hasOwnProperty(kid)) {
            innerKills = kills[kid];
            for (kid in innerKills) {
              if (innerKills.hasOwnProperty(kid)) {
                innerKills[kid]();
              }
            }
          }
        }
        kills = null;
        var newKills = kill2(error4, root, cb2);
        return function(killError) {
          return new Aff2(ASYNC, function(killCb) {
            return function() {
              for (var kid2 in newKills) {
                if (newKills.hasOwnProperty(kid2)) {
                  newKills[kid2]();
                }
              }
              return nonCanceler2;
            };
          });
        };
      }
      run3();
      return function(killError) {
        return new Aff2(ASYNC, function(killCb) {
          return function() {
            return cancel(killError, killCb);
          };
        });
      };
    }
    function sequential3(util, supervisor, par) {
      return new Aff2(ASYNC, function(cb) {
        return function() {
          return runPar(util, supervisor, par, cb);
        };
      });
    }
    Aff2.EMPTY = EMPTY;
    Aff2.Pure = AffCtr(PURE);
    Aff2.Throw = AffCtr(THROW);
    Aff2.Catch = AffCtr(CATCH);
    Aff2.Sync = AffCtr(SYNC);
    Aff2.Async = AffCtr(ASYNC);
    Aff2.Bind = AffCtr(BIND);
    Aff2.Bracket = AffCtr(BRACKET);
    Aff2.Fork = AffCtr(FORK);
    Aff2.Seq = AffCtr(SEQ);
    Aff2.ParMap = AffCtr(MAP);
    Aff2.ParApply = AffCtr(APPLY);
    Aff2.ParAlt = AffCtr(ALT);
    Aff2.Fiber = Fiber;
    Aff2.Supervisor = Supervisor;
    Aff2.Scheduler = Scheduler;
    Aff2.nonCanceler = nonCanceler2;
    return Aff2;
  })();
  var _pure = Aff.Pure;
  var _throwError = Aff.Throw;
  function _catchError(aff) {
    return function(k) {
      return Aff.Catch(aff, k);
    };
  }
  function _map(f) {
    return function(aff) {
      if (aff.tag === Aff.Pure.tag) {
        return Aff.Pure(f(aff._1));
      } else {
        return Aff.Bind(aff, function(value16) {
          return Aff.Pure(f(value16));
        });
      }
    };
  }
  function _bind(aff) {
    return function(k) {
      return Aff.Bind(aff, k);
    };
  }
  function _fork(immediate) {
    return function(aff) {
      return Aff.Fork(immediate, aff);
    };
  }
  var _liftEffect = Aff.Sync;
  function _parAffMap(f) {
    return function(aff) {
      return Aff.ParMap(f, aff);
    };
  }
  function _parAffApply(aff1) {
    return function(aff2) {
      return Aff.ParApply(aff1, aff2);
    };
  }
  var makeAff = Aff.Async;
  function generalBracket(acquire) {
    return function(options2) {
      return function(k) {
        return Aff.Bracket(acquire, options2, k);
      };
    };
  }
  function _makeFiber(util, aff) {
    return function() {
      return Aff.Fiber(util, null, aff);
    };
  }
  var _delay = /* @__PURE__ */ (function() {
    function setDelay(n, k) {
      if (n === 0 && typeof setImmediate !== "undefined") {
        return setImmediate(k);
      } else {
        return setTimeout(k, n);
      }
    }
    function clearDelay(n, t2) {
      if (n === 0 && typeof clearImmediate !== "undefined") {
        return clearImmediate(t2);
      } else {
        return clearTimeout(t2);
      }
    }
    return function(right, ms) {
      return Aff.Async(function(cb) {
        return function() {
          var timer = setDelay(ms, cb(right()));
          return function() {
            return Aff.Sync(function() {
              return right(clearDelay(ms, timer));
            });
          };
        };
      });
    };
  })();
  var _sequential = Aff.Seq;

  // output/Control.Parallel.Class/index.js
  var sequential = function(dict) {
    return dict.sequential;
  };
  var parallel = function(dict) {
    return dict.parallel;
  };

  // output/Control.Parallel/index.js
  var identity7 = /* @__PURE__ */ identity(categoryFn);
  var parTraverse_ = function(dictParallel) {
    var sequential3 = sequential(dictParallel);
    var parallel4 = parallel(dictParallel);
    return function(dictApplicative) {
      var traverse_7 = traverse_(dictApplicative);
      return function(dictFoldable) {
        var traverse_14 = traverse_7(dictFoldable);
        return function(f) {
          var $51 = traverse_14(function($53) {
            return parallel4(f($53));
          });
          return function($52) {
            return sequential3($51($52));
          };
        };
      };
    };
  };
  var parSequence_ = function(dictParallel) {
    var parTraverse_1 = parTraverse_(dictParallel);
    return function(dictApplicative) {
      var parTraverse_2 = parTraverse_1(dictApplicative);
      return function(dictFoldable) {
        return parTraverse_2(dictFoldable)(identity7);
      };
    };
  };

  // output/Effect.Unsafe/foreign.js
  var unsafePerformEffect = function(f) {
    return f();
  };

  // output/Effect.Aff/index.js
  var $runtime_lazy4 = function(name16, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name16 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var pure3 = /* @__PURE__ */ pure(applicativeEffect);
  var $$void3 = /* @__PURE__ */ $$void(functorEffect);
  var map10 = /* @__PURE__ */ map(functorEffect);
  var Canceler = function(x) {
    return x;
  };
  var suspendAff = /* @__PURE__ */ _fork(false);
  var functorParAff = {
    map: _parAffMap
  };
  var functorAff = {
    map: _map
  };
  var map12 = /* @__PURE__ */ map(functorAff);
  var forkAff = /* @__PURE__ */ _fork(true);
  var ffiUtil = /* @__PURE__ */ (function() {
    var unsafeFromRight = function(v2) {
      if (v2 instanceof Right) {
        return v2.value0;
      }
      ;
      if (v2 instanceof Left) {
        return unsafeCrashWith("unsafeFromRight: Left");
      }
      ;
      throw new Error("Failed pattern match at Effect.Aff (line 412, column 21 - line 414, column 54): " + [v2.constructor.name]);
    };
    var unsafeFromLeft = function(v2) {
      if (v2 instanceof Left) {
        return v2.value0;
      }
      ;
      if (v2 instanceof Right) {
        return unsafeCrashWith("unsafeFromLeft: Right");
      }
      ;
      throw new Error("Failed pattern match at Effect.Aff (line 407, column 20 - line 409, column 55): " + [v2.constructor.name]);
    };
    var isLeft = function(v2) {
      if (v2 instanceof Left) {
        return true;
      }
      ;
      if (v2 instanceof Right) {
        return false;
      }
      ;
      throw new Error("Failed pattern match at Effect.Aff (line 402, column 12 - line 404, column 21): " + [v2.constructor.name]);
    };
    return {
      isLeft,
      fromLeft: unsafeFromLeft,
      fromRight: unsafeFromRight,
      left: Left.create,
      right: Right.create
    };
  })();
  var makeFiber = function(aff) {
    return _makeFiber(ffiUtil, aff);
  };
  var launchAff = function(aff) {
    return function __do3() {
      var fiber = makeFiber(aff)();
      fiber.run();
      return fiber;
    };
  };
  var delay = function(v2) {
    return _delay(Right.create, v2);
  };
  var bracket = function(acquire) {
    return function(completed) {
      return generalBracket(acquire)({
        killed: $$const(completed),
        failed: $$const(completed),
        completed: $$const(completed)
      });
    };
  };
  var applyParAff = {
    apply: _parAffApply,
    Functor0: function() {
      return functorParAff;
    }
  };
  var monadAff = {
    Applicative0: function() {
      return applicativeAff;
    },
    Bind1: function() {
      return bindAff;
    }
  };
  var bindAff = {
    bind: _bind,
    Apply0: function() {
      return $lazy_applyAff(0);
    }
  };
  var applicativeAff = {
    pure: _pure,
    Apply0: function() {
      return $lazy_applyAff(0);
    }
  };
  var $lazy_applyAff = /* @__PURE__ */ $runtime_lazy4("applyAff", "Effect.Aff", function() {
    return {
      apply: ap(monadAff),
      Functor0: function() {
        return functorAff;
      }
    };
  });
  var applyAff = /* @__PURE__ */ $lazy_applyAff(73);
  var pure22 = /* @__PURE__ */ pure(applicativeAff);
  var bind1 = /* @__PURE__ */ bind(bindAff);
  var bindFlipped3 = /* @__PURE__ */ bindFlipped(bindAff);
  var $$finally = function(fin) {
    return function(a3) {
      return bracket(pure22(unit))($$const(fin))($$const(a3));
    };
  };
  var parallelAff = {
    parallel: unsafeCoerce2,
    sequential: _sequential,
    Apply0: function() {
      return applyAff;
    },
    Apply1: function() {
      return applyParAff;
    }
  };
  var parallel2 = /* @__PURE__ */ parallel(parallelAff);
  var applicativeParAff = {
    pure: function($76) {
      return parallel2(pure22($76));
    },
    Apply0: function() {
      return applyParAff;
    }
  };
  var parSequence_2 = /* @__PURE__ */ parSequence_(parallelAff)(applicativeParAff)(foldableArray);
  var semigroupCanceler = {
    append: function(v2) {
      return function(v1) {
        return function(err) {
          return parSequence_2([v2(err), v1(err)]);
        };
      };
    }
  };
  var monadEffectAff = {
    liftEffect: _liftEffect,
    Monad0: function() {
      return monadAff;
    }
  };
  var liftEffect2 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var effectCanceler = function($77) {
    return Canceler($$const(liftEffect2($77)));
  };
  var joinFiber = function(v2) {
    return makeAff(function(k) {
      return map10(effectCanceler)(v2.join(k));
    });
  };
  var functorFiber = {
    map: function(f) {
      return function(t2) {
        return unsafePerformEffect(makeFiber(map12(f)(joinFiber(t2))));
      };
    }
  };
  var killFiber = function(e) {
    return function(v2) {
      return bind1(liftEffect2(v2.isSuspended))(function(suspended) {
        if (suspended) {
          return liftEffect2($$void3(v2.kill(e, $$const(pure3(unit)))));
        }
        ;
        return makeAff(function(k) {
          return map10(effectCanceler)(v2.kill(e, k));
        });
      });
    };
  };
  var monadThrowAff = {
    throwError: _throwError,
    Monad0: function() {
      return monadAff;
    }
  };
  var monadErrorAff = {
    catchError: _catchError,
    MonadThrow0: function() {
      return monadThrowAff;
    }
  };
  var $$try2 = /* @__PURE__ */ $$try(monadErrorAff);
  var runAff = function(k) {
    return function(aff) {
      return launchAff(bindFlipped3(function($83) {
        return liftEffect2(k($83));
      })($$try2(aff)));
    };
  };
  var runAff_ = function(k) {
    return function(aff) {
      return $$void3(runAff(k)(aff));
    };
  };
  var monadRecAff = {
    tailRecM: function(k) {
      var go2 = function(a3) {
        return bind1(k(a3))(function(res) {
          if (res instanceof Done) {
            return pure22(res.value0);
          }
          ;
          if (res instanceof Loop) {
            return go2(res.value0);
          }
          ;
          throw new Error("Failed pattern match at Effect.Aff (line 104, column 7 - line 106, column 23): " + [res.constructor.name]);
        });
      };
      return go2;
    },
    Monad0: function() {
      return monadAff;
    }
  };
  var nonCanceler = /* @__PURE__ */ $$const(/* @__PURE__ */ pure22(unit));
  var monoidCanceler = {
    mempty: nonCanceler,
    Semigroup0: function() {
      return semigroupCanceler;
    }
  };

  // output/Control.Promise/index.js
  var voidRight2 = /* @__PURE__ */ voidRight(functorEffect);
  var mempty2 = /* @__PURE__ */ mempty(monoidCanceler);
  var identity8 = /* @__PURE__ */ identity(categoryFn);
  var alt2 = /* @__PURE__ */ alt(/* @__PURE__ */ altExceptT(semigroupNonEmptyList)(monadIdentity));
  var unsafeReadTagged2 = /* @__PURE__ */ unsafeReadTagged(monadIdentity);
  var map11 = /* @__PURE__ */ map(/* @__PURE__ */ functorExceptT(functorIdentity));
  var readString2 = /* @__PURE__ */ readString(monadIdentity);
  var toAff$prime = function(customCoerce) {
    return function(p2) {
      return makeAff(function(cb) {
        return voidRight2(mempty2)(thenImpl(p2)(function($14) {
          return cb(Left.create(customCoerce($14)))();
        })(function($15) {
          return cb(Right.create($15))();
        }));
      });
    };
  };
  var coerce3 = function(fn) {
    return either(function(v2) {
      return error("Promise failed, couldn't extract JS Error or String");
    })(identity8)(runExcept(alt2(unsafeReadTagged2("Error")(fn))(map11(error)(readString2(fn)))));
  };
  var toAff = /* @__PURE__ */ toAff$prime(coerce3);

  // output/Data.String.CodePoints/foreign.js
  var hasArrayFrom = typeof Array.from === "function";
  var hasStringIterator = typeof Symbol !== "undefined" && Symbol != null && typeof Symbol.iterator !== "undefined" && typeof String.prototype[Symbol.iterator] === "function";
  var hasFromCodePoint = typeof String.prototype.fromCodePoint === "function";
  var hasCodePointAt = typeof String.prototype.codePointAt === "function";
  var _unsafeCodePointAt0 = function(fallback) {
    return hasCodePointAt ? function(str) {
      return str.codePointAt(0);
    } : fallback;
  };
  var _toCodePointArray = function(fallback) {
    return function(unsafeCodePointAt02) {
      if (hasArrayFrom) {
        return function(str) {
          return Array.from(str, unsafeCodePointAt02);
        };
      }
      return fallback;
    };
  };

  // output/Data.Enum/foreign.js
  function toCharCode(c2) {
    return c2.charCodeAt(0);
  }
  function fromCharCode(c2) {
    return String.fromCharCode(c2);
  }

  // output/Data.Enum/index.js
  var bottom1 = /* @__PURE__ */ bottom(boundedChar);
  var top1 = /* @__PURE__ */ top(boundedChar);
  var fromEnum = function(dict) {
    return dict.fromEnum;
  };
  var defaultSucc = function(toEnum$prime) {
    return function(fromEnum$prime) {
      return function(a3) {
        return toEnum$prime(fromEnum$prime(a3) + 1 | 0);
      };
    };
  };
  var defaultPred = function(toEnum$prime) {
    return function(fromEnum$prime) {
      return function(a3) {
        return toEnum$prime(fromEnum$prime(a3) - 1 | 0);
      };
    };
  };
  var charToEnum = function(v2) {
    if (v2 >= toCharCode(bottom1) && v2 <= toCharCode(top1)) {
      return new Just(fromCharCode(v2));
    }
    ;
    return Nothing.value;
  };
  var enumChar = {
    succ: /* @__PURE__ */ defaultSucc(charToEnum)(toCharCode),
    pred: /* @__PURE__ */ defaultPred(charToEnum)(toCharCode),
    Ord0: function() {
      return ordChar;
    }
  };
  var boundedEnumChar = /* @__PURE__ */ (function() {
    return {
      cardinality: toCharCode(top1) - toCharCode(bottom1) | 0,
      toEnum: charToEnum,
      fromEnum: toCharCode,
      Bounded0: function() {
        return boundedChar;
      },
      Enum1: function() {
        return enumChar;
      }
    };
  })();

  // output/Data.String.CodePoints/index.js
  var fromEnum2 = /* @__PURE__ */ fromEnum(boundedEnumChar);
  var map13 = /* @__PURE__ */ map(functorMaybe);
  var unfoldr2 = /* @__PURE__ */ unfoldr(unfoldableArray);
  var unsurrogate = function(lead) {
    return function(trail) {
      return (((lead - 55296 | 0) * 1024 | 0) + (trail - 56320 | 0) | 0) + 65536 | 0;
    };
  };
  var isTrail = function(cu) {
    return 56320 <= cu && cu <= 57343;
  };
  var isLead = function(cu) {
    return 55296 <= cu && cu <= 56319;
  };
  var uncons2 = function(s2) {
    var v2 = length3(s2);
    if (v2 === 0) {
      return Nothing.value;
    }
    ;
    if (v2 === 1) {
      return new Just({
        head: fromEnum2(charAt(0)(s2)),
        tail: ""
      });
    }
    ;
    var cu1 = fromEnum2(charAt(1)(s2));
    var cu0 = fromEnum2(charAt(0)(s2));
    var $43 = isLead(cu0) && isTrail(cu1);
    if ($43) {
      return new Just({
        head: unsurrogate(cu0)(cu1),
        tail: drop2(2)(s2)
      });
    }
    ;
    return new Just({
      head: cu0,
      tail: drop2(1)(s2)
    });
  };
  var unconsButWithTuple = function(s2) {
    return map13(function(v2) {
      return new Tuple(v2.head, v2.tail);
    })(uncons2(s2));
  };
  var toCodePointArrayFallback = function(s2) {
    return unfoldr2(unconsButWithTuple)(s2);
  };
  var unsafeCodePointAt0Fallback = function(s2) {
    var cu0 = fromEnum2(charAt(0)(s2));
    var $47 = isLead(cu0) && length3(s2) > 1;
    if ($47) {
      var cu1 = fromEnum2(charAt(1)(s2));
      var $48 = isTrail(cu1);
      if ($48) {
        return unsurrogate(cu0)(cu1);
      }
      ;
      return cu0;
    }
    ;
    return cu0;
  };
  var unsafeCodePointAt0 = /* @__PURE__ */ _unsafeCodePointAt0(unsafeCodePointAt0Fallback);
  var toCodePointArray = /* @__PURE__ */ _toCodePointArray(toCodePointArrayFallback)(unsafeCodePointAt0);
  var length4 = function($74) {
    return length(toCodePointArray($74));
  };

  // node_modules/decimal.js/decimal.mjs
  var EXP_LIMIT = 9e15;
  var MAX_DIGITS = 1e9;
  var NUMERALS = "0123456789abcdef";
  var LN10 = "2.3025850929940456840179914546843642076011014886287729760333279009675726096773524802359972050895982983419677840422862486334095254650828067566662873690987816894829072083255546808437998948262331985283935053089653777326288461633662222876982198867465436674744042432743651550489343149393914796194044002221051017141748003688084012647080685567743216228355220114804663715659121373450747856947683463616792101806445070648000277502684916746550586856935673420670581136429224554405758925724208241314695689016758940256776311356919292033376587141660230105703089634572075440370847469940168269282808481184289314848524948644871927809676271275775397027668605952496716674183485704422507197965004714951050492214776567636938662976979522110718264549734772662425709429322582798502585509785265383207606726317164309505995087807523710333101197857547331541421808427543863591778117054309827482385045648019095610299291824318237525357709750539565187697510374970888692180205189339507238539205144634197265287286965110862571492198849978748873771345686209167058";
  var PI = "3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989380952572010654858632789";
  var DEFAULTS = {
    // These values must be integers within the stated ranges (inclusive).
    // Most of these values can be changed at run-time using the `Decimal.config` method.
    // The maximum number of significant digits of the result of a calculation or base conversion.
    // E.g. `Decimal.config({ precision: 20 });`
    precision: 20,
    // 1 to MAX_DIGITS
    // The rounding mode used when rounding to `precision`.
    //
    // ROUND_UP         0 Away from zero.
    // ROUND_DOWN       1 Towards zero.
    // ROUND_CEIL       2 Towards +Infinity.
    // ROUND_FLOOR      3 Towards -Infinity.
    // ROUND_HALF_UP    4 Towards nearest neighbour. If equidistant, up.
    // ROUND_HALF_DOWN  5 Towards nearest neighbour. If equidistant, down.
    // ROUND_HALF_EVEN  6 Towards nearest neighbour. If equidistant, towards even neighbour.
    // ROUND_HALF_CEIL  7 Towards nearest neighbour. If equidistant, towards +Infinity.
    // ROUND_HALF_FLOOR 8 Towards nearest neighbour. If equidistant, towards -Infinity.
    //
    // E.g.
    // `Decimal.rounding = 4;`
    // `Decimal.rounding = Decimal.ROUND_HALF_UP;`
    rounding: 4,
    // 0 to 8
    // The modulo mode used when calculating the modulus: a mod n.
    // The quotient (q = a / n) is calculated according to the corresponding rounding mode.
    // The remainder (r) is calculated as: r = a - n * q.
    //
    // UP         0 The remainder is positive if the dividend is negative, else is negative.
    // DOWN       1 The remainder has the same sign as the dividend (JavaScript %).
    // FLOOR      3 The remainder has the same sign as the divisor (Python %).
    // HALF_EVEN  6 The IEEE 754 remainder function.
    // EUCLID     9 Euclidian division. q = sign(n) * floor(a / abs(n)). Always positive.
    //
    // Truncated division (1), floored division (3), the IEEE 754 remainder (6), and Euclidian
    // division (9) are commonly used for the modulus operation. The other rounding modes can also
    // be used, but they may not give useful results.
    modulo: 1,
    // 0 to 9
    // The exponent value at and beneath which `toString` returns exponential notation.
    // JavaScript numbers: -7
    toExpNeg: -7,
    // 0 to -EXP_LIMIT
    // The exponent value at and above which `toString` returns exponential notation.
    // JavaScript numbers: 21
    toExpPos: 21,
    // 0 to EXP_LIMIT
    // The minimum exponent value, beneath which underflow to zero occurs.
    // JavaScript numbers: -324  (5e-324)
    minE: -EXP_LIMIT,
    // -1 to -EXP_LIMIT
    // The maximum exponent value, above which overflow to Infinity occurs.
    // JavaScript numbers: 308  (1.7976931348623157e+308)
    maxE: EXP_LIMIT,
    // 1 to EXP_LIMIT
    // Whether to use cryptographically-secure random number generation, if available.
    crypto: false
    // true/false
  };
  var inexact;
  var quadrant;
  var external = true;
  var decimalError = "[DecimalError] ";
  var invalidArgument = decimalError + "Invalid argument: ";
  var precisionLimitExceeded = decimalError + "Precision limit exceeded";
  var cryptoUnavailable = decimalError + "crypto unavailable";
  var tag = "[object Decimal]";
  var mathfloor = Math.floor;
  var mathpow = Math.pow;
  var isBinary = /^0b([01]+(\.[01]*)?|\.[01]+)(p[+-]?\d+)?$/i;
  var isHex = /^0x([0-9a-f]+(\.[0-9a-f]*)?|\.[0-9a-f]+)(p[+-]?\d+)?$/i;
  var isOctal = /^0o([0-7]+(\.[0-7]*)?|\.[0-7]+)(p[+-]?\d+)?$/i;
  var isDecimal = /^(\d+(\.\d*)?|\.\d+)(e[+-]?\d+)?$/i;
  var BASE = 1e7;
  var LOG_BASE = 7;
  var MAX_SAFE_INTEGER = 9007199254740991;
  var LN10_PRECISION = LN10.length - 1;
  var PI_PRECISION = PI.length - 1;
  var P = { toStringTag: tag };
  P.absoluteValue = P.abs = function() {
    var x = new this.constructor(this);
    if (x.s < 0) x.s = 1;
    return finalise(x);
  };
  P.ceil = function() {
    return finalise(new this.constructor(this), this.e + 1, 2);
  };
  P.clampedTo = P.clamp = function(min7, max8) {
    var k, x = this, Ctor = x.constructor;
    min7 = new Ctor(min7);
    max8 = new Ctor(max8);
    if (!min7.s || !max8.s) return new Ctor(NaN);
    if (min7.gt(max8)) throw Error(invalidArgument + max8);
    k = x.cmp(min7);
    return k < 0 ? min7 : x.cmp(max8) > 0 ? max8 : new Ctor(x);
  };
  P.comparedTo = P.cmp = function(y) {
    var i2, j, xdL, ydL, x = this, xd = x.d, yd = (y = new x.constructor(y)).d, xs = x.s, ys = y.s;
    if (!xd || !yd) {
      return !xs || !ys ? NaN : xs !== ys ? xs : xd === yd ? 0 : !xd ^ xs < 0 ? 1 : -1;
    }
    if (!xd[0] || !yd[0]) return xd[0] ? xs : yd[0] ? -ys : 0;
    if (xs !== ys) return xs;
    if (x.e !== y.e) return x.e > y.e ^ xs < 0 ? 1 : -1;
    xdL = xd.length;
    ydL = yd.length;
    for (i2 = 0, j = xdL < ydL ? xdL : ydL; i2 < j; ++i2) {
      if (xd[i2] !== yd[i2]) return xd[i2] > yd[i2] ^ xs < 0 ? 1 : -1;
    }
    return xdL === ydL ? 0 : xdL > ydL ^ xs < 0 ? 1 : -1;
  };
  P.cosine = P.cos = function() {
    var pr, rm, x = this, Ctor = x.constructor;
    if (!x.d) return new Ctor(NaN);
    if (!x.d[0]) return new Ctor(1);
    pr = Ctor.precision;
    rm = Ctor.rounding;
    Ctor.precision = pr + Math.max(x.e, x.sd()) + LOG_BASE;
    Ctor.rounding = 1;
    x = cosine(Ctor, toLessThanHalfPi(Ctor, x));
    Ctor.precision = pr;
    Ctor.rounding = rm;
    return finalise(quadrant == 2 || quadrant == 3 ? x.neg() : x, pr, rm, true);
  };
  P.cubeRoot = P.cbrt = function() {
    var e, m2, n, r, rep, s2, sd, t2, t3, t3plusx, x = this, Ctor = x.constructor;
    if (!x.isFinite() || x.isZero()) return new Ctor(x);
    external = false;
    s2 = x.s * mathpow(x.s * x, 1 / 3);
    if (!s2 || Math.abs(s2) == 1 / 0) {
      n = digitsToString(x.d);
      e = x.e;
      if (s2 = (e - n.length + 1) % 3) n += s2 == 1 || s2 == -2 ? "0" : "00";
      s2 = mathpow(n, 1 / 3);
      e = mathfloor((e + 1) / 3) - (e % 3 == (e < 0 ? -1 : 2));
      if (s2 == 1 / 0) {
        n = "5e" + e;
      } else {
        n = s2.toExponential();
        n = n.slice(0, n.indexOf("e") + 1) + e;
      }
      r = new Ctor(n);
      r.s = x.s;
    } else {
      r = new Ctor(s2.toString());
    }
    sd = (e = Ctor.precision) + 3;
    for (; ; ) {
      t2 = r;
      t3 = t2.times(t2).times(t2);
      t3plusx = t3.plus(x);
      r = divide(t3plusx.plus(x).times(t2), t3plusx.plus(t3), sd + 2, 1);
      if (digitsToString(t2.d).slice(0, sd) === (n = digitsToString(r.d)).slice(0, sd)) {
        n = n.slice(sd - 3, sd + 1);
        if (n == "9999" || !rep && n == "4999") {
          if (!rep) {
            finalise(t2, e + 1, 0);
            if (t2.times(t2).times(t2).eq(x)) {
              r = t2;
              break;
            }
          }
          sd += 4;
          rep = 1;
        } else {
          if (!+n || !+n.slice(1) && n.charAt(0) == "5") {
            finalise(r, e + 1, 1);
            m2 = !r.times(r).times(r).eq(x);
          }
          break;
        }
      }
    }
    external = true;
    return finalise(r, e, Ctor.rounding, m2);
  };
  P.decimalPlaces = P.dp = function() {
    var w, d = this.d, n = NaN;
    if (d) {
      w = d.length - 1;
      n = (w - mathfloor(this.e / LOG_BASE)) * LOG_BASE;
      w = d[w];
      if (w) for (; w % 10 == 0; w /= 10) n--;
      if (n < 0) n = 0;
    }
    return n;
  };
  P.dividedBy = P.div = function(y) {
    return divide(this, new this.constructor(y));
  };
  P.dividedToIntegerBy = P.divToInt = function(y) {
    var x = this, Ctor = x.constructor;
    return finalise(divide(x, new Ctor(y), 0, 1, 1), Ctor.precision, Ctor.rounding);
  };
  P.equals = P.eq = function(y) {
    return this.cmp(y) === 0;
  };
  P.floor = function() {
    return finalise(new this.constructor(this), this.e + 1, 3);
  };
  P.greaterThan = P.gt = function(y) {
    return this.cmp(y) > 0;
  };
  P.greaterThanOrEqualTo = P.gte = function(y) {
    var k = this.cmp(y);
    return k == 1 || k === 0;
  };
  P.hyperbolicCosine = P.cosh = function() {
    var k, n, pr, rm, len, x = this, Ctor = x.constructor, one2 = new Ctor(1);
    if (!x.isFinite()) return new Ctor(x.s ? 1 / 0 : NaN);
    if (x.isZero()) return one2;
    pr = Ctor.precision;
    rm = Ctor.rounding;
    Ctor.precision = pr + Math.max(x.e, x.sd()) + 4;
    Ctor.rounding = 1;
    len = x.d.length;
    if (len < 32) {
      k = Math.ceil(len / 3);
      n = (1 / tinyPow(4, k)).toString();
    } else {
      k = 16;
      n = "2.3283064365386962890625e-10";
    }
    x = taylorSeries(Ctor, 1, x.times(n), new Ctor(1), true);
    var cosh2_x, i2 = k, d8 = new Ctor(8);
    for (; i2--; ) {
      cosh2_x = x.times(x);
      x = one2.minus(cosh2_x.times(d8.minus(cosh2_x.times(d8))));
    }
    return finalise(x, Ctor.precision = pr, Ctor.rounding = rm, true);
  };
  P.hyperbolicSine = P.sinh = function() {
    var k, pr, rm, len, x = this, Ctor = x.constructor;
    if (!x.isFinite() || x.isZero()) return new Ctor(x);
    pr = Ctor.precision;
    rm = Ctor.rounding;
    Ctor.precision = pr + Math.max(x.e, x.sd()) + 4;
    Ctor.rounding = 1;
    len = x.d.length;
    if (len < 3) {
      x = taylorSeries(Ctor, 2, x, x, true);
    } else {
      k = 1.4 * Math.sqrt(len);
      k = k > 16 ? 16 : k | 0;
      x = x.times(1 / tinyPow(5, k));
      x = taylorSeries(Ctor, 2, x, x, true);
      var sinh2_x, d5 = new Ctor(5), d16 = new Ctor(16), d20 = new Ctor(20);
      for (; k--; ) {
        sinh2_x = x.times(x);
        x = x.times(d5.plus(sinh2_x.times(d16.times(sinh2_x).plus(d20))));
      }
    }
    Ctor.precision = pr;
    Ctor.rounding = rm;
    return finalise(x, pr, rm, true);
  };
  P.hyperbolicTangent = P.tanh = function() {
    var pr, rm, x = this, Ctor = x.constructor;
    if (!x.isFinite()) return new Ctor(x.s);
    if (x.isZero()) return new Ctor(x);
    pr = Ctor.precision;
    rm = Ctor.rounding;
    Ctor.precision = pr + 7;
    Ctor.rounding = 1;
    return divide(x.sinh(), x.cosh(), Ctor.precision = pr, Ctor.rounding = rm);
  };
  P.inverseCosine = P.acos = function() {
    var x = this, Ctor = x.constructor, k = x.abs().cmp(1), pr = Ctor.precision, rm = Ctor.rounding;
    if (k !== -1) {
      return k === 0 ? x.isNeg() ? getPi(Ctor, pr, rm) : new Ctor(0) : new Ctor(NaN);
    }
    if (x.isZero()) return getPi(Ctor, pr + 4, rm).times(0.5);
    Ctor.precision = pr + 6;
    Ctor.rounding = 1;
    x = new Ctor(1).minus(x).div(x.plus(1)).sqrt().atan();
    Ctor.precision = pr;
    Ctor.rounding = rm;
    return x.times(2);
  };
  P.inverseHyperbolicCosine = P.acosh = function() {
    var pr, rm, x = this, Ctor = x.constructor;
    if (x.lte(1)) return new Ctor(x.eq(1) ? 0 : NaN);
    if (!x.isFinite()) return new Ctor(x);
    pr = Ctor.precision;
    rm = Ctor.rounding;
    Ctor.precision = pr + Math.max(Math.abs(x.e), x.sd()) + 4;
    Ctor.rounding = 1;
    external = false;
    x = x.times(x).minus(1).sqrt().plus(x);
    external = true;
    Ctor.precision = pr;
    Ctor.rounding = rm;
    return x.ln();
  };
  P.inverseHyperbolicSine = P.asinh = function() {
    var pr, rm, x = this, Ctor = x.constructor;
    if (!x.isFinite() || x.isZero()) return new Ctor(x);
    pr = Ctor.precision;
    rm = Ctor.rounding;
    Ctor.precision = pr + 2 * Math.max(Math.abs(x.e), x.sd()) + 6;
    Ctor.rounding = 1;
    external = false;
    x = x.times(x).plus(1).sqrt().plus(x);
    external = true;
    Ctor.precision = pr;
    Ctor.rounding = rm;
    return x.ln();
  };
  P.inverseHyperbolicTangent = P.atanh = function() {
    var pr, rm, wpr, xsd, x = this, Ctor = x.constructor;
    if (!x.isFinite()) return new Ctor(NaN);
    if (x.e >= 0) return new Ctor(x.abs().eq(1) ? x.s / 0 : x.isZero() ? x : NaN);
    pr = Ctor.precision;
    rm = Ctor.rounding;
    xsd = x.sd();
    if (Math.max(xsd, pr) < 2 * -x.e - 1) return finalise(new Ctor(x), pr, rm, true);
    Ctor.precision = wpr = xsd - x.e;
    x = divide(x.plus(1), new Ctor(1).minus(x), wpr + pr, 1);
    Ctor.precision = pr + 4;
    Ctor.rounding = 1;
    x = x.ln();
    Ctor.precision = pr;
    Ctor.rounding = rm;
    return x.times(0.5);
  };
  P.inverseSine = P.asin = function() {
    var halfPi, k, pr, rm, x = this, Ctor = x.constructor;
    if (x.isZero()) return new Ctor(x);
    k = x.abs().cmp(1);
    pr = Ctor.precision;
    rm = Ctor.rounding;
    if (k !== -1) {
      if (k === 0) {
        halfPi = getPi(Ctor, pr + 4, rm).times(0.5);
        halfPi.s = x.s;
        return halfPi;
      }
      return new Ctor(NaN);
    }
    Ctor.precision = pr + 6;
    Ctor.rounding = 1;
    x = x.div(new Ctor(1).minus(x.times(x)).sqrt().plus(1)).atan();
    Ctor.precision = pr;
    Ctor.rounding = rm;
    return x.times(2);
  };
  P.inverseTangent = P.atan = function() {
    var i2, j, k, n, px, t2, r, wpr, x2, x = this, Ctor = x.constructor, pr = Ctor.precision, rm = Ctor.rounding;
    if (!x.isFinite()) {
      if (!x.s) return new Ctor(NaN);
      if (pr + 4 <= PI_PRECISION) {
        r = getPi(Ctor, pr + 4, rm).times(0.5);
        r.s = x.s;
        return r;
      }
    } else if (x.isZero()) {
      return new Ctor(x);
    } else if (x.abs().eq(1) && pr + 4 <= PI_PRECISION) {
      r = getPi(Ctor, pr + 4, rm).times(0.25);
      r.s = x.s;
      return r;
    }
    Ctor.precision = wpr = pr + 10;
    Ctor.rounding = 1;
    k = Math.min(28, wpr / LOG_BASE + 2 | 0);
    for (i2 = k; i2; --i2) x = x.div(x.times(x).plus(1).sqrt().plus(1));
    external = false;
    j = Math.ceil(wpr / LOG_BASE);
    n = 1;
    x2 = x.times(x);
    r = new Ctor(x);
    px = x;
    for (; i2 !== -1; ) {
      px = px.times(x2);
      t2 = r.minus(px.div(n += 2));
      px = px.times(x2);
      r = t2.plus(px.div(n += 2));
      if (r.d[j] !== void 0) for (i2 = j; r.d[i2] === t2.d[i2] && i2--; ) ;
    }
    if (k) r = r.times(2 << k - 1);
    external = true;
    return finalise(r, Ctor.precision = pr, Ctor.rounding = rm, true);
  };
  P.isFinite = function() {
    return !!this.d;
  };
  P.isInteger = P.isInt = function() {
    return !!this.d && mathfloor(this.e / LOG_BASE) > this.d.length - 2;
  };
  P.isNaN = function() {
    return !this.s;
  };
  P.isNegative = P.isNeg = function() {
    return this.s < 0;
  };
  P.isPositive = P.isPos = function() {
    return this.s > 0;
  };
  P.isZero = function() {
    return !!this.d && this.d[0] === 0;
  };
  P.lessThan = P.lt = function(y) {
    return this.cmp(y) < 0;
  };
  P.lessThanOrEqualTo = P.lte = function(y) {
    return this.cmp(y) < 1;
  };
  P.logarithm = P.log = function(base2) {
    var isBase10, d, denominator, k, inf, num, sd, r, arg = this, Ctor = arg.constructor, pr = Ctor.precision, rm = Ctor.rounding, guard2 = 5;
    if (base2 == null) {
      base2 = new Ctor(10);
      isBase10 = true;
    } else {
      base2 = new Ctor(base2);
      d = base2.d;
      if (base2.s < 0 || !d || !d[0] || base2.eq(1)) return new Ctor(NaN);
      isBase10 = base2.eq(10);
    }
    d = arg.d;
    if (arg.s < 0 || !d || !d[0] || arg.eq(1)) {
      return new Ctor(d && !d[0] ? -1 / 0 : arg.s != 1 ? NaN : d ? 0 : 1 / 0);
    }
    if (isBase10) {
      if (d.length > 1) {
        inf = true;
      } else {
        for (k = d[0]; k % 10 === 0; ) k /= 10;
        inf = k !== 1;
      }
    }
    external = false;
    sd = pr + guard2;
    num = naturalLogarithm(arg, sd);
    denominator = isBase10 ? getLn10(Ctor, sd + 10) : naturalLogarithm(base2, sd);
    r = divide(num, denominator, sd, 1);
    if (checkRoundingDigits(r.d, k = pr, rm)) {
      do {
        sd += 10;
        num = naturalLogarithm(arg, sd);
        denominator = isBase10 ? getLn10(Ctor, sd + 10) : naturalLogarithm(base2, sd);
        r = divide(num, denominator, sd, 1);
        if (!inf) {
          if (+digitsToString(r.d).slice(k + 1, k + 15) + 1 == 1e14) {
            r = finalise(r, pr + 1, 0);
          }
          break;
        }
      } while (checkRoundingDigits(r.d, k += 10, rm));
    }
    external = true;
    return finalise(r, pr, rm);
  };
  P.minus = P.sub = function(y) {
    var d, e, i2, j, k, len, pr, rm, xd, xe, xLTy, yd, x = this, Ctor = x.constructor;
    y = new Ctor(y);
    if (!x.d || !y.d) {
      if (!x.s || !y.s) y = new Ctor(NaN);
      else if (x.d) y.s = -y.s;
      else y = new Ctor(y.d || x.s !== y.s ? x : NaN);
      return y;
    }
    if (x.s != y.s) {
      y.s = -y.s;
      return x.plus(y);
    }
    xd = x.d;
    yd = y.d;
    pr = Ctor.precision;
    rm = Ctor.rounding;
    if (!xd[0] || !yd[0]) {
      if (yd[0]) y.s = -y.s;
      else if (xd[0]) y = new Ctor(x);
      else return new Ctor(rm === 3 ? -0 : 0);
      return external ? finalise(y, pr, rm) : y;
    }
    e = mathfloor(y.e / LOG_BASE);
    xe = mathfloor(x.e / LOG_BASE);
    xd = xd.slice();
    k = xe - e;
    if (k) {
      xLTy = k < 0;
      if (xLTy) {
        d = xd;
        k = -k;
        len = yd.length;
      } else {
        d = yd;
        e = xe;
        len = xd.length;
      }
      i2 = Math.max(Math.ceil(pr / LOG_BASE), len) + 2;
      if (k > i2) {
        k = i2;
        d.length = 1;
      }
      d.reverse();
      for (i2 = k; i2--; ) d.push(0);
      d.reverse();
    } else {
      i2 = xd.length;
      len = yd.length;
      xLTy = i2 < len;
      if (xLTy) len = i2;
      for (i2 = 0; i2 < len; i2++) {
        if (xd[i2] != yd[i2]) {
          xLTy = xd[i2] < yd[i2];
          break;
        }
      }
      k = 0;
    }
    if (xLTy) {
      d = xd;
      xd = yd;
      yd = d;
      y.s = -y.s;
    }
    len = xd.length;
    for (i2 = yd.length - len; i2 > 0; --i2) xd[len++] = 0;
    for (i2 = yd.length; i2 > k; ) {
      if (xd[--i2] < yd[i2]) {
        for (j = i2; j && xd[--j] === 0; ) xd[j] = BASE - 1;
        --xd[j];
        xd[i2] += BASE;
      }
      xd[i2] -= yd[i2];
    }
    for (; xd[--len] === 0; ) xd.pop();
    for (; xd[0] === 0; xd.shift()) --e;
    if (!xd[0]) return new Ctor(rm === 3 ? -0 : 0);
    y.d = xd;
    y.e = getBase10Exponent(xd, e);
    return external ? finalise(y, pr, rm) : y;
  };
  P.modulo = P.mod = function(y) {
    var q3, x = this, Ctor = x.constructor;
    y = new Ctor(y);
    if (!x.d || !y.s || y.d && !y.d[0]) return new Ctor(NaN);
    if (!y.d || x.d && !x.d[0]) {
      return finalise(new Ctor(x), Ctor.precision, Ctor.rounding);
    }
    external = false;
    if (Ctor.modulo == 9) {
      q3 = divide(x, y.abs(), 0, 3, 1);
      q3.s *= y.s;
    } else {
      q3 = divide(x, y, 0, Ctor.modulo, 1);
    }
    q3 = q3.times(y);
    external = true;
    return x.minus(q3);
  };
  P.naturalExponential = P.exp = function() {
    return naturalExponential(this);
  };
  P.naturalLogarithm = P.ln = function() {
    return naturalLogarithm(this);
  };
  P.negated = P.neg = function() {
    var x = new this.constructor(this);
    x.s = -x.s;
    return finalise(x);
  };
  P.plus = P.add = function(y) {
    var carry, d, e, i2, k, len, pr, rm, xd, yd, x = this, Ctor = x.constructor;
    y = new Ctor(y);
    if (!x.d || !y.d) {
      if (!x.s || !y.s) y = new Ctor(NaN);
      else if (!x.d) y = new Ctor(y.d || x.s === y.s ? x : NaN);
      return y;
    }
    if (x.s != y.s) {
      y.s = -y.s;
      return x.minus(y);
    }
    xd = x.d;
    yd = y.d;
    pr = Ctor.precision;
    rm = Ctor.rounding;
    if (!xd[0] || !yd[0]) {
      if (!yd[0]) y = new Ctor(x);
      return external ? finalise(y, pr, rm) : y;
    }
    k = mathfloor(x.e / LOG_BASE);
    e = mathfloor(y.e / LOG_BASE);
    xd = xd.slice();
    i2 = k - e;
    if (i2) {
      if (i2 < 0) {
        d = xd;
        i2 = -i2;
        len = yd.length;
      } else {
        d = yd;
        e = k;
        len = xd.length;
      }
      k = Math.ceil(pr / LOG_BASE);
      len = k > len ? k + 1 : len + 1;
      if (i2 > len) {
        i2 = len;
        d.length = 1;
      }
      d.reverse();
      for (; i2--; ) d.push(0);
      d.reverse();
    }
    len = xd.length;
    i2 = yd.length;
    if (len - i2 < 0) {
      i2 = len;
      d = yd;
      yd = xd;
      xd = d;
    }
    for (carry = 0; i2; ) {
      carry = (xd[--i2] = xd[i2] + yd[i2] + carry) / BASE | 0;
      xd[i2] %= BASE;
    }
    if (carry) {
      xd.unshift(carry);
      ++e;
    }
    for (len = xd.length; xd[--len] == 0; ) xd.pop();
    y.d = xd;
    y.e = getBase10Exponent(xd, e);
    return external ? finalise(y, pr, rm) : y;
  };
  P.precision = P.sd = function(z2) {
    var k, x = this;
    if (z2 !== void 0 && z2 !== !!z2 && z2 !== 1 && z2 !== 0) throw Error(invalidArgument + z2);
    if (x.d) {
      k = getPrecision(x.d);
      if (z2 && x.e + 1 > k) k = x.e + 1;
    } else {
      k = NaN;
    }
    return k;
  };
  P.round = function() {
    var x = this, Ctor = x.constructor;
    return finalise(new Ctor(x), x.e + 1, Ctor.rounding);
  };
  P.sine = P.sin = function() {
    var pr, rm, x = this, Ctor = x.constructor;
    if (!x.isFinite()) return new Ctor(NaN);
    if (x.isZero()) return new Ctor(x);
    pr = Ctor.precision;
    rm = Ctor.rounding;
    Ctor.precision = pr + Math.max(x.e, x.sd()) + LOG_BASE;
    Ctor.rounding = 1;
    x = sine(Ctor, toLessThanHalfPi(Ctor, x));
    Ctor.precision = pr;
    Ctor.rounding = rm;
    return finalise(quadrant > 2 ? x.neg() : x, pr, rm, true);
  };
  P.squareRoot = P.sqrt = function() {
    var m2, n, sd, r, rep, t2, x = this, d = x.d, e = x.e, s2 = x.s, Ctor = x.constructor;
    if (s2 !== 1 || !d || !d[0]) {
      return new Ctor(!s2 || s2 < 0 && (!d || d[0]) ? NaN : d ? x : 1 / 0);
    }
    external = false;
    s2 = Math.sqrt(+x);
    if (s2 == 0 || s2 == 1 / 0) {
      n = digitsToString(d);
      if ((n.length + e) % 2 == 0) n += "0";
      s2 = Math.sqrt(n);
      e = mathfloor((e + 1) / 2) - (e < 0 || e % 2);
      if (s2 == 1 / 0) {
        n = "5e" + e;
      } else {
        n = s2.toExponential();
        n = n.slice(0, n.indexOf("e") + 1) + e;
      }
      r = new Ctor(n);
    } else {
      r = new Ctor(s2.toString());
    }
    sd = (e = Ctor.precision) + 3;
    for (; ; ) {
      t2 = r;
      r = t2.plus(divide(x, t2, sd + 2, 1)).times(0.5);
      if (digitsToString(t2.d).slice(0, sd) === (n = digitsToString(r.d)).slice(0, sd)) {
        n = n.slice(sd - 3, sd + 1);
        if (n == "9999" || !rep && n == "4999") {
          if (!rep) {
            finalise(t2, e + 1, 0);
            if (t2.times(t2).eq(x)) {
              r = t2;
              break;
            }
          }
          sd += 4;
          rep = 1;
        } else {
          if (!+n || !+n.slice(1) && n.charAt(0) == "5") {
            finalise(r, e + 1, 1);
            m2 = !r.times(r).eq(x);
          }
          break;
        }
      }
    }
    external = true;
    return finalise(r, e, Ctor.rounding, m2);
  };
  P.tangent = P.tan = function() {
    var pr, rm, x = this, Ctor = x.constructor;
    if (!x.isFinite()) return new Ctor(NaN);
    if (x.isZero()) return new Ctor(x);
    pr = Ctor.precision;
    rm = Ctor.rounding;
    Ctor.precision = pr + 10;
    Ctor.rounding = 1;
    x = x.sin();
    x.s = 1;
    x = divide(x, new Ctor(1).minus(x.times(x)).sqrt(), pr + 10, 0);
    Ctor.precision = pr;
    Ctor.rounding = rm;
    return finalise(quadrant == 2 || quadrant == 4 ? x.neg() : x, pr, rm, true);
  };
  P.times = P.mul = function(y) {
    var carry, e, i2, k, r, rL, t2, xdL, ydL, x = this, Ctor = x.constructor, xd = x.d, yd = (y = new Ctor(y)).d;
    y.s *= x.s;
    if (!xd || !xd[0] || !yd || !yd[0]) {
      return new Ctor(!y.s || xd && !xd[0] && !yd || yd && !yd[0] && !xd ? NaN : !xd || !yd ? y.s / 0 : y.s * 0);
    }
    e = mathfloor(x.e / LOG_BASE) + mathfloor(y.e / LOG_BASE);
    xdL = xd.length;
    ydL = yd.length;
    if (xdL < ydL) {
      r = xd;
      xd = yd;
      yd = r;
      rL = xdL;
      xdL = ydL;
      ydL = rL;
    }
    r = [];
    rL = xdL + ydL;
    for (i2 = rL; i2--; ) r.push(0);
    for (i2 = ydL; --i2 >= 0; ) {
      carry = 0;
      for (k = xdL + i2; k > i2; ) {
        t2 = r[k] + yd[i2] * xd[k - i2 - 1] + carry;
        r[k--] = t2 % BASE | 0;
        carry = t2 / BASE | 0;
      }
      r[k] = (r[k] + carry) % BASE | 0;
    }
    for (; !r[--rL]; ) r.pop();
    if (carry) ++e;
    else r.shift();
    y.d = r;
    y.e = getBase10Exponent(r, e);
    return external ? finalise(y, Ctor.precision, Ctor.rounding) : y;
  };
  P.toBinary = function(sd, rm) {
    return toStringBinary(this, 2, sd, rm);
  };
  P.toDecimalPlaces = P.toDP = function(dp, rm) {
    var x = this, Ctor = x.constructor;
    x = new Ctor(x);
    if (dp === void 0) return x;
    checkInt32(dp, 0, MAX_DIGITS);
    if (rm === void 0) rm = Ctor.rounding;
    else checkInt32(rm, 0, 8);
    return finalise(x, dp + x.e + 1, rm);
  };
  P.toExponential = function(dp, rm) {
    var str, x = this, Ctor = x.constructor;
    if (dp === void 0) {
      str = finiteToString(x, true);
    } else {
      checkInt32(dp, 0, MAX_DIGITS);
      if (rm === void 0) rm = Ctor.rounding;
      else checkInt32(rm, 0, 8);
      x = finalise(new Ctor(x), dp + 1, rm);
      str = finiteToString(x, true, dp + 1);
    }
    return x.isNeg() && !x.isZero() ? "-" + str : str;
  };
  P.toFixed = function(dp, rm) {
    var str, y, x = this, Ctor = x.constructor;
    if (dp === void 0) {
      str = finiteToString(x);
    } else {
      checkInt32(dp, 0, MAX_DIGITS);
      if (rm === void 0) rm = Ctor.rounding;
      else checkInt32(rm, 0, 8);
      y = finalise(new Ctor(x), dp + x.e + 1, rm);
      str = finiteToString(y, false, dp + y.e + 1);
    }
    return x.isNeg() && !x.isZero() ? "-" + str : str;
  };
  P.toFraction = function(maxD) {
    var d, d0, d1, d2, e, k, n, n0, n1, pr, q3, r, x = this, xd = x.d, Ctor = x.constructor;
    if (!xd) return new Ctor(x);
    n1 = d0 = new Ctor(1);
    d1 = n0 = new Ctor(0);
    d = new Ctor(d1);
    e = d.e = getPrecision(xd) - x.e - 1;
    k = e % LOG_BASE;
    d.d[0] = mathpow(10, k < 0 ? LOG_BASE + k : k);
    if (maxD == null) {
      maxD = e > 0 ? d : n1;
    } else {
      n = new Ctor(maxD);
      if (!n.isInt() || n.lt(n1)) throw Error(invalidArgument + n);
      maxD = n.gt(d) ? e > 0 ? d : n1 : n;
    }
    external = false;
    n = new Ctor(digitsToString(xd));
    pr = Ctor.precision;
    Ctor.precision = e = xd.length * LOG_BASE * 2;
    for (; ; ) {
      q3 = divide(n, d, 0, 1, 1);
      d2 = d0.plus(q3.times(d1));
      if (d2.cmp(maxD) == 1) break;
      d0 = d1;
      d1 = d2;
      d2 = n1;
      n1 = n0.plus(q3.times(d2));
      n0 = d2;
      d2 = d;
      d = n.minus(q3.times(d2));
      n = d2;
    }
    d2 = divide(maxD.minus(d0), d1, 0, 1, 1);
    n0 = n0.plus(d2.times(n1));
    d0 = d0.plus(d2.times(d1));
    n0.s = n1.s = x.s;
    r = divide(n1, d1, e, 1).minus(x).abs().cmp(divide(n0, d0, e, 1).minus(x).abs()) < 1 ? [n1, d1] : [n0, d0];
    Ctor.precision = pr;
    external = true;
    return r;
  };
  P.toHexadecimal = P.toHex = function(sd, rm) {
    return toStringBinary(this, 16, sd, rm);
  };
  P.toNearest = function(y, rm) {
    var x = this, Ctor = x.constructor;
    x = new Ctor(x);
    if (y == null) {
      if (!x.d) return x;
      y = new Ctor(1);
      rm = Ctor.rounding;
    } else {
      y = new Ctor(y);
      if (rm === void 0) {
        rm = Ctor.rounding;
      } else {
        checkInt32(rm, 0, 8);
      }
      if (!x.d) return y.s ? x : y;
      if (!y.d) {
        if (y.s) y.s = x.s;
        return y;
      }
    }
    if (y.d[0]) {
      external = false;
      x = divide(x, y, 0, rm, 1).times(y);
      external = true;
      finalise(x);
    } else {
      y.s = x.s;
      x = y;
    }
    return x;
  };
  P.toNumber = function() {
    return +this;
  };
  P.toOctal = function(sd, rm) {
    return toStringBinary(this, 8, sd, rm);
  };
  P.toPower = P.pow = function(y) {
    var e, k, pr, r, rm, s2, x = this, Ctor = x.constructor, yn = +(y = new Ctor(y));
    if (!x.d || !y.d || !x.d[0] || !y.d[0]) return new Ctor(mathpow(+x, yn));
    x = new Ctor(x);
    if (x.eq(1)) return x;
    pr = Ctor.precision;
    rm = Ctor.rounding;
    if (y.eq(1)) return finalise(x, pr, rm);
    e = mathfloor(y.e / LOG_BASE);
    if (e >= y.d.length - 1 && (k = yn < 0 ? -yn : yn) <= MAX_SAFE_INTEGER) {
      r = intPow(Ctor, x, k, pr);
      return y.s < 0 ? new Ctor(1).div(r) : finalise(r, pr, rm);
    }
    s2 = x.s;
    if (s2 < 0) {
      if (e < y.d.length - 1) return new Ctor(NaN);
      if ((y.d[e] & 1) == 0) s2 = 1;
      if (x.e == 0 && x.d[0] == 1 && x.d.length == 1) {
        x.s = s2;
        return x;
      }
    }
    k = mathpow(+x, yn);
    e = k == 0 || !isFinite(k) ? mathfloor(yn * (Math.log("0." + digitsToString(x.d)) / Math.LN10 + x.e + 1)) : new Ctor(k + "").e;
    if (e > Ctor.maxE + 1 || e < Ctor.minE - 1) return new Ctor(e > 0 ? s2 / 0 : 0);
    external = false;
    Ctor.rounding = x.s = 1;
    k = Math.min(12, (e + "").length);
    r = naturalExponential(y.times(naturalLogarithm(x, pr + k)), pr);
    if (r.d) {
      r = finalise(r, pr + 5, 1);
      if (checkRoundingDigits(r.d, pr, rm)) {
        e = pr + 10;
        r = finalise(naturalExponential(y.times(naturalLogarithm(x, e + k)), e), e + 5, 1);
        if (+digitsToString(r.d).slice(pr + 1, pr + 15) + 1 == 1e14) {
          r = finalise(r, pr + 1, 0);
        }
      }
    }
    r.s = s2;
    external = true;
    Ctor.rounding = rm;
    return finalise(r, pr, rm);
  };
  P.toPrecision = function(sd, rm) {
    var str, x = this, Ctor = x.constructor;
    if (sd === void 0) {
      str = finiteToString(x, x.e <= Ctor.toExpNeg || x.e >= Ctor.toExpPos);
    } else {
      checkInt32(sd, 1, MAX_DIGITS);
      if (rm === void 0) rm = Ctor.rounding;
      else checkInt32(rm, 0, 8);
      x = finalise(new Ctor(x), sd, rm);
      str = finiteToString(x, sd <= x.e || x.e <= Ctor.toExpNeg, sd);
    }
    return x.isNeg() && !x.isZero() ? "-" + str : str;
  };
  P.toSignificantDigits = P.toSD = function(sd, rm) {
    var x = this, Ctor = x.constructor;
    if (sd === void 0) {
      sd = Ctor.precision;
      rm = Ctor.rounding;
    } else {
      checkInt32(sd, 1, MAX_DIGITS);
      if (rm === void 0) rm = Ctor.rounding;
      else checkInt32(rm, 0, 8);
    }
    return finalise(new Ctor(x), sd, rm);
  };
  P.toString = function() {
    var x = this, Ctor = x.constructor, str = finiteToString(x, x.e <= Ctor.toExpNeg || x.e >= Ctor.toExpPos);
    return x.isNeg() && !x.isZero() ? "-" + str : str;
  };
  P.truncated = P.trunc = function() {
    return finalise(new this.constructor(this), this.e + 1, 1);
  };
  P.valueOf = P.toJSON = function() {
    var x = this, Ctor = x.constructor, str = finiteToString(x, x.e <= Ctor.toExpNeg || x.e >= Ctor.toExpPos);
    return x.isNeg() ? "-" + str : str;
  };
  function digitsToString(d) {
    var i2, k, ws, indexOfLastWord = d.length - 1, str = "", w = d[0];
    if (indexOfLastWord > 0) {
      str += w;
      for (i2 = 1; i2 < indexOfLastWord; i2++) {
        ws = d[i2] + "";
        k = LOG_BASE - ws.length;
        if (k) str += getZeroString(k);
        str += ws;
      }
      w = d[i2];
      ws = w + "";
      k = LOG_BASE - ws.length;
      if (k) str += getZeroString(k);
    } else if (w === 0) {
      return "0";
    }
    for (; w % 10 === 0; ) w /= 10;
    return str + w;
  }
  function checkInt32(i2, min7, max8) {
    if (i2 !== ~~i2 || i2 < min7 || i2 > max8) {
      throw Error(invalidArgument + i2);
    }
  }
  function checkRoundingDigits(d, i2, rm, repeating) {
    var di, k, r, rd;
    for (k = d[0]; k >= 10; k /= 10) --i2;
    if (--i2 < 0) {
      i2 += LOG_BASE;
      di = 0;
    } else {
      di = Math.ceil((i2 + 1) / LOG_BASE);
      i2 %= LOG_BASE;
    }
    k = mathpow(10, LOG_BASE - i2);
    rd = d[di] % k | 0;
    if (repeating == null) {
      if (i2 < 3) {
        if (i2 == 0) rd = rd / 100 | 0;
        else if (i2 == 1) rd = rd / 10 | 0;
        r = rm < 4 && rd == 99999 || rm > 3 && rd == 49999 || rd == 5e4 || rd == 0;
      } else {
        r = (rm < 4 && rd + 1 == k || rm > 3 && rd + 1 == k / 2) && (d[di + 1] / k / 100 | 0) == mathpow(10, i2 - 2) - 1 || (rd == k / 2 || rd == 0) && (d[di + 1] / k / 100 | 0) == 0;
      }
    } else {
      if (i2 < 4) {
        if (i2 == 0) rd = rd / 1e3 | 0;
        else if (i2 == 1) rd = rd / 100 | 0;
        else if (i2 == 2) rd = rd / 10 | 0;
        r = (repeating || rm < 4) && rd == 9999 || !repeating && rm > 3 && rd == 4999;
      } else {
        r = ((repeating || rm < 4) && rd + 1 == k || !repeating && rm > 3 && rd + 1 == k / 2) && (d[di + 1] / k / 1e3 | 0) == mathpow(10, i2 - 3) - 1;
      }
    }
    return r;
  }
  function convertBase(str, baseIn, baseOut) {
    var j, arr = [0], arrL, i2 = 0, strL = str.length;
    for (; i2 < strL; ) {
      for (arrL = arr.length; arrL--; ) arr[arrL] *= baseIn;
      arr[0] += NUMERALS.indexOf(str.charAt(i2++));
      for (j = 0; j < arr.length; j++) {
        if (arr[j] > baseOut - 1) {
          if (arr[j + 1] === void 0) arr[j + 1] = 0;
          arr[j + 1] += arr[j] / baseOut | 0;
          arr[j] %= baseOut;
        }
      }
    }
    return arr.reverse();
  }
  function cosine(Ctor, x) {
    var k, len, y;
    if (x.isZero()) return x;
    len = x.d.length;
    if (len < 32) {
      k = Math.ceil(len / 3);
      y = (1 / tinyPow(4, k)).toString();
    } else {
      k = 16;
      y = "2.3283064365386962890625e-10";
    }
    Ctor.precision += k;
    x = taylorSeries(Ctor, 1, x.times(y), new Ctor(1));
    for (var i2 = k; i2--; ) {
      var cos2x = x.times(x);
      x = cos2x.times(cos2x).minus(cos2x).times(8).plus(1);
    }
    Ctor.precision -= k;
    return x;
  }
  var divide = /* @__PURE__ */ (function() {
    function multiplyInteger(x, k, base2) {
      var temp, carry = 0, i2 = x.length;
      for (x = x.slice(); i2--; ) {
        temp = x[i2] * k + carry;
        x[i2] = temp % base2 | 0;
        carry = temp / base2 | 0;
      }
      if (carry) x.unshift(carry);
      return x;
    }
    function compare4(a3, b2, aL, bL) {
      var i2, r;
      if (aL != bL) {
        r = aL > bL ? 1 : -1;
      } else {
        for (i2 = r = 0; i2 < aL; i2++) {
          if (a3[i2] != b2[i2]) {
            r = a3[i2] > b2[i2] ? 1 : -1;
            break;
          }
        }
      }
      return r;
    }
    function subtract2(a3, b2, aL, base2) {
      var i2 = 0;
      for (; aL--; ) {
        a3[aL] -= i2;
        i2 = a3[aL] < b2[aL] ? 1 : 0;
        a3[aL] = i2 * base2 + a3[aL] - b2[aL];
      }
      for (; !a3[0] && a3.length > 1; ) a3.shift();
    }
    return function(x, y, pr, rm, dp, base2) {
      var cmp, e, i2, k, logBase, more, prod, prodL, q3, qd, rem2, remL, rem0, sd, t2, xi, xL, yd0, yL, yz, Ctor = x.constructor, sign3 = x.s == y.s ? 1 : -1, xd = x.d, yd = y.d;
      if (!xd || !xd[0] || !yd || !yd[0]) {
        return new Ctor(
          // Return NaN if either NaN, or both Infinity or 0.
          !x.s || !y.s || (xd ? yd && xd[0] == yd[0] : !yd) ? NaN : (
            // Return ±0 if x is 0 or y is ±Infinity, or return ±Infinity as y is 0.
            xd && xd[0] == 0 || !yd ? sign3 * 0 : sign3 / 0
          )
        );
      }
      if (base2) {
        logBase = 1;
        e = x.e - y.e;
      } else {
        base2 = BASE;
        logBase = LOG_BASE;
        e = mathfloor(x.e / logBase) - mathfloor(y.e / logBase);
      }
      yL = yd.length;
      xL = xd.length;
      q3 = new Ctor(sign3);
      qd = q3.d = [];
      for (i2 = 0; yd[i2] == (xd[i2] || 0); i2++) ;
      if (yd[i2] > (xd[i2] || 0)) e--;
      if (pr == null) {
        sd = pr = Ctor.precision;
        rm = Ctor.rounding;
      } else if (dp) {
        sd = pr + (x.e - y.e) + 1;
      } else {
        sd = pr;
      }
      if (sd < 0) {
        qd.push(1);
        more = true;
      } else {
        sd = sd / logBase + 2 | 0;
        i2 = 0;
        if (yL == 1) {
          k = 0;
          yd = yd[0];
          sd++;
          for (; (i2 < xL || k) && sd--; i2++) {
            t2 = k * base2 + (xd[i2] || 0);
            qd[i2] = t2 / yd | 0;
            k = t2 % yd | 0;
          }
          more = k || i2 < xL;
        } else {
          k = base2 / (yd[0] + 1) | 0;
          if (k > 1) {
            yd = multiplyInteger(yd, k, base2);
            xd = multiplyInteger(xd, k, base2);
            yL = yd.length;
            xL = xd.length;
          }
          xi = yL;
          rem2 = xd.slice(0, yL);
          remL = rem2.length;
          for (; remL < yL; ) rem2[remL++] = 0;
          yz = yd.slice();
          yz.unshift(0);
          yd0 = yd[0];
          if (yd[1] >= base2 / 2) ++yd0;
          do {
            k = 0;
            cmp = compare4(yd, rem2, yL, remL);
            if (cmp < 0) {
              rem0 = rem2[0];
              if (yL != remL) rem0 = rem0 * base2 + (rem2[1] || 0);
              k = rem0 / yd0 | 0;
              if (k > 1) {
                if (k >= base2) k = base2 - 1;
                prod = multiplyInteger(yd, k, base2);
                prodL = prod.length;
                remL = rem2.length;
                cmp = compare4(prod, rem2, prodL, remL);
                if (cmp == 1) {
                  k--;
                  subtract2(prod, yL < prodL ? yz : yd, prodL, base2);
                }
              } else {
                if (k == 0) cmp = k = 1;
                prod = yd.slice();
              }
              prodL = prod.length;
              if (prodL < remL) prod.unshift(0);
              subtract2(rem2, prod, remL, base2);
              if (cmp == -1) {
                remL = rem2.length;
                cmp = compare4(yd, rem2, yL, remL);
                if (cmp < 1) {
                  k++;
                  subtract2(rem2, yL < remL ? yz : yd, remL, base2);
                }
              }
              remL = rem2.length;
            } else if (cmp === 0) {
              k++;
              rem2 = [0];
            }
            qd[i2++] = k;
            if (cmp && rem2[0]) {
              rem2[remL++] = xd[xi] || 0;
            } else {
              rem2 = [xd[xi]];
              remL = 1;
            }
          } while ((xi++ < xL || rem2[0] !== void 0) && sd--);
          more = rem2[0] !== void 0;
        }
        if (!qd[0]) qd.shift();
      }
      if (logBase == 1) {
        q3.e = e;
        inexact = more;
      } else {
        for (i2 = 1, k = qd[0]; k >= 10; k /= 10) i2++;
        q3.e = i2 + e * logBase - 1;
        finalise(q3, dp ? pr + q3.e + 1 : pr, rm, more);
      }
      return q3;
    };
  })();
  function finalise(x, sd, rm, isTruncated) {
    var digits, i2, j, k, rd, roundUp, w, xd, xdi, Ctor = x.constructor;
    out: if (sd != null) {
      xd = x.d;
      if (!xd) return x;
      for (digits = 1, k = xd[0]; k >= 10; k /= 10) digits++;
      i2 = sd - digits;
      if (i2 < 0) {
        i2 += LOG_BASE;
        j = sd;
        w = xd[xdi = 0];
        rd = w / mathpow(10, digits - j - 1) % 10 | 0;
      } else {
        xdi = Math.ceil((i2 + 1) / LOG_BASE);
        k = xd.length;
        if (xdi >= k) {
          if (isTruncated) {
            for (; k++ <= xdi; ) xd.push(0);
            w = rd = 0;
            digits = 1;
            i2 %= LOG_BASE;
            j = i2 - LOG_BASE + 1;
          } else {
            break out;
          }
        } else {
          w = k = xd[xdi];
          for (digits = 1; k >= 10; k /= 10) digits++;
          i2 %= LOG_BASE;
          j = i2 - LOG_BASE + digits;
          rd = j < 0 ? 0 : w / mathpow(10, digits - j - 1) % 10 | 0;
        }
      }
      isTruncated = isTruncated || sd < 0 || xd[xdi + 1] !== void 0 || (j < 0 ? w : w % mathpow(10, digits - j - 1));
      roundUp = rm < 4 ? (rd || isTruncated) && (rm == 0 || rm == (x.s < 0 ? 3 : 2)) : rd > 5 || rd == 5 && (rm == 4 || isTruncated || rm == 6 && // Check whether the digit to the left of the rounding digit is odd.
      (i2 > 0 ? j > 0 ? w / mathpow(10, digits - j) : 0 : xd[xdi - 1]) % 10 & 1 || rm == (x.s < 0 ? 8 : 7));
      if (sd < 1 || !xd[0]) {
        xd.length = 0;
        if (roundUp) {
          sd -= x.e + 1;
          xd[0] = mathpow(10, (LOG_BASE - sd % LOG_BASE) % LOG_BASE);
          x.e = -sd || 0;
        } else {
          xd[0] = x.e = 0;
        }
        return x;
      }
      if (i2 == 0) {
        xd.length = xdi;
        k = 1;
        xdi--;
      } else {
        xd.length = xdi + 1;
        k = mathpow(10, LOG_BASE - i2);
        xd[xdi] = j > 0 ? (w / mathpow(10, digits - j) % mathpow(10, j) | 0) * k : 0;
      }
      if (roundUp) {
        for (; ; ) {
          if (xdi == 0) {
            for (i2 = 1, j = xd[0]; j >= 10; j /= 10) i2++;
            j = xd[0] += k;
            for (k = 1; j >= 10; j /= 10) k++;
            if (i2 != k) {
              x.e++;
              if (xd[0] == BASE) xd[0] = 1;
            }
            break;
          } else {
            xd[xdi] += k;
            if (xd[xdi] != BASE) break;
            xd[xdi--] = 0;
            k = 1;
          }
        }
      }
      for (i2 = xd.length; xd[--i2] === 0; ) xd.pop();
    }
    if (external) {
      if (x.e > Ctor.maxE) {
        x.d = null;
        x.e = NaN;
      } else if (x.e < Ctor.minE) {
        x.e = 0;
        x.d = [0];
      }
    }
    return x;
  }
  function finiteToString(x, isExp, sd) {
    if (!x.isFinite()) return nonFiniteToString(x);
    var k, e = x.e, str = digitsToString(x.d), len = str.length;
    if (isExp) {
      if (sd && (k = sd - len) > 0) {
        str = str.charAt(0) + "." + str.slice(1) + getZeroString(k);
      } else if (len > 1) {
        str = str.charAt(0) + "." + str.slice(1);
      }
      str = str + (x.e < 0 ? "e" : "e+") + x.e;
    } else if (e < 0) {
      str = "0." + getZeroString(-e - 1) + str;
      if (sd && (k = sd - len) > 0) str += getZeroString(k);
    } else if (e >= len) {
      str += getZeroString(e + 1 - len);
      if (sd && (k = sd - e - 1) > 0) str = str + "." + getZeroString(k);
    } else {
      if ((k = e + 1) < len) str = str.slice(0, k) + "." + str.slice(k);
      if (sd && (k = sd - len) > 0) {
        if (e + 1 === len) str += ".";
        str += getZeroString(k);
      }
    }
    return str;
  }
  function getBase10Exponent(digits, e) {
    var w = digits[0];
    for (e *= LOG_BASE; w >= 10; w /= 10) e++;
    return e;
  }
  function getLn10(Ctor, sd, pr) {
    if (sd > LN10_PRECISION) {
      external = true;
      if (pr) Ctor.precision = pr;
      throw Error(precisionLimitExceeded);
    }
    return finalise(new Ctor(LN10), sd, 1, true);
  }
  function getPi(Ctor, sd, rm) {
    if (sd > PI_PRECISION) throw Error(precisionLimitExceeded);
    return finalise(new Ctor(PI), sd, rm, true);
  }
  function getPrecision(digits) {
    var w = digits.length - 1, len = w * LOG_BASE + 1;
    w = digits[w];
    if (w) {
      for (; w % 10 == 0; w /= 10) len--;
      for (w = digits[0]; w >= 10; w /= 10) len++;
    }
    return len;
  }
  function getZeroString(k) {
    var zs = "";
    for (; k--; ) zs += "0";
    return zs;
  }
  function intPow(Ctor, x, n, pr) {
    var isTruncated, r = new Ctor(1), k = Math.ceil(pr / LOG_BASE + 4);
    external = false;
    for (; ; ) {
      if (n % 2) {
        r = r.times(x);
        if (truncate(r.d, k)) isTruncated = true;
      }
      n = mathfloor(n / 2);
      if (n === 0) {
        n = r.d.length - 1;
        if (isTruncated && r.d[n] === 0) ++r.d[n];
        break;
      }
      x = x.times(x);
      truncate(x.d, k);
    }
    external = true;
    return r;
  }
  function isOdd(n) {
    return n.d[n.d.length - 1] & 1;
  }
  function maxOrMin(Ctor, args, n) {
    var k, y, x = new Ctor(args[0]), i2 = 0;
    for (; ++i2 < args.length; ) {
      y = new Ctor(args[i2]);
      if (!y.s) {
        x = y;
        break;
      }
      k = x.cmp(y);
      if (k === n || k === 0 && x.s === n) {
        x = y;
      }
    }
    return x;
  }
  function naturalExponential(x, sd) {
    var denominator, guard2, j, pow4, sum3, t2, wpr, rep = 0, i2 = 0, k = 0, Ctor = x.constructor, rm = Ctor.rounding, pr = Ctor.precision;
    if (!x.d || !x.d[0] || x.e > 17) {
      return new Ctor(x.d ? !x.d[0] ? 1 : x.s < 0 ? 0 : 1 / 0 : x.s ? x.s < 0 ? 0 : x : 0 / 0);
    }
    if (sd == null) {
      external = false;
      wpr = pr;
    } else {
      wpr = sd;
    }
    t2 = new Ctor(0.03125);
    while (x.e > -2) {
      x = x.times(t2);
      k += 5;
    }
    guard2 = Math.log(mathpow(2, k)) / Math.LN10 * 2 + 5 | 0;
    wpr += guard2;
    denominator = pow4 = sum3 = new Ctor(1);
    Ctor.precision = wpr;
    for (; ; ) {
      pow4 = finalise(pow4.times(x), wpr, 1);
      denominator = denominator.times(++i2);
      t2 = sum3.plus(divide(pow4, denominator, wpr, 1));
      if (digitsToString(t2.d).slice(0, wpr) === digitsToString(sum3.d).slice(0, wpr)) {
        j = k;
        while (j--) sum3 = finalise(sum3.times(sum3), wpr, 1);
        if (sd == null) {
          if (rep < 3 && checkRoundingDigits(sum3.d, wpr - guard2, rm, rep)) {
            Ctor.precision = wpr += 10;
            denominator = pow4 = t2 = new Ctor(1);
            i2 = 0;
            rep++;
          } else {
            return finalise(sum3, Ctor.precision = pr, rm, external = true);
          }
        } else {
          Ctor.precision = pr;
          return sum3;
        }
      }
      sum3 = t2;
    }
  }
  function naturalLogarithm(y, sd) {
    var c2, c0, denominator, e, numerator, rep, sum3, t2, wpr, x1, x2, n = 1, guard2 = 10, x = y, xd = x.d, Ctor = x.constructor, rm = Ctor.rounding, pr = Ctor.precision;
    if (x.s < 0 || !xd || !xd[0] || !x.e && xd[0] == 1 && xd.length == 1) {
      return new Ctor(xd && !xd[0] ? -1 / 0 : x.s != 1 ? NaN : xd ? 0 : x);
    }
    if (sd == null) {
      external = false;
      wpr = pr;
    } else {
      wpr = sd;
    }
    Ctor.precision = wpr += guard2;
    c2 = digitsToString(xd);
    c0 = c2.charAt(0);
    if (Math.abs(e = x.e) < 15e14) {
      while (c0 < 7 && c0 != 1 || c0 == 1 && c2.charAt(1) > 3) {
        x = x.times(y);
        c2 = digitsToString(x.d);
        c0 = c2.charAt(0);
        n++;
      }
      e = x.e;
      if (c0 > 1) {
        x = new Ctor("0." + c2);
        e++;
      } else {
        x = new Ctor(c0 + "." + c2.slice(1));
      }
    } else {
      t2 = getLn10(Ctor, wpr + 2, pr).times(e + "");
      x = naturalLogarithm(new Ctor(c0 + "." + c2.slice(1)), wpr - guard2).plus(t2);
      Ctor.precision = pr;
      return sd == null ? finalise(x, pr, rm, external = true) : x;
    }
    x1 = x;
    sum3 = numerator = x = divide(x.minus(1), x.plus(1), wpr, 1);
    x2 = finalise(x.times(x), wpr, 1);
    denominator = 3;
    for (; ; ) {
      numerator = finalise(numerator.times(x2), wpr, 1);
      t2 = sum3.plus(divide(numerator, new Ctor(denominator), wpr, 1));
      if (digitsToString(t2.d).slice(0, wpr) === digitsToString(sum3.d).slice(0, wpr)) {
        sum3 = sum3.times(2);
        if (e !== 0) sum3 = sum3.plus(getLn10(Ctor, wpr + 2, pr).times(e + ""));
        sum3 = divide(sum3, new Ctor(n), wpr, 1);
        if (sd == null) {
          if (checkRoundingDigits(sum3.d, wpr - guard2, rm, rep)) {
            Ctor.precision = wpr += guard2;
            t2 = numerator = x = divide(x1.minus(1), x1.plus(1), wpr, 1);
            x2 = finalise(x.times(x), wpr, 1);
            denominator = rep = 1;
          } else {
            return finalise(sum3, Ctor.precision = pr, rm, external = true);
          }
        } else {
          Ctor.precision = pr;
          return sum3;
        }
      }
      sum3 = t2;
      denominator += 2;
    }
  }
  function nonFiniteToString(x) {
    return String(x.s * x.s / 0);
  }
  function parseDecimal(x, str) {
    var e, i2, len;
    if ((e = str.indexOf(".")) > -1) str = str.replace(".", "");
    if ((i2 = str.search(/e/i)) > 0) {
      if (e < 0) e = i2;
      e += +str.slice(i2 + 1);
      str = str.substring(0, i2);
    } else if (e < 0) {
      e = str.length;
    }
    for (i2 = 0; str.charCodeAt(i2) === 48; i2++) ;
    for (len = str.length; str.charCodeAt(len - 1) === 48; --len) ;
    str = str.slice(i2, len);
    if (str) {
      len -= i2;
      x.e = e = e - i2 - 1;
      x.d = [];
      i2 = (e + 1) % LOG_BASE;
      if (e < 0) i2 += LOG_BASE;
      if (i2 < len) {
        if (i2) x.d.push(+str.slice(0, i2));
        for (len -= LOG_BASE; i2 < len; ) x.d.push(+str.slice(i2, i2 += LOG_BASE));
        str = str.slice(i2);
        i2 = LOG_BASE - str.length;
      } else {
        i2 -= len;
      }
      for (; i2--; ) str += "0";
      x.d.push(+str);
      if (external) {
        if (x.e > x.constructor.maxE) {
          x.d = null;
          x.e = NaN;
        } else if (x.e < x.constructor.minE) {
          x.e = 0;
          x.d = [0];
        }
      }
    } else {
      x.e = 0;
      x.d = [0];
    }
    return x;
  }
  function parseOther(x, str) {
    var base2, Ctor, divisor, i2, isFloat, len, p2, xd, xe;
    if (str.indexOf("_") > -1) {
      str = str.replace(/(\d)_(?=\d)/g, "$1");
      if (isDecimal.test(str)) return parseDecimal(x, str);
    } else if (str === "Infinity" || str === "NaN") {
      if (!+str) x.s = NaN;
      x.e = NaN;
      x.d = null;
      return x;
    }
    if (isHex.test(str)) {
      base2 = 16;
      str = str.toLowerCase();
    } else if (isBinary.test(str)) {
      base2 = 2;
    } else if (isOctal.test(str)) {
      base2 = 8;
    } else {
      throw Error(invalidArgument + str);
    }
    i2 = str.search(/p/i);
    if (i2 > 0) {
      p2 = +str.slice(i2 + 1);
      str = str.substring(2, i2);
    } else {
      str = str.slice(2);
    }
    i2 = str.indexOf(".");
    isFloat = i2 >= 0;
    Ctor = x.constructor;
    if (isFloat) {
      str = str.replace(".", "");
      len = str.length;
      i2 = len - i2;
      divisor = intPow(Ctor, new Ctor(base2), i2, i2 * 2);
    }
    xd = convertBase(str, base2, BASE);
    xe = xd.length - 1;
    for (i2 = xe; xd[i2] === 0; --i2) xd.pop();
    if (i2 < 0) return new Ctor(x.s * 0);
    x.e = getBase10Exponent(xd, xe);
    x.d = xd;
    external = false;
    if (isFloat) x = divide(x, divisor, len * 4);
    if (p2) x = x.times(Math.abs(p2) < 54 ? mathpow(2, p2) : Decimal.pow(2, p2));
    external = true;
    return x;
  }
  function sine(Ctor, x) {
    var k, len = x.d.length;
    if (len < 3) {
      return x.isZero() ? x : taylorSeries(Ctor, 2, x, x);
    }
    k = 1.4 * Math.sqrt(len);
    k = k > 16 ? 16 : k | 0;
    x = x.times(1 / tinyPow(5, k));
    x = taylorSeries(Ctor, 2, x, x);
    var sin2_x, d5 = new Ctor(5), d16 = new Ctor(16), d20 = new Ctor(20);
    for (; k--; ) {
      sin2_x = x.times(x);
      x = x.times(d5.plus(sin2_x.times(d16.times(sin2_x).minus(d20))));
    }
    return x;
  }
  function taylorSeries(Ctor, n, x, y, isHyperbolic) {
    var j, t2, u2, x2, i2 = 1, pr = Ctor.precision, k = Math.ceil(pr / LOG_BASE);
    external = false;
    x2 = x.times(x);
    u2 = new Ctor(y);
    for (; ; ) {
      t2 = divide(u2.times(x2), new Ctor(n++ * n++), pr, 1);
      u2 = isHyperbolic ? y.plus(t2) : y.minus(t2);
      y = divide(t2.times(x2), new Ctor(n++ * n++), pr, 1);
      t2 = u2.plus(y);
      if (t2.d[k] !== void 0) {
        for (j = k; t2.d[j] === u2.d[j] && j--; ) ;
        if (j == -1) break;
      }
      j = u2;
      u2 = y;
      y = t2;
      t2 = j;
      i2++;
    }
    external = true;
    t2.d.length = k + 1;
    return t2;
  }
  function tinyPow(b2, e) {
    var n = b2;
    while (--e) n *= b2;
    return n;
  }
  function toLessThanHalfPi(Ctor, x) {
    var t2, isNeg = x.s < 0, pi = getPi(Ctor, Ctor.precision, 1), halfPi = pi.times(0.5);
    x = x.abs();
    if (x.lte(halfPi)) {
      quadrant = isNeg ? 4 : 1;
      return x;
    }
    t2 = x.divToInt(pi);
    if (t2.isZero()) {
      quadrant = isNeg ? 3 : 2;
    } else {
      x = x.minus(t2.times(pi));
      if (x.lte(halfPi)) {
        quadrant = isOdd(t2) ? isNeg ? 2 : 3 : isNeg ? 4 : 1;
        return x;
      }
      quadrant = isOdd(t2) ? isNeg ? 1 : 4 : isNeg ? 3 : 2;
    }
    return x.minus(pi).abs();
  }
  function toStringBinary(x, baseOut, sd, rm) {
    var base2, e, i2, k, len, roundUp, str, xd, y, Ctor = x.constructor, isExp = sd !== void 0;
    if (isExp) {
      checkInt32(sd, 1, MAX_DIGITS);
      if (rm === void 0) rm = Ctor.rounding;
      else checkInt32(rm, 0, 8);
    } else {
      sd = Ctor.precision;
      rm = Ctor.rounding;
    }
    if (!x.isFinite()) {
      str = nonFiniteToString(x);
    } else {
      str = finiteToString(x);
      i2 = str.indexOf(".");
      if (isExp) {
        base2 = 2;
        if (baseOut == 16) {
          sd = sd * 4 - 3;
        } else if (baseOut == 8) {
          sd = sd * 3 - 2;
        }
      } else {
        base2 = baseOut;
      }
      if (i2 >= 0) {
        str = str.replace(".", "");
        y = new Ctor(1);
        y.e = str.length - i2;
        y.d = convertBase(finiteToString(y), 10, base2);
        y.e = y.d.length;
      }
      xd = convertBase(str, 10, base2);
      e = len = xd.length;
      for (; xd[--len] == 0; ) xd.pop();
      if (!xd[0]) {
        str = isExp ? "0p+0" : "0";
      } else {
        if (i2 < 0) {
          e--;
        } else {
          x = new Ctor(x);
          x.d = xd;
          x.e = e;
          x = divide(x, y, sd, rm, 0, base2);
          xd = x.d;
          e = x.e;
          roundUp = inexact;
        }
        i2 = xd[sd];
        k = base2 / 2;
        roundUp = roundUp || xd[sd + 1] !== void 0;
        roundUp = rm < 4 ? (i2 !== void 0 || roundUp) && (rm === 0 || rm === (x.s < 0 ? 3 : 2)) : i2 > k || i2 === k && (rm === 4 || roundUp || rm === 6 && xd[sd - 1] & 1 || rm === (x.s < 0 ? 8 : 7));
        xd.length = sd;
        if (roundUp) {
          for (; ++xd[--sd] > base2 - 1; ) {
            xd[sd] = 0;
            if (!sd) {
              ++e;
              xd.unshift(1);
            }
          }
        }
        for (len = xd.length; !xd[len - 1]; --len) ;
        for (i2 = 0, str = ""; i2 < len; i2++) str += NUMERALS.charAt(xd[i2]);
        if (isExp) {
          if (len > 1) {
            if (baseOut == 16 || baseOut == 8) {
              i2 = baseOut == 16 ? 4 : 3;
              for (--len; len % i2; len++) str += "0";
              xd = convertBase(str, base2, baseOut);
              for (len = xd.length; !xd[len - 1]; --len) ;
              for (i2 = 1, str = "1."; i2 < len; i2++) str += NUMERALS.charAt(xd[i2]);
            } else {
              str = str.charAt(0) + "." + str.slice(1);
            }
          }
          str = str + (e < 0 ? "p" : "p+") + e;
        } else if (e < 0) {
          for (; ++e; ) str = "0" + str;
          str = "0." + str;
        } else {
          if (++e > len) for (e -= len; e--; ) str += "0";
          else if (e < len) str = str.slice(0, e) + "." + str.slice(e);
        }
      }
      str = (baseOut == 16 ? "0x" : baseOut == 2 ? "0b" : baseOut == 8 ? "0o" : "") + str;
    }
    return x.s < 0 ? "-" + str : str;
  }
  function truncate(arr, len) {
    if (arr.length > len) {
      arr.length = len;
      return true;
    }
  }
  function abs2(x) {
    return new this(x).abs();
  }
  function acos2(x) {
    return new this(x).acos();
  }
  function acosh(x) {
    return new this(x).acosh();
  }
  function add2(x, y) {
    return new this(x).plus(y);
  }
  function asin2(x) {
    return new this(x).asin();
  }
  function asinh(x) {
    return new this(x).asinh();
  }
  function atan3(x) {
    return new this(x).atan();
  }
  function atanh(x) {
    return new this(x).atanh();
  }
  function atan22(y, x) {
    y = new this(y);
    x = new this(x);
    var r, pr = this.precision, rm = this.rounding, wpr = pr + 4;
    if (!y.s || !x.s) {
      r = new this(NaN);
    } else if (!y.d && !x.d) {
      r = getPi(this, wpr, 1).times(x.s > 0 ? 0.25 : 0.75);
      r.s = y.s;
    } else if (!x.d || y.isZero()) {
      r = x.s < 0 ? getPi(this, pr, rm) : new this(0);
      r.s = y.s;
    } else if (!y.d || x.isZero()) {
      r = getPi(this, wpr, 1).times(0.5);
      r.s = y.s;
    } else if (x.s < 0) {
      this.precision = wpr;
      this.rounding = 1;
      r = this.atan(divide(y, x, wpr, 1));
      x = getPi(this, wpr, 1);
      this.precision = pr;
      this.rounding = rm;
      r = y.s < 0 ? r.minus(x) : r.plus(x);
    } else {
      r = this.atan(divide(y, x, wpr, 1));
    }
    return r;
  }
  function cbrt(x) {
    return new this(x).cbrt();
  }
  function ceil2(x) {
    return finalise(x = new this(x), x.e + 1, 2);
  }
  function clamp(x, min7, max8) {
    return new this(x).clamp(min7, max8);
  }
  function config(obj) {
    if (!obj || typeof obj !== "object") throw Error(decimalError + "Object expected");
    var i2, p2, v2, useDefaults = obj.defaults === true, ps = [
      "precision",
      1,
      MAX_DIGITS,
      "rounding",
      0,
      8,
      "toExpNeg",
      -EXP_LIMIT,
      0,
      "toExpPos",
      0,
      EXP_LIMIT,
      "maxE",
      0,
      EXP_LIMIT,
      "minE",
      -EXP_LIMIT,
      0,
      "modulo",
      0,
      9
    ];
    for (i2 = 0; i2 < ps.length; i2 += 3) {
      if (p2 = ps[i2], useDefaults) this[p2] = DEFAULTS[p2];
      if ((v2 = obj[p2]) !== void 0) {
        if (mathfloor(v2) === v2 && v2 >= ps[i2 + 1] && v2 <= ps[i2 + 2]) this[p2] = v2;
        else throw Error(invalidArgument + p2 + ": " + v2);
      }
    }
    if (p2 = "crypto", useDefaults) this[p2] = DEFAULTS[p2];
    if ((v2 = obj[p2]) !== void 0) {
      if (v2 === true || v2 === false || v2 === 0 || v2 === 1) {
        if (v2) {
          if (typeof crypto != "undefined" && crypto && (crypto.getRandomValues || crypto.randomBytes)) {
            this[p2] = true;
          } else {
            throw Error(cryptoUnavailable);
          }
        } else {
          this[p2] = false;
        }
      } else {
        throw Error(invalidArgument + p2 + ": " + v2);
      }
    }
    return this;
  }
  function cos2(x) {
    return new this(x).cos();
  }
  function cosh(x) {
    return new this(x).cosh();
  }
  function clone(obj) {
    var i2, p2, ps;
    function Decimal2(v2) {
      var e, i3, t2, x = this;
      if (!(x instanceof Decimal2)) return new Decimal2(v2);
      x.constructor = Decimal2;
      if (isDecimalInstance(v2)) {
        x.s = v2.s;
        if (external) {
          if (!v2.d || v2.e > Decimal2.maxE) {
            x.e = NaN;
            x.d = null;
          } else if (v2.e < Decimal2.minE) {
            x.e = 0;
            x.d = [0];
          } else {
            x.e = v2.e;
            x.d = v2.d.slice();
          }
        } else {
          x.e = v2.e;
          x.d = v2.d ? v2.d.slice() : v2.d;
        }
        return;
      }
      t2 = typeof v2;
      if (t2 === "number") {
        if (v2 === 0) {
          x.s = 1 / v2 < 0 ? -1 : 1;
          x.e = 0;
          x.d = [0];
          return;
        }
        if (v2 < 0) {
          v2 = -v2;
          x.s = -1;
        } else {
          x.s = 1;
        }
        if (v2 === ~~v2 && v2 < 1e7) {
          for (e = 0, i3 = v2; i3 >= 10; i3 /= 10) e++;
          if (external) {
            if (e > Decimal2.maxE) {
              x.e = NaN;
              x.d = null;
            } else if (e < Decimal2.minE) {
              x.e = 0;
              x.d = [0];
            } else {
              x.e = e;
              x.d = [v2];
            }
          } else {
            x.e = e;
            x.d = [v2];
          }
          return;
        }
        if (v2 * 0 !== 0) {
          if (!v2) x.s = NaN;
          x.e = NaN;
          x.d = null;
          return;
        }
        return parseDecimal(x, v2.toString());
      }
      if (t2 === "string") {
        if ((i3 = v2.charCodeAt(0)) === 45) {
          v2 = v2.slice(1);
          x.s = -1;
        } else {
          if (i3 === 43) v2 = v2.slice(1);
          x.s = 1;
        }
        return isDecimal.test(v2) ? parseDecimal(x, v2) : parseOther(x, v2);
      }
      if (t2 === "bigint") {
        if (v2 < 0) {
          v2 = -v2;
          x.s = -1;
        } else {
          x.s = 1;
        }
        return parseDecimal(x, v2.toString());
      }
      throw Error(invalidArgument + v2);
    }
    Decimal2.prototype = P;
    Decimal2.ROUND_UP = 0;
    Decimal2.ROUND_DOWN = 1;
    Decimal2.ROUND_CEIL = 2;
    Decimal2.ROUND_FLOOR = 3;
    Decimal2.ROUND_HALF_UP = 4;
    Decimal2.ROUND_HALF_DOWN = 5;
    Decimal2.ROUND_HALF_EVEN = 6;
    Decimal2.ROUND_HALF_CEIL = 7;
    Decimal2.ROUND_HALF_FLOOR = 8;
    Decimal2.EUCLID = 9;
    Decimal2.config = Decimal2.set = config;
    Decimal2.clone = clone;
    Decimal2.isDecimal = isDecimalInstance;
    Decimal2.abs = abs2;
    Decimal2.acos = acos2;
    Decimal2.acosh = acosh;
    Decimal2.add = add2;
    Decimal2.asin = asin2;
    Decimal2.asinh = asinh;
    Decimal2.atan = atan3;
    Decimal2.atanh = atanh;
    Decimal2.atan2 = atan22;
    Decimal2.cbrt = cbrt;
    Decimal2.ceil = ceil2;
    Decimal2.clamp = clamp;
    Decimal2.cos = cos2;
    Decimal2.cosh = cosh;
    Decimal2.div = div3;
    Decimal2.exp = exp2;
    Decimal2.floor = floor2;
    Decimal2.hypot = hypot;
    Decimal2.ln = ln;
    Decimal2.log = log2;
    Decimal2.log10 = log10;
    Decimal2.log2 = log22;
    Decimal2.max = max3;
    Decimal2.min = min3;
    Decimal2.mod = mod2;
    Decimal2.mul = mul2;
    Decimal2.pow = pow3;
    Decimal2.random = random;
    Decimal2.round = round2;
    Decimal2.sign = sign2;
    Decimal2.sin = sin2;
    Decimal2.sinh = sinh;
    Decimal2.sqrt = sqrt2;
    Decimal2.sub = sub2;
    Decimal2.sum = sum2;
    Decimal2.tan = tan2;
    Decimal2.tanh = tanh;
    Decimal2.trunc = trunc2;
    if (obj === void 0) obj = {};
    if (obj) {
      if (obj.defaults !== true) {
        ps = ["precision", "rounding", "toExpNeg", "toExpPos", "maxE", "minE", "modulo", "crypto"];
        for (i2 = 0; i2 < ps.length; ) if (!obj.hasOwnProperty(p2 = ps[i2++])) obj[p2] = this[p2];
      }
    }
    Decimal2.config(obj);
    return Decimal2;
  }
  function div3(x, y) {
    return new this(x).div(y);
  }
  function exp2(x) {
    return new this(x).exp();
  }
  function floor2(x) {
    return finalise(x = new this(x), x.e + 1, 3);
  }
  function hypot() {
    var i2, n, t2 = new this(0);
    external = false;
    for (i2 = 0; i2 < arguments.length; ) {
      n = new this(arguments[i2++]);
      if (!n.d) {
        if (n.s) {
          external = true;
          return new this(1 / 0);
        }
        t2 = n;
      } else if (t2.d) {
        t2 = t2.plus(n.times(n));
      }
    }
    external = true;
    return t2.sqrt();
  }
  function isDecimalInstance(obj) {
    return obj instanceof Decimal || obj && obj.toStringTag === tag || false;
  }
  function ln(x) {
    return new this(x).ln();
  }
  function log2(x, y) {
    return new this(x).log(y);
  }
  function log22(x) {
    return new this(x).log(2);
  }
  function log10(x) {
    return new this(x).log(10);
  }
  function max3() {
    return maxOrMin(this, arguments, -1);
  }
  function min3() {
    return maxOrMin(this, arguments, 1);
  }
  function mod2(x, y) {
    return new this(x).mod(y);
  }
  function mul2(x, y) {
    return new this(x).mul(y);
  }
  function pow3(x, y) {
    return new this(x).pow(y);
  }
  function random(sd) {
    var d, e, k, n, i2 = 0, r = new this(1), rd = [];
    if (sd === void 0) sd = this.precision;
    else checkInt32(sd, 1, MAX_DIGITS);
    k = Math.ceil(sd / LOG_BASE);
    if (!this.crypto) {
      for (; i2 < k; ) rd[i2++] = Math.random() * 1e7 | 0;
    } else if (crypto.getRandomValues) {
      d = crypto.getRandomValues(new Uint32Array(k));
      for (; i2 < k; ) {
        n = d[i2];
        if (n >= 429e7) {
          d[i2] = crypto.getRandomValues(new Uint32Array(1))[0];
        } else {
          rd[i2++] = n % 1e7;
        }
      }
    } else if (crypto.randomBytes) {
      d = crypto.randomBytes(k *= 4);
      for (; i2 < k; ) {
        n = d[i2] + (d[i2 + 1] << 8) + (d[i2 + 2] << 16) + ((d[i2 + 3] & 127) << 24);
        if (n >= 214e7) {
          crypto.randomBytes(4).copy(d, i2);
        } else {
          rd.push(n % 1e7);
          i2 += 4;
        }
      }
      i2 = k / 4;
    } else {
      throw Error(cryptoUnavailable);
    }
    k = rd[--i2];
    sd %= LOG_BASE;
    if (k && sd) {
      n = mathpow(10, LOG_BASE - sd);
      rd[i2] = (k / n | 0) * n;
    }
    for (; rd[i2] === 0; i2--) rd.pop();
    if (i2 < 0) {
      e = 0;
      rd = [0];
    } else {
      e = -1;
      for (; rd[0] === 0; e -= LOG_BASE) rd.shift();
      for (k = 1, n = rd[0]; n >= 10; n /= 10) k++;
      if (k < LOG_BASE) e -= LOG_BASE - k;
    }
    r.e = e;
    r.d = rd;
    return r;
  }
  function round2(x) {
    return finalise(x = new this(x), x.e + 1, this.rounding);
  }
  function sign2(x) {
    x = new this(x);
    return x.d ? x.d[0] ? x.s : 0 * x.s : x.s || NaN;
  }
  function sin2(x) {
    return new this(x).sin();
  }
  function sinh(x) {
    return new this(x).sinh();
  }
  function sqrt2(x) {
    return new this(x).sqrt();
  }
  function sub2(x, y) {
    return new this(x).sub(y);
  }
  function sum2() {
    var i2 = 0, args = arguments, x = new this(args[i2]);
    external = false;
    for (; x.s && ++i2 < args.length; ) x = x.plus(args[i2]);
    external = true;
    return finalise(x, this.precision, this.rounding);
  }
  function tan2(x) {
    return new this(x).tan();
  }
  function tanh(x) {
    return new this(x).tanh();
  }
  function trunc2(x) {
    return finalise(x = new this(x), x.e + 1, 1);
  }
  P[Symbol.for("nodejs.util.inspect.custom")] = P.toString;
  P[Symbol.toStringTag] = "Decimal";
  var Decimal = P.constructor = clone(DEFAULTS);
  LN10 = new Decimal(LN10);
  PI = new Decimal(PI);
  var decimal_default = Decimal;

  // output/Decimal/foreign.js
  decimal_default.set({
    precision: 20,
    // 20 significant digits
    rounding: decimal_default.ROUND_HALF_UP,
    // Standard rounding (0.5 rounds up)
    toExpNeg: -7,
    // No exponential notation for small numbers
    toExpPos: 20,
    // No exponential notation for large numbers
    minE: -9e15,
    maxE: 9e15
  });
  var fromStringImpl2 = function(str) {
    try {
      const d = new decimal_default(str);
      if (d.isNaN()) {
        return null;
      }
      return d;
    } catch (e) {
      return null;
    }
  };
  var fromInt = function(n) {
    return new decimal_default(n);
  };
  var unsafeFromString = function(str) {
    return new decimal_default(str);
  };
  var toString = function(d) {
    return d.toString();
  };
  var add3 = function(a3) {
    return function(b2) {
      return a3.plus(b2);
    };
  };
  var multiply = function(a3) {
    return function(b2) {
      return a3.times(b2);
    };
  };
  var negate2 = function(d) {
    return d.negated();
  };
  var abs3 = function(d) {
    return d.abs();
  };
  var _compare = function(a3) {
    return function(b2) {
      return a3.comparedTo(b2);
    };
  };
  var lte = function(a3) {
    return function(b2) {
      return a3.lessThanOrEqualTo(b2);
    };
  };
  var gt = function(a3) {
    return function(b2) {
      return a3.greaterThan(b2);
    };
  };
  var gte = function(a3) {
    return function(b2) {
      return a3.greaterThanOrEqualTo(b2);
    };
  };
  var isNegative = function(d) {
    return d.isNegative();
  };
  var isPositive = function(d) {
    return d.isPositive();
  };

  // output/Data.Argonaut.Core/foreign.js
  function id3(x) {
    return x;
  }
  function stringify(j) {
    return JSON.stringify(j);
  }
  function _caseJson(isNull3, isBool, isNum, isStr, isArr, isObj, j) {
    if (j == null) return isNull3();
    else if (typeof j === "boolean") return isBool(j);
    else if (typeof j === "number") return isNum(j);
    else if (typeof j === "string") return isStr(j);
    else if (Object.prototype.toString.call(j) === "[object Array]")
      return isArr(j);
    else return isObj(j);
  }

  // output/Data.Argonaut.Core/index.js
  var verbJsonType = function(def) {
    return function(f) {
      return function(g) {
        return g(def)(f);
      };
    };
  };
  var toJsonType = /* @__PURE__ */ (function() {
    return verbJsonType(Nothing.value)(Just.create);
  })();
  var jsonEmptyObject = /* @__PURE__ */ id3(empty2);
  var isJsonType = /* @__PURE__ */ verbJsonType(false)(/* @__PURE__ */ $$const(true));
  var caseJsonString = function(d) {
    return function(f) {
      return function(j) {
        return _caseJson($$const(d), $$const(d), $$const(d), f, $$const(d), $$const(d), j);
      };
    };
  };
  var caseJsonObject = function(d) {
    return function(f) {
      return function(j) {
        return _caseJson($$const(d), $$const(d), $$const(d), $$const(d), $$const(d), f, j);
      };
    };
  };
  var toObject = /* @__PURE__ */ toJsonType(caseJsonObject);
  var caseJsonNumber = function(d) {
    return function(f) {
      return function(j) {
        return _caseJson($$const(d), $$const(d), f, $$const(d), $$const(d), $$const(d), j);
      };
    };
  };
  var caseJsonNull = function(d) {
    return function(f) {
      return function(j) {
        return _caseJson(f, $$const(d), $$const(d), $$const(d), $$const(d), $$const(d), j);
      };
    };
  };
  var isNull2 = /* @__PURE__ */ isJsonType(caseJsonNull);
  var caseJsonArray = function(d) {
    return function(f) {
      return function(j) {
        return _caseJson($$const(d), $$const(d), $$const(d), $$const(d), f, $$const(d), j);
      };
    };
  };
  var toArray = /* @__PURE__ */ toJsonType(caseJsonArray);

  // output/Data.Argonaut.Decode.Error/index.js
  var show4 = /* @__PURE__ */ show(showString);
  var show12 = /* @__PURE__ */ show(showInt);
  var TypeMismatch2 = /* @__PURE__ */ (function() {
    function TypeMismatch3(value0) {
      this.value0 = value0;
    }
    ;
    TypeMismatch3.create = function(value0) {
      return new TypeMismatch3(value0);
    };
    return TypeMismatch3;
  })();
  var UnexpectedValue = /* @__PURE__ */ (function() {
    function UnexpectedValue2(value0) {
      this.value0 = value0;
    }
    ;
    UnexpectedValue2.create = function(value0) {
      return new UnexpectedValue2(value0);
    };
    return UnexpectedValue2;
  })();
  var AtIndex = /* @__PURE__ */ (function() {
    function AtIndex2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    AtIndex2.create = function(value0) {
      return function(value1) {
        return new AtIndex2(value0, value1);
      };
    };
    return AtIndex2;
  })();
  var AtKey = /* @__PURE__ */ (function() {
    function AtKey2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    AtKey2.create = function(value0) {
      return function(value1) {
        return new AtKey2(value0, value1);
      };
    };
    return AtKey2;
  })();
  var Named2 = /* @__PURE__ */ (function() {
    function Named3(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Named3.create = function(value0) {
      return function(value1) {
        return new Named3(value0, value1);
      };
    };
    return Named3;
  })();
  var MissingValue = /* @__PURE__ */ (function() {
    function MissingValue2() {
    }
    ;
    MissingValue2.value = new MissingValue2();
    return MissingValue2;
  })();
  var showJsonDecodeError = {
    show: function(v2) {
      if (v2 instanceof TypeMismatch2) {
        return "(TypeMismatch " + (show4(v2.value0) + ")");
      }
      ;
      if (v2 instanceof UnexpectedValue) {
        return "(UnexpectedValue " + (stringify(v2.value0) + ")");
      }
      ;
      if (v2 instanceof AtIndex) {
        return "(AtIndex " + (show12(v2.value0) + (" " + (show(showJsonDecodeError)(v2.value1) + ")")));
      }
      ;
      if (v2 instanceof AtKey) {
        return "(AtKey " + (show4(v2.value0) + (" " + (show(showJsonDecodeError)(v2.value1) + ")")));
      }
      ;
      if (v2 instanceof Named2) {
        return "(Named " + (show4(v2.value0) + (" " + (show(showJsonDecodeError)(v2.value1) + ")")));
      }
      ;
      if (v2 instanceof MissingValue) {
        return "MissingValue";
      }
      ;
      throw new Error("Failed pattern match at Data.Argonaut.Decode.Error (line 24, column 10 - line 30, column 35): " + [v2.constructor.name]);
    }
  };
  var printJsonDecodeError = function(err) {
    var go2 = function(v2) {
      if (v2 instanceof TypeMismatch2) {
        return "  Expected value of type '" + (v2.value0 + "'.");
      }
      ;
      if (v2 instanceof UnexpectedValue) {
        return "  Unexpected value " + (stringify(v2.value0) + ".");
      }
      ;
      if (v2 instanceof AtIndex) {
        return "  At array index " + (show12(v2.value0) + (":\n" + go2(v2.value1)));
      }
      ;
      if (v2 instanceof AtKey) {
        return "  At object key '" + (v2.value0 + ("':\n" + go2(v2.value1)));
      }
      ;
      if (v2 instanceof Named2) {
        return "  Under '" + (v2.value0 + ("':\n" + go2(v2.value1)));
      }
      ;
      if (v2 instanceof MissingValue) {
        return "  No value was found.";
      }
      ;
      throw new Error("Failed pattern match at Data.Argonaut.Decode.Error (line 37, column 8 - line 43, column 44): " + [v2.constructor.name]);
    };
    return "An error occurred while decoding a JSON value:\n" + go2(err);
  };

  // output/Data.Map.Internal/index.js
  var $runtime_lazy5 = function(name16, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name16 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var map14 = /* @__PURE__ */ map(functorMaybe);
  var Leaf = /* @__PURE__ */ (function() {
    function Leaf2() {
    }
    ;
    Leaf2.value = new Leaf2();
    return Leaf2;
  })();
  var Node = /* @__PURE__ */ (function() {
    function Node2(value0, value1, value22, value32, value42, value52) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
      this.value3 = value32;
      this.value4 = value42;
      this.value5 = value52;
    }
    ;
    Node2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return function(value32) {
            return function(value42) {
              return function(value52) {
                return new Node2(value0, value1, value22, value32, value42, value52);
              };
            };
          };
        };
      };
    };
    return Node2;
  })();
  var Split = /* @__PURE__ */ (function() {
    function Split2(value0, value1, value22) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
    }
    ;
    Split2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return new Split2(value0, value1, value22);
        };
      };
    };
    return Split2;
  })();
  var SplitLast = /* @__PURE__ */ (function() {
    function SplitLast2(value0, value1, value22) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
    }
    ;
    SplitLast2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return new SplitLast2(value0, value1, value22);
        };
      };
    };
    return SplitLast2;
  })();
  var unsafeNode = function(k, v2, l2, r) {
    if (l2 instanceof Leaf) {
      if (r instanceof Leaf) {
        return new Node(1, 1, k, v2, l2, r);
      }
      ;
      if (r instanceof Node) {
        return new Node(1 + r.value0 | 0, 1 + r.value1 | 0, k, v2, l2, r);
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 702, column 5 - line 706, column 39): " + [r.constructor.name]);
    }
    ;
    if (l2 instanceof Node) {
      if (r instanceof Leaf) {
        return new Node(1 + l2.value0 | 0, 1 + l2.value1 | 0, k, v2, l2, r);
      }
      ;
      if (r instanceof Node) {
        return new Node(1 + (function() {
          var $280 = l2.value0 > r.value0;
          if ($280) {
            return l2.value0;
          }
          ;
          return r.value0;
        })() | 0, (1 + l2.value1 | 0) + r.value1 | 0, k, v2, l2, r);
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 708, column 5 - line 712, column 68): " + [r.constructor.name]);
    }
    ;
    throw new Error("Failed pattern match at Data.Map.Internal (line 700, column 32 - line 712, column 68): " + [l2.constructor.name]);
  };
  var singleton7 = function(k) {
    return function(v2) {
      return new Node(1, 1, k, v2, Leaf.value, Leaf.value);
    };
  };
  var unsafeBalancedNode = /* @__PURE__ */ (function() {
    var height9 = function(v2) {
      if (v2 instanceof Leaf) {
        return 0;
      }
      ;
      if (v2 instanceof Node) {
        return v2.value0;
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 757, column 12 - line 759, column 26): " + [v2.constructor.name]);
    };
    var rotateLeft = function(k, v2, l2, rk, rv, rl, rr) {
      if (rl instanceof Node && rl.value0 > height9(rr)) {
        return unsafeNode(rl.value2, rl.value3, unsafeNode(k, v2, l2, rl.value4), unsafeNode(rk, rv, rl.value5, rr));
      }
      ;
      return unsafeNode(rk, rv, unsafeNode(k, v2, l2, rl), rr);
    };
    var rotateRight = function(k, v2, lk, lv, ll, lr, r) {
      if (lr instanceof Node && height9(ll) <= lr.value0) {
        return unsafeNode(lr.value2, lr.value3, unsafeNode(lk, lv, ll, lr.value4), unsafeNode(k, v2, lr.value5, r));
      }
      ;
      return unsafeNode(lk, lv, ll, unsafeNode(k, v2, lr, r));
    };
    return function(k, v2, l2, r) {
      if (l2 instanceof Leaf) {
        if (r instanceof Leaf) {
          return singleton7(k)(v2);
        }
        ;
        if (r instanceof Node && r.value0 > 1) {
          return rotateLeft(k, v2, l2, r.value2, r.value3, r.value4, r.value5);
        }
        ;
        return unsafeNode(k, v2, l2, r);
      }
      ;
      if (l2 instanceof Node) {
        if (r instanceof Node) {
          if (r.value0 > (l2.value0 + 1 | 0)) {
            return rotateLeft(k, v2, l2, r.value2, r.value3, r.value4, r.value5);
          }
          ;
          if (l2.value0 > (r.value0 + 1 | 0)) {
            return rotateRight(k, v2, l2.value2, l2.value3, l2.value4, l2.value5, r);
          }
          ;
        }
        ;
        if (r instanceof Leaf && l2.value0 > 1) {
          return rotateRight(k, v2, l2.value2, l2.value3, l2.value4, l2.value5, r);
        }
        ;
        return unsafeNode(k, v2, l2, r);
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 717, column 40 - line 738, column 34): " + [l2.constructor.name]);
    };
  })();
  var $lazy_unsafeSplit = /* @__PURE__ */ $runtime_lazy5("unsafeSplit", "Data.Map.Internal", function() {
    return function(comp, k, m2) {
      if (m2 instanceof Leaf) {
        return new Split(Nothing.value, Leaf.value, Leaf.value);
      }
      ;
      if (m2 instanceof Node) {
        var v2 = comp(k)(m2.value2);
        if (v2 instanceof LT) {
          var v1 = $lazy_unsafeSplit(793)(comp, k, m2.value4);
          return new Split(v1.value0, v1.value1, unsafeBalancedNode(m2.value2, m2.value3, v1.value2, m2.value5));
        }
        ;
        if (v2 instanceof GT) {
          var v1 = $lazy_unsafeSplit(796)(comp, k, m2.value5);
          return new Split(v1.value0, unsafeBalancedNode(m2.value2, m2.value3, m2.value4, v1.value1), v1.value2);
        }
        ;
        if (v2 instanceof EQ) {
          return new Split(new Just(m2.value3), m2.value4, m2.value5);
        }
        ;
        throw new Error("Failed pattern match at Data.Map.Internal (line 791, column 5 - line 799, column 30): " + [v2.constructor.name]);
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 787, column 34 - line 799, column 30): " + [m2.constructor.name]);
    };
  });
  var unsafeSplit = /* @__PURE__ */ $lazy_unsafeSplit(786);
  var $lazy_unsafeSplitLast = /* @__PURE__ */ $runtime_lazy5("unsafeSplitLast", "Data.Map.Internal", function() {
    return function(k, v2, l2, r) {
      if (r instanceof Leaf) {
        return new SplitLast(k, v2, l2);
      }
      ;
      if (r instanceof Node) {
        var v1 = $lazy_unsafeSplitLast(779)(r.value2, r.value3, r.value4, r.value5);
        return new SplitLast(v1.value0, v1.value1, unsafeBalancedNode(k, v2, l2, v1.value2));
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 776, column 37 - line 780, column 57): " + [r.constructor.name]);
    };
  });
  var unsafeSplitLast = /* @__PURE__ */ $lazy_unsafeSplitLast(775);
  var unsafeJoinNodes = function(v2, v1) {
    if (v2 instanceof Leaf) {
      return v1;
    }
    ;
    if (v2 instanceof Node) {
      var v22 = unsafeSplitLast(v2.value2, v2.value3, v2.value4, v2.value5);
      return unsafeBalancedNode(v22.value0, v22.value1, v22.value2, v1);
    }
    ;
    throw new Error("Failed pattern match at Data.Map.Internal (line 764, column 25 - line 768, column 38): " + [v2.constructor.name, v1.constructor.name]);
  };
  var pop = function(dictOrd) {
    var compare4 = compare(dictOrd);
    return function(k) {
      return function(m2) {
        var v2 = unsafeSplit(compare4, k, m2);
        return map14(function(a3) {
          return new Tuple(a3, unsafeJoinNodes(v2.value1, v2.value2));
        })(v2.value0);
      };
    };
  };
  var lookup2 = function(dictOrd) {
    var compare4 = compare(dictOrd);
    return function(k) {
      var go2 = function($copy_v) {
        var $tco_done = false;
        var $tco_result;
        function $tco_loop(v2) {
          if (v2 instanceof Leaf) {
            $tco_done = true;
            return Nothing.value;
          }
          ;
          if (v2 instanceof Node) {
            var v1 = compare4(k)(v2.value2);
            if (v1 instanceof LT) {
              $copy_v = v2.value4;
              return;
            }
            ;
            if (v1 instanceof GT) {
              $copy_v = v2.value5;
              return;
            }
            ;
            if (v1 instanceof EQ) {
              $tco_done = true;
              return new Just(v2.value3);
            }
            ;
            throw new Error("Failed pattern match at Data.Map.Internal (line 283, column 7 - line 286, column 22): " + [v1.constructor.name]);
          }
          ;
          throw new Error("Failed pattern match at Data.Map.Internal (line 280, column 8 - line 286, column 22): " + [v2.constructor.name]);
        }
        ;
        while (!$tco_done) {
          $tco_result = $tco_loop($copy_v);
        }
        ;
        return $tco_result;
      };
      return go2;
    };
  };
  var insert3 = function(dictOrd) {
    var compare4 = compare(dictOrd);
    return function(k) {
      return function(v2) {
        var go2 = function(v1) {
          if (v1 instanceof Leaf) {
            return singleton7(k)(v2);
          }
          ;
          if (v1 instanceof Node) {
            var v22 = compare4(k)(v1.value2);
            if (v22 instanceof LT) {
              return unsafeBalancedNode(v1.value2, v1.value3, go2(v1.value4), v1.value5);
            }
            ;
            if (v22 instanceof GT) {
              return unsafeBalancedNode(v1.value2, v1.value3, v1.value4, go2(v1.value5));
            }
            ;
            if (v22 instanceof EQ) {
              return new Node(v1.value0, v1.value1, k, v2, v1.value4, v1.value5);
            }
            ;
            throw new Error("Failed pattern match at Data.Map.Internal (line 471, column 7 - line 474, column 35): " + [v22.constructor.name]);
          }
          ;
          throw new Error("Failed pattern match at Data.Map.Internal (line 468, column 8 - line 474, column 35): " + [v1.constructor.name]);
        };
        return go2;
      };
    };
  };
  var foldableMap = {
    foldr: function(f) {
      return function(z2) {
        var $lazy_go = $runtime_lazy5("go", "Data.Map.Internal", function() {
          return function(m$prime, z$prime) {
            if (m$prime instanceof Leaf) {
              return z$prime;
            }
            ;
            if (m$prime instanceof Node) {
              return $lazy_go(172)(m$prime.value4, f(m$prime.value3)($lazy_go(172)(m$prime.value5, z$prime)));
            }
            ;
            throw new Error("Failed pattern match at Data.Map.Internal (line 169, column 26 - line 172, column 43): " + [m$prime.constructor.name]);
          };
        });
        var go2 = $lazy_go(169);
        return function(m2) {
          return go2(m2, z2);
        };
      };
    },
    foldl: function(f) {
      return function(z2) {
        var $lazy_go = $runtime_lazy5("go", "Data.Map.Internal", function() {
          return function(z$prime, m$prime) {
            if (m$prime instanceof Leaf) {
              return z$prime;
            }
            ;
            if (m$prime instanceof Node) {
              return $lazy_go(178)(f($lazy_go(178)(z$prime, m$prime.value4))(m$prime.value3), m$prime.value5);
            }
            ;
            throw new Error("Failed pattern match at Data.Map.Internal (line 175, column 26 - line 178, column 43): " + [m$prime.constructor.name]);
          };
        });
        var go2 = $lazy_go(175);
        return function(m2) {
          return go2(z2, m2);
        };
      };
    },
    foldMap: function(dictMonoid) {
      var mempty3 = mempty(dictMonoid);
      var append12 = append(dictMonoid.Semigroup0());
      return function(f) {
        var go2 = function(v2) {
          if (v2 instanceof Leaf) {
            return mempty3;
          }
          ;
          if (v2 instanceof Node) {
            return append12(go2(v2.value4))(append12(f(v2.value3))(go2(v2.value5)));
          }
          ;
          throw new Error("Failed pattern match at Data.Map.Internal (line 181, column 10 - line 184, column 28): " + [v2.constructor.name]);
        };
        return go2;
      };
    }
  };
  var empty3 = /* @__PURE__ */ (function() {
    return Leaf.value;
  })();
  var $$delete2 = function(dictOrd) {
    var compare4 = compare(dictOrd);
    return function(k) {
      var go2 = function(v2) {
        if (v2 instanceof Leaf) {
          return Leaf.value;
        }
        ;
        if (v2 instanceof Node) {
          var v1 = compare4(k)(v2.value2);
          if (v1 instanceof LT) {
            return unsafeBalancedNode(v2.value2, v2.value3, go2(v2.value4), v2.value5);
          }
          ;
          if (v1 instanceof GT) {
            return unsafeBalancedNode(v2.value2, v2.value3, v2.value4, go2(v2.value5));
          }
          ;
          if (v1 instanceof EQ) {
            return unsafeJoinNodes(v2.value4, v2.value5);
          }
          ;
          throw new Error("Failed pattern match at Data.Map.Internal (line 498, column 7 - line 501, column 43): " + [v1.constructor.name]);
        }
        ;
        throw new Error("Failed pattern match at Data.Map.Internal (line 495, column 8 - line 501, column 43): " + [v2.constructor.name]);
      };
      return go2;
    };
  };
  var alter = function(dictOrd) {
    var compare4 = compare(dictOrd);
    return function(f) {
      return function(k) {
        return function(m2) {
          var v2 = unsafeSplit(compare4, k, m2);
          var v22 = f(v2.value0);
          if (v22 instanceof Nothing) {
            return unsafeJoinNodes(v2.value1, v2.value2);
          }
          ;
          if (v22 instanceof Just) {
            return unsafeBalancedNode(k, v22.value0, v2.value1, v2.value2);
          }
          ;
          throw new Error("Failed pattern match at Data.Map.Internal (line 514, column 3 - line 518, column 41): " + [v22.constructor.name]);
        };
      };
    };
  };

  // output/Data.Argonaut.Decode.Decoders/index.js
  var pure4 = /* @__PURE__ */ pure(applicativeEither);
  var map15 = /* @__PURE__ */ map(functorEither);
  var lmap2 = /* @__PURE__ */ lmap(bifunctorEither);
  var composeKleisliFlipped2 = /* @__PURE__ */ composeKleisliFlipped(bindEither);
  var traverse5 = /* @__PURE__ */ traverse(traversableObject)(applicativeEither);
  var traverseWithIndex2 = /* @__PURE__ */ traverseWithIndex(traversableWithIndexArray)(applicativeEither);
  var getField = function(decoder) {
    return function(obj) {
      return function(str) {
        return maybe(new Left(new AtKey(str, MissingValue.value)))((function() {
          var $48 = lmap2(AtKey.create(str));
          return function($49) {
            return $48(decoder($49));
          };
        })())(lookup(str)(obj));
      };
    };
  };
  var decodeString = /* @__PURE__ */ (function() {
    return caseJsonString(new Left(new TypeMismatch2("String")))(Right.create);
  })();
  var decodeNumber = /* @__PURE__ */ (function() {
    return caseJsonNumber(new Left(new TypeMismatch2("Number")))(Right.create);
  })();
  var decodeMaybe = function(decoder) {
    return function(json3) {
      if (isNull2(json3)) {
        return pure4(Nothing.value);
      }
      ;
      if (otherwise) {
        return map15(Just.create)(decoder(json3));
      }
      ;
      throw new Error("Failed pattern match at Data.Argonaut.Decode.Decoders (line 37, column 1 - line 41, column 38): " + [decoder.constructor.name, json3.constructor.name]);
    };
  };
  var decodeJObject = /* @__PURE__ */ (function() {
    var $50 = note(new TypeMismatch2("Object"));
    return function($51) {
      return $50(toObject($51));
    };
  })();
  var decodeJArray = /* @__PURE__ */ (function() {
    var $52 = note(new TypeMismatch2("Array"));
    return function($53) {
      return $52(toArray($53));
    };
  })();
  var decodeInt = /* @__PURE__ */ composeKleisliFlipped2(/* @__PURE__ */ (function() {
    var $84 = note(new TypeMismatch2("Integer"));
    return function($85) {
      return $84(fromNumber($85));
    };
  })())(decodeNumber);
  var decodeForeignObject = function(decoder) {
    return composeKleisliFlipped2((function() {
      var $86 = lmap2(Named2.create("ForeignObject"));
      var $87 = traverse5(decoder);
      return function($88) {
        return $86($87($88));
      };
    })())(decodeJObject);
  };
  var decodeArray = function(decoder) {
    return composeKleisliFlipped2((function() {
      var $89 = lmap2(Named2.create("Array"));
      var $90 = traverseWithIndex2(function(i2) {
        var $92 = lmap2(AtIndex.create(i2));
        return function($93) {
          return $92(decoder($93));
        };
      });
      return function($91) {
        return $89($90($91));
      };
    })())(decodeJArray);
  };

  // output/Record/index.js
  var get2 = function(dictIsSymbol) {
    var reflectSymbol2 = reflectSymbol(dictIsSymbol);
    return function() {
      return function(l2) {
        return function(r) {
          return unsafeGet(reflectSymbol2(l2))(r);
        };
      };
    };
  };

  // output/Data.Argonaut.Decode.Class/index.js
  var decodeJsonString = {
    decodeJson: decodeString
  };
  var decodeJsonJson = /* @__PURE__ */ (function() {
    return {
      decodeJson: Right.create
    };
  })();
  var decodeJsonInt = {
    decodeJson: decodeInt
  };
  var decodeJson = function(dict) {
    return dict.decodeJson;
  };
  var decodeJsonMaybe = function(dictDecodeJson) {
    return {
      decodeJson: decodeMaybe(decodeJson(dictDecodeJson))
    };
  };
  var decodeForeignObject2 = function(dictDecodeJson) {
    return {
      decodeJson: decodeForeignObject(decodeJson(dictDecodeJson))
    };
  };
  var decodeArray2 = function(dictDecodeJson) {
    return {
      decodeJson: decodeArray(decodeJson(dictDecodeJson))
    };
  };

  // output/Data.Argonaut.Encode.Encoders/index.js
  var encodeString = id3;

  // output/Data.Argonaut.Encode.Class/index.js
  var gEncodeJsonNil = {
    gEncodeJson: function(v2) {
      return function(v1) {
        return empty2;
      };
    }
  };
  var gEncodeJson = function(dict) {
    return dict.gEncodeJson;
  };
  var encodeRecord = function(dictGEncodeJson) {
    var gEncodeJson1 = gEncodeJson(dictGEncodeJson);
    return function() {
      return {
        encodeJson: function(rec) {
          return id3(gEncodeJson1(rec)($$Proxy.value));
        }
      };
    };
  };
  var encodeJsonJString = {
    encodeJson: encodeString
  };
  var encodeJson = function(dict) {
    return dict.encodeJson;
  };
  var gEncodeJsonCons = function(dictEncodeJson) {
    var encodeJson12 = encodeJson(dictEncodeJson);
    return function(dictGEncodeJson) {
      var gEncodeJson1 = gEncodeJson(dictGEncodeJson);
      return function(dictIsSymbol) {
        var reflectSymbol2 = reflectSymbol(dictIsSymbol);
        var get7 = get2(dictIsSymbol)();
        return function() {
          return {
            gEncodeJson: function(row) {
              return function(v2) {
                return insert(reflectSymbol2($$Proxy.value))(encodeJson12(get7($$Proxy.value)(row)))(gEncodeJson1(row)($$Proxy.value));
              };
            }
          };
        };
      };
    };
  };

  // output/Decimal/index.js
  var bind2 = /* @__PURE__ */ bind(bindEither);
  var decodeJson2 = /* @__PURE__ */ decodeJson(decodeJsonString);
  var zero2 = /* @__PURE__ */ fromInt(0);
  var fromString2 = function($10) {
    return toMaybe(fromStringImpl2($10));
  };
  var decodeJsonDecimal = {
    decodeJson: function(json3) {
      return bind2(decodeJson2(json3))(function(str) {
        var v2 = fromString2(str);
        if (v2 instanceof Nothing) {
          return new Left(new TypeMismatch2("Invalid decimal string"));
        }
        ;
        if (v2 instanceof Just) {
          return new Right(v2.value0);
        }
        ;
        throw new Error("Failed pattern match at Decimal (line 111, column 5 - line 113, column 24): " + [v2.constructor.name]);
      });
    }
  };
  var compare2 = function(a3) {
    return function(b2) {
      var v2 = _compare(a3)(b2);
      if (v2 === -1) {
        return LT.value;
      }
      ;
      if (v2 === 0) {
        return EQ.value;
      }
      ;
      if (v2 === 1) {
        return GT.value;
      }
      ;
      return EQ.value;
    };
  };

  // output/Effect.Aff.Class/index.js
  var monadAffAff = {
    liftAff: /* @__PURE__ */ identity(categoryFn),
    MonadEffect0: function() {
      return monadEffectAff;
    }
  };
  var liftAff = function(dict) {
    return dict.liftAff;
  };

  // output/Data.Exists/index.js
  var runExists = unsafeCoerce2;
  var mkExists = unsafeCoerce2;

  // output/Data.Coyoneda/index.js
  var CoyonedaF = /* @__PURE__ */ (function() {
    function CoyonedaF2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    CoyonedaF2.create = function(value0) {
      return function(value1) {
        return new CoyonedaF2(value0, value1);
      };
    };
    return CoyonedaF2;
  })();
  var unCoyoneda = function(f) {
    return function(v2) {
      return runExists(function(v1) {
        return f(v1.value0)(v1.value1);
      })(v2);
    };
  };
  var coyoneda = function(k) {
    return function(fi) {
      return mkExists(new CoyonedaF(k, fi));
    };
  };
  var functorCoyoneda = {
    map: function(f) {
      return function(v2) {
        return runExists(function(v1) {
          return coyoneda(function($180) {
            return f(v1.value0($180));
          })(v1.value1);
        })(v2);
      };
    }
  };
  var liftCoyoneda = /* @__PURE__ */ coyoneda(/* @__PURE__ */ identity(categoryFn));

  // output/Halogen.Data.OrdBox/index.js
  var OrdBox = /* @__PURE__ */ (function() {
    function OrdBox2(value0, value1, value22) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
    }
    ;
    OrdBox2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return new OrdBox2(value0, value1, value22);
        };
      };
    };
    return OrdBox2;
  })();
  var mkOrdBox = function(dictOrd) {
    return OrdBox.create(eq(dictOrd.Eq0()))(compare(dictOrd));
  };
  var eqOrdBox = {
    eq: function(v2) {
      return function(v1) {
        return v2.value0(v2.value2)(v1.value2);
      };
    }
  };
  var ordOrdBox = {
    compare: function(v2) {
      return function(v1) {
        return v2.value1(v2.value2)(v1.value2);
      };
    },
    Eq0: function() {
      return eqOrdBox;
    }
  };

  // output/Halogen.Data.Slot/index.js
  var ordTuple2 = /* @__PURE__ */ ordTuple(ordString)(ordOrdBox);
  var pop1 = /* @__PURE__ */ pop(ordTuple2);
  var lookup1 = /* @__PURE__ */ lookup2(ordTuple2);
  var insert1 = /* @__PURE__ */ insert3(ordTuple2);
  var pop2 = function() {
    return function(dictIsSymbol) {
      var reflectSymbol2 = reflectSymbol(dictIsSymbol);
      return function(dictOrd) {
        var mkOrdBox2 = mkOrdBox(dictOrd);
        return function(sym) {
          return function(key2) {
            return function(v2) {
              return pop1(new Tuple(reflectSymbol2(sym), mkOrdBox2(key2)))(v2);
            };
          };
        };
      };
    };
  };
  var lookup3 = function() {
    return function(dictIsSymbol) {
      var reflectSymbol2 = reflectSymbol(dictIsSymbol);
      return function(dictOrd) {
        var mkOrdBox2 = mkOrdBox(dictOrd);
        return function(sym) {
          return function(key2) {
            return function(v2) {
              return lookup1(new Tuple(reflectSymbol2(sym), mkOrdBox2(key2)))(v2);
            };
          };
        };
      };
    };
  };
  var insert5 = function() {
    return function(dictIsSymbol) {
      var reflectSymbol2 = reflectSymbol(dictIsSymbol);
      return function(dictOrd) {
        var mkOrdBox2 = mkOrdBox(dictOrd);
        return function(sym) {
          return function(key2) {
            return function(val) {
              return function(v2) {
                return insert1(new Tuple(reflectSymbol2(sym), mkOrdBox2(key2)))(val)(v2);
              };
            };
          };
        };
      };
    };
  };
  var foreachSlot = function(dictApplicative) {
    var traverse_7 = traverse_(dictApplicative)(foldableMap);
    return function(v2) {
      return function(k) {
        return traverse_7(function($54) {
          return k($54);
        })(v2);
      };
    };
  };
  var empty4 = empty3;

  // output/Control.Applicative.Free/index.js
  var identity9 = /* @__PURE__ */ identity(categoryFn);
  var Pure = /* @__PURE__ */ (function() {
    function Pure2(value0) {
      this.value0 = value0;
    }
    ;
    Pure2.create = function(value0) {
      return new Pure2(value0);
    };
    return Pure2;
  })();
  var Lift = /* @__PURE__ */ (function() {
    function Lift3(value0) {
      this.value0 = value0;
    }
    ;
    Lift3.create = function(value0) {
      return new Lift3(value0);
    };
    return Lift3;
  })();
  var Ap = /* @__PURE__ */ (function() {
    function Ap2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Ap2.create = function(value0) {
      return function(value1) {
        return new Ap2(value0, value1);
      };
    };
    return Ap2;
  })();
  var mkAp = function(fba) {
    return function(fb) {
      return new Ap(fba, fb);
    };
  };
  var liftFreeAp = /* @__PURE__ */ (function() {
    return Lift.create;
  })();
  var goLeft = function(dictApplicative) {
    var pure18 = pure(dictApplicative);
    return function(fStack) {
      return function(valStack) {
        return function(nat) {
          return function(func) {
            return function(count) {
              if (func instanceof Pure) {
                return new Tuple(new Cons({
                  func: pure18(func.value0),
                  count
                }, fStack), valStack);
              }
              ;
              if (func instanceof Lift) {
                return new Tuple(new Cons({
                  func: nat(func.value0),
                  count
                }, fStack), valStack);
              }
              ;
              if (func instanceof Ap) {
                return goLeft(dictApplicative)(fStack)(cons(func.value1)(valStack))(nat)(func.value0)(count + 1 | 0);
              }
              ;
              throw new Error("Failed pattern match at Control.Applicative.Free (line 102, column 41 - line 105, column 81): " + [func.constructor.name]);
            };
          };
        };
      };
    };
  };
  var goApply = function(dictApplicative) {
    var apply3 = apply(dictApplicative.Apply0());
    return function(fStack) {
      return function(vals) {
        return function(gVal) {
          if (fStack instanceof Nil) {
            return new Left(gVal);
          }
          ;
          if (fStack instanceof Cons) {
            var gRes = apply3(fStack.value0.func)(gVal);
            var $31 = fStack.value0.count === 1;
            if ($31) {
              if (fStack.value1 instanceof Nil) {
                return new Left(gRes);
              }
              ;
              return goApply(dictApplicative)(fStack.value1)(vals)(gRes);
            }
            ;
            if (vals instanceof Nil) {
              return new Left(gRes);
            }
            ;
            if (vals instanceof Cons) {
              return new Right(new Tuple(new Cons({
                func: gRes,
                count: fStack.value0.count - 1 | 0
              }, fStack.value1), new NonEmpty(vals.value0, vals.value1)));
            }
            ;
            throw new Error("Failed pattern match at Control.Applicative.Free (line 83, column 11 - line 88, column 50): " + [vals.constructor.name]);
          }
          ;
          throw new Error("Failed pattern match at Control.Applicative.Free (line 72, column 3 - line 88, column 50): " + [fStack.constructor.name]);
        };
      };
    };
  };
  var functorFreeAp = {
    map: function(f) {
      return function(x) {
        return mkAp(new Pure(f))(x);
      };
    }
  };
  var foldFreeAp = function(dictApplicative) {
    var goApply1 = goApply(dictApplicative);
    var pure18 = pure(dictApplicative);
    var goLeft1 = goLeft(dictApplicative);
    return function(nat) {
      return function(z2) {
        var go2 = function($copy_v) {
          var $tco_done = false;
          var $tco_result;
          function $tco_loop(v2) {
            if (v2.value1.value0 instanceof Pure) {
              var v1 = goApply1(v2.value0)(v2.value1.value1)(pure18(v2.value1.value0.value0));
              if (v1 instanceof Left) {
                $tco_done = true;
                return v1.value0;
              }
              ;
              if (v1 instanceof Right) {
                $copy_v = v1.value0;
                return;
              }
              ;
              throw new Error("Failed pattern match at Control.Applicative.Free (line 54, column 17 - line 56, column 24): " + [v1.constructor.name]);
            }
            ;
            if (v2.value1.value0 instanceof Lift) {
              var v1 = goApply1(v2.value0)(v2.value1.value1)(nat(v2.value1.value0.value0));
              if (v1 instanceof Left) {
                $tco_done = true;
                return v1.value0;
              }
              ;
              if (v1 instanceof Right) {
                $copy_v = v1.value0;
                return;
              }
              ;
              throw new Error("Failed pattern match at Control.Applicative.Free (line 57, column 17 - line 59, column 24): " + [v1.constructor.name]);
            }
            ;
            if (v2.value1.value0 instanceof Ap) {
              var nextVals = new NonEmpty(v2.value1.value0.value1, v2.value1.value1);
              $copy_v = goLeft1(v2.value0)(nextVals)(nat)(v2.value1.value0.value0)(1);
              return;
            }
            ;
            throw new Error("Failed pattern match at Control.Applicative.Free (line 53, column 5 - line 62, column 47): " + [v2.value1.value0.constructor.name]);
          }
          ;
          while (!$tco_done) {
            $tco_result = $tco_loop($copy_v);
          }
          ;
          return $tco_result;
        };
        return go2(new Tuple(Nil.value, singleton4(z2)));
      };
    };
  };
  var retractFreeAp = function(dictApplicative) {
    return foldFreeAp(dictApplicative)(identity9);
  };
  var applyFreeAp = {
    apply: function(fba) {
      return function(fb) {
        return mkAp(fba)(fb);
      };
    },
    Functor0: function() {
      return functorFreeAp;
    }
  };
  var applicativeFreeAp = /* @__PURE__ */ (function() {
    return {
      pure: Pure.create,
      Apply0: function() {
        return applyFreeAp;
      }
    };
  })();
  var foldFreeAp1 = /* @__PURE__ */ foldFreeAp(applicativeFreeAp);
  var hoistFreeAp = function(f) {
    return foldFreeAp1(function($54) {
      return liftFreeAp(f($54));
    });
  };

  // output/Data.CatQueue/index.js
  var CatQueue = /* @__PURE__ */ (function() {
    function CatQueue2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    CatQueue2.create = function(value0) {
      return function(value1) {
        return new CatQueue2(value0, value1);
      };
    };
    return CatQueue2;
  })();
  var uncons4 = function($copy_v) {
    var $tco_done = false;
    var $tco_result;
    function $tco_loop(v2) {
      if (v2.value0 instanceof Nil && v2.value1 instanceof Nil) {
        $tco_done = true;
        return Nothing.value;
      }
      ;
      if (v2.value0 instanceof Nil) {
        $copy_v = new CatQueue(reverse2(v2.value1), Nil.value);
        return;
      }
      ;
      if (v2.value0 instanceof Cons) {
        $tco_done = true;
        return new Just(new Tuple(v2.value0.value0, new CatQueue(v2.value0.value1, v2.value1)));
      }
      ;
      throw new Error("Failed pattern match at Data.CatQueue (line 82, column 1 - line 82, column 63): " + [v2.constructor.name]);
    }
    ;
    while (!$tco_done) {
      $tco_result = $tco_loop($copy_v);
    }
    ;
    return $tco_result;
  };
  var snoc3 = function(v2) {
    return function(a3) {
      return new CatQueue(v2.value0, new Cons(a3, v2.value1));
    };
  };
  var $$null2 = function(v2) {
    if (v2.value0 instanceof Nil && v2.value1 instanceof Nil) {
      return true;
    }
    ;
    return false;
  };
  var empty5 = /* @__PURE__ */ (function() {
    return new CatQueue(Nil.value, Nil.value);
  })();

  // output/Data.CatList/index.js
  var CatNil = /* @__PURE__ */ (function() {
    function CatNil2() {
    }
    ;
    CatNil2.value = new CatNil2();
    return CatNil2;
  })();
  var CatCons = /* @__PURE__ */ (function() {
    function CatCons2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    CatCons2.create = function(value0) {
      return function(value1) {
        return new CatCons2(value0, value1);
      };
    };
    return CatCons2;
  })();
  var link = function(v2) {
    return function(v1) {
      if (v2 instanceof CatNil) {
        return v1;
      }
      ;
      if (v1 instanceof CatNil) {
        return v2;
      }
      ;
      if (v2 instanceof CatCons) {
        return new CatCons(v2.value0, snoc3(v2.value1)(v1));
      }
      ;
      throw new Error("Failed pattern match at Data.CatList (line 108, column 1 - line 108, column 54): " + [v2.constructor.name, v1.constructor.name]);
    };
  };
  var foldr4 = function(k) {
    return function(b2) {
      return function(q3) {
        var foldl3 = function($copy_v) {
          return function($copy_v1) {
            return function($copy_v2) {
              var $tco_var_v = $copy_v;
              var $tco_var_v1 = $copy_v1;
              var $tco_done = false;
              var $tco_result;
              function $tco_loop(v2, v1, v22) {
                if (v22 instanceof Nil) {
                  $tco_done = true;
                  return v1;
                }
                ;
                if (v22 instanceof Cons) {
                  $tco_var_v = v2;
                  $tco_var_v1 = v2(v1)(v22.value0);
                  $copy_v2 = v22.value1;
                  return;
                }
                ;
                throw new Error("Failed pattern match at Data.CatList (line 124, column 3 - line 124, column 59): " + [v2.constructor.name, v1.constructor.name, v22.constructor.name]);
              }
              ;
              while (!$tco_done) {
                $tco_result = $tco_loop($tco_var_v, $tco_var_v1, $copy_v2);
              }
              ;
              return $tco_result;
            };
          };
        };
        var go2 = function($copy_xs) {
          return function($copy_ys) {
            var $tco_var_xs = $copy_xs;
            var $tco_done1 = false;
            var $tco_result;
            function $tco_loop(xs, ys) {
              var v2 = uncons4(xs);
              if (v2 instanceof Nothing) {
                $tco_done1 = true;
                return foldl3(function(x) {
                  return function(i2) {
                    return i2(x);
                  };
                })(b2)(ys);
              }
              ;
              if (v2 instanceof Just) {
                $tco_var_xs = v2.value0.value1;
                $copy_ys = new Cons(k(v2.value0.value0), ys);
                return;
              }
              ;
              throw new Error("Failed pattern match at Data.CatList (line 120, column 14 - line 122, column 67): " + [v2.constructor.name]);
            }
            ;
            while (!$tco_done1) {
              $tco_result = $tco_loop($tco_var_xs, $copy_ys);
            }
            ;
            return $tco_result;
          };
        };
        return go2(q3)(Nil.value);
      };
    };
  };
  var uncons5 = function(v2) {
    if (v2 instanceof CatNil) {
      return Nothing.value;
    }
    ;
    if (v2 instanceof CatCons) {
      return new Just(new Tuple(v2.value0, (function() {
        var $66 = $$null2(v2.value1);
        if ($66) {
          return CatNil.value;
        }
        ;
        return foldr4(link)(CatNil.value)(v2.value1);
      })()));
    }
    ;
    throw new Error("Failed pattern match at Data.CatList (line 99, column 1 - line 99, column 61): " + [v2.constructor.name]);
  };
  var empty6 = /* @__PURE__ */ (function() {
    return CatNil.value;
  })();
  var append2 = link;
  var semigroupCatList = {
    append: append2
  };
  var snoc4 = function(cat) {
    return function(a3) {
      return append2(cat)(new CatCons(a3, empty5));
    };
  };

  // output/Control.Monad.Free/index.js
  var $runtime_lazy6 = function(name16, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name16 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var append3 = /* @__PURE__ */ append(semigroupCatList);
  var Free = /* @__PURE__ */ (function() {
    function Free2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Free2.create = function(value0) {
      return function(value1) {
        return new Free2(value0, value1);
      };
    };
    return Free2;
  })();
  var Return = /* @__PURE__ */ (function() {
    function Return2(value0) {
      this.value0 = value0;
    }
    ;
    Return2.create = function(value0) {
      return new Return2(value0);
    };
    return Return2;
  })();
  var Bind = /* @__PURE__ */ (function() {
    function Bind2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Bind2.create = function(value0) {
      return function(value1) {
        return new Bind2(value0, value1);
      };
    };
    return Bind2;
  })();
  var toView = function($copy_v) {
    var $tco_done = false;
    var $tco_result;
    function $tco_loop(v2) {
      var runExpF = function(v23) {
        return v23;
      };
      var concatF = function(v23) {
        return function(r) {
          return new Free(v23.value0, append3(v23.value1)(r));
        };
      };
      if (v2.value0 instanceof Return) {
        var v22 = uncons5(v2.value1);
        if (v22 instanceof Nothing) {
          $tco_done = true;
          return new Return(v2.value0.value0);
        }
        ;
        if (v22 instanceof Just) {
          $copy_v = concatF(runExpF(v22.value0.value0)(v2.value0.value0))(v22.value0.value1);
          return;
        }
        ;
        throw new Error("Failed pattern match at Control.Monad.Free (line 227, column 7 - line 231, column 64): " + [v22.constructor.name]);
      }
      ;
      if (v2.value0 instanceof Bind) {
        $tco_done = true;
        return new Bind(v2.value0.value0, function(a3) {
          return concatF(v2.value0.value1(a3))(v2.value1);
        });
      }
      ;
      throw new Error("Failed pattern match at Control.Monad.Free (line 225, column 3 - line 233, column 56): " + [v2.value0.constructor.name]);
    }
    ;
    while (!$tco_done) {
      $tco_result = $tco_loop($copy_v);
    }
    ;
    return $tco_result;
  };
  var fromView = function(f) {
    return new Free(f, empty6);
  };
  var freeMonad = {
    Applicative0: function() {
      return freeApplicative;
    },
    Bind1: function() {
      return freeBind;
    }
  };
  var freeFunctor = {
    map: function(k) {
      return function(f) {
        return bindFlipped(freeBind)((function() {
          var $189 = pure(freeApplicative);
          return function($190) {
            return $189(k($190));
          };
        })())(f);
      };
    }
  };
  var freeBind = {
    bind: function(v2) {
      return function(k) {
        return new Free(v2.value0, snoc4(v2.value1)(k));
      };
    },
    Apply0: function() {
      return $lazy_freeApply(0);
    }
  };
  var freeApplicative = {
    pure: function($191) {
      return fromView(Return.create($191));
    },
    Apply0: function() {
      return $lazy_freeApply(0);
    }
  };
  var $lazy_freeApply = /* @__PURE__ */ $runtime_lazy6("freeApply", "Control.Monad.Free", function() {
    return {
      apply: ap(freeMonad),
      Functor0: function() {
        return freeFunctor;
      }
    };
  });
  var pure5 = /* @__PURE__ */ pure(freeApplicative);
  var liftF = function(f) {
    return fromView(new Bind(f, function($192) {
      return pure5($192);
    }));
  };
  var foldFree = function(dictMonadRec) {
    var Monad0 = dictMonadRec.Monad0();
    var map112 = map(Monad0.Bind1().Apply0().Functor0());
    var pure18 = pure(Monad0.Applicative0());
    var tailRecM4 = tailRecM(dictMonadRec);
    return function(k) {
      var go2 = function(f) {
        var v2 = toView(f);
        if (v2 instanceof Return) {
          return map112(Done.create)(pure18(v2.value0));
        }
        ;
        if (v2 instanceof Bind) {
          return map112(function($199) {
            return Loop.create(v2.value1($199));
          })(k(v2.value0));
        }
        ;
        throw new Error("Failed pattern match at Control.Monad.Free (line 158, column 10 - line 160, column 37): " + [v2.constructor.name]);
      };
      return tailRecM4(go2);
    };
  };

  // output/Halogen.Query.ChildQuery/index.js
  var unChildQueryBox = unsafeCoerce2;

  // output/Unsafe.Reference/foreign.js
  function reallyUnsafeRefEq(a3) {
    return function(b2) {
      return a3 === b2;
    };
  }

  // output/Unsafe.Reference/index.js
  var unsafeRefEq = reallyUnsafeRefEq;

  // output/Halogen.Subscription/index.js
  var $$void4 = /* @__PURE__ */ $$void(functorEffect);
  var bind3 = /* @__PURE__ */ bind(bindEffect);
  var append4 = /* @__PURE__ */ append(semigroupArray);
  var traverse_2 = /* @__PURE__ */ traverse_(applicativeEffect);
  var traverse_1 = /* @__PURE__ */ traverse_2(foldableArray);
  var unsubscribe = function(v2) {
    return v2;
  };
  var subscribe = function(v2) {
    return function(k) {
      return v2(function($76) {
        return $$void4(k($76));
      });
    };
  };
  var notify = function(v2) {
    return function(a3) {
      return v2(a3);
    };
  };
  var create = function __do() {
    var subscribers = $$new([])();
    return {
      emitter: function(k) {
        return function __do3() {
          modify_(function(v2) {
            return append4(v2)([k]);
          })(subscribers)();
          return modify_(deleteBy(unsafeRefEq)(k))(subscribers);
        };
      },
      listener: function(a3) {
        return bind3(read(subscribers))(traverse_1(function(k) {
          return k(a3);
        }));
      }
    };
  };

  // output/Halogen.Query.HalogenM/index.js
  var identity10 = /* @__PURE__ */ identity(categoryFn);
  var SubscriptionId = function(x) {
    return x;
  };
  var ForkId = function(x) {
    return x;
  };
  var State = /* @__PURE__ */ (function() {
    function State2(value0) {
      this.value0 = value0;
    }
    ;
    State2.create = function(value0) {
      return new State2(value0);
    };
    return State2;
  })();
  var Subscribe = /* @__PURE__ */ (function() {
    function Subscribe2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Subscribe2.create = function(value0) {
      return function(value1) {
        return new Subscribe2(value0, value1);
      };
    };
    return Subscribe2;
  })();
  var Unsubscribe = /* @__PURE__ */ (function() {
    function Unsubscribe2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Unsubscribe2.create = function(value0) {
      return function(value1) {
        return new Unsubscribe2(value0, value1);
      };
    };
    return Unsubscribe2;
  })();
  var Lift2 = /* @__PURE__ */ (function() {
    function Lift3(value0) {
      this.value0 = value0;
    }
    ;
    Lift3.create = function(value0) {
      return new Lift3(value0);
    };
    return Lift3;
  })();
  var ChildQuery2 = /* @__PURE__ */ (function() {
    function ChildQuery3(value0) {
      this.value0 = value0;
    }
    ;
    ChildQuery3.create = function(value0) {
      return new ChildQuery3(value0);
    };
    return ChildQuery3;
  })();
  var Raise = /* @__PURE__ */ (function() {
    function Raise2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Raise2.create = function(value0) {
      return function(value1) {
        return new Raise2(value0, value1);
      };
    };
    return Raise2;
  })();
  var Par = /* @__PURE__ */ (function() {
    function Par2(value0) {
      this.value0 = value0;
    }
    ;
    Par2.create = function(value0) {
      return new Par2(value0);
    };
    return Par2;
  })();
  var Fork = /* @__PURE__ */ (function() {
    function Fork2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Fork2.create = function(value0) {
      return function(value1) {
        return new Fork2(value0, value1);
      };
    };
    return Fork2;
  })();
  var Join = /* @__PURE__ */ (function() {
    function Join2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Join2.create = function(value0) {
      return function(value1) {
        return new Join2(value0, value1);
      };
    };
    return Join2;
  })();
  var Kill = /* @__PURE__ */ (function() {
    function Kill2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Kill2.create = function(value0) {
      return function(value1) {
        return new Kill2(value0, value1);
      };
    };
    return Kill2;
  })();
  var GetRef = /* @__PURE__ */ (function() {
    function GetRef2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    GetRef2.create = function(value0) {
      return function(value1) {
        return new GetRef2(value0, value1);
      };
    };
    return GetRef2;
  })();
  var HalogenM = function(x) {
    return x;
  };
  var raise = function(o) {
    return liftF(new Raise(o, unit));
  };
  var ordSubscriptionId = ordInt;
  var ordForkId = ordInt;
  var monadTransHalogenM = {
    lift: function(dictMonad) {
      return function($180) {
        return HalogenM(liftF(Lift2.create($180)));
      };
    }
  };
  var monadHalogenM = freeMonad;
  var monadStateHalogenM = {
    state: function($181) {
      return HalogenM(liftF(State.create($181)));
    },
    Monad0: function() {
      return monadHalogenM;
    }
  };
  var monadEffectHalogenM = function(dictMonadEffect) {
    return {
      liftEffect: (function() {
        var $186 = liftEffect(dictMonadEffect);
        return function($187) {
          return HalogenM(liftF(Lift2.create($186($187))));
        };
      })(),
      Monad0: function() {
        return monadHalogenM;
      }
    };
  };
  var monadAffHalogenM = function(dictMonadAff) {
    var monadEffectHalogenM1 = monadEffectHalogenM(dictMonadAff.MonadEffect0());
    return {
      liftAff: (function() {
        var $188 = liftAff(dictMonadAff);
        return function($189) {
          return HalogenM(liftF(Lift2.create($188($189))));
        };
      })(),
      MonadEffect0: function() {
        return monadEffectHalogenM1;
      }
    };
  };
  var functorHalogenM = freeFunctor;
  var fork = function(hmu) {
    return liftF(new Fork(hmu, identity10));
  };
  var bindHalogenM = freeBind;
  var applicativeHalogenM = freeApplicative;

  // output/Halogen.Query.HalogenQ/index.js
  var Initialize = /* @__PURE__ */ (function() {
    function Initialize4(value0) {
      this.value0 = value0;
    }
    ;
    Initialize4.create = function(value0) {
      return new Initialize4(value0);
    };
    return Initialize4;
  })();
  var Finalize = /* @__PURE__ */ (function() {
    function Finalize2(value0) {
      this.value0 = value0;
    }
    ;
    Finalize2.create = function(value0) {
      return new Finalize2(value0);
    };
    return Finalize2;
  })();
  var Receive = /* @__PURE__ */ (function() {
    function Receive2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Receive2.create = function(value0) {
      return function(value1) {
        return new Receive2(value0, value1);
      };
    };
    return Receive2;
  })();
  var Action2 = /* @__PURE__ */ (function() {
    function Action3(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Action3.create = function(value0) {
      return function(value1) {
        return new Action3(value0, value1);
      };
    };
    return Action3;
  })();
  var Query = /* @__PURE__ */ (function() {
    function Query2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Query2.create = function(value0) {
      return function(value1) {
        return new Query2(value0, value1);
      };
    };
    return Query2;
  })();

  // output/Halogen.VDom.Thunk/index.js
  var $runtime_lazy7 = function(name16, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name16 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var unsafeEqThunk = function(v2, v1) {
    return refEq2(v2.value0, v1.value0) && (refEq2(v2.value1, v1.value1) && v2.value1(v2.value3, v1.value3));
  };
  var runThunk = function(v2) {
    return v2.value2(v2.value3);
  };
  var buildThunk = function(toVDom) {
    var haltThunk = function(state3) {
      return halt(state3.vdom);
    };
    var $lazy_patchThunk = $runtime_lazy7("patchThunk", "Halogen.VDom.Thunk", function() {
      return function(state3, t2) {
        var $48 = unsafeEqThunk(state3.thunk, t2);
        if ($48) {
          return mkStep(new Step(extract2(state3.vdom), state3, $lazy_patchThunk(112), haltThunk));
        }
        ;
        var vdom = step(state3.vdom, toVDom(runThunk(t2)));
        return mkStep(new Step(extract2(vdom), {
          vdom,
          thunk: t2
        }, $lazy_patchThunk(115), haltThunk));
      };
    });
    var patchThunk = $lazy_patchThunk(108);
    var renderThunk = function(spec) {
      return function(t2) {
        var vdom = buildVDom(spec)(toVDom(runThunk(t2)));
        return mkStep(new Step(extract2(vdom), {
          thunk: t2,
          vdom
        }, patchThunk, haltThunk));
      };
    };
    return renderThunk;
  };

  // output/Halogen.Component/index.js
  var voidLeft2 = /* @__PURE__ */ voidLeft(functorHalogenM);
  var traverse_3 = /* @__PURE__ */ traverse_(applicativeHalogenM)(foldableMaybe);
  var map16 = /* @__PURE__ */ map(functorHalogenM);
  var pure6 = /* @__PURE__ */ pure(applicativeHalogenM);
  var lookup4 = /* @__PURE__ */ lookup3();
  var pop3 = /* @__PURE__ */ pop2();
  var insert6 = /* @__PURE__ */ insert5();
  var ComponentSlot = /* @__PURE__ */ (function() {
    function ComponentSlot2(value0) {
      this.value0 = value0;
    }
    ;
    ComponentSlot2.create = function(value0) {
      return new ComponentSlot2(value0);
    };
    return ComponentSlot2;
  })();
  var ThunkSlot = /* @__PURE__ */ (function() {
    function ThunkSlot2(value0) {
      this.value0 = value0;
    }
    ;
    ThunkSlot2.create = function(value0) {
      return new ThunkSlot2(value0);
    };
    return ThunkSlot2;
  })();
  var unComponentSlot = unsafeCoerce2;
  var unComponent = unsafeCoerce2;
  var mkEval = function(args) {
    return function(v2) {
      if (v2 instanceof Initialize) {
        return voidLeft2(traverse_3(args.handleAction)(args.initialize))(v2.value0);
      }
      ;
      if (v2 instanceof Finalize) {
        return voidLeft2(traverse_3(args.handleAction)(args.finalize))(v2.value0);
      }
      ;
      if (v2 instanceof Receive) {
        return voidLeft2(traverse_3(args.handleAction)(args.receive(v2.value0)))(v2.value1);
      }
      ;
      if (v2 instanceof Action2) {
        return voidLeft2(args.handleAction(v2.value0))(v2.value1);
      }
      ;
      if (v2 instanceof Query) {
        return unCoyoneda(function(g) {
          var $45 = map16(maybe(v2.value1(unit))(g));
          return function($46) {
            return $45(args.handleQuery($46));
          };
        })(v2.value0);
      }
      ;
      throw new Error("Failed pattern match at Halogen.Component (line 182, column 15 - line 192, column 71): " + [v2.constructor.name]);
    };
  };
  var mkComponentSlot = unsafeCoerce2;
  var mkComponent = unsafeCoerce2;
  var defaultEval = /* @__PURE__ */ (function() {
    return {
      handleAction: $$const(pure6(unit)),
      handleQuery: $$const(pure6(Nothing.value)),
      receive: $$const(Nothing.value),
      initialize: Nothing.value,
      finalize: Nothing.value
    };
  })();
  var componentSlot = function() {
    return function(dictIsSymbol) {
      var lookup13 = lookup4(dictIsSymbol);
      var pop12 = pop3(dictIsSymbol);
      var insert13 = insert6(dictIsSymbol);
      return function(dictOrd) {
        var lookup23 = lookup13(dictOrd);
        var pop22 = pop12(dictOrd);
        var insert22 = insert13(dictOrd);
        return function(label5) {
          return function(p2) {
            return function(comp) {
              return function(input3) {
                return function(output2) {
                  return mkComponentSlot({
                    get: lookup23(label5)(p2),
                    pop: pop22(label5)(p2),
                    set: insert22(label5)(p2),
                    component: comp,
                    input: input3,
                    output: output2
                  });
                };
              };
            };
          };
        };
      };
    };
  };

  // output/Foreign.Index/foreign.js
  function unsafeReadPropImpl(f, s2, key2, value16) {
    return value16 == null ? f : s2(value16[key2]);
  }

  // output/Foreign.Index/index.js
  var unsafeReadProp = function(dictMonad) {
    var fail3 = fail(dictMonad);
    var pure18 = pure(applicativeExceptT(dictMonad));
    return function(k) {
      return function(value16) {
        return unsafeReadPropImpl(fail3(new TypeMismatch("object", typeOf(value16))), pure18, k, value16);
      };
    };
  };
  var readProp = function(dictMonad) {
    return unsafeReadProp(dictMonad);
  };

  // output/Web.Event.Event/foreign.js
  function _currentTarget(e) {
    return e.currentTarget;
  }
  function _target(e) {
    return e.target;
  }
  function preventDefault(e) {
    return function() {
      return e.preventDefault();
    };
  }
  function stopPropagation(e) {
    return function() {
      return e.stopPropagation();
    };
  }

  // output/Web.Event.Event/index.js
  var target = function($3) {
    return toMaybe(_target($3));
  };
  var currentTarget = function($5) {
    return toMaybe(_currentTarget($5));
  };

  // output/Web.HTML.Event.EventTypes/index.js
  var input2 = "input";
  var domcontentloaded = "DOMContentLoaded";

  // output/Web.UIEvent.KeyboardEvent.EventTypes/index.js
  var keydown = "keydown";

  // output/Web.UIEvent.MouseEvent.EventTypes/index.js
  var click = "click";

  // output/Halogen.HTML.Events/index.js
  var map17 = /* @__PURE__ */ map(functorMaybe);
  var composeKleisli2 = /* @__PURE__ */ composeKleisli(bindMaybe);
  var composeKleisliFlipped3 = /* @__PURE__ */ composeKleisliFlipped(/* @__PURE__ */ bindExceptT(monadIdentity));
  var readProp2 = /* @__PURE__ */ readProp(monadIdentity);
  var readString3 = /* @__PURE__ */ readString(monadIdentity);
  var mouseHandler = unsafeCoerce2;
  var keyHandler = unsafeCoerce2;
  var handler$prime = function(et) {
    return function(f) {
      return handler(et)(function(ev) {
        return map17(Action.create)(f(ev));
      });
    };
  };
  var handler2 = function(et) {
    return function(f) {
      return handler(et)(function(ev) {
        return new Just(new Action(f(ev)));
      });
    };
  };
  var onClick = /* @__PURE__ */ (function() {
    var $15 = handler2(click);
    return function($16) {
      return $15(mouseHandler($16));
    };
  })();
  var onKeyDown = /* @__PURE__ */ (function() {
    var $23 = handler2(keydown);
    return function($24) {
      return $23(keyHandler($24));
    };
  })();
  var onScroll = /* @__PURE__ */ handler2("scroll");
  var onSubmit = /* @__PURE__ */ handler2("submit");
  var addForeignPropHandler = function(key2) {
    return function(prop4) {
      return function(reader) {
        return function(f) {
          var go2 = function(a3) {
            return composeKleisliFlipped3(reader)(readProp2(prop4))(unsafeToForeign(a3));
          };
          return handler$prime(key2)(composeKleisli2(currentTarget)(function(e) {
            return either($$const(Nothing.value))(function($85) {
              return Just.create(f($85));
            })(runExcept(go2(e)));
          }));
        };
      };
    };
  };
  var onValueInput = /* @__PURE__ */ addForeignPropHandler(input2)("value")(readString3);

  // output/TextConstants/index.js
  var show5 = /* @__PURE__ */ show(showInt);
  var routerConstants = {
    routePOS: "\u0E1A\u0E34\u0E25\u0E27\u0E31\u0E19\u0E19\u0E35\u0E49",
    routeCustomers: "\u0E23\u0E32\u0E22\u0E0A\u0E37\u0E48\u0E2D\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32"
  };
  var posConstants = {
    searchPlaceholder: "\u0E04\u0E49\u0E19\u0E2B\u0E32\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32",
    todaysBillsTitle: function(n) {
      return "\u0E1A\u0E34\u0E25\u0E27\u0E31\u0E19\u0E19\u0E35\u0E49 (" + (show5(n) + ")");
    },
    columnTime: "\u0E40\u0E27\u0E25\u0E32",
    columnCustomerName: "\u0E0A\u0E37\u0E48\u0E2D\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32",
    noCustomersFound: "\u0E44\u0E21\u0E48\u0E1E\u0E1A\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32"
  };
  var customerListConstants = {
    appTitle: "\u0E23\u0E32\u0E22\u0E0A\u0E37\u0E48\u0E2D\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32",
    customersCount: function(n) {
      return show5(n) + " \u0E23\u0E32\u0E22";
    },
    columnId: "\u0E23\u0E2B\u0E31\u0E2A",
    columnName: "\u0E0A\u0E37\u0E48\u0E2D",
    columnMoney: "\u0E40\u0E07\u0E34\u0E19",
    columnGoldJewelry: "\u0E23\u0E39\u0E1B\u0E1E\u0E23\u0E23\u0E13",
    columnGoldBar96: "\u0E41\u0E17\u0E48\u0E07 96.5%",
    columnGoldBar99: "\u0E41\u0E17\u0E48\u0E07 99.99%",
    columnUpdated: "\u0E1B\u0E23\u0E31\u0E1A\u0E1B\u0E23\u0E38\u0E07",
    columnActions: "\u0E25\u0E1A",
    headerDebit: "\u0E04\u0E49\u0E32\u0E07",
    headerCredit: "\u0E40\u0E2B\u0E25\u0E37\u0E2D",
    newCustomerPlaceholder: "\u0E0A\u0E37\u0E48\u0E2D\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32\u0E23\u0E32\u0E22\u0E43\u0E2B\u0E21\u0E48",
    searchPlaceholder: "\u0E04\u0E49\u0E19\u0E2B\u0E32\u0E0A\u0E37\u0E48\u0E2D\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32 ...",
    deleteConfirmTitle: "\u0E22\u0E37\u0E19\u0E22\u0E31\u0E19\u0E01\u0E32\u0E23\u0E25\u0E1A",
    deleteConfirmPrompt: "\u0E42\u0E1B\u0E23\u0E14\u0E43\u0E2A\u0E48\u0E23\u0E2B\u0E31\u0E2A\u0E40\u0E1E\u0E37\u0E48\u0E2D\u0E22\u0E37\u0E19\u0E22\u0E31\u0E19:",
    buttonConfirm: "\u0E22\u0E37\u0E19\u0E22\u0E31\u0E19",
    buttonCancel: "\u0E22\u0E01\u0E40\u0E25\u0E34\u0E01",
    unitGrams: "g",
    unitBaht: "\u0E1A"
  };

  // output/Web.HTML.HTMLElement/foreign.js
  function _read(nothing, just, value16) {
    var tag2 = Object.prototype.toString.call(value16);
    if (tag2.indexOf("[object HTML") === 0 && tag2.indexOf("Element]") === tag2.length - 8) {
      return just(value16);
    } else {
      return nothing;
    }
  }

  // output/Web.HTML.HTMLElement/index.js
  var toNode2 = unsafeCoerce2;
  var fromEventTarget2 = function(x) {
    return _read(Nothing.value, Just.create, x);
  };
  var fromElement = function(x) {
    return _read(Nothing.value, Just.create, x);
  };

  // output/Web.UIEvent.KeyboardEvent/foreign.js
  function key(e) {
    return e.key;
  }

  // output/Web.UIEvent.MouseEvent/index.js
  var toEvent = unsafeCoerce2;

  // output/Component.CustomerList/index.js
  var type_4 = /* @__PURE__ */ type_(isPropInputType);
  var value3 = /* @__PURE__ */ value(isPropString);
  var type_1 = /* @__PURE__ */ type_(isPropButtonType);
  var show6 = /* @__PURE__ */ show(showInt);
  var map18 = /* @__PURE__ */ map(functorArray);
  var append5 = /* @__PURE__ */ append(semigroupArray);
  var compare3 = /* @__PURE__ */ compare(ordString);
  var max5 = /* @__PURE__ */ max(ordInt);
  var min5 = /* @__PURE__ */ min(ordInt);
  var compare12 = /* @__PURE__ */ compare(ordInt);
  var bind4 = /* @__PURE__ */ bind(bindHalogenM);
  var lift3 = /* @__PURE__ */ lift(monadTransHalogenM);
  var discard2 = /* @__PURE__ */ discard(discardUnit)(bindHalogenM);
  var modify_3 = /* @__PURE__ */ modify_2(monadStateHalogenM);
  var get3 = /* @__PURE__ */ get(monadStateHalogenM);
  var when2 = /* @__PURE__ */ when(applicativeHalogenM);
  var pure1 = /* @__PURE__ */ pure(applicativeHalogenM);
  var $$void5 = /* @__PURE__ */ $$void(functorHalogenM);
  var bind12 = /* @__PURE__ */ bind(bindMaybe);
  var max1 = /* @__PURE__ */ max(ordNumber);
  var eq32 = /* @__PURE__ */ eq(/* @__PURE__ */ eqMaybe(eqInt));
  var mod3 = /* @__PURE__ */ mod(euclideanRingInt);
  var show13 = /* @__PURE__ */ show(showNumber);
  var SortById = /* @__PURE__ */ (function() {
    function SortById2() {
    }
    ;
    SortById2.value = new SortById2();
    return SortById2;
  })();
  var SortByName = /* @__PURE__ */ (function() {
    function SortByName2() {
    }
    ;
    SortByName2.value = new SortByName2();
    return SortByName2;
  })();
  var SortByMoneyDebit = /* @__PURE__ */ (function() {
    function SortByMoneyDebit2() {
    }
    ;
    SortByMoneyDebit2.value = new SortByMoneyDebit2();
    return SortByMoneyDebit2;
  })();
  var SortByMoneyCredit = /* @__PURE__ */ (function() {
    function SortByMoneyCredit2() {
    }
    ;
    SortByMoneyCredit2.value = new SortByMoneyCredit2();
    return SortByMoneyCredit2;
  })();
  var SortByGoldJewelryDebit = /* @__PURE__ */ (function() {
    function SortByGoldJewelryDebit2() {
    }
    ;
    SortByGoldJewelryDebit2.value = new SortByGoldJewelryDebit2();
    return SortByGoldJewelryDebit2;
  })();
  var SortByGoldJewelryCredit = /* @__PURE__ */ (function() {
    function SortByGoldJewelryCredit2() {
    }
    ;
    SortByGoldJewelryCredit2.value = new SortByGoldJewelryCredit2();
    return SortByGoldJewelryCredit2;
  })();
  var SortByGoldBar96Debit = /* @__PURE__ */ (function() {
    function SortByGoldBar96Debit2() {
    }
    ;
    SortByGoldBar96Debit2.value = new SortByGoldBar96Debit2();
    return SortByGoldBar96Debit2;
  })();
  var SortByGoldBar96Credit = /* @__PURE__ */ (function() {
    function SortByGoldBar96Credit2() {
    }
    ;
    SortByGoldBar96Credit2.value = new SortByGoldBar96Credit2();
    return SortByGoldBar96Credit2;
  })();
  var SortByGoldBar99Debit = /* @__PURE__ */ (function() {
    function SortByGoldBar99Debit2() {
    }
    ;
    SortByGoldBar99Debit2.value = new SortByGoldBar99Debit2();
    return SortByGoldBar99Debit2;
  })();
  var SortByGoldBar99Credit = /* @__PURE__ */ (function() {
    function SortByGoldBar99Credit2() {
    }
    ;
    SortByGoldBar99Credit2.value = new SortByGoldBar99Credit2();
    return SortByGoldBar99Credit2;
  })();
  var SortByUpdated = /* @__PURE__ */ (function() {
    function SortByUpdated2() {
    }
    ;
    SortByUpdated2.value = new SortByUpdated2();
    return SortByUpdated2;
  })();
  var Ascending = /* @__PURE__ */ (function() {
    function Ascending2() {
    }
    ;
    Ascending2.value = new Ascending2();
    return Ascending2;
  })();
  var Descending = /* @__PURE__ */ (function() {
    function Descending2() {
    }
    ;
    Descending2.value = new Descending2();
    return Descending2;
  })();
  var CustomerCountChanged = /* @__PURE__ */ (function() {
    function CustomerCountChanged2(value0) {
      this.value0 = value0;
    }
    ;
    CustomerCountChanged2.create = function(value0) {
      return new CustomerCountChanged2(value0);
    };
    return CustomerCountChanged2;
  })();
  var FieldName = /* @__PURE__ */ (function() {
    function FieldName2() {
    }
    ;
    FieldName2.value = new FieldName2();
    return FieldName2;
  })();
  var FieldMoney = /* @__PURE__ */ (function() {
    function FieldMoney2() {
    }
    ;
    FieldMoney2.value = new FieldMoney2();
    return FieldMoney2;
  })();
  var FieldGoldJewelryGrams = /* @__PURE__ */ (function() {
    function FieldGoldJewelryGrams2() {
    }
    ;
    FieldGoldJewelryGrams2.value = new FieldGoldJewelryGrams2();
    return FieldGoldJewelryGrams2;
  })();
  var FieldGoldJewelryBaht = /* @__PURE__ */ (function() {
    function FieldGoldJewelryBaht2() {
    }
    ;
    FieldGoldJewelryBaht2.value = new FieldGoldJewelryBaht2();
    return FieldGoldJewelryBaht2;
  })();
  var FieldGoldBar96Grams = /* @__PURE__ */ (function() {
    function FieldGoldBar96Grams2() {
    }
    ;
    FieldGoldBar96Grams2.value = new FieldGoldBar96Grams2();
    return FieldGoldBar96Grams2;
  })();
  var FieldGoldBar96Baht = /* @__PURE__ */ (function() {
    function FieldGoldBar96Baht2() {
    }
    ;
    FieldGoldBar96Baht2.value = new FieldGoldBar96Baht2();
    return FieldGoldBar96Baht2;
  })();
  var FieldGoldBar99Grams = /* @__PURE__ */ (function() {
    function FieldGoldBar99Grams2() {
    }
    ;
    FieldGoldBar99Grams2.value = new FieldGoldBar99Grams2();
    return FieldGoldBar99Grams2;
  })();
  var FieldGoldBar99Baht = /* @__PURE__ */ (function() {
    function FieldGoldBar99Baht2() {
    }
    ;
    FieldGoldBar99Baht2.value = new FieldGoldBar99Baht2();
    return FieldGoldBar99Baht2;
  })();
  var Initialize2 = /* @__PURE__ */ (function() {
    function Initialize4() {
    }
    ;
    Initialize4.value = new Initialize4();
    return Initialize4;
  })();
  var LoadCustomers = /* @__PURE__ */ (function() {
    function LoadCustomers2() {
    }
    ;
    LoadCustomers2.value = new LoadCustomers2();
    return LoadCustomers2;
  })();
  var PollForChanges = /* @__PURE__ */ (function() {
    function PollForChanges2() {
    }
    ;
    PollForChanges2.value = new PollForChanges2();
    return PollForChanges2;
  })();
  var ApplyChanges = /* @__PURE__ */ (function() {
    function ApplyChanges2(value0) {
      this.value0 = value0;
    }
    ;
    ApplyChanges2.create = function(value0) {
      return new ApplyChanges2(value0);
    };
    return ApplyChanges2;
  })();
  var StartEditField = /* @__PURE__ */ (function() {
    function StartEditField2(value0, value1, value22, value32) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
      this.value3 = value32;
    }
    ;
    StartEditField2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return function(value32) {
            return new StartEditField2(value0, value1, value22, value32);
          };
        };
      };
    };
    return StartEditField2;
  })();
  var StartEditFieldWithEvent = /* @__PURE__ */ (function() {
    function StartEditFieldWithEvent2(value0, value1, value22, value32, value42) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
      this.value3 = value32;
      this.value4 = value42;
    }
    ;
    StartEditFieldWithEvent2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return function(value32) {
            return function(value42) {
              return new StartEditFieldWithEvent2(value0, value1, value22, value32, value42);
            };
          };
        };
      };
    };
    return StartEditFieldWithEvent2;
  })();
  var UpdateEditValue = /* @__PURE__ */ (function() {
    function UpdateEditValue2(value0) {
      this.value0 = value0;
    }
    ;
    UpdateEditValue2.create = function(value0) {
      return new UpdateEditValue2(value0);
    };
    return UpdateEditValue2;
  })();
  var SaveEditField = /* @__PURE__ */ (function() {
    function SaveEditField2() {
    }
    ;
    SaveEditField2.value = new SaveEditField2();
    return SaveEditField2;
  })();
  var SaveEditOnEnter = /* @__PURE__ */ (function() {
    function SaveEditOnEnter2(value0) {
      this.value0 = value0;
    }
    ;
    SaveEditOnEnter2.create = function(value0) {
      return new SaveEditOnEnter2(value0);
    };
    return SaveEditOnEnter2;
  })();
  var CancelEdit = /* @__PURE__ */ (function() {
    function CancelEdit2() {
    }
    ;
    CancelEdit2.value = new CancelEdit2();
    return CancelEdit2;
  })();
  var CancelEditOnClickOutside = /* @__PURE__ */ (function() {
    function CancelEditOnClickOutside2(value0) {
      this.value0 = value0;
    }
    ;
    CancelEditOnClickOutside2.create = function(value0) {
      return new CancelEditOnClickOutside2(value0);
    };
    return CancelEditOnClickOutside2;
  })();
  var UpdateNewName = /* @__PURE__ */ (function() {
    function UpdateNewName2(value0) {
      this.value0 = value0;
    }
    ;
    UpdateNewName2.create = function(value0) {
      return new UpdateNewName2(value0);
    };
    return UpdateNewName2;
  })();
  var AddCustomer = /* @__PURE__ */ (function() {
    function AddCustomer2(value0) {
      this.value0 = value0;
    }
    ;
    AddCustomer2.create = function(value0) {
      return new AddCustomer2(value0);
    };
    return AddCustomer2;
  })();
  var ShowDeleteConfirmation = /* @__PURE__ */ (function() {
    function ShowDeleteConfirmation2(value0) {
      this.value0 = value0;
    }
    ;
    ShowDeleteConfirmation2.create = function(value0) {
      return new ShowDeleteConfirmation2(value0);
    };
    return ShowDeleteConfirmation2;
  })();
  var UpdateDeleteConfirmInput = /* @__PURE__ */ (function() {
    function UpdateDeleteConfirmInput2(value0) {
      this.value0 = value0;
    }
    ;
    UpdateDeleteConfirmInput2.create = function(value0) {
      return new UpdateDeleteConfirmInput2(value0);
    };
    return UpdateDeleteConfirmInput2;
  })();
  var ConfirmDelete = /* @__PURE__ */ (function() {
    function ConfirmDelete2(value0) {
      this.value0 = value0;
    }
    ;
    ConfirmDelete2.create = function(value0) {
      return new ConfirmDelete2(value0);
    };
    return ConfirmDelete2;
  })();
  var CancelDelete = /* @__PURE__ */ (function() {
    function CancelDelete2() {
    }
    ;
    CancelDelete2.value = new CancelDelete2();
    return CancelDelete2;
  })();
  var FocusDeleteInput = /* @__PURE__ */ (function() {
    function FocusDeleteInput2() {
    }
    ;
    FocusDeleteInput2.value = new FocusDeleteInput2();
    return FocusDeleteInput2;
  })();
  var FocusEditInput = /* @__PURE__ */ (function() {
    function FocusEditInput2() {
    }
    ;
    FocusEditInput2.value = new FocusEditInput2();
    return FocusEditInput2;
  })();
  var SortBy = /* @__PURE__ */ (function() {
    function SortBy2(value0) {
      this.value0 = value0;
    }
    ;
    SortBy2.create = function(value0) {
      return new SortBy2(value0);
    };
    return SortBy2;
  })();
  var HandleScroll = /* @__PURE__ */ (function() {
    function HandleScroll2(value0) {
      this.value0 = value0;
    }
    ;
    HandleScroll2.create = function(value0) {
      return new HandleScroll2(value0);
    };
    return HandleScroll2;
  })();
  var ScrollToCustomer = /* @__PURE__ */ (function() {
    function ScrollToCustomer2(value0) {
      this.value0 = value0;
    }
    ;
    ScrollToCustomer2.create = function(value0) {
      return new ScrollToCustomer2(value0);
    };
    return ScrollToCustomer2;
  })();
  var ScrollToCustomerId = /* @__PURE__ */ (function() {
    function ScrollToCustomerId2(value0) {
      this.value0 = value0;
    }
    ;
    ScrollToCustomerId2.create = function(value0) {
      return new ScrollToCustomerId2(value0);
    };
    return ScrollToCustomerId2;
  })();
  var UpdateSearchQuery = /* @__PURE__ */ (function() {
    function UpdateSearchQuery3(value0) {
      this.value0 = value0;
    }
    ;
    UpdateSearchQuery3.create = function(value0) {
      return new UpdateSearchQuery3(value0);
    };
    return UpdateSearchQuery3;
  })();
  var MeasureRenderedRows = /* @__PURE__ */ (function() {
    function MeasureRenderedRows2() {
    }
    ;
    MeasureRenderedRows2.value = new MeasureRenderedRows2();
    return MeasureRenderedRows2;
  })();
  var UpdateRenderedRange = /* @__PURE__ */ (function() {
    function UpdateRenderedRange2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    UpdateRenderedRange2.create = function(value0) {
      return function(value1) {
        return new UpdateRenderedRange2(value0, value1);
      };
    };
    return UpdateRenderedRange2;
  })();
  var RenderAroundAndScrollTo = /* @__PURE__ */ (function() {
    function RenderAroundAndScrollTo2(value0) {
      this.value0 = value0;
    }
    ;
    RenderAroundAndScrollTo2.create = function(value0) {
      return new RenderAroundAndScrollTo2(value0);
    };
    return RenderAroundAndScrollTo2;
  })();
  var trimTrailingZeros = function($copy_s) {
    var $tco_done = false;
    var $tco_result;
    function $tco_loop(s2) {
      var len = length3(s2);
      var $134 = len === 0;
      if ($134) {
        $tco_done = true;
        return s2;
      }
      ;
      var $135 = takeRight(1)(s2) === "0";
      if ($135) {
        $copy_s = dropRight(1)(s2);
        return;
      }
      ;
      $tco_done = true;
      return s2;
    }
    ;
    while (!$tco_done) {
      $tco_result = $tco_loop($copy_s);
    }
    ;
    return $tco_result;
  };
  var toggleDirection = function(v2) {
    if (v2 instanceof Ascending) {
      return Descending.value;
    }
    ;
    if (v2 instanceof Descending) {
      return Ascending.value;
    }
    ;
    throw new Error("Failed pattern match at Component.CustomerList (line 63, column 1 - line 63, column 50): " + [v2.constructor.name]);
  };
  var textConstants = customerListConstants;
  var renderTableFooter = function(state3) {
    return div2([class_("table-footer")])([form([class_("add-customer-form"), onSubmit(AddCustomer.create)])([input([type_4(InputText.value), class_("new-customer-input"), placeholder(textConstants.newCustomerPlaceholder), value3(state3.newCustomerName), onValueInput(UpdateNewName.create)]), button([type_1(ButtonSubmit.value), class_("btn btn-add"), title("Add Customer")])([addIcon])])]);
  };
  var renderStyles = /* @__PURE__ */ style_([/* @__PURE__ */ text("\n      * {\n        box-sizing: border-box;\n      }\n      \n      body {\n        margin: 0;\n        padding: 0;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',\n          'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',\n          sans-serif;\n        -webkit-font-smoothing: antialiased;\n        -moz-osx-font-smoothing: grayscale;\n        overflow: hidden;\n        height: 100vh;\n      }\n      \n      .app-wrapper {\n        width: 100%;\n        height: 100vh;\n        overflow: hidden;\n      }\n      \n      .customer-app {\n        width: 100%;\n        padding: 8px;\n        height: calc(100vh - 38px);\n        display: flex;\n        flex-direction: column;\n      }\n      \n      .customer-list-container {\n        border: 1px solid #ddd;\n        border-radius: 4px;\n        overflow: hidden;\n        flex: 1;\n        display: flex;\n        flex-direction: column;\n        min-height: 0;\n      }\n      \n      .table-header-container {\n        background-color: #f8f9fa;\n        border-bottom: 2px solid #dee2e6;\n      }\n      \n      .table-header-row1,\n      .table-header-row2 {\n        display: grid;\n        grid-template-columns: 50px 200px 90px 90px 100px 100px 100px 100px 100px 100px 90px 100px;\n        align-items: center;\n        padding: 4px 8px;\n        font-weight: 600;\n        color: #495057;\n        gap: 8px;\n        font-size: 12px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .table-header-row1 {\n        border-bottom: 1px solid #dee2e6;\n      }\n      \n      .table-header-row1 .header-cell {\n        justify-content: center;\n      }\n      \n      .header-money-merged {\n        grid-column: span 2;\n        text-align: center;\n      }\n      \n      .header-gold-acc-merged {\n        grid-column: span 2;\n        text-align: center;\n      }\n      \n      .header-gold-965-merged {\n        grid-column: span 2;\n        text-align: center;\n      }\n      \n      .header-gold-9999-merged {\n        grid-column: span 2;\n        text-align: center;\n      }\n      \n      .header-cell {\n        display: flex;\n        align-items: center;\n        padding: 2px;\n        border-right: 1px solid #dee2e6;\n      }\n      \n      .header-cell:last-child {\n        border-right: none;\n      }\n      \n      .header-debit,\n      .header-credit {\n        justify-content: flex-end;\n      }\n      \n      .header-id {\n        min-width: 50px;\n      }\n      \n      .header-name {\n        min-width: 150px;\n      }\n      \n      .header-name-content {\n        display: flex;\n        align-items: center;\n        gap: 6px;\n        width: 100%;\n      }\n      \n      .search-input {\n        flex: 1;\n        padding: 3px 6px;\n        border: 1px solid #ced4da;\n        border-radius: 3px;\n        font-size: 12px;\n        min-width: 80px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .search-input:focus {\n        outline: none;\n        border-color: #007bff;\n        box-shadow: 0 0 0 1px rgba(0, 123, 255, 0.2);\n      }\n      \n      .header-actions {\n        min-width: 100px;\n        justify-content: center;\n      }\n      \n      .sort-button {\n        background: none;\n        border: none;\n        cursor: pointer;\n        padding: 2px 4px;\n        display: flex;\n        align-items: center;\n        gap: 4px;\n        color: #495057;\n        font-weight: 600;\n        font-size: 12px;\n        transition: color 0.2s;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .sort-button:hover {\n        color: #007bff;\n      }\n      \n      .customer-list {\n        flex: 1;\n        overflow-y: scroll;\n        overflow-x: auto;\n        background-color: #fff;\n        position: relative;\n        min-height: 0;\n      }\n      \n      .scroll-spacer {\n        width: 100%;\n        pointer-events: none;\n      }\n      \n      .visible-rows {\n        position: absolute;\n        top: 0;\n        left: 0;\n        right: 0;\n        will-change: transform;\n      }\n      \n      .customer-row {\n        display: grid;\n        grid-template-columns: 50px 200px 90px 90px 100px 100px 100px 100px 100px 100px 90px 100px;\n        align-items: center;\n        padding: 6px 8px;\n        border-bottom: 1px solid #eee;\n        gap: 8px;\n        min-height: 36px;\n        box-sizing: border-box;\n        font-size: 12px;\n      }\n      \n      .customer-row > * {\n        border-right: 1px solid #eee;\n        padding-right: 8px;\n      }\n      \n      .customer-row > *:last-child {\n        border-right: none;\n      }\n      \n      .customer-row:last-child {\n        border-bottom: none;\n      }\n      \n      .customer-row-even {\n        background-color: #ffffff;\n      }\n      \n      .customer-row-odd {\n        background-color: #f9f9f9;\n      }\n      \n      .customer-row:hover {\n        background-color: #f0f0f0 !important;\n      }\n      \n      .customer-row-highlighted {\n        background-color: #f5e6d3 !important;\n        transition: background-color 0.3s ease;\n      }\n      \n      .customer-row-highlighted:hover {\n        background-color: #ead5bb !important;\n      }\n      \n      .customer-row-pending-delete {\n        background-color: #d4a59a !important;\n        transition: background-color 0.3s ease;\n      }\n      \n      .customer-row-pending-delete:hover {\n        background-color: #c99388 !important;\n      }\n      \n      .customer-id {\n        font-weight: bold;\n        color: #666;\n        padding: 2px;\n        text-align: right;\n      }\n      \n      .customer-name {\n        color: #333;\n        word-wrap: break-word;\n        overflow-wrap: break-word;\n        hyphens: auto;\n        padding: 2px;\n        cursor: pointer;\n        border-radius: 3px;\n        transition: background-color 0.2s ease;\n      }\n      \n      .customer-name:hover {\n        background-color: #e3f2fd;\n        box-shadow: 0 0 0 1px #90caf9;\n      }\n      \n      .editable-field {\n        cursor: pointer;\n        border-radius: 3px;\n        transition: background-color 0.2s ease;\n        padding: 2px 4px;\n        min-height: 20px;\n        display: inline-block;\n      }\n      \n      .editable-field:hover {\n        background-color: #e3f2fd;\n        box-shadow: 0 0 0 1px #90caf9;\n      }\n      \n      .gold-grams .editable-field,\n      .gold-baht .editable-field {\n        display: block;\n        width: 100%;\n        box-sizing: border-box;\n      }\n      \n      .field-warning {\n        background-color: #d4a59a !important;\n        animation: pulse-warning 1s ease-in-out infinite;\n      }\n      \n      @keyframes pulse-warning {\n        0%, 100% {\n          background-color: #d4a59a;\n        }\n        50% {\n          background-color: #c99388;\n        }\n      }\n      \n      .money-input {\n        width: 80px;\n        padding: 2px 4px;\n        border: 2px solid #007bff;\n        border-radius: 3px;\n        font-size: 12px;\n        text-align: right;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .gold-input-container {\n        display: flex;\n        align-items: center;\n        gap: 4px;\n      }\n      \n      .gold-input {\n        width: 70px;\n        padding: 2px 4px;\n        border: 2px solid #007bff;\n        border-radius: 3px;\n        font-size: 12px;\n        text-align: right;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .gold-unit {\n        font-size: 12px;\n        color: #666;\n        font-weight: 500;\n      }\n      \n      .customer-name-input {\n        width: 100%;\n        padding: 4px 6px;\n        border: 2px solid #007bff;\n        border-radius: 3px;\n        font-size: 12px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .customer-name-input:focus {\n        outline: none;\n        border-color: #0056b3;\n      }\n      \n      .customer-money-debit,\n      .customer-money-credit {\n        text-align: right;\n        padding: 2px 4px;\n        color: #333;\n      }\n      \n      .customer-money-debit {\n        color: #dc3545;\n      }\n      \n      .customer-money-credit {\n        color: #28a745;\n      }\n      \n      .money-value {\n        white-space: nowrap;\n      }\n      \n      .money-integer {\n        font-size: 12px;\n      }\n      \n      .money-decimal,\n      .money-fraction {\n        font-size: 9px;\n        vertical-align: baseline;\n      }\n      \n      /* Make .00 fraction and decimal point blend with background for right alignment */\n      .money-decimal-zero,\n      .money-fraction-zero {\n        color: transparent;\n      }\n      \n      /* Default row backgrounds */\n      .customer-row-even .money-decimal-zero,\n      .customer-row-even .money-fraction-zero {\n        color: #ffffff;\n      }\n      \n      .customer-row-odd .money-decimal-zero,\n      .customer-row-odd .money-fraction-zero {\n        color: #f9f9f9;\n      }\n      \n      /* Hover state */\n      .customer-row:hover .money-decimal-zero,\n      .customer-row:hover .money-fraction-zero {\n        color: #f0f0f0;\n      }\n      \n      /* Highlighted row (newly added/edited) */\n      .customer-row-highlighted .money-decimal-zero,\n      .customer-row-highlighted .money-fraction-zero {\n        color: #f5e6d3;\n      }\n      \n      .customer-row-highlighted:hover .money-decimal-zero,\n      .customer-row-highlighted:hover .money-fraction-zero {\n        color: #ead5bb;\n      }\n      \n      /* Pending delete row */\n      .customer-row-pending-delete .money-decimal-zero,\n      .customer-row-pending-delete .money-fraction-zero {\n        color: #d4a59a;\n      }\n      \n      .customer-row-pending-delete:hover .money-decimal-zero,\n      .customer-row-pending-delete:hover .money-fraction-zero {\n        color: #c99388;\n      }\n      \n      /* Warning field (opposite side being edited) */\n      .field-warning .money-decimal-zero,\n      .field-warning .money-fraction-zero {\n        color: #d4a59a;\n        animation: pulse-warning-text 1s ease-in-out infinite;\n      }\n      \n      @keyframes pulse-warning-text {\n        0%, 100% {\n          color: #d4a59a;\n        }\n        50% {\n          color: #c99388;\n        }\n      }\n      \n      .customer-gold-debit,\n      .customer-gold-credit {\n        text-align: right;\n        padding: 2px 4px;\n        font-size: 12px;\n        line-height: 1.3;\n      }\n      \n      .customer-gold-debit {\n        color: #dc3545;\n      }\n      \n      .customer-gold-credit {\n        color: #28a745;\n      }\n      \n      .gold-grams {\n        font-weight: 500;\n      }\n      \n      .gold-baht {\n        font-size: 12px;\n      }\n      \n      .customer-gold-debit .gold-baht {\n        color: #dc3545;\n      }\n      \n      .customer-gold-credit .gold-baht {\n        color: #28a745;\n      }\n      \n      .baht-value {\n        white-space: nowrap;\n        font-size: 12px;\n      }\n      \n      .baht-integer,\n      .baht-unit {\n        font-size: 12px;\n      }\n      \n      .baht-fraction {\n        font-size: 12px;\n        vertical-align: baseline;\n      }\n      \n      .grams-value {\n        white-space: nowrap;\n      }\n      \n      .grams-integer,\n      .grams-unit {\n        font-size: 12px;\n      }\n      \n      .grams-decimal,\n      .grams-fraction {\n        font-size: 12px;\n        vertical-align: baseline;\n      }\n      \n      .customer-updated {\n        font-size: 12px;\n        color: #666;\n        padding: 2px;\n        text-align: center;\n      }\n      \n      .customer-actions {\n        display: flex;\n        gap: 4px;\n        justify-content: center;\n      }\n      \n      .btn {\n        padding: 4px 6px;\n        border: none;\n        border-radius: 3px;\n        cursor: pointer;\n        font-size: 12px;\n        font-weight: 500;\n        transition: all 0.2s;\n        display: flex;\n        align-items: center;\n        gap: 4px;\n      }\n      \n      .btn:hover {\n        transform: translateY(-1px);\n        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);\n      }\n      \n      .btn-edit {\n        background-color: #007bff;\n        color: white;\n        padding: 4px 6px;\n      }\n      \n      .btn-edit:hover {\n        background-color: #0056b3;\n      }\n      \n      .btn-save {\n        background-color: #28a745;\n        color: white;\n        padding: 4px 6px;\n      }\n      \n      .btn-save:hover {\n        background-color: #218838;\n      }\n      \n      .btn-delete {\n        background-color: #dc3545;\n        color: white;\n        padding: 4px 6px;\n      }\n      \n      .btn-delete:hover {\n        background-color: #c82333;\n      }\n      \n      .table-footer {\n        background-color: #f8f9fa;\n        border-top: 2px solid #dee2e6;\n      }\n      \n      .add-customer-form {\n        display: flex;\n        gap: 6px;\n        padding: 6px 8px;\n        align-items: center;\n      }\n      \n      .new-customer-input {\n        flex: 1;\n        padding: 4px 6px;\n        border: 1px solid #ddd;\n        border-radius: 3px;\n        font-size: 12px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .new-customer-input:focus {\n        outline: none;\n        border-color: #007bff;\n      }\n      \n      .btn-add {\n        background-color: #28a745;\n        color: white;\n        padding: 4px 6px;\n        min-width: 32px;\n      }\n      \n      .btn-add:hover {\n        background-color: #218838;\n      }\n      \n      /* Modal Dialog Styles */\n      .modal-overlay {\n        position: fixed;\n        top: 0;\n        left: 0;\n        right: 0;\n        bottom: 0;\n        background-color: rgba(0, 0, 0, 0.5);\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        z-index: 1000;\n      }\n      \n      .modal-dialog {\n        background: white;\n        border-radius: 8px;\n        padding: 24px;\n        max-width: 400px;\n        width: 90%;\n        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);\n      }\n      \n      .modal-title {\n        margin: 0 0 16px 0;\n        font-size: 20px;\n        font-weight: 600;\n        color: #333;\n      }\n      \n      .modal-message {\n        margin: 0 0 16px 0;\n        color: #666;\n        line-height: 1.5;\n      }\n      \n      .modal-code {\n        background: #f8f9fa;\n        border: 2px solid #dee2e6;\n        border-radius: 4px;\n        padding: 16px;\n        text-align: center;\n        font-size: 24px;\n        font-weight: 700;\n        color: #dc3545;\n        margin-bottom: 16px;\n        letter-spacing: 2px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .modal-input {\n        width: 100%;\n        padding: 12px;\n        border: 2px solid #dee2e6;\n        border-radius: 4px;\n        font-size: 16px;\n        margin-bottom: 16px;\n        text-align: center;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n        letter-spacing: 1px;\n      }\n      \n      .modal-input:focus {\n        outline: none;\n        border-color: #0056b3;\n      }\n      \n      .modal-buttons {\n        display: flex;\n        gap: 12px;\n        justify-content: flex-end;\n      }\n      \n      .btn-confirm {\n        background-color: #dc3545;\n        color: white;\n        padding: 10px 20px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .btn-confirm:hover {\n        background-color: #c82333;\n      }\n      \n      .btn-cancel {\n        background-color: #6c757d;\n        color: white;\n        padding: 10px 20px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .btn-cancel:hover {\n        background-color: #5a6268;\n      }\n    ")]);
  var renderMoney = function(d) {
    var absD = abs3(d);
    var formatted = formatMoneyValue(absD);
    var isInteger = formatted.fraction === "00";
    var decimalClass = (function() {
      if (isInteger) {
        return "money-decimal money-decimal-zero";
      }
      ;
      return "money-decimal";
    })();
    var fractionClass = (function() {
      if (isInteger) {
        return "money-fraction money-fraction-zero";
      }
      ;
      return "money-fraction";
    })();
    return span2([class_("money-value")])([span2([class_("money-integer")])([text(formatted.integer)]), span2([class_(decimalClass)])([text(".")]), span2([class_(fractionClass)])([text(formatted.fraction)])]);
  };
  var renderGrams = function(d) {
    var absD = abs3(d);
    var formatted = formatGramsValue(absD);
    var $139 = formatted.integer === "";
    if ($139) {
      return text("");
    }
    ;
    return span2([class_("grams-value")])([span2([class_("grams-integer")])([text(formatted.integer)]), span2([class_("grams-decimal")])([text(".")]), span2([class_("grams-fraction")])([text(formatted.fraction)]), span2([class_("grams-unit")])([text(textConstants.unitGrams)])]);
  };
  var renderDeleteConfirmationDialog = function(state3) {
    if (state3.deleteConfirmation instanceof Nothing) {
      return text("");
    }
    ;
    if (state3.deleteConfirmation instanceof Just) {
      return div2([class_("modal-overlay")])([div2([class_("modal-dialog")])([h2([class_("modal-title")])([text(textConstants.deleteConfirmTitle)]), p([class_("modal-message")])([text(textConstants.deleteConfirmPrompt)]), div2([class_("modal-code")])([text(show6(state3.deleteConfirmation.value0.confirmCode))]), input([type_4(InputText.value), class_("modal-input"), placeholder(textConstants.deleteConfirmPrompt), value3(state3.deleteConfirmation.value0.inputValue), onValueInput(UpdateDeleteConfirmInput.create), onKeyDown(function(e) {
        var $141 = key(e) === "Enter";
        if ($141) {
          return new ConfirmDelete(state3.deleteConfirmation.value0.customerId);
        }
        ;
        var $142 = key(e) === "Escape";
        if ($142) {
          return CancelDelete.value;
        }
        ;
        return new UpdateDeleteConfirmInput(state3.deleteConfirmation.value0.inputValue);
      })]), div2([class_("modal-buttons")])([button([class_("btn btn-confirm"), onClick(function(v2) {
        return new ConfirmDelete(state3.deleteConfirmation.value0.customerId);
      })])([text(textConstants.buttonConfirm)]), button([class_("btn btn-cancel"), onClick(function(v2) {
        return CancelDelete.value;
      })])([text(textConstants.buttonCancel)])])])]);
    }
    ;
    throw new Error("Failed pattern match at Component.CustomerList (line 945, column 3 - line 989, column 10): " + [state3.deleteConfirmation.constructor.name]);
  };
  var renderBaht = function(d) {
    var absD = abs3(d);
    var formatted = formatBahtValue(absD);
    var $144 = formatted.integer === "";
    if ($144) {
      return text("");
    }
    ;
    return span2([class_("baht-value")])([span2([class_("baht-integer")])([text(formatted.integer)]), (function() {
      if (formatted.hasFraction) {
        return span2([class_("baht-fraction")])([text(formatted.fraction)]);
      }
      ;
      return text("");
    })(), span2([class_("baht-unit")])([text(textConstants.unitBaht)])]);
  };
  var parseNumber = function(value1) {
    return function(maxDecimals) {
      var v2 = fromString2(value1);
      if (v2 instanceof Nothing) {
        return Nothing.value;
      }
      ;
      if (v2 instanceof Just) {
        var $147 = isNegative(v2.value0);
        if ($147) {
          return Nothing.value;
        }
        ;
        var parts = split(".")(value1);
        if (parts.length === 1) {
          return new Just(value1);
        }
        ;
        if (parts.length === 2) {
          var $150 = length4(parts[1]) <= maxDecimals;
          if ($150) {
            return new Just(value1);
          }
          ;
          return Nothing.value;
        }
        ;
        return Nothing.value;
      }
      ;
      throw new Error("Failed pattern match at Component.CustomerList (line 130, column 3 - line 142, column 23): " + [v2.constructor.name]);
    };
  };
  var parseFieldValue = function(v2) {
    return function(v1) {
      if (v2 instanceof FieldName) {
        var $156 = v1 === "";
        if ($156) {
          return Nothing.value;
        }
        ;
        return new Just(v1);
      }
      ;
      if (v2 instanceof FieldMoney) {
        return parseNumber(v1)(2);
      }
      ;
      if (v2 instanceof FieldGoldJewelryGrams) {
        return parseNumber(v1)(3);
      }
      ;
      if (v2 instanceof FieldGoldJewelryBaht) {
        return parseNumber(v1)(3);
      }
      ;
      if (v2 instanceof FieldGoldBar96Grams) {
        return parseNumber(v1)(3);
      }
      ;
      if (v2 instanceof FieldGoldBar96Baht) {
        return parseNumber(v1)(3);
      }
      ;
      if (v2 instanceof FieldGoldBar99Grams) {
        return parseNumber(v1)(3);
      }
      ;
      if (v2 instanceof FieldGoldBar99Baht) {
        return parseNumber(v1)(3);
      }
      ;
      throw new Error("Failed pattern match at Component.CustomerList (line 116, column 1 - line 116, column 59): " + [v2.constructor.name, v1.constructor.name]);
    };
  };
  var overscan = 10;
  var mergeCustomers = function(existing) {
    return function(changes) {
      var updated = map18(function(c2) {
        var v2 = findIndex(function(ch) {
          return ch.id === c2.id;
        })(changes);
        if (v2 instanceof Just) {
          var v1 = index(changes)(v2.value0);
          if (v1 instanceof Just) {
            var $159 = v1.value0.name !== c2.name;
            if ($159) {
              return v1.value0;
            }
            ;
            return {
              baht_bar96: v1.value0.baht_bar96,
              baht_bar99: v1.value0.baht_bar99,
              baht_jewelry: v1.value0.baht_jewelry,
              created_at: v1.value0.created_at,
              gram_bar96: v1.value0.gram_bar96,
              gram_bar99: v1.value0.gram_bar99,
              gram_jewelry: v1.value0.gram_jewelry,
              id: v1.value0.id,
              money: v1.value0.money,
              name: v1.value0.name,
              updated_at: v1.value0.updated_at,
              rowHeight: c2.rowHeight
            };
          }
          ;
          if (v1 instanceof Nothing) {
            return c2;
          }
          ;
          throw new Error("Failed pattern match at Component.CustomerList (line 322, column 21 - line 329, column 23): " + [v1.constructor.name]);
        }
        ;
        if (v2 instanceof Nothing) {
          return c2;
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 321, column 7 - line 330, column 21): " + [v2.constructor.name]);
      })(existing);
      var newCustomers = filter(function(ch) {
        var v2 = findIndex(function(c2) {
          return c2.id === ch.id;
        })(existing);
        if (v2 instanceof Just) {
          return false;
        }
        ;
        if (v2 instanceof Nothing) {
          return true;
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 335, column 7 - line 337, column 24): " + [v2.constructor.name]);
      })(changes);
      return append5(updated)(newCustomers);
    };
  };
  var gramsPerBahtJewelry = /* @__PURE__ */ unsafeFromString("15.24");
  var gramsPerBahtBar99 = /* @__PURE__ */ unsafeFromString("15.244");
  var gramsPerBahtBar96 = /* @__PURE__ */ unsafeFromString("15.244");
  var getLatestTimestamp = function(customers) {
    if (customers.length === 0) {
      return Nothing.value;
    }
    ;
    var timestamps = catMaybes(map18(function(v3) {
      return v3.updated_at;
    })(customers));
    var v2 = sortBy(compare3)(timestamps);
    if (v2.length === 0) {
      return Nothing.value;
    }
    ;
    return last(v2);
  };
  var getDbFieldName = function(v2) {
    if (v2 instanceof FieldName) {
      return "name";
    }
    ;
    if (v2 instanceof FieldMoney) {
      return "money";
    }
    ;
    if (v2 instanceof FieldGoldJewelryGrams) {
      return "gram_jewelry";
    }
    ;
    if (v2 instanceof FieldGoldJewelryBaht) {
      return "baht_jewelry";
    }
    ;
    if (v2 instanceof FieldGoldBar96Grams) {
      return "gram_bar96";
    }
    ;
    if (v2 instanceof FieldGoldBar96Baht) {
      return "baht_bar96";
    }
    ;
    if (v2 instanceof FieldGoldBar99Grams) {
      return "gram_bar99";
    }
    ;
    if (v2 instanceof FieldGoldBar99Baht) {
      return "baht_bar99";
    }
    ;
    throw new Error("Failed pattern match at Component.CustomerList (line 105, column 1 - line 105, column 42): " + [v2.constructor.name]);
  };
  var getCustomerListElement = function __do2() {
    var nullable2 = getCustomerListElementImpl();
    return toMaybe(nullable2);
  };
  var formatNumberForEdit = function(d) {
    var str = toString(d);
    var trimmed = trimTrailingZeros(str);
    var $167 = takeRight(1)(trimmed) === ".";
    if ($167) {
      return dropRight(1)(trimmed);
    }
    ;
    return trimmed;
  };
  var getFieldValue = function(v2) {
    return function(v1) {
      if (v2 instanceof FieldName) {
        return v1.name;
      }
      ;
      if (v2 instanceof FieldMoney) {
        return formatNumberForEdit(v1.money);
      }
      ;
      if (v2 instanceof FieldGoldJewelryGrams) {
        return formatNumberForEdit(v1.gram_jewelry);
      }
      ;
      if (v2 instanceof FieldGoldJewelryBaht) {
        return formatNumberForEdit(v1.baht_jewelry);
      }
      ;
      if (v2 instanceof FieldGoldBar96Grams) {
        return formatNumberForEdit(v1.gram_bar96);
      }
      ;
      if (v2 instanceof FieldGoldBar96Baht) {
        return formatNumberForEdit(v1.baht_bar96);
      }
      ;
      if (v2 instanceof FieldGoldBar99Grams) {
        return formatNumberForEdit(v1.gram_bar99);
      }
      ;
      if (v2 instanceof FieldGoldBar99Baht) {
        return formatNumberForEdit(v1.baht_bar99);
      }
      ;
      throw new Error("Failed pattern match at Component.CustomerList (line 94, column 1 - line 94, column 53): " + [v2.constructor.name, v1.constructor.name]);
    };
  };
  var filterCustomers = function(v2) {
    return function(v1) {
      if (v2 === "") {
        return v1;
      }
      ;
      return filter(function(c2) {
        return contains(toLower(v2))(toLower(c2.name));
      })(v1);
    };
  };
  var extractDatePart = function(v2) {
    if (v2 instanceof Nothing) {
      return "";
    }
    ;
    if (v2 instanceof Just) {
      var v1 = split("T")(v2.value0);
      if (v1.length === 2) {
        return v1[0];
      }
      ;
      return v2.value0;
    }
    ;
    throw new Error("Failed pattern match at Component.CustomerList (line 146, column 1 - line 146, column 42): " + [v2.constructor.name]);
  };
  var eqSortField = {
    eq: function(x) {
      return function(y) {
        if (x instanceof SortById && y instanceof SortById) {
          return true;
        }
        ;
        if (x instanceof SortByName && y instanceof SortByName) {
          return true;
        }
        ;
        if (x instanceof SortByMoneyDebit && y instanceof SortByMoneyDebit) {
          return true;
        }
        ;
        if (x instanceof SortByMoneyCredit && y instanceof SortByMoneyCredit) {
          return true;
        }
        ;
        if (x instanceof SortByGoldJewelryDebit && y instanceof SortByGoldJewelryDebit) {
          return true;
        }
        ;
        if (x instanceof SortByGoldJewelryCredit && y instanceof SortByGoldJewelryCredit) {
          return true;
        }
        ;
        if (x instanceof SortByGoldBar96Debit && y instanceof SortByGoldBar96Debit) {
          return true;
        }
        ;
        if (x instanceof SortByGoldBar96Credit && y instanceof SortByGoldBar96Credit) {
          return true;
        }
        ;
        if (x instanceof SortByGoldBar99Debit && y instanceof SortByGoldBar99Debit) {
          return true;
        }
        ;
        if (x instanceof SortByGoldBar99Credit && y instanceof SortByGoldBar99Credit) {
          return true;
        }
        ;
        if (x instanceof SortByUpdated && y instanceof SortByUpdated) {
          return true;
        }
        ;
        return false;
      };
    }
  };
  var eq4 = /* @__PURE__ */ eq(eqSortField);
  var renderSortIcon = function(field) {
    return function(v2) {
      if (v2.field instanceof Just && eq4(v2.field.value0)(field)) {
        if (v2.direction instanceof Ascending) {
          return sortAscIcon;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortDescIcon;
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 625, column 7 - line 627, column 41): " + [v2.direction.constructor.name]);
      }
      ;
      return sortNeutralIcon;
    };
  };
  var renderTableHeader = function(state3) {
    return div2([class_("table-header-container")])([div2([class_("table-header-row1")])([div2([class_("header-cell header-id-row1")])([]), div2([class_("header-cell header-name-row1")])([button([class_("sort-button"), onClick(function(v2) {
      return new SortBy(SortByName.value);
    })])([text(textConstants.columnName + " "), renderSortIcon(SortByName.value)(state3.sortState)])]), div2([class_("header-cell header-money-merged")])([text(textConstants.columnMoney)]), div2([class_("header-cell header-gold-acc-merged")])([text(textConstants.columnGoldJewelry)]), div2([class_("header-cell header-gold-965-merged")])([text(textConstants.columnGoldBar96)]), div2([class_("header-cell header-gold-9999-merged")])([text(textConstants.columnGoldBar99)]), div2([class_("header-cell header-updated-row1")])([]), div2([class_("header-cell header-actions-row1")])([text(textConstants.columnActions)])]), div2([class_("table-header-row2")])([div2([class_("header-cell header-id-row2")])([button([class_("sort-button"), onClick(function(v2) {
      return new SortBy(SortById.value);
    })])([text(textConstants.columnId + " "), renderSortIcon(SortById.value)(state3.sortState)])]), div2([class_("header-cell header-name-row2")])([input([type_4(InputText.value), class_("search-input"), placeholder(textConstants.searchPlaceholder), value3(state3.searchQuery), onValueInput(UpdateSearchQuery.create)])]), button([class_("header-cell header-debit sort-button"), onClick(function(v2) {
      return new SortBy(SortByMoneyDebit.value);
    })])([text(textConstants.headerDebit + " "), renderSortIcon(SortByMoneyDebit.value)(state3.sortState)]), button([class_("header-cell header-credit sort-button"), onClick(function(v2) {
      return new SortBy(SortByMoneyCredit.value);
    })])([text(textConstants.headerCredit + " "), renderSortIcon(SortByMoneyCredit.value)(state3.sortState)]), button([class_("header-cell header-debit sort-button"), onClick(function(v2) {
      return new SortBy(SortByGoldJewelryDebit.value);
    })])([text(textConstants.headerDebit + " "), renderSortIcon(SortByGoldJewelryDebit.value)(state3.sortState)]), button([class_("header-cell header-credit sort-button"), onClick(function(v2) {
      return new SortBy(SortByGoldJewelryCredit.value);
    })])([text(textConstants.headerCredit + " "), renderSortIcon(SortByGoldJewelryCredit.value)(state3.sortState)]), button([class_("header-cell header-debit sort-button"), onClick(function(v2) {
      return new SortBy(SortByGoldBar96Debit.value);
    })])([text(textConstants.headerDebit + " "), renderSortIcon(SortByGoldBar96Debit.value)(state3.sortState)]), button([class_("header-cell header-credit sort-button"), onClick(function(v2) {
      return new SortBy(SortByGoldBar96Credit.value);
    })])([text(textConstants.headerCredit + " "), renderSortIcon(SortByGoldBar96Credit.value)(state3.sortState)]), button([class_("header-cell header-debit sort-button"), onClick(function(v2) {
      return new SortBy(SortByGoldBar99Debit.value);
    })])([text(textConstants.headerDebit + " "), renderSortIcon(SortByGoldBar99Debit.value)(state3.sortState)]), button([class_("header-cell header-credit sort-button"), onClick(function(v2) {
      return new SortBy(SortByGoldBar99Credit.value);
    })])([text(textConstants.headerCredit + " "), renderSortIcon(SortByGoldBar99Credit.value)(state3.sortState)]), button([class_("header-cell sort-button"), onClick(function(v2) {
      return new SortBy(SortByUpdated.value);
    })])([text(textConstants.columnUpdated), renderSortIcon(SortByUpdated.value)(state3.sortState)]), div2([class_("header-cell header-actions-row2")])([])])]);
  };
  var eqEditableField = {
    eq: function(x) {
      return function(y) {
        if (x instanceof FieldName && y instanceof FieldName) {
          return true;
        }
        ;
        if (x instanceof FieldMoney && y instanceof FieldMoney) {
          return true;
        }
        ;
        if (x instanceof FieldGoldJewelryGrams && y instanceof FieldGoldJewelryGrams) {
          return true;
        }
        ;
        if (x instanceof FieldGoldJewelryBaht && y instanceof FieldGoldJewelryBaht) {
          return true;
        }
        ;
        if (x instanceof FieldGoldBar96Grams && y instanceof FieldGoldBar96Grams) {
          return true;
        }
        ;
        if (x instanceof FieldGoldBar96Baht && y instanceof FieldGoldBar96Baht) {
          return true;
        }
        ;
        if (x instanceof FieldGoldBar99Grams && y instanceof FieldGoldBar99Grams) {
          return true;
        }
        ;
        if (x instanceof FieldGoldBar99Baht && y instanceof FieldGoldBar99Baht) {
          return true;
        }
        ;
        return false;
      };
    }
  };
  var eq5 = /* @__PURE__ */ eq(eqEditableField);
  var notEq4 = /* @__PURE__ */ notEq(eqEditableField);
  var renderEditableField = function(state3) {
    return function(customer) {
      return function(field) {
        return function(displayClass) {
          return function(inputClass) {
            var isEditing = (function() {
              if (state3.editing instanceof Just) {
                return state3.editing.value0.customerId === customer.id && eq5(state3.editing.value0.field)(field);
              }
              ;
              if (state3.editing instanceof Nothing) {
                return false;
              }
              ;
              throw new Error("Failed pattern match at Component.CustomerList (line 697, column 17 - line 699, column 23): " + [state3.editing.constructor.name]);
            })();
            var currentValue = getFieldValue(field)(customer);
            var editValue = (function() {
              if (state3.editing instanceof Just && (state3.editing.value0.customerId === customer.id && eq5(state3.editing.value0.field)(field))) {
                return state3.editing.value0.value;
              }
              ;
              return currentValue;
            })();
            if (isEditing) {
              return input([type_4(InputText.value), class_(inputClass), value3(editValue), onValueInput(UpdateEditValue.create), onKeyDown(SaveEditOnEnter.create)]);
            }
            ;
            return span2([class_(displayClass), onClick(function(e) {
              return new StartEditFieldWithEvent(customer.id, field, currentValue, false, e);
            })])([text(currentValue)]);
          };
        };
      };
    };
  };
  var renderGoldField = function(state3) {
    return function(customer) {
      return function(field) {
        return function(isDebit) {
          return function(unit2) {
            return function(renderer) {
              return function(value1) {
                var shouldShowValue = (function() {
                  if (isDebit) {
                    return lte(value1)(zero2);
                  }
                  ;
                  return gte(value1)(zero2);
                })();
                var isEditingThisSide = (function() {
                  if (state3.editing instanceof Just) {
                    return state3.editing.value0.customerId === customer.id && (eq5(state3.editing.value0.field)(field) && state3.editing.value0.isDebitSide === isDebit);
                  }
                  ;
                  if (state3.editing instanceof Nothing) {
                    return false;
                  }
                  ;
                  throw new Error("Failed pattern match at Component.CustomerList (line 725, column 25 - line 727, column 23): " + [state3.editing.constructor.name]);
                })();
                var isEditingOppositeSide = (function() {
                  if (state3.editing instanceof Just) {
                    return state3.editing.value0.customerId === customer.id && (eq5(state3.editing.value0.field)(field) && state3.editing.value0.isDebitSide !== isDebit);
                  }
                  ;
                  if (state3.editing instanceof Nothing) {
                    return false;
                  }
                  ;
                  throw new Error("Failed pattern match at Component.CustomerList (line 729, column 29 - line 731, column 23): " + [state3.editing.constructor.name]);
                })();
                var baseClassName = (function() {
                  if (isDebit) {
                    return "customer-gold-debit";
                  }
                  ;
                  return "customer-gold-credit";
                })();
                var absValue = abs3(value1);
                var className2 = (function() {
                  var $201 = isEditingOppositeSide && (shouldShowValue && gt(absValue)(zero2));
                  if ($201) {
                    return baseClassName + " field-warning";
                  }
                  ;
                  return baseClassName;
                })();
                var displayValue = (function() {
                  var $202 = shouldShowValue && gt(absValue)(zero2);
                  if ($202) {
                    return formatNumberForEdit(absValue);
                  }
                  ;
                  return "";
                })();
                var editValue = (function() {
                  if (state3.editing instanceof Just && (state3.editing.value0.customerId === customer.id && (eq5(state3.editing.value0.field)(field) && state3.editing.value0.isDebitSide === isDebit))) {
                    return state3.editing.value0.value;
                  }
                  ;
                  return displayValue;
                })();
                if (isEditingThisSide) {
                  return div2([class_(baseClassName + " gold-input-container")])([input([type_4(InputText.value), class_("gold-input"), value3(editValue), onValueInput(UpdateEditValue.create), onKeyDown(SaveEditOnEnter.create)]), span2([class_("gold-unit")])([text(unit2)])]);
                }
                ;
                return div2([class_(className2 + " editable-field"), onClick(function(e) {
                  return new StartEditFieldWithEvent(customer.id, field, displayValue, isDebit, e);
                })])([(function() {
                  var $206 = shouldShowValue && gt(absValue)(zero2);
                  if ($206) {
                    return renderer(value1);
                  }
                  ;
                  return text(" ");
                })()]);
              };
            };
          };
        };
      };
    };
  };
  var renderMoneyField = function(state3) {
    return function(customer) {
      return function(isDebit) {
        var shouldShowValue = (function() {
          if (isDebit) {
            return lte(customer.money)(zero2);
          }
          ;
          return gte(customer.money)(zero2);
        })();
        var isEditingThisSide = (function() {
          if (state3.editing instanceof Just) {
            return state3.editing.value0.customerId === customer.id && (eq5(state3.editing.value0.field)(FieldMoney.value) && state3.editing.value0.isDebitSide === isDebit);
          }
          ;
          if (state3.editing instanceof Nothing) {
            return false;
          }
          ;
          throw new Error("Failed pattern match at Component.CustomerList (line 772, column 25 - line 774, column 23): " + [state3.editing.constructor.name]);
        })();
        var isEditingOppositeSide = (function() {
          if (state3.editing instanceof Just) {
            return state3.editing.value0.customerId === customer.id && (eq5(state3.editing.value0.field)(FieldMoney.value) && state3.editing.value0.isDebitSide !== isDebit);
          }
          ;
          if (state3.editing instanceof Nothing) {
            return false;
          }
          ;
          throw new Error("Failed pattern match at Component.CustomerList (line 776, column 29 - line 778, column 23): " + [state3.editing.constructor.name]);
        })();
        var baseClassName = (function() {
          if (isDebit) {
            return "customer-money-debit";
          }
          ;
          return "customer-money-credit";
        })();
        var absValue = abs3(customer.money);
        var className2 = (function() {
          var $213 = isEditingOppositeSide && (shouldShowValue && gt(absValue)(zero2));
          if ($213) {
            return baseClassName + " field-warning";
          }
          ;
          return baseClassName;
        })();
        var displayValue = (function() {
          var $214 = shouldShowValue && gt(absValue)(zero2);
          if ($214) {
            return formatNumberForEdit(absValue);
          }
          ;
          return "";
        })();
        var editValue = (function() {
          if (state3.editing instanceof Just && (state3.editing.value0.customerId === customer.id && (eq5(state3.editing.value0.field)(FieldMoney.value) && state3.editing.value0.isDebitSide === isDebit))) {
            return state3.editing.value0.value;
          }
          ;
          return displayValue;
        })();
        if (isEditingThisSide) {
          return span2([class_(baseClassName)])([input([type_4(InputText.value), class_("money-input"), value3(editValue), onValueInput(UpdateEditValue.create), onKeyDown(SaveEditOnEnter.create)])]);
        }
        ;
        return span2([class_(className2 + " editable-field"), onClick(function(e) {
          return new StartEditFieldWithEvent(customer.id, FieldMoney.value, displayValue, isDebit, e);
        })])([(function() {
          var $218 = shouldShowValue && gt(absValue)(zero2);
          if ($218) {
            return renderMoney(customer.money);
          }
          ;
          return text(" ");
        })()]);
      };
    };
  };
  var defaultRowHeight = 37;
  var getCustomerHeight = function(customer) {
    if (customer.rowHeight instanceof Just) {
      return customer.rowHeight.value0;
    }
    ;
    if (customer.rowHeight instanceof Nothing) {
      return defaultRowHeight;
    }
    ;
    throw new Error("Failed pattern match at Component.CustomerList (line 358, column 3 - line 360, column 32): " + [customer.rowHeight.constructor.name]);
  };
  var calculateHeightRange = function(customers) {
    return function(start2) {
      return function(end) {
        var slice$prime = slice(start2)(end)(customers);
        return foldl2(function(acc) {
          return function(c2) {
            return acc + getCustomerHeight(c2);
          };
        })(0)(slice$prime);
      };
    };
  };
  var calculateVisibleRange = function(state3) {
    return function(customers) {
      var totalRows = length(customers);
      var findStartRow = function($copy_idx) {
        return function($copy_accHeight) {
          var $tco_var_idx = $copy_idx;
          var $tco_done = false;
          var $tco_result;
          function $tco_loop(idx, accHeight) {
            var $221 = idx >= totalRows;
            if ($221) {
              $tco_done = true;
              return totalRows;
            }
            ;
            var v2 = index(customers)(idx);
            if (v2 instanceof Just) {
              var rowHeight = getCustomerHeight(v2.value0);
              var nextHeight = accHeight + rowHeight;
              var $223 = nextHeight > state3.scrollTop;
              if ($223) {
                $tco_done = true;
                return idx;
              }
              ;
              $tco_var_idx = idx + 1 | 0;
              $copy_accHeight = nextHeight;
              return;
            }
            ;
            if (v2 instanceof Nothing) {
              $tco_done = true;
              return totalRows;
            }
            ;
            throw new Error("Failed pattern match at Component.CustomerList (line 381, column 9 - line 388, column 31): " + [v2.constructor.name]);
          }
          ;
          while (!$tco_done) {
            $tco_result = $tco_loop($tco_var_idx, $copy_accHeight);
          }
          ;
          return $tco_result;
        };
      };
      var start2 = max5(0)(findStartRow(0)(0) - overscan | 0);
      var topSpacerHeight = calculateHeightRange(customers)(0)(start2);
      var findEndRow = function($copy_idx) {
        return function($copy_accHeight) {
          var $tco_var_idx = $copy_idx;
          var $tco_done1 = false;
          var $tco_result;
          function $tco_loop(idx, accHeight) {
            var $225 = idx >= totalRows;
            if ($225) {
              $tco_done1 = true;
              return totalRows;
            }
            ;
            var v2 = index(customers)(idx);
            if (v2 instanceof Just) {
              var rowHeight = getCustomerHeight(v2.value0);
              var nextHeight = accHeight + rowHeight;
              var $227 = nextHeight > state3.containerHeight;
              if ($227) {
                $tco_done1 = true;
                return idx + 1 | 0;
              }
              ;
              $tco_var_idx = idx + 1 | 0;
              $copy_accHeight = nextHeight;
              return;
            }
            ;
            if (v2 instanceof Nothing) {
              $tco_done1 = true;
              return totalRows;
            }
            ;
            throw new Error("Failed pattern match at Component.CustomerList (line 397, column 9 - line 404, column 31): " + [v2.constructor.name]);
          }
          ;
          while (!$tco_done1) {
            $tco_result = $tco_loop($tco_var_idx, $copy_accHeight);
          }
          ;
          return $tco_result;
        };
      };
      var end = min5(totalRows)(findEndRow(start2)(0) + overscan | 0);
      return {
        start: start2,
        end,
        topSpacerHeight
      };
    };
  };
  var applySorting = function(v2) {
    return function(v1) {
      if (v2.field instanceof Nothing) {
        return v1;
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortById) {
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare12(a3.id)(b2.id);
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare12(b2.id)(a3.id);
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 424, column 6 - line 426, column 65): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByName) {
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare3(toLower(a3.name))(toLower(b2.name));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare3(toLower(b2.name))(toLower(a3.name));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 429, column 6 - line 431, column 89): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByMoneyDebit) {
        var debitValue = function(c2) {
          var $240 = isNegative(c2.money);
          if ($240) {
            return negate2(c2.money);
          }
          ;
          return zero2;
        };
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare2(debitValue(a3))(debitValue(b2));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare2(debitValue(b2))(debitValue(a3));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 439, column 6 - line 441, column 87): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByMoneyCredit) {
        var creditValue = function(c2) {
          var $245 = isPositive(c2.money);
          if ($245) {
            return c2.money;
          }
          ;
          return zero2;
        };
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare2(creditValue(a3))(creditValue(b2));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare2(creditValue(b2))(creditValue(a3));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 446, column 6 - line 448, column 89): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldJewelryDebit) {
        var netWeight = function(c2) {
          return add3(c2.gram_jewelry)(multiply(c2.baht_jewelry)(gramsPerBahtJewelry));
        };
        var debitValue = function(c2) {
          var $250 = isNegative(netWeight(c2));
          if ($250) {
            return negate2(netWeight(c2));
          }
          ;
          return zero2;
        };
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare2(debitValue(a3))(debitValue(b2));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare2(debitValue(b2))(debitValue(a3));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 455, column 6 - line 457, column 87): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldJewelryCredit) {
        var netWeight = function(c2) {
          return add3(c2.gram_jewelry)(multiply(c2.baht_jewelry)(gramsPerBahtJewelry));
        };
        var creditValue = function(c2) {
          var $255 = isPositive(netWeight(c2));
          if ($255) {
            return netWeight(c2);
          }
          ;
          return zero2;
        };
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare2(creditValue(a3))(creditValue(b2));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare2(creditValue(b2))(creditValue(a3));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 463, column 6 - line 465, column 89): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldBar96Debit) {
        var netWeight = function(c2) {
          return add3(c2.gram_bar96)(multiply(c2.baht_bar96)(gramsPerBahtBar96));
        };
        var debitValue = function(c2) {
          var $260 = isNegative(netWeight(c2));
          if ($260) {
            return negate2(netWeight(c2));
          }
          ;
          return zero2;
        };
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare2(debitValue(a3))(debitValue(b2));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare2(debitValue(b2))(debitValue(a3));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 472, column 6 - line 474, column 87): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldBar96Credit) {
        var netWeight = function(c2) {
          return add3(c2.gram_bar96)(multiply(c2.baht_bar96)(gramsPerBahtBar96));
        };
        var creditValue = function(c2) {
          var $265 = isPositive(netWeight(c2));
          if ($265) {
            return netWeight(c2);
          }
          ;
          return zero2;
        };
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare2(creditValue(a3))(creditValue(b2));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare2(creditValue(b2))(creditValue(a3));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 480, column 6 - line 482, column 89): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldBar99Debit) {
        var netWeight = function(c2) {
          return add3(c2.gram_bar99)(multiply(c2.baht_bar99)(gramsPerBahtBar99));
        };
        var debitValue = function(c2) {
          var $270 = isNegative(netWeight(c2));
          if ($270) {
            return negate2(netWeight(c2));
          }
          ;
          return zero2;
        };
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare2(debitValue(a3))(debitValue(b2));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare2(debitValue(b2))(debitValue(a3));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 489, column 6 - line 491, column 87): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldBar99Credit) {
        var netWeight = function(c2) {
          return add3(c2.gram_bar99)(multiply(c2.baht_bar99)(gramsPerBahtBar99));
        };
        var creditValue = function(c2) {
          var $275 = isPositive(netWeight(c2));
          if ($275) {
            return netWeight(c2);
          }
          ;
          return zero2;
        };
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare2(creditValue(a3))(creditValue(b2));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare2(creditValue(b2))(creditValue(a3));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 497, column 6 - line 499, column 89): " + [v2.direction.constructor.name]);
      }
      ;
      if (v2.field instanceof Just && v2.field.value0 instanceof SortByUpdated) {
        var dateOnly = function(c2) {
          return extractDatePart(c2.updated_at);
        };
        var sorted = sortBy(function(a3) {
          return function(b2) {
            return compare3(dateOnly(a3))(dateOnly(b2));
          };
        })(v1);
        if (v2.direction instanceof Ascending) {
          return sorted;
        }
        ;
        if (v2.direction instanceof Descending) {
          return sortBy(function(a3) {
            return function(b2) {
              return compare3(dateOnly(b2))(dateOnly(a3));
            };
          })(v1);
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 505, column 6 - line 507, column 81): " + [v2.direction.constructor.name]);
      }
      ;
      throw new Error("Failed pattern match at Component.CustomerList (line 420, column 1 - line 420, column 62): " + [v2.constructor.name, v1.constructor.name]);
    };
  };
  var handleAction = function(dictMonadAff) {
    var MonadEffect0 = dictMonadAff.MonadEffect0();
    var lift1 = lift3(MonadEffect0.Monad0());
    var liftAff2 = liftAff(monadAffHalogenM(dictMonadAff));
    var liftEffect8 = liftEffect(monadEffectHalogenM(MonadEffect0));
    return function(db) {
      return function(v2) {
        if (v2 instanceof Initialize2) {
          return handleAction(dictMonadAff)(db)(LoadCustomers.value);
        }
        ;
        if (v2 instanceof LoadCustomers) {
          return bind4(lift1(db.getAllCustomers))(function(customers) {
            var latestTime = getLatestTimestamp(customers);
            return discard2(modify_3(function(v12) {
              var $285 = {};
              for (var $286 in v12) {
                if ({}.hasOwnProperty.call(v12, $286)) {
                  $285[$286] = v12[$286];
                }
                ;
              }
              ;
              $285.customers = customers;
              $285.lastSyncTime = latestTime;
              return $285;
            }))(function() {
              return discard2(raise(new CustomerCountChanged(length(customers))))(function() {
                return handleAction(dictMonadAff)(db)(PollForChanges.value);
              });
            });
          });
        }
        ;
        if (v2 instanceof PollForChanges) {
          return bind4(get3)(function(state3) {
            return when2(state3.pollingEnabled)(discard2((function() {
              if (state3.lastSyncTime instanceof Just) {
                return bind4(lift1(db.getChangesSince(state3.lastSyncTime.value0)))(function(changes) {
                  return when2(length(changes) > 0)(handleAction(dictMonadAff)(db)(new ApplyChanges(changes)));
                });
              }
              ;
              if (state3.lastSyncTime instanceof Nothing) {
                return pure1(unit);
              }
              ;
              throw new Error("Failed pattern match at Component.CustomerList (line 1697, column 7 - line 1702, column 29): " + [state3.lastSyncTime.constructor.name]);
            })())(function() {
              return $$void5(fork(discard2(liftAff2(delay(3e3)))(function() {
                return handleAction(dictMonadAff)(db)(PollForChanges.value);
              })));
            }));
          });
        }
        ;
        if (v2 instanceof ApplyChanges) {
          return bind4(get3)(function(state3) {
            var mergedCustomers = mergeCustomers(state3.customers)(v2.value0);
            var latestTime = getLatestTimestamp(v2.value0);
            return discard2(modify_3(function(v12) {
              var $290 = {};
              for (var $291 in v12) {
                if ({}.hasOwnProperty.call(v12, $291)) {
                  $290[$291] = v12[$291];
                }
                ;
              }
              ;
              $290.customers = mergedCustomers;
              $290.lastSyncTime = latestTime;
              return $290;
            }))(function() {
              return $$void5(fork(bind4(liftEffect8(requestAnimationFrameAction(unit)))(function(promise2) {
                return discard2($$void5(liftAff2(toAff(promise2))))(function() {
                  return handleAction(dictMonadAff)(db)(MeasureRenderedRows.value);
                });
              })));
            });
          });
        }
        ;
        if (v2 instanceof StartEditFieldWithEvent) {
          return discard2(liftEffect8(stopPropagation(toEvent(v2.value4))))(function() {
            return handleAction(dictMonadAff)(db)(new StartEditField(v2.value0, v2.value1, v2.value2, v2.value3));
          });
        }
        ;
        if (v2 instanceof StartEditField) {
          return bind4(get3)(function(state3) {
            return discard2((function() {
              if (state3.editing instanceof Just && (state3.editing.value0.customerId !== v2.value0 || notEq4(state3.editing.value0.field)(v2.value1))) {
                return handleAction(dictMonadAff)(db)(SaveEditField.value);
              }
              ;
              return pure1(unit);
            })())(function() {
              return discard2(modify_3(function(v12) {
                var $301 = {};
                for (var $302 in v12) {
                  if ({}.hasOwnProperty.call(v12, $302)) {
                    $301[$302] = v12[$302];
                  }
                  ;
                }
                ;
                $301.editing = new Just({
                  customerId: v2.value0,
                  field: v2.value1,
                  value: v2.value2,
                  originalValue: v2.value2,
                  isDebitSide: v2.value3
                });
                return $301;
              }))(function() {
                return handleAction(dictMonadAff)(db)(FocusEditInput.value);
              });
            });
          });
        }
        ;
        if (v2 instanceof UpdateEditValue) {
          return bind4(get3)(function(state3) {
            if (state3.editing instanceof Just) {
              return modify_3(function(v12) {
                var $312 = {};
                for (var $313 in v12) {
                  if ({}.hasOwnProperty.call(v12, $313)) {
                    $312[$313] = v12[$313];
                  }
                  ;
                }
                ;
                $312.editing = new Just((function() {
                  var $309 = {};
                  for (var $310 in state3.editing.value0) {
                    if ({}.hasOwnProperty.call(state3.editing.value0, $310)) {
                      $309[$310] = state3["editing"]["value0"][$310];
                    }
                    ;
                  }
                  ;
                  $309.value = v2.value0;
                  return $309;
                })());
                return $312;
              });
            }
            ;
            if (state3.editing instanceof Nothing) {
              return pure1(unit);
            }
            ;
            throw new Error("Failed pattern match at Component.CustomerList (line 1744, column 5 - line 1746, column 27): " + [state3.editing.constructor.name]);
          });
        }
        ;
        if (v2 instanceof SaveEditField) {
          return bind4(get3)(function(state3) {
            if (state3.editing instanceof Nothing) {
              return pure1(unit);
            }
            ;
            if (state3.editing instanceof Just) {
              var valueChanged = state3.editing.value0.value !== state3.editing.value0.originalValue;
              var v12 = parseFieldValue(state3.editing.value0.field)(state3.editing.value0.value);
              if (v12 instanceof Nothing) {
                return handleAction(dictMonadAff)(db)(CancelEdit.value);
              }
              ;
              if (v12 instanceof Just) {
                var finalValue = (function() {
                  if (state3.editing.value0.field instanceof FieldMoney) {
                    if (state3.editing.value0.isDebitSide) {
                      return "-" + v12.value0;
                    }
                    ;
                    return v12.value0;
                  }
                  ;
                  if (state3.editing.value0.isDebitSide) {
                    return "-" + v12.value0;
                  }
                  ;
                  return v12.value0;
                })();
                return bind4(lift1(db.updateCustomerField({
                  id: state3.editing.value0.customerId,
                  field: getDbFieldName(state3.editing.value0.field),
                  value: finalValue
                })))(function(updatedCustomer) {
                  return discard2(modify_3(function(v22) {
                    var $324 = {};
                    for (var $325 in v22) {
                      if ({}.hasOwnProperty.call(v22, $325)) {
                        $324[$325] = v22[$325];
                      }
                      ;
                    }
                    ;
                    $324.editing = Nothing.value;
                    $324.searchQuery = "";
                    $324.customers = map18(function(c2) {
                      var $322 = c2.id === state3.editing.value0.customerId;
                      if ($322) {
                        return updatedCustomer;
                      }
                      ;
                      return c2;
                    })(state3.customers);
                    $324.lastSyncTime = updatedCustomer.updated_at;
                    $324.highlightedCustomerId = (function() {
                      if (valueChanged) {
                        return new Just(state3.editing.value0.customerId);
                      }
                      ;
                      return Nothing.value;
                    })();
                    return $324;
                  }))(function() {
                    return when2(valueChanged)(handleAction(dictMonadAff)(db)(new RenderAroundAndScrollTo(state3.editing.value0.customerId)));
                  });
                });
              }
              ;
              throw new Error("Failed pattern match at Component.CustomerList (line 1755, column 9 - line 1784, column 72): " + [v12.constructor.name]);
            }
            ;
            throw new Error("Failed pattern match at Component.CustomerList (line 1750, column 5 - line 1784, column 72): " + [state3.editing.constructor.name]);
          });
        }
        ;
        if (v2 instanceof SaveEditOnEnter) {
          var v1 = key(v2.value0);
          if (v1 === "Enter") {
            return handleAction(dictMonadAff)(db)(SaveEditField.value);
          }
          ;
          if (v1 === "Escape") {
            return handleAction(dictMonadAff)(db)(CancelEdit.value);
          }
          ;
          return pure1(unit);
        }
        ;
        if (v2 instanceof CancelEdit) {
          return modify_3(function(v12) {
            var $331 = {};
            for (var $332 in v12) {
              if ({}.hasOwnProperty.call(v12, $332)) {
                $331[$332] = v12[$332];
              }
              ;
            }
            ;
            $331.editing = Nothing.value;
            return $331;
          });
        }
        ;
        if (v2 instanceof CancelEditOnClickOutside) {
          return bind4(get3)(function(state3) {
            if (state3.editing instanceof Just) {
              var eventTarget = toEvent(v2.value0);
              var v12 = target(eventTarget);
              if (v12 instanceof Just) {
                return bind4(liftEffect8(checkClickOutsideInput(v12.value0)))(function(isOutside) {
                  return when2(isOutside)(handleAction(dictMonadAff)(db)(SaveEditField.value));
                });
              }
              ;
              if (v12 instanceof Nothing) {
                return pure1(unit);
              }
              ;
              throw new Error("Failed pattern match at Component.CustomerList (line 1801, column 9 - line 1806, column 31): " + [v12.constructor.name]);
            }
            ;
            if (state3.editing instanceof Nothing) {
              return pure1(unit);
            }
            ;
            throw new Error("Failed pattern match at Component.CustomerList (line 1797, column 5 - line 1807, column 27): " + [state3.editing.constructor.name]);
          });
        }
        ;
        if (v2 instanceof UpdateNewName) {
          return modify_3(function(v12) {
            var $339 = {};
            for (var $340 in v12) {
              if ({}.hasOwnProperty.call(v12, $340)) {
                $339[$340] = v12[$340];
              }
              ;
            }
            ;
            $339.newCustomerName = v2.value0;
            return $339;
          });
        }
        ;
        if (v2 instanceof AddCustomer) {
          return discard2(liftEffect8(preventDefault(v2.value0)))(function() {
            return bind4(get3)(function(state3) {
              return when2(state3.newCustomerName !== "")(bind4(lift1(db.addNewCustomer(state3.newCustomerName)))(function(newCustomer) {
                return discard2(modify_3(function(v12) {
                  var $343 = {};
                  for (var $344 in v12) {
                    if ({}.hasOwnProperty.call(v12, $344)) {
                      $343[$344] = v12[$344];
                    }
                    ;
                  }
                  ;
                  $343.newCustomerName = "";
                  $343.searchQuery = "";
                  $343.customers = snoc(state3.customers)(newCustomer);
                  $343.lastSyncTime = newCustomer.updated_at;
                  $343.highlightedCustomerId = new Just(newCustomer.id);
                  return $343;
                }))(function() {
                  return handleAction(dictMonadAff)(db)(new RenderAroundAndScrollTo(newCustomer.id));
                });
              }));
            });
          });
        }
        ;
        if (v2 instanceof ShowDeleteConfirmation) {
          return bind4(liftEffect8(generateRandomCode))(function(randomCode) {
            return discard2(modify_3(function(v12) {
              var $347 = {};
              for (var $348 in v12) {
                if ({}.hasOwnProperty.call(v12, $348)) {
                  $347[$348] = v12[$348];
                }
                ;
              }
              ;
              $347.deleteConfirmation = new Just({
                customerId: v2.value0,
                confirmCode: randomCode,
                inputValue: ""
              });
              return $347;
            }))(function() {
              return handleAction(dictMonadAff)(db)(FocusDeleteInput.value);
            });
          });
        }
        ;
        if (v2 instanceof UpdateDeleteConfirmInput) {
          return bind4(get3)(function(state3) {
            if (state3.deleteConfirmation instanceof Just) {
              return modify_3(function(v12) {
                var $355 = {};
                for (var $356 in v12) {
                  if ({}.hasOwnProperty.call(v12, $356)) {
                    $355[$356] = v12[$356];
                  }
                  ;
                }
                ;
                $355.deleteConfirmation = new Just((function() {
                  var $352 = {};
                  for (var $353 in state3.deleteConfirmation.value0) {
                    if ({}.hasOwnProperty.call(state3.deleteConfirmation.value0, $353)) {
                      $352[$353] = state3["deleteConfirmation"]["value0"][$353];
                    }
                    ;
                  }
                  ;
                  $352.inputValue = v2.value0;
                  return $352;
                })());
                return $355;
              });
            }
            ;
            if (state3.deleteConfirmation instanceof Nothing) {
              return pure1(unit);
            }
            ;
            throw new Error("Failed pattern match at Component.CustomerList (line 1836, column 5 - line 1839, column 27): " + [state3.deleteConfirmation.constructor.name]);
          });
        }
        ;
        if (v2 instanceof ConfirmDelete) {
          return bind4(get3)(function(state3) {
            if (state3.deleteConfirmation instanceof Just && state3.deleteConfirmation.value0.customerId === v2.value0) {
              var $361 = state3.deleteConfirmation.value0.inputValue === show6(state3.deleteConfirmation.value0.confirmCode);
              if ($361) {
                return discard2(lift1(db.deleteCustomer(v2.value0)))(function() {
                  var newCustomers = filter(function(c2) {
                    return c2.id !== v2.value0;
                  })(state3.customers);
                  return discard2(modify_3(function(v12) {
                    var $362 = {};
                    for (var $363 in v12) {
                      if ({}.hasOwnProperty.call(v12, $363)) {
                        $362[$363] = v12[$363];
                      }
                      ;
                    }
                    ;
                    $362.customers = newCustomers;
                    $362.highlightedCustomerId = Nothing.value;
                    $362.deleteConfirmation = Nothing.value;
                    return $362;
                  }))(function() {
                    return $$void5(fork(bind4(liftEffect8(getCustomerListElement))(function(mbContainer) {
                      if (mbContainer instanceof Just) {
                        return bind4(liftEffect8(getScrollTop(mbContainer.value0)))(function(scrollTop2) {
                          return bind4(liftEffect8(getClientHeight(mbContainer.value0)))(function(clientHeight2) {
                            return discard2(modify_3(function(v12) {
                              var $366 = {};
                              for (var $367 in v12) {
                                if ({}.hasOwnProperty.call(v12, $367)) {
                                  $366[$367] = v12[$367];
                                }
                                ;
                              }
                              ;
                              $366.scrollTop = scrollTop2;
                              $366.containerHeight = clientHeight2;
                              return $366;
                            }))(function() {
                              return handleAction(dictMonadAff)(db)(MeasureRenderedRows.value);
                            });
                          });
                        });
                      }
                      ;
                      if (mbContainer instanceof Nothing) {
                        return pure1(unit);
                      }
                      ;
                      throw new Error("Failed pattern match at Component.CustomerList (line 1857, column 13 - line 1866, column 35): " + [mbContainer.constructor.name]);
                    })));
                  });
                });
              }
              ;
              return pure1(unit);
            }
            ;
            return pure1(unit);
          });
        }
        ;
        if (v2 instanceof CancelDelete) {
          return modify_3(function(v12) {
            var $372 = {};
            for (var $373 in v12) {
              if ({}.hasOwnProperty.call(v12, $373)) {
                $372[$373] = v12[$373];
              }
              ;
            }
            ;
            $372.deleteConfirmation = Nothing.value;
            return $372;
          });
        }
        ;
        if (v2 instanceof FocusDeleteInput) {
          return liftEffect8(focusDeleteConfirmInput);
        }
        ;
        if (v2 instanceof FocusEditInput) {
          return liftEffect8(focusEditInput);
        }
        ;
        if (v2 instanceof SortBy) {
          return bind4(get3)(function(state3) {
            var newSortState = (function() {
              if (state3.sortState.field instanceof Just && eq4(state3.sortState.field.value0)(v2.value0)) {
                return {
                  field: new Just(v2.value0),
                  direction: toggleDirection(state3.sortState.direction)
                };
              }
              ;
              return {
                field: new Just(v2.value0),
                direction: Ascending.value
              };
            })();
            return modify_3(function(v12) {
              var $377 = {};
              for (var $378 in v12) {
                if ({}.hasOwnProperty.call(v12, $378)) {
                  $377[$378] = v12[$378];
                }
                ;
              }
              ;
              $377.sortState = newSortState;
              return $377;
            });
          });
        }
        ;
        if (v2 instanceof HandleScroll) {
          var mbTarget = target(v2.value0);
          var v1 = bind12(mbTarget)(fromEventTarget2);
          if (v1 instanceof Just) {
            return bind4(liftEffect8(getScrollTop(v1.value0)))(function(scrollTop2) {
              return bind4(liftEffect8(getClientHeight(v1.value0)))(function(clientHeight2) {
                return discard2(modify_3(function(v22) {
                  var $382 = {};
                  for (var $383 in v22) {
                    if ({}.hasOwnProperty.call(v22, $383)) {
                      $382[$383] = v22[$383];
                    }
                    ;
                  }
                  ;
                  $382.scrollTop = scrollTop2;
                  $382.containerHeight = clientHeight2;
                  return $382;
                }))(function() {
                  return handleAction(dictMonadAff)(db)(MeasureRenderedRows.value);
                });
              });
            });
          }
          ;
          if (v1 instanceof Nothing) {
            return pure1(unit);
          }
          ;
          throw new Error("Failed pattern match at Component.CustomerList (line 1895, column 5 - line 1904, column 27): " + [v1.constructor.name]);
        }
        ;
        if (v2 instanceof MeasureRenderedRows) {
          return bind4(liftEffect8(measureRowHeights))(function(measurements) {
            return bind4(get3)(function(state3) {
              var updateCustomer = function(customer) {
                var v12 = find2(function(m2) {
                  return m2.customerId === customer.id;
                })(measurements);
                if (v12 instanceof Just) {
                  return {
                    id: customer.id,
                    name: customer.name,
                    money: customer.money,
                    gram_jewelry: customer.gram_jewelry,
                    baht_jewelry: customer.baht_jewelry,
                    gram_bar96: customer.gram_bar96,
                    baht_bar96: customer.baht_bar96,
                    gram_bar99: customer.gram_bar99,
                    baht_bar99: customer.baht_bar99,
                    created_at: customer.created_at,
                    updated_at: customer.updated_at,
                    rowHeight: new Just(v12.value0.height)
                  };
                }
                ;
                if (v12 instanceof Nothing) {
                  return customer;
                }
                ;
                throw new Error("Failed pattern match at Component.CustomerList (line 1913, column 9 - line 1915, column 30): " + [v12.constructor.name]);
              };
              var updatedCustomers = map18(updateCustomer)(state3.customers);
              return modify_3(function(v12) {
                var $389 = {};
                for (var $390 in v12) {
                  if ({}.hasOwnProperty.call(v12, $390)) {
                    $389[$390] = v12[$390];
                  }
                  ;
                }
                ;
                $389.customers = updatedCustomers;
                return $389;
              });
            });
          });
        }
        ;
        if (v2 instanceof UpdateRenderedRange) {
          return modify_3(function(v12) {
            var $392 = {};
            for (var $393 in v12) {
              if ({}.hasOwnProperty.call(v12, $393)) {
                $392[$393] = v12[$393];
              }
              ;
            }
            ;
            $392.renderedRange = {
              start: v2.value0,
              end: v2.value1
            };
            return $392;
          });
        }
        ;
        if (v2 instanceof RenderAroundAndScrollTo) {
          return $$void5(fork(bind4(get3)(function(state3) {
            var filteredCustomers = filterCustomers(state3.searchQuery)(state3.customers);
            var sortedCustomers = applySorting(state3.sortState)(filteredCustomers);
            var v12 = findIndex(function(c2) {
              return c2.id === v2.value0;
            })(sortedCustomers);
            if (v12 instanceof Just) {
              return bind4(liftEffect8(getCustomerListElement))(function(mbContainer) {
                return bind4((function() {
                  if (mbContainer instanceof Just) {
                    return liftEffect8(getClientHeight(mbContainer.value0));
                  }
                  ;
                  if (mbContainer instanceof Nothing) {
                    return pure1(state3.containerHeight);
                  }
                  ;
                  throw new Error("Failed pattern match at Component.CustomerList (line 1949, column 27 - line 1951, column 50): " + [mbContainer.constructor.name]);
                })())(function(actualHeight) {
                  return discard2(when2(actualHeight !== state3.containerHeight)(modify_3(function(v22) {
                    var $400 = {};
                    for (var $401 in v22) {
                      if ({}.hasOwnProperty.call(v22, $401)) {
                        $400[$401] = v22[$401];
                      }
                      ;
                    }
                    ;
                    $400.containerHeight = actualHeight;
                    return $400;
                  })))(function() {
                    var roughYPosition = calculateHeightRange(sortedCustomers)(0)(v12.value0);
                    var roughScrollTop = max1(0)(roughYPosition - actualHeight + 100);
                    return discard2(liftEffect8(scrollToPosition(roughScrollTop)))(function() {
                      return bind4(liftEffect8(waitForRowAndMeasureImpl(v12.value0)))(function(promise2) {
                        return bind4(liftAff2(toAff(promise2)))(function(result) {
                          return discard2(handleAction(dictMonadAff)(db)(MeasureRenderedRows.value))(function() {
                            var targetScrollTop = max1(0)(result.offsetTop + result.height - actualHeight);
                            return liftEffect8(scrollToPosition(targetScrollTop));
                          });
                        });
                      });
                    });
                  });
                });
              });
            }
            ;
            if (v12 instanceof Nothing) {
              return pure1(unit);
            }
            ;
            throw new Error("Failed pattern match at Component.CustomerList (line 1945, column 7 - line 1972, column 29): " + [v12.constructor.name]);
          })));
        }
        ;
        if (v2 instanceof ScrollToCustomer) {
          return bind4(get3)(function(state3) {
            var filteredCustomers = filterCustomers(state3.searchQuery)(state3.customers);
            var sortedCustomers = applySorting(state3.sortState)(filteredCustomers);
            var v12 = find2(function(c2) {
              return c2.name === v2.value0;
            })(sortedCustomers);
            if (v12 instanceof Just) {
              return handleAction(dictMonadAff)(db)(new RenderAroundAndScrollTo(v12.value0.id));
            }
            ;
            if (v12 instanceof Nothing) {
              return pure1(unit);
            }
            ;
            throw new Error("Failed pattern match at Component.CustomerList (line 1978, column 5 - line 1980, column 27): " + [v12.constructor.name]);
          });
        }
        ;
        if (v2 instanceof ScrollToCustomerId) {
          return handleAction(dictMonadAff)(db)(new RenderAroundAndScrollTo(v2.value0));
        }
        ;
        if (v2 instanceof UpdateSearchQuery) {
          return modify_3(function(v12) {
            var $409 = {};
            for (var $410 in v12) {
              if ({}.hasOwnProperty.call(v12, $410)) {
                $409[$410] = v12[$410];
              }
              ;
            }
            ;
            $409.searchQuery = v2.value0;
            return $409;
          });
        }
        ;
        throw new Error("Failed pattern match at Component.CustomerList (line 1680, column 19 - line 1986, column 40): " + [v2.constructor.name]);
      };
    };
  };
  var renderCustomerRow = function(state3) {
    return function(customer) {
      return function(startIdx) {
        var isPendingDelete = (function() {
          if (state3.deleteConfirmation instanceof Just) {
            return state3.deleteConfirmation.value0.customerId === customer.id;
          }
          ;
          if (state3.deleteConfirmation instanceof Nothing) {
            return false;
          }
          ;
          throw new Error("Failed pattern match at Component.CustomerList (line 820, column 23 - line 822, column 23): " + [state3.deleteConfirmation.constructor.name]);
        })();
        var isHighlighted = eq32(state3.highlightedCustomerId)(new Just(customer.id));
        var isEditingField = function(field) {
          if (state3.editing instanceof Just) {
            return state3.editing.value0.customerId === customer.id && eq5(state3.editing.value0.field)(field);
          }
          ;
          if (state3.editing instanceof Nothing) {
            return false;
          }
          ;
          throw new Error("Failed pattern match at Component.CustomerList (line 816, column 28 - line 818, column 23): " + [state3.editing.constructor.name]);
        };
        var filteredCustomers = filterCustomers(state3.searchQuery)(state3.customers);
        var sortedCustomers = applySorting(state3.sortState)(filteredCustomers);
        var customerIndex = (function() {
          var v2 = findIndex(function(c2) {
            return c2.id === customer.id;
          })(sortedCustomers);
          if (v2 instanceof Just) {
            return v2.value0;
          }
          ;
          if (v2 instanceof Nothing) {
            return 0;
          }
          ;
          throw new Error("Failed pattern match at Component.CustomerList (line 826, column 21 - line 828, column 19): " + [v2.constructor.name]);
        })();
        var isEvenRow = mod3(customerIndex)(2) === 0;
        var rowClasses = (function() {
          if (isPendingDelete) {
            return "customer-row customer-row-pending-delete";
          }
          ;
          if (isHighlighted) {
            return "customer-row customer-row-highlighted";
          }
          ;
          if (isEvenRow) {
            return "customer-row customer-row-even";
          }
          ;
          return "customer-row customer-row-odd";
        })();
        return div2([class_(rowClasses), attr2("data-row-index")(show6(customerIndex)), attr2("data-customer-id")(show6(customer.id))])([span2([class_("customer-id")])([text(show6(customer.id))]), renderEditableField(state3)(customer)(FieldName.value)("customer-name")("customer-name-input"), renderMoneyField(state3)(customer)(true), renderMoneyField(state3)(customer)(false), div2([class_("customer-gold-debit")])([div_([div2([class_("gold-grams")])([renderGoldField(state3)(customer)(FieldGoldJewelryGrams.value)(true)(textConstants.unitGrams)(renderGrams)(customer.gram_jewelry)]), div2([class_("gold-baht")])([renderGoldField(state3)(customer)(FieldGoldJewelryBaht.value)(true)(textConstants.unitBaht)(renderBaht)(customer.baht_jewelry)])])]), div2([class_("customer-gold-credit")])([div_([div2([class_("gold-grams")])([renderGoldField(state3)(customer)(FieldGoldJewelryGrams.value)(false)(textConstants.unitGrams)(renderGrams)(customer.gram_jewelry)]), div2([class_("gold-baht")])([renderGoldField(state3)(customer)(FieldGoldJewelryBaht.value)(false)(textConstants.unitBaht)(renderBaht)(customer.baht_jewelry)])])]), div2([class_("customer-gold-debit")])([div_([div2([class_("gold-grams")])([renderGoldField(state3)(customer)(FieldGoldBar96Grams.value)(true)(textConstants.unitGrams)(renderGrams)(customer.gram_bar96)]), div2([class_("gold-baht")])([renderGoldField(state3)(customer)(FieldGoldBar96Baht.value)(true)(textConstants.unitBaht)(renderBaht)(customer.baht_bar96)])])]), div2([class_("customer-gold-credit")])([div_([div2([class_("gold-grams")])([renderGoldField(state3)(customer)(FieldGoldBar96Grams.value)(false)(textConstants.unitGrams)(renderGrams)(customer.gram_bar96)]), div2([class_("gold-baht")])([renderGoldField(state3)(customer)(FieldGoldBar96Baht.value)(false)(textConstants.unitBaht)(renderBaht)(customer.baht_bar96)])])]), div2([class_("customer-gold-debit")])([div_([div2([class_("gold-grams")])([renderGoldField(state3)(customer)(FieldGoldBar99Grams.value)(true)(textConstants.unitGrams)(renderGrams)(customer.gram_bar99)]), div2([class_("gold-baht")])([renderGoldField(state3)(customer)(FieldGoldBar99Baht.value)(true)(textConstants.unitBaht)(renderBaht)(customer.baht_bar99)])])]), div2([class_("customer-gold-credit")])([div_([div2([class_("gold-grams")])([renderGoldField(state3)(customer)(FieldGoldBar99Grams.value)(false)(textConstants.unitGrams)(renderGrams)(customer.gram_bar99)]), div2([class_("gold-baht")])([renderGoldField(state3)(customer)(FieldGoldBar99Baht.value)(false)(textConstants.unitBaht)(renderBaht)(customer.baht_bar99)])])]), span2([class_("customer-updated")])([text((function() {
          if (customer.updated_at instanceof Just) {
            return formatDateString(customer.updated_at.value0);
          }
          ;
          if (customer.updated_at instanceof Nothing) {
            return "";
          }
          ;
          throw new Error("Failed pattern match at Component.CustomerList (line 908, column 23 - line 910, column 28): " + [customer.updated_at.constructor.name]);
        })())]), div2([class_("customer-actions")])([button([class_("btn btn-delete"), onClick(function(v2) {
          return new ShowDeleteConfirmation(customer.id);
        }), title("Delete")])([deleteIcon])])]);
      };
    };
  };
  var render = function(state3) {
    var filteredCustomers = filterCustomers(state3.searchQuery)(state3.customers);
    var sortedCustomers = applySorting(state3.sortState)(filteredCustomers);
    var totalRows = length(sortedCustomers);
    var v2 = (function() {
      if (state3.forceRenderRange) {
        return {
          start: state3.renderedRange.start,
          end: state3.renderedRange.end,
          topSpacerHeight: calculateHeightRange(sortedCustomers)(0)(state3.renderedRange.start)
        };
      }
      ;
      return calculateVisibleRange(state3)(sortedCustomers);
    })();
    var visibleCustomers = slice(v2.start)(v2.end)(sortedCustomers);
    var totalHeight = calculateHeightRange(sortedCustomers)(0)(totalRows);
    return div2([class_("app-wrapper"), onClick(CancelEditOnClickOutside.create)])([div2([class_("customer-app")])([div2([class_("customer-list-container")])([renderTableHeader(state3), div2([class_("customer-list"), onScroll(HandleScroll.create)])([div2([class_("scroll-spacer"), attr2("style")("height: " + (show13(totalHeight) + "px"))])([]), div2([class_("visible-rows"), attr2("style")("transform: translateY(" + (show13(v2.topSpacerHeight) + "px)")), id2("visible-rows-container")])(map18(function(c2) {
      return renderCustomerRow(state3)(c2)(v2.start);
    })(visibleCustomers))]), renderTableFooter(state3)]), renderDeleteConfirmationDialog(state3), renderStyles])]);
  };
  var component = function(dictMonadAff) {
    var handleAction1 = handleAction(dictMonadAff);
    return function(db) {
      return mkComponent({
        initialState: function(v2) {
          return {
            customers: [],
            editing: Nothing.value,
            newCustomerName: "",
            sortState: {
              field: new Just(SortByName.value),
              direction: Ascending.value
            },
            scrollTop: 0,
            containerHeight: 600,
            searchQuery: "",
            renderedRange: {
              start: 0,
              end: 20
            },
            topSpacerHeight: 0,
            lastSyncTime: Nothing.value,
            pollingEnabled: true,
            forceRenderRange: false,
            highlightedCustomerId: Nothing.value,
            deleteConfirmation: Nothing.value
          };
        },
        render,
        "eval": mkEval({
          handleQuery: defaultEval.handleQuery,
          receive: defaultEval.receive,
          finalize: defaultEval.finalize,
          handleAction: handleAction1(db),
          initialize: new Just(Initialize2.value)
        })
      });
    };
  };

  // output/Effect.Console/foreign.js
  var log3 = function(s2) {
    return function() {
      console.log(s2);
    };
  };
  var warn = function(s2) {
    return function() {
      console.warn(s2);
    };
  };

  // output/Effect.Class.Console/index.js
  var log4 = function(dictMonadEffect) {
    var $67 = liftEffect(dictMonadEffect);
    return function($68) {
      return $67(log3($68));
    };
  };

  // output/Component.POS/index.js
  var show7 = /* @__PURE__ */ show(showInt);
  var map19 = /* @__PURE__ */ map(functorArray);
  var type_5 = /* @__PURE__ */ type_(isPropInputType);
  var value4 = /* @__PURE__ */ value(isPropString);
  var bind5 = /* @__PURE__ */ bind(bindHalogenM);
  var get4 = /* @__PURE__ */ get(monadStateHalogenM);
  var lift4 = /* @__PURE__ */ lift(monadTransHalogenM);
  var discard3 = /* @__PURE__ */ discard(discardUnit)(bindHalogenM);
  var modify_4 = /* @__PURE__ */ modify_2(monadStateHalogenM);
  var pure7 = /* @__PURE__ */ pure(applicativeHalogenM);
  var show14 = /* @__PURE__ */ show(showBoolean);
  var TodaysBillsView = /* @__PURE__ */ (function() {
    function TodaysBillsView2() {
    }
    ;
    TodaysBillsView2.value = new TodaysBillsView2();
    return TodaysBillsView2;
  })();
  var CustomerBillsView = /* @__PURE__ */ (function() {
    function CustomerBillsView2(value0) {
      this.value0 = value0;
    }
    ;
    CustomerBillsView2.create = function(value0) {
      return new CustomerBillsView2(value0);
    };
    return CustomerBillsView2;
  })();
  var NavigateToCustomers = /* @__PURE__ */ (function() {
    function NavigateToCustomers2() {
    }
    ;
    NavigateToCustomers2.value = new NavigateToCustomers2();
    return NavigateToCustomers2;
  })();
  var Initialize3 = /* @__PURE__ */ (function() {
    function Initialize4() {
    }
    ;
    Initialize4.value = new Initialize4();
    return Initialize4;
  })();
  var UpdateSearchQuery2 = /* @__PURE__ */ (function() {
    function UpdateSearchQuery3(value0) {
      this.value0 = value0;
    }
    ;
    UpdateSearchQuery3.create = function(value0) {
      return new UpdateSearchQuery3(value0);
    };
    return UpdateSearchQuery3;
  })();
  var ClearSearch = /* @__PURE__ */ (function() {
    function ClearSearch2() {
    }
    ;
    ClearSearch2.value = new ClearSearch2();
    return ClearSearch2;
  })();
  var SelectCustomer = /* @__PURE__ */ (function() {
    function SelectCustomer2(value0) {
      this.value0 = value0;
    }
    ;
    SelectCustomer2.create = function(value0) {
      return new SelectCustomer2(value0);
    };
    return SelectCustomer2;
  })();
  var OpenCustomerManagement = /* @__PURE__ */ (function() {
    function OpenCustomerManagement2() {
    }
    ;
    OpenCustomerManagement2.value = new OpenCustomerManagement2();
    return OpenCustomerManagement2;
  })();
  var DeleteBill = /* @__PURE__ */ (function() {
    function DeleteBill2(value0) {
      this.value0 = value0;
    }
    ;
    DeleteBill2.create = function(value0) {
      return new DeleteBill2(value0);
    };
    return DeleteBill2;
  })();
  var OpenBillEditor = /* @__PURE__ */ (function() {
    function OpenBillEditor2(value0) {
      this.value0 = value0;
    }
    ;
    OpenBillEditor2.create = function(value0) {
      return new OpenBillEditor2(value0);
    };
    return OpenBillEditor2;
  })();
  var CreateNewBill = /* @__PURE__ */ (function() {
    function CreateNewBill2() {
    }
    ;
    CreateNewBill2.value = new CreateNewBill2();
    return CreateNewBill2;
  })();
  var renderStyles2 = /* @__PURE__ */ style_([/* @__PURE__ */ text("\n      .pos-container {\n        padding: 20px;\n        max-width: 1400px;\n        margin: 0 auto;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .pos-header {\n        margin-bottom: 20px;\n      }\n      \n      .pos-header h1 {\n        margin: 0;\n        font-size: 24px;\n        color: #333;\n      }\n      \n      /* Search box */\n      .pos-search-container {\n        display: flex;\n        gap: 8px;\n        margin-bottom: 20px;\n      }\n      \n      .pos-search-box {\n        position: relative;\n        width: 600px;\n      }\n      \n      .pos-search-input {\n        width: 100%;\n        padding: 10px 40px 10px 12px;\n        font-size: 16px;\n        border: 1px solid #ddd;\n        border-radius: 4px;\n        box-sizing: border-box;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .pos-search-input:focus {\n        outline: none;\n        border-color: #007bff;\n      }\n      \n      .pos-search-clear {\n        position: absolute;\n        right: 8px;\n        top: 50%;\n        transform: translateY(-50%);\n        background: none;\n        border: none;\n        font-size: 24px;\n        cursor: pointer;\n        color: #999;\n        padding: 0 8px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .pos-search-clear:hover {\n        color: #333;\n      }\n      \n\n      \n      /* Search popup */\n      .pos-search-popup {\n        position: absolute;\n        top: 100%;\n        left: 0;\n        right: 0;\n        background: white;\n        border: 1px solid #ddd;\n        border-top: none;\n        border-radius: 0 0 4px 4px;\n        box-shadow: 0 4px 6px rgba(0,0,0,0.1);\n        max-height: 300px;\n        overflow-y: auto;\n        z-index: 1000;\n      }\n      \n      .pos-search-result {\n        padding: 12px;\n        border-bottom: 1px solid #eee;\n        cursor: pointer;\n      }\n      \n      .pos-search-result:hover {\n        background: #f5f5f5;\n      }\n      \n      .pos-search-result-name {\n        font-weight: 500;\n        font-size: 14px;\n      }\n      \n      .pos-search-no-results {\n        padding: 12px;\n        color: #999;\n        text-align: center;\n      }\n      \n      /* Content area */\n      .pos-content {\n        margin-top: 20px;\n      }\n      \n      .pos-content h2 {\n        margin: 0 0 16px 0;\n        font-size: 20px;\n        color: #333;\n      }\n      \n      /* Tables */\n      .pos-table {\n        width: 100%;\n        border-collapse: collapse;\n        background: white;\n        border: 1px solid #ddd;\n      }\n      \n      .pos-table th {\n        background: #f8f9fa;\n        padding: 12px 8px;\n        text-align: left;\n        font-weight: 600;\n        border-bottom: 2px solid #dee2e6;\n      }\n      \n      .pos-table td {\n        padding: 12px 8px;\n        border-bottom: 1px solid #eee;\n        vertical-align: top;\n      }\n      \n      .pos-table tr:hover {\n        background: #f5f5f5;\n      }\n      \n      /* Today's Bills table */\n      .pos-time-col {\n        text-align: right;\n        width: 80px;\n      }\n      \n      .pos-customer-name-cell {\n        cursor: pointer;\n      }\n      \n      .pos-customer-name-cell:hover {\n        background: #e8f4f8 !important;\n        text-decoration: underline;\n      }\n      \n      /* Customer Bills table */\n      .pos-date-col {\n        text-align: right;\n        width: 100px;\n      }\n      \n      .pos-gold-label {\n        text-align: left;\n        width: 120px;\n        line-height: 1.6;\n      }\n      \n      .pos-gold-value {\n        text-align: right;\n        width: 100px;\n        line-height: 1.6;\n      }\n      \n      .pos-money-label {\n        text-align: left;\n        width: 80px;\n      }\n      \n      .pos-money-value {\n        text-align: right;\n        width: 100px;\n      }\n      \n      .pos-actions-col {\n        text-align: center;\n        width: 60px;\n      }\n      \n      /* Clickable cells */\n      .pos-clickable-gold,\n      .pos-clickable-money {\n        cursor: pointer;\n      }\n      \n      .pos-gold-label:hover,\n      .pos-gold-label:hover + .pos-gold-value {\n        background: #e8f4f8 !important;\n      }\n      \n      .pos-gold-value:hover {\n        background: #e8f4f8 !important;\n      }\n      \n      .pos-money-label:hover,\n      .pos-money-label:hover + .pos-money-value {\n        background: #e8f4f8 !important;\n      }\n      \n      .pos-money-value:hover {\n        background: #e8f4f8 !important;\n      }\n      \n      /* Settlement row */\n      .pos-settlement-row {\n        background: #e3f2fd !important;\n        font-weight: 500;\n      }\n      \n      .pos-settlement-row .pos-clickable-gold:hover,\n      .pos-settlement-row .pos-clickable-money:hover {\n        background: #bbdefb !important;\n      }\n      \n      /* New bill row */\n      .pos-new-bill-row {\n        background: #fff9c4 !important;\n        text-align: center;\n        cursor: pointer;\n      }\n      \n      .pos-new-bill-row:hover {\n        background: #fff59d !important;\n      }\n      \n      .pos-new-bill-row td {\n        padding: 20px;\n        font-size: 24px;\n      }\n      \n      /* Icon buttons */\n      .pos-icon-btn {\n        background: none;\n        border: none;\n        font-size: 20px;\n        cursor: pointer;\n        padding: 4px 8px;\n        color: #666;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .pos-icon-btn:hover {\n        color: #333;\n      }\n      \n      .pos-delete-btn:hover {\n        color: #dc3545;\n      }\n    ")]);
  var renderSettlementRow = function(customer) {
    return tr([class_("pos-settlement-row")])([td([class_("pos-date-col")])([text("2024-11-18")]), td([class_("pos-gold-label pos-clickable-gold"), onClick(function(v2) {
      return new OpenBillEditor(Nothing.value);
    })])([text("\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E17\u0E2D\u0E07")]), td([class_("pos-gold-value pos-clickable-gold"), onClick(function(v2) {
      return new OpenBillEditor(Nothing.value);
    })])([text("10.500g")]), td([class_("pos-money-label pos-clickable-money"), onClick(function(v2) {
      return new OpenBillEditor(Nothing.value);
    })])([text("\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E40\u0E07\u0E34\u0E19")]), td([class_("pos-money-value pos-clickable-money"), onClick(function(v2) {
      return new OpenBillEditor(Nothing.value);
    })])([text("5,000")]), td([class_("pos-actions-col")])([text("")])]);
  };
  var renderSearchResult = function(customer) {
    return div2([class_("pos-search-result"), onClick(function(v2) {
      return new SelectCustomer(customer);
    })])([div2([class_("pos-search-result-name")])([text(customer.name + (" (ID: " + (show7(customer.id) + ")")))])]);
  };
  var renderSearchPopup = function(state3) {
    return div2([class_("pos-search-popup")])((function() {
      var $40 = length(state3.searchResults) === 0;
      if ($40) {
        return [div2([class_("pos-search-no-results")])([text(posConstants.noCustomersFound)])];
      }
      ;
      return map19(renderSearchResult)(state3.searchResults);
    })());
  };
  var renderSearchBox = function(state3) {
    return div2([class_("pos-search-container")])([div2([class_("pos-search-box")])([input([type_5(InputText.value), class_("pos-search-input"), placeholder(posConstants.searchPlaceholder), value4(state3.searchQuery), onValueInput(UpdateSearchQuery2.create)]), (function() {
      var $41 = state3.searchQuery !== "";
      if ($41) {
        return button([class_("pos-search-clear"), onClick(function(v2) {
          return ClearSearch.value;
        })])([text("\xD7")]);
      }
      ;
      return text("");
    })(), (function() {
      if (state3.showSearchPopup) {
        return renderSearchPopup(state3);
      }
      ;
      return text("");
    })()])]);
  };
  var renderNewBillRow = /* @__PURE__ */ tr([/* @__PURE__ */ class_("pos-new-bill-row"), /* @__PURE__ */ onClick(function(v2) {
    return CreateNewBill.value;
  })])([/* @__PURE__ */ td([/* @__PURE__ */ colSpan(6)])([/* @__PURE__ */ text("\u2795")])]);
  var renderHeader = /* @__PURE__ */ text("");
  var renderCustomerBills = function(state3) {
    return function(customer) {
      return div2([class_("pos-content")])([h2_([text(customer.name + (" (ID: " + (show7(customer.id) + ")")))]), table([class_("pos-table pos-customer-bills-table")])([thead_([tr_([th([class_("pos-date-col")])([text("Date")]), th([class_("pos-gold-label")])([text("Gold Label")]), th([class_("pos-gold-value")])([text("Gold Value")]), th([class_("pos-money-label")])([text("Money Label")]), th([class_("pos-money-value")])([text("Money Value")]), th([class_("pos-actions-col")])([text("\xD7")])])]), tbody_([renderSettlementRow(customer), renderNewBillRow])])]);
    };
  };
  var initialState = function(database) {
    return function(v2) {
      return {
        view: TodaysBillsView.value,
        searchQuery: "",
        searchResults: [],
        selectedCustomer: Nothing.value,
        todaysBills: [],
        customerBills: [],
        showSearchPopup: false,
        allCustomers: [],
        database
      };
    };
  };
  var formatTime = function(timestamp) {
    return "09:15";
  };
  var renderTodaysBillRow = function(bill) {
    return tr_([td([class_("pos-time-col")])([text(formatTime(bill.createdAt))]), td([class_("pos-customer-name-cell"), onClick(function(v2) {
      return new OpenBillEditor(new Just(bill.id));
    })])([text(bill.customerName)]), td([class_("pos-actions-col")])([button([class_("pos-icon-btn pos-delete-btn"), onClick(function(v2) {
      return new DeleteBill(bill.id);
    }), title("Delete bill")])([text("\u{1F5D1}\uFE0F")])])]);
  };
  var renderTodaysBills = function(state3) {
    return div2([class_("pos-content")])([h2_([text(posConstants.todaysBillsTitle(length(state3.todaysBills)))]), table([class_("pos-table pos-todays-bills-table")])([thead_([tr_([th_([text(posConstants.columnTime)]), th_([text(posConstants.columnCustomerName)]), th_([text("")])])]), tbody_(map19(renderTodaysBillRow)(state3.todaysBills))])]);
  };
  var renderContent = function(state3) {
    if (state3.view instanceof TodaysBillsView) {
      return renderTodaysBills(state3);
    }
    ;
    if (state3.view instanceof CustomerBillsView) {
      return renderCustomerBills(state3)(state3.view.value0);
    }
    ;
    throw new Error("Failed pattern match at Component.POS (line 413, column 3 - line 415, column 69): " + [state3.view.constructor.name]);
  };
  var render2 = function(state3) {
    return div2([class_("pos-container")])([renderStyles2, renderHeader, renderSearchBox(state3), renderContent(state3)]);
  };
  var filterCustomers2 = function(query2) {
    return function(customers) {
      var $45 = query2 === "";
      if ($45) {
        return [];
      }
      ;
      var lowerQuery = toLower(query2);
      var matchesQuery = function(customer) {
        return contains(lowerQuery)(toLower(customer.name)) || contains(query2)(show7(customer.id));
      };
      var results = filter(matchesQuery)(customers);
      return results;
    };
  };
  var handleAction2 = function(dictMonadAff) {
    var MonadEffect0 = dictMonadAff.MonadEffect0();
    var lift1 = lift4(MonadEffect0.Monad0());
    var log6 = log4(MonadEffect0);
    return function(v2) {
      if (v2 instanceof Initialize3) {
        return bind5(get4)(function(state3) {
          return bind5(lift1(state3.database.getAllCustomers))(function(customers) {
            return discard3(lift1(log6("POS: Loaded " + (show7(length(customers)) + " customers"))))(function() {
              return discard3(modify_4(function(v1) {
                var $47 = {};
                for (var $48 in v1) {
                  if ({}.hasOwnProperty.call(v1, $48)) {
                    $47[$48] = v1[$48];
                  }
                  ;
                }
                ;
                $47.allCustomers = customers;
                return $47;
              }))(function() {
                return pure7(unit);
              });
            });
          });
        });
      }
      ;
      if (v2 instanceof UpdateSearchQuery2) {
        return bind5(get4)(function(state3) {
          return discard3(lift1(log6("Search query: " + v2.value0)))(function() {
            return discard3(lift1(log6("Total customers: " + show7(length(state3.allCustomers)))))(function() {
              var searchResults = filterCustomers2(v2.value0)(state3.allCustomers);
              return discard3(lift1(log6("Search results: " + show7(length(searchResults)))))(function() {
                return discard3(lift1(log6("Show popup: " + show14(v2.value0 !== ""))))(function() {
                  return modify_4(function(v1) {
                    var $50 = {};
                    for (var $51 in v1) {
                      if ({}.hasOwnProperty.call(v1, $51)) {
                        $50[$51] = v1[$51];
                      }
                      ;
                    }
                    ;
                    $50.searchQuery = v2.value0;
                    $50.showSearchPopup = v2.value0 !== "";
                    $50.searchResults = searchResults;
                    return $50;
                  });
                });
              });
            });
          });
        });
      }
      ;
      if (v2 instanceof ClearSearch) {
        return modify_4(function(v1) {
          var $54 = {};
          for (var $55 in v1) {
            if ({}.hasOwnProperty.call(v1, $55)) {
              $54[$55] = v1[$55];
            }
            ;
          }
          ;
          $54.searchQuery = "";
          $54.showSearchPopup = false;
          $54.selectedCustomer = Nothing.value;
          $54.view = TodaysBillsView.value;
          return $54;
        });
      }
      ;
      if (v2 instanceof SelectCustomer) {
        return discard3(modify_4(function(v1) {
          var $57 = {};
          for (var $58 in v1) {
            if ({}.hasOwnProperty.call(v1, $58)) {
              $57[$58] = v1[$58];
            }
            ;
          }
          ;
          $57.selectedCustomer = new Just(v2.value0);
          $57.searchQuery = v2.value0.name;
          $57.showSearchPopup = false;
          $57.view = new CustomerBillsView(v2.value0);
          return $57;
        }))(function() {
          return pure7(unit);
        });
      }
      ;
      if (v2 instanceof OpenCustomerManagement) {
        return raise(NavigateToCustomers.value);
      }
      ;
      if (v2 instanceof DeleteBill) {
        return pure7(unit);
      }
      ;
      if (v2 instanceof OpenBillEditor) {
        return pure7(unit);
      }
      ;
      if (v2 instanceof CreateNewBill) {
        return pure7(unit);
      }
      ;
      throw new Error("Failed pattern match at Component.POS (line 546, column 16 - line 600, column 14): " + [v2.constructor.name]);
    };
  };
  var component2 = function(dictMonadAff) {
    var handleAction1 = handleAction2(dictMonadAff);
    return function(database) {
      return mkComponent({
        initialState: initialState(database),
        render: render2,
        "eval": mkEval({
          handleQuery: defaultEval.handleQuery,
          receive: defaultEval.receive,
          finalize: defaultEval.finalize,
          handleAction: handleAction1,
          initialize: new Just(Initialize3.value)
        })
      });
    };
  };

  // output/Halogen.HTML/index.js
  var componentSlot2 = /* @__PURE__ */ componentSlot();
  var slot = function() {
    return function(dictIsSymbol) {
      var componentSlot1 = componentSlot2(dictIsSymbol);
      return function(dictOrd) {
        var componentSlot22 = componentSlot1(dictOrd);
        return function(label5) {
          return function(p2) {
            return function(component5) {
              return function(input3) {
                return function(outputQuery) {
                  return widget(new ComponentSlot(componentSlot22(label5)(p2)(component5)(input3)(function($11) {
                    return Just.create(outputQuery($11));
                  })));
                };
              };
            };
          };
        };
      };
    };
  };

  // output/Component.Router/index.js
  var modify_5 = /* @__PURE__ */ modify_2(monadStateHalogenM);
  var show8 = /* @__PURE__ */ show(showInt);
  var slot2 = /* @__PURE__ */ slot();
  var slot1 = /* @__PURE__ */ slot2({
    reflectSymbol: function() {
      return "pos";
    }
  })(ordUnit);
  var slot22 = /* @__PURE__ */ slot2({
    reflectSymbol: function() {
      return "customers";
    }
  })(ordUnit);
  var POSRoute = /* @__PURE__ */ (function() {
    function POSRoute2() {
    }
    ;
    POSRoute2.value = new POSRoute2();
    return POSRoute2;
  })();
  var CustomersRoute = /* @__PURE__ */ (function() {
    function CustomersRoute2() {
    }
    ;
    CustomersRoute2.value = new CustomersRoute2();
    return CustomersRoute2;
  })();
  var Navigate = /* @__PURE__ */ (function() {
    function Navigate2(value0) {
      this.value0 = value0;
    }
    ;
    Navigate2.create = function(value0) {
      return new Navigate2(value0);
    };
    return Navigate2;
  })();
  var ToggleMenu = /* @__PURE__ */ (function() {
    function ToggleMenu2() {
    }
    ;
    ToggleMenu2.value = new ToggleMenu2();
    return ToggleMenu2;
  })();
  var HandlePOSOutput = /* @__PURE__ */ (function() {
    function HandlePOSOutput2(value0) {
      this.value0 = value0;
    }
    ;
    HandlePOSOutput2.create = function(value0) {
      return new HandlePOSOutput2(value0);
    };
    return HandlePOSOutput2;
  })();
  var HandleCustomerListOutput = /* @__PURE__ */ (function() {
    function HandleCustomerListOutput2(value0) {
      this.value0 = value0;
    }
    ;
    HandleCustomerListOutput2.create = function(value0) {
      return new HandleCustomerListOutput2(value0);
    };
    return HandleCustomerListOutput2;
  })();
  var handleAction3 = function(dictMonadAff) {
    return function(v2) {
      if (v2 instanceof Navigate) {
        return modify_5(function(v1) {
          var $36 = {};
          for (var $37 in v1) {
            if ({}.hasOwnProperty.call(v1, $37)) {
              $36[$37] = v1[$37];
            }
            ;
          }
          ;
          $36.currentRoute = v2.value0;
          $36.showMenu = false;
          return $36;
        });
      }
      ;
      if (v2 instanceof ToggleMenu) {
        return modify_5(function(s2) {
          var $40 = {};
          for (var $41 in s2) {
            if ({}.hasOwnProperty.call(s2, $41)) {
              $40[$41] = s2[$41];
            }
            ;
          }
          ;
          $40.showMenu = !s2.showMenu;
          return $40;
        });
      }
      ;
      if (v2 instanceof HandlePOSOutput) {
        return modify_5(function(v1) {
          var $44 = {};
          for (var $45 in v1) {
            if ({}.hasOwnProperty.call(v1, $45)) {
              $44[$45] = v1[$45];
            }
            ;
          }
          ;
          $44.currentRoute = CustomersRoute.value;
          return $44;
        });
      }
      ;
      if (v2 instanceof HandleCustomerListOutput) {
        return modify_5(function(v1) {
          var $49 = {};
          for (var $50 in v1) {
            if ({}.hasOwnProperty.call(v1, $50)) {
              $49[$50] = v1[$50];
            }
            ;
          }
          ;
          $49.customerCount = v2.value0.value0;
          return $49;
        });
      }
      ;
      throw new Error("Failed pattern match at Component.Router (line 197, column 16 - line 212, column 46): " + [v2.constructor.name]);
    };
  };
  var eqRoute = {
    eq: function(x) {
      return function(y) {
        if (x instanceof POSRoute && y instanceof POSRoute) {
          return true;
        }
        ;
        if (x instanceof CustomersRoute && y instanceof CustomersRoute) {
          return true;
        }
        ;
        return false;
      };
    }
  };
  var eq6 = /* @__PURE__ */ eq(eqRoute);
  var renderDropdown = function(state3) {
    return div2([class_("app-nav-dropdown")])([div2([class_("app-nav-item" + (function() {
      var $56 = eq6(state3.currentRoute)(POSRoute.value);
      if ($56) {
        return " active";
      }
      ;
      return "";
    })()), onClick(function(v2) {
      return new Navigate(POSRoute.value);
    })])([text(routerConstants.routePOS)]), div2([class_("app-nav-item" + (function() {
      var $57 = eq6(state3.currentRoute)(CustomersRoute.value);
      if ($57) {
        return " active";
      }
      ;
      return "";
    })()), onClick(function(v2) {
      return new Navigate(CustomersRoute.value);
    })])([text(routerConstants.routeCustomers)])]);
  };
  var renderNav = function(state3) {
    return div2([class_("app-nav")])([style_([text("\n          .app-nav {\n            background: #f8f9fa;\n            border-bottom: 1px solid #dee2e6;\n            padding: 0;\n            margin: 0;\n            display: flex;\n            align-items: center;\n            height: 38px;\n          }\n          \n          .app-nav-menu {\n            position: relative;\n            display: inline-block;\n          }\n          \n          .app-nav-title {\n            font-size: 20px;\n            color: #333;\n            padding: 0 16px;\n            font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n          }\n          \n          .app-nav-toggle {\n            background: none;\n            border: none;\n            font-size: 20px;\n            padding: 8px 16px;\n            cursor: pointer;\n            color: #333;\n            height: 38px;\n            display: flex;\n            align-items: center;\n            font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n          }\n          \n          .app-nav-toggle:hover {\n            background: #e9ecef;\n          }\n          \n          .app-nav-dropdown {\n            position: absolute;\n            top: 100%;\n            left: 0;\n            background: white;\n            border: 1px solid #dee2e6;\n            border-radius: 0 0 4px 4px;\n            box-shadow: 0 4px 6px rgba(0,0,0,0.1);\n            min-width: 200px;\n            z-index: 1000;\n          }\n          \n          .app-nav-item {\n            padding: 12px 20px;\n            cursor: pointer;\n            border-bottom: 1px solid #eee;\n            font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n          }\n          \n          .app-nav-item:last-child {\n            border-bottom: none;\n          }\n          \n          .app-nav-item:hover {\n            background: #f8f9fa;\n          }\n          \n          .app-nav-item.active {\n            background: #e3f2fd;\n            font-weight: 600;\n          }\n        ")]), div2([class_("app-nav-menu")])([button([class_("app-nav-toggle"), title("Menu"), onClick(function(v2) {
      return ToggleMenu.value;
    })])([text("\u2630")]), (function() {
      if (state3.showMenu) {
        return renderDropdown(state3);
      }
      ;
      return text("");
    })()]), span2([class_("app-nav-title")])([text((function() {
      if (state3.currentRoute instanceof POSRoute) {
        return routerConstants.routePOS;
      }
      ;
      if (state3.currentRoute instanceof CustomersRoute) {
        return routerConstants.routeCustomers + (" (" + (show8(state3.customerCount) + " \u0E23\u0E32\u0E22)"));
      }
      ;
      throw new Error("Failed pattern match at Component.Router (line 161, column 21 - line 163, column 108): " + [state3.currentRoute.constructor.name]);
    })())])]);
  };
  var _pos = /* @__PURE__ */ (function() {
    return $$Proxy.value;
  })();
  var _customers = /* @__PURE__ */ (function() {
    return $$Proxy.value;
  })();
  var renderPage = function(dictMonadAff) {
    var component1 = component2(dictMonadAff);
    var component22 = component(dictMonadAff);
    return function(state3) {
      if (state3.currentRoute instanceof POSRoute) {
        return slot1(_pos)(unit)(component1(state3.database))(unit)(HandlePOSOutput.create);
      }
      ;
      if (state3.currentRoute instanceof CustomersRoute) {
        return slot22(_customers)(unit)(component22(state3.database))(unit)(HandleCustomerListOutput.create);
      }
      ;
      throw new Error("Failed pattern match at Component.Router (line 189, column 3 - line 193, column 100): " + [state3.currentRoute.constructor.name]);
    };
  };
  var render3 = function(dictMonadAff) {
    var renderPage1 = renderPage(dictMonadAff);
    return function(state3) {
      return div_([renderNav(state3), renderPage1(state3)]);
    };
  };
  var component3 = function(dictMonadAff) {
    var render1 = render3(dictMonadAff);
    var handleAction1 = handleAction3(dictMonadAff);
    return function(database) {
      return mkComponent({
        initialState: function(v2) {
          return {
            currentRoute: POSRoute.value,
            database,
            showMenu: false,
            customerCount: 0
          };
        },
        render: render1,
        "eval": mkEval({
          handleQuery: defaultEval.handleQuery,
          receive: defaultEval.receive,
          initialize: defaultEval.initialize,
          finalize: defaultEval.finalize,
          handleAction: handleAction1
        })
      });
    };
  };

  // output/Affjax/foreign.js
  function _ajax(platformSpecificDriver, timeoutErrorMessageIdent, requestFailedMessageIdent, mkHeader, options2) {
    return function(errback, callback) {
      var xhr = platformSpecificDriver.newXHR();
      var fixedUrl = platformSpecificDriver.fixupUrl(options2.url, xhr);
      xhr.open(options2.method || "GET", fixedUrl, true, options2.username, options2.password);
      if (options2.headers) {
        try {
          for (var i2 = 0, header2; (header2 = options2.headers[i2]) != null; i2++) {
            xhr.setRequestHeader(header2.field, header2.value);
          }
        } catch (e) {
          errback(e);
        }
      }
      var onerror = function(msgIdent) {
        return function() {
          errback(new Error(msgIdent));
        };
      };
      xhr.onerror = onerror(requestFailedMessageIdent);
      xhr.ontimeout = onerror(timeoutErrorMessageIdent);
      xhr.onload = function() {
        callback({
          status: xhr.status,
          statusText: xhr.statusText,
          headers: xhr.getAllResponseHeaders().split("\r\n").filter(function(header3) {
            return header3.length > 0;
          }).map(function(header3) {
            var i3 = header3.indexOf(":");
            return mkHeader(header3.substring(0, i3))(header3.substring(i3 + 2));
          }),
          body: xhr.response
        });
      };
      xhr.responseType = options2.responseType;
      xhr.withCredentials = options2.withCredentials;
      xhr.timeout = options2.timeout;
      xhr.send(options2.content);
      return function(error4, cancelErrback, cancelCallback) {
        try {
          xhr.abort();
        } catch (e) {
          return cancelErrback(e);
        }
        return cancelCallback();
      };
    };
  }

  // output/Data.MediaType.Common/index.js
  var applicationJSON = "application/json";
  var applicationFormURLEncoded = "application/x-www-form-urlencoded";

  // output/Affjax.RequestBody/index.js
  var ArrayView = /* @__PURE__ */ (function() {
    function ArrayView2(value0) {
      this.value0 = value0;
    }
    ;
    ArrayView2.create = function(value0) {
      return new ArrayView2(value0);
    };
    return ArrayView2;
  })();
  var Blob = /* @__PURE__ */ (function() {
    function Blob3(value0) {
      this.value0 = value0;
    }
    ;
    Blob3.create = function(value0) {
      return new Blob3(value0);
    };
    return Blob3;
  })();
  var Document = /* @__PURE__ */ (function() {
    function Document3(value0) {
      this.value0 = value0;
    }
    ;
    Document3.create = function(value0) {
      return new Document3(value0);
    };
    return Document3;
  })();
  var $$String = /* @__PURE__ */ (function() {
    function $$String3(value0) {
      this.value0 = value0;
    }
    ;
    $$String3.create = function(value0) {
      return new $$String3(value0);
    };
    return $$String3;
  })();
  var FormData = /* @__PURE__ */ (function() {
    function FormData2(value0) {
      this.value0 = value0;
    }
    ;
    FormData2.create = function(value0) {
      return new FormData2(value0);
    };
    return FormData2;
  })();
  var FormURLEncoded = /* @__PURE__ */ (function() {
    function FormURLEncoded2(value0) {
      this.value0 = value0;
    }
    ;
    FormURLEncoded2.create = function(value0) {
      return new FormURLEncoded2(value0);
    };
    return FormURLEncoded2;
  })();
  var Json = /* @__PURE__ */ (function() {
    function Json3(value0) {
      this.value0 = value0;
    }
    ;
    Json3.create = function(value0) {
      return new Json3(value0);
    };
    return Json3;
  })();
  var toMediaType = function(v2) {
    if (v2 instanceof FormURLEncoded) {
      return new Just(applicationFormURLEncoded);
    }
    ;
    if (v2 instanceof Json) {
      return new Just(applicationJSON);
    }
    ;
    return Nothing.value;
  };
  var json = /* @__PURE__ */ (function() {
    return Json.create;
  })();

  // output/Affjax.RequestHeader/index.js
  var unwrap4 = /* @__PURE__ */ unwrap();
  var Accept = /* @__PURE__ */ (function() {
    function Accept2(value0) {
      this.value0 = value0;
    }
    ;
    Accept2.create = function(value0) {
      return new Accept2(value0);
    };
    return Accept2;
  })();
  var ContentType = /* @__PURE__ */ (function() {
    function ContentType2(value0) {
      this.value0 = value0;
    }
    ;
    ContentType2.create = function(value0) {
      return new ContentType2(value0);
    };
    return ContentType2;
  })();
  var RequestHeader = /* @__PURE__ */ (function() {
    function RequestHeader2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    RequestHeader2.create = function(value0) {
      return function(value1) {
        return new RequestHeader2(value0, value1);
      };
    };
    return RequestHeader2;
  })();
  var value5 = function(v2) {
    if (v2 instanceof Accept) {
      return unwrap4(v2.value0);
    }
    ;
    if (v2 instanceof ContentType) {
      return unwrap4(v2.value0);
    }
    ;
    if (v2 instanceof RequestHeader) {
      return v2.value1;
    }
    ;
    throw new Error("Failed pattern match at Affjax.RequestHeader (line 26, column 1 - line 26, column 33): " + [v2.constructor.name]);
  };
  var name3 = function(v2) {
    if (v2 instanceof Accept) {
      return "Accept";
    }
    ;
    if (v2 instanceof ContentType) {
      return "Content-Type";
    }
    ;
    if (v2 instanceof RequestHeader) {
      return v2.value0;
    }
    ;
    throw new Error("Failed pattern match at Affjax.RequestHeader (line 21, column 1 - line 21, column 32): " + [v2.constructor.name]);
  };

  // output/Affjax.ResponseFormat/index.js
  var identity11 = /* @__PURE__ */ identity(categoryFn);
  var $$ArrayBuffer = /* @__PURE__ */ (function() {
    function $$ArrayBuffer2(value0) {
      this.value0 = value0;
    }
    ;
    $$ArrayBuffer2.create = function(value0) {
      return new $$ArrayBuffer2(value0);
    };
    return $$ArrayBuffer2;
  })();
  var Blob2 = /* @__PURE__ */ (function() {
    function Blob3(value0) {
      this.value0 = value0;
    }
    ;
    Blob3.create = function(value0) {
      return new Blob3(value0);
    };
    return Blob3;
  })();
  var Document2 = /* @__PURE__ */ (function() {
    function Document3(value0) {
      this.value0 = value0;
    }
    ;
    Document3.create = function(value0) {
      return new Document3(value0);
    };
    return Document3;
  })();
  var Json2 = /* @__PURE__ */ (function() {
    function Json3(value0) {
      this.value0 = value0;
    }
    ;
    Json3.create = function(value0) {
      return new Json3(value0);
    };
    return Json3;
  })();
  var $$String2 = /* @__PURE__ */ (function() {
    function $$String3(value0) {
      this.value0 = value0;
    }
    ;
    $$String3.create = function(value0) {
      return new $$String3(value0);
    };
    return $$String3;
  })();
  var Ignore = /* @__PURE__ */ (function() {
    function Ignore2(value0) {
      this.value0 = value0;
    }
    ;
    Ignore2.create = function(value0) {
      return new Ignore2(value0);
    };
    return Ignore2;
  })();
  var toResponseType = function(v2) {
    if (v2 instanceof $$ArrayBuffer) {
      return "arraybuffer";
    }
    ;
    if (v2 instanceof Blob2) {
      return "blob";
    }
    ;
    if (v2 instanceof Document2) {
      return "document";
    }
    ;
    if (v2 instanceof Json2) {
      return "text";
    }
    ;
    if (v2 instanceof $$String2) {
      return "text";
    }
    ;
    if (v2 instanceof Ignore) {
      return "";
    }
    ;
    throw new Error("Failed pattern match at Affjax.ResponseFormat (line 44, column 3 - line 50, column 19): " + [v2.constructor.name]);
  };
  var toMediaType2 = function(v2) {
    if (v2 instanceof Json2) {
      return new Just(applicationJSON);
    }
    ;
    return Nothing.value;
  };
  var json2 = /* @__PURE__ */ (function() {
    return new Json2(identity11);
  })();
  var ignore = /* @__PURE__ */ (function() {
    return new Ignore(identity11);
  })();

  // output/Affjax.ResponseHeader/index.js
  var ResponseHeader = /* @__PURE__ */ (function() {
    function ResponseHeader2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    ResponseHeader2.create = function(value0) {
      return function(value1) {
        return new ResponseHeader2(value0, value1);
      };
    };
    return ResponseHeader2;
  })();

  // output/Data.Argonaut.Parser/foreign.js
  function _jsonParser(fail3, succ, s2) {
    try {
      return succ(JSON.parse(s2));
    } catch (e) {
      return fail3(e.message);
    }
  }

  // output/Data.Argonaut.Parser/index.js
  var jsonParser = function(j) {
    return _jsonParser(Left.create, Right.create, j);
  };

  // output/JSURI/foreign.js
  function encodeURIComponent_to_RFC3986(input3) {
    return input3.replace(/[!'()*]/g, function(c2) {
      return "%" + c2.charCodeAt(0).toString(16);
    });
  }
  function _encodeFormURLComponent(fail3, succeed, input3) {
    try {
      return succeed(encodeURIComponent_to_RFC3986(encodeURIComponent(input3)).replace(/%20/g, "+"));
    } catch (err) {
      return fail3(err);
    }
  }

  // output/JSURI/index.js
  var encodeFormURLComponent = /* @__PURE__ */ (function() {
    return runFn3(_encodeFormURLComponent)($$const(Nothing.value))(Just.create);
  })();

  // output/Data.FormURLEncoded/index.js
  var apply2 = /* @__PURE__ */ apply(applyMaybe);
  var map21 = /* @__PURE__ */ map(functorMaybe);
  var traverse2 = /* @__PURE__ */ traverse(traversableArray)(applicativeMaybe);
  var toArray3 = function(v2) {
    return v2;
  };
  var encode = /* @__PURE__ */ (function() {
    var encodePart = function(v2) {
      if (v2.value1 instanceof Nothing) {
        return encodeFormURLComponent(v2.value0);
      }
      ;
      if (v2.value1 instanceof Just) {
        return apply2(map21(function(key2) {
          return function(val) {
            return key2 + ("=" + val);
          };
        })(encodeFormURLComponent(v2.value0)))(encodeFormURLComponent(v2.value1.value0));
      }
      ;
      throw new Error("Failed pattern match at Data.FormURLEncoded (line 37, column 16 - line 39, column 114): " + [v2.constructor.name]);
    };
    var $37 = map21(joinWith("&"));
    var $38 = traverse2(encodePart);
    return function($39) {
      return $37($38(toArray3($39)));
    };
  })();

  // output/Data.HTTP.Method/index.js
  var OPTIONS = /* @__PURE__ */ (function() {
    function OPTIONS2() {
    }
    ;
    OPTIONS2.value = new OPTIONS2();
    return OPTIONS2;
  })();
  var GET2 = /* @__PURE__ */ (function() {
    function GET3() {
    }
    ;
    GET3.value = new GET3();
    return GET3;
  })();
  var HEAD = /* @__PURE__ */ (function() {
    function HEAD2() {
    }
    ;
    HEAD2.value = new HEAD2();
    return HEAD2;
  })();
  var POST2 = /* @__PURE__ */ (function() {
    function POST3() {
    }
    ;
    POST3.value = new POST3();
    return POST3;
  })();
  var PUT = /* @__PURE__ */ (function() {
    function PUT2() {
    }
    ;
    PUT2.value = new PUT2();
    return PUT2;
  })();
  var DELETE = /* @__PURE__ */ (function() {
    function DELETE2() {
    }
    ;
    DELETE2.value = new DELETE2();
    return DELETE2;
  })();
  var TRACE = /* @__PURE__ */ (function() {
    function TRACE2() {
    }
    ;
    TRACE2.value = new TRACE2();
    return TRACE2;
  })();
  var CONNECT = /* @__PURE__ */ (function() {
    function CONNECT2() {
    }
    ;
    CONNECT2.value = new CONNECT2();
    return CONNECT2;
  })();
  var PROPFIND = /* @__PURE__ */ (function() {
    function PROPFIND2() {
    }
    ;
    PROPFIND2.value = new PROPFIND2();
    return PROPFIND2;
  })();
  var PROPPATCH = /* @__PURE__ */ (function() {
    function PROPPATCH2() {
    }
    ;
    PROPPATCH2.value = new PROPPATCH2();
    return PROPPATCH2;
  })();
  var MKCOL = /* @__PURE__ */ (function() {
    function MKCOL2() {
    }
    ;
    MKCOL2.value = new MKCOL2();
    return MKCOL2;
  })();
  var COPY = /* @__PURE__ */ (function() {
    function COPY2() {
    }
    ;
    COPY2.value = new COPY2();
    return COPY2;
  })();
  var MOVE = /* @__PURE__ */ (function() {
    function MOVE2() {
    }
    ;
    MOVE2.value = new MOVE2();
    return MOVE2;
  })();
  var LOCK = /* @__PURE__ */ (function() {
    function LOCK2() {
    }
    ;
    LOCK2.value = new LOCK2();
    return LOCK2;
  })();
  var UNLOCK = /* @__PURE__ */ (function() {
    function UNLOCK2() {
    }
    ;
    UNLOCK2.value = new UNLOCK2();
    return UNLOCK2;
  })();
  var PATCH = /* @__PURE__ */ (function() {
    function PATCH2() {
    }
    ;
    PATCH2.value = new PATCH2();
    return PATCH2;
  })();
  var unCustomMethod = function(v2) {
    return v2;
  };
  var showMethod = {
    show: function(v2) {
      if (v2 instanceof OPTIONS) {
        return "OPTIONS";
      }
      ;
      if (v2 instanceof GET2) {
        return "GET";
      }
      ;
      if (v2 instanceof HEAD) {
        return "HEAD";
      }
      ;
      if (v2 instanceof POST2) {
        return "POST";
      }
      ;
      if (v2 instanceof PUT) {
        return "PUT";
      }
      ;
      if (v2 instanceof DELETE) {
        return "DELETE";
      }
      ;
      if (v2 instanceof TRACE) {
        return "TRACE";
      }
      ;
      if (v2 instanceof CONNECT) {
        return "CONNECT";
      }
      ;
      if (v2 instanceof PROPFIND) {
        return "PROPFIND";
      }
      ;
      if (v2 instanceof PROPPATCH) {
        return "PROPPATCH";
      }
      ;
      if (v2 instanceof MKCOL) {
        return "MKCOL";
      }
      ;
      if (v2 instanceof COPY) {
        return "COPY";
      }
      ;
      if (v2 instanceof MOVE) {
        return "MOVE";
      }
      ;
      if (v2 instanceof LOCK) {
        return "LOCK";
      }
      ;
      if (v2 instanceof UNLOCK) {
        return "UNLOCK";
      }
      ;
      if (v2 instanceof PATCH) {
        return "PATCH";
      }
      ;
      throw new Error("Failed pattern match at Data.HTTP.Method (line 43, column 1 - line 59, column 23): " + [v2.constructor.name]);
    }
  };
  var print2 = /* @__PURE__ */ either(/* @__PURE__ */ show(showMethod))(unCustomMethod);

  // output/Effect.Aff.Compat/index.js
  var fromEffectFnAff = function(v2) {
    return makeAff(function(k) {
      return function __do3() {
        var v1 = v2(function($9) {
          return k(Left.create($9))();
        }, function($10) {
          return k(Right.create($10))();
        });
        return function(e) {
          return makeAff(function(k2) {
            return function __do4() {
              v1(e, function($11) {
                return k2(Left.create($11))();
              }, function($12) {
                return k2(Right.create($12))();
              });
              return nonCanceler;
            };
          });
        };
      };
    });
  };

  // output/Affjax/index.js
  var pure8 = /* @__PURE__ */ pure(/* @__PURE__ */ applicativeExceptT(monadIdentity));
  var fail2 = /* @__PURE__ */ fail(monadIdentity);
  var unsafeReadTagged3 = /* @__PURE__ */ unsafeReadTagged(monadIdentity);
  var alt4 = /* @__PURE__ */ alt(/* @__PURE__ */ altExceptT(semigroupNonEmptyList)(monadIdentity));
  var composeKleisliFlipped4 = /* @__PURE__ */ composeKleisliFlipped(/* @__PURE__ */ bindExceptT(monadIdentity));
  var map22 = /* @__PURE__ */ map(functorMaybe);
  var any3 = /* @__PURE__ */ any(foldableArray)(heytingAlgebraBoolean);
  var eq7 = /* @__PURE__ */ eq(eqString);
  var bindFlipped4 = /* @__PURE__ */ bindFlipped(bindMaybe);
  var map110 = /* @__PURE__ */ map(functorArray);
  var mapFlipped2 = /* @__PURE__ */ mapFlipped(functorAff);
  var $$try3 = /* @__PURE__ */ $$try(monadErrorAff);
  var pure12 = /* @__PURE__ */ pure(applicativeAff);
  var map23 = /* @__PURE__ */ map(functorAff);
  var $$void6 = /* @__PURE__ */ $$void(functorEither);
  var RequestContentError = /* @__PURE__ */ (function() {
    function RequestContentError2(value0) {
      this.value0 = value0;
    }
    ;
    RequestContentError2.create = function(value0) {
      return new RequestContentError2(value0);
    };
    return RequestContentError2;
  })();
  var ResponseBodyError = /* @__PURE__ */ (function() {
    function ResponseBodyError2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    ResponseBodyError2.create = function(value0) {
      return function(value1) {
        return new ResponseBodyError2(value0, value1);
      };
    };
    return ResponseBodyError2;
  })();
  var TimeoutError = /* @__PURE__ */ (function() {
    function TimeoutError2() {
    }
    ;
    TimeoutError2.value = new TimeoutError2();
    return TimeoutError2;
  })();
  var RequestFailedError = /* @__PURE__ */ (function() {
    function RequestFailedError2() {
    }
    ;
    RequestFailedError2.value = new RequestFailedError2();
    return RequestFailedError2;
  })();
  var XHROtherError = /* @__PURE__ */ (function() {
    function XHROtherError2(value0) {
      this.value0 = value0;
    }
    ;
    XHROtherError2.create = function(value0) {
      return new XHROtherError2(value0);
    };
    return XHROtherError2;
  })();
  var request = function(driver2) {
    return function(req) {
      var parseJSON = function(v3) {
        if (v3 === "") {
          return pure8(jsonEmptyObject);
        }
        ;
        return either(function($74) {
          return fail2(ForeignError.create($74));
        })(pure8)(jsonParser(v3));
      };
      var fromResponse = (function() {
        if (req.responseFormat instanceof $$ArrayBuffer) {
          return unsafeReadTagged3("ArrayBuffer");
        }
        ;
        if (req.responseFormat instanceof Blob2) {
          return unsafeReadTagged3("Blob");
        }
        ;
        if (req.responseFormat instanceof Document2) {
          return function(x) {
            return alt4(unsafeReadTagged3("Document")(x))(alt4(unsafeReadTagged3("XMLDocument")(x))(unsafeReadTagged3("HTMLDocument")(x)));
          };
        }
        ;
        if (req.responseFormat instanceof Json2) {
          return composeKleisliFlipped4(function($75) {
            return req.responseFormat.value0(parseJSON($75));
          })(unsafeReadTagged3("String"));
        }
        ;
        if (req.responseFormat instanceof $$String2) {
          return unsafeReadTagged3("String");
        }
        ;
        if (req.responseFormat instanceof Ignore) {
          return $$const(req.responseFormat.value0(pure8(unit)));
        }
        ;
        throw new Error("Failed pattern match at Affjax (line 274, column 18 - line 283, column 57): " + [req.responseFormat.constructor.name]);
      })();
      var extractContent = function(v3) {
        if (v3 instanceof ArrayView) {
          return new Right(v3.value0(unsafeToForeign));
        }
        ;
        if (v3 instanceof Blob) {
          return new Right(unsafeToForeign(v3.value0));
        }
        ;
        if (v3 instanceof Document) {
          return new Right(unsafeToForeign(v3.value0));
        }
        ;
        if (v3 instanceof $$String) {
          return new Right(unsafeToForeign(v3.value0));
        }
        ;
        if (v3 instanceof FormData) {
          return new Right(unsafeToForeign(v3.value0));
        }
        ;
        if (v3 instanceof FormURLEncoded) {
          return note("Body contains values that cannot be encoded as application/x-www-form-urlencoded")(map22(unsafeToForeign)(encode(v3.value0)));
        }
        ;
        if (v3 instanceof Json) {
          return new Right(unsafeToForeign(stringify(v3.value0)));
        }
        ;
        throw new Error("Failed pattern match at Affjax (line 235, column 20 - line 250, column 69): " + [v3.constructor.name]);
      };
      var addHeader = function(mh) {
        return function(hs) {
          if (mh instanceof Just && !any3(on(eq7)(name3)(mh.value0))(hs)) {
            return snoc(hs)(mh.value0);
          }
          ;
          return hs;
        };
      };
      var headers = function(reqContent) {
        return addHeader(map22(ContentType.create)(bindFlipped4(toMediaType)(reqContent)))(addHeader(map22(Accept.create)(toMediaType2(req.responseFormat)))(req.headers));
      };
      var ajaxRequest = function(v3) {
        return {
          method: print2(req.method),
          url: req.url,
          headers: map110(function(h7) {
            return {
              field: name3(h7),
              value: value5(h7)
            };
          })(headers(req.content)),
          content: v3,
          responseType: toResponseType(req.responseFormat),
          username: toNullable(req.username),
          password: toNullable(req.password),
          withCredentials: req.withCredentials,
          timeout: fromMaybe(0)(map22(function(v1) {
            return v1;
          })(req.timeout))
        };
      };
      var send = function(content3) {
        return mapFlipped2($$try3(fromEffectFnAff(_ajax(driver2, "AffjaxTimeoutErrorMessageIdent", "AffjaxRequestFailedMessageIdent", ResponseHeader.create, ajaxRequest(content3)))))(function(v3) {
          if (v3 instanceof Right) {
            var v1 = runExcept(fromResponse(v3.value0.body));
            if (v1 instanceof Left) {
              return new Left(new ResponseBodyError(head(v1.value0), v3.value0));
            }
            ;
            if (v1 instanceof Right) {
              return new Right({
                headers: v3.value0.headers,
                status: v3.value0.status,
                statusText: v3.value0.statusText,
                body: v1.value0
              });
            }
            ;
            throw new Error("Failed pattern match at Affjax (line 209, column 9 - line 211, column 52): " + [v1.constructor.name]);
          }
          ;
          if (v3 instanceof Left) {
            return new Left((function() {
              var message2 = message(v3.value0);
              var $61 = message2 === "AffjaxTimeoutErrorMessageIdent";
              if ($61) {
                return TimeoutError.value;
              }
              ;
              var $62 = message2 === "AffjaxRequestFailedMessageIdent";
              if ($62) {
                return RequestFailedError.value;
              }
              ;
              return new XHROtherError(v3.value0);
            })());
          }
          ;
          throw new Error("Failed pattern match at Affjax (line 207, column 144 - line 219, column 28): " + [v3.constructor.name]);
        });
      };
      if (req.content instanceof Nothing) {
        return send(toNullable(Nothing.value));
      }
      ;
      if (req.content instanceof Just) {
        var v2 = extractContent(req.content.value0);
        if (v2 instanceof Right) {
          return send(toNullable(new Just(v2.value0)));
        }
        ;
        if (v2 instanceof Left) {
          return pure12(new Left(new RequestContentError(v2.value0)));
        }
        ;
        throw new Error("Failed pattern match at Affjax (line 199, column 7 - line 203, column 48): " + [v2.constructor.name]);
      }
      ;
      throw new Error("Failed pattern match at Affjax (line 195, column 3 - line 203, column 48): " + [req.content.constructor.name]);
    };
  };
  var printError = function(v2) {
    if (v2 instanceof RequestContentError) {
      return "There was a problem with the request content: " + v2.value0;
    }
    ;
    if (v2 instanceof ResponseBodyError) {
      return "There was a problem with the response body: " + renderForeignError(v2.value0);
    }
    ;
    if (v2 instanceof TimeoutError) {
      return "There was a problem making the request: timeout";
    }
    ;
    if (v2 instanceof RequestFailedError) {
      return "There was a problem making the request: request failed";
    }
    ;
    if (v2 instanceof XHROtherError) {
      return "There was a problem making the request: " + message(v2.value0);
    }
    ;
    throw new Error("Failed pattern match at Affjax (line 113, column 14 - line 123, column 66): " + [v2.constructor.name]);
  };
  var defaultRequest = /* @__PURE__ */ (function() {
    return {
      method: new Left(GET2.value),
      url: "/",
      headers: [],
      content: Nothing.value,
      username: Nothing.value,
      password: Nothing.value,
      withCredentials: false,
      responseFormat: ignore,
      timeout: Nothing.value
    };
  })();
  var $$delete3 = function(driver2) {
    return function(rf) {
      return function(u2) {
        return request(driver2)({
          headers: defaultRequest.headers,
          content: defaultRequest.content,
          username: defaultRequest.username,
          password: defaultRequest.password,
          withCredentials: defaultRequest.withCredentials,
          timeout: defaultRequest.timeout,
          method: new Left(DELETE.value),
          url: u2,
          responseFormat: rf
        });
      };
    };
  };
  var delete_ = function(driver2) {
    var $76 = map23($$void6);
    var $77 = $$delete3(driver2)(ignore);
    return function($78) {
      return $76($77($78));
    };
  };
  var get5 = function(driver2) {
    return function(rf) {
      return function(u2) {
        return request(driver2)({
          method: defaultRequest.method,
          headers: defaultRequest.headers,
          content: defaultRequest.content,
          username: defaultRequest.username,
          password: defaultRequest.password,
          withCredentials: defaultRequest.withCredentials,
          timeout: defaultRequest.timeout,
          url: u2,
          responseFormat: rf
        });
      };
    };
  };
  var post = function(driver2) {
    return function(rf) {
      return function(u2) {
        return function(c2) {
          return request(driver2)({
            headers: defaultRequest.headers,
            username: defaultRequest.username,
            password: defaultRequest.password,
            withCredentials: defaultRequest.withCredentials,
            timeout: defaultRequest.timeout,
            method: new Left(POST2.value),
            url: u2,
            content: c2,
            responseFormat: rf
          });
        };
      };
    };
  };
  var put2 = function(driver2) {
    return function(rf) {
      return function(u2) {
        return function(c2) {
          return request(driver2)({
            headers: defaultRequest.headers,
            username: defaultRequest.username,
            password: defaultRequest.password,
            withCredentials: defaultRequest.withCredentials,
            timeout: defaultRequest.timeout,
            method: new Left(PUT.value),
            url: u2,
            content: c2,
            responseFormat: rf
          });
        };
      };
    };
  };

  // output/Affjax.Web/foreign.js
  var driver = {
    newXHR: function() {
      return new XMLHttpRequest();
    },
    fixupUrl: function(url) {
      return url || "/";
    }
  };

  // output/Affjax.Web/index.js
  var put3 = /* @__PURE__ */ put2(driver);
  var post2 = /* @__PURE__ */ post(driver);
  var get6 = /* @__PURE__ */ get5(driver);
  var delete_2 = /* @__PURE__ */ delete_(driver);

  // output/Data.Argonaut.Decode.Combinators/index.js
  var getField2 = function(dictDecodeJson) {
    return getField(decodeJson(dictDecodeJson));
  };

  // output/Database.Codecs/index.js
  var lmap3 = /* @__PURE__ */ lmap(bifunctorEither);
  var bind6 = /* @__PURE__ */ bind(bindEither);
  var decodeJson3 = /* @__PURE__ */ decodeJson(/* @__PURE__ */ decodeForeignObject2(decodeJsonJson));
  var getField3 = /* @__PURE__ */ getField2(decodeJsonInt);
  var getField1 = /* @__PURE__ */ getField2(decodeJsonString);
  var getField22 = /* @__PURE__ */ getField2(decodeJsonDecimal);
  var getField32 = /* @__PURE__ */ getField2(/* @__PURE__ */ decodeJsonMaybe(decodeJsonString));
  var pure9 = /* @__PURE__ */ pure(applicativeEither);
  var decodeCustomer = function(json3) {
    return lmap3(printJsonDecodeError)(bind6(decodeJson3(json3))(function(obj) {
      return bind6(getField3(obj)("id"))(function(id4) {
        return bind6(getField1(obj)("name"))(function(name16) {
          return bind6(getField22(obj)("money"))(function(money) {
            return bind6(getField22(obj)("gram_jewelry"))(function(gram_jewelry) {
              return bind6(getField22(obj)("baht_jewelry"))(function(baht_jewelry) {
                return bind6(getField22(obj)("gram_bar96"))(function(gram_bar96) {
                  return bind6(getField22(obj)("baht_bar96"))(function(baht_bar96) {
                    return bind6(getField22(obj)("gram_bar99"))(function(gram_bar99) {
                      return bind6(getField22(obj)("baht_bar99"))(function(baht_bar99) {
                        return bind6(getField32(obj)("created_at"))(function(created_at) {
                          return bind6(getField32(obj)("updated_at"))(function(updated_at) {
                            return pure9({
                              id: id4,
                              name: name16,
                              money,
                              gram_jewelry,
                              baht_jewelry,
                              gram_bar96,
                              baht_bar96,
                              gram_bar99,
                              baht_bar99,
                              created_at,
                              updated_at,
                              rowHeight: Nothing.value
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    }));
  };

  // output/Database.API/index.js
  var bind7 = /* @__PURE__ */ bind(bindAff);
  var liftEffect3 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var log5 = /* @__PURE__ */ log4(monadEffectEffect);
  var throwError2 = /* @__PURE__ */ throwError(monadThrowAff);
  var decodeJson4 = /* @__PURE__ */ decodeJson(/* @__PURE__ */ decodeArray2(decodeJsonJson));
  var show9 = /* @__PURE__ */ show(showJsonDecodeError);
  var show15 = /* @__PURE__ */ show(showInt);
  var pure10 = /* @__PURE__ */ pure(applicativeAff);
  var traverse3 = /* @__PURE__ */ traverse(traversableArray)(applicativeEither);
  var gEncodeJsonCons2 = /* @__PURE__ */ gEncodeJsonCons(encodeJsonJString);
  var gEncodeJsonCons1 = /* @__PURE__ */ gEncodeJsonCons2(gEncodeJsonNil);
  var encodeJson2 = /* @__PURE__ */ encodeJson(/* @__PURE__ */ encodeRecord(/* @__PURE__ */ gEncodeJsonCons1({
    reflectSymbol: function() {
      return "name";
    }
  })())());
  var encodeJson1 = /* @__PURE__ */ encodeJson(/* @__PURE__ */ encodeRecord(/* @__PURE__ */ gEncodeJsonCons2(/* @__PURE__ */ gEncodeJsonCons1({
    reflectSymbol: function() {
      return "value";
    }
  })())({
    reflectSymbol: function() {
      return "field";
    }
  })())());
  var apiUrl = "/api/customers";
  var createAPIDatabase = function(dictMonadAff) {
    var liftAff2 = liftAff(dictMonadAff);
    return {
      getAllCustomers: liftAff2(bind7(liftEffect3(log5("Fetching all customers...")))(function() {
        return bind7(get6(json2)(apiUrl))(function(result) {
          if (result instanceof Left) {
            return bind7(liftEffect3(log5("API error: " + printError(result.value0))))(function() {
              return throwError2(error("API error: " + printError(result.value0)));
            });
          }
          ;
          if (result instanceof Right) {
            return bind7(liftEffect3(log5("Got response, decoding JSON array...")))(function() {
              return bind7((function() {
                var v2 = decodeJson4(result.value0.body);
                if (v2 instanceof Left) {
                  return bind7(liftEffect3(log5("JSON array decode error: " + show9(v2.value0))))(function() {
                    return throwError2(error("JSON array decode error: " + show9(v2.value0)));
                  });
                }
                ;
                if (v2 instanceof Right) {
                  return bind7(liftEffect3(log5("Decoded array with " + (show15(length(v2.value0)) + " items"))))(function() {
                    return pure10(v2.value0);
                  });
                }
                ;
                throw new Error("Failed pattern match at Database.API (line 36, column 28 - line 42, column 23): " + [v2.constructor.name]);
              })())(function(customersJson) {
                return bind7(liftEffect3(log5("Decoding customers...")))(function() {
                  var v2 = traverse3(decodeCustomer)(customersJson);
                  if (v2 instanceof Left) {
                    return bind7(liftEffect3(log5("Customer decode error: " + v2.value0)))(function() {
                      return throwError2(error("Customer decode error: " + v2.value0));
                    });
                  }
                  ;
                  if (v2 instanceof Right) {
                    return bind7(liftEffect3(log5("Successfully decoded " + (show15(length(v2.value0)) + " customers"))))(function() {
                      return pure10(v2.value0);
                    });
                  }
                  ;
                  throw new Error("Failed pattern match at Database.API (line 44, column 11 - line 50, column 29): " + [v2.constructor.name]);
                });
              });
            });
          }
          ;
          throw new Error("Failed pattern match at Database.API (line 30, column 7 - line 50, column 29): " + [result.constructor.name]);
        });
      })),
      getChangesSince: function(since) {
        return liftAff2(bind7(get6(json2)(apiUrl + ("/changes?since=" + since)))(function(result) {
          if (result instanceof Left) {
            return throwError2(error("API error: " + printError(result.value0)));
          }
          ;
          if (result instanceof Right) {
            return bind7((function() {
              var v2 = decodeJson4(result.value0.body);
              if (v2 instanceof Left) {
                return throwError2(error("JSON array decode error: " + show9(v2.value0)));
              }
              ;
              if (v2 instanceof Right) {
                return pure10(v2.value0);
              }
              ;
              throw new Error("Failed pattern match at Database.API (line 57, column 26 - line 59, column 34): " + [v2.constructor.name]);
            })())(function(changesJson) {
              var v2 = traverse3(decodeCustomer)(changesJson);
              if (v2 instanceof Left) {
                return throwError2(error("Customer decode error: " + v2.value0));
              }
              ;
              if (v2 instanceof Right) {
                return pure10(v2.value0);
              }
              ;
              throw new Error("Failed pattern match at Database.API (line 60, column 11 - line 62, column 46): " + [v2.constructor.name]);
            });
          }
          ;
          throw new Error("Failed pattern match at Database.API (line 54, column 7 - line 62, column 46): " + [result.constructor.name]);
        }));
      },
      addNewCustomer: function(name16) {
        return liftAff2(bind7(post2(json2)(apiUrl)(new Just(json(encodeJson2({
          name: name16
        })))))(function(result) {
          if (result instanceof Left) {
            return throwError2(error("API error: " + printError(result.value0)));
          }
          ;
          if (result instanceof Right) {
            var v2 = decodeCustomer(result.value0.body);
            if (v2 instanceof Left) {
              return throwError2(error("Customer decode error: " + v2.value0));
            }
            ;
            if (v2 instanceof Right) {
              return pure10(v2.value0);
            }
            ;
            throw new Error("Failed pattern match at Database.API (line 68, column 27 - line 70, column 42): " + [v2.constructor.name]);
          }
          ;
          throw new Error("Failed pattern match at Database.API (line 66, column 7 - line 70, column 42): " + [result.constructor.name]);
        }));
      },
      updateCustomerField: function(v2) {
        return liftAff2(bind7(put3(json2)(apiUrl + ("/" + show15(v2.id)))(new Just(json(encodeJson1({
          field: v2.field,
          value: v2.value
        })))))(function(result) {
          if (result instanceof Left) {
            return throwError2(error("API error: " + printError(result.value0)));
          }
          ;
          if (result instanceof Right) {
            var v1 = decodeCustomer(result.value0.body);
            if (v1 instanceof Left) {
              return throwError2(error("Customer decode error: " + v1.value0));
            }
            ;
            if (v1 instanceof Right) {
              return pure10(v1.value0);
            }
            ;
            throw new Error("Failed pattern match at Database.API (line 76, column 27 - line 78, column 42): " + [v1.constructor.name]);
          }
          ;
          throw new Error("Failed pattern match at Database.API (line 74, column 7 - line 78, column 42): " + [result.constructor.name]);
        }));
      },
      deleteCustomer: function(id4) {
        return liftAff2(bind7(delete_2(apiUrl + ("/" + show15(id4))))(function(result) {
          if (result instanceof Left) {
            return throwError2(error("API error: " + printError(result.value0)));
          }
          ;
          if (result instanceof Right) {
            return pure10(unit);
          }
          ;
          throw new Error("Failed pattern match at Database.API (line 82, column 7 - line 84, column 29): " + [result.constructor.name]);
        }));
      }
    };
  };

  // output/Web.HTML/foreign.js
  var windowImpl = function() {
    return window;
  };

  // output/Web.HTML.HTMLDocument/foreign.js
  function _readyState(doc) {
    return doc.readyState;
  }

  // output/Web.HTML.HTMLDocument.ReadyState/index.js
  var Loading = /* @__PURE__ */ (function() {
    function Loading2() {
    }
    ;
    Loading2.value = new Loading2();
    return Loading2;
  })();
  var Interactive = /* @__PURE__ */ (function() {
    function Interactive2() {
    }
    ;
    Interactive2.value = new Interactive2();
    return Interactive2;
  })();
  var Complete = /* @__PURE__ */ (function() {
    function Complete2() {
    }
    ;
    Complete2.value = new Complete2();
    return Complete2;
  })();
  var parse = function(v2) {
    if (v2 === "loading") {
      return new Just(Loading.value);
    }
    ;
    if (v2 === "interactive") {
      return new Just(Interactive.value);
    }
    ;
    if (v2 === "complete") {
      return new Just(Complete.value);
    }
    ;
    return Nothing.value;
  };

  // output/Web.HTML.HTMLDocument/index.js
  var map24 = /* @__PURE__ */ map(functorEffect);
  var toParentNode = unsafeCoerce2;
  var toDocument = unsafeCoerce2;
  var readyState = function(doc) {
    return map24((function() {
      var $4 = fromMaybe(Loading.value);
      return function($5) {
        return $4(parse($5));
      };
    })())(function() {
      return _readyState(doc);
    });
  };

  // output/Web.HTML.Window/foreign.js
  function document2(window2) {
    return function() {
      return window2.document;
    };
  }

  // output/Web.HTML.Window/index.js
  var toEventTarget = unsafeCoerce2;

  // output/Halogen.Aff.Util/index.js
  var bind8 = /* @__PURE__ */ bind(bindAff);
  var liftEffect4 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var bindFlipped5 = /* @__PURE__ */ bindFlipped(bindEffect);
  var composeKleisliFlipped5 = /* @__PURE__ */ composeKleisliFlipped(bindEffect);
  var pure11 = /* @__PURE__ */ pure(applicativeAff);
  var bindFlipped1 = /* @__PURE__ */ bindFlipped(bindMaybe);
  var pure13 = /* @__PURE__ */ pure(applicativeEffect);
  var map25 = /* @__PURE__ */ map(functorEffect);
  var discard4 = /* @__PURE__ */ discard(discardUnit);
  var throwError3 = /* @__PURE__ */ throwError(monadThrowAff);
  var selectElement = function(query2) {
    return bind8(liftEffect4(bindFlipped5(composeKleisliFlipped5((function() {
      var $16 = querySelector(query2);
      return function($17) {
        return $16(toParentNode($17));
      };
    })())(document2))(windowImpl)))(function(mel) {
      return pure11(bindFlipped1(fromElement)(mel));
    });
  };
  var runHalogenAff = /* @__PURE__ */ runAff_(/* @__PURE__ */ either(throwException)(/* @__PURE__ */ $$const(/* @__PURE__ */ pure13(unit))));
  var awaitLoad = /* @__PURE__ */ makeAff(function(callback) {
    return function __do3() {
      var rs = bindFlipped5(readyState)(bindFlipped5(document2)(windowImpl))();
      if (rs instanceof Loading) {
        var et = map25(toEventTarget)(windowImpl)();
        var listener = eventListener(function(v2) {
          return callback(new Right(unit));
        })();
        addEventListener2(domcontentloaded)(listener)(false)(et)();
        return effectCanceler(removeEventListener2(domcontentloaded)(listener)(false)(et));
      }
      ;
      callback(new Right(unit))();
      return nonCanceler;
    };
  });
  var awaitBody = /* @__PURE__ */ discard4(bindAff)(awaitLoad)(function() {
    return bind8(selectElement("body"))(function(body2) {
      return maybe(throwError3(error("Could not find body")))(pure11)(body2);
    });
  });

  // output/Control.Monad.Fork.Class/index.js
  var monadForkAff = {
    suspend: suspendAff,
    fork: forkAff,
    join: joinFiber,
    Monad0: function() {
      return monadAff;
    },
    Functor1: function() {
      return functorFiber;
    }
  };
  var fork2 = function(dict) {
    return dict.fork;
  };

  // output/Halogen.Aff.Driver.State/index.js
  var unRenderStateX = unsafeCoerce2;
  var unDriverStateX = unsafeCoerce2;
  var renderStateX_ = function(dictApplicative) {
    var traverse_7 = traverse_(dictApplicative)(foldableMaybe);
    return function(f) {
      return unDriverStateX(function(st) {
        return traverse_7(f)(st.rendering);
      });
    };
  };
  var mkRenderStateX = unsafeCoerce2;
  var renderStateX = function(dictFunctor) {
    return function(f) {
      return unDriverStateX(function(st) {
        return mkRenderStateX(f(st.rendering));
      });
    };
  };
  var mkDriverStateXRef = unsafeCoerce2;
  var mapDriverState = function(f) {
    return function(v2) {
      return f(v2);
    };
  };
  var initDriverState = function(component5) {
    return function(input3) {
      return function(handler3) {
        return function(lchs) {
          return function __do3() {
            var selfRef = $$new({})();
            var childrenIn = $$new(empty4)();
            var childrenOut = $$new(empty4)();
            var handlerRef = $$new(handler3)();
            var pendingQueries = $$new(new Just(Nil.value))();
            var pendingOuts = $$new(new Just(Nil.value))();
            var pendingHandlers = $$new(Nothing.value)();
            var fresh2 = $$new(1)();
            var subscriptions = $$new(new Just(empty3))();
            var forks = $$new(empty3)();
            var ds = {
              component: component5,
              state: component5.initialState(input3),
              refs: empty3,
              children: empty4,
              childrenIn,
              childrenOut,
              selfRef,
              handlerRef,
              pendingQueries,
              pendingOuts,
              pendingHandlers,
              rendering: Nothing.value,
              fresh: fresh2,
              subscriptions,
              forks,
              lifecycleHandlers: lchs
            };
            write(ds)(selfRef)();
            return mkDriverStateXRef(selfRef);
          };
        };
      };
    };
  };

  // output/Halogen.Aff.Driver.Eval/index.js
  var traverse_4 = /* @__PURE__ */ traverse_(applicativeEffect)(foldableMaybe);
  var bindFlipped6 = /* @__PURE__ */ bindFlipped(bindMaybe);
  var lookup5 = /* @__PURE__ */ lookup2(ordSubscriptionId);
  var bind13 = /* @__PURE__ */ bind(bindAff);
  var liftEffect5 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var discard5 = /* @__PURE__ */ discard(discardUnit);
  var discard1 = /* @__PURE__ */ discard5(bindAff);
  var traverse_12 = /* @__PURE__ */ traverse_(applicativeAff);
  var traverse_22 = /* @__PURE__ */ traverse_12(foldableList);
  var fork3 = /* @__PURE__ */ fork2(monadForkAff);
  var parSequence_3 = /* @__PURE__ */ parSequence_(parallelAff)(applicativeParAff)(foldableList);
  var pure14 = /* @__PURE__ */ pure(applicativeAff);
  var map26 = /* @__PURE__ */ map(functorCoyoneda);
  var parallel3 = /* @__PURE__ */ parallel(parallelAff);
  var map111 = /* @__PURE__ */ map(functorAff);
  var sequential2 = /* @__PURE__ */ sequential(parallelAff);
  var map27 = /* @__PURE__ */ map(functorMaybe);
  var insert7 = /* @__PURE__ */ insert3(ordSubscriptionId);
  var retractFreeAp2 = /* @__PURE__ */ retractFreeAp(applicativeParAff);
  var $$delete4 = /* @__PURE__ */ $$delete2(ordForkId);
  var unlessM2 = /* @__PURE__ */ unlessM(monadEffect);
  var insert12 = /* @__PURE__ */ insert3(ordForkId);
  var traverse_32 = /* @__PURE__ */ traverse_12(foldableMaybe);
  var lookup12 = /* @__PURE__ */ lookup2(ordForkId);
  var lookup22 = /* @__PURE__ */ lookup2(ordString);
  var foldFree2 = /* @__PURE__ */ foldFree(monadRecAff);
  var alter2 = /* @__PURE__ */ alter(ordString);
  var unsubscribe3 = function(sid) {
    return function(ref2) {
      return function __do3() {
        var v2 = read(ref2)();
        var subs = read(v2.subscriptions)();
        return traverse_4(unsubscribe)(bindFlipped6(lookup5(sid))(subs))();
      };
    };
  };
  var queueOrRun = function(ref2) {
    return function(au) {
      return bind13(liftEffect5(read(ref2)))(function(v2) {
        if (v2 instanceof Nothing) {
          return au;
        }
        ;
        if (v2 instanceof Just) {
          return liftEffect5(write(new Just(new Cons(au, v2.value0)))(ref2));
        }
        ;
        throw new Error("Failed pattern match at Halogen.Aff.Driver.Eval (line 188, column 33 - line 190, column 57): " + [v2.constructor.name]);
      });
    };
  };
  var handleLifecycle = function(lchs) {
    return function(f) {
      return discard1(liftEffect5(write({
        initializers: Nil.value,
        finalizers: Nil.value
      })(lchs)))(function() {
        return bind13(liftEffect5(f))(function(result) {
          return bind13(liftEffect5(read(lchs)))(function(v2) {
            return discard1(traverse_22(fork3)(v2.finalizers))(function() {
              return discard1(parSequence_3(v2.initializers))(function() {
                return pure14(result);
              });
            });
          });
        });
      });
    };
  };
  var handleAff = /* @__PURE__ */ runAff_(/* @__PURE__ */ either(throwException)(/* @__PURE__ */ $$const(/* @__PURE__ */ pure(applicativeEffect)(unit))));
  var fresh = function(f) {
    return function(ref2) {
      return bind13(liftEffect5(read(ref2)))(function(v2) {
        return liftEffect5(modify$prime(function(i2) {
          return {
            state: i2 + 1 | 0,
            value: f(i2)
          };
        })(v2.fresh));
      });
    };
  };
  var evalQ = function(render4) {
    return function(ref2) {
      return function(q3) {
        return bind13(liftEffect5(read(ref2)))(function(v2) {
          return evalM(render4)(ref2)(v2["component"]["eval"](new Query(map26(Just.create)(liftCoyoneda(q3)), $$const(Nothing.value))));
        });
      };
    };
  };
  var evalM = function(render4) {
    return function(initRef) {
      return function(v2) {
        var evalChildQuery = function(ref2) {
          return function(cqb) {
            return bind13(liftEffect5(read(ref2)))(function(v1) {
              return unChildQueryBox(function(v22) {
                var evalChild = function(v3) {
                  return parallel3(bind13(liftEffect5(read(v3)))(function(dsx) {
                    return unDriverStateX(function(ds) {
                      return evalQ(render4)(ds.selfRef)(v22.value1);
                    })(dsx);
                  }));
                };
                return map111(v22.value2)(sequential2(v22.value0(applicativeParAff)(evalChild)(v1.children)));
              })(cqb);
            });
          };
        };
        var go2 = function(ref2) {
          return function(v1) {
            if (v1 instanceof State) {
              return bind13(liftEffect5(read(ref2)))(function(v22) {
                var v3 = v1.value0(v22.state);
                if (unsafeRefEq(v22.state)(v3.value1)) {
                  return pure14(v3.value0);
                }
                ;
                if (otherwise) {
                  return discard1(liftEffect5(write({
                    component: v22.component,
                    refs: v22.refs,
                    children: v22.children,
                    childrenIn: v22.childrenIn,
                    childrenOut: v22.childrenOut,
                    selfRef: v22.selfRef,
                    handlerRef: v22.handlerRef,
                    pendingQueries: v22.pendingQueries,
                    pendingOuts: v22.pendingOuts,
                    pendingHandlers: v22.pendingHandlers,
                    rendering: v22.rendering,
                    fresh: v22.fresh,
                    subscriptions: v22.subscriptions,
                    forks: v22.forks,
                    lifecycleHandlers: v22.lifecycleHandlers,
                    state: v3.value1
                  })(ref2)))(function() {
                    return discard1(handleLifecycle(v22.lifecycleHandlers)(render4(v22.lifecycleHandlers)(ref2)))(function() {
                      return pure14(v3.value0);
                    });
                  });
                }
                ;
                throw new Error("Failed pattern match at Halogen.Aff.Driver.Eval (line 86, column 7 - line 92, column 21): " + [v3.constructor.name]);
              });
            }
            ;
            if (v1 instanceof Subscribe) {
              return bind13(fresh(SubscriptionId)(ref2))(function(sid) {
                return bind13(liftEffect5(subscribe(v1.value0(sid))(function(act) {
                  return handleAff(evalF(render4)(ref2)(new Action(act)));
                })))(function(finalize) {
                  return bind13(liftEffect5(read(ref2)))(function(v22) {
                    return discard1(liftEffect5(modify_(map27(insert7(sid)(finalize)))(v22.subscriptions)))(function() {
                      return pure14(v1.value1(sid));
                    });
                  });
                });
              });
            }
            ;
            if (v1 instanceof Unsubscribe) {
              return discard1(liftEffect5(unsubscribe3(v1.value0)(ref2)))(function() {
                return pure14(v1.value1);
              });
            }
            ;
            if (v1 instanceof Lift2) {
              return v1.value0;
            }
            ;
            if (v1 instanceof ChildQuery2) {
              return evalChildQuery(ref2)(v1.value0);
            }
            ;
            if (v1 instanceof Raise) {
              return bind13(liftEffect5(read(ref2)))(function(v22) {
                return bind13(liftEffect5(read(v22.handlerRef)))(function(handler3) {
                  return discard1(queueOrRun(v22.pendingOuts)(handler3(v1.value0)))(function() {
                    return pure14(v1.value1);
                  });
                });
              });
            }
            ;
            if (v1 instanceof Par) {
              return sequential2(retractFreeAp2(hoistFreeAp((function() {
                var $119 = evalM(render4)(ref2);
                return function($120) {
                  return parallel3($119($120));
                };
              })())(v1.value0)));
            }
            ;
            if (v1 instanceof Fork) {
              return bind13(fresh(ForkId)(ref2))(function(fid) {
                return bind13(liftEffect5(read(ref2)))(function(v22) {
                  return bind13(liftEffect5($$new(false)))(function(doneRef) {
                    return bind13(fork3($$finally(liftEffect5(function __do3() {
                      modify_($$delete4(fid))(v22.forks)();
                      return write(true)(doneRef)();
                    }))(evalM(render4)(ref2)(v1.value0))))(function(fiber) {
                      return discard1(liftEffect5(unlessM2(read(doneRef))(modify_(insert12(fid)(fiber))(v22.forks))))(function() {
                        return pure14(v1.value1(fid));
                      });
                    });
                  });
                });
              });
            }
            ;
            if (v1 instanceof Join) {
              return bind13(liftEffect5(read(ref2)))(function(v22) {
                return bind13(liftEffect5(read(v22.forks)))(function(forkMap) {
                  return discard1(traverse_32(joinFiber)(lookup12(v1.value0)(forkMap)))(function() {
                    return pure14(v1.value1);
                  });
                });
              });
            }
            ;
            if (v1 instanceof Kill) {
              return bind13(liftEffect5(read(ref2)))(function(v22) {
                return bind13(liftEffect5(read(v22.forks)))(function(forkMap) {
                  return discard1(traverse_32(killFiber(error("Cancelled")))(lookup12(v1.value0)(forkMap)))(function() {
                    return pure14(v1.value1);
                  });
                });
              });
            }
            ;
            if (v1 instanceof GetRef) {
              return bind13(liftEffect5(read(ref2)))(function(v22) {
                return pure14(v1.value1(lookup22(v1.value0)(v22.refs)));
              });
            }
            ;
            throw new Error("Failed pattern match at Halogen.Aff.Driver.Eval (line 83, column 12 - line 139, column 33): " + [v1.constructor.name]);
          };
        };
        return foldFree2(go2(initRef))(v2);
      };
    };
  };
  var evalF = function(render4) {
    return function(ref2) {
      return function(v2) {
        if (v2 instanceof RefUpdate) {
          return liftEffect5(flip(modify_)(ref2)(mapDriverState(function(st) {
            return {
              component: st.component,
              state: st.state,
              children: st.children,
              childrenIn: st.childrenIn,
              childrenOut: st.childrenOut,
              selfRef: st.selfRef,
              handlerRef: st.handlerRef,
              pendingQueries: st.pendingQueries,
              pendingOuts: st.pendingOuts,
              pendingHandlers: st.pendingHandlers,
              rendering: st.rendering,
              fresh: st.fresh,
              subscriptions: st.subscriptions,
              forks: st.forks,
              lifecycleHandlers: st.lifecycleHandlers,
              refs: alter2($$const(v2.value1))(v2.value0)(st.refs)
            };
          })));
        }
        ;
        if (v2 instanceof Action) {
          return bind13(liftEffect5(read(ref2)))(function(v1) {
            return evalM(render4)(ref2)(v1["component"]["eval"](new Action2(v2.value0, unit)));
          });
        }
        ;
        throw new Error("Failed pattern match at Halogen.Aff.Driver.Eval (line 52, column 20 - line 58, column 62): " + [v2.constructor.name]);
      };
    };
  };

  // output/Halogen.Aff.Driver/index.js
  var bind9 = /* @__PURE__ */ bind(bindEffect);
  var discard6 = /* @__PURE__ */ discard(discardUnit);
  var for_2 = /* @__PURE__ */ for_(applicativeEffect)(foldableMaybe);
  var traverse_5 = /* @__PURE__ */ traverse_(applicativeAff)(foldableList);
  var fork4 = /* @__PURE__ */ fork2(monadForkAff);
  var bindFlipped7 = /* @__PURE__ */ bindFlipped(bindEffect);
  var traverse_13 = /* @__PURE__ */ traverse_(applicativeEffect);
  var traverse_23 = /* @__PURE__ */ traverse_13(foldableMaybe);
  var traverse_33 = /* @__PURE__ */ traverse_13(foldableMap);
  var discard22 = /* @__PURE__ */ discard6(bindAff);
  var parSequence_4 = /* @__PURE__ */ parSequence_(parallelAff)(applicativeParAff)(foldableList);
  var liftEffect6 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var pure15 = /* @__PURE__ */ pure(applicativeEffect);
  var map28 = /* @__PURE__ */ map(functorEffect);
  var pure16 = /* @__PURE__ */ pure(applicativeAff);
  var when3 = /* @__PURE__ */ when(applicativeEffect);
  var renderStateX2 = /* @__PURE__ */ renderStateX(functorEffect);
  var $$void7 = /* @__PURE__ */ $$void(functorAff);
  var foreachSlot2 = /* @__PURE__ */ foreachSlot(applicativeEffect);
  var renderStateX_2 = /* @__PURE__ */ renderStateX_(applicativeEffect);
  var tailRecM3 = /* @__PURE__ */ tailRecM(monadRecEffect);
  var voidLeft3 = /* @__PURE__ */ voidLeft(functorEffect);
  var bind14 = /* @__PURE__ */ bind(bindAff);
  var liftEffect1 = /* @__PURE__ */ liftEffect(monadEffectEffect);
  var newLifecycleHandlers = /* @__PURE__ */ (function() {
    return $$new({
      initializers: Nil.value,
      finalizers: Nil.value
    });
  })();
  var handlePending = function(ref2) {
    return function __do3() {
      var queue = read(ref2)();
      write(Nothing.value)(ref2)();
      return for_2(queue)((function() {
        var $59 = traverse_5(fork4);
        return function($60) {
          return handleAff($59(reverse2($60)));
        };
      })())();
    };
  };
  var cleanupSubscriptionsAndForks = function(v2) {
    return function __do3() {
      bindFlipped7(traverse_23(traverse_33(unsubscribe)))(read(v2.subscriptions))();
      write(Nothing.value)(v2.subscriptions)();
      bindFlipped7(traverse_33((function() {
        var $61 = killFiber(error("finalized"));
        return function($62) {
          return handleAff($61($62));
        };
      })()))(read(v2.forks))();
      return write(empty3)(v2.forks)();
    };
  };
  var runUI = function(renderSpec2) {
    return function(component5) {
      return function(i2) {
        var squashChildInitializers = function(lchs) {
          return function(preInits) {
            return unDriverStateX(function(st) {
              var parentInitializer = evalM(render4)(st.selfRef)(st["component"]["eval"](new Initialize(unit)));
              return modify_(function(handlers) {
                return {
                  initializers: new Cons(discard22(parSequence_4(reverse2(handlers.initializers)))(function() {
                    return discard22(parentInitializer)(function() {
                      return liftEffect6(function __do3() {
                        handlePending(st.pendingQueries)();
                        return handlePending(st.pendingOuts)();
                      });
                    });
                  }), preInits),
                  finalizers: handlers.finalizers
                };
              })(lchs);
            });
          };
        };
        var runComponent = function(lchs) {
          return function(handler3) {
            return function(j) {
              return unComponent(function(c2) {
                return function __do3() {
                  var lchs$prime = newLifecycleHandlers();
                  var $$var2 = initDriverState(c2)(j)(handler3)(lchs$prime)();
                  var pre2 = read(lchs)();
                  write({
                    initializers: Nil.value,
                    finalizers: pre2.finalizers
                  })(lchs)();
                  bindFlipped7(unDriverStateX((function() {
                    var $63 = render4(lchs);
                    return function($64) {
                      return $63((function(v2) {
                        return v2.selfRef;
                      })($64));
                    };
                  })()))(read($$var2))();
                  bindFlipped7(squashChildInitializers(lchs)(pre2.initializers))(read($$var2))();
                  return $$var2;
                };
              });
            };
          };
        };
        var renderChild = function(lchs) {
          return function(handler3) {
            return function(childrenInRef) {
              return function(childrenOutRef) {
                return unComponentSlot(function(slot3) {
                  return function __do3() {
                    var childrenIn = map28(slot3.pop)(read(childrenInRef))();
                    var $$var2 = (function() {
                      if (childrenIn instanceof Just) {
                        write(childrenIn.value0.value1)(childrenInRef)();
                        var dsx = read(childrenIn.value0.value0)();
                        unDriverStateX(function(st) {
                          return function __do4() {
                            flip(write)(st.handlerRef)((function() {
                              var $65 = maybe(pure16(unit))(handler3);
                              return function($66) {
                                return $65(slot3.output($66));
                              };
                            })())();
                            return handleAff(evalM(render4)(st.selfRef)(st["component"]["eval"](new Receive(slot3.input, unit))))();
                          };
                        })(dsx)();
                        return childrenIn.value0.value0;
                      }
                      ;
                      if (childrenIn instanceof Nothing) {
                        return runComponent(lchs)((function() {
                          var $67 = maybe(pure16(unit))(handler3);
                          return function($68) {
                            return $67(slot3.output($68));
                          };
                        })())(slot3.input)(slot3.component)();
                      }
                      ;
                      throw new Error("Failed pattern match at Halogen.Aff.Driver (line 213, column 14 - line 222, column 98): " + [childrenIn.constructor.name]);
                    })();
                    var isDuplicate = map28(function($69) {
                      return isJust(slot3.get($69));
                    })(read(childrenOutRef))();
                    when3(isDuplicate)(warn("Halogen: Duplicate slot address was detected during rendering, unexpected results may occur"))();
                    modify_(slot3.set($$var2))(childrenOutRef)();
                    return bind9(read($$var2))(renderStateX2(function(v2) {
                      if (v2 instanceof Nothing) {
                        return $$throw("Halogen internal error: child was not initialized in renderChild");
                      }
                      ;
                      if (v2 instanceof Just) {
                        return pure15(renderSpec2.renderChild(v2.value0));
                      }
                      ;
                      throw new Error("Failed pattern match at Halogen.Aff.Driver (line 227, column 37 - line 229, column 50): " + [v2.constructor.name]);
                    }))();
                  };
                });
              };
            };
          };
        };
        var render4 = function(lchs) {
          return function($$var2) {
            return function __do3() {
              var v2 = read($$var2)();
              var shouldProcessHandlers = map28(isNothing)(read(v2.pendingHandlers))();
              when3(shouldProcessHandlers)(write(new Just(Nil.value))(v2.pendingHandlers))();
              write(empty4)(v2.childrenOut)();
              write(v2.children)(v2.childrenIn)();
              var handler3 = (function() {
                var $70 = queueOrRun(v2.pendingHandlers);
                var $71 = evalF(render4)(v2.selfRef);
                return function($72) {
                  return $70($$void7($71($72)));
                };
              })();
              var childHandler = (function() {
                var $73 = queueOrRun(v2.pendingQueries);
                return function($74) {
                  return $73(handler3(Action.create($74)));
                };
              })();
              var rendering = renderSpec2.render(function($75) {
                return handleAff(handler3($75));
              })(renderChild(lchs)(childHandler)(v2.childrenIn)(v2.childrenOut))(v2.component.render(v2.state))(v2.rendering)();
              var children2 = read(v2.childrenOut)();
              var childrenIn = read(v2.childrenIn)();
              foreachSlot2(childrenIn)(function(v1) {
                return function __do4() {
                  var childDS = read(v1)();
                  renderStateX_2(renderSpec2.removeChild)(childDS)();
                  return finalize(lchs)(childDS)();
                };
              })();
              flip(modify_)(v2.selfRef)(mapDriverState(function(ds$prime) {
                return {
                  component: ds$prime.component,
                  state: ds$prime.state,
                  refs: ds$prime.refs,
                  childrenIn: ds$prime.childrenIn,
                  childrenOut: ds$prime.childrenOut,
                  selfRef: ds$prime.selfRef,
                  handlerRef: ds$prime.handlerRef,
                  pendingQueries: ds$prime.pendingQueries,
                  pendingOuts: ds$prime.pendingOuts,
                  pendingHandlers: ds$prime.pendingHandlers,
                  fresh: ds$prime.fresh,
                  subscriptions: ds$prime.subscriptions,
                  forks: ds$prime.forks,
                  lifecycleHandlers: ds$prime.lifecycleHandlers,
                  rendering: new Just(rendering),
                  children: children2
                };
              }))();
              return when3(shouldProcessHandlers)(flip(tailRecM3)(unit)(function(v1) {
                return function __do4() {
                  var handlers = read(v2.pendingHandlers)();
                  write(new Just(Nil.value))(v2.pendingHandlers)();
                  traverse_23((function() {
                    var $76 = traverse_5(fork4);
                    return function($77) {
                      return handleAff($76(reverse2($77)));
                    };
                  })())(handlers)();
                  var mmore = read(v2.pendingHandlers)();
                  var $52 = maybe(false)($$null)(mmore);
                  if ($52) {
                    return voidLeft3(write(Nothing.value)(v2.pendingHandlers))(new Done(unit))();
                  }
                  ;
                  return new Loop(unit);
                };
              }))();
            };
          };
        };
        var finalize = function(lchs) {
          return unDriverStateX(function(st) {
            return function __do3() {
              cleanupSubscriptionsAndForks(st)();
              var f = evalM(render4)(st.selfRef)(st["component"]["eval"](new Finalize(unit)));
              modify_(function(handlers) {
                return {
                  initializers: handlers.initializers,
                  finalizers: new Cons(f, handlers.finalizers)
                };
              })(lchs)();
              return foreachSlot2(st.children)(function(v2) {
                return function __do4() {
                  var dsx = read(v2)();
                  return finalize(lchs)(dsx)();
                };
              })();
            };
          });
        };
        var evalDriver = function(disposed) {
          return function(ref2) {
            return function(q3) {
              return bind14(liftEffect6(read(disposed)))(function(v2) {
                if (v2) {
                  return pure16(Nothing.value);
                }
                ;
                return evalQ(render4)(ref2)(q3);
              });
            };
          };
        };
        var dispose = function(disposed) {
          return function(lchs) {
            return function(dsx) {
              return handleLifecycle(lchs)(function __do3() {
                var v2 = read(disposed)();
                if (v2) {
                  return unit;
                }
                ;
                write(true)(disposed)();
                finalize(lchs)(dsx)();
                return unDriverStateX(function(v1) {
                  return function __do4() {
                    var v22 = liftEffect1(read(v1.selfRef))();
                    return for_2(v22.rendering)(renderSpec2.dispose)();
                  };
                })(dsx)();
              });
            };
          };
        };
        return bind14(liftEffect6(newLifecycleHandlers))(function(lchs) {
          return bind14(liftEffect6($$new(false)))(function(disposed) {
            return handleLifecycle(lchs)(function __do3() {
              var sio = create();
              var dsx = bindFlipped7(read)(runComponent(lchs)((function() {
                var $78 = notify(sio.listener);
                return function($79) {
                  return liftEffect6($78($79));
                };
              })())(i2)(component5))();
              return unDriverStateX(function(st) {
                return pure15({
                  query: evalDriver(disposed)(st.selfRef),
                  messages: sio.emitter,
                  dispose: dispose(disposed)(lchs)(dsx)
                });
              })(dsx)();
            });
          });
        });
      };
    };
  };

  // output/Web.DOM.Node/foreign.js
  var getEffProp2 = function(name16) {
    return function(node) {
      return function() {
        return node[name16];
      };
    };
  };
  var baseURI = getEffProp2("baseURI");
  var _ownerDocument = getEffProp2("ownerDocument");
  var _parentNode = getEffProp2("parentNode");
  var _parentElement = getEffProp2("parentElement");
  var childNodes = getEffProp2("childNodes");
  var _firstChild = getEffProp2("firstChild");
  var _lastChild = getEffProp2("lastChild");
  var _previousSibling = getEffProp2("previousSibling");
  var _nextSibling = getEffProp2("nextSibling");
  var _nodeValue = getEffProp2("nodeValue");
  var textContent = getEffProp2("textContent");
  function insertBefore(node1) {
    return function(node2) {
      return function(parent2) {
        return function() {
          parent2.insertBefore(node1, node2);
        };
      };
    };
  }
  function appendChild(node) {
    return function(parent2) {
      return function() {
        parent2.appendChild(node);
      };
    };
  }
  function removeChild2(node) {
    return function(parent2) {
      return function() {
        parent2.removeChild(node);
      };
    };
  }

  // output/Web.DOM.Node/index.js
  var map29 = /* @__PURE__ */ map(functorEffect);
  var parentNode2 = /* @__PURE__ */ (function() {
    var $6 = map29(toMaybe);
    return function($7) {
      return $6(_parentNode($7));
    };
  })();
  var nextSibling = /* @__PURE__ */ (function() {
    var $15 = map29(toMaybe);
    return function($16) {
      return $15(_nextSibling($16));
    };
  })();

  // output/Halogen.VDom.Driver/index.js
  var $runtime_lazy8 = function(name16, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name16 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var $$void8 = /* @__PURE__ */ $$void(functorEffect);
  var pure17 = /* @__PURE__ */ pure(applicativeEffect);
  var traverse_6 = /* @__PURE__ */ traverse_(applicativeEffect)(foldableMaybe);
  var unwrap5 = /* @__PURE__ */ unwrap();
  var when4 = /* @__PURE__ */ when(applicativeEffect);
  var not2 = /* @__PURE__ */ not(/* @__PURE__ */ heytingAlgebraFunction(/* @__PURE__ */ heytingAlgebraFunction(heytingAlgebraBoolean)));
  var identity12 = /* @__PURE__ */ identity(categoryFn);
  var bind15 = /* @__PURE__ */ bind(bindAff);
  var liftEffect7 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var map30 = /* @__PURE__ */ map(functorEffect);
  var bindFlipped8 = /* @__PURE__ */ bindFlipped(bindEffect);
  var substInParent = function(v2) {
    return function(v1) {
      return function(v22) {
        if (v1 instanceof Just && v22 instanceof Just) {
          return $$void8(insertBefore(v2)(v1.value0)(v22.value0));
        }
        ;
        if (v1 instanceof Nothing && v22 instanceof Just) {
          return $$void8(appendChild(v2)(v22.value0));
        }
        ;
        return pure17(unit);
      };
    };
  };
  var removeChild3 = function(v2) {
    return function __do3() {
      var npn = parentNode2(v2.node)();
      return traverse_6(function(pn) {
        return removeChild2(v2.node)(pn);
      })(npn)();
    };
  };
  var mkSpec = function(handler3) {
    return function(renderChildRef) {
      return function(document3) {
        var getNode = unRenderStateX(function(v2) {
          return v2.node;
        });
        var done = function(st) {
          if (st instanceof Just) {
            return halt(st.value0);
          }
          ;
          return unit;
        };
        var buildWidget2 = function(spec) {
          var buildThunk2 = buildThunk(unwrap5)(spec);
          var $lazy_patch = $runtime_lazy8("patch", "Halogen.VDom.Driver", function() {
            return function(st, slot3) {
              if (st instanceof Just) {
                if (slot3 instanceof ComponentSlot) {
                  halt(st.value0);
                  return $lazy_renderComponentSlot(100)(slot3.value0);
                }
                ;
                if (slot3 instanceof ThunkSlot) {
                  var step$prime = step(st.value0, slot3.value0);
                  return mkStep(new Step(extract2(step$prime), new Just(step$prime), $lazy_patch(103), done));
                }
                ;
                throw new Error("Failed pattern match at Halogen.VDom.Driver (line 97, column 22 - line 103, column 79): " + [slot3.constructor.name]);
              }
              ;
              return $lazy_render(104)(slot3);
            };
          });
          var $lazy_render = $runtime_lazy8("render", "Halogen.VDom.Driver", function() {
            return function(slot3) {
              if (slot3 instanceof ComponentSlot) {
                return $lazy_renderComponentSlot(86)(slot3.value0);
              }
              ;
              if (slot3 instanceof ThunkSlot) {
                var step3 = buildThunk2(slot3.value0);
                return mkStep(new Step(extract2(step3), new Just(step3), $lazy_patch(89), done));
              }
              ;
              throw new Error("Failed pattern match at Halogen.VDom.Driver (line 84, column 7 - line 89, column 75): " + [slot3.constructor.name]);
            };
          });
          var $lazy_renderComponentSlot = $runtime_lazy8("renderComponentSlot", "Halogen.VDom.Driver", function() {
            return function(cs) {
              var renderChild = read(renderChildRef)();
              var rsx = renderChild(cs)();
              var node = getNode(rsx);
              return mkStep(new Step(node, Nothing.value, $lazy_patch(117), done));
            };
          });
          var patch2 = $lazy_patch(91);
          var render4 = $lazy_render(82);
          var renderComponentSlot = $lazy_renderComponentSlot(109);
          return render4;
        };
        var buildAttributes = buildProp(handler3);
        return {
          buildWidget: buildWidget2,
          buildAttributes,
          document: document3
        };
      };
    };
  };
  var renderSpec = function(document3) {
    return function(container) {
      var render4 = function(handler3) {
        return function(child) {
          return function(v2) {
            return function(v1) {
              if (v1 instanceof Nothing) {
                return function __do3() {
                  var renderChildRef = $$new(child)();
                  var spec = mkSpec(handler3)(renderChildRef)(document3);
                  var machine = buildVDom(spec)(v2);
                  var node = extract2(machine);
                  $$void8(appendChild(node)(toNode2(container)))();
                  return {
                    machine,
                    node,
                    renderChildRef
                  };
                };
              }
              ;
              if (v1 instanceof Just) {
                return function __do3() {
                  write(child)(v1.value0.renderChildRef)();
                  var parent2 = parentNode2(v1.value0.node)();
                  var nextSib = nextSibling(v1.value0.node)();
                  var machine$prime = step(v1.value0.machine, v2);
                  var newNode = extract2(machine$prime);
                  when4(not2(unsafeRefEq)(v1.value0.node)(newNode))(substInParent(newNode)(nextSib)(parent2))();
                  return {
                    machine: machine$prime,
                    node: newNode,
                    renderChildRef: v1.value0.renderChildRef
                  };
                };
              }
              ;
              throw new Error("Failed pattern match at Halogen.VDom.Driver (line 157, column 5 - line 173, column 80): " + [v1.constructor.name]);
            };
          };
        };
      };
      return {
        render: render4,
        renderChild: identity12,
        removeChild: removeChild3,
        dispose: removeChild3
      };
    };
  };
  var runUI2 = function(component5) {
    return function(i2) {
      return function(element4) {
        return bind15(liftEffect7(map30(toDocument)(bindFlipped8(document2)(windowImpl))))(function(document3) {
          return runUI(renderSpec(document3)(element4))(component5)(i2);
        });
      };
    };
  };

  // output/Main/index.js
  var component4 = /* @__PURE__ */ component3(monadAffAff);
  var main2 = /* @__PURE__ */ runHalogenAff(/* @__PURE__ */ bind(bindAff)(awaitBody)(function(body2) {
    return runUI2(component4(createAPIDatabase(monadAffAff)))(unit)(body2);
  }));

  // <stdin>
  main2();
})();
/*! Bundled license information:

decimal.js/decimal.mjs:
  (*!
   *  decimal.js v10.6.0
   *  An arbitrary-precision Decimal type for JavaScript.
   *  https://github.com/MikeMcl/decimal.js
   *  Copyright (c) 2025 Michael Mclaughlin <M8ch88l@gmail.com>
   *  MIT Licence
   *)
*/
