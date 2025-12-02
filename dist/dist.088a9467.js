(()=>{
    // output/Affjax/foreign.js
    function _ajax(platformSpecificDriver, timeoutErrorMessageIdent, requestFailedMessageIdent, mkHeader, options2) {
        return function(errback, callback) {
            var xhr = platformSpecificDriver.newXHR();
            var fixedUrl = platformSpecificDriver.fixupUrl(options2.url, xhr);
            xhr.open(options2.method || "GET", fixedUrl, true, options2.username, options2.password);
            if (options2.headers) try {
                for(var i2 = 0, header2; (header2 = options2.headers[i2]) != null; i2++)xhr.setRequestHeader(header2.field, header2.value);
            } catch (e) {
                errback(e);
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
    // output/Data.Functor/foreign.js
    var arrayMap = function(f) {
        return function(arr) {
            var l2 = arr.length;
            var result = new Array(l2);
            for(var i2 = 0; i2 < l2; i2++)result[i2] = f(arr[i2]);
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
    // output/Data.Unit/foreign.js
    var unit = void 0;
    // output/Type.Proxy/index.js
    var $$Proxy = /* @__PURE__ */ function() {
        function $$Proxy2() {}
        $$Proxy2.value = new $$Proxy2();
        return $$Proxy2;
    }();
    // output/Data.Functor/index.js
    var map = function(dict) {
        return dict.map;
    };
    var mapFlipped = function(dictFunctor) {
        var map111 = map(dictFunctor);
        return function(fa) {
            return function(f) {
                return map111(f)(fa);
            };
        };
    };
    var $$void = function(dictFunctor) {
        return map(dictFunctor)($$const(unit));
    };
    var voidLeft = function(dictFunctor) {
        var map111 = map(dictFunctor);
        return function(f) {
            return function(x) {
                return map111($$const(x))(f);
            };
        };
    };
    var voidRight = function(dictFunctor) {
        var map111 = map(dictFunctor);
        return function(x) {
            return map111($$const(x));
        };
    };
    var functorArray = {
        map: arrayMap
    };
    // output/Data.Semigroup/foreign.js
    var concatArray = function(xs) {
        return function(ys) {
            if (xs.length === 0) return ys;
            if (ys.length === 0) return xs;
            return xs.concat(ys);
        };
    };
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
    // output/Data.Semigroup/index.js
    var semigroupArray = {
        append: concatArray
    };
    var append = function(dict) {
        return dict.append;
    };
    // output/Control.Alt/index.js
    var alt = function(dict) {
        return dict.alt;
    };
    // output/Control.Apply/foreign.js
    var arrayApply = function(fs) {
        return function(xs) {
            var l2 = fs.length;
            var k = xs.length;
            var result = new Array(l2 * k);
            var n = 0;
            for(var i2 = 0; i2 < l2; i2++){
                var f = fs[i2];
                for(var j = 0; j < k; j++)result[n++] = f(xs[j]);
            }
            return result;
        };
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
        var map34 = map(dictApply.Functor0());
        return function(a3) {
            return function(b2) {
                return apply1(map34($$const(identity2))(a3))(b2);
            };
        };
    };
    // output/Control.Applicative/index.js
    var pure = function(dict) {
        return dict.pure;
    };
    var unless = function(dictApplicative) {
        var pure111 = pure(dictApplicative);
        return function(v2) {
            return function(v1) {
                if (!v2) return v1;
                if (v2) return pure111(unit);
                throw new Error("Failed pattern match at Control.Applicative (line 68, column 1 - line 68, column 65): " + [
                    v2.constructor.name,
                    v1.constructor.name
                ]);
            };
        };
    };
    var when = function(dictApplicative) {
        var pure111 = pure(dictApplicative);
        return function(v2) {
            return function(v1) {
                if (v2) return v1;
                if (!v2) return pure111(unit);
                throw new Error("Failed pattern match at Control.Applicative (line 63, column 1 - line 63, column 63): " + [
                    v2.constructor.name,
                    v1.constructor.name
                ]);
            };
        };
    };
    var liftA1 = function(dictApplicative) {
        var apply3 = apply(dictApplicative.Apply0());
        var pure111 = pure(dictApplicative);
        return function(f) {
            return function(a3) {
                return apply3(pure111(f))(a3);
            };
        };
    };
    // output/Data.Bounded/foreign.js
    var topInt = 2147483647;
    var bottomInt = -2147483648;
    var topChar = String.fromCharCode(65535);
    var bottomChar = String.fromCharCode(0);
    var topNumber = Number.POSITIVE_INFINITY;
    var bottomNumber = Number.NEGATIVE_INFINITY;
    // output/Data.Ord/foreign.js
    var unsafeCompareImpl = function(lt) {
        return function(eq7) {
            return function(gt) {
                return function(x) {
                    return function(y) {
                        return x < y ? lt : x === y ? eq7 : gt;
                    };
                };
            };
        };
    };
    var ordIntImpl = unsafeCompareImpl;
    var ordNumberImpl = unsafeCompareImpl;
    var ordStringImpl = unsafeCompareImpl;
    var ordCharImpl = unsafeCompareImpl;
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
        var eq32 = eq(dictEq);
        return function(x) {
            return function(y) {
                return eq2(eq32(x)(y))(false);
            };
        };
    };
    // output/Data.Ordering/index.js
    var LT = /* @__PURE__ */ function() {
        function LT2() {}
        LT2.value = new LT2();
        return LT2;
    }();
    var GT = /* @__PURE__ */ function() {
        function GT2() {}
        GT2.value = new GT2();
        return GT2;
    }();
    var EQ = /* @__PURE__ */ function() {
        function EQ2() {}
        EQ2.value = new EQ2();
        return EQ2;
    }();
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
    var ordString = /* @__PURE__ */ function() {
        return {
            compare: ordStringImpl(LT.value)(EQ.value)(GT.value),
            Eq0: function() {
                return eqString;
            }
        };
    }();
    var ordNumber = /* @__PURE__ */ function() {
        return {
            compare: ordNumberImpl(LT.value)(EQ.value)(GT.value),
            Eq0: function() {
                return eqNumber;
            }
        };
    }();
    var ordInt = /* @__PURE__ */ function() {
        return {
            compare: ordIntImpl(LT.value)(EQ.value)(GT.value),
            Eq0: function() {
                return eqInt;
            }
        };
    }();
    var ordChar = /* @__PURE__ */ function() {
        return {
            compare: ordCharImpl(LT.value)(EQ.value)(GT.value),
            Eq0: function() {
                return eqChar;
            }
        };
    }();
    var compare = function(dict) {
        return dict.compare;
    };
    var max = function(dictOrd) {
        var compare3 = compare(dictOrd);
        return function(x) {
            return function(y) {
                var v2 = compare3(x)(y);
                if (v2 instanceof LT) return y;
                if (v2 instanceof EQ) return x;
                if (v2 instanceof GT) return x;
                throw new Error("Failed pattern match at Data.Ord (line 181, column 3 - line 184, column 12): " + [
                    v2.constructor.name
                ]);
            };
        };
    };
    var min = function(dictOrd) {
        var compare3 = compare(dictOrd);
        return function(x) {
            return function(y) {
                var v2 = compare3(x)(y);
                if (v2 instanceof LT) return x;
                if (v2 instanceof EQ) return x;
                if (v2 instanceof GT) return y;
                throw new Error("Failed pattern match at Data.Ord (line 172, column 3 - line 175, column 12): " + [
                    v2.constructor.name
                ]);
            };
        };
    };
    var clamp = function(dictOrd) {
        var min1 = min(dictOrd);
        var max12 = max(dictOrd);
        return function(low2) {
            return function(hi) {
                return function(x) {
                    return min1(hi)(max12(low2)(x));
                };
            };
        };
    };
    // output/Data.Bounded/index.js
    var top = function(dict) {
        return dict.top;
    };
    var boundedInt = {
        top: topInt,
        bottom: bottomInt,
        Ord0: function() {
            return ordInt;
        }
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
        return '"' + s2.replace(/[\0-\x1F\x7F"\\]/g, // eslint-disable-line no-control-regex
        function(c2, i2) {
            switch(c2){
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
        }) + '"';
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
            if (v2) return "true";
            if (!v2) return "false";
            throw new Error("Failed pattern match at Data.Show (line 29, column 1 - line 31, column 23): " + [
                v2.constructor.name
            ]);
        }
    };
    var show = function(dict) {
        return dict.show;
    };
    // output/Data.Maybe/index.js
    var identity3 = /* @__PURE__ */ identity(categoryFn);
    var Nothing = /* @__PURE__ */ function() {
        function Nothing2() {}
        Nothing2.value = new Nothing2();
        return Nothing2;
    }();
    var Just = /* @__PURE__ */ function() {
        function Just2(value0) {
            this.value0 = value0;
        }
        Just2.create = function(value0) {
            return new Just2(value0);
        };
        return Just2;
    }();
    var maybe = function(v2) {
        return function(v1) {
            return function(v22) {
                if (v22 instanceof Nothing) return v2;
                if (v22 instanceof Just) return v1(v22.value0);
                throw new Error("Failed pattern match at Data.Maybe (line 237, column 1 - line 237, column 51): " + [
                    v2.constructor.name,
                    v1.constructor.name,
                    v22.constructor.name
                ]);
            };
        };
    };
    var isNothing = /* @__PURE__ */ maybe(true)(/* @__PURE__ */ $$const(false));
    var isJust = /* @__PURE__ */ maybe(false)(/* @__PURE__ */ $$const(true));
    var functorMaybe = {
        map: function(v2) {
            return function(v1) {
                if (v1 instanceof Just) return new Just(v2(v1.value0));
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
            if (v2 instanceof Just) return v2.value0;
            throw new Error("Failed pattern match at Data.Maybe (line 288, column 1 - line 288, column 46): " + [
                v2.constructor.name
            ]);
        };
    };
    var eqMaybe = function(dictEq) {
        var eq7 = eq(dictEq);
        return {
            eq: function(x) {
                return function(y) {
                    if (x instanceof Nothing && y instanceof Nothing) return true;
                    if (x instanceof Just && y instanceof Just) return eq7(x.value0)(y.value0);
                    return false;
                };
            }
        };
    };
    var applyMaybe = {
        apply: function(v2) {
            return function(v1) {
                if (v2 instanceof Just) return map2(v2.value0)(v1);
                if (v2 instanceof Nothing) return Nothing.value;
                throw new Error("Failed pattern match at Data.Maybe (line 67, column 1 - line 69, column 30): " + [
                    v2.constructor.name,
                    v1.constructor.name
                ]);
            };
        },
        Functor0: function() {
            return functorMaybe;
        }
    };
    var bindMaybe = {
        bind: function(v2) {
            return function(v1) {
                if (v2 instanceof Just) return v1(v2.value0);
                if (v2 instanceof Nothing) return Nothing.value;
                throw new Error("Failed pattern match at Data.Maybe (line 125, column 1 - line 127, column 28): " + [
                    v2.constructor.name,
                    v1.constructor.name
                ]);
            };
        },
        Apply0: function() {
            return applyMaybe;
        }
    };
    var applicativeMaybe = /* @__PURE__ */ function() {
        return {
            pure: Just.create,
            Apply0: function() {
                return applyMaybe;
            }
        };
    }();
    // output/Data.MediaType.Common/index.js
    var applicationJSON = "application/json";
    var applicationFormURLEncoded = "application/x-www-form-urlencoded";
    // output/Affjax.RequestBody/index.js
    var ArrayView = /* @__PURE__ */ function() {
        function ArrayView2(value0) {
            this.value0 = value0;
        }
        ArrayView2.create = function(value0) {
            return new ArrayView2(value0);
        };
        return ArrayView2;
    }();
    var Blob = /* @__PURE__ */ function() {
        function Blob3(value0) {
            this.value0 = value0;
        }
        Blob3.create = function(value0) {
            return new Blob3(value0);
        };
        return Blob3;
    }();
    var Document = /* @__PURE__ */ function() {
        function Document3(value0) {
            this.value0 = value0;
        }
        Document3.create = function(value0) {
            return new Document3(value0);
        };
        return Document3;
    }();
    var $$String = /* @__PURE__ */ function() {
        function $$String3(value0) {
            this.value0 = value0;
        }
        $$String3.create = function(value0) {
            return new $$String3(value0);
        };
        return $$String3;
    }();
    var FormData = /* @__PURE__ */ function() {
        function FormData2(value0) {
            this.value0 = value0;
        }
        FormData2.create = function(value0) {
            return new FormData2(value0);
        };
        return FormData2;
    }();
    var FormURLEncoded = /* @__PURE__ */ function() {
        function FormURLEncoded2(value0) {
            this.value0 = value0;
        }
        FormURLEncoded2.create = function(value0) {
            return new FormURLEncoded2(value0);
        };
        return FormURLEncoded2;
    }();
    var Json = /* @__PURE__ */ function() {
        function Json3(value0) {
            this.value0 = value0;
        }
        Json3.create = function(value0) {
            return new Json3(value0);
        };
        return Json3;
    }();
    var toMediaType = function(v2) {
        if (v2 instanceof FormURLEncoded) return new Just(applicationFormURLEncoded);
        if (v2 instanceof Json) return new Just(applicationJSON);
        return Nothing.value;
    };
    var json = /* @__PURE__ */ function() {
        return Json.create;
    }();
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
    // output/Affjax.RequestHeader/index.js
    var unwrap2 = /* @__PURE__ */ unwrap();
    var Accept = /* @__PURE__ */ function() {
        function Accept2(value0) {
            this.value0 = value0;
        }
        Accept2.create = function(value0) {
            return new Accept2(value0);
        };
        return Accept2;
    }();
    var ContentType = /* @__PURE__ */ function() {
        function ContentType2(value0) {
            this.value0 = value0;
        }
        ContentType2.create = function(value0) {
            return new ContentType2(value0);
        };
        return ContentType2;
    }();
    var RequestHeader = /* @__PURE__ */ function() {
        function RequestHeader2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        RequestHeader2.create = function(value0) {
            return function(value1) {
                return new RequestHeader2(value0, value1);
            };
        };
        return RequestHeader2;
    }();
    var value = function(v2) {
        if (v2 instanceof Accept) return unwrap2(v2.value0);
        if (v2 instanceof ContentType) return unwrap2(v2.value0);
        if (v2 instanceof RequestHeader) return v2.value1;
        throw new Error("Failed pattern match at Affjax.RequestHeader (line 26, column 1 - line 26, column 33): " + [
            v2.constructor.name
        ]);
    };
    var name = function(v2) {
        if (v2 instanceof Accept) return "Accept";
        if (v2 instanceof ContentType) return "Content-Type";
        if (v2 instanceof RequestHeader) return v2.value0;
        throw new Error("Failed pattern match at Affjax.RequestHeader (line 21, column 1 - line 21, column 32): " + [
            v2.constructor.name
        ]);
    };
    // output/Affjax.ResponseFormat/index.js
    var identity4 = /* @__PURE__ */ identity(categoryFn);
    var $$ArrayBuffer = /* @__PURE__ */ function() {
        function $$ArrayBuffer2(value0) {
            this.value0 = value0;
        }
        $$ArrayBuffer2.create = function(value0) {
            return new $$ArrayBuffer2(value0);
        };
        return $$ArrayBuffer2;
    }();
    var Blob2 = /* @__PURE__ */ function() {
        function Blob3(value0) {
            this.value0 = value0;
        }
        Blob3.create = function(value0) {
            return new Blob3(value0);
        };
        return Blob3;
    }();
    var Document2 = /* @__PURE__ */ function() {
        function Document3(value0) {
            this.value0 = value0;
        }
        Document3.create = function(value0) {
            return new Document3(value0);
        };
        return Document3;
    }();
    var Json2 = /* @__PURE__ */ function() {
        function Json3(value0) {
            this.value0 = value0;
        }
        Json3.create = function(value0) {
            return new Json3(value0);
        };
        return Json3;
    }();
    var $$String2 = /* @__PURE__ */ function() {
        function $$String3(value0) {
            this.value0 = value0;
        }
        $$String3.create = function(value0) {
            return new $$String3(value0);
        };
        return $$String3;
    }();
    var Ignore = /* @__PURE__ */ function() {
        function Ignore2(value0) {
            this.value0 = value0;
        }
        Ignore2.create = function(value0) {
            return new Ignore2(value0);
        };
        return Ignore2;
    }();
    var toResponseType = function(v2) {
        if (v2 instanceof $$ArrayBuffer) return "arraybuffer";
        if (v2 instanceof Blob2) return "blob";
        if (v2 instanceof Document2) return "document";
        if (v2 instanceof Json2) return "text";
        if (v2 instanceof $$String2) return "text";
        if (v2 instanceof Ignore) return "";
        throw new Error("Failed pattern match at Affjax.ResponseFormat (line 44, column 3 - line 50, column 19): " + [
            v2.constructor.name
        ]);
    };
    var toMediaType2 = function(v2) {
        if (v2 instanceof Json2) return new Just(applicationJSON);
        return Nothing.value;
    };
    var json2 = /* @__PURE__ */ function() {
        return new Json2(identity4);
    }();
    var ignore = /* @__PURE__ */ function() {
        return new Ignore(identity4);
    }();
    // output/Affjax.ResponseHeader/index.js
    var ResponseHeader = /* @__PURE__ */ function() {
        function ResponseHeader2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        ResponseHeader2.create = function(value0) {
            return function(value1) {
                return new ResponseHeader2(value0, value1);
            };
        };
        return ResponseHeader2;
    }();
    // output/Control.Bind/foreign.js
    var arrayBind = function(arr) {
        return function(f) {
            var result = [];
            for(var i2 = 0, l2 = arr.length; i2 < l2; i2++)Array.prototype.push.apply(result, f(arr[i2]));
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
        var bind19 = bind(dictBind);
        return function(f) {
            return function(g) {
                return function(a3) {
                    return bind19(f(a3))(g);
                };
            };
        };
    };
    var discardUnit = {
        discard: function(dictBind) {
            return bind(dictBind);
        }
    };
    // output/Data.Either/index.js
    var Left = /* @__PURE__ */ function() {
        function Left2(value0) {
            this.value0 = value0;
        }
        Left2.create = function(value0) {
            return new Left2(value0);
        };
        return Left2;
    }();
    var Right = /* @__PURE__ */ function() {
        function Right2(value0) {
            this.value0 = value0;
        }
        Right2.create = function(value0) {
            return new Right2(value0);
        };
        return Right2;
    }();
    var note = function(a3) {
        return maybe(new Left(a3))(Right.create);
    };
    var functorEither = {
        map: function(f) {
            return function(m2) {
                if (m2 instanceof Left) return new Left(m2.value0);
                if (m2 instanceof Right) return new Right(f(m2.value0));
                throw new Error("Failed pattern match at Data.Either (line 0, column 0 - line 0, column 0): " + [
                    m2.constructor.name
                ]);
            };
        }
    };
    var map3 = /* @__PURE__ */ map(functorEither);
    var either = function(v2) {
        return function(v1) {
            return function(v22) {
                if (v22 instanceof Left) return v2(v22.value0);
                if (v22 instanceof Right) return v1(v22.value0);
                throw new Error("Failed pattern match at Data.Either (line 208, column 1 - line 208, column 64): " + [
                    v2.constructor.name,
                    v1.constructor.name,
                    v22.constructor.name
                ]);
            };
        };
    };
    var applyEither = {
        apply: function(v2) {
            return function(v1) {
                if (v2 instanceof Left) return new Left(v2.value0);
                if (v2 instanceof Right) return map3(v2.value0)(v1);
                throw new Error("Failed pattern match at Data.Either (line 70, column 1 - line 72, column 30): " + [
                    v2.constructor.name,
                    v1.constructor.name
                ]);
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
    var applicativeEither = /* @__PURE__ */ function() {
        return {
            pure: Right.create,
            Apply0: function() {
                return applyEither;
            }
        };
    }();
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
    // output/Control.Monad/index.js
    var unlessM = function(dictMonad) {
        var bind19 = bind(dictMonad.Bind1());
        var unless2 = unless(dictMonad.Applicative0());
        return function(mb) {
            return function(m2) {
                return bind19(mb)(function(b2) {
                    return unless2(b2)(m2);
                });
            };
        };
    };
    var ap = function(dictMonad) {
        var bind19 = bind(dictMonad.Bind1());
        var pure24 = pure(dictMonad.Applicative0());
        return function(f) {
            return function(a3) {
                return bind19(f)(function(f$prime) {
                    return bind19(a3)(function(a$prime) {
                        return pure24(f$prime(a$prime));
                    });
                });
            };
        };
    };
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
    var div = function(dict) {
        return dict.div;
    };
    // output/Data.Monoid/index.js
    var mempty = function(dict) {
        return dict.mempty;
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
        var map34 = map(Monad0.Bind1().Apply0().Functor0());
        var pure24 = pure(Monad0.Applicative0());
        return function(a3) {
            return catchError1(map34(Right.create)(a3))(function($52) {
                return pure24(Left.create($52));
            });
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
    // output/Effect.Ref/foreign.js
    var _new = function(val) {
        return function() {
            return {
                value: val
            };
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
    var Loop = /* @__PURE__ */ function() {
        function Loop2(value0) {
            this.value0 = value0;
        }
        Loop2.create = function(value0) {
            return new Loop2(value0);
        };
        return Loop2;
    }();
    var Done = /* @__PURE__ */ function() {
        function Done2(value0) {
            this.value0 = value0;
        }
        Done2.create = function(value0) {
            return new Done2(value0);
        };
        return Done2;
    }();
    var tailRecM = function(dict) {
        return dict.tailRecM;
    };
    var monadRecEffect = {
        tailRecM: function(f) {
            return function(a3) {
                var fromDone = function(v2) {
                    if (v2 instanceof Done) return v2.value0;
                    throw new Error("Failed pattern match at Control.Monad.Rec.Class (line 137, column 30 - line 137, column 44): " + [
                        v2.constructor.name
                    ]);
                };
                return function __do3() {
                    var r = bindFlipped2($$new)(f(a3))();
                    (function() {
                        while(!function __do4() {
                            var v2 = read(r)();
                            if (v2 instanceof Loop) {
                                var e = f(v2.value0)();
                                write(e)(r)();
                                return false;
                            }
                            if (v2 instanceof Done) return true;
                            throw new Error("Failed pattern match at Control.Monad.Rec.Class (line 128, column 22 - line 133, column 28): " + [
                                v2.constructor.name
                            ]);
                        }());
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
    // output/Data.Tuple/index.js
    var Tuple = /* @__PURE__ */ function() {
        function Tuple2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Tuple2.create = function(value0) {
            return function(value1) {
                return new Tuple2(value0, value1);
            };
        };
        return Tuple2;
    }();
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
        var eq7 = eq(dictEq);
        return function(dictEq1) {
            var eq13 = eq(dictEq1);
            return {
                eq: function(x) {
                    return function(y) {
                        return eq7(x.value0)(y.value0) && eq13(x.value1)(y.value1);
                    };
                }
            };
        };
    };
    var ordTuple = function(dictOrd) {
        var compare3 = compare(dictOrd);
        var eqTuple1 = eqTuple(dictOrd.Eq0());
        return function(dictOrd1) {
            var compare13 = compare(dictOrd1);
            var eqTuple2 = eqTuple1(dictOrd1.Eq0());
            return {
                compare: function(x) {
                    return function(y) {
                        var v2 = compare3(x.value0)(y.value0);
                        if (v2 instanceof LT) return LT.value;
                        if (v2 instanceof GT) return GT.value;
                        return compare13(x.value1)(y.value1);
                    };
                },
                Eq0: function() {
                    return eqTuple2;
                }
            };
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
    var map5 = /* @__PURE__ */ map(functorEither);
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
        var map111 = map(dictFunctor);
        return {
            map: function(f) {
                return mapExceptT(map111(map5(f)));
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
        var bind19 = bind(dictMonad.Bind1());
        var pure24 = pure(dictMonad.Applicative0());
        return {
            bind: function(v2) {
                return function(k) {
                    return bind19(v2)(either(function($187) {
                        return pure24(Left.create($187));
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
            pure: function() {
                var $188 = pure(dictMonad.Applicative0());
                return function($189) {
                    return ExceptT($188(Right.create($189)));
                };
            }(),
            Apply0: function() {
                return applyExceptT(dictMonad);
            }
        };
    };
    var monadThrowExceptT = function(dictMonad) {
        var monadExceptT1 = monadExceptT(dictMonad);
        return {
            throwError: function() {
                var $198 = pure(dictMonad.Applicative0());
                return function($199) {
                    return ExceptT($198(Left.create($199)));
                };
            }(),
            Monad0: function() {
                return monadExceptT1;
            }
        };
    };
    var altExceptT = function(dictSemigroup) {
        var append6 = append(dictSemigroup);
        return function(dictMonad) {
            var Bind1 = dictMonad.Bind1();
            var bind19 = bind(Bind1);
            var pure24 = pure(dictMonad.Applicative0());
            var functorExceptT1 = functorExceptT(Bind1.Apply0().Functor0());
            return {
                alt: function(v2) {
                    return function(v1) {
                        return bind19(v2)(function(rm) {
                            if (rm instanceof Right) return pure24(new Right(rm.value0));
                            if (rm instanceof Left) return bind19(v1)(function(rn) {
                                if (rn instanceof Right) return pure24(new Right(rn.value0));
                                if (rn instanceof Left) return pure24(new Left(append6(rm.value0)(rn.value0)));
                                throw new Error("Failed pattern match at Control.Monad.Except.Trans (line 86, column 9 - line 88, column 49): " + [
                                    rn.constructor.name
                                ]);
                            });
                            throw new Error("Failed pattern match at Control.Monad.Except.Trans (line 82, column 5 - line 88, column 49): " + [
                                rm.constructor.name
                            ]);
                        });
                    };
                },
                Functor0: function() {
                    return functorExceptT1;
                }
            };
        };
    };
    // output/Control.Monad.Except/index.js
    var unwrap3 = /* @__PURE__ */ unwrap();
    var runExcept = function($3) {
        return unwrap3(runExceptT($3));
    };
    // output/Data.Argonaut.Core/foreign.js
    function id(x) {
        return x;
    }
    var jsonNull = null;
    function stringify(j) {
        return JSON.stringify(j);
    }
    function _caseJson(isNull3, isBool, isNum, isStr, isArr, isObj, j) {
        if (j == null) return isNull3();
        else if (typeof j === "boolean") return isBool(j);
        else if (typeof j === "number") return isNum(j);
        else if (typeof j === "string") return isStr(j);
        else if (Object.prototype.toString.call(j) === "[object Array]") return isArr(j);
        else return isObj(j);
    }
    // output/Foreign.Object/foreign.js
    function _copyST(m2) {
        return function() {
            var r = {};
            for(var k in m2)if (hasOwnProperty.call(m2, k)) r[k] = m2[k];
            return r;
        };
    }
    var empty = {};
    function runST(f) {
        return f();
    }
    function _fmapObject(m0, f) {
        var m2 = {};
        for(var k in m0)if (hasOwnProperty.call(m0, k)) m2[k] = f(m0[k]);
        return m2;
    }
    function _mapWithKey(m0, f) {
        var m2 = {};
        for(var k in m0)if (hasOwnProperty.call(m0, k)) m2[k] = f(k)(m0[k]);
        return m2;
    }
    function _foldM(bind19) {
        return function(f) {
            return function(mz) {
                return function(m2) {
                    var acc = mz;
                    function g(k2) {
                        return function(z2) {
                            return f(z2)(k2)(m2[k2]);
                        };
                    }
                    for(var k in m2)if (hasOwnProperty.call(m2, k)) acc = bind19(acc)(g(k));
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
            for(var k in m2)if (hasOwnProperty.call(m2, k)) r.push(f(k)(m2[k]));
            return r;
        };
    }
    var keys = Object.keys || toArrayWithKey(function(k) {
        return function() {
            return k;
        };
    });
    // output/Control.Monad.ST.Internal/foreign.js
    var map_ = function(f) {
        return function(a3) {
            return function() {
                return f(a3());
            };
        };
    };
    var pure_ = function(a3) {
        return function() {
            return a3;
        };
    };
    var bind_ = function(a3) {
        return function(f) {
            return function() {
                return f(a3())();
            };
        };
    };
    // output/Control.Monad.ST.Internal/index.js
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
    var functorST = {
        map: map_
    };
    var monadST = {
        Applicative0: function() {
            return applicativeST;
        },
        Bind1: function() {
            return bindST;
        }
    };
    var bindST = {
        bind: bind_,
        Apply0: function() {
            return $lazy_applyST(0);
        }
    };
    var applicativeST = {
        pure: pure_,
        Apply0: function() {
            return $lazy_applyST(0);
        }
    };
    var $lazy_applyST = /* @__PURE__ */ $runtime_lazy2("applyST", "Control.Monad.ST.Internal", function() {
        return {
            apply: ap(monadST),
            Functor0: function() {
                return functorST;
            }
        };
    });
    // output/Data.Array/foreign.js
    var replicateFill = function(count, value16) {
        if (count < 1) return [];
        var result = new Array(count);
        return result.fill(value16);
    };
    var replicatePolyfill = function(count, value16) {
        var result = [];
        var n = 0;
        for(var i2 = 0; i2 < count; i2++)result[n++] = value16;
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
        for(var i2 = 0, l2 = xs.length; i2 < l2; i2++){
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
    var sortByImpl = /* @__PURE__ */ function() {
        function mergeFromTo(compare3, fromOrdering, xs1, xs2, from2, to) {
            var mid;
            var i2;
            var j;
            var k;
            var x;
            var y;
            var c2;
            mid = from2 + (to - from2 >> 1);
            if (mid - from2 > 1) mergeFromTo(compare3, fromOrdering, xs2, xs1, from2, mid);
            if (to - mid > 1) mergeFromTo(compare3, fromOrdering, xs2, xs1, mid, to);
            i2 = from2;
            j = mid;
            k = from2;
            while(i2 < mid && j < to){
                x = xs2[i2];
                y = xs2[j];
                c2 = fromOrdering(compare3(x)(y));
                if (c2 > 0) {
                    xs1[k++] = y;
                    ++j;
                } else {
                    xs1[k++] = x;
                    ++i2;
                }
            }
            while(i2 < mid)xs1[k++] = xs2[i2++];
            while(j < to)xs1[k++] = xs2[j++];
        }
        return function(compare3, fromOrdering, xs) {
            var out;
            if (xs.length < 2) return xs;
            out = xs.slice(0);
            mergeFromTo(compare3, fromOrdering, out, xs.slice(0), 0, xs.length);
            return out;
        };
    }();
    var sliceImpl = function(s2, e, l2) {
        return l2.slice(s2, e);
    };
    var unsafeIndexImpl = function(xs, n) {
        return xs[n];
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
                for(var i2 = len - 1; i2 >= 0; i2--)acc = f(xs[i2])(acc);
                return acc;
            };
        };
    };
    var foldlArray = function(f) {
        return function(init3) {
            return function(xs) {
                var acc = init3;
                var len = xs.length;
                for(var i2 = 0; i2 < len; i2++)acc = f(acc)(xs[i2]);
                return acc;
            };
        };
    };
    // output/Control.Plus/index.js
    var empty2 = function(dict) {
        return dict.empty;
    };
    // output/Data.Bifunctor/index.js
    var identity5 = /* @__PURE__ */ identity(categoryFn);
    var bimap = function(dict) {
        return dict.bimap;
    };
    var lmap = function(dictBifunctor) {
        var bimap1 = bimap(dictBifunctor);
        return function(f) {
            return bimap1(f)(identity5);
        };
    };
    var bifunctorEither = {
        bimap: function(v2) {
            return function(v1) {
                return function(v22) {
                    if (v22 instanceof Left) return new Left(v2(v22.value0));
                    if (v22 instanceof Right) return new Right(v1(v22.value0));
                    throw new Error("Failed pattern match at Data.Bifunctor (line 32, column 1 - line 34, column 36): " + [
                        v2.constructor.name,
                        v1.constructor.name,
                        v22.constructor.name
                    ]);
                };
            };
        }
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
        var pure24 = pure(dictApplicative);
        return function(dictFoldable) {
            var foldr22 = foldr(dictFoldable);
            return function(f) {
                return foldr22(function($454) {
                    return applySecond2(f($454));
                })(pure24(unit));
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
                    if (v22 instanceof Nothing) return v1;
                    if (v22 instanceof Just) return v2(v22.value0)(v1);
                    throw new Error("Failed pattern match at Data.Foldable (line 138, column 1 - line 144, column 27): " + [
                        v2.constructor.name,
                        v1.constructor.name,
                        v22.constructor.name
                    ]);
                };
            };
        },
        foldl: function(v2) {
            return function(v1) {
                return function(v22) {
                    if (v22 instanceof Nothing) return v1;
                    if (v22 instanceof Just) return v2(v1)(v22.value0);
                    throw new Error("Failed pattern match at Data.Foldable (line 138, column 1 - line 144, column 27): " + [
                        v2.constructor.name,
                        v1.constructor.name,
                        v22.constructor.name
                    ]);
                };
            };
        },
        foldMap: function(dictMonoid) {
            var mempty3 = mempty(dictMonoid);
            return function(v2) {
                return function(v1) {
                    if (v1 instanceof Nothing) return mempty3;
                    if (v1 instanceof Just) return v2(v1.value0);
                    throw new Error("Failed pattern match at Data.Foldable (line 138, column 1 - line 144, column 27): " + [
                        v2.constructor.name,
                        v1.constructor.name
                    ]);
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
            for(var i2 = 0; i2 < l2; i2++)result[i2] = f(i2)(xs[i2]);
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
    var traverseArrayImpl = /* @__PURE__ */ function() {
        function array1(a3) {
            return [
                a3
            ];
        }
        function array2(a3) {
            return function(b2) {
                return [
                    a3,
                    b2
                ];
            };
        }
        function array3(a3) {
            return function(b2) {
                return function(c2) {
                    return [
                        a3,
                        b2,
                        c2
                    ];
                };
            };
        }
        function concat2(xs) {
            return function(ys) {
                return xs.concat(ys);
            };
        }
        return function(apply3) {
            return function(map34) {
                return function(pure24) {
                    return function(f) {
                        return function(array) {
                            function go2(bot, top3) {
                                switch(top3 - bot){
                                    case 0:
                                        return pure24([]);
                                    case 1:
                                        return map34(array1)(f(array[bot]));
                                    case 2:
                                        return apply3(map34(array2)(f(array[bot])))(f(array[bot + 1]));
                                    case 3:
                                        return apply3(apply3(map34(array3)(f(array[bot])))(f(array[bot + 1])))(f(array[bot + 2]));
                                    default:
                                        var pivot = bot + Math.floor((top3 - bot) / 4) * 2;
                                        return apply3(map34(concat2)(go2(bot, pivot)))(go2(pivot, top3));
                                }
                            }
                            return go2(0, array.length);
                        };
                    };
                };
            };
        };
    }();
    // output/Data.Traversable/index.js
    var identity6 = /* @__PURE__ */ identity(categoryFn);
    var traverse = function(dict) {
        return dict.traverse;
    };
    var sequenceDefault = function(dictTraversable) {
        var traverse22 = traverse(dictTraversable);
        return function(dictApplicative) {
            return traverse22(dictApplicative)(identity6);
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
                            while(true){
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
                            while(true){
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
    var map6 = /* @__PURE__ */ map(functorMaybe);
    var fromJust4 = /* @__PURE__ */ fromJust();
    var unsafeIndex = function() {
        return runFn2(unsafeIndexImpl);
    };
    var unsafeIndex1 = /* @__PURE__ */ unsafeIndex();
    var sortBy = function(comp) {
        return runFn3(sortByImpl)(comp)(function(v2) {
            if (v2 instanceof GT) return 1;
            if (v2 instanceof EQ) return 0;
            if (v2 instanceof LT) return -1;
            throw new Error("Failed pattern match at Data.Array (line 897, column 38 - line 900, column 11): " + [
                v2.constructor.name
            ]);
        });
    };
    var snoc = function(xs) {
        return function(x) {
            return withArray(push(x))(xs)();
        };
    };
    var slice = /* @__PURE__ */ runFn3(sliceImpl);
    var singleton2 = function(a3) {
        return [
            a3
        ];
    };
    var index = /* @__PURE__ */ function() {
        return runFn4(indexImpl)(Just.create)(Nothing.value);
    }();
    var last = function(xs) {
        return index(xs)(length(xs) - 1 | 0);
    };
    var foldl2 = /* @__PURE__ */ foldl(foldableArray);
    var findIndex = /* @__PURE__ */ function() {
        return runFn4(findIndexImpl)(Just.create)(Nothing.value);
    }();
    var find2 = function(f) {
        return function(xs) {
            return map6(unsafeIndex1(xs))(findIndex(f)(xs));
        };
    };
    var filter = /* @__PURE__ */ runFn2(filterImpl);
    var deleteAt = /* @__PURE__ */ function() {
        return runFn4(_deleteAt)(Just.create)(Nothing.value);
    }();
    var deleteBy = function(v2) {
        return function(v1) {
            return function(v22) {
                if (v22.length === 0) return [];
                return maybe(v22)(function(i2) {
                    return fromJust4(deleteAt(i2)(v22));
                })(findIndex(v2(v1))(v22));
            };
        };
    };
    var concatMap = /* @__PURE__ */ flip(/* @__PURE__ */ bind(bindArray));
    var mapMaybe = function(f) {
        return concatMap(function() {
            var $189 = maybe([])(singleton2);
            return function($190) {
                return $189(f($190));
            };
        }());
    };
    var catMaybes = /* @__PURE__ */ mapMaybe(/* @__PURE__ */ identity(categoryFn));
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
    // output/Foreign.Object/index.js
    var bindFlipped3 = /* @__PURE__ */ bindFlipped(bindST);
    var foldr2 = /* @__PURE__ */ foldr(foldableArray);
    var identity7 = /* @__PURE__ */ identity(categoryFn);
    var values = /* @__PURE__ */ toArrayWithKey(function(v2) {
        return function(v1) {
            return v1;
        };
    });
    var thawST = _copyST;
    var singleton3 = function(k) {
        return function(v2) {
            return runST(bindFlipped3(poke2(k)(v2))(newImpl));
        };
    };
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
    var lookup = /* @__PURE__ */ function() {
        return runFn4(_lookup)(Nothing.value)(Just.create);
    }();
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
        var append13 = append(dictMonoid.Semigroup0());
        var mempty3 = mempty(dictMonoid);
        return function(f) {
            return fold2(function(acc) {
                return function(k) {
                    return function(v2) {
                        return append13(acc)(f(k)(v2));
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
                    return foldr2(f)(z2)(values(m2));
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
                    return foldr2(uncurry(f))(z2)(toArrayWithKey(Tuple.create)(m2));
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
            var map34 = map(Apply0.Functor0());
            var pure111 = pure(dictApplicative);
            return function(f) {
                return function(ms) {
                    return fold2(function(acc) {
                        return function(k) {
                            return function(v2) {
                                return apply3(map34(flip(insert(k)))(acc))(f(k)(v2));
                            };
                        };
                    })(pure111(empty))(ms);
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
            return traverse(traversableObject)(dictApplicative)(identity7);
        },
        Functor0: function() {
            return functorObject;
        },
        Foldable1: function() {
            return foldableObject;
        }
    };
    // output/Data.Argonaut.Core/index.js
    var verbJsonType = function(def) {
        return function(f) {
            return function(g) {
                return g(def)(f);
            };
        };
    };
    var toJsonType = /* @__PURE__ */ function() {
        return verbJsonType(Nothing.value)(Just.create);
    }();
    var jsonSingletonObject = function(key2) {
        return function(val) {
            return id(singleton3(key2)(val));
        };
    };
    var jsonEmptyObject = /* @__PURE__ */ id(empty);
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
    var isNull = /* @__PURE__ */ isJsonType(caseJsonNull);
    var caseJsonBoolean = function(d) {
        return function(f) {
            return function(j) {
                return _caseJson($$const(d), f, $$const(d), $$const(d), $$const(d), $$const(d), j);
            };
        };
    };
    var caseJsonArray = function(d) {
        return function(f) {
            return function(j) {
                return _caseJson($$const(d), $$const(d), $$const(d), $$const(d), f, $$const(d), j);
            };
        };
    };
    var toArray = /* @__PURE__ */ toJsonType(caseJsonArray);
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
    // output/Data.String.Common/foreign.js
    var replace = function(s1) {
        return function(s2) {
            return function(s3) {
                return s3.replace(s1, s2);
            };
        };
    };
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
    var encodeFormURLComponent = /* @__PURE__ */ function() {
        return runFn3(_encodeFormURLComponent)($$const(Nothing.value))(Just.create);
    }();
    // output/Data.FormURLEncoded/index.js
    var apply2 = /* @__PURE__ */ apply(applyMaybe);
    var map7 = /* @__PURE__ */ map(functorMaybe);
    var traverse2 = /* @__PURE__ */ traverse(traversableArray)(applicativeMaybe);
    var toArray2 = function(v2) {
        return v2;
    };
    var encode = /* @__PURE__ */ function() {
        var encodePart = function(v2) {
            if (v2.value1 instanceof Nothing) return encodeFormURLComponent(v2.value0);
            if (v2.value1 instanceof Just) return apply2(map7(function(key2) {
                return function(val) {
                    return key2 + ("=" + val);
                };
            })(encodeFormURLComponent(v2.value0)))(encodeFormURLComponent(v2.value1.value0));
            throw new Error("Failed pattern match at Data.FormURLEncoded (line 37, column 16 - line 39, column 114): " + [
                v2.constructor.name
            ]);
        };
        var $37 = map7(joinWith("&"));
        var $38 = traverse2(encodePart);
        return function($39) {
            return $37($38(toArray2($39)));
        };
    }();
    // output/Data.HTTP.Method/index.js
    var OPTIONS = /* @__PURE__ */ function() {
        function OPTIONS2() {}
        OPTIONS2.value = new OPTIONS2();
        return OPTIONS2;
    }();
    var GET = /* @__PURE__ */ function() {
        function GET3() {}
        GET3.value = new GET3();
        return GET3;
    }();
    var HEAD = /* @__PURE__ */ function() {
        function HEAD2() {}
        HEAD2.value = new HEAD2();
        return HEAD2;
    }();
    var POST = /* @__PURE__ */ function() {
        function POST3() {}
        POST3.value = new POST3();
        return POST3;
    }();
    var PUT = /* @__PURE__ */ function() {
        function PUT2() {}
        PUT2.value = new PUT2();
        return PUT2;
    }();
    var DELETE = /* @__PURE__ */ function() {
        function DELETE2() {}
        DELETE2.value = new DELETE2();
        return DELETE2;
    }();
    var TRACE = /* @__PURE__ */ function() {
        function TRACE2() {}
        TRACE2.value = new TRACE2();
        return TRACE2;
    }();
    var CONNECT = /* @__PURE__ */ function() {
        function CONNECT2() {}
        CONNECT2.value = new CONNECT2();
        return CONNECT2;
    }();
    var PROPFIND = /* @__PURE__ */ function() {
        function PROPFIND2() {}
        PROPFIND2.value = new PROPFIND2();
        return PROPFIND2;
    }();
    var PROPPATCH = /* @__PURE__ */ function() {
        function PROPPATCH2() {}
        PROPPATCH2.value = new PROPPATCH2();
        return PROPPATCH2;
    }();
    var MKCOL = /* @__PURE__ */ function() {
        function MKCOL2() {}
        MKCOL2.value = new MKCOL2();
        return MKCOL2;
    }();
    var COPY = /* @__PURE__ */ function() {
        function COPY2() {}
        COPY2.value = new COPY2();
        return COPY2;
    }();
    var MOVE = /* @__PURE__ */ function() {
        function MOVE2() {}
        MOVE2.value = new MOVE2();
        return MOVE2;
    }();
    var LOCK = /* @__PURE__ */ function() {
        function LOCK2() {}
        LOCK2.value = new LOCK2();
        return LOCK2;
    }();
    var UNLOCK = /* @__PURE__ */ function() {
        function UNLOCK2() {}
        UNLOCK2.value = new UNLOCK2();
        return UNLOCK2;
    }();
    var PATCH = /* @__PURE__ */ function() {
        function PATCH2() {}
        PATCH2.value = new PATCH2();
        return PATCH2;
    }();
    var unCustomMethod = function(v2) {
        return v2;
    };
    var showMethod = {
        show: function(v2) {
            if (v2 instanceof OPTIONS) return "OPTIONS";
            if (v2 instanceof GET) return "GET";
            if (v2 instanceof HEAD) return "HEAD";
            if (v2 instanceof POST) return "POST";
            if (v2 instanceof PUT) return "PUT";
            if (v2 instanceof DELETE) return "DELETE";
            if (v2 instanceof TRACE) return "TRACE";
            if (v2 instanceof CONNECT) return "CONNECT";
            if (v2 instanceof PROPFIND) return "PROPFIND";
            if (v2 instanceof PROPPATCH) return "PROPPATCH";
            if (v2 instanceof MKCOL) return "MKCOL";
            if (v2 instanceof COPY) return "COPY";
            if (v2 instanceof MOVE) return "MOVE";
            if (v2 instanceof LOCK) return "LOCK";
            if (v2 instanceof UNLOCK) return "UNLOCK";
            if (v2 instanceof PATCH) return "PATCH";
            throw new Error("Failed pattern match at Data.HTTP.Method (line 43, column 1 - line 59, column 23): " + [
                v2.constructor.name
            ]);
        }
    };
    var print = /* @__PURE__ */ either(/* @__PURE__ */ show(showMethod))(unCustomMethod);
    // output/Data.NonEmpty/index.js
    var NonEmpty = /* @__PURE__ */ function() {
        function NonEmpty2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        NonEmpty2.create = function(value0) {
            return function(value1) {
                return new NonEmpty2(value0, value1);
            };
        };
        return NonEmpty2;
    }();
    var singleton4 = function(dictPlus) {
        var empty7 = empty2(dictPlus);
        return function(a3) {
            return new NonEmpty(a3, empty7);
        };
    };
    // output/Data.List.Types/index.js
    var Nil = /* @__PURE__ */ function() {
        function Nil2() {}
        Nil2.value = new Nil2();
        return Nil2;
    }();
    var Cons = /* @__PURE__ */ function() {
        function Cons2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Cons2.create = function(value0) {
            return function(value1) {
                return new Cons2(value0, value1);
            };
        };
        return Cons2;
    }();
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
                    if (v1 instanceof Cons && v1.value1 instanceof Cons && v1.value1.value1 instanceof Cons) {
                        $tco_var_v = new Cons(v1, v2);
                        $copy_v1 = v1.value1.value1.value1;
                        return;
                    }
                    var unrolledMap = function(v22) {
                        if (v22 instanceof Cons && v22.value1 instanceof Cons && v22.value1.value1 instanceof Nil) return new Cons(f(v22.value0), new Cons(f(v22.value1.value0), Nil.value));
                        if (v22 instanceof Cons && v22.value1 instanceof Nil) return new Cons(f(v22.value0), Nil.value);
                        return Nil.value;
                    };
                    var reverseUnrolledMap = function($copy_v2) {
                        return function($copy_v3) {
                            var $tco_var_v2 = $copy_v2;
                            var $tco_done1 = false;
                            var $tco_result2;
                            function $tco_loop2(v22, v3) {
                                if (v22 instanceof Cons && v22.value0 instanceof Cons && v22.value0.value1 instanceof Cons && v22.value0.value1.value1 instanceof Cons) {
                                    $tco_var_v2 = v22.value1;
                                    $copy_v3 = new Cons(f(v22.value0.value0), new Cons(f(v22.value0.value1.value0), new Cons(f(v22.value0.value1.value1.value0), v3)));
                                    return;
                                }
                                $tco_done1 = true;
                                return v3;
                            }
                            while(!$tco_done1)$tco_result2 = $tco_loop2($tco_var_v2, $copy_v3);
                            return $tco_result2;
                        };
                    };
                    $tco_done = true;
                    return reverseUnrolledMap(v2)(unrolledMap(v1));
                }
                while(!$tco_done)$tco_result = $tco_loop($tco_var_v, $copy_v1);
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
                var rev3 = function() {
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
                                if (v1 instanceof Cons) {
                                    $tco_var_v = new Cons(v1.value0, v2);
                                    $copy_v1 = v1.value1;
                                    return;
                                }
                                throw new Error("Failed pattern match at Data.List.Types (line 107, column 7 - line 107, column 23): " + [
                                    v2.constructor.name,
                                    v1.constructor.name
                                ]);
                            }
                            while(!$tco_done)$tco_result = $tco_loop($tco_var_v, $copy_v1);
                            return $tco_result;
                        };
                    };
                    return go2(Nil.value);
                }();
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
                        if (v2 instanceof Cons) {
                            $tco_var_b = f(b2)(v2.value0);
                            $copy_v = v2.value1;
                            return;
                        }
                        throw new Error("Failed pattern match at Data.List.Types (line 111, column 12 - line 113, column 30): " + [
                            v2.constructor.name
                        ]);
                    }
                    while(!$tco_done1)$tco_result = $tco_loop($tco_var_b, $copy_v);
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
    var foldr3 = /* @__PURE__ */ foldr(foldableList);
    var semigroupList = {
        append: function(xs) {
            return function(ys) {
                return foldr3(Cons.create)(ys)(xs);
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
    var plusList = /* @__PURE__ */ function() {
        return {
            empty: Nil.value,
            Alt0: function() {
                return altList;
            }
        };
    }();
    // output/Data.List/index.js
    var reverse2 = /* @__PURE__ */ function() {
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
                    if (v1 instanceof Cons) {
                        $tco_var_v = new Cons(v1.value0, v2);
                        $copy_v1 = v1.value1;
                        return;
                    }
                    throw new Error("Failed pattern match at Data.List (line 368, column 3 - line 368, column 19): " + [
                        v2.constructor.name,
                        v1.constructor.name
                    ]);
                }
                while(!$tco_done)$tco_result = $tco_loop($tco_var_v, $copy_v1);
                return $tco_result;
            };
        };
        return go2(Nil.value);
    }();
    var $$null = function(v2) {
        if (v2 instanceof Nil) return true;
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
    var singleton5 = /* @__PURE__ */ function() {
        var $200 = singleton4(plusList);
        return function($201) {
            return NonEmptyList($200($201));
        };
    }();
    var head = function(v2) {
        return v2.value0;
    };
    var cons = function(y) {
        return function(v2) {
            return new NonEmpty(y, new Cons(v2.value0, v2.value1));
        };
    };
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
    // output/Effect.Aff/foreign.js
    var Aff = function() {
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
        function Aff2(tag, _1, _2, _3) {
            this.tag = tag;
            this._1 = _1;
            this._2 = _2;
            this._3 = _3;
        }
        function AffCtr(tag) {
            var fn = function(_1, _2, _3) {
                return new Aff2(tag, _1, _2, _3);
            };
            fn.tag = tag;
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
        var Scheduler = function() {
            var limit = 1024;
            var size5 = 0;
            var ix = 0;
            var queue = new Array(limit);
            var draining = false;
            function drain() {
                var thunk;
                draining = true;
                while(size5 !== 0){
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
                    if (!draining) drain();
                }
            };
        }();
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
                        if (count === 0) return cb();
                        var killCount = 0;
                        var kills = {};
                        function kill2(fid) {
                            kills[fid] = fibers[fid].kill(killError, function(result) {
                                return function() {
                                    delete kills[fid];
                                    killCount--;
                                    if (util.isLeft(result) && util.fromLeft(result)) setTimeout(function() {
                                        throw util.fromLeft(result);
                                    }, 0);
                                    if (killCount === 0) cb();
                                };
                            })();
                        }
                        for(var k in fibers)if (fibers.hasOwnProperty(k)) {
                            killCount++;
                            kill2(k);
                        }
                        fibers = {};
                        fiberId = 0;
                        count = 0;
                        return function(error4) {
                            return new Aff2(SYNC, function() {
                                for(var k2 in kills)if (kills.hasOwnProperty(k2)) kills[k2]();
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
            var status2 = SUSPENDED;
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
                while(true){
                    tmp = null;
                    result = null;
                    attempt = null;
                    switch(status2){
                        case STEP_BIND:
                            status2 = CONTINUE;
                            try {
                                step3 = bhead(step3);
                                if (btail === null) bhead = null;
                                else {
                                    bhead = btail._1;
                                    btail = btail._2;
                                }
                            } catch (e) {
                                status2 = RETURN;
                                fail3 = util.left(e);
                                step3 = null;
                            }
                            break;
                        case STEP_RESULT:
                            if (util.isLeft(step3)) {
                                status2 = RETURN;
                                fail3 = step3;
                                step3 = null;
                            } else if (bhead === null) status2 = RETURN;
                            else {
                                status2 = STEP_BIND;
                                step3 = util.fromRight(step3);
                            }
                            break;
                        case CONTINUE:
                            switch(step3.tag){
                                case BIND:
                                    if (bhead) btail = new Aff2(CONS, bhead, btail);
                                    bhead = step3._2;
                                    status2 = CONTINUE;
                                    step3 = step3._1;
                                    break;
                                case PURE:
                                    if (bhead === null) {
                                        status2 = RETURN;
                                        step3 = util.right(step3._1);
                                    } else {
                                        status2 = STEP_BIND;
                                        step3 = step3._1;
                                    }
                                    break;
                                case SYNC:
                                    status2 = STEP_RESULT;
                                    step3 = runSync(util.left, util.right, step3._1);
                                    break;
                                case ASYNC:
                                    status2 = PENDING;
                                    step3 = runAsync(util.left, step3._1, function(result2) {
                                        return function() {
                                            if (runTick !== localRunTick) return;
                                            runTick++;
                                            Scheduler.enqueue(function() {
                                                if (runTick !== localRunTick + 1) return;
                                                status2 = STEP_RESULT;
                                                step3 = result2;
                                                run3(runTick);
                                            });
                                        };
                                    });
                                    return;
                                case THROW:
                                    status2 = RETURN;
                                    fail3 = util.left(step3._1);
                                    step3 = null;
                                    break;
                                // Enqueue the Catch so that we can call the error handler later on
                                // in case of an exception.
                                case CATCH:
                                    if (bhead === null) attempts = new Aff2(CONS, step3, attempts, interrupt);
                                    else attempts = new Aff2(CONS, step3, new Aff2(CONS, new Aff2(RESUME, bhead, btail), attempts, interrupt), interrupt);
                                    bhead = null;
                                    btail = null;
                                    status2 = CONTINUE;
                                    step3 = step3._1;
                                    break;
                                // Enqueue the Bracket so that we can call the appropriate handlers
                                // after resource acquisition.
                                case BRACKET:
                                    bracketCount++;
                                    if (bhead === null) attempts = new Aff2(CONS, step3, attempts, interrupt);
                                    else attempts = new Aff2(CONS, step3, new Aff2(CONS, new Aff2(RESUME, bhead, btail), attempts, interrupt), interrupt);
                                    bhead = null;
                                    btail = null;
                                    status2 = CONTINUE;
                                    step3 = step3._1;
                                    break;
                                case FORK:
                                    status2 = STEP_RESULT;
                                    tmp = Fiber(util, supervisor, step3._2);
                                    if (supervisor) supervisor.register(tmp);
                                    if (step3._1) tmp.run();
                                    step3 = util.right(tmp);
                                    break;
                                case SEQ:
                                    status2 = CONTINUE;
                                    step3 = sequential3(util, supervisor, step3._1);
                                    break;
                            }
                            break;
                        case RETURN:
                            bhead = null;
                            btail = null;
                            if (attempts === null) {
                                status2 = COMPLETED;
                                step3 = interrupt || fail3 || step3;
                            } else {
                                tmp = attempts._3;
                                attempt = attempts._1;
                                attempts = attempts._2;
                                switch(attempt.tag){
                                    // We cannot recover from an unmasked interrupt. Otherwise we should
                                    // continue stepping, or run the exception handler if an exception
                                    // was raised.
                                    case CATCH:
                                        if (interrupt && interrupt !== tmp && bracketCount === 0) status2 = RETURN;
                                        else if (fail3) {
                                            status2 = CONTINUE;
                                            step3 = attempt._2(util.fromLeft(fail3));
                                            fail3 = null;
                                        }
                                        break;
                                    // We cannot resume from an unmasked interrupt or exception.
                                    case RESUME:
                                        if (interrupt && interrupt !== tmp && bracketCount === 0 || fail3) status2 = RETURN;
                                        else {
                                            bhead = attempt._1;
                                            btail = attempt._2;
                                            status2 = STEP_BIND;
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
                                                status2 = CONTINUE;
                                                step3 = attempt._3(result);
                                            }
                                        }
                                        break;
                                    // Enqueue the appropriate handler. We increase the bracket count
                                    // because it should not be cancelled.
                                    case RELEASE:
                                        attempts = new Aff2(CONS, new Aff2(FINALIZED, step3, fail3), attempts, interrupt);
                                        status2 = CONTINUE;
                                        if (interrupt && interrupt !== tmp && bracketCount === 0) step3 = attempt._1.killed(util.fromLeft(interrupt))(attempt._2);
                                        else if (fail3) step3 = attempt._1.failed(util.fromLeft(fail3))(attempt._2);
                                        else step3 = attempt._1.completed(util.fromRight(step3))(attempt._2);
                                        fail3 = null;
                                        bracketCount++;
                                        break;
                                    case FINALIZER:
                                        bracketCount++;
                                        attempts = new Aff2(CONS, new Aff2(FINALIZED, step3, fail3), attempts, interrupt);
                                        status2 = CONTINUE;
                                        step3 = attempt._1;
                                        break;
                                    case FINALIZED:
                                        bracketCount--;
                                        status2 = RETURN;
                                        step3 = attempt._1;
                                        fail3 = attempt._2;
                                        break;
                                }
                            }
                            break;
                        case COMPLETED:
                            for(var k in joins)if (joins.hasOwnProperty(k)) {
                                rethrow = rethrow && joins[k].rethrow;
                                runEff(joins[k].handler(step3));
                            }
                            joins = null;
                            if (interrupt && fail3) setTimeout(function() {
                                throw util.fromLeft(fail3);
                            }, 0);
                            else if (util.isLeft(step3) && rethrow) setTimeout(function() {
                                if (rethrow) throw util.fromLeft(step3);
                            }, 0);
                            return;
                        case SUSPENDED:
                            status2 = CONTINUE;
                            break;
                        case PENDING:
                            return;
                    }
                }
            }
            function onComplete(join4) {
                return function() {
                    if (status2 === COMPLETED) {
                        rethrow = rethrow && join4.rethrow;
                        join4.handler(step3)();
                        return function() {};
                    }
                    var jid = joinId++;
                    joins = joins || {};
                    joins[jid] = join4;
                    return function() {
                        if (joins !== null) delete joins[jid];
                    };
                };
            }
            function kill2(error4, cb) {
                return function() {
                    if (status2 === COMPLETED) {
                        cb(util.right(void 0))();
                        return function() {};
                    }
                    var canceler = onComplete({
                        rethrow: false,
                        handler: function() {
                            return cb(util.right(void 0));
                        }
                    })();
                    switch(status2){
                        case SUSPENDED:
                            interrupt = util.left(error4);
                            status2 = COMPLETED;
                            step3 = interrupt;
                            run3(runTick);
                            break;
                        case PENDING:
                            if (interrupt === null) interrupt = util.left(error4);
                            if (bracketCount === 0) {
                                if (status2 === PENDING) attempts = new Aff2(CONS, new Aff2(FINALIZER, step3(error4)), attempts, interrupt);
                                status2 = RETURN;
                                step3 = null;
                                fail3 = null;
                                run3(++runTick);
                            }
                            break;
                        default:
                            if (interrupt === null) interrupt = util.left(error4);
                            if (bracketCount === 0) {
                                status2 = RETURN;
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
                    if (status2 === SUSPENDED) run3(runTick);
                    return canceler;
                };
            }
            return {
                kill: kill2,
                join: join3,
                onComplete,
                isSuspended: function() {
                    return status2 === SUSPENDED;
                },
                run: function() {
                    if (status2 === SUSPENDED) {
                        if (!Scheduler.isDraining()) Scheduler.enqueue(function() {
                            run3(runTick);
                        });
                        else run3(runTick);
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
                loop: while(true){
                    tmp = null;
                    switch(step3.tag){
                        case FORKED:
                            if (step3._3 === EMPTY) {
                                tmp = fibers[step3._1];
                                kills2[count++] = tmp.kill(error4, function(result) {
                                    return function() {
                                        count--;
                                        if (count === 0) cb2(result)();
                                    };
                                });
                            }
                            if (head4 === null) break loop;
                            step3 = head4._2;
                            if (tail2 === null) head4 = null;
                            else {
                                head4 = tail2._1;
                                tail2 = tail2._2;
                            }
                            break;
                        case MAP:
                            step3 = step3._2;
                            break;
                        case APPLY:
                        case ALT:
                            if (head4) tail2 = new Aff2(CONS, head4, tail2);
                            head4 = step3;
                            step3 = step3._1;
                            break;
                    }
                }
                if (count === 0) cb2(util.right(void 0))();
                else {
                    kid = 0;
                    tmp = count;
                    for(; kid < tmp; kid++)kills2[kid] = kills2[kid]();
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
                loop: while(true){
                    lhs = null;
                    rhs = null;
                    tmp = null;
                    kid = null;
                    if (interrupt !== null) return;
                    if (head4 === null) {
                        cb(fail3 || step3)();
                        return;
                    }
                    if (head4._3 !== EMPTY) return;
                    switch(head4.tag){
                        case MAP:
                            if (fail3 === null) {
                                head4._3 = util.right(head4._1(util.fromRight(step3)));
                                step3 = head4._3;
                            } else head4._3 = fail3;
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
                                        if (tmp) tmp = false;
                                        else if (tail2 === null) join3(fail3, null, null);
                                        else join3(fail3, tail2._1, tail2._2);
                                    };
                                });
                                if (tmp) {
                                    tmp = false;
                                    return;
                                }
                            } else if (lhs === EMPTY || rhs === EMPTY) return;
                            else {
                                step3 = util.right(util.fromRight(lhs)(util.fromRight(rhs)));
                                head4._3 = step3;
                            }
                            break;
                        case ALT:
                            lhs = head4._1._3;
                            rhs = head4._2._3;
                            if (lhs === EMPTY && util.isLeft(rhs) || rhs === EMPTY && util.isLeft(lhs)) return;
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
                                        if (tmp) tmp = false;
                                        else if (tail2 === null) join3(step3, null, null);
                                        else join3(step3, tail2._1, tail2._2);
                                    };
                                });
                                if (tmp) {
                                    tmp = false;
                                    return;
                                }
                            }
                            break;
                    }
                    if (tail2 === null) head4 = null;
                    else {
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
                var status2 = CONTINUE;
                var step3 = par;
                var head4 = null;
                var tail2 = null;
                var tmp, fid;
                loop: while(true){
                    tmp = null;
                    fid = null;
                    switch(status2){
                        case CONTINUE:
                            switch(step3.tag){
                                case MAP:
                                    if (head4) tail2 = new Aff2(CONS, head4, tail2);
                                    head4 = new Aff2(MAP, step3._1, EMPTY, EMPTY);
                                    step3 = step3._2;
                                    break;
                                case APPLY:
                                    if (head4) tail2 = new Aff2(CONS, head4, tail2);
                                    head4 = new Aff2(APPLY, EMPTY, step3._2, EMPTY);
                                    step3 = step3._1;
                                    break;
                                case ALT:
                                    if (head4) tail2 = new Aff2(CONS, head4, tail2);
                                    head4 = new Aff2(ALT, EMPTY, step3._2, EMPTY);
                                    step3 = step3._1;
                                    break;
                                default:
                                    fid = fiberId++;
                                    status2 = RETURN;
                                    tmp = step3;
                                    step3 = new Aff2(FORKED, fid, new Aff2(CONS, head4, tail2), EMPTY);
                                    tmp = Fiber(util, supervisor, tmp);
                                    tmp.onComplete({
                                        rethrow: false,
                                        handler: resolve(step3)
                                    })();
                                    fibers[fid] = tmp;
                                    if (supervisor) supervisor.register(tmp);
                            }
                            break;
                        case RETURN:
                            if (head4 === null) break loop;
                            if (head4._1 === EMPTY) {
                                head4._1 = step3;
                                status2 = CONTINUE;
                                step3 = head4._2;
                                head4._2 = EMPTY;
                            } else {
                                head4._2 = step3;
                                step3 = head4;
                                if (tail2 === null) head4 = null;
                                else {
                                    head4 = tail2._1;
                                    tail2 = tail2._2;
                                }
                            }
                    }
                }
                root = step3;
                for(fid = 0; fid < fiberId; fid++)fibers[fid].run();
            }
            function cancel(error4, cb2) {
                interrupt = util.left(error4);
                var innerKills;
                for(var kid in kills)if (kills.hasOwnProperty(kid)) {
                    innerKills = kills[kid];
                    for(kid in innerKills)if (innerKills.hasOwnProperty(kid)) innerKills[kid]();
                }
                kills = null;
                var newKills = kill2(error4, root, cb2);
                return function(killError) {
                    return new Aff2(ASYNC, function(killCb) {
                        return function() {
                            for(var kid2 in newKills)if (newKills.hasOwnProperty(kid2)) newKills[kid2]();
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
    }();
    var _pure = Aff.Pure;
    var _throwError = Aff.Throw;
    function _catchError(aff) {
        return function(k) {
            return Aff.Catch(aff, k);
        };
    }
    function _map(f) {
        return function(aff) {
            if (aff.tag === Aff.Pure.tag) return Aff.Pure(f(aff._1));
            else return Aff.Bind(aff, function(value16) {
                return Aff.Pure(f(value16));
            });
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
    var _delay = /* @__PURE__ */ function() {
        function setDelay(n, k) {
            if (n === 0 && typeof setImmediate !== "undefined") return setImmediate(k);
            else return setTimeout(k, n);
        }
        function clearDelay(n, t2) {
            if (n === 0 && typeof clearImmediate !== "undefined") return clearImmediate(t2);
            else return clearTimeout(t2);
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
    }();
    var _sequential = Aff.Seq;
    // output/Control.Parallel.Class/index.js
    var sequential = function(dict) {
        return dict.sequential;
    };
    var parallel = function(dict) {
        return dict.parallel;
    };
    // output/Control.Parallel/index.js
    var identity8 = /* @__PURE__ */ identity(categoryFn);
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
                return parTraverse_2(dictFoldable)(identity8);
            };
        };
    };
    // output/Effect.Unsafe/foreign.js
    var unsafePerformEffect = function(f) {
        return f();
    };
    // output/Effect.Aff/index.js
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
    var pure2 = /* @__PURE__ */ pure(applicativeEffect);
    var $$void3 = /* @__PURE__ */ $$void(functorEffect);
    var map8 = /* @__PURE__ */ map(functorEffect);
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
    var map1 = /* @__PURE__ */ map(functorAff);
    var forkAff = /* @__PURE__ */ _fork(true);
    var ffiUtil = /* @__PURE__ */ function() {
        var unsafeFromRight = function(v2) {
            if (v2 instanceof Right) return v2.value0;
            if (v2 instanceof Left) return unsafeCrashWith("unsafeFromRight: Left");
            throw new Error("Failed pattern match at Effect.Aff (line 412, column 21 - line 414, column 54): " + [
                v2.constructor.name
            ]);
        };
        var unsafeFromLeft = function(v2) {
            if (v2 instanceof Left) return v2.value0;
            if (v2 instanceof Right) return unsafeCrashWith("unsafeFromLeft: Right");
            throw new Error("Failed pattern match at Effect.Aff (line 407, column 20 - line 409, column 55): " + [
                v2.constructor.name
            ]);
        };
        var isLeft = function(v2) {
            if (v2 instanceof Left) return true;
            if (v2 instanceof Right) return false;
            throw new Error("Failed pattern match at Effect.Aff (line 402, column 12 - line 404, column 21): " + [
                v2.constructor.name
            ]);
        };
        return {
            isLeft,
            fromLeft: unsafeFromLeft,
            fromRight: unsafeFromRight,
            left: Left.create,
            right: Right.create
        };
    }();
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
    var $lazy_applyAff = /* @__PURE__ */ $runtime_lazy3("applyAff", "Effect.Aff", function() {
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
    var bindFlipped4 = /* @__PURE__ */ bindFlipped(bindAff);
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
                    return parSequence_2([
                        v2(err),
                        v1(err)
                    ]);
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
            return map8(effectCanceler)(v2.join(k));
        });
    };
    var functorFiber = {
        map: function(f) {
            return function(t2) {
                return unsafePerformEffect(makeFiber(map1(f)(joinFiber(t2))));
            };
        }
    };
    var killFiber = function(e) {
        return function(v2) {
            return bind1(liftEffect2(v2.isSuspended))(function(suspended) {
                if (suspended) return liftEffect2($$void3(v2.kill(e, $$const(pure2(unit)))));
                return makeAff(function(k) {
                    return map8(effectCanceler)(v2.kill(e, k));
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
            return launchAff(bindFlipped4(function($83) {
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
                    if (res instanceof Done) return pure22(res.value0);
                    if (res instanceof Loop) return go2(res.value0);
                    throw new Error("Failed pattern match at Effect.Aff (line 104, column 7 - line 106, column 23): " + [
                        res.constructor.name
                    ]);
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
    // output/Foreign/foreign.js
    function typeOf(value16) {
        return typeof value16;
    }
    function tagOf(value16) {
        return Object.prototype.toString.call(value16).slice(8, -1);
    }
    // output/Data.Int/foreign.js
    var fromNumberImpl = function(just) {
        return function(nothing) {
            return function(n) {
                return (n | 0) === n ? just(n) : nothing;
            };
        };
    };
    var toNumber = function(n) {
        return n;
    };
    var rem = function(x) {
        return function(y) {
            return x % y;
        };
    };
    // output/Data.Number/foreign.js
    var isFiniteImpl = isFinite;
    function fromStringImpl(str, isFinite2, just, nothing) {
        var num = parseFloat(str);
        if (isFinite2(num)) return just(num);
        else return nothing;
    }
    var abs = Math.abs;
    var floor = Math.floor;
    var round = Math.round;
    // output/Data.Number/index.js
    var fromString = function(str) {
        return fromStringImpl(str, isFiniteImpl, Just.create, Nothing.value);
    };
    // output/Data.Int/index.js
    var top2 = /* @__PURE__ */ top(boundedInt);
    var bottom2 = /* @__PURE__ */ bottom(boundedInt);
    var fromNumber = /* @__PURE__ */ function() {
        return fromNumberImpl(Just.create)(Nothing.value);
    }();
    var unsafeClamp = function(x) {
        if (!isFiniteImpl(x)) return 0;
        if (x >= toNumber(top2)) return top2;
        if (x <= toNumber(bottom2)) return bottom2;
        if (otherwise) return fromMaybe(0)(fromNumber(x));
        throw new Error("Failed pattern match at Data.Int (line 72, column 1 - line 72, column 29): " + [
            x.constructor.name
        ]);
    };
    var round2 = function($37) {
        return unsafeClamp(round($37));
    };
    var floor2 = function($39) {
        return unsafeClamp(floor($39));
    };
    // output/Data.String.CodeUnits/foreign.js
    var singleton6 = function(c2) {
        return c2;
    };
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
    var indexOf = /* @__PURE__ */ function() {
        return _indexOf(Just.create)(Nothing.value);
    }();
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
    var ForeignError = /* @__PURE__ */ function() {
        function ForeignError2(value0) {
            this.value0 = value0;
        }
        ForeignError2.create = function(value0) {
            return new ForeignError2(value0);
        };
        return ForeignError2;
    }();
    var TypeMismatch = /* @__PURE__ */ function() {
        function TypeMismatch3(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        TypeMismatch3.create = function(value0) {
            return function(value1) {
                return new TypeMismatch3(value0, value1);
            };
        };
        return TypeMismatch3;
    }();
    var ErrorAtIndex = /* @__PURE__ */ function() {
        function ErrorAtIndex2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        ErrorAtIndex2.create = function(value0) {
            return function(value1) {
                return new ErrorAtIndex2(value0, value1);
            };
        };
        return ErrorAtIndex2;
    }();
    var ErrorAtProperty = /* @__PURE__ */ function() {
        function ErrorAtProperty2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        ErrorAtProperty2.create = function(value0) {
            return function(value1) {
                return new ErrorAtProperty2(value0, value1);
            };
        };
        return ErrorAtProperty2;
    }();
    var unsafeToForeign = unsafeCoerce2;
    var unsafeFromForeign = unsafeCoerce2;
    var renderForeignError = function(v2) {
        if (v2 instanceof ForeignError) return v2.value0;
        if (v2 instanceof ErrorAtIndex) return "Error at array index " + (show1(v2.value0) + (": " + renderForeignError(v2.value1)));
        if (v2 instanceof ErrorAtProperty) return "Error at property " + (show2(v2.value0) + (": " + renderForeignError(v2.value1)));
        if (v2 instanceof TypeMismatch) return "Type mismatch: expected " + (v2.value0 + (", found " + v2.value1));
        throw new Error("Failed pattern match at Foreign (line 78, column 1 - line 78, column 45): " + [
            v2.constructor.name
        ]);
    };
    var fail = function(dictMonad) {
        var $153 = throwError(monadThrowExceptT(dictMonad));
        return function($154) {
            return $153(singleton5($154));
        };
    };
    var unsafeReadTagged = function(dictMonad) {
        var pure111 = pure(applicativeExceptT(dictMonad));
        var fail1 = fail(dictMonad);
        return function(tag) {
            return function(value16) {
                if (tagOf(value16) === tag) return pure111(unsafeFromForeign(value16));
                if (otherwise) return fail1(new TypeMismatch(tag, tagOf(value16)));
                throw new Error("Failed pattern match at Foreign (line 123, column 1 - line 123, column 104): " + [
                    tag.constructor.name,
                    value16.constructor.name
                ]);
            };
        };
    };
    var readString = function(dictMonad) {
        return unsafeReadTagged(dictMonad)("String");
    };
    // output/Affjax/index.js
    var pure3 = /* @__PURE__ */ pure(/* @__PURE__ */ applicativeExceptT(monadIdentity));
    var fail2 = /* @__PURE__ */ fail(monadIdentity);
    var unsafeReadTagged2 = /* @__PURE__ */ unsafeReadTagged(monadIdentity);
    var alt2 = /* @__PURE__ */ alt(/* @__PURE__ */ altExceptT(semigroupNonEmptyList)(monadIdentity));
    var composeKleisliFlipped2 = /* @__PURE__ */ composeKleisliFlipped(/* @__PURE__ */ bindExceptT(monadIdentity));
    var map9 = /* @__PURE__ */ map(functorMaybe);
    var any2 = /* @__PURE__ */ any(foldableArray)(heytingAlgebraBoolean);
    var eq3 = /* @__PURE__ */ eq(eqString);
    var bindFlipped5 = /* @__PURE__ */ bindFlipped(bindMaybe);
    var map12 = /* @__PURE__ */ map(functorArray);
    var mapFlipped2 = /* @__PURE__ */ mapFlipped(functorAff);
    var $$try3 = /* @__PURE__ */ $$try(monadErrorAff);
    var pure1 = /* @__PURE__ */ pure(applicativeAff);
    var map22 = /* @__PURE__ */ map(functorAff);
    var $$void4 = /* @__PURE__ */ $$void(functorEither);
    var RequestContentError = /* @__PURE__ */ function() {
        function RequestContentError2(value0) {
            this.value0 = value0;
        }
        RequestContentError2.create = function(value0) {
            return new RequestContentError2(value0);
        };
        return RequestContentError2;
    }();
    var ResponseBodyError = /* @__PURE__ */ function() {
        function ResponseBodyError2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        ResponseBodyError2.create = function(value0) {
            return function(value1) {
                return new ResponseBodyError2(value0, value1);
            };
        };
        return ResponseBodyError2;
    }();
    var TimeoutError = /* @__PURE__ */ function() {
        function TimeoutError2() {}
        TimeoutError2.value = new TimeoutError2();
        return TimeoutError2;
    }();
    var RequestFailedError = /* @__PURE__ */ function() {
        function RequestFailedError2() {}
        RequestFailedError2.value = new RequestFailedError2();
        return RequestFailedError2;
    }();
    var XHROtherError = /* @__PURE__ */ function() {
        function XHROtherError2(value0) {
            this.value0 = value0;
        }
        XHROtherError2.create = function(value0) {
            return new XHROtherError2(value0);
        };
        return XHROtherError2;
    }();
    var request = function(driver2) {
        return function(req) {
            var parseJSON = function(v3) {
                if (v3 === "") return pure3(jsonEmptyObject);
                return either(function($74) {
                    return fail2(ForeignError.create($74));
                })(pure3)(jsonParser(v3));
            };
            var fromResponse = function() {
                if (req.responseFormat instanceof $$ArrayBuffer) return unsafeReadTagged2("ArrayBuffer");
                if (req.responseFormat instanceof Blob2) return unsafeReadTagged2("Blob");
                if (req.responseFormat instanceof Document2) return function(x) {
                    return alt2(unsafeReadTagged2("Document")(x))(alt2(unsafeReadTagged2("XMLDocument")(x))(unsafeReadTagged2("HTMLDocument")(x)));
                };
                if (req.responseFormat instanceof Json2) return composeKleisliFlipped2(function($75) {
                    return req.responseFormat.value0(parseJSON($75));
                })(unsafeReadTagged2("String"));
                if (req.responseFormat instanceof $$String2) return unsafeReadTagged2("String");
                if (req.responseFormat instanceof Ignore) return $$const(req.responseFormat.value0(pure3(unit)));
                throw new Error("Failed pattern match at Affjax (line 274, column 18 - line 283, column 57): " + [
                    req.responseFormat.constructor.name
                ]);
            }();
            var extractContent = function(v3) {
                if (v3 instanceof ArrayView) return new Right(v3.value0(unsafeToForeign));
                if (v3 instanceof Blob) return new Right(unsafeToForeign(v3.value0));
                if (v3 instanceof Document) return new Right(unsafeToForeign(v3.value0));
                if (v3 instanceof $$String) return new Right(unsafeToForeign(v3.value0));
                if (v3 instanceof FormData) return new Right(unsafeToForeign(v3.value0));
                if (v3 instanceof FormURLEncoded) return note("Body contains values that cannot be encoded as application/x-www-form-urlencoded")(map9(unsafeToForeign)(encode(v3.value0)));
                if (v3 instanceof Json) return new Right(unsafeToForeign(stringify(v3.value0)));
                throw new Error("Failed pattern match at Affjax (line 235, column 20 - line 250, column 69): " + [
                    v3.constructor.name
                ]);
            };
            var addHeader = function(mh) {
                return function(hs) {
                    if (mh instanceof Just && !any2(on(eq3)(name)(mh.value0))(hs)) return snoc(hs)(mh.value0);
                    return hs;
                };
            };
            var headers = function(reqContent) {
                return addHeader(map9(ContentType.create)(bindFlipped5(toMediaType)(reqContent)))(addHeader(map9(Accept.create)(toMediaType2(req.responseFormat)))(req.headers));
            };
            var ajaxRequest = function(v3) {
                return {
                    method: print(req.method),
                    url: req.url,
                    headers: map12(function(h7) {
                        return {
                            field: name(h7),
                            value: value(h7)
                        };
                    })(headers(req.content)),
                    content: v3,
                    responseType: toResponseType(req.responseFormat),
                    username: toNullable(req.username),
                    password: toNullable(req.password),
                    withCredentials: req.withCredentials,
                    timeout: fromMaybe(0)(map9(function(v1) {
                        return v1;
                    })(req.timeout))
                };
            };
            var send = function(content3) {
                return mapFlipped2($$try3(fromEffectFnAff(_ajax(driver2, "AffjaxTimeoutErrorMessageIdent", "AffjaxRequestFailedMessageIdent", ResponseHeader.create, ajaxRequest(content3)))))(function(v3) {
                    if (v3 instanceof Right) {
                        var v1 = runExcept(fromResponse(v3.value0.body));
                        if (v1 instanceof Left) return new Left(new ResponseBodyError(head(v1.value0), v3.value0));
                        if (v1 instanceof Right) return new Right({
                            headers: v3.value0.headers,
                            status: v3.value0.status,
                            statusText: v3.value0.statusText,
                            body: v1.value0
                        });
                        throw new Error("Failed pattern match at Affjax (line 209, column 9 - line 211, column 52): " + [
                            v1.constructor.name
                        ]);
                    }
                    if (v3 instanceof Left) return new Left(function() {
                        var message2 = message(v3.value0);
                        var $61 = message2 === "AffjaxTimeoutErrorMessageIdent";
                        if ($61) return TimeoutError.value;
                        var $62 = message2 === "AffjaxRequestFailedMessageIdent";
                        if ($62) return RequestFailedError.value;
                        return new XHROtherError(v3.value0);
                    }());
                    throw new Error("Failed pattern match at Affjax (line 207, column 144 - line 219, column 28): " + [
                        v3.constructor.name
                    ]);
                });
            };
            if (req.content instanceof Nothing) return send(toNullable(Nothing.value));
            if (req.content instanceof Just) {
                var v2 = extractContent(req.content.value0);
                if (v2 instanceof Right) return send(toNullable(new Just(v2.value0)));
                if (v2 instanceof Left) return pure1(new Left(new RequestContentError(v2.value0)));
                throw new Error("Failed pattern match at Affjax (line 199, column 7 - line 203, column 48): " + [
                    v2.constructor.name
                ]);
            }
            throw new Error("Failed pattern match at Affjax (line 195, column 3 - line 203, column 48): " + [
                req.content.constructor.name
            ]);
        };
    };
    var printError = function(v2) {
        if (v2 instanceof RequestContentError) return "There was a problem with the request content: " + v2.value0;
        if (v2 instanceof ResponseBodyError) return "There was a problem with the response body: " + renderForeignError(v2.value0);
        if (v2 instanceof TimeoutError) return "There was a problem making the request: timeout";
        if (v2 instanceof RequestFailedError) return "There was a problem making the request: request failed";
        if (v2 instanceof XHROtherError) return "There was a problem making the request: " + message(v2.value0);
        throw new Error("Failed pattern match at Affjax (line 113, column 14 - line 123, column 66): " + [
            v2.constructor.name
        ]);
    };
    var defaultRequest = /* @__PURE__ */ function() {
        return {
            method: new Left(GET.value),
            url: "/",
            headers: [],
            content: Nothing.value,
            username: Nothing.value,
            password: Nothing.value,
            withCredentials: false,
            responseFormat: ignore,
            timeout: Nothing.value
        };
    }();
    var $$delete = function(driver2) {
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
        var $76 = map22($$void4);
        var $77 = $$delete(driver2)(ignore);
        return function($78) {
            return $76($77($78));
        };
    };
    var get2 = function(driver2) {
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
                        method: new Left(POST.value),
                        url: u2,
                        content: c2,
                        responseFormat: rf
                    });
                };
            };
        };
    };
    var put = function(driver2) {
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
    var put2 = /* @__PURE__ */ put(driver);
    var post2 = /* @__PURE__ */ post(driver);
    var get3 = /* @__PURE__ */ get2(driver);
    var delete_2 = /* @__PURE__ */ delete_(driver);
    // output/Data.Argonaut.Decode.Error/index.js
    var show3 = /* @__PURE__ */ show(showString);
    var show12 = /* @__PURE__ */ show(showInt);
    var TypeMismatch2 = /* @__PURE__ */ function() {
        function TypeMismatch3(value0) {
            this.value0 = value0;
        }
        TypeMismatch3.create = function(value0) {
            return new TypeMismatch3(value0);
        };
        return TypeMismatch3;
    }();
    var UnexpectedValue = /* @__PURE__ */ function() {
        function UnexpectedValue2(value0) {
            this.value0 = value0;
        }
        UnexpectedValue2.create = function(value0) {
            return new UnexpectedValue2(value0);
        };
        return UnexpectedValue2;
    }();
    var AtIndex = /* @__PURE__ */ function() {
        function AtIndex2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        AtIndex2.create = function(value0) {
            return function(value1) {
                return new AtIndex2(value0, value1);
            };
        };
        return AtIndex2;
    }();
    var AtKey = /* @__PURE__ */ function() {
        function AtKey2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        AtKey2.create = function(value0) {
            return function(value1) {
                return new AtKey2(value0, value1);
            };
        };
        return AtKey2;
    }();
    var Named = /* @__PURE__ */ function() {
        function Named3(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Named3.create = function(value0) {
            return function(value1) {
                return new Named3(value0, value1);
            };
        };
        return Named3;
    }();
    var MissingValue = /* @__PURE__ */ function() {
        function MissingValue2() {}
        MissingValue2.value = new MissingValue2();
        return MissingValue2;
    }();
    var showJsonDecodeError = {
        show: function(v2) {
            if (v2 instanceof TypeMismatch2) return "(TypeMismatch " + (show3(v2.value0) + ")");
            if (v2 instanceof UnexpectedValue) return "(UnexpectedValue " + (stringify(v2.value0) + ")");
            if (v2 instanceof AtIndex) return "(AtIndex " + (show12(v2.value0) + (" " + (show(showJsonDecodeError)(v2.value1) + ")")));
            if (v2 instanceof AtKey) return "(AtKey " + (show3(v2.value0) + (" " + (show(showJsonDecodeError)(v2.value1) + ")")));
            if (v2 instanceof Named) return "(Named " + (show3(v2.value0) + (" " + (show(showJsonDecodeError)(v2.value1) + ")")));
            if (v2 instanceof MissingValue) return "MissingValue";
            throw new Error("Failed pattern match at Data.Argonaut.Decode.Error (line 24, column 10 - line 30, column 35): " + [
                v2.constructor.name
            ]);
        }
    };
    var printJsonDecodeError = function(err) {
        var go2 = function(v2) {
            if (v2 instanceof TypeMismatch2) return "  Expected value of type '" + (v2.value0 + "'.");
            if (v2 instanceof UnexpectedValue) return "  Unexpected value " + (stringify(v2.value0) + ".");
            if (v2 instanceof AtIndex) return "  At array index " + (show12(v2.value0) + (":\n" + go2(v2.value1)));
            if (v2 instanceof AtKey) return "  At object key '" + (v2.value0 + ("':\n" + go2(v2.value1)));
            if (v2 instanceof Named) return "  Under '" + (v2.value0 + ("':\n" + go2(v2.value1)));
            if (v2 instanceof MissingValue) return "  No value was found.";
            throw new Error("Failed pattern match at Data.Argonaut.Decode.Error (line 37, column 8 - line 43, column 44): " + [
                v2.constructor.name
            ]);
        };
        return "An error occurred while decoding a JSON value:\n" + go2(err);
    };
    // output/Data.Map.Internal/index.js
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
    var map10 = /* @__PURE__ */ map(functorMaybe);
    var Leaf = /* @__PURE__ */ function() {
        function Leaf2() {}
        Leaf2.value = new Leaf2();
        return Leaf2;
    }();
    var Node = /* @__PURE__ */ function() {
        function Node2(value0, value1, value22, value32, value42, value52) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
            this.value3 = value32;
            this.value4 = value42;
            this.value5 = value52;
        }
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
    }();
    var Split = /* @__PURE__ */ function() {
        function Split2(value0, value1, value22) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
        }
        Split2.create = function(value0) {
            return function(value1) {
                return function(value22) {
                    return new Split2(value0, value1, value22);
                };
            };
        };
        return Split2;
    }();
    var SplitLast = /* @__PURE__ */ function() {
        function SplitLast2(value0, value1, value22) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
        }
        SplitLast2.create = function(value0) {
            return function(value1) {
                return function(value22) {
                    return new SplitLast2(value0, value1, value22);
                };
            };
        };
        return SplitLast2;
    }();
    var unsafeNode = function(k, v2, l2, r) {
        if (l2 instanceof Leaf) {
            if (r instanceof Leaf) return new Node(1, 1, k, v2, l2, r);
            if (r instanceof Node) return new Node(1 + r.value0 | 0, 1 + r.value1 | 0, k, v2, l2, r);
            throw new Error("Failed pattern match at Data.Map.Internal (line 702, column 5 - line 706, column 39): " + [
                r.constructor.name
            ]);
        }
        if (l2 instanceof Node) {
            if (r instanceof Leaf) return new Node(1 + l2.value0 | 0, 1 + l2.value1 | 0, k, v2, l2, r);
            if (r instanceof Node) return new Node(1 + function() {
                var $280 = l2.value0 > r.value0;
                if ($280) return l2.value0;
                return r.value0;
            }() | 0, (1 + l2.value1 | 0) + r.value1 | 0, k, v2, l2, r);
            throw new Error("Failed pattern match at Data.Map.Internal (line 708, column 5 - line 712, column 68): " + [
                r.constructor.name
            ]);
        }
        throw new Error("Failed pattern match at Data.Map.Internal (line 700, column 32 - line 712, column 68): " + [
            l2.constructor.name
        ]);
    };
    var singleton7 = function(k) {
        return function(v2) {
            return new Node(1, 1, k, v2, Leaf.value, Leaf.value);
        };
    };
    var unsafeBalancedNode = /* @__PURE__ */ function() {
        var height9 = function(v2) {
            if (v2 instanceof Leaf) return 0;
            if (v2 instanceof Node) return v2.value0;
            throw new Error("Failed pattern match at Data.Map.Internal (line 757, column 12 - line 759, column 26): " + [
                v2.constructor.name
            ]);
        };
        var rotateLeft = function(k, v2, l2, rk, rv, rl, rr) {
            if (rl instanceof Node && rl.value0 > height9(rr)) return unsafeNode(rl.value2, rl.value3, unsafeNode(k, v2, l2, rl.value4), unsafeNode(rk, rv, rl.value5, rr));
            return unsafeNode(rk, rv, unsafeNode(k, v2, l2, rl), rr);
        };
        var rotateRight = function(k, v2, lk, lv, ll, lr, r) {
            if (lr instanceof Node && height9(ll) <= lr.value0) return unsafeNode(lr.value2, lr.value3, unsafeNode(lk, lv, ll, lr.value4), unsafeNode(k, v2, lr.value5, r));
            return unsafeNode(lk, lv, ll, unsafeNode(k, v2, lr, r));
        };
        return function(k, v2, l2, r) {
            if (l2 instanceof Leaf) {
                if (r instanceof Leaf) return singleton7(k)(v2);
                if (r instanceof Node && r.value0 > 1) return rotateLeft(k, v2, l2, r.value2, r.value3, r.value4, r.value5);
                return unsafeNode(k, v2, l2, r);
            }
            if (l2 instanceof Node) {
                if (r instanceof Node) {
                    if (r.value0 > (l2.value0 + 1 | 0)) return rotateLeft(k, v2, l2, r.value2, r.value3, r.value4, r.value5);
                    if (l2.value0 > (r.value0 + 1 | 0)) return rotateRight(k, v2, l2.value2, l2.value3, l2.value4, l2.value5, r);
                }
                if (r instanceof Leaf && l2.value0 > 1) return rotateRight(k, v2, l2.value2, l2.value3, l2.value4, l2.value5, r);
                return unsafeNode(k, v2, l2, r);
            }
            throw new Error("Failed pattern match at Data.Map.Internal (line 717, column 40 - line 738, column 34): " + [
                l2.constructor.name
            ]);
        };
    }();
    var $lazy_unsafeSplit = /* @__PURE__ */ $runtime_lazy4("unsafeSplit", "Data.Map.Internal", function() {
        return function(comp, k, m2) {
            if (m2 instanceof Leaf) return new Split(Nothing.value, Leaf.value, Leaf.value);
            if (m2 instanceof Node) {
                var v2 = comp(k)(m2.value2);
                if (v2 instanceof LT) {
                    var v1 = $lazy_unsafeSplit(793)(comp, k, m2.value4);
                    return new Split(v1.value0, v1.value1, unsafeBalancedNode(m2.value2, m2.value3, v1.value2, m2.value5));
                }
                if (v2 instanceof GT) {
                    var v1 = $lazy_unsafeSplit(796)(comp, k, m2.value5);
                    return new Split(v1.value0, unsafeBalancedNode(m2.value2, m2.value3, m2.value4, v1.value1), v1.value2);
                }
                if (v2 instanceof EQ) return new Split(new Just(m2.value3), m2.value4, m2.value5);
                throw new Error("Failed pattern match at Data.Map.Internal (line 791, column 5 - line 799, column 30): " + [
                    v2.constructor.name
                ]);
            }
            throw new Error("Failed pattern match at Data.Map.Internal (line 787, column 34 - line 799, column 30): " + [
                m2.constructor.name
            ]);
        };
    });
    var unsafeSplit = /* @__PURE__ */ $lazy_unsafeSplit(786);
    var $lazy_unsafeSplitLast = /* @__PURE__ */ $runtime_lazy4("unsafeSplitLast", "Data.Map.Internal", function() {
        return function(k, v2, l2, r) {
            if (r instanceof Leaf) return new SplitLast(k, v2, l2);
            if (r instanceof Node) {
                var v1 = $lazy_unsafeSplitLast(779)(r.value2, r.value3, r.value4, r.value5);
                return new SplitLast(v1.value0, v1.value1, unsafeBalancedNode(k, v2, l2, v1.value2));
            }
            throw new Error("Failed pattern match at Data.Map.Internal (line 776, column 37 - line 780, column 57): " + [
                r.constructor.name
            ]);
        };
    });
    var unsafeSplitLast = /* @__PURE__ */ $lazy_unsafeSplitLast(775);
    var unsafeJoinNodes = function(v2, v1) {
        if (v2 instanceof Leaf) return v1;
        if (v2 instanceof Node) {
            var v22 = unsafeSplitLast(v2.value2, v2.value3, v2.value4, v2.value5);
            return unsafeBalancedNode(v22.value0, v22.value1, v22.value2, v1);
        }
        throw new Error("Failed pattern match at Data.Map.Internal (line 764, column 25 - line 768, column 38): " + [
            v2.constructor.name,
            v1.constructor.name
        ]);
    };
    var pop = function(dictOrd) {
        var compare3 = compare(dictOrd);
        return function(k) {
            return function(m2) {
                var v2 = unsafeSplit(compare3, k, m2);
                return map10(function(a3) {
                    return new Tuple(a3, unsafeJoinNodes(v2.value1, v2.value2));
                })(v2.value0);
            };
        };
    };
    var lookup2 = function(dictOrd) {
        var compare3 = compare(dictOrd);
        return function(k) {
            var go2 = function($copy_v) {
                var $tco_done = false;
                var $tco_result;
                function $tco_loop(v2) {
                    if (v2 instanceof Leaf) {
                        $tco_done = true;
                        return Nothing.value;
                    }
                    if (v2 instanceof Node) {
                        var v1 = compare3(k)(v2.value2);
                        if (v1 instanceof LT) {
                            $copy_v = v2.value4;
                            return;
                        }
                        if (v1 instanceof GT) {
                            $copy_v = v2.value5;
                            return;
                        }
                        if (v1 instanceof EQ) {
                            $tco_done = true;
                            return new Just(v2.value3);
                        }
                        throw new Error("Failed pattern match at Data.Map.Internal (line 283, column 7 - line 286, column 22): " + [
                            v1.constructor.name
                        ]);
                    }
                    throw new Error("Failed pattern match at Data.Map.Internal (line 280, column 8 - line 286, column 22): " + [
                        v2.constructor.name
                    ]);
                }
                while(!$tco_done)$tco_result = $tco_loop($copy_v);
                return $tco_result;
            };
            return go2;
        };
    };
    var insert3 = function(dictOrd) {
        var compare3 = compare(dictOrd);
        return function(k) {
            return function(v2) {
                var go2 = function(v1) {
                    if (v1 instanceof Leaf) return singleton7(k)(v2);
                    if (v1 instanceof Node) {
                        var v22 = compare3(k)(v1.value2);
                        if (v22 instanceof LT) return unsafeBalancedNode(v1.value2, v1.value3, go2(v1.value4), v1.value5);
                        if (v22 instanceof GT) return unsafeBalancedNode(v1.value2, v1.value3, v1.value4, go2(v1.value5));
                        if (v22 instanceof EQ) return new Node(v1.value0, v1.value1, k, v2, v1.value4, v1.value5);
                        throw new Error("Failed pattern match at Data.Map.Internal (line 471, column 7 - line 474, column 35): " + [
                            v22.constructor.name
                        ]);
                    }
                    throw new Error("Failed pattern match at Data.Map.Internal (line 468, column 8 - line 474, column 35): " + [
                        v1.constructor.name
                    ]);
                };
                return go2;
            };
        };
    };
    var foldableMap = {
        foldr: function(f) {
            return function(z2) {
                var $lazy_go = $runtime_lazy4("go", "Data.Map.Internal", function() {
                    return function(m$prime, z$prime) {
                        if (m$prime instanceof Leaf) return z$prime;
                        if (m$prime instanceof Node) return $lazy_go(172)(m$prime.value4, f(m$prime.value3)($lazy_go(172)(m$prime.value5, z$prime)));
                        throw new Error("Failed pattern match at Data.Map.Internal (line 169, column 26 - line 172, column 43): " + [
                            m$prime.constructor.name
                        ]);
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
                var $lazy_go = $runtime_lazy4("go", "Data.Map.Internal", function() {
                    return function(z$prime, m$prime) {
                        if (m$prime instanceof Leaf) return z$prime;
                        if (m$prime instanceof Node) return $lazy_go(178)(f($lazy_go(178)(z$prime, m$prime.value4))(m$prime.value3), m$prime.value5);
                        throw new Error("Failed pattern match at Data.Map.Internal (line 175, column 26 - line 178, column 43): " + [
                            m$prime.constructor.name
                        ]);
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
            var append13 = append(dictMonoid.Semigroup0());
            return function(f) {
                var go2 = function(v2) {
                    if (v2 instanceof Leaf) return mempty3;
                    if (v2 instanceof Node) return append13(go2(v2.value4))(append13(f(v2.value3))(go2(v2.value5)));
                    throw new Error("Failed pattern match at Data.Map.Internal (line 181, column 10 - line 184, column 28): " + [
                        v2.constructor.name
                    ]);
                };
                return go2;
            };
        }
    };
    var empty3 = /* @__PURE__ */ function() {
        return Leaf.value;
    }();
    var $$delete3 = function(dictOrd) {
        var compare3 = compare(dictOrd);
        return function(k) {
            var go2 = function(v2) {
                if (v2 instanceof Leaf) return Leaf.value;
                if (v2 instanceof Node) {
                    var v1 = compare3(k)(v2.value2);
                    if (v1 instanceof LT) return unsafeBalancedNode(v2.value2, v2.value3, go2(v2.value4), v2.value5);
                    if (v1 instanceof GT) return unsafeBalancedNode(v2.value2, v2.value3, v2.value4, go2(v2.value5));
                    if (v1 instanceof EQ) return unsafeJoinNodes(v2.value4, v2.value5);
                    throw new Error("Failed pattern match at Data.Map.Internal (line 498, column 7 - line 501, column 43): " + [
                        v1.constructor.name
                    ]);
                }
                throw new Error("Failed pattern match at Data.Map.Internal (line 495, column 8 - line 501, column 43): " + [
                    v2.constructor.name
                ]);
            };
            return go2;
        };
    };
    var alter = function(dictOrd) {
        var compare3 = compare(dictOrd);
        return function(f) {
            return function(k) {
                return function(m2) {
                    var v2 = unsafeSplit(compare3, k, m2);
                    var v22 = f(v2.value0);
                    if (v22 instanceof Nothing) return unsafeJoinNodes(v2.value1, v2.value2);
                    if (v22 instanceof Just) return unsafeBalancedNode(k, v22.value0, v2.value1, v2.value2);
                    throw new Error("Failed pattern match at Data.Map.Internal (line 514, column 3 - line 518, column 41): " + [
                        v22.constructor.name
                    ]);
                };
            };
        };
    };
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
    var _singleton = function(fallback) {
        return hasFromCodePoint ? String.fromCodePoint : fallback;
    };
    var _take = function(fallback) {
        return function(n) {
            if (hasStringIterator) return function(str) {
                var accum = "";
                var iter = str[Symbol.iterator]();
                for(var i2 = 0; i2 < n; ++i2){
                    var o = iter.next();
                    if (o.done) return accum;
                    accum += o.value;
                }
                return accum;
            };
            return fallback(n);
        };
    };
    var _toCodePointArray = function(fallback) {
        return function(unsafeCodePointAt02) {
            if (hasArrayFrom) return function(str) {
                return Array.from(str, unsafeCodePointAt02);
            };
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
    var toEnum = function(dict) {
        return dict.toEnum;
    };
    var fromEnum = function(dict) {
        return dict.fromEnum;
    };
    var toEnumWithDefaults = function(dictBoundedEnum) {
        var toEnum1 = toEnum(dictBoundedEnum);
        var fromEnum1 = fromEnum(dictBoundedEnum);
        var bottom22 = bottom(dictBoundedEnum.Bounded0());
        return function(low2) {
            return function(high2) {
                return function(x) {
                    var v2 = toEnum1(x);
                    if (v2 instanceof Just) return v2.value0;
                    if (v2 instanceof Nothing) {
                        var $140 = x < fromEnum1(bottom22);
                        if ($140) return low2;
                        return high2;
                    }
                    throw new Error("Failed pattern match at Data.Enum (line 158, column 33 - line 160, column 62): " + [
                        v2.constructor.name
                    ]);
                };
            };
        };
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
        if (v2 >= toCharCode(bottom1) && v2 <= toCharCode(top1)) return new Just(fromCharCode(v2));
        return Nothing.value;
    };
    var enumChar = {
        succ: /* @__PURE__ */ defaultSucc(charToEnum)(toCharCode),
        pred: /* @__PURE__ */ defaultPred(charToEnum)(toCharCode),
        Ord0: function() {
            return ordChar;
        }
    };
    var boundedEnumChar = /* @__PURE__ */ function() {
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
    }();
    // output/Data.String.CodePoints/index.js
    var fromEnum2 = /* @__PURE__ */ fromEnum(boundedEnumChar);
    var map11 = /* @__PURE__ */ map(functorMaybe);
    var unfoldr2 = /* @__PURE__ */ unfoldr(unfoldableArray);
    var div2 = /* @__PURE__ */ div(euclideanRingInt);
    var mod2 = /* @__PURE__ */ mod(euclideanRingInt);
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
    var uncons3 = function(s2) {
        var v2 = length3(s2);
        if (v2 === 0) return Nothing.value;
        if (v2 === 1) return new Just({
            head: fromEnum2(charAt(0)(s2)),
            tail: ""
        });
        var cu1 = fromEnum2(charAt(1)(s2));
        var cu0 = fromEnum2(charAt(0)(s2));
        var $43 = isLead(cu0) && isTrail(cu1);
        if ($43) return new Just({
            head: unsurrogate(cu0)(cu1),
            tail: drop2(2)(s2)
        });
        return new Just({
            head: cu0,
            tail: drop2(1)(s2)
        });
    };
    var unconsButWithTuple = function(s2) {
        return map11(function(v2) {
            return new Tuple(v2.head, v2.tail);
        })(uncons3(s2));
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
            if ($48) return unsurrogate(cu0)(cu1);
            return cu0;
        }
        return cu0;
    };
    var unsafeCodePointAt0 = /* @__PURE__ */ _unsafeCodePointAt0(unsafeCodePointAt0Fallback);
    var toCodePointArray = /* @__PURE__ */ _toCodePointArray(toCodePointArrayFallback)(unsafeCodePointAt0);
    var length4 = function($74) {
        return length(toCodePointArray($74));
    };
    var fromCharCode2 = /* @__PURE__ */ function() {
        var $75 = toEnumWithDefaults(boundedEnumChar)(bottom(boundedChar))(top(boundedChar));
        return function($76) {
            return singleton6($75($76));
        };
    }();
    var singletonFallback = function(v2) {
        if (v2 <= 65535) return fromCharCode2(v2);
        var lead = div2(v2 - 65536 | 0)(1024) + 55296 | 0;
        var trail = mod2(v2 - 65536 | 0)(1024) + 56320 | 0;
        return fromCharCode2(lead) + fromCharCode2(trail);
    };
    var singleton8 = /* @__PURE__ */ _singleton(singletonFallback);
    var takeFallback = function(v2) {
        return function(v1) {
            if (v2 < 1) return "";
            var v22 = uncons3(v1);
            if (v22 instanceof Just) return singleton8(v22.value0.head) + takeFallback(v2 - 1 | 0)(v22.value0.tail);
            return v1;
        };
    };
    var take4 = /* @__PURE__ */ _take(takeFallback);
    var drop4 = function(n) {
        return function(s2) {
            return drop2(length3(take4(n)(s2)))(s2);
        };
    };
    // output/Data.Argonaut.Decode.Decoders/index.js
    var pure4 = /* @__PURE__ */ pure(applicativeEither);
    var map13 = /* @__PURE__ */ map(functorEither);
    var lmap2 = /* @__PURE__ */ lmap(bifunctorEither);
    var composeKleisliFlipped3 = /* @__PURE__ */ composeKleisliFlipped(bindEither);
    var traverse5 = /* @__PURE__ */ traverse(traversableObject)(applicativeEither);
    var traverseWithIndex2 = /* @__PURE__ */ traverseWithIndex(traversableWithIndexArray)(applicativeEither);
    var getFieldOptional$prime = function(decoder) {
        return function(obj) {
            return function(str) {
                var decode = function(json3) {
                    var $35 = isNull(json3);
                    if ($35) return pure4(Nothing.value);
                    return map13(Just.create)(lmap2(AtKey.create(str))(decoder(json3)));
                };
                return maybe(pure4(Nothing.value))(decode)(lookup(str)(obj));
            };
        };
    };
    var getField = function(decoder) {
        return function(obj) {
            return function(str) {
                return maybe(new Left(new AtKey(str, MissingValue.value)))(function() {
                    var $48 = lmap2(AtKey.create(str));
                    return function($49) {
                        return $48(decoder($49));
                    };
                }())(lookup(str)(obj));
            };
        };
    };
    var decodeString = /* @__PURE__ */ function() {
        return caseJsonString(new Left(new TypeMismatch2("String")))(Right.create);
    }();
    var decodeNumber = /* @__PURE__ */ function() {
        return caseJsonNumber(new Left(new TypeMismatch2("Number")))(Right.create);
    }();
    var decodeMaybe = function(decoder) {
        return function(json3) {
            if (isNull(json3)) return pure4(Nothing.value);
            if (otherwise) return map13(Just.create)(decoder(json3));
            throw new Error("Failed pattern match at Data.Argonaut.Decode.Decoders (line 37, column 1 - line 41, column 38): " + [
                decoder.constructor.name,
                json3.constructor.name
            ]);
        };
    };
    var decodeJObject = /* @__PURE__ */ function() {
        var $50 = note(new TypeMismatch2("Object"));
        return function($51) {
            return $50(toObject($51));
        };
    }();
    var decodeJArray = /* @__PURE__ */ function() {
        var $52 = note(new TypeMismatch2("Array"));
        return function($53) {
            return $52(toArray($53));
        };
    }();
    var decodeInt = /* @__PURE__ */ composeKleisliFlipped3(/* @__PURE__ */ function() {
        var $84 = note(new TypeMismatch2("Integer"));
        return function($85) {
            return $84(fromNumber($85));
        };
    }())(decodeNumber);
    var decodeForeignObject = function(decoder) {
        return composeKleisliFlipped3(function() {
            var $86 = lmap2(Named.create("ForeignObject"));
            var $87 = traverse5(decoder);
            return function($88) {
                return $86($87($88));
            };
        }())(decodeJObject);
    };
    var decodeBoolean = /* @__PURE__ */ function() {
        return caseJsonBoolean(new Left(new TypeMismatch2("Boolean")))(Right.create);
    }();
    var decodeArray = function(decoder) {
        return composeKleisliFlipped3(function() {
            var $89 = lmap2(Named.create("Array"));
            var $90 = traverseWithIndex2(function(i2) {
                var $92 = lmap2(AtIndex.create(i2));
                return function($93) {
                    return $92(decoder($93));
                };
            });
            return function($91) {
                return $89($90($91));
            };
        }())(decodeJArray);
    };
    // output/Record/index.js
    var get4 = function(dictIsSymbol) {
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
    var decodeJsonJson = /* @__PURE__ */ function() {
        return {
            decodeJson: Right.create
        };
    }();
    var decodeJsonInt = {
        decodeJson: decodeInt
    };
    var decodeJsonBoolean = {
        decodeJson: decodeBoolean
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
    // output/Data.Argonaut.Decode.Combinators/index.js
    var getFieldOptional$prime2 = function(dictDecodeJson) {
        return getFieldOptional$prime(decodeJson(dictDecodeJson));
    };
    var getField2 = function(dictDecodeJson) {
        return getField(decodeJson(dictDecodeJson));
    };
    // output/Data.Argonaut.Encode.Encoders/index.js
    var extend2 = function(encoder) {
        return function(v2) {
            var $40 = caseJsonObject(jsonSingletonObject(v2.value0)(v2.value1))(function() {
                var $42 = insert(v2.value0)(v2.value1);
                return function($43) {
                    return id($42($43));
                };
            }());
            return function($41) {
                return $40(encoder($41));
            };
        };
    };
    var encodeString = id;
    var encodeMaybe = function(encoder) {
        return function(v2) {
            if (v2 instanceof Nothing) return jsonNull;
            if (v2 instanceof Just) return encoder(v2.value0);
            throw new Error("Failed pattern match at Data.Argonaut.Encode.Encoders (line 31, column 23 - line 33, column 22): " + [
                v2.constructor.name
            ]);
        };
    };
    var encodeInt = function($53) {
        return id(toNumber($53));
    };
    var encodeBoolean = id;
    var assoc = function(encoder) {
        return function(k) {
            var $64 = Tuple.create(k);
            return function($65) {
                return $64(encoder($65));
            };
        };
    };
    // output/Data.Argonaut.Encode.Class/index.js
    var gEncodeJsonNil = {
        gEncodeJson: function(v2) {
            return function(v1) {
                return empty;
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
                    return id(gEncodeJson1(rec)($$Proxy.value));
                }
            };
        };
    };
    var encodeJsonJson = {
        encodeJson: /* @__PURE__ */ identity(categoryFn)
    };
    var encodeJsonJString = {
        encodeJson: encodeString
    };
    var encodeJsonJBoolean = {
        encodeJson: encodeBoolean
    };
    var encodeJsonInt = {
        encodeJson: encodeInt
    };
    var encodeJson = function(dict) {
        return dict.encodeJson;
    };
    var encodeJsonMaybe = function(dictEncodeJson) {
        return {
            encodeJson: encodeMaybe(encodeJson(dictEncodeJson))
        };
    };
    var gEncodeJsonCons = function(dictEncodeJson) {
        var encodeJson12 = encodeJson(dictEncodeJson);
        return function(dictGEncodeJson) {
            var gEncodeJson1 = gEncodeJson(dictGEncodeJson);
            return function(dictIsSymbol) {
                var reflectSymbol2 = reflectSymbol(dictIsSymbol);
                var get10 = get4(dictIsSymbol)();
                return function() {
                    return {
                        gEncodeJson: function(row) {
                            return function(v2) {
                                return insert(reflectSymbol2($$Proxy.value))(encodeJson12(get10($$Proxy.value)(row)))(gEncodeJson1(row)($$Proxy.value));
                            };
                        }
                    };
                };
            };
        };
    };
    // output/Data.Argonaut.Encode.Combinators/index.js
    var extend3 = function(dictEncodeJson) {
        return extend2(encodeJson(dictEncodeJson));
    };
    var assoc2 = function(dictEncodeJson) {
        return assoc(encodeJson(dictEncodeJson));
    };
    // output/Bill.Types/index.js
    var extend4 = /* @__PURE__ */ extend3(encodeJsonJson);
    var assoc3 = /* @__PURE__ */ assoc2(encodeJsonInt);
    var assoc1 = /* @__PURE__ */ assoc2(encodeJsonJString);
    var assoc22 = /* @__PURE__ */ assoc2(/* @__PURE__ */ encodeJsonMaybe(encodeJsonJString));
    var assoc32 = /* @__PURE__ */ assoc2(encodeJsonJBoolean);
    var lmap3 = /* @__PURE__ */ lmap(bifunctorEither);
    var bind2 = /* @__PURE__ */ bind(bindEither);
    var decodeJson2 = /* @__PURE__ */ decodeJson(/* @__PURE__ */ decodeForeignObject2(decodeJsonJson));
    var getField3 = /* @__PURE__ */ getField2(decodeJsonInt);
    var getField1 = /* @__PURE__ */ getField2(decodeJsonBoolean);
    var getFieldOptional$prime3 = /* @__PURE__ */ getFieldOptional$prime2(decodeJsonString);
    var getField22 = /* @__PURE__ */ getField2(decodeJsonString);
    var getFieldOptional$prime1 = /* @__PURE__ */ getFieldOptional$prime2(decodeJsonInt);
    var pure5 = /* @__PURE__ */ pure(applicativeEither);
    var getFieldOptional$prime22 = /* @__PURE__ */ getFieldOptional$prime2(decodeJsonJson);
    var getField32 = /* @__PURE__ */ getField2(/* @__PURE__ */ decodeArray2(decodeJsonJson));
    var map14 = /* @__PURE__ */ map(functorEither);
    var traverse3 = /* @__PURE__ */ traverse(traversableArray)(applicativeEither);
    var encodeBill = function(bill) {
        return extend4(assoc3("id")(bill.id))(extend4(assoc3("customer_id")(bill.customer_id))(extend4(assoc1("date")(bill.date))(extend4(assoc1("prev_balance_money")(bill.prev_balance_money))(extend4(assoc1("prev_gram_jewel")(bill.prev_gram_jewel))(extend4(assoc1("prev_baht_jewel")(bill.prev_baht_jewel))(extend4(assoc1("prev_gram_bar96")(bill.prev_gram_bar96))(extend4(assoc1("prev_baht_bar96")(bill.prev_baht_bar96))(extend4(assoc1("prev_gram_bar99")(bill.prev_gram_bar99))(extend4(assoc1("prev_baht_bar99")(bill.prev_baht_bar99))(extend4(assoc32("is_vat_deferred")(bill.is_vat_deferred))(extend4(assoc1("vat_rate")(bill.vat_rate))(extend4(assoc22("market_buying_price_jewel")(bill.market_buying_price_jewel))(extend4(assoc32("is_finalized")(bill.is_finalized))(extend4(assoc3("version")(bill.version))(jsonEmptyObject)))))))))))))));
    };
    var decodeTrayData = function(json3) {
        return lmap3(printJsonDecodeError)(bind2(decodeJson2(json3))(function(obj) {
            return bind2(getField3(obj)("id"))(function(id4) {
                return bind2(getField3(obj)("group_id"))(function(group_id) {
                    return bind2(getField3(obj)("internal_num"))(function(internal_num) {
                        return bind2(getField1(obj)("is_return"))(function(is_return) {
                            return bind2(getFieldOptional$prime3(obj)("purity"))(function(purity) {
                                return bind2(getField22(obj)("shape"))(function(shape2) {
                                    return bind2(getFieldOptional$prime1(obj)("discount"))(function(discount) {
                                        return bind2(getField22(obj)("actual_weight_grams"))(function(actual_weight_grams) {
                                            return bind2(getFieldOptional$prime3(obj)("price_rate"))(function(price_rate) {
                                                return bind2(getFieldOptional$prime3(obj)("additional_charge_rate"))(function(additional_charge_rate) {
                                                    return pure5({
                                                        id: id4,
                                                        group_id,
                                                        internal_num,
                                                        is_return,
                                                        purity,
                                                        shape: shape2,
                                                        discount,
                                                        actual_weight_grams,
                                                        price_rate,
                                                        additional_charge_rate
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
    var decodeTransactionData = function(json3) {
        return lmap3(printJsonDecodeError)(bind2(decodeJson2(json3))(function(obj) {
            return bind2(getField3(obj)("id"))(function(id4) {
                return bind2(getField3(obj)("group_id"))(function(group_id) {
                    return pure5({
                        id: id4,
                        group_id
                    });
                });
            });
        }));
    };
    var decodePackData = function(json3) {
        return lmap3(printJsonDecodeError)(bind2(decodeJson2(json3))(function(obj) {
            return bind2(getField3(obj)("id"))(function(id4) {
                return bind2(getField3(obj)("group_id"))(function(group_id) {
                    return bind2(getField3(obj)("internal_id"))(function(internal_id) {
                        return bind2(getField22(obj)("user_number"))(function(user_number) {
                            return pure5({
                                id: id4,
                                group_id,
                                internal_id,
                                user_number
                            });
                        });
                    });
                });
            });
        }));
    };
    var decodeItemData = function(json3) {
        return lmap3(printJsonDecodeError)(bind2(decodeJson2(json3))(function(obj) {
            return bind2(getField3(obj)("id"))(function(id4) {
                return bind2(getField3(obj)("display_order"))(function(display_order) {
                    return bind2(getFieldOptional$prime1(obj)("tray_id"))(function(tray_id) {
                        return bind2(getFieldOptional$prime3(obj)("making_charge"))(function(making_charge) {
                            return bind2(getFieldOptional$prime1(obj)("jewelry_type_id"))(function(jewelry_type_id) {
                                return bind2(getFieldOptional$prime3(obj)("design_name"))(function(design_name) {
                                    return bind2(getFieldOptional$prime3(obj)("nominal_weight"))(function(nominal_weight) {
                                        return bind2(getFieldOptional$prime1(obj)("quantity"))(function(quantity) {
                                            return bind2(getFieldOptional$prime3(obj)("amount"))(function(amount) {
                                                return bind2(getFieldOptional$prime1(obj)("pack_id"))(function(pack_id) {
                                                    return bind2(getFieldOptional$prime3(obj)("deduction_rate"))(function(deduction_rate) {
                                                        return bind2(getFieldOptional$prime3(obj)("shape"))(function(shape2) {
                                                            return bind2(getFieldOptional$prime3(obj)("purity"))(function(purity) {
                                                                return bind2(getFieldOptional$prime3(obj)("description"))(function(description) {
                                                                    return bind2(getFieldOptional$prime3(obj)("weight_grams"))(function(weight_grams) {
                                                                        return bind2(getFieldOptional$prime3(obj)("weight_baht"))(function(weight_baht) {
                                                                            return bind2(getFieldOptional$prime3(obj)("calculation_amount"))(function(calculation_amount) {
                                                                                return bind2(getFieldOptional$prime1(obj)("transaction_id"))(function(transaction_id) {
                                                                                    return bind2(getFieldOptional$prime3(obj)("transaction_type"))(function(transaction_type) {
                                                                                        return bind2(getFieldOptional$prime3(obj)("balance_type"))(function(balance_type) {
                                                                                            return bind2(getFieldOptional$prime3(obj)("amount_money"))(function(amount_money) {
                                                                                                return bind2(getFieldOptional$prime3(obj)("amount_grams"))(function(amount_grams) {
                                                                                                    return bind2(getFieldOptional$prime3(obj)("amount_baht"))(function(amount_baht) {
                                                                                                        return bind2(getFieldOptional$prime3(obj)("price_rate"))(function(price_rate) {
                                                                                                            return bind2(getFieldOptional$prime3(obj)("conversion_charge_rate"))(function(conversion_charge_rate) {
                                                                                                                return bind2(getFieldOptional$prime3(obj)("split_charge_rate"))(function(split_charge_rate) {
                                                                                                                    return bind2(getFieldOptional$prime3(obj)("block_making_charge_rate"))(function(block_making_charge_rate) {
                                                                                                                        return bind2(getFieldOptional$prime3(obj)("source_amount_grams"))(function(source_amount_grams) {
                                                                                                                            return bind2(getFieldOptional$prime3(obj)("source_amount_baht"))(function(source_amount_baht) {
                                                                                                                                return bind2(getFieldOptional$prime3(obj)("dest_amount_grams"))(function(dest_amount_grams) {
                                                                                                                                    return bind2(getFieldOptional$prime3(obj)("dest_amount_baht"))(function(dest_amount_baht) {
                                                                                                                                        return pure5({
                                                                                                                                            id: id4,
                                                                                                                                            display_order,
                                                                                                                                            tray_id,
                                                                                                                                            making_charge,
                                                                                                                                            jewelry_type_id,
                                                                                                                                            design_name,
                                                                                                                                            nominal_weight,
                                                                                                                                            quantity,
                                                                                                                                            amount,
                                                                                                                                            pack_id,
                                                                                                                                            deduction_rate,
                                                                                                                                            shape: shape2,
                                                                                                                                            purity,
                                                                                                                                            description,
                                                                                                                                            weight_grams,
                                                                                                                                            weight_baht,
                                                                                                                                            calculation_amount,
                                                                                                                                            transaction_id,
                                                                                                                                            transaction_type,
                                                                                                                                            balance_type,
                                                                                                                                            amount_money,
                                                                                                                                            amount_grams,
                                                                                                                                            amount_baht,
                                                                                                                                            price_rate,
                                                                                                                                            conversion_charge_rate,
                                                                                                                                            split_charge_rate,
                                                                                                                                            block_making_charge_rate,
                                                                                                                                            source_amount_grams,
                                                                                                                                            source_amount_baht,
                                                                                                                                            dest_amount_grams,
                                                                                                                                            dest_amount_baht
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
    var decodeGroupData = function(json3) {
        return bind2(lmap3(printJsonDecodeError)(decodeJson2(json3)))(function(obj) {
            return bind2(lmap3(printJsonDecodeError)(getField22(obj)("type")))(function(type_21) {
                return bind2(lmap3(printJsonDecodeError)(getFieldOptional$prime22(obj)("tray")))(function(trayJson) {
                    return bind2(lmap3(printJsonDecodeError)(getFieldOptional$prime22(obj)("pack")))(function(packJson) {
                        return bind2(lmap3(printJsonDecodeError)(getFieldOptional$prime22(obj)("transaction")))(function(transactionJson) {
                            return bind2(lmap3(printJsonDecodeError)(getField32(obj)("items")))(function(itemsJson) {
                                return bind2(function() {
                                    if (trayJson instanceof Nothing) return pure5(Nothing.value);
                                    if (trayJson instanceof Just) return map14(Just.create)(decodeTrayData(trayJson.value0));
                                    throw new Error("Failed pattern match at Bill.Types (line 418, column 11 - line 420, column 42): " + [
                                        trayJson.constructor.name
                                    ]);
                                }())(function(tray) {
                                    return bind2(function() {
                                        if (packJson instanceof Nothing) return pure5(Nothing.value);
                                        if (packJson instanceof Just) return map14(Just.create)(decodePackData(packJson.value0));
                                        throw new Error("Failed pattern match at Bill.Types (line 422, column 11 - line 424, column 42): " + [
                                            packJson.constructor.name
                                        ]);
                                    }())(function(pack) {
                                        return bind2(function() {
                                            if (transactionJson instanceof Nothing) return pure5(Nothing.value);
                                            if (transactionJson instanceof Just) return map14(Just.create)(decodeTransactionData(transactionJson.value0));
                                            throw new Error("Failed pattern match at Bill.Types (line 426, column 18 - line 428, column 49): " + [
                                                transactionJson.constructor.name
                                            ]);
                                        }())(function(transaction) {
                                            return bind2(traverse3(decodeItemData)(itemsJson))(function(items2) {
                                                return pure5({
                                                    type: type_21,
                                                    tray,
                                                    pack,
                                                    transaction,
                                                    items: items2
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
    };
    var decodeBillGroup = function(json3) {
        return bind2(lmap3(printJsonDecodeError)(decodeJson2(json3)))(function(obj) {
            return bind2(lmap3(printJsonDecodeError)(getField3(obj)("id")))(function(id4) {
                return bind2(lmap3(printJsonDecodeError)(getField3(obj)("bill_id")))(function(bill_id) {
                    return bind2(lmap3(printJsonDecodeError)(getField22(obj)("group_type")))(function(group_type) {
                        return bind2(lmap3(printJsonDecodeError)(getField3(obj)("display_order")))(function(display_order) {
                            return bind2(lmap3(printJsonDecodeError)(getField3(obj)("version")))(function(version) {
                                return bind2(lmap3(printJsonDecodeError)(getFieldOptional$prime3(obj)("updated_by")))(function(updated_by) {
                                    return bind2(lmap3(printJsonDecodeError)(getField22(obj)("created_at")))(function(created_at) {
                                        return bind2(lmap3(printJsonDecodeError)(getField22(obj)("updated_at")))(function(updated_at) {
                                            return bind2(lmap3(printJsonDecodeError)(getFieldOptional$prime22(obj)("data")))(function(dataJson) {
                                                return bind2(function() {
                                                    if (dataJson instanceof Nothing) return pure5(Nothing.value);
                                                    if (dataJson instanceof Just) return map14(Just.create)(decodeGroupData(dataJson.value0));
                                                    throw new Error("Failed pattern match at Bill.Types (line 447, column 16 - line 449, column 43): " + [
                                                        dataJson.constructor.name
                                                    ]);
                                                }())(function(groupData) {
                                                    return pure5({
                                                        id: id4,
                                                        bill_id,
                                                        group_type,
                                                        display_order,
                                                        version,
                                                        updated_by,
                                                        created_at,
                                                        updated_at,
                                                        groupData
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
    };
    var decodeBill = function(json3) {
        return lmap3(printJsonDecodeError)(bind2(decodeJson2(json3))(function(obj) {
            return bind2(getField3(obj)("id"))(function(id4) {
                return bind2(getField3(obj)("customer_id"))(function(customer_id) {
                    return bind2(getField22(obj)("date"))(function(date2) {
                        return bind2(getField22(obj)("prev_balance_money"))(function(prev_balance_money) {
                            return bind2(getField22(obj)("prev_gram_jewel"))(function(prev_gram_jewel) {
                                return bind2(getField22(obj)("prev_baht_jewel"))(function(prev_baht_jewel) {
                                    return bind2(getField22(obj)("prev_gram_bar96"))(function(prev_gram_bar96) {
                                        return bind2(getField22(obj)("prev_baht_bar96"))(function(prev_baht_bar96) {
                                            return bind2(getField22(obj)("prev_gram_bar99"))(function(prev_gram_bar99) {
                                                return bind2(getField22(obj)("prev_baht_bar99"))(function(prev_baht_bar99) {
                                                    return bind2(getFieldOptional$prime3(obj)("final_balance_money"))(function(final_balance_money) {
                                                        return bind2(getFieldOptional$prime3(obj)("final_gram_jewel"))(function(final_gram_jewel) {
                                                            return bind2(getFieldOptional$prime3(obj)("final_baht_jewel"))(function(final_baht_jewel) {
                                                                return bind2(getFieldOptional$prime3(obj)("final_gram_bar96"))(function(final_gram_bar96) {
                                                                    return bind2(getFieldOptional$prime3(obj)("final_baht_bar96"))(function(final_baht_bar96) {
                                                                        return bind2(getFieldOptional$prime3(obj)("final_gram_bar99"))(function(final_gram_bar99) {
                                                                            return bind2(getFieldOptional$prime3(obj)("final_baht_bar99"))(function(final_baht_bar99) {
                                                                                return bind2(getField1(obj)("is_vat_deferred"))(function(is_vat_deferred) {
                                                                                    return bind2(getField22(obj)("vat_rate"))(function(vat_rate) {
                                                                                        return bind2(getFieldOptional$prime3(obj)("market_buying_price_jewel"))(function(market_buying_price_jewel) {
                                                                                            return bind2(getFieldOptional$prime3(obj)("vat_taxable_amount"))(function(vat_taxable_amount) {
                                                                                                return bind2(getFieldOptional$prime3(obj)("vat_amount"))(function(vat_amount) {
                                                                                                    return bind2(getField1(obj)("is_finalized"))(function(is_finalized) {
                                                                                                        return bind2(getFieldOptional$prime3(obj)("finalized_at"))(function(finalized_at) {
                                                                                                            return bind2(getField22(obj)("created_at"))(function(created_at) {
                                                                                                                return bind2(getField22(obj)("updated_at"))(function(updated_at) {
                                                                                                                    return bind2(getField3(obj)("version"))(function(version) {
                                                                                                                        return pure5({
                                                                                                                            id: id4,
                                                                                                                            customer_id,
                                                                                                                            date: date2,
                                                                                                                            prev_balance_money,
                                                                                                                            prev_gram_jewel,
                                                                                                                            prev_baht_jewel,
                                                                                                                            prev_gram_bar96,
                                                                                                                            prev_baht_bar96,
                                                                                                                            prev_gram_bar99,
                                                                                                                            prev_baht_bar99,
                                                                                                                            final_balance_money,
                                                                                                                            final_gram_jewel,
                                                                                                                            final_baht_jewel,
                                                                                                                            final_gram_bar96,
                                                                                                                            final_baht_bar96,
                                                                                                                            final_gram_bar99,
                                                                                                                            final_baht_bar99,
                                                                                                                            is_vat_deferred,
                                                                                                                            vat_rate,
                                                                                                                            market_buying_price_jewel,
                                                                                                                            vat_taxable_amount,
                                                                                                                            vat_amount,
                                                                                                                            is_finalized,
                                                                                                                            finalized_at,
                                                                                                                            created_at,
                                                                                                                            updated_at,
                                                                                                                            version
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
                        });
                    });
                });
            });
        }));
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
    // output/Bill.API/index.js
    var bind3 = /* @__PURE__ */ bind(bindAff);
    var encodeJson2 = /* @__PURE__ */ encodeJson(/* @__PURE__ */ encodeRecord(/* @__PURE__ */ gEncodeJsonCons(encodeJsonInt)(gEncodeJsonNil)({
        reflectSymbol: function() {
            return "customer_id";
        }
    })())());
    var pure6 = /* @__PURE__ */ pure(applicativeAff);
    var show4 = /* @__PURE__ */ show(showInt);
    var bind12 = /* @__PURE__ */ bind(bindEither);
    var lmap4 = /* @__PURE__ */ lmap(bifunctorEither);
    var decodeJson3 = /* @__PURE__ */ decodeJson(/* @__PURE__ */ decodeForeignObject2(decodeJsonJson));
    var getField4 = /* @__PURE__ */ getField2(decodeJsonJson);
    var decodeArray3 = /* @__PURE__ */ decodeArray2(decodeJsonJson);
    var getField12 = /* @__PURE__ */ getField2(decodeArray3);
    var traverse4 = /* @__PURE__ */ traverse(traversableArray)(applicativeEither);
    var pure12 = /* @__PURE__ */ pure(applicativeEither);
    var decodeJson1 = /* @__PURE__ */ decodeJson(decodeArray3);
    var apiUrl = "/api/bills";
    var createBill = function(dictMonadAff) {
        var liftAff2 = liftAff(dictMonadAff);
        return function(customerId) {
            return liftAff2(bind3(post2(json2)(apiUrl)(new Just(json(encodeJson2({
                customer_id: customerId
            })))))(function(result) {
                return pure6(function() {
                    if (result instanceof Left) return new Left("API error: " + printError(result.value0));
                    if (result instanceof Right) return decodeBill(result.value0.body);
                    throw new Error("Failed pattern match at Bill.API (line 59, column 10 - line 61, column 47): " + [
                        result.constructor.name
                    ]);
                }());
            }));
        };
    };
    var getBillWithGroups = function(dictMonadAff) {
        var liftAff2 = liftAff(dictMonadAff);
        return function(billId2) {
            return liftAff2(bind3(get3(json2)(apiUrl + ("/" + show4(billId2))))(function(result) {
                return pure6(function() {
                    if (result instanceof Left) return new Left("API error: " + printError(result.value0));
                    if (result instanceof Right) return bind12(lmap4(printJsonDecodeError)(decodeJson3(result.value0.body)))(function(obj) {
                        return bind12(lmap4(printJsonDecodeError)(getField4(obj)("bill")))(function(billJson) {
                            return bind12(lmap4(printJsonDecodeError)(getField12(obj)("groups")))(function(groupsJson) {
                                return bind12(decodeBill(billJson))(function(bill) {
                                    return bind12(traverse4(decodeBillGroup)(groupsJson))(function(groups) {
                                        return pure12({
                                            bill,
                                            groups
                                        });
                                    });
                                });
                            });
                        });
                    });
                    throw new Error("Failed pattern match at Bill.API (line 45, column 10 - line 53, column 28): " + [
                        result.constructor.name
                    ]);
                }());
            }));
        };
    };
    var getCustomerBills = function(dictMonadAff) {
        var liftAff2 = liftAff(dictMonadAff);
        return function(customerId) {
            return liftAff2(bind3(get3(json2)(apiUrl + ("/customer/" + show4(customerId))))(function(result) {
                return pure6(function() {
                    if (result instanceof Left) return new Left("API error: " + printError(result.value0));
                    if (result instanceof Right) return bind12(lmap4(printJsonDecodeError)(decodeJson1(result.value0.body)))(function(billsJson) {
                        return traverse4(decodeBill)(billsJson);
                    });
                    throw new Error("Failed pattern match at Bill.API (line 81, column 10 - line 85, column 36): " + [
                        result.constructor.name
                    ]);
                }());
            }));
        };
    };
    var updateBill = function(dictMonadAff) {
        var liftAff2 = liftAff(dictMonadAff);
        return function(bill) {
            return liftAff2(bind3(put2(json2)(apiUrl + ("/" + show4(bill.id)))(new Just(json(encodeBill(bill)))))(function(result) {
                return pure6(function() {
                    if (result instanceof Left) return new Left("API error: " + printError(result.value0));
                    if (result instanceof Right) return decodeBill(result.value0.body);
                    throw new Error("Failed pattern match at Bill.API (line 67, column 10 - line 69, column 47): " + [
                        result.constructor.name
                    ]);
                }());
            }));
        };
    };
    // output/Data.Number.Format/foreign.js
    function wrap2(method2) {
        return function(d) {
            return function(num) {
                return method2.apply(num, [
                    d
                ]);
            };
        };
    }
    var toPrecisionNative = wrap2(Number.prototype.toPrecision);
    var toFixedNative = wrap2(Number.prototype.toFixed);
    var toExponentialNative = wrap2(Number.prototype.toExponential);
    // output/Data.Number.Format/index.js
    var clamp2 = /* @__PURE__ */ clamp(ordInt);
    var Precision = /* @__PURE__ */ function() {
        function Precision2(value0) {
            this.value0 = value0;
        }
        Precision2.create = function(value0) {
            return new Precision2(value0);
        };
        return Precision2;
    }();
    var Fixed = /* @__PURE__ */ function() {
        function Fixed2(value0) {
            this.value0 = value0;
        }
        Fixed2.create = function(value0) {
            return new Fixed2(value0);
        };
        return Fixed2;
    }();
    var Exponential = /* @__PURE__ */ function() {
        function Exponential2(value0) {
            this.value0 = value0;
        }
        Exponential2.create = function(value0) {
            return new Exponential2(value0);
        };
        return Exponential2;
    }();
    var toStringWith = function(v2) {
        if (v2 instanceof Precision) return toPrecisionNative(v2.value0);
        if (v2 instanceof Fixed) return toFixedNative(v2.value0);
        if (v2 instanceof Exponential) return toExponentialNative(v2.value0);
        throw new Error("Failed pattern match at Data.Number.Format (line 59, column 1 - line 59, column 43): " + [
            v2.constructor.name
        ]);
    };
    var fixed = /* @__PURE__ */ function() {
        var $9 = clamp2(0)(20);
        return function($10) {
            return Fixed.create($9($10));
        };
    }();
    // output/Data.Exists/index.js
    var runExists = unsafeCoerce2;
    var mkExists = unsafeCoerce2;
    // output/Data.Coyoneda/index.js
    var CoyonedaF = /* @__PURE__ */ function() {
        function CoyonedaF2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        CoyonedaF2.create = function(value0) {
            return function(value1) {
                return new CoyonedaF2(value0, value1);
            };
        };
        return CoyonedaF2;
    }();
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
    var OrdBox = /* @__PURE__ */ function() {
        function OrdBox2(value0, value1, value22) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
        }
        OrdBox2.create = function(value0) {
            return function(value1) {
                return function(value22) {
                    return new OrdBox2(value0, value1, value22);
                };
            };
        };
        return OrdBox2;
    }();
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
    // output/DOM.HTML.Indexed.ButtonType/index.js
    var ButtonButton = /* @__PURE__ */ function() {
        function ButtonButton2() {}
        ButtonButton2.value = new ButtonButton2();
        return ButtonButton2;
    }();
    var ButtonSubmit = /* @__PURE__ */ function() {
        function ButtonSubmit2() {}
        ButtonSubmit2.value = new ButtonSubmit2();
        return ButtonSubmit2;
    }();
    var ButtonReset = /* @__PURE__ */ function() {
        function ButtonReset2() {}
        ButtonReset2.value = new ButtonReset2();
        return ButtonReset2;
    }();
    var renderButtonType = function(v2) {
        if (v2 instanceof ButtonButton) return "button";
        if (v2 instanceof ButtonSubmit) return "submit";
        if (v2 instanceof ButtonReset) return "reset";
        throw new Error("Failed pattern match at DOM.HTML.Indexed.ButtonType (line 14, column 20 - line 17, column 25): " + [
            v2.constructor.name
        ]);
    };
    // output/DOM.HTML.Indexed.InputType/index.js
    var InputButton = /* @__PURE__ */ function() {
        function InputButton2() {}
        InputButton2.value = new InputButton2();
        return InputButton2;
    }();
    var InputCheckbox = /* @__PURE__ */ function() {
        function InputCheckbox2() {}
        InputCheckbox2.value = new InputCheckbox2();
        return InputCheckbox2;
    }();
    var InputColor = /* @__PURE__ */ function() {
        function InputColor2() {}
        InputColor2.value = new InputColor2();
        return InputColor2;
    }();
    var InputDate = /* @__PURE__ */ function() {
        function InputDate2() {}
        InputDate2.value = new InputDate2();
        return InputDate2;
    }();
    var InputDatetimeLocal = /* @__PURE__ */ function() {
        function InputDatetimeLocal2() {}
        InputDatetimeLocal2.value = new InputDatetimeLocal2();
        return InputDatetimeLocal2;
    }();
    var InputEmail = /* @__PURE__ */ function() {
        function InputEmail2() {}
        InputEmail2.value = new InputEmail2();
        return InputEmail2;
    }();
    var InputFile = /* @__PURE__ */ function() {
        function InputFile2() {}
        InputFile2.value = new InputFile2();
        return InputFile2;
    }();
    var InputHidden = /* @__PURE__ */ function() {
        function InputHidden2() {}
        InputHidden2.value = new InputHidden2();
        return InputHidden2;
    }();
    var InputImage = /* @__PURE__ */ function() {
        function InputImage2() {}
        InputImage2.value = new InputImage2();
        return InputImage2;
    }();
    var InputMonth = /* @__PURE__ */ function() {
        function InputMonth2() {}
        InputMonth2.value = new InputMonth2();
        return InputMonth2;
    }();
    var InputNumber = /* @__PURE__ */ function() {
        function InputNumber2() {}
        InputNumber2.value = new InputNumber2();
        return InputNumber2;
    }();
    var InputPassword = /* @__PURE__ */ function() {
        function InputPassword2() {}
        InputPassword2.value = new InputPassword2();
        return InputPassword2;
    }();
    var InputRadio = /* @__PURE__ */ function() {
        function InputRadio2() {}
        InputRadio2.value = new InputRadio2();
        return InputRadio2;
    }();
    var InputRange = /* @__PURE__ */ function() {
        function InputRange2() {}
        InputRange2.value = new InputRange2();
        return InputRange2;
    }();
    var InputReset = /* @__PURE__ */ function() {
        function InputReset2() {}
        InputReset2.value = new InputReset2();
        return InputReset2;
    }();
    var InputSearch = /* @__PURE__ */ function() {
        function InputSearch2() {}
        InputSearch2.value = new InputSearch2();
        return InputSearch2;
    }();
    var InputSubmit = /* @__PURE__ */ function() {
        function InputSubmit2() {}
        InputSubmit2.value = new InputSubmit2();
        return InputSubmit2;
    }();
    var InputTel = /* @__PURE__ */ function() {
        function InputTel2() {}
        InputTel2.value = new InputTel2();
        return InputTel2;
    }();
    var InputText = /* @__PURE__ */ function() {
        function InputText2() {}
        InputText2.value = new InputText2();
        return InputText2;
    }();
    var InputTime = /* @__PURE__ */ function() {
        function InputTime2() {}
        InputTime2.value = new InputTime2();
        return InputTime2;
    }();
    var InputUrl = /* @__PURE__ */ function() {
        function InputUrl2() {}
        InputUrl2.value = new InputUrl2();
        return InputUrl2;
    }();
    var InputWeek = /* @__PURE__ */ function() {
        function InputWeek2() {}
        InputWeek2.value = new InputWeek2();
        return InputWeek2;
    }();
    var renderInputType = function(v2) {
        if (v2 instanceof InputButton) return "button";
        if (v2 instanceof InputCheckbox) return "checkbox";
        if (v2 instanceof InputColor) return "color";
        if (v2 instanceof InputDate) return "date";
        if (v2 instanceof InputDatetimeLocal) return "datetime-local";
        if (v2 instanceof InputEmail) return "email";
        if (v2 instanceof InputFile) return "file";
        if (v2 instanceof InputHidden) return "hidden";
        if (v2 instanceof InputImage) return "image";
        if (v2 instanceof InputMonth) return "month";
        if (v2 instanceof InputNumber) return "number";
        if (v2 instanceof InputPassword) return "password";
        if (v2 instanceof InputRadio) return "radio";
        if (v2 instanceof InputRange) return "range";
        if (v2 instanceof InputReset) return "reset";
        if (v2 instanceof InputSearch) return "search";
        if (v2 instanceof InputSubmit) return "submit";
        if (v2 instanceof InputTel) return "tel";
        if (v2 instanceof InputText) return "text";
        if (v2 instanceof InputTime) return "time";
        if (v2 instanceof InputUrl) return "url";
        if (v2 instanceof InputWeek) return "week";
        throw new Error("Failed pattern match at DOM.HTML.Indexed.InputType (line 33, column 19 - line 55, column 22): " + [
            v2.constructor.name
        ]);
    };
    // output/Halogen.Query.Input/index.js
    var RefUpdate = /* @__PURE__ */ function() {
        function RefUpdate2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        RefUpdate2.create = function(value0) {
            return function(value1) {
                return new RefUpdate2(value0, value1);
            };
        };
        return RefUpdate2;
    }();
    var Action = /* @__PURE__ */ function() {
        function Action3(value0) {
            this.value0 = value0;
        }
        Action3.create = function(value0) {
            return new Action3(value0);
        };
        return Action3;
    }();
    // output/Halogen.VDom.Machine/index.js
    var Step = /* @__PURE__ */ function() {
        function Step3(value0, value1, value22, value32) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
            this.value3 = value32;
        }
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
    }();
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
    var map15 = /* @__PURE__ */ map(functorArray);
    var map16 = /* @__PURE__ */ map(functorTuple);
    var Text = /* @__PURE__ */ function() {
        function Text2(value0) {
            this.value0 = value0;
        }
        Text2.create = function(value0) {
            return new Text2(value0);
        };
        return Text2;
    }();
    var Elem = /* @__PURE__ */ function() {
        function Elem2(value0, value1, value22, value32) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
            this.value3 = value32;
        }
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
    }();
    var Keyed = /* @__PURE__ */ function() {
        function Keyed2(value0, value1, value22, value32) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
            this.value3 = value32;
        }
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
    }();
    var Widget = /* @__PURE__ */ function() {
        function Widget2(value0) {
            this.value0 = value0;
        }
        Widget2.create = function(value0) {
            return new Widget2(value0);
        };
        return Widget2;
    }();
    var Grafted = /* @__PURE__ */ function() {
        function Grafted2(value0) {
            this.value0 = value0;
        }
        Grafted2.create = function(value0) {
            return new Grafted2(value0);
        };
        return Grafted2;
    }();
    var Graft = /* @__PURE__ */ function() {
        function Graft2(value0, value1, value22) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
        }
        Graft2.create = function(value0) {
            return function(value1) {
                return function(value22) {
                    return new Graft2(value0, value1, value22);
                };
            };
        };
        return Graft2;
    }();
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
            if (v22 instanceof Text) return new Text(v22.value0);
            if (v22 instanceof Elem) return new Elem(v22.value0, v22.value1, v2.value0(v22.value2), map15(go2)(v22.value3));
            if (v22 instanceof Keyed) return new Keyed(v22.value0, v22.value1, v2.value0(v22.value2), map15(map16(go2))(v22.value3));
            if (v22 instanceof Widget) return new Widget(v2.value1(v22.value0));
            if (v22 instanceof Grafted) return new Grafted(bimap2(v2.value0)(v2.value1)(v22.value0));
            throw new Error("Failed pattern match at Halogen.VDom.Types (line 86, column 7 - line 86, column 27): " + [
                v22.constructor.name
            ]);
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
        for(var i2 = 0; i2 < a3.length; i2++)b2.push(f(i2, a3[i2]));
        return b2;
    }
    function forEachE(a3, f) {
        for(var i2 = 0; i2 < a3.length; i2++)f(a3[i2]);
    }
    function forInE(o, f) {
        var ks = Object.keys(o);
        for(var i2 = 0; i2 < ks.length; i2++){
            var k = ks[i2];
            f(k, o[k]);
        }
    }
    function diffWithIxE(a1, a22, f1, f2, f3) {
        var a3 = [];
        var l1 = a1.length;
        var l2 = a22.length;
        var i2 = 0;
        while(true){
            if (i2 < l1) {
                if (i2 < l2) a3.push(f1(i2, a1[i2], a22[i2]));
                else f2(i2, a1[i2]);
            } else if (i2 < l2) a3.push(f3(i2, a22[i2]));
            else break;
            i2++;
        }
        return a3;
    }
    function strMapWithIxE(as, fk, f) {
        var o = {};
        for(var i2 = 0; i2 < as.length; i2++){
            var a3 = as[i2];
            var k = fk(a3);
            o[k] = f(k, i2, a3);
        }
        return o;
    }
    function diffWithKeyAndIxE(o1, as, fk, f1, f2, f3) {
        var o2 = {};
        for(var i2 = 0; i2 < as.length; i2++){
            var a3 = as[i2];
            var k = fk(a3);
            if (o1.hasOwnProperty(k)) o2[k] = f1(k, i2, o1[k], a3);
            else o2[k] = f3(k, i2, a3);
        }
        for(var k in o1){
            if (k in o2) continue;
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
        if (ns != null) return doc.createElementNS(ns, name16);
        else return doc.createElement(name16);
    }
    function insertChildIx(i2, a3, b2) {
        var n = b2.childNodes.item(i2) || null;
        if (n !== a3) b2.insertBefore(a3, n);
    }
    function removeChild(a3, b2) {
        if (b2 && a3.parentNode === b2) b2.removeChild(a3);
    }
    function parentNode(a3) {
        return a3.parentNode;
    }
    function setAttribute(ns, attr3, val, el) {
        if (ns != null) el.setAttributeNS(ns, attr3, val);
        else el.setAttribute(attr3, val);
    }
    function removeAttribute(ns, attr3, el) {
        if (ns != null) el.removeAttributeNS(ns, attr3);
        else el.removeAttribute(attr3);
    }
    function hasAttribute(ns, attr3, el) {
        if (ns != null) return el.hasAttributeNS(ns, attr3);
        else return el.hasAttribute(attr3);
    }
    function addEventListener(ev, listener, el) {
        el.addEventListener(ev, listener, false);
    }
    function removeEventListener(ev, listener, el) {
        el.removeEventListener(ev, listener, false);
    }
    var jsUndefined = void 0;
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
    var map17 = /* @__PURE__ */ map(functorEffect);
    var querySelector = function(qs) {
        var $2 = map17(toMaybe);
        var $3 = _querySelector(qs);
        return function($4) {
            return $2($3($4));
        };
    };
    // output/Web.DOM.Element/index.js
    var toNode = unsafeCoerce2;
    // output/Halogen.VDom.DOM/index.js
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
    var haltWidget = function(v2) {
        return halt(v2.widget);
    };
    var $lazy_patchWidget = /* @__PURE__ */ $runtime_lazy5("patchWidget", "Halogen.VDom.DOM", function() {
        return function(state3, vdom) {
            if (vdom instanceof Grafted) return $lazy_patchWidget(291)(state3, runGraft(vdom.value0));
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
            haltWidget(state3);
            return state3.build(vdom);
        };
    });
    var patchWidget = /* @__PURE__ */ $lazy_patchWidget(286);
    var haltText = function(v2) {
        var parent2 = parentNode(v2.node);
        return removeChild(v2.node, parent2);
    };
    var $lazy_patchText = /* @__PURE__ */ $runtime_lazy5("patchText", "Halogen.VDom.DOM", function() {
        return function(state3, vdom) {
            if (vdom instanceof Grafted) return $lazy_patchText(82)(state3, runGraft(vdom.value0));
            if (vdom instanceof Text) {
                if (state3.value === vdom.value0) return mkStep(new Step(state3.node, state3, $lazy_patchText(85), haltText));
                if (otherwise) {
                    var nextState = {
                        build: state3.build,
                        node: state3.node,
                        value: vdom.value0
                    };
                    setTextContent(vdom.value0, state3.node);
                    return mkStep(new Step(state3.node, nextState, $lazy_patchText(89), haltText));
                }
            }
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
            if (ns1 instanceof Just && ns2 instanceof Just && ns1.value0 === ns2.value0) return true;
            if (ns1 instanceof Nothing && ns2 instanceof Nothing) return true;
            return false;
        }
        return false;
    };
    var $lazy_patchElem = /* @__PURE__ */ $runtime_lazy5("patchElem", "Halogen.VDom.DOM", function() {
        return function(state3, vdom) {
            if (vdom instanceof Grafted) return $lazy_patchElem(135)(state3, runGraft(vdom.value0));
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
            haltElem(state3);
            return state3.build(vdom);
        };
    });
    var patchElem = /* @__PURE__ */ $lazy_patchElem(130);
    var $lazy_patchKeyed = /* @__PURE__ */ $runtime_lazy5("patchKeyed", "Halogen.VDom.DOM", function() {
        return function(state3, vdom) {
            if (vdom instanceof Grafted) return $lazy_patchKeyed(222)(state3, runGraft(vdom.value0));
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
        var $lazy_build = $runtime_lazy5("build", "Halogen.VDom.DOM", function() {
            return function(v2) {
                if (v2 instanceof Text) return buildText(spec, $lazy_build(59), v2.value0);
                if (v2 instanceof Elem) return buildElem(spec, $lazy_build(60), v2.value0, v2.value1, v2.value2, v2.value3);
                if (v2 instanceof Keyed) return buildKeyed(spec, $lazy_build(61), v2.value0, v2.value1, v2.value2, v2.value3);
                if (v2 instanceof Widget) return buildWidget(spec, $lazy_build(62), v2.value0);
                if (v2 instanceof Grafted) return $lazy_build(63)(runGraft(v2.value0));
                throw new Error("Failed pattern match at Halogen.VDom.DOM (line 58, column 27 - line 63, column 52): " + [
                    v2.constructor.name
                ]);
            };
        });
        var build = $lazy_build(58);
        return build;
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
    var Created = /* @__PURE__ */ function() {
        function Created2(value0) {
            this.value0 = value0;
        }
        Created2.create = function(value0) {
            return new Created2(value0);
        };
        return Created2;
    }();
    var Removed = /* @__PURE__ */ function() {
        function Removed2(value0) {
            this.value0 = value0;
        }
        Removed2.create = function(value0) {
            return new Removed2(value0);
        };
        return Removed2;
    }();
    var Attribute = /* @__PURE__ */ function() {
        function Attribute2(value0, value1, value22) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
        }
        Attribute2.create = function(value0) {
            return function(value1) {
                return function(value22) {
                    return new Attribute2(value0, value1, value22);
                };
            };
        };
        return Attribute2;
    }();
    var Property = /* @__PURE__ */ function() {
        function Property2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Property2.create = function(value0) {
            return function(value1) {
                return new Property2(value0, value1);
            };
        };
        return Property2;
    }();
    var Handler = /* @__PURE__ */ function() {
        function Handler2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Handler2.create = function(value0) {
            return function(value1) {
                return new Handler2(value0, value1);
            };
        };
        return Handler2;
    }();
    var Ref = /* @__PURE__ */ function() {
        function Ref2(value0) {
            this.value0 = value0;
        }
        Ref2.create = function(value0) {
            return new Ref2(value0);
        };
        return Ref2;
    }();
    var unsafeGetProperty = unsafeGetAny;
    var setProperty = unsafeSetAny;
    var removeProperty = function(key2, el) {
        var v2 = hasAttribute(nullImpl, key2, el);
        if (v2) return removeAttribute(nullImpl, key2, el);
        var v1 = typeOf(unsafeGetAny(key2, el));
        if (v1 === "string") return unsafeSetAny(key2, "", el);
        if (key2 === "rowSpan") return unsafeSetAny(key2, 1, el);
        if (key2 === "colSpan") return unsafeSetAny(key2, 1, el);
        return unsafeSetAny(key2, jsUndefined, el);
    };
    var propToStrKey = function(v2) {
        if (v2 instanceof Attribute && v2.value0 instanceof Just) return "attr/" + (v2.value0.value0 + (":" + v2.value1));
        if (v2 instanceof Attribute) return "attr/:" + v2.value1;
        if (v2 instanceof Property) return "prop/" + v2.value0;
        if (v2 instanceof Handler) return "handler/" + v2.value0;
        if (v2 instanceof Ref) return "ref";
        throw new Error("Failed pattern match at Halogen.VDom.DOM.Prop (line 182, column 16 - line 187, column 16): " + [
            v2.constructor.name
        ]);
    };
    var propFromString = unsafeCoerce2;
    var propFromInt = unsafeCoerce2;
    var propFromBoolean = unsafeCoerce2;
    var buildProp = function(emit) {
        return function(el) {
            var removeProp = function(prevEvents) {
                return function(v2, v1) {
                    if (v1 instanceof Attribute) return removeAttribute(toNullable(v1.value0), v1.value1, el);
                    if (v1 instanceof Property) return removeProperty(v1.value0, el);
                    if (v1 instanceof Handler) {
                        var handler3 = unsafeLookup(v1.value0, prevEvents);
                        return removeEventListener(v1.value0, fst(handler3), el);
                    }
                    if (v1 instanceof Ref) return unit;
                    throw new Error("Failed pattern match at Halogen.VDom.DOM.Prop (line 169, column 5 - line 179, column 18): " + [
                        v1.constructor.name
                    ]);
                };
            };
            var mbEmit = function(v2) {
                if (v2 instanceof Just) return emit(v2.value0)();
                return unit;
            };
            var haltProp = function(state3) {
                var v2 = lookup("ref")(state3.props);
                if (v2 instanceof Just && v2.value0 instanceof Ref) return mbEmit(v2.value0.value0(new Removed(el)));
                return unit;
            };
            var diffProp = function(prevEvents, events) {
                return function(v2, v1, v11, v22) {
                    if (v11 instanceof Attribute && v22 instanceof Attribute) {
                        var $66 = v11.value2 === v22.value2;
                        if ($66) return v22;
                        setAttribute(toNullable(v22.value0), v22.value1, v22.value2, el);
                        return v22;
                    }
                    if (v11 instanceof Property && v22 instanceof Property) {
                        var v4 = refEq2(v11.value1, v22.value1);
                        if (v4) return v22;
                        if (v22.value0 === "value") {
                            var elVal = unsafeGetProperty("value", el);
                            var $75 = refEq2(elVal, v22.value1);
                            if ($75) return v22;
                            setProperty(v22.value0, v22.value1, el);
                            return v22;
                        }
                        setProperty(v22.value0, v22.value1, el);
                        return v22;
                    }
                    if (v11 instanceof Handler && v22 instanceof Handler) {
                        var handler3 = unsafeLookup(v22.value0, prevEvents);
                        write(v22.value1)(snd(handler3))();
                        pokeMutMap(v22.value0, handler3, events);
                        return v22;
                    }
                    return v22;
                };
            };
            var applyProp = function(events) {
                return function(v2, v1, v22) {
                    if (v22 instanceof Attribute) {
                        setAttribute(toNullable(v22.value0), v22.value1, v22.value2, el);
                        return v22;
                    }
                    if (v22 instanceof Property) {
                        setProperty(v22.value0, v22.value1, el);
                        return v22;
                    }
                    if (v22 instanceof Handler) {
                        var v3 = unsafeGetAny(v22.value0, events);
                        if (unsafeHasAny(v22.value0, events)) {
                            write(v22.value1)(snd(v3))();
                            return v22;
                        }
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
                    if (v22 instanceof Ref) {
                        mbEmit(v22.value0(new Created(el)));
                        return v22;
                    }
                    throw new Error("Failed pattern match at Halogen.VDom.DOM.Prop (line 113, column 5 - line 135, column 15): " + [
                        v22.constructor.name
                    ]);
                };
            };
            var $lazy_patchProp = $runtime_lazy6("patchProp", "Halogen.VDom.DOM.Prop", function() {
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
    var isPropBoolean = {
        toPropValue: propFromBoolean
    };
    var handler = /* @__PURE__ */ function() {
        return Handler.create;
    }();
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
    // output/Control.Applicative.Free/index.js
    var identity9 = /* @__PURE__ */ identity(categoryFn);
    var Pure = /* @__PURE__ */ function() {
        function Pure2(value0) {
            this.value0 = value0;
        }
        Pure2.create = function(value0) {
            return new Pure2(value0);
        };
        return Pure2;
    }();
    var Lift = /* @__PURE__ */ function() {
        function Lift3(value0) {
            this.value0 = value0;
        }
        Lift3.create = function(value0) {
            return new Lift3(value0);
        };
        return Lift3;
    }();
    var Ap = /* @__PURE__ */ function() {
        function Ap2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Ap2.create = function(value0) {
            return function(value1) {
                return new Ap2(value0, value1);
            };
        };
        return Ap2;
    }();
    var mkAp = function(fba) {
        return function(fb) {
            return new Ap(fba, fb);
        };
    };
    var liftFreeAp = /* @__PURE__ */ function() {
        return Lift.create;
    }();
    var goLeft = function(dictApplicative) {
        var pure24 = pure(dictApplicative);
        return function(fStack) {
            return function(valStack) {
                return function(nat) {
                    return function(func) {
                        return function(count) {
                            if (func instanceof Pure) return new Tuple(new Cons({
                                func: pure24(func.value0),
                                count
                            }, fStack), valStack);
                            if (func instanceof Lift) return new Tuple(new Cons({
                                func: nat(func.value0),
                                count
                            }, fStack), valStack);
                            if (func instanceof Ap) return goLeft(dictApplicative)(fStack)(cons(func.value1)(valStack))(nat)(func.value0)(count + 1 | 0);
                            throw new Error("Failed pattern match at Control.Applicative.Free (line 102, column 41 - line 105, column 81): " + [
                                func.constructor.name
                            ]);
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
                    if (fStack instanceof Nil) return new Left(gVal);
                    if (fStack instanceof Cons) {
                        var gRes = apply3(fStack.value0.func)(gVal);
                        var $31 = fStack.value0.count === 1;
                        if ($31) {
                            if (fStack.value1 instanceof Nil) return new Left(gRes);
                            return goApply(dictApplicative)(fStack.value1)(vals)(gRes);
                        }
                        if (vals instanceof Nil) return new Left(gRes);
                        if (vals instanceof Cons) return new Right(new Tuple(new Cons({
                            func: gRes,
                            count: fStack.value0.count - 1 | 0
                        }, fStack.value1), new NonEmpty(vals.value0, vals.value1)));
                        throw new Error("Failed pattern match at Control.Applicative.Free (line 83, column 11 - line 88, column 50): " + [
                            vals.constructor.name
                        ]);
                    }
                    throw new Error("Failed pattern match at Control.Applicative.Free (line 72, column 3 - line 88, column 50): " + [
                        fStack.constructor.name
                    ]);
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
        var pure24 = pure(dictApplicative);
        var goLeft1 = goLeft(dictApplicative);
        return function(nat) {
            return function(z2) {
                var go2 = function($copy_v) {
                    var $tco_done = false;
                    var $tco_result;
                    function $tco_loop(v2) {
                        if (v2.value1.value0 instanceof Pure) {
                            var v1 = goApply1(v2.value0)(v2.value1.value1)(pure24(v2.value1.value0.value0));
                            if (v1 instanceof Left) {
                                $tco_done = true;
                                return v1.value0;
                            }
                            if (v1 instanceof Right) {
                                $copy_v = v1.value0;
                                return;
                            }
                            throw new Error("Failed pattern match at Control.Applicative.Free (line 54, column 17 - line 56, column 24): " + [
                                v1.constructor.name
                            ]);
                        }
                        if (v2.value1.value0 instanceof Lift) {
                            var v1 = goApply1(v2.value0)(v2.value1.value1)(nat(v2.value1.value0.value0));
                            if (v1 instanceof Left) {
                                $tco_done = true;
                                return v1.value0;
                            }
                            if (v1 instanceof Right) {
                                $copy_v = v1.value0;
                                return;
                            }
                            throw new Error("Failed pattern match at Control.Applicative.Free (line 57, column 17 - line 59, column 24): " + [
                                v1.constructor.name
                            ]);
                        }
                        if (v2.value1.value0 instanceof Ap) {
                            var nextVals = new NonEmpty(v2.value1.value0.value1, v2.value1.value1);
                            $copy_v = goLeft1(v2.value0)(nextVals)(nat)(v2.value1.value0.value0)(1);
                            return;
                        }
                        throw new Error("Failed pattern match at Control.Applicative.Free (line 53, column 5 - line 62, column 47): " + [
                            v2.value1.value0.constructor.name
                        ]);
                    }
                    while(!$tco_done)$tco_result = $tco_loop($copy_v);
                    return $tco_result;
                };
                return go2(new Tuple(Nil.value, singleton5(z2)));
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
    var applicativeFreeAp = /* @__PURE__ */ function() {
        return {
            pure: Pure.create,
            Apply0: function() {
                return applyFreeAp;
            }
        };
    }();
    var foldFreeAp1 = /* @__PURE__ */ foldFreeAp(applicativeFreeAp);
    var hoistFreeAp = function(f) {
        return foldFreeAp1(function($54) {
            return liftFreeAp(f($54));
        });
    };
    // output/Data.CatQueue/index.js
    var CatQueue = /* @__PURE__ */ function() {
        function CatQueue2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        CatQueue2.create = function(value0) {
            return function(value1) {
                return new CatQueue2(value0, value1);
            };
        };
        return CatQueue2;
    }();
    var uncons4 = function($copy_v) {
        var $tco_done = false;
        var $tco_result;
        function $tco_loop(v2) {
            if (v2.value0 instanceof Nil && v2.value1 instanceof Nil) {
                $tco_done = true;
                return Nothing.value;
            }
            if (v2.value0 instanceof Nil) {
                $copy_v = new CatQueue(reverse2(v2.value1), Nil.value);
                return;
            }
            if (v2.value0 instanceof Cons) {
                $tco_done = true;
                return new Just(new Tuple(v2.value0.value0, new CatQueue(v2.value0.value1, v2.value1)));
            }
            throw new Error("Failed pattern match at Data.CatQueue (line 82, column 1 - line 82, column 63): " + [
                v2.constructor.name
            ]);
        }
        while(!$tco_done)$tco_result = $tco_loop($copy_v);
        return $tco_result;
    };
    var snoc3 = function(v2) {
        return function(a3) {
            return new CatQueue(v2.value0, new Cons(a3, v2.value1));
        };
    };
    var $$null2 = function(v2) {
        if (v2.value0 instanceof Nil && v2.value1 instanceof Nil) return true;
        return false;
    };
    var empty5 = /* @__PURE__ */ function() {
        return new CatQueue(Nil.value, Nil.value);
    }();
    // output/Data.CatList/index.js
    var CatNil = /* @__PURE__ */ function() {
        function CatNil2() {}
        CatNil2.value = new CatNil2();
        return CatNil2;
    }();
    var CatCons = /* @__PURE__ */ function() {
        function CatCons2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        CatCons2.create = function(value0) {
            return function(value1) {
                return new CatCons2(value0, value1);
            };
        };
        return CatCons2;
    }();
    var link = function(v2) {
        return function(v1) {
            if (v2 instanceof CatNil) return v1;
            if (v1 instanceof CatNil) return v2;
            if (v2 instanceof CatCons) return new CatCons(v2.value0, snoc3(v2.value1)(v1));
            throw new Error("Failed pattern match at Data.CatList (line 108, column 1 - line 108, column 54): " + [
                v2.constructor.name,
                v1.constructor.name
            ]);
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
                                if (v22 instanceof Cons) {
                                    $tco_var_v = v2;
                                    $tco_var_v1 = v2(v1)(v22.value0);
                                    $copy_v2 = v22.value1;
                                    return;
                                }
                                throw new Error("Failed pattern match at Data.CatList (line 124, column 3 - line 124, column 59): " + [
                                    v2.constructor.name,
                                    v1.constructor.name,
                                    v22.constructor.name
                                ]);
                            }
                            while(!$tco_done)$tco_result = $tco_loop($tco_var_v, $tco_var_v1, $copy_v2);
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
                            if (v2 instanceof Just) {
                                $tco_var_xs = v2.value0.value1;
                                $copy_ys = new Cons(k(v2.value0.value0), ys);
                                return;
                            }
                            throw new Error("Failed pattern match at Data.CatList (line 120, column 14 - line 122, column 67): " + [
                                v2.constructor.name
                            ]);
                        }
                        while(!$tco_done1)$tco_result = $tco_loop($tco_var_xs, $copy_ys);
                        return $tco_result;
                    };
                };
                return go2(q3)(Nil.value);
            };
        };
    };
    var uncons5 = function(v2) {
        if (v2 instanceof CatNil) return Nothing.value;
        if (v2 instanceof CatCons) return new Just(new Tuple(v2.value0, function() {
            var $66 = $$null2(v2.value1);
            if ($66) return CatNil.value;
            return foldr4(link)(CatNil.value)(v2.value1);
        }()));
        throw new Error("Failed pattern match at Data.CatList (line 99, column 1 - line 99, column 61): " + [
            v2.constructor.name
        ]);
    };
    var empty6 = /* @__PURE__ */ function() {
        return CatNil.value;
    }();
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
    var append3 = /* @__PURE__ */ append(semigroupCatList);
    var Free = /* @__PURE__ */ function() {
        function Free2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Free2.create = function(value0) {
            return function(value1) {
                return new Free2(value0, value1);
            };
        };
        return Free2;
    }();
    var Return = /* @__PURE__ */ function() {
        function Return2(value0) {
            this.value0 = value0;
        }
        Return2.create = function(value0) {
            return new Return2(value0);
        };
        return Return2;
    }();
    var Bind = /* @__PURE__ */ function() {
        function Bind2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Bind2.create = function(value0) {
            return function(value1) {
                return new Bind2(value0, value1);
            };
        };
        return Bind2;
    }();
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
                if (v22 instanceof Just) {
                    $copy_v = concatF(runExpF(v22.value0.value0)(v2.value0.value0))(v22.value0.value1);
                    return;
                }
                throw new Error("Failed pattern match at Control.Monad.Free (line 227, column 7 - line 231, column 64): " + [
                    v22.constructor.name
                ]);
            }
            if (v2.value0 instanceof Bind) {
                $tco_done = true;
                return new Bind(v2.value0.value0, function(a3) {
                    return concatF(v2.value0.value1(a3))(v2.value1);
                });
            }
            throw new Error("Failed pattern match at Control.Monad.Free (line 225, column 3 - line 233, column 56): " + [
                v2.value0.constructor.name
            ]);
        }
        while(!$tco_done)$tco_result = $tco_loop($copy_v);
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
                return bindFlipped(freeBind)(function() {
                    var $189 = pure(freeApplicative);
                    return function($190) {
                        return $189(k($190));
                    };
                }())(f);
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
    var $lazy_freeApply = /* @__PURE__ */ $runtime_lazy7("freeApply", "Control.Monad.Free", function() {
        return {
            apply: ap(freeMonad),
            Functor0: function() {
                return freeFunctor;
            }
        };
    });
    var pure7 = /* @__PURE__ */ pure(freeApplicative);
    var liftF = function(f) {
        return fromView(new Bind(f, function($192) {
            return pure7($192);
        }));
    };
    var foldFree = function(dictMonadRec) {
        var Monad0 = dictMonadRec.Monad0();
        var map111 = map(Monad0.Bind1().Apply0().Functor0());
        var pure111 = pure(Monad0.Applicative0());
        var tailRecM4 = tailRecM(dictMonadRec);
        return function(k) {
            var go2 = function(f) {
                var v2 = toView(f);
                if (v2 instanceof Return) return map111(Done.create)(pure111(v2.value0));
                if (v2 instanceof Bind) return map111(function($199) {
                    return Loop.create(v2.value1($199));
                })(k(v2.value0));
                throw new Error("Failed pattern match at Control.Monad.Free (line 158, column 10 - line 160, column 37): " + [
                    v2.constructor.name
                ]);
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
    var $$void5 = /* @__PURE__ */ $$void(functorEffect);
    var bind4 = /* @__PURE__ */ bind(bindEffect);
    var append4 = /* @__PURE__ */ append(semigroupArray);
    var traverse_2 = /* @__PURE__ */ traverse_(applicativeEffect);
    var traverse_1 = /* @__PURE__ */ traverse_2(foldableArray);
    var unsubscribe = function(v2) {
        return v2;
    };
    var subscribe = function(v2) {
        return function(k) {
            return v2(function($76) {
                return $$void5(k($76));
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
                        return append4(v2)([
                            k
                        ]);
                    })(subscribers)();
                    return modify_(deleteBy(unsafeRefEq)(k))(subscribers);
                };
            },
            listener: function(a3) {
                return bind4(read(subscribers))(traverse_1(function(k) {
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
    var State = /* @__PURE__ */ function() {
        function State2(value0) {
            this.value0 = value0;
        }
        State2.create = function(value0) {
            return new State2(value0);
        };
        return State2;
    }();
    var Subscribe = /* @__PURE__ */ function() {
        function Subscribe2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Subscribe2.create = function(value0) {
            return function(value1) {
                return new Subscribe2(value0, value1);
            };
        };
        return Subscribe2;
    }();
    var Unsubscribe = /* @__PURE__ */ function() {
        function Unsubscribe2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Unsubscribe2.create = function(value0) {
            return function(value1) {
                return new Unsubscribe2(value0, value1);
            };
        };
        return Unsubscribe2;
    }();
    var Lift2 = /* @__PURE__ */ function() {
        function Lift3(value0) {
            this.value0 = value0;
        }
        Lift3.create = function(value0) {
            return new Lift3(value0);
        };
        return Lift3;
    }();
    var ChildQuery2 = /* @__PURE__ */ function() {
        function ChildQuery3(value0) {
            this.value0 = value0;
        }
        ChildQuery3.create = function(value0) {
            return new ChildQuery3(value0);
        };
        return ChildQuery3;
    }();
    var Raise = /* @__PURE__ */ function() {
        function Raise2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Raise2.create = function(value0) {
            return function(value1) {
                return new Raise2(value0, value1);
            };
        };
        return Raise2;
    }();
    var Par = /* @__PURE__ */ function() {
        function Par2(value0) {
            this.value0 = value0;
        }
        Par2.create = function(value0) {
            return new Par2(value0);
        };
        return Par2;
    }();
    var Fork = /* @__PURE__ */ function() {
        function Fork2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Fork2.create = function(value0) {
            return function(value1) {
                return new Fork2(value0, value1);
            };
        };
        return Fork2;
    }();
    var Join = /* @__PURE__ */ function() {
        function Join2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Join2.create = function(value0) {
            return function(value1) {
                return new Join2(value0, value1);
            };
        };
        return Join2;
    }();
    var Kill = /* @__PURE__ */ function() {
        function Kill2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Kill2.create = function(value0) {
            return function(value1) {
                return new Kill2(value0, value1);
            };
        };
        return Kill2;
    }();
    var GetRef = /* @__PURE__ */ function() {
        function GetRef2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        GetRef2.create = function(value0) {
            return function(value1) {
                return new GetRef2(value0, value1);
            };
        };
        return GetRef2;
    }();
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
            liftEffect: function() {
                var $186 = liftEffect(dictMonadEffect);
                return function($187) {
                    return HalogenM(liftF(Lift2.create($186($187))));
                };
            }(),
            Monad0: function() {
                return monadHalogenM;
            }
        };
    };
    var monadAffHalogenM = function(dictMonadAff) {
        var monadEffectHalogenM1 = monadEffectHalogenM(dictMonadAff.MonadEffect0());
        return {
            liftAff: function() {
                var $188 = liftAff(dictMonadAff);
                return function($189) {
                    return HalogenM(liftF(Lift2.create($188($189))));
                };
            }(),
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
    var Initialize = /* @__PURE__ */ function() {
        function Initialize6(value0) {
            this.value0 = value0;
        }
        Initialize6.create = function(value0) {
            return new Initialize6(value0);
        };
        return Initialize6;
    }();
    var Finalize = /* @__PURE__ */ function() {
        function Finalize3(value0) {
            this.value0 = value0;
        }
        Finalize3.create = function(value0) {
            return new Finalize3(value0);
        };
        return Finalize3;
    }();
    var Receive = /* @__PURE__ */ function() {
        function Receive2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Receive2.create = function(value0) {
            return function(value1) {
                return new Receive2(value0, value1);
            };
        };
        return Receive2;
    }();
    var Action2 = /* @__PURE__ */ function() {
        function Action3(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Action3.create = function(value0) {
            return function(value1) {
                return new Action3(value0, value1);
            };
        };
        return Action3;
    }();
    var Query = /* @__PURE__ */ function() {
        function Query2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        Query2.create = function(value0) {
            return function(value1) {
                return new Query2(value0, value1);
            };
        };
        return Query2;
    }();
    // output/Halogen.VDom.Thunk/index.js
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
    var unsafeEqThunk = function(v2, v1) {
        return refEq2(v2.value0, v1.value0) && refEq2(v2.value1, v1.value1) && v2.value1(v2.value3, v1.value3);
    };
    var runThunk = function(v2) {
        return v2.value2(v2.value3);
    };
    var buildThunk = function(toVDom) {
        var haltThunk = function(state3) {
            return halt(state3.vdom);
        };
        var $lazy_patchThunk = $runtime_lazy8("patchThunk", "Halogen.VDom.Thunk", function() {
            return function(state3, t2) {
                var $48 = unsafeEqThunk(state3.thunk, t2);
                if ($48) return mkStep(new Step(extract2(state3.vdom), state3, $lazy_patchThunk(112), haltThunk));
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
    var map18 = /* @__PURE__ */ map(functorHalogenM);
    var pure8 = /* @__PURE__ */ pure(applicativeHalogenM);
    var lookup4 = /* @__PURE__ */ lookup3();
    var pop3 = /* @__PURE__ */ pop2();
    var insert6 = /* @__PURE__ */ insert5();
    var ComponentSlot = /* @__PURE__ */ function() {
        function ComponentSlot2(value0) {
            this.value0 = value0;
        }
        ComponentSlot2.create = function(value0) {
            return new ComponentSlot2(value0);
        };
        return ComponentSlot2;
    }();
    var ThunkSlot = /* @__PURE__ */ function() {
        function ThunkSlot2(value0) {
            this.value0 = value0;
        }
        ThunkSlot2.create = function(value0) {
            return new ThunkSlot2(value0);
        };
        return ThunkSlot2;
    }();
    var unComponentSlot = unsafeCoerce2;
    var unComponent = unsafeCoerce2;
    var mkEval = function(args) {
        return function(v2) {
            if (v2 instanceof Initialize) return voidLeft2(traverse_3(args.handleAction)(args.initialize))(v2.value0);
            if (v2 instanceof Finalize) return voidLeft2(traverse_3(args.handleAction)(args.finalize))(v2.value0);
            if (v2 instanceof Receive) return voidLeft2(traverse_3(args.handleAction)(args.receive(v2.value0)))(v2.value1);
            if (v2 instanceof Action2) return voidLeft2(args.handleAction(v2.value0))(v2.value1);
            if (v2 instanceof Query) return unCoyoneda(function(g) {
                var $45 = map18(maybe(v2.value1(unit))(g));
                return function($46) {
                    return $45(args.handleQuery($46));
                };
            })(v2.value0);
            throw new Error("Failed pattern match at Halogen.Component (line 182, column 15 - line 192, column 71): " + [
                v2.constructor.name
            ]);
        };
    };
    var mkComponentSlot = unsafeCoerce2;
    var mkComponent = unsafeCoerce2;
    var defaultEval = /* @__PURE__ */ function() {
        return {
            handleAction: $$const(pure8(unit)),
            handleQuery: $$const(pure8(Nothing.value)),
            receive: $$const(Nothing.value),
            initialize: Nothing.value,
            finalize: Nothing.value
        };
    }();
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
    // output/Halogen.HTML.Elements/index.js
    var pure9 = /* @__PURE__ */ pure(applicativeMaybe);
    var elementNS = function($15) {
        return element(pure9($15));
    };
    var element2 = /* @__PURE__ */ function() {
        return element(Nothing.value);
    }();
    var form = /* @__PURE__ */ element2("form");
    var h2 = /* @__PURE__ */ element2("h2");
    var h2_ = /* @__PURE__ */ h2([]);
    var h3 = /* @__PURE__ */ element2("h3");
    var h3_ = /* @__PURE__ */ h3([]);
    var input = function(props) {
        return element2("input")(props)([]);
    };
    var p = /* @__PURE__ */ element2("p");
    var p_ = /* @__PURE__ */ p([]);
    var span3 = /* @__PURE__ */ element2("span");
    var span_ = /* @__PURE__ */ span3([]);
    var style = /* @__PURE__ */ element2("style");
    var style_ = /* @__PURE__ */ style([]);
    var table = /* @__PURE__ */ element2("table");
    var tbody = /* @__PURE__ */ element2("tbody");
    var tbody_ = /* @__PURE__ */ tbody([]);
    var td = /* @__PURE__ */ element2("td");
    var td_ = /* @__PURE__ */ td([]);
    var th = /* @__PURE__ */ element2("th");
    var th_ = /* @__PURE__ */ th([]);
    var thead = /* @__PURE__ */ element2("thead");
    var thead_ = /* @__PURE__ */ thead([]);
    var tr = /* @__PURE__ */ element2("tr");
    var tr_ = /* @__PURE__ */ tr([]);
    var div3 = /* @__PURE__ */ element2("div");
    var div_ = /* @__PURE__ */ div3([]);
    var button = /* @__PURE__ */ element2("button");
    // output/Foreign.Index/foreign.js
    function unsafeReadPropImpl(f, s2, key2, value16) {
        return value16 == null ? f : s2(value16[key2]);
    }
    // output/Foreign.Index/index.js
    var unsafeReadProp = function(dictMonad) {
        var fail3 = fail(dictMonad);
        var pure24 = pure(applicativeExceptT(dictMonad));
        return function(k) {
            return function(value16) {
                return unsafeReadPropImpl(fail3(new TypeMismatch("object", typeOf(value16))), pure24, k, value16);
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
    var map19 = /* @__PURE__ */ map(functorMaybe);
    var composeKleisli2 = /* @__PURE__ */ composeKleisli(bindMaybe);
    var composeKleisliFlipped4 = /* @__PURE__ */ composeKleisliFlipped(/* @__PURE__ */ bindExceptT(monadIdentity));
    var readProp2 = /* @__PURE__ */ readProp(monadIdentity);
    var readString2 = /* @__PURE__ */ readString(monadIdentity);
    var mouseHandler = unsafeCoerce2;
    var keyHandler = unsafeCoerce2;
    var handler$prime = function(et) {
        return function(f) {
            return handler(et)(function(ev) {
                return map19(Action.create)(f(ev));
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
    var onClick = /* @__PURE__ */ function() {
        var $15 = handler2(click);
        return function($16) {
            return $15(mouseHandler($16));
        };
    }();
    var onKeyDown = /* @__PURE__ */ function() {
        var $23 = handler2(keydown);
        return function($24) {
            return $23(keyHandler($24));
        };
    }();
    var onScroll = /* @__PURE__ */ handler2("scroll");
    var onSubmit = /* @__PURE__ */ handler2("submit");
    var addForeignPropHandler = function(key2) {
        return function(prop4) {
            return function(reader) {
                return function(f) {
                    var go2 = function(a3) {
                        return composeKleisliFlipped4(reader)(readProp2(prop4))(unsafeToForeign(a3));
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
    var onValueInput = /* @__PURE__ */ addForeignPropHandler(input2)("value")(readString2);
    // output/Halogen.HTML.Properties/index.js
    var unwrap4 = /* @__PURE__ */ unwrap();
    var prop2 = function(dictIsProp) {
        return prop(dictIsProp);
    };
    var prop1 = /* @__PURE__ */ prop2(isPropBoolean);
    var prop22 = /* @__PURE__ */ prop2(isPropString);
    var prop3 = /* @__PURE__ */ prop2(isPropInt);
    var title = /* @__PURE__ */ prop22("title");
    var type_3 = function(dictIsProp) {
        return prop2(dictIsProp)("type");
    };
    var value3 = function(dictIsProp) {
        return prop2(dictIsProp)("value");
    };
    var placeholder2 = /* @__PURE__ */ prop22("placeholder");
    var id3 = /* @__PURE__ */ prop22("id");
    var disabled2 = /* @__PURE__ */ prop1("disabled");
    var colSpan = /* @__PURE__ */ prop3("colSpan");
    var class_ = /* @__PURE__ */ function() {
        var $36 = prop22("className");
        return function($37) {
            return $36(unwrap4($37));
        };
    }();
    var attr2 = /* @__PURE__ */ function() {
        return attr(Nothing.value);
    }();
    var style2 = /* @__PURE__ */ attr2("style");
    // output/TextConstants.BillEditor/index.js
    var weightLabel = "\u0E19\u0E49\u0E33\u0E2B\u0E19\u0E31\u0E01";
    var userNumberLabel = "\u0E40\u0E25\u0E02\u0E17\u0E35\u0E48\u0E1C\u0E39\u0E49\u0E43\u0E0A\u0E49";
    var unitTHB = "\u0E1A\u0E32\u0E17";
    var unitGrams = "\u0E01\u0E23\u0E31\u0E21";
    var unitBaht = "\u0E1A\u0E32\u0E17";
    var trayLabel = "\u0E16\u0E32\u0E14";
    var transactionLabel = "\u0E23\u0E32\u0E22\u0E01\u0E32\u0E23";
    var status = "\u0E2A\u0E16\u0E32\u0E19\u0E30";
    var shapeLabel = "\u0E23\u0E39\u0E1B\u0E41\u0E1A\u0E1A";
    var savingMessage = "\u0E01\u0E33\u0E25\u0E31\u0E07\u0E1A\u0E31\u0E19\u0E17\u0E36\u0E01...";
    var saveButton = "\u0E1A\u0E31\u0E19\u0E17\u0E36\u0E01";
    var reload = "\u0E42\u0E2B\u0E25\u0E14\u0E43\u0E2B\u0E21\u0E48";
    var quantityLabel = "\u0E08\u0E33\u0E19\u0E27\u0E19";
    var purityLabel = "\u0E04\u0E27\u0E32\u0E21\u0E1A\u0E23\u0E34\u0E2A\u0E38\u0E17\u0E18\u0E34\u0E4C";
    var priceRateLabel = "\u0E23\u0E32\u0E04\u0E32";
    var packLabel = "\u0E41\u0E1E\u0E47\u0E04";
    var packIdLabel = "\u0E40\u0E25\u0E02\u0E41\u0E1E\u0E47\u0E04";
    var nominalWeightLabel = "\u0E19\u0E49\u0E33\u0E2B\u0E19\u0E31\u0E01\u0E19\u0E32\u0E21";
    var noBillsFound = "\u0E44\u0E21\u0E48\u0E1E\u0E1A\u0E1A\u0E34\u0E25";
    var newBill = "\u0E1A\u0E34\u0E25\u0E43\u0E2B\u0E21\u0E48";
    var makingChargeLabel = "\u0E04\u0E48\u0E32\u0E17\u0E33";
    var loading = "\u0E01\u0E33\u0E25\u0E31\u0E07\u0E42\u0E2B\u0E25\u0E14...";
    var grandTotalLabel = "\u0E23\u0E27\u0E21\u0E17\u0E31\u0E49\u0E07\u0E2B\u0E21\u0E14";
    var finalized = "\u0E1B\u0E34\u0E14\u0E41\u0E25\u0E49\u0E27";
    var finalizeButton = "\u0E1B\u0E34\u0E14\u0E1A\u0E34\u0E25";
    var errorPrefix = "\u0E02\u0E49\u0E2D\u0E1C\u0E34\u0E14\u0E1E\u0E25\u0E32\u0E14: ";
    var edit = "\u0E41\u0E01\u0E49\u0E44\u0E02";
    var draft = "\u0E23\u0E48\u0E32\u0E07";
    var discountLabel = "\u0E2A\u0E48\u0E27\u0E19\u0E25\u0E14";
    var deductionRateLabel = "\u0E2D\u0E31\u0E15\u0E23\u0E32\u0E2B\u0E31\u0E01";
    var date = "\u0E27\u0E31\u0E19\u0E17\u0E35\u0E48";
    var cancelButton = "\u0E22\u0E01\u0E40\u0E25\u0E34\u0E01";
    var calculationAmountLabel = "\u0E04\u0E33\u0E19\u0E27\u0E13";
    var billsFor = "\u0E1A\u0E34\u0E25\u0E02\u0E2D\u0E07";
    var billId = "\u0E40\u0E25\u0E02\u0E1A\u0E34\u0E25";
    var billEditor = "\u0E41\u0E01\u0E49\u0E44\u0E02\u0E1A\u0E34\u0E25";
    var amountLabel = "\u0E23\u0E27\u0E21";
    var addTrayButton = "+ \u0E40\u0E1E\u0E34\u0E48\u0E21\u0E16\u0E32\u0E14";
    var addTransactionButton = "+ \u0E40\u0E1E\u0E34\u0E48\u0E21\u0E23\u0E32\u0E22\u0E01\u0E32\u0E23";
    var addPackButton = "+ \u0E40\u0E1E\u0E34\u0E48\u0E21\u0E41\u0E1E\u0E47\u0E04";
    var actualWeightLabel = "\u0E19\u0E49\u0E33\u0E2B\u0E19\u0E31\u0E01\u0E08\u0E23\u0E34\u0E07";
    var actions = "\u0E08\u0E31\u0E14\u0E01\u0E32\u0E23";
    // output/Bill.Components.BillEditor/index.js
    var show5 = /* @__PURE__ */ show(showInt);
    var bind5 = /* @__PURE__ */ bind(bindHalogenM);
    var get5 = /* @__PURE__ */ get(monadStateHalogenM);
    var lift3 = /* @__PURE__ */ lift(monadTransHalogenM);
    var modify_3 = /* @__PURE__ */ modify_2(monadStateHalogenM);
    var pure10 = /* @__PURE__ */ pure(applicativeHalogenM);
    var discard2 = /* @__PURE__ */ discard(discardUnit)(bindHalogenM);
    var map20 = /* @__PURE__ */ map(functorArray);
    var identity11 = /* @__PURE__ */ identity(categoryFn);
    var append12 = /* @__PURE__ */ append(semigroupArray);
    var BillSaved = /* @__PURE__ */ function() {
        function BillSaved2(value0) {
            this.value0 = value0;
        }
        BillSaved2.create = function(value0) {
            return new BillSaved2(value0);
        };
        return BillSaved2;
    }();
    var BillCancelled = /* @__PURE__ */ function() {
        function BillCancelled2() {}
        BillCancelled2.value = new BillCancelled2();
        return BillCancelled2;
    }();
    var BillFinalized = /* @__PURE__ */ function() {
        function BillFinalized2(value0) {
            this.value0 = value0;
        }
        BillFinalized2.create = function(value0) {
            return new BillFinalized2(value0);
        };
        return BillFinalized2;
    }();
    var Initialize2 = /* @__PURE__ */ function() {
        function Initialize6() {}
        Initialize6.value = new Initialize6();
        return Initialize6;
    }();
    var Reload = /* @__PURE__ */ function() {
        function Reload3() {}
        Reload3.value = new Reload3();
        return Reload3;
    }();
    var Save = /* @__PURE__ */ function() {
        function Save2() {}
        Save2.value = new Save2();
        return Save2;
    }();
    var Cancel = /* @__PURE__ */ function() {
        function Cancel2() {}
        Cancel2.value = new Cancel2();
        return Cancel2;
    }();
    var Finalize2 = /* @__PURE__ */ function() {
        function Finalize3() {}
        Finalize3.value = new Finalize3();
        return Finalize3;
    }();
    var AddTray = /* @__PURE__ */ function() {
        function AddTray2() {}
        AddTray2.value = new AddTray2();
        return AddTray2;
    }();
    var AddPack = /* @__PURE__ */ function() {
        function AddPack2() {}
        AddPack2.value = new AddPack2();
        return AddPack2;
    }();
    var AddTransaction = /* @__PURE__ */ function() {
        function AddTransaction2() {}
        AddTransaction2.value = new AddTransaction2();
        return AddTransaction2;
    }();
    var renderPackSettings = function(pack) {
        return table([
            class_("settings-table")
        ])([
            tbody_([
                tr_([
                    td_([
                        text(packIdLabel)
                    ]),
                    td_([
                        span3([
                            class_("num")
                        ])([
                            text(show5(pack.internal_id))
                        ])
                    ])
                ]),
                tr_([
                    td_([
                        text(userNumberLabel)
                    ]),
                    td_([
                        text(pack.user_number)
                    ])
                ])
            ])
        ]);
    };
    var renderNoBill = /* @__PURE__ */ div3([
        /* @__PURE__ */ class_("bill-editor-empty")
    ])([
        /* @__PURE__ */ text("No bill loaded")
    ]);
    var renderMoneyValue = function(str) {
        var $66 = contains(".")(str);
        if ($66) {
            var parts = split(".")(str);
            if (parts.length === 2) {
                var isZeroDecimal = parts[1] === "\u2080\u2080";
                var decClass = function() {
                    if (isZeroDecimal) return "num-subscript-hidden";
                    return "num-subscript";
                }();
                return span_([
                    span3([
                        class_("num")
                    ])([
                        text(parts[0])
                    ]),
                    text("."),
                    span3([
                        class_(decClass)
                    ])([
                        text(parts[1])
                    ])
                ]);
            }
            return text(str);
        }
        return text(str);
    };
    var renderLoading = /* @__PURE__ */ div3([
        /* @__PURE__ */ class_("bill-editor-loading")
    ])([
        /* @__PURE__ */ text(loading)
    ]);
    var renderHeader = function(state3) {
        return div3([
            class_("bill-editor-header")
        ])([
            h2_([
                text(billEditor + (" - " + state3.customerName))
            ]),
            function() {
                if (state3.bill instanceof Nothing) return text("");
                if (state3.bill instanceof Just) return div3([
                    class_("bill-info")
                ])([
                    span_([
                        text(billId + (": " + show5(state3.bill.value0.id)))
                    ]),
                    span_([
                        text(" | " + (date + (": " + state3.bill.value0.date)))
                    ]),
                    span_([
                        text(" | " + (status + (": " + function() {
                            if (state3.bill.value0.is_finalized) return finalized;
                            return draft;
                        }())))
                    ])
                ]);
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 101, column 7 - line 110, column 14): " + [
                    state3.bill.constructor.name
                ]);
            }()
        ]);
    };
    var renderGrandTotal = function(bill) {
        return div3([
            class_("grand-total")
        ])([
            h3_([
                text(grandTotalLabel)
            ]),
            p_([
                text("Calculation not yet implemented")
            ])
        ]);
    };
    var renderGoldValue = function(str) {
        var hasG = contains("g")(str);
        var hasBaht = contains("\u0E1A")(str);
        if (hasG) {
            var numPart = replace("g")("")(str);
            return span_([
                span3([
                    class_("num")
                ])([
                    text(numPart)
                ]),
                text("g")
            ]);
        }
        if (hasBaht) {
            var numPart = replace("\u0E1A")("")(str);
            return span_([
                span3([
                    class_("num")
                ])([
                    text(numPart)
                ]),
                text("\u0E1A")
            ]);
        }
        return text(str);
    };
    var renderFooter = function(state3) {
        return div3([
            class_("bill-editor-footer")
        ])([
            button([
                class_("btn btn-primary"),
                onClick(function(v2) {
                    return Save.value;
                }),
                disabled2(state3.isSaving)
            ])([
                text(function() {
                    if (state3.isSaving) return savingMessage;
                    return saveButton;
                }())
            ]),
            button([
                class_("btn btn-secondary"),
                onClick(function(v2) {
                    return Cancel.value;
                })
            ])([
                text(cancelButton)
            ]),
            function() {
                if (state3.bill instanceof Just && !state3.bill.value0.is_finalized) return button([
                    class_("btn btn-success"),
                    onClick(function(v2) {
                        return Finalize2.value;
                    })
                ])([
                    text(finalizeButton)
                ]);
                return text("");
            }()
        ]);
    };
    var renderError = function(err) {
        return div3([
            class_("bill-editor-error")
        ])([
            text(errorPrefix + err)
        ]);
    };
    var renderAddGroupButtons = /* @__PURE__ */ div3([
        /* @__PURE__ */ class_("add-group-buttons")
    ])([
        /* @__PURE__ */ button([
            /* @__PURE__ */ class_("btn btn-primary"),
            /* @__PURE__ */ onClick(function(v2) {
                return AddTray.value;
            })
        ])([
            /* @__PURE__ */ text(addTrayButton)
        ]),
        /* @__PURE__ */ button([
            /* @__PURE__ */ class_("btn btn-primary"),
            /* @__PURE__ */ onClick(function(v2) {
                return AddPack.value;
            })
        ])([
            /* @__PURE__ */ text(addPackButton)
        ]),
        /* @__PURE__ */ button([
            /* @__PURE__ */ class_("btn btn-primary"),
            /* @__PURE__ */ onClick(function(v2) {
                return AddTransaction.value;
            })
        ])([
            /* @__PURE__ */ text(addTransactionButton)
        ])
    ]);
    var parseNumber = function(str) {
        var v2 = fromString(str);
        if (v2 instanceof Just) return v2.value0;
        if (v2 instanceof Nothing) return 0;
        throw new Error("Failed pattern match at Bill.Components.BillEditor (line 255, column 19 - line 257, column 17): " + [
            v2.constructor.name
        ]);
    };
    var initialState = function(input3) {
        return {
            billId: input3.billId,
            customerId: input3.customerId,
            customerName: input3.customerName,
            bill: Nothing.value,
            groups: [],
            isLoading: false,
            isSaving: false,
            error: Nothing.value,
            isDirty: false
        };
    };
    var handleAction = function(dictMonadAff) {
        var lift1 = lift3(dictMonadAff.MonadEffect0().Monad0());
        var createBill2 = createBill(dictMonadAff);
        var getBillWithGroups2 = getBillWithGroups(dictMonadAff);
        var updateBill2 = updateBill(dictMonadAff);
        return function(v2) {
            if (v2 instanceof Initialize2) return bind5(get5)(function(state3) {
                if (state3.billId instanceof Nothing) return bind5(lift1(createBill2(state3.customerId)))(function(result) {
                    if (result instanceof Left) return modify_3(function(v1) {
                        var $84 = {};
                        for(var $85 in v1)if (({}).hasOwnProperty.call(v1, $85)) $84[$85] = v1[$85];
                        $84.error = new Just(result.value0);
                        return $84;
                    });
                    if (result instanceof Right) return modify_3(function(v1) {
                        var $88 = {};
                        for(var $89 in v1)if (({}).hasOwnProperty.call(v1, $89)) $88[$89] = v1[$89];
                        $88.bill = new Just(result.value0);
                        $88.billId = new Just(result.value0.id);
                        return $88;
                    });
                    throw new Error("Failed pattern match at Bill.Components.BillEditor (line 764, column 9 - line 768, column 68): " + [
                        result.constructor.name
                    ]);
                });
                if (state3.billId instanceof Just) return handleAction(dictMonadAff)(Reload.value);
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 760, column 5 - line 771, column 28): " + [
                    state3.billId.constructor.name
                ]);
            });
            if (v2 instanceof Reload) return bind5(get5)(function(state3) {
                if (state3.billId instanceof Nothing) return pure10(unit);
                if (state3.billId instanceof Just) return discard2(modify_3(function(v1) {
                    var $94 = {};
                    for(var $95 in v1)if (({}).hasOwnProperty.call(v1, $95)) $94[$95] = v1[$95];
                    $94.isLoading = true;
                    $94.error = Nothing.value;
                    return $94;
                }))(function() {
                    return bind5(lift1(getBillWithGroups2(state3.billId.value0)))(function(result) {
                        if (result instanceof Left) return modify_3(function(v1) {
                            var $98 = {};
                            for(var $99 in v1)if (({}).hasOwnProperty.call(v1, $99)) $98[$99] = v1[$99];
                            $98.isLoading = false;
                            $98.error = new Just(result.value0);
                            return $98;
                        });
                        if (result instanceof Right) return modify_3(function(v1) {
                            var $102 = {};
                            for(var $103 in v1)if (({}).hasOwnProperty.call(v1, $103)) $102[$103] = v1[$103];
                            $102.isLoading = false;
                            $102.bill = new Just(result.value0.bill);
                            $102.groups = result.value0.groups;
                            return $102;
                        });
                        throw new Error("Failed pattern match at Bill.Components.BillEditor (line 780, column 9 - line 784, column 81): " + [
                            result.constructor.name
                        ]);
                    });
                });
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 775, column 5 - line 784, column 81): " + [
                    state3.billId.constructor.name
                ]);
            });
            if (v2 instanceof Save) return bind5(get5)(function(state3) {
                if (state3.bill instanceof Nothing) return pure10(unit);
                if (state3.bill instanceof Just) return discard2(modify_3(function(v1) {
                    var $110 = {};
                    for(var $111 in v1)if (({}).hasOwnProperty.call(v1, $111)) $110[$111] = v1[$111];
                    $110.isSaving = true;
                    return $110;
                }))(function() {
                    return bind5(lift1(updateBill2(state3.bill.value0)))(function(result) {
                        if (result instanceof Left) return modify_3(function(v1) {
                            var $114 = {};
                            for(var $115 in v1)if (({}).hasOwnProperty.call(v1, $115)) $114[$115] = v1[$115];
                            $114.isSaving = false;
                            $114.error = new Just(result.value0);
                            return $114;
                        });
                        if (result instanceof Right) return discard2(modify_3(function(v1) {
                            var $118 = {};
                            for(var $119 in v1)if (({}).hasOwnProperty.call(v1, $119)) $118[$119] = v1[$119];
                            $118.isSaving = false;
                            $118.bill = new Just(result.value0);
                            $118.isDirty = false;
                            return $118;
                        }))(function() {
                            return raise(new BillSaved(result.value0));
                        });
                        throw new Error("Failed pattern match at Bill.Components.BillEditor (line 793, column 9 - line 798, column 44): " + [
                            result.constructor.name
                        ]);
                    });
                });
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 788, column 5 - line 798, column 44): " + [
                    state3.bill.constructor.name
                ]);
            });
            if (v2 instanceof Cancel) return raise(BillCancelled.value);
            if (v2 instanceof Finalize2) return bind5(get5)(function(state3) {
                if (state3.bill instanceof Nothing) return pure10(unit);
                if (state3.bill instanceof Just) return raise(new BillFinalized(state3.bill.value0));
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 805, column 5 - line 809, column 37): " + [
                    state3.bill.constructor.name
                ]);
            });
            if (v2 instanceof AddTray) return pure10(unit);
            if (v2 instanceof AddPack) return pure10(unit);
            if (v2 instanceof AddTransaction) return pure10(unit);
            throw new Error("Failed pattern match at Bill.Components.BillEditor (line 757, column 16 - line 821, column 14): " + [
                v2.constructor.name
            ]);
        };
    };
    var handleQuery = function(dictMonadAff) {
        var handleAction1 = handleAction(dictMonadAff);
        return function(v2) {
            return discard2(modify_3(function(v1) {
                var $126 = {};
                for(var $127 in v1)if (({}).hasOwnProperty.call(v1, $127)) $126[$127] = v1[$127];
                $126.billId = new Just(v2.value0);
                return $126;
            }))(function() {
                return discard2(handleAction1(Reload.value))(function() {
                    return pure10(new Just(v2.value1));
                });
            });
        };
    };
    var getGroupTypeLabel = function(groupType) {
        if (groupType === "tray") return trayLabel;
        if (groupType === "pack") return packLabel;
        if (groupType === "transaction") return transactionLabel;
        return groupType;
    };
    var renderEmptyGroup = function(group4) {
        return div3([
            class_("bill-group-item")
        ])([
            div3([
                class_("group-header")
            ])([
                span_([
                    text(getGroupTypeLabel(group4.group_type))
                ]),
                span_([
                    text(" #" + show5(group4.display_order))
                ])
            ]),
            div3([
                class_("group-content")
            ])([
                text("No data")
            ])
        ]);
    };
    var digitToSubscript = function(d) {
        if (d === "0") return "\u2080";
        if (d === "1") return "\u2081";
        if (d === "2") return "\u2082";
        if (d === "3") return "\u2083";
        if (d === "4") return "\u2084";
        if (d === "5") return "\u2085";
        if (d === "6") return "\u2086";
        if (d === "7") return "\u2087";
        if (d === "8") return "\u2088";
        if (d === "9") return "\u2089";
        return d;
    };
    var toSubscript = function(n) {
        var digits = split("")(show5(n));
        var subscriptDigits = map20(digitToSubscript)(digits);
        return joinWith("")(subscriptDigits);
    };
    var addCommasToString = function(str) {
        var len = length4(str);
        var go2 = function($copy_idx) {
            return function($copy_count) {
                return function($copy_acc) {
                    var $tco_var_idx = $copy_idx;
                    var $tco_var_count = $copy_count;
                    var $tco_done = false;
                    var $tco_result;
                    function $tco_loop(idx, count, acc) {
                        var $133 = idx < 0;
                        if ($133) {
                            $tco_done = true;
                            return acc;
                        }
                        var $$char = take4(1)(drop4(idx)(str));
                        var newAcc = function() {
                            var $134 = count > 0 && rem(count)(3) === 0;
                            if ($134) return $$char + ("," + acc);
                            return $$char + acc;
                        }();
                        $tco_var_idx = idx - 1 | 0;
                        $tco_var_count = count + 1 | 0;
                        $copy_acc = newAcc;
                        return;
                    }
                    while(!$tco_done)$tco_result = $tco_loop($tco_var_idx, $tco_var_count, $copy_acc);
                    return $tco_result;
                };
            };
        };
        var result = go2(len - 1 | 0)(0)("");
        return result;
    };
    var formatWithCommas = function(n) {
        var str = show5(function() {
            var $135 = n < 0;
            if ($135) return -n | 0;
            return n;
        }());
        var len = length4(str);
        var $136 = len <= 3;
        if ($136) return str;
        return addCommasToString(str);
    };
    var formatMoneyDisplay = function(str) {
        var v2 = fromString(str);
        if (v2 instanceof Just) {
            var intPart = floor2(v2.value0);
            var intStr = formatWithCommas(intPart);
            var decPart = round2((v2.value0 - toNumber(intPart)) * 100);
            var $138 = decPart === 0;
            if ($138) return span_([
                span3([
                    class_("num")
                ])([
                    text(intStr)
                ]),
                text("."),
                span3([
                    class_("num-subscript-hidden")
                ])([
                    text("\u2080\u2080")
                ])
            ]);
            return span_([
                span3([
                    class_("num")
                ])([
                    text(intStr)
                ]),
                text("."),
                span3([
                    class_("num-subscript")
                ])([
                    text(toSubscript(decPart))
                ])
            ]);
        }
        if (v2 instanceof Nothing) return text(str);
        throw new Error("Failed pattern match at Bill.Components.BillEditor (line 416, column 3 - line 434, column 27): " + [
            v2.constructor.name
        ]);
    };
    var renderMoneyWithUnit = function(num) {
        return function(unit2) {
            var $140 = num === "-";
            if ($140) return text("-");
            var formatted = formatMoneyDisplay(num);
            return span_([
                formatted,
                text(" " + unit2)
            ]);
        };
    };
    var formatMoneyString = function(n) {
        var intPart = floor2(n);
        var intStr = formatWithCommas(intPart);
        var decPart = round2((n - toNumber(intPart)) * 100);
        var $141 = decPart === 0;
        if ($141) return intStr + ".\u2080\u2080";
        return intStr + ("." + toSubscript(decPart));
    };
    var formatNumberString = function(str) {
        var v2 = fromString(str);
        if (v2 instanceof Just) {
            var intPart = floor2(v2.value0);
            var decPart = v2.value0 - toNumber(intPart);
            var $143 = decPart === 0;
            if ($143) return formatWithCommas(intPart);
            return formatWithCommas(intPart) + drop4(length4(show5(intPart)))(str);
        }
        if (v2 instanceof Nothing) return str;
        throw new Error("Failed pattern match at Bill.Components.BillEditor (line 403, column 3 - line 412, column 19): " + [
            v2.constructor.name
        ]);
    };
    var renderNumberWithUnit = function(num) {
        return function(unit2) {
            var $145 = num === "-";
            if ($145) return text("-");
            return span_([
                span3([
                    class_("num")
                ])([
                    text(formatNumberString(num))
                ]),
                text(" " + unit2)
            ]);
        };
    };
    var renderPackWeight = function(item) {
        if (item.weight_grams instanceof Just) return renderNumberWithUnit(item.weight_grams.value0)(unitGrams);
        if (item.weight_baht instanceof Just) return renderNumberWithUnit(item.weight_baht.value0)(unitBaht);
        return text("-");
    };
    var renderPackItem = function(item) {
        return tr_([
            td_([
                text(show5(item.display_order))
            ]),
            td_([
                text(fromMaybe("-")(item.shape))
            ]),
            td_([
                renderNumberWithUnit(maybe("-")(identity11)(item.purity))("%")
            ]),
            td_([
                renderPackWeight(item)
            ]),
            td_([
                span3([
                    class_("num")
                ])([
                    text(fromMaybe("-")(item.deduction_rate))
                ])
            ]),
            td_([
                renderMoneyWithUnit(fromMaybe("-")(item.calculation_amount))(unitTHB)
            ])
        ]);
    };
    var renderPackItems = function(items2) {
        var $150 = length(items2) === 0;
        if ($150) return p_([
            text("\u0E22\u0E31\u0E07\u0E44\u0E21\u0E48\u0E21\u0E35\u0E41\u0E17\u0E48\u0E07")
        ]);
        return table([
            class_("items-table")
        ])([
            thead_([
                tr_([
                    th_([
                        text("#")
                    ]),
                    th_([
                        text(shapeLabel)
                    ]),
                    th_([
                        text(purityLabel)
                    ]),
                    th_([
                        text(weightLabel)
                    ]),
                    th_([
                        text(deductionRateLabel)
                    ]),
                    th_([
                        text(calculationAmountLabel)
                    ])
                ])
            ]),
            tbody_(map20(renderPackItem)(items2))
        ]);
    };
    var renderPackGroup = function(group4) {
        return function(pack) {
            return function(items2) {
                return div3([
                    class_("pack-group")
                ])([
                    div3([
                        class_("pack-header")
                    ])([
                        div_([
                            span3([
                                class_("pack-title")
                            ])([
                                text(packLabel + (" " + pack.user_number))
                            ]),
                            span3([
                                class_("pack-summary")
                            ])([
                                text(show5(length(items2)) + " \u0E41\u0E17\u0E48\u0E07")
                            ])
                        ])
                    ]),
                    div3([
                        class_("pack-content")
                    ])([
                        renderPackSettings(pack),
                        renderPackItems(items2)
                    ])
                ]);
            };
        };
    };
    var renderTransactionDetails = function(item) {
        if (item.amount_money instanceof Just) return renderMoneyWithUnit(item.amount_money.value0)(unitTHB);
        if (item.amount_money instanceof Nothing) {
            if (item.amount_grams instanceof Just) return renderNumberWithUnit(item.amount_grams.value0)(unitGrams);
            if (item.amount_grams instanceof Nothing) {
                if (item.amount_baht instanceof Just) return renderNumberWithUnit(item.amount_baht.value0)(unitBaht);
                if (item.amount_baht instanceof Nothing) return text("-");
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 691, column 16 - line 693, column 29): " + [
                    item.amount_baht.constructor.name
                ]);
            }
            throw new Error("Failed pattern match at Bill.Components.BillEditor (line 689, column 14 - line 693, column 29): " + [
                item.amount_grams.constructor.name
            ]);
        }
        throw new Error("Failed pattern match at Bill.Components.BillEditor (line 687, column 33 - line 693, column 29): " + [
            item.amount_money.constructor.name
        ]);
    };
    var renderTransactionItem = function(item) {
        return tr_([
            td_([
                text(show5(item.display_order))
            ]),
            td_([
                text(fromMaybe("-")(item.transaction_type))
            ]),
            td_([
                renderTransactionDetails(item)
            ])
        ]);
    };
    var renderTransactionItems = function(items2) {
        var $157 = length(items2) === 0;
        if ($157) return p_([
            text("\u0E22\u0E31\u0E07\u0E44\u0E21\u0E48\u0E21\u0E35\u0E23\u0E32\u0E22\u0E01\u0E32\u0E23")
        ]);
        return table([
            class_("items-table")
        ])([
            thead_([
                tr_([
                    th_([
                        text("#")
                    ]),
                    th_([
                        text("\u0E1B\u0E23\u0E30\u0E40\u0E20\u0E17")
                    ]),
                    th_([
                        text("\u0E23\u0E32\u0E22\u0E25\u0E30\u0E40\u0E2D\u0E35\u0E22\u0E14")
                    ])
                ])
            ]),
            tbody_(map20(renderTransactionItem)(items2))
        ]);
    };
    var renderTransactionGroup = function(group4) {
        return function(transaction) {
            return function(items2) {
                return div3([
                    class_("transaction-group")
                ])([
                    div3([
                        class_("transaction-header")
                    ])([
                        div_([
                            span3([
                                class_("transaction-title")
                            ])([
                                text(transactionLabel)
                            ]),
                            span3([
                                class_("transaction-summary")
                            ])([
                                text(show5(length(items2)) + " \u0E23\u0E32\u0E22\u0E01\u0E32\u0E23")
                            ])
                        ])
                    ]),
                    div3([
                        class_("transaction-content")
                    ])([
                        renderTransactionItems(items2)
                    ])
                ]);
            };
        };
    };
    var renderTrayItem = function(item) {
        return tr_([
            td_([
                text(show5(item.display_order))
            ]),
            td_([
                renderNumberWithUnit(fromMaybe("-")(item.nominal_weight))(unitBaht)
            ]),
            td_([
                span3([
                    class_("num")
                ])([
                    text(maybe("-")(show5)(item.quantity))
                ])
            ]),
            td_([
                renderMoneyWithUnit(fromMaybe("-")(item.making_charge))(unitTHB)
            ]),
            td_([
                renderMoneyWithUnit(fromMaybe("-")(item.amount))(unitTHB)
            ])
        ]);
    };
    var renderTrayItems = function(items2) {
        var $158 = length(items2) === 0;
        if ($158) return p_([
            text("\u0E22\u0E31\u0E07\u0E44\u0E21\u0E48\u0E21\u0E35\u0E23\u0E32\u0E22\u0E01\u0E32\u0E23")
        ]);
        return table([
            class_("items-table")
        ])([
            thead_([
                tr_([
                    th_([
                        text("#")
                    ]),
                    th_([
                        text(nominalWeightLabel)
                    ]),
                    th_([
                        text(quantityLabel)
                    ]),
                    th_([
                        text(makingChargeLabel)
                    ]),
                    th_([
                        text(amountLabel)
                    ])
                ])
            ]),
            tbody_(map20(renderTrayItem)(items2))
        ]);
    };
    var renderTraySettings = function(tray) {
        return table([
            class_("settings-table")
        ])([
            tbody_([
                tr_([
                    td_([
                        text(purityLabel)
                    ]),
                    td_([
                        renderNumberWithUnit(fromMaybe("-")(tray.purity))("%")
                    ])
                ]),
                tr_([
                    td_([
                        text(shapeLabel)
                    ]),
                    td_([
                        text(tray.shape)
                    ])
                ]),
                tr_([
                    td_([
                        text(discountLabel)
                    ]),
                    td_([
                        renderNumberWithUnit(maybe("-")(show5)(tray.discount))("%")
                    ])
                ]),
                tr_([
                    td_([
                        text(actualWeightLabel)
                    ]),
                    td_([
                        renderNumberWithUnit(tray.actual_weight_grams)(unitGrams)
                    ])
                ]),
                tr_([
                    td_([
                        text(priceRateLabel)
                    ]),
                    td_([
                        renderMoneyWithUnit(fromMaybe("-")(tray.price_rate))(unitTHB)
                    ])
                ])
            ])
        ]);
    };
    var renderTrayGroup = function(group4) {
        return function(tray) {
            return function(items2) {
                return div3([
                    class_("tray-group")
                ])([
                    div3([
                        class_("tray-header")
                    ])([
                        div_([
                            span3([
                                class_("tray-title")
                            ])([
                                text(trayLabel + (" #" + show5(tray.internal_num)))
                            ]),
                            span3([
                                class_("tray-summary")
                            ])([
                                text(show5(length(items2)) + " \u0E23\u0E32\u0E22\u0E01\u0E32\u0E23")
                            ])
                        ])
                    ]),
                    div3([
                        class_("tray-content")
                    ])([
                        renderTraySettings(tray),
                        renderTrayItems(items2)
                    ])
                ]);
            };
        };
    };
    var renderGroup = function(group4) {
        if (group4.groupData instanceof Nothing) return renderEmptyGroup(group4);
        if (group4.groupData instanceof Just) {
            if (group4.groupData.value0.type === "tray") {
                if (group4.groupData.value0.tray instanceof Just) return renderTrayGroup(group4)(group4.groupData.value0.tray.value0)(group4.groupData.value0.items);
                if (group4.groupData.value0.tray instanceof Nothing) return renderEmptyGroup(group4);
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 471, column 15 - line 473, column 40): " + [
                    group4.groupData.value0.tray.constructor.name
                ]);
            }
            if (group4.groupData.value0.type === "pack") {
                if (group4.groupData.value0.pack instanceof Just) return renderPackGroup(group4)(group4.groupData.value0.pack.value0)(group4.groupData.value0.items);
                if (group4.groupData.value0.pack instanceof Nothing) return renderEmptyGroup(group4);
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 474, column 15 - line 476, column 40): " + [
                    group4.groupData.value0.pack.constructor.name
                ]);
            }
            if (group4.groupData.value0.type === "transaction") {
                if (group4.groupData.value0.transaction instanceof Just) return renderTransactionGroup(group4)(group4.groupData.value0.transaction.value0)(group4.groupData.value0.items);
                if (group4.groupData.value0.transaction instanceof Nothing) return renderEmptyGroup(group4);
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 477, column 22 - line 479, column 40): " + [
                    group4.groupData.value0.transaction.constructor.name
                ]);
            }
            return renderEmptyGroup(group4);
        }
        throw new Error("Failed pattern match at Bill.Components.BillEditor (line 468, column 21 - line 480, column 32): " + [
            group4.groupData.constructor.name
        ]);
    };
    var renderGroups = function(groups) {
        return div3([
            class_("bill-groups")
        ])([
            function() {
                var $168 = length(groups) === 0;
                if ($168) return p_([
                    text("\u0E22\u0E31\u0E07\u0E44\u0E21\u0E48\u0E21\u0E35\u0E01\u0E25\u0E38\u0E48\u0E21 - \u0E01\u0E14\u0E1B\u0E38\u0E48\u0E21\u0E14\u0E49\u0E32\u0E19\u0E25\u0E48\u0E32\u0E07\u0E40\u0E1E\u0E37\u0E48\u0E2D\u0E40\u0E1E\u0E34\u0E48\u0E21")
                ]);
                return div_(map20(renderGroup)(groups));
            }()
        ]);
    };
    var abs3 = function(n) {
        var $169 = n < 0;
        if ($169) return -n;
        return n;
    };
    var formatBaht = function(n) {
        var absN = abs3(n);
        var formatted = toStringWith(fixed(3))(absN);
        var cleaned = function() {
            var $170 = contains(".000")(formatted);
            if ($170) return replace(".000")("")(formatted);
            var $171 = contains(".00")(formatted);
            if ($171) return replace(".00")("")(formatted);
            var $172 = contains(".0")(formatted);
            if ($172) return replace(".0")("")(formatted);
            return formatted;
        }();
        return cleaned + "\u0E1A";
    };
    var formatGrams = function(n) {
        var absN = abs3(n);
        var formatted = toStringWith(fixed(3))(absN);
        return formatted + "g";
    };
    var getGoldBalances = function(bill) {
        var rows4 = [];
        var gramJewel = parseNumber(bill.prev_gram_jewel);
        var rows$prime = function() {
            var $173 = gramJewel !== 0;
            if ($173) return append12(rows4)([
                {
                    description: function() {
                        var $174 = gramJewel > 0;
                        if ($174) return "\u0E40\u0E01\u0E48\u0E32\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E17\u0E2D\u0E07";
                        return "\u0E40\u0E01\u0E48\u0E32\u0E04\u0E49\u0E32\u0E07\u0E17\u0E2D\u0E07";
                    }(),
                    value: formatGrams(gramJewel)
                }
            ]);
            return rows4;
        }();
        var gramBar99 = parseNumber(bill.prev_gram_bar99);
        var gramBar96 = parseNumber(bill.prev_gram_bar96);
        var bahtJewel = parseNumber(bill.prev_baht_jewel);
        var rows$prime$prime = function() {
            var $175 = bahtJewel !== 0;
            if ($175) return append12(rows$prime)([
                {
                    description: function() {
                        var $176 = bahtJewel > 0;
                        if ($176) return "\u0E40\u0E01\u0E48\u0E32\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E17\u0E2D\u0E07";
                        return "\u0E40\u0E01\u0E48\u0E32\u0E04\u0E49\u0E32\u0E07\u0E17\u0E2D\u0E07";
                    }(),
                    value: formatBaht(bahtJewel)
                }
            ]);
            return rows$prime;
        }();
        var bahtBar99 = parseNumber(bill.prev_baht_bar99);
        var bahtBar96 = parseNumber(bill.prev_baht_bar96);
        var rows$prime$prime$prime = function() {
            var $177 = bahtBar96 !== 0;
            if ($177) return append12(rows$prime$prime)([
                {
                    description: function() {
                        var $178 = bahtBar96 > 0;
                        if ($178) return "\u0E40\u0E01\u0E48\u0E32\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E41\u0E17\u0E48\u0E07 \u2079\u2076\u22C5\u2085\uFE6A";
                        return "\u0E40\u0E01\u0E48\u0E32\u0E04\u0E49\u0E32\u0E07\u0E41\u0E17\u0E48\u0E07 \u2079\u2076\u22C5\u2085\uFE6A";
                    }(),
                    value: formatBaht(bahtBar96)
                }
            ]);
            return rows$prime$prime;
        }();
        var rows$prime$prime$prime$prime = function() {
            var $179 = gramBar96 !== 0;
            if ($179) return append12(rows$prime$prime$prime)([
                {
                    description: function() {
                        var $180 = gramBar96 > 0;
                        if ($180) return "\u0E40\u0E01\u0E48\u0E32\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E41\u0E17\u0E48\u0E07 \u2079\u2076\u22C5\u2085\uFE6A";
                        return "\u0E40\u0E01\u0E48\u0E32\u0E04\u0E49\u0E32\u0E07\u0E41\u0E17\u0E48\u0E07 \u2079\u2076\u22C5\u2085\uFE6A";
                    }(),
                    value: formatGrams(gramBar96)
                }
            ]);
            return rows$prime$prime$prime;
        }();
        var rows$prime$prime$prime$prime$prime = function() {
            var $181 = bahtBar99 !== 0;
            if ($181) return append12(rows$prime$prime$prime$prime)([
                {
                    description: function() {
                        var $182 = bahtBar99 > 0;
                        if ($182) return "\u0E40\u0E01\u0E48\u0E32\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E41\u0E17\u0E48\u0E07 \u2079\u2079\u22C5\u2089\u2089\uFE6A";
                        return "\u0E40\u0E01\u0E48\u0E32\u0E04\u0E49\u0E32\u0E07\u0E41\u0E17\u0E48\u0E07 \u2079\u2079\u22C5\u2089\u2089\uFE6A";
                    }(),
                    value: formatBaht(bahtBar99)
                }
            ]);
            return rows$prime$prime$prime$prime;
        }();
        var rows$prime$prime$prime$prime$prime$prime = function() {
            var $183 = gramBar99 !== 0;
            if ($183) return append12(rows$prime$prime$prime$prime$prime)([
                {
                    description: function() {
                        var $184 = gramBar99 > 0;
                        if ($184) return "\u0E40\u0E01\u0E48\u0E32\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E41\u0E17\u0E48\u0E07 \u2079\u2079\u22C5\u2089\u2089\uFE6A";
                        return "\u0E40\u0E01\u0E48\u0E32\u0E04\u0E49\u0E32\u0E07\u0E41\u0E17\u0E48\u0E07 \u2079\u2079\u22C5\u2089\u2089\uFE6A";
                    }(),
                    value: formatGrams(gramBar99)
                }
            ]);
            return rows$prime$prime$prime$prime$prime;
        }();
        return rows$prime$prime$prime$prime$prime$prime;
    };
    var getMoneyBalance = function(bill) {
        var money = parseNumber(bill.prev_balance_money);
        var $185 = money === 0;
        if ($185) return {
            hasBalance: false,
            description: "",
            value: ""
        };
        return {
            hasBalance: true,
            description: function() {
                var $186 = money > 0;
                if ($186) return "\u0E40\u0E01\u0E48\u0E32\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E40\u0E07\u0E34\u0E19";
                return "\u0E40\u0E01\u0E48\u0E32\u0E04\u0E49\u0E32\u0E07\u0E40\u0E07\u0E34\u0E19";
            }(),
            value: formatMoneyString(abs3(money))
        };
    };
    var renderPreviousBalance = function(bill) {
        var moneyBalance = getMoneyBalance(bill);
        var goldBalances = getGoldBalances(bill);
        var $187 = length(goldBalances) === 0 && !moneyBalance.hasBalance;
        if ($187) return text("");
        return table([
            class_("balance-table-compact")
        ])([
            tbody_([
                tr_([
                    td([
                        class_("balance-desc-col")
                    ])(map20(function(b2) {
                        return div_([
                            text(b2.description)
                        ]);
                    })(goldBalances)),
                    td([
                        class_("balance-value-col")
                    ])(map20(function(b2) {
                        return div_([
                            renderGoldValue(b2.value)
                        ]);
                    })(goldBalances)),
                    td([
                        class_("balance-desc-col")
                    ])([
                        function() {
                            if (moneyBalance.hasBalance) return text(moneyBalance.description);
                            return text("");
                        }()
                    ]),
                    td([
                        class_("balance-value-col")
                    ])([
                        function() {
                            if (moneyBalance.hasBalance) return renderMoneyValue(moneyBalance.value);
                            return text("");
                        }()
                    ])
                ])
            ])
        ]);
    };
    var renderBillContent = function(state3) {
        if (state3.bill instanceof Nothing) return text("");
        if (state3.bill instanceof Just) return div3([
            class_("bill-editor-content")
        ])([
            renderPreviousBalance(state3.bill.value0),
            renderGroups(state3.groups),
            renderAddGroupButtons,
            renderGrandTotal(state3.bill.value0)
        ]);
        throw new Error("Failed pattern match at Bill.Components.BillEditor (line 140, column 3 - line 149, column 10): " + [
            state3.bill.constructor.name
        ]);
    };
    var renderContent = function(state3) {
        if (state3.isLoading) return renderLoading;
        var v2 = function(v1) {
            var v22 = function(v3) {
                if (otherwise) return renderBillContent(state3);
                throw new Error("Failed pattern match at Bill.Components.BillEditor (line 113, column 1 - line 113, column 64): " + [
                    state3.constructor.name
                ]);
            };
            if (state3.bill instanceof Nothing) return renderNoBill;
            return v22(true);
        };
        if (state3.error instanceof Just) return renderError(state3.error.value0);
        return v2(true);
    };
    var render = function(state3) {
        return div3([
            class_("bill-editor")
        ])([
            renderHeader(state3),
            renderContent(state3),
            renderFooter(state3)
        ]);
    };
    var component = function(dictMonadAff) {
        return mkComponent({
            initialState,
            render,
            "eval": mkEval({
                receive: defaultEval.receive,
                finalize: defaultEval.finalize,
                handleAction: handleAction(dictMonadAff),
                handleQuery: handleQuery(dictMonadAff),
                initialize: new Just(Initialize2.value)
            })
        });
    };
    // output/Bill.Components.BillList/index.js
    var show6 = /* @__PURE__ */ show(showInt);
    var map21 = /* @__PURE__ */ map(functorArray);
    var discard3 = /* @__PURE__ */ discard(discardUnit)(bindHalogenM);
    var modify_4 = /* @__PURE__ */ modify_2(monadStateHalogenM);
    var bind6 = /* @__PURE__ */ bind(bindHalogenM);
    var get6 = /* @__PURE__ */ get(monadStateHalogenM);
    var lift4 = /* @__PURE__ */ lift(monadTransHalogenM);
    var pure11 = /* @__PURE__ */ pure(applicativeHalogenM);
    var BillSelected = /* @__PURE__ */ function() {
        function BillSelected2(value0) {
            this.value0 = value0;
        }
        BillSelected2.create = function(value0) {
            return new BillSelected2(value0);
        };
        return BillSelected2;
    }();
    var NewBillRequested = /* @__PURE__ */ function() {
        function NewBillRequested2() {}
        NewBillRequested2.value = new NewBillRequested2();
        return NewBillRequested2;
    }();
    var Initialize3 = /* @__PURE__ */ function() {
        function Initialize6() {}
        Initialize6.value = new Initialize6();
        return Initialize6;
    }();
    var Reload2 = /* @__PURE__ */ function() {
        function Reload3() {}
        Reload3.value = new Reload3();
        return Reload3;
    }();
    var SelectBill = /* @__PURE__ */ function() {
        function SelectBill2(value0) {
            this.value0 = value0;
        }
        SelectBill2.create = function(value0) {
            return new SelectBill2(value0);
        };
        return SelectBill2;
    }();
    var CreateNewBill = /* @__PURE__ */ function() {
        function CreateNewBill3() {}
        CreateNewBill3.value = new CreateNewBill3();
        return CreateNewBill3;
    }();
    var renderLoading2 = /* @__PURE__ */ div3([
        /* @__PURE__ */ class_("bill-list-loading")
    ])([
        /* @__PURE__ */ text(loading)
    ]);
    var renderHeader2 = function(state3) {
        return div3([
            class_("bill-list-header")
        ])([
            h2_([
                text(billsFor + (" " + state3.customerName))
            ]),
            button([
                class_("btn btn-primary"),
                onClick(function(v2) {
                    return CreateNewBill.value;
                })
            ])([
                text(newBill)
            ]),
            button([
                class_("btn btn-secondary"),
                onClick(function(v2) {
                    return Reload2.value;
                })
            ])([
                text(reload)
            ])
        ]);
    };
    var renderError2 = function(err) {
        return div3([
            class_("bill-list-error")
        ])([
            text(errorPrefix + err)
        ]);
    };
    var renderEmpty = /* @__PURE__ */ div3([
        /* @__PURE__ */ class_("bill-list-empty")
    ])([
        /* @__PURE__ */ text(noBillsFound)
    ]);
    var renderBillRow = function(bill) {
        return tr_([
            td_([
                text(show6(bill.id))
            ]),
            td_([
                text(bill.date)
            ]),
            td_([
                text(function() {
                    if (bill.is_finalized) return finalized;
                    return draft;
                }())
            ]),
            td_([
                button([
                    class_("btn btn-sm btn-primary"),
                    onClick(function(v2) {
                        return new SelectBill(bill.id);
                    })
                ])([
                    text(edit)
                ])
            ])
        ]);
    };
    var renderBills = function(bills) {
        return div3([
            class_("bill-list-items")
        ])([
            table([
                class_("bill-table")
            ])([
                thead_([
                    tr_([
                        th_([
                            text(billId)
                        ]),
                        th_([
                            text(date)
                        ]),
                        th_([
                            text(status)
                        ]),
                        th_([
                            text(actions)
                        ])
                    ])
                ]),
                tbody_(map21(renderBillRow)(bills))
            ])
        ]);
    };
    var renderContent2 = function(state3) {
        if (state3.isLoading) return renderLoading2;
        var v2 = function(v1) {
            if (length(state3.bills) === 0) return renderEmpty;
            if (otherwise) return renderBills(state3.bills);
            throw new Error("Failed pattern match at Bill.Components.BillList (line 90, column 1 - line 90, column 64): " + [
                state3.constructor.name
            ]);
        };
        if (state3.error instanceof Just) return renderError2(state3.error.value0);
        return v2(true);
    };
    var render2 = function(state3) {
        return div3([
            class_("bill-list")
        ])([
            renderHeader2(state3),
            renderContent2(state3)
        ]);
    };
    var initialState2 = function(input3) {
        return {
            customerId: input3.customerId,
            customerName: input3.customerName,
            bills: [],
            isLoading: false,
            error: Nothing.value
        };
    };
    var handleAction2 = function(dictMonadAff) {
        var lift1 = lift4(dictMonadAff.MonadEffect0().Monad0());
        var getCustomerBills2 = getCustomerBills(dictMonadAff);
        return function(v2) {
            if (v2 instanceof Initialize3) return handleAction2(dictMonadAff)(Reload2.value);
            if (v2 instanceof Reload2) return discard3(modify_4(function(v1) {
                var $39 = {};
                for(var $40 in v1)if (({}).hasOwnProperty.call(v1, $40)) $39[$40] = v1[$40];
                $39.isLoading = true;
                $39.error = Nothing.value;
                return $39;
            }))(function() {
                return bind6(get6)(function(state3) {
                    return bind6(lift1(getCustomerBills2(state3.customerId)))(function(result) {
                        if (result instanceof Left) return modify_4(function(v1) {
                            var $43 = {};
                            for(var $44 in v1)if (({}).hasOwnProperty.call(v1, $44)) $43[$44] = v1[$44];
                            $43.isLoading = false;
                            $43.error = new Just(result.value0);
                            return $43;
                        });
                        if (result instanceof Right) return modify_4(function(v1) {
                            var $47 = {};
                            for(var $48 in v1)if (({}).hasOwnProperty.call(v1, $48)) $47[$48] = v1[$48];
                            $47.isLoading = false;
                            $47.bills = result.value0;
                            return $47;
                        });
                        throw new Error("Failed pattern match at Bill.Components.BillList (line 157, column 5 - line 161, column 57): " + [
                            result.constructor.name
                        ]);
                    });
                });
            });
            if (v2 instanceof SelectBill) return raise(new BillSelected(v2.value0));
            if (v2 instanceof CreateNewBill) return raise(NewBillRequested.value);
            throw new Error("Failed pattern match at Bill.Components.BillList (line 149, column 16 - line 167, column 29): " + [
                v2.constructor.name
            ]);
        };
    };
    var handleQuery2 = function(dictMonadAff) {
        var handleAction1 = handleAction2(dictMonadAff);
        return function(v2) {
            return discard3(handleAction1(Reload2.value))(function() {
                return pure11(new Just(v2.value0));
            });
        };
    };
    var component2 = function(dictMonadAff) {
        return mkComponent({
            initialState: initialState2,
            render: render2,
            "eval": mkEval({
                receive: defaultEval.receive,
                finalize: defaultEval.finalize,
                handleAction: handleAction2(dictMonadAff),
                handleQuery: handleQuery2(dictMonadAff),
                initialize: new Just(Initialize3.value)
            })
        });
    };
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
            if (listElement) listElement.scrollTo({
                top: scrollTop2,
                behavior: "smooth"
            });
        };
    };
    var getCustomerListElementImpl = function() {
        const element4 = document.querySelector(".customer-list");
        return element4;
    };
    var measureRowHeights = function() {
        const rows4 = document.querySelectorAll(".customer-row[data-row-index]");
        const measurements = [];
        rows4.forEach((row)=>{
            const index4 = parseInt(row.getAttribute("data-row-index"), 10);
            const customerId = parseInt(row.getAttribute("data-customer-id"), 10);
            const height9 = row.offsetHeight;
            measurements.push({
                index: index4,
                customerId,
                height: height9
            });
        });
        return measurements;
    };
    var requestAnimationFrameAction = function() {
        return new Promise((resolve)=>{
            requestAnimationFrame(()=>{
                resolve();
            });
        });
    };
    var waitForRowAndMeasureImpl = function(rowIndex2) {
        return function() {
            return new Promise((resolve, reject)=>{
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
                    if (!row) return null;
                    row.offsetHeight;
                    container.offsetHeight;
                    let offsetTop2 = row.offsetTop;
                    const visibleRowsStyle = window.getComputedStyle(container);
                    const transform = visibleRowsStyle.transform;
                    if (transform && transform !== "none") {
                        const matrix = new DOMMatrix(transform);
                        offsetTop2 += matrix.m42;
                    }
                    return {
                        offsetTop: offsetTop2,
                        height: row.offsetHeight
                    };
                };
                const checkStability = function() {
                    requestAnimationFrame(()=>{
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
                timeoutId = setTimeout(()=>{
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
            if (!activeInput) return true;
            if (activeInput.contains(target6)) return false;
            const editableField = target6.closest(".editable-field");
            if (editableField) return false;
            return true;
        };
    };
    var generateRandomCode = function() {
        return Math.floor(Math.random() * 9e5) + 1e5;
    };
    var focusDeleteConfirmInput = function() {
        requestAnimationFrame(()=>{
            const input3 = document.querySelector(".modal-input");
            if (input3) input3.focus();
        });
    };
    var focusEditInput = function() {
        requestAnimationFrame(()=>{
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
        const date2 = new Date(dateStr);
        const now = /* @__PURE__ */ new Date();
        const currentYear = now.getFullYear();
        const dateYear = date2.getFullYear();
        const day = date2.getDate();
        const month = date2.getMonth() + 1;
        if (dateYear === currentYear) return `${day}/${month}`;
        else return `${day}/${month}/${dateYear}`;
    };
    var formatMoneyValue = function(n) {
        const absN = Math.abs(n);
        const intPart = Math.floor(absN);
        const fracPart = Math.round((absN - intPart) * 100);
        const fracStr = fracPart < 10 ? "0" + fracPart : fracPart.toString();
        return {
            integer: intPart.toLocaleString(),
            fraction: fracStr
        };
    };
    var formatGramsValue = function(n) {
        const absN = Math.abs(n);
        if (absN === 0) return {
            integer: "",
            fraction: ""
        };
        const intPart = Math.floor(absN);
        const fracPart = Math.round((absN - intPart) * 1e3);
        const fracStr = fracPart.toString().padStart(3, "0");
        return {
            integer: intPart.toLocaleString(),
            fraction: fracStr
        };
    };
    var formatBahtValue = function(n) {
        const absN = Math.abs(n);
        if (absN === 0) return {
            integer: "",
            fraction: "",
            hasFraction: false
        };
        const intPart = Math.floor(absN);
        const fracPart = absN - intPart;
        if (fracPart === 0) return {
            integer: intPart.toLocaleString(),
            fraction: "",
            hasFraction: false
        };
        else {
            const fracStr = fracPart.toFixed(3).substring(1).replace(/0+$/, "");
            return {
                integer: intPart.toLocaleString(),
                fraction: fracStr,
                hasFraction: true
            };
        }
    };
    // output/Halogen.Svg.Attributes/index.js
    var show7 = /* @__PURE__ */ show(showNumber);
    var map23 = /* @__PURE__ */ map(functorArray);
    var width2 = /* @__PURE__ */ function() {
        var $34 = attr2("width");
        return function($35) {
            return $34(show7($35));
        };
    }();
    var viewBox = function(x_) {
        return function(y_) {
            return function(w) {
                return function(h_) {
                    return attr2("viewBox")(joinWith(" ")(map23(show7)([
                        x_,
                        y_,
                        w,
                        h_
                    ])));
                };
            };
        };
    };
    var height2 = /* @__PURE__ */ function() {
        var $92 = attr2("height");
        return function($93) {
            return $92(show7($93));
        };
    }();
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
    var sortNeutralIcon = /* @__PURE__ */ svg([
        /* @__PURE__ */ viewBox(0)(0)(24)(24),
        /* @__PURE__ */ width2(14),
        /* @__PURE__ */ height2(14),
        /* @__PURE__ */ attr2("fill")("none"),
        /* @__PURE__ */ attr2("stroke")("currentColor"),
        /* @__PURE__ */ attr2("stroke-width")("2"),
        /* @__PURE__ */ attr2("stroke-linecap")("round"),
        /* @__PURE__ */ attr2("stroke-linejoin")("round")
    ])([
        /* @__PURE__ */ polyline([
            /* @__PURE__ */ attr2("points")("7 15 12 20 17 15")
        ]),
        /* @__PURE__ */ polyline([
            /* @__PURE__ */ attr2("points")("7 9 12 4 17 9")
        ])
    ]);
    var sortDescIcon = /* @__PURE__ */ svg([
        /* @__PURE__ */ viewBox(0)(0)(24)(24),
        /* @__PURE__ */ width2(14),
        /* @__PURE__ */ height2(14),
        /* @__PURE__ */ attr2("fill")("none"),
        /* @__PURE__ */ attr2("stroke")("currentColor"),
        /* @__PURE__ */ attr2("stroke-width")("2"),
        /* @__PURE__ */ attr2("stroke-linecap")("round"),
        /* @__PURE__ */ attr2("stroke-linejoin")("round")
    ])([
        /* @__PURE__ */ line([
            /* @__PURE__ */ attr2("x1")("12"),
            /* @__PURE__ */ attr2("y1")("5"),
            /* @__PURE__ */ attr2("x2")("12"),
            /* @__PURE__ */ attr2("y2")("19")
        ]),
        /* @__PURE__ */ polyline([
            /* @__PURE__ */ attr2("points")("19 12 12 19 5 12")
        ])
    ]);
    var sortAscIcon = /* @__PURE__ */ svg([
        /* @__PURE__ */ viewBox(0)(0)(24)(24),
        /* @__PURE__ */ width2(14),
        /* @__PURE__ */ height2(14),
        /* @__PURE__ */ attr2("fill")("none"),
        /* @__PURE__ */ attr2("stroke")("currentColor"),
        /* @__PURE__ */ attr2("stroke-width")("2"),
        /* @__PURE__ */ attr2("stroke-linecap")("round"),
        /* @__PURE__ */ attr2("stroke-linejoin")("round")
    ])([
        /* @__PURE__ */ line([
            /* @__PURE__ */ attr2("x1")("12"),
            /* @__PURE__ */ attr2("y1")("19"),
            /* @__PURE__ */ attr2("x2")("12"),
            /* @__PURE__ */ attr2("y2")("5")
        ]),
        /* @__PURE__ */ polyline([
            /* @__PURE__ */ attr2("points")("5 12 12 5 19 12")
        ])
    ]);
    var deleteIcon = /* @__PURE__ */ svg([
        /* @__PURE__ */ viewBox(0)(0)(24)(24),
        /* @__PURE__ */ width2(16),
        /* @__PURE__ */ height2(16),
        /* @__PURE__ */ attr2("fill")("none"),
        /* @__PURE__ */ attr2("stroke")("currentColor"),
        /* @__PURE__ */ attr2("stroke-width")("2"),
        /* @__PURE__ */ attr2("stroke-linecap")("round"),
        /* @__PURE__ */ attr2("stroke-linejoin")("round")
    ])([
        /* @__PURE__ */ polyline([
            /* @__PURE__ */ attr2("points")("3 6 5 6 21 6")
        ]),
        /* @__PURE__ */ path([
            /* @__PURE__ */ attr2("d")("M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2")
        ]),
        /* @__PURE__ */ line([
            /* @__PURE__ */ attr2("x1")("10"),
            /* @__PURE__ */ attr2("y1")("11"),
            /* @__PURE__ */ attr2("x2")("10"),
            /* @__PURE__ */ attr2("y2")("17")
        ]),
        /* @__PURE__ */ line([
            /* @__PURE__ */ attr2("x1")("14"),
            /* @__PURE__ */ attr2("y1")("11"),
            /* @__PURE__ */ attr2("x2")("14"),
            /* @__PURE__ */ attr2("y2")("17")
        ])
    ]);
    var addIcon = /* @__PURE__ */ svg([
        /* @__PURE__ */ viewBox(0)(0)(24)(24),
        /* @__PURE__ */ width2(16),
        /* @__PURE__ */ height2(16),
        /* @__PURE__ */ attr2("fill")("none"),
        /* @__PURE__ */ attr2("stroke")("currentColor"),
        /* @__PURE__ */ attr2("stroke-width")("2"),
        /* @__PURE__ */ attr2("stroke-linecap")("round"),
        /* @__PURE__ */ attr2("stroke-linejoin")("round")
    ])([
        /* @__PURE__ */ line([
            /* @__PURE__ */ attr2("x1")("12"),
            /* @__PURE__ */ attr2("y1")("5"),
            /* @__PURE__ */ attr2("x2")("12"),
            /* @__PURE__ */ attr2("y2")("19")
        ]),
        /* @__PURE__ */ line([
            /* @__PURE__ */ attr2("x1")("5"),
            /* @__PURE__ */ attr2("y1")("12"),
            /* @__PURE__ */ attr2("x2")("19"),
            /* @__PURE__ */ attr2("y2")("12")
        ])
    ]);
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
    // output/Control.Promise/index.js
    var voidRight2 = /* @__PURE__ */ voidRight(functorEffect);
    var mempty2 = /* @__PURE__ */ mempty(monoidCanceler);
    var identity12 = /* @__PURE__ */ identity(categoryFn);
    var alt4 = /* @__PURE__ */ alt(/* @__PURE__ */ altExceptT(semigroupNonEmptyList)(monadIdentity));
    var unsafeReadTagged3 = /* @__PURE__ */ unsafeReadTagged(monadIdentity);
    var map24 = /* @__PURE__ */ map(/* @__PURE__ */ functorExceptT(functorIdentity));
    var readString3 = /* @__PURE__ */ readString(monadIdentity);
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
        })(identity12)(runExcept(alt4(unsafeReadTagged3("Error")(fn))(map24(error)(readString3(fn)))));
    };
    var toAff = /* @__PURE__ */ toAff$prime(coerce3);
    // output/TextConstants/index.js
    var show8 = /* @__PURE__ */ show(showInt);
    var routerConstants = {
        routePOS: "\u0E1A\u0E34\u0E25\u0E27\u0E31\u0E19\u0E19\u0E35\u0E49",
        routeCustomers: "\u0E23\u0E32\u0E22\u0E0A\u0E37\u0E48\u0E2D\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32"
    };
    var posConstants = {
        searchPlaceholder: "\u0E04\u0E49\u0E19\u0E2B\u0E32\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32",
        todaysBillsTitle: function(n) {
            return "\u0E1A\u0E34\u0E25\u0E27\u0E31\u0E19\u0E19\u0E35\u0E49 (" + (show8(n) + ")");
        },
        columnTime: "\u0E40\u0E27\u0E25\u0E32",
        columnCustomerName: "\u0E0A\u0E37\u0E48\u0E2D\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32",
        noCustomersFound: "\u0E44\u0E21\u0E48\u0E1E\u0E1A\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32"
    };
    var customerListConstants = {
        appTitle: "\u0E23\u0E32\u0E22\u0E0A\u0E37\u0E48\u0E2D\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32",
        customersCount: function(n) {
            return show8(n) + " \u0E23\u0E32\u0E22";
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
        var tag = Object.prototype.toString.call(value16);
        if (tag.indexOf("[object HTML") === 0 && tag.indexOf("Element]") === tag.length - 8) return just(value16);
        else return nothing;
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
    var type_4 = /* @__PURE__ */ type_3(isPropInputType);
    var value4 = /* @__PURE__ */ value3(isPropString);
    var type_1 = /* @__PURE__ */ type_3(isPropButtonType);
    var show9 = /* @__PURE__ */ show(showInt);
    var map25 = /* @__PURE__ */ map(functorArray);
    var append5 = /* @__PURE__ */ append(semigroupArray);
    var compare2 = /* @__PURE__ */ compare(ordString);
    var show13 = /* @__PURE__ */ show(showNumber);
    var max4 = /* @__PURE__ */ max(ordInt);
    var min4 = /* @__PURE__ */ min(ordInt);
    var compare12 = /* @__PURE__ */ compare(ordInt);
    var compare22 = /* @__PURE__ */ compare(ordNumber);
    var bind7 = /* @__PURE__ */ bind(bindHalogenM);
    var lift5 = /* @__PURE__ */ lift(monadTransHalogenM);
    var discard4 = /* @__PURE__ */ discard(discardUnit)(bindHalogenM);
    var modify_5 = /* @__PURE__ */ modify_2(monadStateHalogenM);
    var get7 = /* @__PURE__ */ get(monadStateHalogenM);
    var when2 = /* @__PURE__ */ when(applicativeHalogenM);
    var pure13 = /* @__PURE__ */ pure(applicativeHalogenM);
    var $$void6 = /* @__PURE__ */ $$void(functorHalogenM);
    var bind13 = /* @__PURE__ */ bind(bindMaybe);
    var max1 = /* @__PURE__ */ max(ordNumber);
    var eq4 = /* @__PURE__ */ eq(/* @__PURE__ */ eqMaybe(eqInt));
    var mod3 = /* @__PURE__ */ mod(euclideanRingInt);
    var SortById = /* @__PURE__ */ function() {
        function SortById2() {}
        SortById2.value = new SortById2();
        return SortById2;
    }();
    var SortByName = /* @__PURE__ */ function() {
        function SortByName2() {}
        SortByName2.value = new SortByName2();
        return SortByName2;
    }();
    var SortByMoneyDebit = /* @__PURE__ */ function() {
        function SortByMoneyDebit2() {}
        SortByMoneyDebit2.value = new SortByMoneyDebit2();
        return SortByMoneyDebit2;
    }();
    var SortByMoneyCredit = /* @__PURE__ */ function() {
        function SortByMoneyCredit2() {}
        SortByMoneyCredit2.value = new SortByMoneyCredit2();
        return SortByMoneyCredit2;
    }();
    var SortByGoldJewelryDebit = /* @__PURE__ */ function() {
        function SortByGoldJewelryDebit2() {}
        SortByGoldJewelryDebit2.value = new SortByGoldJewelryDebit2();
        return SortByGoldJewelryDebit2;
    }();
    var SortByGoldJewelryCredit = /* @__PURE__ */ function() {
        function SortByGoldJewelryCredit2() {}
        SortByGoldJewelryCredit2.value = new SortByGoldJewelryCredit2();
        return SortByGoldJewelryCredit2;
    }();
    var SortByGoldBar96Debit = /* @__PURE__ */ function() {
        function SortByGoldBar96Debit2() {}
        SortByGoldBar96Debit2.value = new SortByGoldBar96Debit2();
        return SortByGoldBar96Debit2;
    }();
    var SortByGoldBar96Credit = /* @__PURE__ */ function() {
        function SortByGoldBar96Credit2() {}
        SortByGoldBar96Credit2.value = new SortByGoldBar96Credit2();
        return SortByGoldBar96Credit2;
    }();
    var SortByGoldBar99Debit = /* @__PURE__ */ function() {
        function SortByGoldBar99Debit2() {}
        SortByGoldBar99Debit2.value = new SortByGoldBar99Debit2();
        return SortByGoldBar99Debit2;
    }();
    var SortByGoldBar99Credit = /* @__PURE__ */ function() {
        function SortByGoldBar99Credit2() {}
        SortByGoldBar99Credit2.value = new SortByGoldBar99Credit2();
        return SortByGoldBar99Credit2;
    }();
    var SortByUpdated = /* @__PURE__ */ function() {
        function SortByUpdated2() {}
        SortByUpdated2.value = new SortByUpdated2();
        return SortByUpdated2;
    }();
    var Ascending = /* @__PURE__ */ function() {
        function Ascending2() {}
        Ascending2.value = new Ascending2();
        return Ascending2;
    }();
    var Descending = /* @__PURE__ */ function() {
        function Descending2() {}
        Descending2.value = new Descending2();
        return Descending2;
    }();
    var CustomerCountChanged = /* @__PURE__ */ function() {
        function CustomerCountChanged2(value0) {
            this.value0 = value0;
        }
        CustomerCountChanged2.create = function(value0) {
            return new CustomerCountChanged2(value0);
        };
        return CustomerCountChanged2;
    }();
    var FieldName = /* @__PURE__ */ function() {
        function FieldName2() {}
        FieldName2.value = new FieldName2();
        return FieldName2;
    }();
    var FieldMoney = /* @__PURE__ */ function() {
        function FieldMoney2() {}
        FieldMoney2.value = new FieldMoney2();
        return FieldMoney2;
    }();
    var FieldGoldJewelryGrams = /* @__PURE__ */ function() {
        function FieldGoldJewelryGrams2() {}
        FieldGoldJewelryGrams2.value = new FieldGoldJewelryGrams2();
        return FieldGoldJewelryGrams2;
    }();
    var FieldGoldJewelryBaht = /* @__PURE__ */ function() {
        function FieldGoldJewelryBaht2() {}
        FieldGoldJewelryBaht2.value = new FieldGoldJewelryBaht2();
        return FieldGoldJewelryBaht2;
    }();
    var FieldGoldBar96Grams = /* @__PURE__ */ function() {
        function FieldGoldBar96Grams2() {}
        FieldGoldBar96Grams2.value = new FieldGoldBar96Grams2();
        return FieldGoldBar96Grams2;
    }();
    var FieldGoldBar96Baht = /* @__PURE__ */ function() {
        function FieldGoldBar96Baht2() {}
        FieldGoldBar96Baht2.value = new FieldGoldBar96Baht2();
        return FieldGoldBar96Baht2;
    }();
    var FieldGoldBar99Grams = /* @__PURE__ */ function() {
        function FieldGoldBar99Grams2() {}
        FieldGoldBar99Grams2.value = new FieldGoldBar99Grams2();
        return FieldGoldBar99Grams2;
    }();
    var FieldGoldBar99Baht = /* @__PURE__ */ function() {
        function FieldGoldBar99Baht2() {}
        FieldGoldBar99Baht2.value = new FieldGoldBar99Baht2();
        return FieldGoldBar99Baht2;
    }();
    var Initialize4 = /* @__PURE__ */ function() {
        function Initialize6() {}
        Initialize6.value = new Initialize6();
        return Initialize6;
    }();
    var LoadCustomers = /* @__PURE__ */ function() {
        function LoadCustomers2() {}
        LoadCustomers2.value = new LoadCustomers2();
        return LoadCustomers2;
    }();
    var PollForChanges = /* @__PURE__ */ function() {
        function PollForChanges2() {}
        PollForChanges2.value = new PollForChanges2();
        return PollForChanges2;
    }();
    var ApplyChanges = /* @__PURE__ */ function() {
        function ApplyChanges2(value0) {
            this.value0 = value0;
        }
        ApplyChanges2.create = function(value0) {
            return new ApplyChanges2(value0);
        };
        return ApplyChanges2;
    }();
    var StartEditField = /* @__PURE__ */ function() {
        function StartEditField2(value0, value1, value22, value32) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
            this.value3 = value32;
        }
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
    }();
    var StartEditFieldWithEvent = /* @__PURE__ */ function() {
        function StartEditFieldWithEvent2(value0, value1, value22, value32, value42) {
            this.value0 = value0;
            this.value1 = value1;
            this.value2 = value22;
            this.value3 = value32;
            this.value4 = value42;
        }
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
    }();
    var UpdateEditValue = /* @__PURE__ */ function() {
        function UpdateEditValue2(value0) {
            this.value0 = value0;
        }
        UpdateEditValue2.create = function(value0) {
            return new UpdateEditValue2(value0);
        };
        return UpdateEditValue2;
    }();
    var SaveEditField = /* @__PURE__ */ function() {
        function SaveEditField2() {}
        SaveEditField2.value = new SaveEditField2();
        return SaveEditField2;
    }();
    var SaveEditOnEnter = /* @__PURE__ */ function() {
        function SaveEditOnEnter2(value0) {
            this.value0 = value0;
        }
        SaveEditOnEnter2.create = function(value0) {
            return new SaveEditOnEnter2(value0);
        };
        return SaveEditOnEnter2;
    }();
    var CancelEdit = /* @__PURE__ */ function() {
        function CancelEdit2() {}
        CancelEdit2.value = new CancelEdit2();
        return CancelEdit2;
    }();
    var CancelEditOnClickOutside = /* @__PURE__ */ function() {
        function CancelEditOnClickOutside2(value0) {
            this.value0 = value0;
        }
        CancelEditOnClickOutside2.create = function(value0) {
            return new CancelEditOnClickOutside2(value0);
        };
        return CancelEditOnClickOutside2;
    }();
    var UpdateNewName = /* @__PURE__ */ function() {
        function UpdateNewName2(value0) {
            this.value0 = value0;
        }
        UpdateNewName2.create = function(value0) {
            return new UpdateNewName2(value0);
        };
        return UpdateNewName2;
    }();
    var AddCustomer = /* @__PURE__ */ function() {
        function AddCustomer2(value0) {
            this.value0 = value0;
        }
        AddCustomer2.create = function(value0) {
            return new AddCustomer2(value0);
        };
        return AddCustomer2;
    }();
    var ShowDeleteConfirmation = /* @__PURE__ */ function() {
        function ShowDeleteConfirmation2(value0) {
            this.value0 = value0;
        }
        ShowDeleteConfirmation2.create = function(value0) {
            return new ShowDeleteConfirmation2(value0);
        };
        return ShowDeleteConfirmation2;
    }();
    var UpdateDeleteConfirmInput = /* @__PURE__ */ function() {
        function UpdateDeleteConfirmInput2(value0) {
            this.value0 = value0;
        }
        UpdateDeleteConfirmInput2.create = function(value0) {
            return new UpdateDeleteConfirmInput2(value0);
        };
        return UpdateDeleteConfirmInput2;
    }();
    var ConfirmDelete = /* @__PURE__ */ function() {
        function ConfirmDelete2(value0) {
            this.value0 = value0;
        }
        ConfirmDelete2.create = function(value0) {
            return new ConfirmDelete2(value0);
        };
        return ConfirmDelete2;
    }();
    var CancelDelete = /* @__PURE__ */ function() {
        function CancelDelete2() {}
        CancelDelete2.value = new CancelDelete2();
        return CancelDelete2;
    }();
    var FocusDeleteInput = /* @__PURE__ */ function() {
        function FocusDeleteInput2() {}
        FocusDeleteInput2.value = new FocusDeleteInput2();
        return FocusDeleteInput2;
    }();
    var FocusEditInput = /* @__PURE__ */ function() {
        function FocusEditInput2() {}
        FocusEditInput2.value = new FocusEditInput2();
        return FocusEditInput2;
    }();
    var SortBy = /* @__PURE__ */ function() {
        function SortBy2(value0) {
            this.value0 = value0;
        }
        SortBy2.create = function(value0) {
            return new SortBy2(value0);
        };
        return SortBy2;
    }();
    var HandleScroll = /* @__PURE__ */ function() {
        function HandleScroll2(value0) {
            this.value0 = value0;
        }
        HandleScroll2.create = function(value0) {
            return new HandleScroll2(value0);
        };
        return HandleScroll2;
    }();
    var ScrollToCustomer = /* @__PURE__ */ function() {
        function ScrollToCustomer2(value0) {
            this.value0 = value0;
        }
        ScrollToCustomer2.create = function(value0) {
            return new ScrollToCustomer2(value0);
        };
        return ScrollToCustomer2;
    }();
    var ScrollToCustomerId = /* @__PURE__ */ function() {
        function ScrollToCustomerId2(value0) {
            this.value0 = value0;
        }
        ScrollToCustomerId2.create = function(value0) {
            return new ScrollToCustomerId2(value0);
        };
        return ScrollToCustomerId2;
    }();
    var UpdateSearchQuery = /* @__PURE__ */ function() {
        function UpdateSearchQuery3(value0) {
            this.value0 = value0;
        }
        UpdateSearchQuery3.create = function(value0) {
            return new UpdateSearchQuery3(value0);
        };
        return UpdateSearchQuery3;
    }();
    var MeasureRenderedRows = /* @__PURE__ */ function() {
        function MeasureRenderedRows2() {}
        MeasureRenderedRows2.value = new MeasureRenderedRows2();
        return MeasureRenderedRows2;
    }();
    var UpdateRenderedRange = /* @__PURE__ */ function() {
        function UpdateRenderedRange2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        UpdateRenderedRange2.create = function(value0) {
            return function(value1) {
                return new UpdateRenderedRange2(value0, value1);
            };
        };
        return UpdateRenderedRange2;
    }();
    var RenderAroundAndScrollTo = /* @__PURE__ */ function() {
        function RenderAroundAndScrollTo2(value0) {
            this.value0 = value0;
        }
        RenderAroundAndScrollTo2.create = function(value0) {
            return new RenderAroundAndScrollTo2(value0);
        };
        return RenderAroundAndScrollTo2;
    }();
    var trimTrailingZeros = function($copy_s) {
        var $tco_done = false;
        var $tco_result;
        function $tco_loop(s2) {
            var len = length3(s2);
            var $141 = len === 0;
            if ($141) {
                $tco_done = true;
                return s2;
            }
            var $142 = takeRight(1)(s2) === "0";
            if ($142) {
                $copy_s = dropRight(1)(s2);
                return;
            }
            $tco_done = true;
            return s2;
        }
        while(!$tco_done)$tco_result = $tco_loop($copy_s);
        return $tco_result;
    };
    var toggleDirection = function(v2) {
        if (v2 instanceof Ascending) return Descending.value;
        if (v2 instanceof Descending) return Ascending.value;
        throw new Error("Failed pattern match at Component.CustomerList (line 73, column 1 - line 73, column 50): " + [
            v2.constructor.name
        ]);
    };
    var textConstants = customerListConstants;
    var renderTableFooter = function(state3) {
        return div3([
            class_("table-footer")
        ])([
            form([
                class_("add-customer-form"),
                onSubmit(AddCustomer.create)
            ])([
                input([
                    type_4(InputText.value),
                    class_("new-customer-input"),
                    placeholder2(textConstants.newCustomerPlaceholder),
                    value4(state3.newCustomerName),
                    onValueInput(UpdateNewName.create)
                ]),
                button([
                    type_1(ButtonSubmit.value),
                    class_("btn btn-add"),
                    title("Add Customer")
                ])([
                    addIcon
                ])
            ])
        ]);
    };
    var renderStyles = /* @__PURE__ */ style_([
        /* @__PURE__ */ text("\n      * {\n        box-sizing: border-box;\n      }\n      \n      body {\n        margin: 0;\n        padding: 0;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',\n          'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',\n          sans-serif;\n        -webkit-font-smoothing: antialiased;\n        -moz-osx-font-smoothing: grayscale;\n        overflow: hidden;\n        height: 100vh;\n      }\n      \n      .app-wrapper {\n        width: 100%;\n        height: 100vh;\n        overflow: hidden;\n      }\n      \n      .customer-app {\n        width: 100%;\n        padding: 8px;\n        height: calc(100vh - 38px);\n        display: flex;\n        flex-direction: column;\n      }\n      \n      .customer-list-container {\n        border: 1px solid #ddd;\n        border-radius: 4px;\n        overflow: hidden;\n        flex: 1;\n        display: flex;\n        flex-direction: column;\n        min-height: 0;\n      }\n      \n      .table-header-container {\n        background-color: #f8f9fa;\n        border-bottom: 2px solid #dee2e6;\n      }\n      \n      .table-header-row1,\n      .table-header-row2 {\n        display: grid;\n        grid-template-columns: 50px 200px 90px 90px 100px 100px 100px 100px 100px 100px 90px 100px;\n        align-items: center;\n        padding: 4px 8px;\n        font-weight: 600;\n        color: #495057;\n        gap: 8px;\n        font-size: 12px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .table-header-row1 {\n        border-bottom: 1px solid #dee2e6;\n      }\n      \n      .table-header-row1 .header-cell {\n        justify-content: center;\n      }\n      \n      .header-money-merged {\n        grid-column: span 2;\n        text-align: center;\n      }\n      \n      .header-gold-acc-merged {\n        grid-column: span 2;\n        text-align: center;\n      }\n      \n      .header-gold-965-merged {\n        grid-column: span 2;\n        text-align: center;\n      }\n      \n      .header-gold-9999-merged {\n        grid-column: span 2;\n        text-align: center;\n      }\n      \n      .header-cell {\n        display: flex;\n        align-items: center;\n        padding: 2px;\n        border-right: 1px solid #dee2e6;\n      }\n      \n      .header-cell:last-child {\n        border-right: none;\n      }\n      \n      .header-debit,\n      .header-credit {\n        justify-content: flex-end;\n      }\n      \n      .header-id {\n        min-width: 50px;\n      }\n      \n      .header-name {\n        min-width: 150px;\n      }\n      \n      .header-name-content {\n        display: flex;\n        align-items: center;\n        gap: 6px;\n        width: 100%;\n      }\n      \n      .search-input {\n        flex: 1;\n        padding: 3px 6px;\n        border: 1px solid #ced4da;\n        border-radius: 3px;\n        font-size: 12px;\n        min-width: 80px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .search-input:focus {\n        outline: none;\n        border-color: #007bff;\n        box-shadow: 0 0 0 1px rgba(0, 123, 255, 0.2);\n      }\n      \n      .header-actions {\n        min-width: 100px;\n        justify-content: center;\n      }\n      \n      .sort-button {\n        background: none;\n        border: none;\n        cursor: pointer;\n        padding: 2px 4px;\n        display: flex;\n        align-items: center;\n        gap: 4px;\n        color: #495057;\n        font-weight: 600;\n        font-size: 12px;\n        transition: color 0.2s;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .sort-button:hover {\n        color: #007bff;\n      }\n      \n      .customer-list {\n        flex: 1;\n        overflow-y: scroll;\n        overflow-x: auto;\n        background-color: #fff;\n        position: relative;\n        min-height: 0;\n      }\n      \n      .scroll-spacer {\n        width: 100%;\n        pointer-events: none;\n      }\n      \n      .visible-rows {\n        position: absolute;\n        top: 0;\n        left: 0;\n        right: 0;\n        will-change: transform;\n      }\n      \n      .customer-row {\n        display: grid;\n        grid-template-columns: 50px 200px 90px 90px 100px 100px 100px 100px 100px 100px 90px 100px;\n        align-items: center;\n        padding: 6px 8px;\n        border-bottom: 1px solid #eee;\n        gap: 8px;\n        min-height: 36px;\n        box-sizing: border-box;\n        font-size: 12px;\n      }\n      \n      .customer-row > * {\n        border-right: 1px solid #eee;\n        padding-right: 8px;\n      }\n      \n      .customer-row > *:last-child {\n        border-right: none;\n      }\n      \n      .customer-row:last-child {\n        border-bottom: none;\n      }\n      \n      .customer-row-even {\n        background-color: #ffffff;\n      }\n      \n      .customer-row-odd {\n        background-color: #f9f9f9;\n      }\n      \n      .customer-row:hover {\n        background-color: #f0f0f0 !important;\n      }\n      \n      .customer-row-highlighted {\n        background-color: #f5e6d3 !important;\n        transition: background-color 0.3s ease;\n      }\n      \n      .customer-row-highlighted:hover {\n        background-color: #ead5bb !important;\n      }\n      \n      .customer-row-pending-delete {\n        background-color: #d4a59a !important;\n        transition: background-color 0.3s ease;\n      }\n      \n      .customer-row-pending-delete:hover {\n        background-color: #c99388 !important;\n      }\n      \n      .customer-id {\n        font-weight: bold;\n        color: #666;\n        padding: 2px;\n        text-align: right;\n      }\n      \n      .customer-name {\n        color: #333;\n        word-wrap: break-word;\n        overflow-wrap: break-word;\n        hyphens: auto;\n        padding: 2px;\n        cursor: pointer;\n        border-radius: 3px;\n        transition: background-color 0.2s ease;\n      }\n      \n      .customer-name:hover {\n        background-color: #e3f2fd;\n        box-shadow: 0 0 0 1px #90caf9;\n      }\n      \n      .editable-field {\n        cursor: pointer;\n        border-radius: 3px;\n        transition: background-color 0.2s ease;\n        padding: 2px 4px;\n        min-height: 20px;\n        display: inline-block;\n      }\n      \n      .editable-field:hover {\n        background-color: #e3f2fd;\n        box-shadow: 0 0 0 1px #90caf9;\n      }\n      \n      .gold-grams .editable-field,\n      .gold-baht .editable-field {\n        display: block;\n        width: 100%;\n        box-sizing: border-box;\n      }\n      \n      .field-warning {\n        background-color: #d4a59a !important;\n        animation: pulse-warning 1s ease-in-out infinite;\n      }\n      \n      @keyframes pulse-warning {\n        0%, 100% {\n          background-color: #d4a59a;\n        }\n        50% {\n          background-color: #c99388;\n        }\n      }\n      \n      .money-input {\n        width: 80px;\n        padding: 2px 4px;\n        border: 2px solid #007bff;\n        border-radius: 3px;\n        font-size: 12px;\n        text-align: right;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .gold-input-container {\n        display: flex;\n        align-items: center;\n        gap: 4px;\n      }\n      \n      .gold-input {\n        width: 70px;\n        padding: 2px 4px;\n        border: 2px solid #007bff;\n        border-radius: 3px;\n        font-size: 12px;\n        text-align: right;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .gold-unit {\n        font-size: 12px;\n        color: #666;\n        font-weight: 500;\n      }\n      \n      .customer-name-input {\n        width: 100%;\n        padding: 4px 6px;\n        border: 2px solid #007bff;\n        border-radius: 3px;\n        font-size: 12px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .customer-name-input:focus {\n        outline: none;\n        border-color: #0056b3;\n      }\n      \n      .customer-money-debit,\n      .customer-money-credit {\n        text-align: right;\n        padding: 2px 4px;\n        color: #333;\n      }\n      \n      .customer-money-debit {\n        color: #dc3545;\n      }\n      \n      .customer-money-credit {\n        color: #28a745;\n      }\n      \n      .money-value {\n        white-space: nowrap;\n      }\n      \n      .money-integer {\n        font-size: 12px;\n      }\n      \n      .money-decimal,\n      .money-fraction {\n        font-size: 9px;\n        vertical-align: baseline;\n      }\n      \n      /* Make .00 fraction and decimal point blend with background for right alignment */\n      .money-decimal-zero,\n      .money-fraction-zero {\n        color: transparent;\n      }\n      \n      /* Default row backgrounds */\n      .customer-row-even .money-decimal-zero,\n      .customer-row-even .money-fraction-zero {\n        color: #ffffff;\n      }\n      \n      .customer-row-odd .money-decimal-zero,\n      .customer-row-odd .money-fraction-zero {\n        color: #f9f9f9;\n      }\n      \n      /* Hover state */\n      .customer-row:hover .money-decimal-zero,\n      .customer-row:hover .money-fraction-zero {\n        color: #f0f0f0;\n      }\n      \n      /* Highlighted row (newly added/edited) */\n      .customer-row-highlighted .money-decimal-zero,\n      .customer-row-highlighted .money-fraction-zero {\n        color: #f5e6d3;\n      }\n      \n      .customer-row-highlighted:hover .money-decimal-zero,\n      .customer-row-highlighted:hover .money-fraction-zero {\n        color: #ead5bb;\n      }\n      \n      /* Pending delete row */\n      .customer-row-pending-delete .money-decimal-zero,\n      .customer-row-pending-delete .money-fraction-zero {\n        color: #d4a59a;\n      }\n      \n      .customer-row-pending-delete:hover .money-decimal-zero,\n      .customer-row-pending-delete:hover .money-fraction-zero {\n        color: #c99388;\n      }\n      \n      /* Warning field (opposite side being edited) */\n      .field-warning .money-decimal-zero,\n      .field-warning .money-fraction-zero {\n        color: #d4a59a;\n        animation: pulse-warning-text 1s ease-in-out infinite;\n      }\n      \n      @keyframes pulse-warning-text {\n        0%, 100% {\n          color: #d4a59a;\n        }\n        50% {\n          color: #c99388;\n        }\n      }\n      \n      .customer-gold-debit,\n      .customer-gold-credit {\n        text-align: right;\n        padding: 2px 4px;\n        font-size: 12px;\n        line-height: 1.3;\n      }\n      \n      .customer-gold-debit {\n        color: #dc3545;\n      }\n      \n      .customer-gold-credit {\n        color: #28a745;\n      }\n      \n      .gold-grams {\n        font-weight: 500;\n      }\n      \n      .gold-baht {\n        font-size: 12px;\n      }\n      \n      .customer-gold-debit .gold-baht {\n        color: #dc3545;\n      }\n      \n      .customer-gold-credit .gold-baht {\n        color: #28a745;\n      }\n      \n      .baht-value {\n        white-space: nowrap;\n        font-size: 12px;\n      }\n      \n      .baht-integer,\n      .baht-unit {\n        font-size: 12px;\n      }\n      \n      .baht-fraction {\n        font-size: 12px;\n        vertical-align: baseline;\n      }\n      \n      .grams-value {\n        white-space: nowrap;\n      }\n      \n      .grams-integer,\n      .grams-unit {\n        font-size: 12px;\n      }\n      \n      .grams-decimal,\n      .grams-fraction {\n        font-size: 12px;\n        vertical-align: baseline;\n      }\n      \n      .customer-updated {\n        font-size: 12px;\n        color: #666;\n        padding: 2px;\n        text-align: center;\n      }\n      \n      .customer-actions {\n        display: flex;\n        gap: 4px;\n        justify-content: center;\n      }\n      \n      .btn {\n        padding: 4px 6px;\n        border: none;\n        border-radius: 3px;\n        cursor: pointer;\n        font-size: 12px;\n        font-weight: 500;\n        transition: all 0.2s;\n        display: flex;\n        align-items: center;\n        gap: 4px;\n      }\n      \n      .btn:hover {\n        transform: translateY(-1px);\n        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);\n      }\n      \n      .btn-edit {\n        background-color: #007bff;\n        color: white;\n        padding: 4px 6px;\n      }\n      \n      .btn-edit:hover {\n        background-color: #0056b3;\n      }\n      \n      .btn-save {\n        background-color: #28a745;\n        color: white;\n        padding: 4px 6px;\n      }\n      \n      .btn-save:hover {\n        background-color: #218838;\n      }\n      \n      .btn-delete {\n        background-color: #dc3545;\n        color: white;\n        padding: 4px 6px;\n      }\n      \n      .btn-delete:hover {\n        background-color: #c82333;\n      }\n      \n      .table-footer {\n        background-color: #f8f9fa;\n        border-top: 2px solid #dee2e6;\n      }\n      \n      .add-customer-form {\n        display: flex;\n        gap: 6px;\n        padding: 6px 8px;\n        align-items: center;\n      }\n      \n      .new-customer-input {\n        flex: 1;\n        padding: 4px 6px;\n        border: 1px solid #ddd;\n        border-radius: 3px;\n        font-size: 12px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .new-customer-input:focus {\n        outline: none;\n        border-color: #007bff;\n      }\n      \n      .btn-add {\n        background-color: #28a745;\n        color: white;\n        padding: 4px 6px;\n        min-width: 32px;\n      }\n      \n      .btn-add:hover {\n        background-color: #218838;\n      }\n      \n      /* Modal Dialog Styles */\n      .modal-overlay {\n        position: fixed;\n        top: 0;\n        left: 0;\n        right: 0;\n        bottom: 0;\n        background-color: rgba(0, 0, 0, 0.5);\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        z-index: 1000;\n      }\n      \n      .modal-dialog {\n        background: white;\n        border-radius: 8px;\n        padding: 24px;\n        max-width: 400px;\n        width: 90%;\n        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);\n      }\n      \n      .modal-title {\n        margin: 0 0 16px 0;\n        font-size: 20px;\n        font-weight: 600;\n        color: #333;\n      }\n      \n      .modal-message {\n        margin: 0 0 16px 0;\n        color: #666;\n        line-height: 1.5;\n      }\n      \n      .modal-code {\n        background: #f8f9fa;\n        border: 2px solid #dee2e6;\n        border-radius: 4px;\n        padding: 16px;\n        text-align: center;\n        font-size: 24px;\n        font-weight: 700;\n        color: #dc3545;\n        margin-bottom: 16px;\n        letter-spacing: 2px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .modal-input {\n        width: 100%;\n        padding: 12px;\n        border: 2px solid #dee2e6;\n        border-radius: 4px;\n        font-size: 16px;\n        margin-bottom: 16px;\n        text-align: center;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n        letter-spacing: 1px;\n      }\n      \n      .modal-input:focus {\n        outline: none;\n        border-color: #0056b3;\n      }\n      \n      .modal-buttons {\n        display: flex;\n        gap: 12px;\n        justify-content: flex-end;\n      }\n      \n      .btn-confirm {\n        background-color: #dc3545;\n        color: white;\n        padding: 10px 20px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .btn-confirm:hover {\n        background-color: #c82333;\n      }\n      \n      .btn-cancel {\n        background-color: #6c757d;\n        color: white;\n        padding: 10px 20px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .btn-cancel:hover {\n        background-color: #5a6268;\n      }\n    ")
    ]);
    var renderMoney = function(n) {
        var absN = abs(n);
        var formatted = formatMoneyValue(absN);
        var isInteger = formatted.fraction === "00";
        var decimalClass = function() {
            if (isInteger) return "money-decimal money-decimal-zero";
            return "money-decimal";
        }();
        var fractionClass = function() {
            if (isInteger) return "money-fraction money-fraction-zero";
            return "money-fraction";
        }();
        return span3([
            class_("money-value")
        ])([
            span3([
                class_("money-integer")
            ])([
                text(formatted.integer)
            ]),
            span3([
                class_(decimalClass)
            ])([
                text(".")
            ]),
            span3([
                class_(fractionClass)
            ])([
                text(formatted.fraction)
            ])
        ]);
    };
    var renderGrams = function(n) {
        var absN = abs(n);
        var formatted = formatGramsValue(absN);
        var $146 = formatted.integer === "";
        if ($146) return text("");
        return span3([
            class_("grams-value")
        ])([
            span3([
                class_("grams-integer")
            ])([
                text(formatted.integer)
            ]),
            span3([
                class_("grams-decimal")
            ])([
                text(".")
            ]),
            span3([
                class_("grams-fraction")
            ])([
                text(formatted.fraction)
            ]),
            span3([
                class_("grams-unit")
            ])([
                text(textConstants.unitGrams)
            ])
        ]);
    };
    var renderDeleteConfirmationDialog = function(state3) {
        if (state3.deleteConfirmation instanceof Nothing) return text("");
        if (state3.deleteConfirmation instanceof Just) return div3([
            class_("modal-overlay")
        ])([
            div3([
                class_("modal-dialog")
            ])([
                h2([
                    class_("modal-title")
                ])([
                    text(textConstants.deleteConfirmTitle)
                ]),
                p([
                    class_("modal-message")
                ])([
                    text(textConstants.deleteConfirmPrompt)
                ]),
                div3([
                    class_("modal-code")
                ])([
                    text(show9(state3.deleteConfirmation.value0.confirmCode))
                ]),
                input([
                    type_4(InputText.value),
                    class_("modal-input"),
                    placeholder2(textConstants.deleteConfirmPrompt),
                    value4(state3.deleteConfirmation.value0.inputValue),
                    onValueInput(UpdateDeleteConfirmInput.create),
                    onKeyDown(function(e) {
                        var $148 = key(e) === "Enter";
                        if ($148) return new ConfirmDelete(state3.deleteConfirmation.value0.customerId);
                        var $149 = key(e) === "Escape";
                        if ($149) return CancelDelete.value;
                        return new UpdateDeleteConfirmInput(state3.deleteConfirmation.value0.inputValue);
                    })
                ]),
                div3([
                    class_("modal-buttons")
                ])([
                    button([
                        class_("btn btn-confirm"),
                        onClick(function(v2) {
                            return new ConfirmDelete(state3.deleteConfirmation.value0.customerId);
                        })
                    ])([
                        text(textConstants.buttonConfirm)
                    ]),
                    button([
                        class_("btn btn-cancel"),
                        onClick(function(v2) {
                            return CancelDelete.value;
                        })
                    ])([
                        text(textConstants.buttonCancel)
                    ])
                ])
            ])
        ]);
        throw new Error("Failed pattern match at Component.CustomerList (line 954, column 3 - line 998, column 10): " + [
            state3.deleteConfirmation.constructor.name
        ]);
    };
    var renderBaht = function(n) {
        var absN = abs(n);
        var formatted = formatBahtValue(absN);
        var $151 = formatted.integer === "";
        if ($151) return text("");
        return span3([
            class_("baht-value")
        ])([
            span3([
                class_("baht-integer")
            ])([
                text(formatted.integer)
            ]),
            function() {
                if (formatted.hasFraction) return span3([
                    class_("baht-fraction")
                ])([
                    text(formatted.fraction)
                ]);
                return text("");
            }(),
            span3([
                class_("baht-unit")
            ])([
                text(textConstants.unitBaht)
            ])
        ]);
    };
    var overscan = 10;
    var mergeCustomers = function(existing) {
        return function(changes) {
            var updated = map25(function(c2) {
                var v2 = findIndex(function(ch) {
                    return ch.id === c2.id;
                })(changes);
                if (v2 instanceof Just) {
                    var v1 = index(changes)(v2.value0);
                    if (v1 instanceof Just) {
                        var $155 = v1.value0.name !== c2.name;
                        if ($155) return v1.value0;
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
                    if (v1 instanceof Nothing) return c2;
                    throw new Error("Failed pattern match at Component.CustomerList (line 332, column 21 - line 339, column 23): " + [
                        v1.constructor.name
                    ]);
                }
                if (v2 instanceof Nothing) return c2;
                throw new Error("Failed pattern match at Component.CustomerList (line 331, column 7 - line 340, column 21): " + [
                    v2.constructor.name
                ]);
            })(existing);
            var newCustomers = filter(function(ch) {
                var v2 = findIndex(function(c2) {
                    return c2.id === ch.id;
                })(existing);
                if (v2 instanceof Just) return false;
                if (v2 instanceof Nothing) return true;
                throw new Error("Failed pattern match at Component.CustomerList (line 345, column 7 - line 347, column 24): " + [
                    v2.constructor.name
                ]);
            })(changes);
            return append5(updated)(newCustomers);
        };
    };
    var isPositive = function(n) {
        return n > 0;
    };
    var isNegative = function(n) {
        return n < 0;
    };
    var parseNumber2 = function(value1) {
        return function(maxDecimals) {
            var v2 = fromString(value1);
            if (v2 instanceof Nothing) return Nothing.value;
            if (v2 instanceof Just) {
                var $161 = isNegative(v2.value0);
                if ($161) return Nothing.value;
                var parts = split(".")(value1);
                if (parts.length === 1) return new Just(value1);
                if (parts.length === 2) {
                    var $164 = length4(parts[1]) <= maxDecimals;
                    if ($164) return new Just(value1);
                    return Nothing.value;
                }
                return Nothing.value;
            }
            throw new Error("Failed pattern match at Component.CustomerList (line 140, column 3 - line 152, column 23): " + [
                v2.constructor.name
            ]);
        };
    };
    var parseFieldValue = function(v2) {
        return function(v1) {
            if (v2 instanceof FieldName) {
                var $170 = v1 === "";
                if ($170) return Nothing.value;
                return new Just(v1);
            }
            if (v2 instanceof FieldMoney) return parseNumber2(v1)(2);
            if (v2 instanceof FieldGoldJewelryGrams) return parseNumber2(v1)(3);
            if (v2 instanceof FieldGoldJewelryBaht) return parseNumber2(v1)(3);
            if (v2 instanceof FieldGoldBar96Grams) return parseNumber2(v1)(3);
            if (v2 instanceof FieldGoldBar96Baht) return parseNumber2(v1)(3);
            if (v2 instanceof FieldGoldBar99Grams) return parseNumber2(v1)(3);
            if (v2 instanceof FieldGoldBar99Baht) return parseNumber2(v1)(3);
            throw new Error("Failed pattern match at Component.CustomerList (line 126, column 1 - line 126, column 59): " + [
                v2.constructor.name,
                v1.constructor.name
            ]);
        };
    };
    var gramsPerBahtJewelry = 15.24;
    var gramsPerBahtBar99 = 15.244;
    var gramsPerBahtBar96 = 15.244;
    var getLatestTimestamp = function(customers) {
        if (customers.length === 0) return Nothing.value;
        var timestamps = catMaybes(map25(function(v3) {
            return v3.updated_at;
        })(customers));
        var v2 = sortBy(compare2)(timestamps);
        if (v2.length === 0) return Nothing.value;
        return last(v2);
    };
    var getDbFieldName = function(v2) {
        if (v2 instanceof FieldName) return "name";
        if (v2 instanceof FieldMoney) return "money";
        if (v2 instanceof FieldGoldJewelryGrams) return "gram_jewelry";
        if (v2 instanceof FieldGoldJewelryBaht) return "baht_jewelry";
        if (v2 instanceof FieldGoldBar96Grams) return "gram_bar96";
        if (v2 instanceof FieldGoldBar96Baht) return "baht_bar96";
        if (v2 instanceof FieldGoldBar99Grams) return "gram_bar99";
        if (v2 instanceof FieldGoldBar99Baht) return "baht_bar99";
        throw new Error("Failed pattern match at Component.CustomerList (line 115, column 1 - line 115, column 42): " + [
            v2.constructor.name
        ]);
    };
    var getCustomerListElement = function __do2() {
        var nullable2 = getCustomerListElementImpl();
        return toMaybe(nullable2);
    };
    var formatNumberForEdit = function(n) {
        var str = show13(n);
        var trimmed = trimTrailingZeros(str);
        var $174 = takeRight(1)(trimmed) === ".";
        if ($174) return dropRight(1)(trimmed);
        return trimmed;
    };
    var getFieldValue = function(v2) {
        return function(v1) {
            if (v2 instanceof FieldName) return v1.name;
            if (v2 instanceof FieldMoney) return formatNumberForEdit(v1.money);
            if (v2 instanceof FieldGoldJewelryGrams) return formatNumberForEdit(v1.gram_jewelry);
            if (v2 instanceof FieldGoldJewelryBaht) return formatNumberForEdit(v1.baht_jewelry);
            if (v2 instanceof FieldGoldBar96Grams) return formatNumberForEdit(v1.gram_bar96);
            if (v2 instanceof FieldGoldBar96Baht) return formatNumberForEdit(v1.baht_bar96);
            if (v2 instanceof FieldGoldBar99Grams) return formatNumberForEdit(v1.gram_bar99);
            if (v2 instanceof FieldGoldBar99Baht) return formatNumberForEdit(v1.baht_bar99);
            throw new Error("Failed pattern match at Component.CustomerList (line 104, column 1 - line 104, column 53): " + [
                v2.constructor.name,
                v1.constructor.name
            ]);
        };
    };
    var filterCustomers = function(v2) {
        return function(v1) {
            if (v2 === "") return v1;
            return filter(function(c2) {
                return contains(toLower(v2))(toLower(c2.name));
            })(v1);
        };
    };
    var extractDatePart = function(v2) {
        if (v2 instanceof Nothing) return "";
        if (v2 instanceof Just) {
            var v1 = split("T")(v2.value0);
            if (v1.length === 2) return v1[0];
            return v2.value0;
        }
        throw new Error("Failed pattern match at Component.CustomerList (line 156, column 1 - line 156, column 42): " + [
            v2.constructor.name
        ]);
    };
    var eqSortField = {
        eq: function(x) {
            return function(y) {
                if (x instanceof SortById && y instanceof SortById) return true;
                if (x instanceof SortByName && y instanceof SortByName) return true;
                if (x instanceof SortByMoneyDebit && y instanceof SortByMoneyDebit) return true;
                if (x instanceof SortByMoneyCredit && y instanceof SortByMoneyCredit) return true;
                if (x instanceof SortByGoldJewelryDebit && y instanceof SortByGoldJewelryDebit) return true;
                if (x instanceof SortByGoldJewelryCredit && y instanceof SortByGoldJewelryCredit) return true;
                if (x instanceof SortByGoldBar96Debit && y instanceof SortByGoldBar96Debit) return true;
                if (x instanceof SortByGoldBar96Credit && y instanceof SortByGoldBar96Credit) return true;
                if (x instanceof SortByGoldBar99Debit && y instanceof SortByGoldBar99Debit) return true;
                if (x instanceof SortByGoldBar99Credit && y instanceof SortByGoldBar99Credit) return true;
                if (x instanceof SortByUpdated && y instanceof SortByUpdated) return true;
                return false;
            };
        }
    };
    var eq5 = /* @__PURE__ */ eq(eqSortField);
    var renderSortIcon = function(field) {
        return function(v2) {
            if (v2.field instanceof Just && eq5(v2.field.value0)(field)) {
                if (v2.direction instanceof Ascending) return sortAscIcon;
                if (v2.direction instanceof Descending) return sortDescIcon;
                throw new Error("Failed pattern match at Component.CustomerList (line 635, column 7 - line 637, column 41): " + [
                    v2.direction.constructor.name
                ]);
            }
            return sortNeutralIcon;
        };
    };
    var renderTableHeader = function(state3) {
        return div3([
            class_("table-header-container")
        ])([
            div3([
                class_("table-header-row1")
            ])([
                div3([
                    class_("header-cell header-id-row1")
                ])([]),
                div3([
                    class_("header-cell header-name-row1")
                ])([
                    button([
                        class_("sort-button"),
                        onClick(function(v2) {
                            return new SortBy(SortByName.value);
                        })
                    ])([
                        text(textConstants.columnName + " "),
                        renderSortIcon(SortByName.value)(state3.sortState)
                    ])
                ]),
                div3([
                    class_("header-cell header-money-merged")
                ])([
                    text(textConstants.columnMoney)
                ]),
                div3([
                    class_("header-cell header-gold-acc-merged")
                ])([
                    text(textConstants.columnGoldJewelry)
                ]),
                div3([
                    class_("header-cell header-gold-965-merged")
                ])([
                    text(textConstants.columnGoldBar96)
                ]),
                div3([
                    class_("header-cell header-gold-9999-merged")
                ])([
                    text(textConstants.columnGoldBar99)
                ]),
                div3([
                    class_("header-cell header-updated-row1")
                ])([]),
                div3([
                    class_("header-cell header-actions-row1")
                ])([
                    text(textConstants.columnActions)
                ])
            ]),
            div3([
                class_("table-header-row2")
            ])([
                div3([
                    class_("header-cell header-id-row2")
                ])([
                    button([
                        class_("sort-button"),
                        onClick(function(v2) {
                            return new SortBy(SortById.value);
                        })
                    ])([
                        text(textConstants.columnId + " "),
                        renderSortIcon(SortById.value)(state3.sortState)
                    ])
                ]),
                div3([
                    class_("header-cell header-name-row2")
                ])([
                    input([
                        type_4(InputText.value),
                        class_("search-input"),
                        placeholder2(textConstants.searchPlaceholder),
                        value4(state3.searchQuery),
                        onValueInput(UpdateSearchQuery.create)
                    ])
                ]),
                button([
                    class_("header-cell header-debit sort-button"),
                    onClick(function(v2) {
                        return new SortBy(SortByMoneyDebit.value);
                    })
                ])([
                    text(textConstants.headerDebit + " "),
                    renderSortIcon(SortByMoneyDebit.value)(state3.sortState)
                ]),
                button([
                    class_("header-cell header-credit sort-button"),
                    onClick(function(v2) {
                        return new SortBy(SortByMoneyCredit.value);
                    })
                ])([
                    text(textConstants.headerCredit + " "),
                    renderSortIcon(SortByMoneyCredit.value)(state3.sortState)
                ]),
                button([
                    class_("header-cell header-debit sort-button"),
                    onClick(function(v2) {
                        return new SortBy(SortByGoldJewelryDebit.value);
                    })
                ])([
                    text(textConstants.headerDebit + " "),
                    renderSortIcon(SortByGoldJewelryDebit.value)(state3.sortState)
                ]),
                button([
                    class_("header-cell header-credit sort-button"),
                    onClick(function(v2) {
                        return new SortBy(SortByGoldJewelryCredit.value);
                    })
                ])([
                    text(textConstants.headerCredit + " "),
                    renderSortIcon(SortByGoldJewelryCredit.value)(state3.sortState)
                ]),
                button([
                    class_("header-cell header-debit sort-button"),
                    onClick(function(v2) {
                        return new SortBy(SortByGoldBar96Debit.value);
                    })
                ])([
                    text(textConstants.headerDebit + " "),
                    renderSortIcon(SortByGoldBar96Debit.value)(state3.sortState)
                ]),
                button([
                    class_("header-cell header-credit sort-button"),
                    onClick(function(v2) {
                        return new SortBy(SortByGoldBar96Credit.value);
                    })
                ])([
                    text(textConstants.headerCredit + " "),
                    renderSortIcon(SortByGoldBar96Credit.value)(state3.sortState)
                ]),
                button([
                    class_("header-cell header-debit sort-button"),
                    onClick(function(v2) {
                        return new SortBy(SortByGoldBar99Debit.value);
                    })
                ])([
                    text(textConstants.headerDebit + " "),
                    renderSortIcon(SortByGoldBar99Debit.value)(state3.sortState)
                ]),
                button([
                    class_("header-cell header-credit sort-button"),
                    onClick(function(v2) {
                        return new SortBy(SortByGoldBar99Credit.value);
                    })
                ])([
                    text(textConstants.headerCredit + " "),
                    renderSortIcon(SortByGoldBar99Credit.value)(state3.sortState)
                ]),
                button([
                    class_("header-cell sort-button"),
                    onClick(function(v2) {
                        return new SortBy(SortByUpdated.value);
                    })
                ])([
                    text(textConstants.columnUpdated),
                    renderSortIcon(SortByUpdated.value)(state3.sortState)
                ]),
                div3([
                    class_("header-cell header-actions-row2")
                ])([])
            ])
        ]);
    };
    var eqEditableField = {
        eq: function(x) {
            return function(y) {
                if (x instanceof FieldName && y instanceof FieldName) return true;
                if (x instanceof FieldMoney && y instanceof FieldMoney) return true;
                if (x instanceof FieldGoldJewelryGrams && y instanceof FieldGoldJewelryGrams) return true;
                if (x instanceof FieldGoldJewelryBaht && y instanceof FieldGoldJewelryBaht) return true;
                if (x instanceof FieldGoldBar96Grams && y instanceof FieldGoldBar96Grams) return true;
                if (x instanceof FieldGoldBar96Baht && y instanceof FieldGoldBar96Baht) return true;
                if (x instanceof FieldGoldBar99Grams && y instanceof FieldGoldBar99Grams) return true;
                if (x instanceof FieldGoldBar99Baht && y instanceof FieldGoldBar99Baht) return true;
                return false;
            };
        }
    };
    var eq6 = /* @__PURE__ */ eq(eqEditableField);
    var notEq4 = /* @__PURE__ */ notEq(eqEditableField);
    var renderEditableField = function(state3) {
        return function(customer) {
            return function(field) {
                return function(displayClass) {
                    return function(inputClass) {
                        var isEditing = function() {
                            if (state3.editing instanceof Just) return state3.editing.value0.customerId === customer.id && eq6(state3.editing.value0.field)(field);
                            if (state3.editing instanceof Nothing) return false;
                            throw new Error("Failed pattern match at Component.CustomerList (line 706, column 17 - line 708, column 23): " + [
                                state3.editing.constructor.name
                            ]);
                        }();
                        var currentValue = getFieldValue(field)(customer);
                        var editValue = function() {
                            if (state3.editing instanceof Just && state3.editing.value0.customerId === customer.id && eq6(state3.editing.value0.field)(field)) return state3.editing.value0.value;
                            return currentValue;
                        }();
                        if (isEditing) return input([
                            type_4(InputText.value),
                            class_(inputClass),
                            value4(editValue),
                            onValueInput(UpdateEditValue.create),
                            onKeyDown(SaveEditOnEnter.create)
                        ]);
                        return span3([
                            class_(displayClass),
                            onClick(function(e) {
                                return new StartEditFieldWithEvent(customer.id, field, currentValue, false, e);
                            })
                        ])([
                            text(currentValue)
                        ]);
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
                                var shouldShowValue = function() {
                                    if (isDebit) return value1 <= 0;
                                    return value1 >= 0;
                                }();
                                var isEditingThisSide = function() {
                                    if (state3.editing instanceof Just) return state3.editing.value0.customerId === customer.id && eq6(state3.editing.value0.field)(field) && state3.editing.value0.isDebitSide === isDebit;
                                    if (state3.editing instanceof Nothing) return false;
                                    throw new Error("Failed pattern match at Component.CustomerList (line 734, column 25 - line 736, column 23): " + [
                                        state3.editing.constructor.name
                                    ]);
                                }();
                                var isEditingOppositeSide = function() {
                                    if (state3.editing instanceof Just) return state3.editing.value0.customerId === customer.id && eq6(state3.editing.value0.field)(field) && state3.editing.value0.isDebitSide !== isDebit;
                                    if (state3.editing instanceof Nothing) return false;
                                    throw new Error("Failed pattern match at Component.CustomerList (line 738, column 29 - line 740, column 23): " + [
                                        state3.editing.constructor.name
                                    ]);
                                }();
                                var baseClassName = function() {
                                    if (isDebit) return "customer-gold-debit";
                                    return "customer-gold-credit";
                                }();
                                var absValue = abs(value1);
                                var className2 = function() {
                                    var $208 = isEditingOppositeSide && shouldShowValue && absValue > 0;
                                    if ($208) return baseClassName + " field-warning";
                                    return baseClassName;
                                }();
                                var displayValue = function() {
                                    var $209 = shouldShowValue && absValue > 0;
                                    if ($209) return formatNumberForEdit(absValue);
                                    return "";
                                }();
                                var editValue = function() {
                                    if (state3.editing instanceof Just && state3.editing.value0.customerId === customer.id && eq6(state3.editing.value0.field)(field) && state3.editing.value0.isDebitSide === isDebit) return state3.editing.value0.value;
                                    return displayValue;
                                }();
                                if (isEditingThisSide) return div3([
                                    class_(baseClassName + " gold-input-container")
                                ])([
                                    input([
                                        type_4(InputText.value),
                                        class_("gold-input"),
                                        value4(editValue),
                                        onValueInput(UpdateEditValue.create),
                                        onKeyDown(SaveEditOnEnter.create)
                                    ]),
                                    span3([
                                        class_("gold-unit")
                                    ])([
                                        text(unit2)
                                    ])
                                ]);
                                return div3([
                                    class_(className2 + " editable-field"),
                                    onClick(function(e) {
                                        return new StartEditFieldWithEvent(customer.id, field, displayValue, isDebit, e);
                                    })
                                ])([
                                    function() {
                                        var $213 = shouldShowValue && absValue > 0;
                                        if ($213) return renderer(value1);
                                        return text(" ");
                                    }()
                                ]);
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
                var shouldShowValue = function() {
                    if (isDebit) return customer.money <= 0;
                    return customer.money >= 0;
                }();
                var isEditingThisSide = function() {
                    if (state3.editing instanceof Just) return state3.editing.value0.customerId === customer.id && eq6(state3.editing.value0.field)(FieldMoney.value) && state3.editing.value0.isDebitSide === isDebit;
                    if (state3.editing instanceof Nothing) return false;
                    throw new Error("Failed pattern match at Component.CustomerList (line 781, column 25 - line 783, column 23): " + [
                        state3.editing.constructor.name
                    ]);
                }();
                var isEditingOppositeSide = function() {
                    if (state3.editing instanceof Just) return state3.editing.value0.customerId === customer.id && eq6(state3.editing.value0.field)(FieldMoney.value) && state3.editing.value0.isDebitSide !== isDebit;
                    if (state3.editing instanceof Nothing) return false;
                    throw new Error("Failed pattern match at Component.CustomerList (line 785, column 29 - line 787, column 23): " + [
                        state3.editing.constructor.name
                    ]);
                }();
                var baseClassName = function() {
                    if (isDebit) return "customer-money-debit";
                    return "customer-money-credit";
                }();
                var absValue = abs(customer.money);
                var className2 = function() {
                    var $220 = isEditingOppositeSide && shouldShowValue && absValue > 0;
                    if ($220) return baseClassName + " field-warning";
                    return baseClassName;
                }();
                var displayValue = function() {
                    var $221 = shouldShowValue && absValue > 0;
                    if ($221) return formatNumberForEdit(absValue);
                    return "";
                }();
                var editValue = function() {
                    if (state3.editing instanceof Just && state3.editing.value0.customerId === customer.id && eq6(state3.editing.value0.field)(FieldMoney.value) && state3.editing.value0.isDebitSide === isDebit) return state3.editing.value0.value;
                    return displayValue;
                }();
                if (isEditingThisSide) return span3([
                    class_(baseClassName)
                ])([
                    input([
                        type_4(InputText.value),
                        class_("money-input"),
                        value4(editValue),
                        onValueInput(UpdateEditValue.create),
                        onKeyDown(SaveEditOnEnter.create)
                    ])
                ]);
                return span3([
                    class_(className2 + " editable-field"),
                    onClick(function(e) {
                        return new StartEditFieldWithEvent(customer.id, FieldMoney.value, displayValue, isDebit, e);
                    })
                ])([
                    function() {
                        var $225 = shouldShowValue && absValue > 0;
                        if ($225) return renderMoney(customer.money);
                        return text(" ");
                    }()
                ]);
            };
        };
    };
    var defaultRowHeight = 37;
    var getCustomerHeight = function(customer) {
        if (customer.rowHeight instanceof Just) return customer.rowHeight.value0;
        if (customer.rowHeight instanceof Nothing) return defaultRowHeight;
        throw new Error("Failed pattern match at Component.CustomerList (line 368, column 3 - line 370, column 32): " + [
            customer.rowHeight.constructor.name
        ]);
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
                        var $228 = idx >= totalRows;
                        if ($228) {
                            $tco_done = true;
                            return totalRows;
                        }
                        var v2 = index(customers)(idx);
                        if (v2 instanceof Just) {
                            var rowHeight = getCustomerHeight(v2.value0);
                            var nextHeight = accHeight + rowHeight;
                            var $230 = nextHeight > state3.scrollTop;
                            if ($230) {
                                $tco_done = true;
                                return idx;
                            }
                            $tco_var_idx = idx + 1 | 0;
                            $copy_accHeight = nextHeight;
                            return;
                        }
                        if (v2 instanceof Nothing) {
                            $tco_done = true;
                            return totalRows;
                        }
                        throw new Error("Failed pattern match at Component.CustomerList (line 391, column 9 - line 398, column 31): " + [
                            v2.constructor.name
                        ]);
                    }
                    while(!$tco_done)$tco_result = $tco_loop($tco_var_idx, $copy_accHeight);
                    return $tco_result;
                };
            };
            var start2 = max4(0)(findStartRow(0)(0) - overscan | 0);
            var topSpacerHeight = calculateHeightRange(customers)(0)(start2);
            var findEndRow = function($copy_idx) {
                return function($copy_accHeight) {
                    var $tco_var_idx = $copy_idx;
                    var $tco_done1 = false;
                    var $tco_result;
                    function $tco_loop(idx, accHeight) {
                        var $232 = idx >= totalRows;
                        if ($232) {
                            $tco_done1 = true;
                            return totalRows;
                        }
                        var v2 = index(customers)(idx);
                        if (v2 instanceof Just) {
                            var rowHeight = getCustomerHeight(v2.value0);
                            var nextHeight = accHeight + rowHeight;
                            var $234 = nextHeight > state3.containerHeight;
                            if ($234) {
                                $tco_done1 = true;
                                return idx + 1 | 0;
                            }
                            $tco_var_idx = idx + 1 | 0;
                            $copy_accHeight = nextHeight;
                            return;
                        }
                        if (v2 instanceof Nothing) {
                            $tco_done1 = true;
                            return totalRows;
                        }
                        throw new Error("Failed pattern match at Component.CustomerList (line 407, column 9 - line 414, column 31): " + [
                            v2.constructor.name
                        ]);
                    }
                    while(!$tco_done1)$tco_result = $tco_loop($tco_var_idx, $copy_accHeight);
                    return $tco_result;
                };
            };
            var end = min4(totalRows)(findEndRow(start2)(0) + overscan | 0);
            return {
                start: start2,
                end,
                topSpacerHeight
            };
        };
    };
    var applySorting = function(v2) {
        return function(v1) {
            if (v2.field instanceof Nothing) return v1;
            if (v2.field instanceof Just && v2.field.value0 instanceof SortById) {
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare12(a3.id)(b2.id);
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare12(b2.id)(a3.id);
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 434, column 6 - line 436, column 65): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByName) {
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare2(toLower(a3.name))(toLower(b2.name));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare2(toLower(b2.name))(toLower(a3.name));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 439, column 6 - line 441, column 89): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByMoneyDebit) {
                var debitValue = function(c2) {
                    var $247 = isNegative(c2.money);
                    if ($247) return -c2.money;
                    return 0;
                };
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare22(debitValue(a3))(debitValue(b2));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare22(debitValue(b2))(debitValue(a3));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 449, column 6 - line 451, column 85): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByMoneyCredit) {
                var creditValue = function(c2) {
                    var $252 = isPositive(c2.money);
                    if ($252) return c2.money;
                    return 0;
                };
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare22(creditValue(a3))(creditValue(b2));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare22(creditValue(b2))(creditValue(a3));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 456, column 6 - line 458, column 87): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldJewelryDebit) {
                var netWeight = function(c2) {
                    return c2.gram_jewelry + c2.baht_jewelry * gramsPerBahtJewelry;
                };
                var debitValue = function(c2) {
                    var $257 = isNegative(netWeight(c2));
                    if ($257) return -netWeight(c2);
                    return 0;
                };
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare22(debitValue(a3))(debitValue(b2));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare22(debitValue(b2))(debitValue(a3));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 465, column 6 - line 467, column 85): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldJewelryCredit) {
                var netWeight = function(c2) {
                    return c2.gram_jewelry + c2.baht_jewelry * gramsPerBahtJewelry;
                };
                var creditValue = function(c2) {
                    var $262 = isPositive(netWeight(c2));
                    if ($262) return netWeight(c2);
                    return 0;
                };
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare22(creditValue(a3))(creditValue(b2));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare22(creditValue(b2))(creditValue(a3));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 473, column 6 - line 475, column 87): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldBar96Debit) {
                var netWeight = function(c2) {
                    return c2.gram_bar96 + c2.baht_bar96 * gramsPerBahtBar96;
                };
                var debitValue = function(c2) {
                    var $267 = isNegative(netWeight(c2));
                    if ($267) return -netWeight(c2);
                    return 0;
                };
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare22(debitValue(a3))(debitValue(b2));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare22(debitValue(b2))(debitValue(a3));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 482, column 6 - line 484, column 85): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldBar96Credit) {
                var netWeight = function(c2) {
                    return c2.gram_bar96 + c2.baht_bar96 * gramsPerBahtBar96;
                };
                var creditValue = function(c2) {
                    var $272 = isPositive(netWeight(c2));
                    if ($272) return netWeight(c2);
                    return 0;
                };
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare22(creditValue(a3))(creditValue(b2));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare22(creditValue(b2))(creditValue(a3));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 490, column 6 - line 492, column 87): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldBar99Debit) {
                var netWeight = function(c2) {
                    return c2.gram_bar99 + c2.baht_bar99 * gramsPerBahtBar99;
                };
                var debitValue = function(c2) {
                    var $277 = isNegative(netWeight(c2));
                    if ($277) return -netWeight(c2);
                    return 0;
                };
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare22(debitValue(a3))(debitValue(b2));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare22(debitValue(b2))(debitValue(a3));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 499, column 6 - line 501, column 85): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByGoldBar99Credit) {
                var netWeight = function(c2) {
                    return c2.gram_bar99 + c2.baht_bar99 * gramsPerBahtBar99;
                };
                var creditValue = function(c2) {
                    var $282 = isPositive(netWeight(c2));
                    if ($282) return netWeight(c2);
                    return 0;
                };
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare22(creditValue(a3))(creditValue(b2));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare22(creditValue(b2))(creditValue(a3));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 507, column 6 - line 509, column 87): " + [
                    v2.direction.constructor.name
                ]);
            }
            if (v2.field instanceof Just && v2.field.value0 instanceof SortByUpdated) {
                var dateOnly = function(c2) {
                    return extractDatePart(c2.updated_at);
                };
                var sorted = sortBy(function(a3) {
                    return function(b2) {
                        return compare2(dateOnly(a3))(dateOnly(b2));
                    };
                })(v1);
                if (v2.direction instanceof Ascending) return sorted;
                if (v2.direction instanceof Descending) return sortBy(function(a3) {
                    return function(b2) {
                        return compare2(dateOnly(b2))(dateOnly(a3));
                    };
                })(v1);
                throw new Error("Failed pattern match at Component.CustomerList (line 515, column 6 - line 517, column 81): " + [
                    v2.direction.constructor.name
                ]);
            }
            throw new Error("Failed pattern match at Component.CustomerList (line 430, column 1 - line 430, column 62): " + [
                v2.constructor.name,
                v1.constructor.name
            ]);
        };
    };
    var handleAction3 = function(dictMonadAff) {
        var MonadEffect0 = dictMonadAff.MonadEffect0();
        var lift1 = lift5(MonadEffect0.Monad0());
        var liftAff2 = liftAff(monadAffHalogenM(dictMonadAff));
        var liftEffect8 = liftEffect(monadEffectHalogenM(MonadEffect0));
        return function(db) {
            return function(v2) {
                if (v2 instanceof Initialize4) return handleAction3(dictMonadAff)(db)(LoadCustomers.value);
                if (v2 instanceof LoadCustomers) return bind7(lift1(db.getAllCustomers))(function(customers) {
                    var latestTime = getLatestTimestamp(customers);
                    return discard4(modify_5(function(v12) {
                        var $292 = {};
                        for(var $293 in v12)if (({}).hasOwnProperty.call(v12, $293)) $292[$293] = v12[$293];
                        $292.customers = customers;
                        $292.lastSyncTime = latestTime;
                        return $292;
                    }))(function() {
                        return discard4(raise(new CustomerCountChanged(length(customers))))(function() {
                            return handleAction3(dictMonadAff)(db)(PollForChanges.value);
                        });
                    });
                });
                if (v2 instanceof PollForChanges) return bind7(get7)(function(state3) {
                    return when2(state3.pollingEnabled)(discard4(function() {
                        if (state3.lastSyncTime instanceof Just) return bind7(lift1(db.getChangesSince(state3.lastSyncTime.value0)))(function(changes) {
                            return when2(length(changes) > 0)(handleAction3(dictMonadAff)(db)(new ApplyChanges(changes)));
                        });
                        if (state3.lastSyncTime instanceof Nothing) return pure13(unit);
                        throw new Error("Failed pattern match at Component.CustomerList (line 1706, column 7 - line 1711, column 29): " + [
                            state3.lastSyncTime.constructor.name
                        ]);
                    }())(function() {
                        return $$void6(fork(discard4(liftAff2(delay(3e3)))(function() {
                            return handleAction3(dictMonadAff)(db)(PollForChanges.value);
                        })));
                    }));
                });
                if (v2 instanceof ApplyChanges) return bind7(get7)(function(state3) {
                    var mergedCustomers = mergeCustomers(state3.customers)(v2.value0);
                    var latestTime = getLatestTimestamp(v2.value0);
                    return discard4(modify_5(function(v12) {
                        var $297 = {};
                        for(var $298 in v12)if (({}).hasOwnProperty.call(v12, $298)) $297[$298] = v12[$298];
                        $297.customers = mergedCustomers;
                        $297.lastSyncTime = latestTime;
                        return $297;
                    }))(function() {
                        return $$void6(fork(bind7(liftEffect8(requestAnimationFrameAction(unit)))(function(promise2) {
                            return discard4($$void6(liftAff2(toAff(promise2))))(function() {
                                return handleAction3(dictMonadAff)(db)(MeasureRenderedRows.value);
                            });
                        })));
                    });
                });
                if (v2 instanceof StartEditFieldWithEvent) return discard4(liftEffect8(stopPropagation(toEvent(v2.value4))))(function() {
                    return handleAction3(dictMonadAff)(db)(new StartEditField(v2.value0, v2.value1, v2.value2, v2.value3));
                });
                if (v2 instanceof StartEditField) return bind7(get7)(function(state3) {
                    return discard4(function() {
                        if (state3.editing instanceof Just && (state3.editing.value0.customerId !== v2.value0 || notEq4(state3.editing.value0.field)(v2.value1))) return handleAction3(dictMonadAff)(db)(SaveEditField.value);
                        return pure13(unit);
                    }())(function() {
                        return discard4(modify_5(function(v12) {
                            var $308 = {};
                            for(var $309 in v12)if (({}).hasOwnProperty.call(v12, $309)) $308[$309] = v12[$309];
                            $308.editing = new Just({
                                customerId: v2.value0,
                                field: v2.value1,
                                value: v2.value2,
                                originalValue: v2.value2,
                                isDebitSide: v2.value3
                            });
                            return $308;
                        }))(function() {
                            return handleAction3(dictMonadAff)(db)(FocusEditInput.value);
                        });
                    });
                });
                if (v2 instanceof UpdateEditValue) return bind7(get7)(function(state3) {
                    if (state3.editing instanceof Just) return modify_5(function(v12) {
                        var $319 = {};
                        for(var $320 in v12)if (({}).hasOwnProperty.call(v12, $320)) $319[$320] = v12[$320];
                        $319.editing = new Just(function() {
                            var $316 = {};
                            for(var $317 in state3.editing.value0)if (({}).hasOwnProperty.call(state3.editing.value0, $317)) $316[$317] = state3["editing"]["value0"][$317];
                            $316.value = v2.value0;
                            return $316;
                        }());
                        return $319;
                    });
                    if (state3.editing instanceof Nothing) return pure13(unit);
                    throw new Error("Failed pattern match at Component.CustomerList (line 1753, column 5 - line 1755, column 27): " + [
                        state3.editing.constructor.name
                    ]);
                });
                if (v2 instanceof SaveEditField) return bind7(get7)(function(state3) {
                    if (state3.editing instanceof Nothing) return pure13(unit);
                    if (state3.editing instanceof Just) {
                        var valueChanged = state3.editing.value0.value !== state3.editing.value0.originalValue;
                        var v12 = parseFieldValue(state3.editing.value0.field)(state3.editing.value0.value);
                        if (v12 instanceof Nothing) return handleAction3(dictMonadAff)(db)(CancelEdit.value);
                        if (v12 instanceof Just) {
                            var finalValue = function() {
                                if (state3.editing.value0.field instanceof FieldMoney) {
                                    if (state3.editing.value0.isDebitSide) return "-" + v12.value0;
                                    return v12.value0;
                                }
                                if (state3.editing.value0.isDebitSide) return "-" + v12.value0;
                                return v12.value0;
                            }();
                            return bind7(lift1(db.updateCustomerField({
                                id: state3.editing.value0.customerId,
                                field: getDbFieldName(state3.editing.value0.field),
                                value: finalValue
                            })))(function(updatedCustomer) {
                                return discard4(modify_5(function(v22) {
                                    var $331 = {};
                                    for(var $332 in v22)if (({}).hasOwnProperty.call(v22, $332)) $331[$332] = v22[$332];
                                    $331.editing = Nothing.value;
                                    $331.searchQuery = "";
                                    $331.customers = map25(function(c2) {
                                        var $329 = c2.id === state3.editing.value0.customerId;
                                        if ($329) return updatedCustomer;
                                        return c2;
                                    })(state3.customers);
                                    $331.lastSyncTime = updatedCustomer.updated_at;
                                    $331.highlightedCustomerId = function() {
                                        if (valueChanged) return new Just(state3.editing.value0.customerId);
                                        return Nothing.value;
                                    }();
                                    return $331;
                                }))(function() {
                                    return when2(valueChanged)(handleAction3(dictMonadAff)(db)(new RenderAroundAndScrollTo(state3.editing.value0.customerId)));
                                });
                            });
                        }
                        throw new Error("Failed pattern match at Component.CustomerList (line 1764, column 9 - line 1793, column 72): " + [
                            v12.constructor.name
                        ]);
                    }
                    throw new Error("Failed pattern match at Component.CustomerList (line 1759, column 5 - line 1793, column 72): " + [
                        state3.editing.constructor.name
                    ]);
                });
                if (v2 instanceof SaveEditOnEnter) {
                    var v1 = key(v2.value0);
                    if (v1 === "Enter") return handleAction3(dictMonadAff)(db)(SaveEditField.value);
                    if (v1 === "Escape") return handleAction3(dictMonadAff)(db)(CancelEdit.value);
                    return pure13(unit);
                }
                if (v2 instanceof CancelEdit) return modify_5(function(v12) {
                    var $338 = {};
                    for(var $339 in v12)if (({}).hasOwnProperty.call(v12, $339)) $338[$339] = v12[$339];
                    $338.editing = Nothing.value;
                    return $338;
                });
                if (v2 instanceof CancelEditOnClickOutside) return bind7(get7)(function(state3) {
                    if (state3.editing instanceof Just) {
                        var eventTarget = toEvent(v2.value0);
                        var v12 = target(eventTarget);
                        if (v12 instanceof Just) return bind7(liftEffect8(checkClickOutsideInput(v12.value0)))(function(isOutside) {
                            return when2(isOutside)(handleAction3(dictMonadAff)(db)(SaveEditField.value));
                        });
                        if (v12 instanceof Nothing) return pure13(unit);
                        throw new Error("Failed pattern match at Component.CustomerList (line 1810, column 9 - line 1815, column 31): " + [
                            v12.constructor.name
                        ]);
                    }
                    if (state3.editing instanceof Nothing) return pure13(unit);
                    throw new Error("Failed pattern match at Component.CustomerList (line 1806, column 5 - line 1816, column 27): " + [
                        state3.editing.constructor.name
                    ]);
                });
                if (v2 instanceof UpdateNewName) return modify_5(function(v12) {
                    var $346 = {};
                    for(var $347 in v12)if (({}).hasOwnProperty.call(v12, $347)) $346[$347] = v12[$347];
                    $346.newCustomerName = v2.value0;
                    return $346;
                });
                if (v2 instanceof AddCustomer) return discard4(liftEffect8(preventDefault(v2.value0)))(function() {
                    return bind7(get7)(function(state3) {
                        return when2(state3.newCustomerName !== "")(bind7(lift1(db.addNewCustomer(state3.newCustomerName)))(function(newCustomer) {
                            return discard4(modify_5(function(v12) {
                                var $350 = {};
                                for(var $351 in v12)if (({}).hasOwnProperty.call(v12, $351)) $350[$351] = v12[$351];
                                $350.newCustomerName = "";
                                $350.searchQuery = "";
                                $350.customers = snoc(state3.customers)(newCustomer);
                                $350.lastSyncTime = newCustomer.updated_at;
                                $350.highlightedCustomerId = new Just(newCustomer.id);
                                return $350;
                            }))(function() {
                                return handleAction3(dictMonadAff)(db)(new RenderAroundAndScrollTo(newCustomer.id));
                            });
                        }));
                    });
                });
                if (v2 instanceof ShowDeleteConfirmation) return bind7(liftEffect8(generateRandomCode))(function(randomCode) {
                    return discard4(modify_5(function(v12) {
                        var $354 = {};
                        for(var $355 in v12)if (({}).hasOwnProperty.call(v12, $355)) $354[$355] = v12[$355];
                        $354.deleteConfirmation = new Just({
                            customerId: v2.value0,
                            confirmCode: randomCode,
                            inputValue: ""
                        });
                        return $354;
                    }))(function() {
                        return handleAction3(dictMonadAff)(db)(FocusDeleteInput.value);
                    });
                });
                if (v2 instanceof UpdateDeleteConfirmInput) return bind7(get7)(function(state3) {
                    if (state3.deleteConfirmation instanceof Just) return modify_5(function(v12) {
                        var $362 = {};
                        for(var $363 in v12)if (({}).hasOwnProperty.call(v12, $363)) $362[$363] = v12[$363];
                        $362.deleteConfirmation = new Just(function() {
                            var $359 = {};
                            for(var $360 in state3.deleteConfirmation.value0)if (({}).hasOwnProperty.call(state3.deleteConfirmation.value0, $360)) $359[$360] = state3["deleteConfirmation"]["value0"][$360];
                            $359.inputValue = v2.value0;
                            return $359;
                        }());
                        return $362;
                    });
                    if (state3.deleteConfirmation instanceof Nothing) return pure13(unit);
                    throw new Error("Failed pattern match at Component.CustomerList (line 1845, column 5 - line 1848, column 27): " + [
                        state3.deleteConfirmation.constructor.name
                    ]);
                });
                if (v2 instanceof ConfirmDelete) return bind7(get7)(function(state3) {
                    if (state3.deleteConfirmation instanceof Just && state3.deleteConfirmation.value0.customerId === v2.value0) {
                        var $368 = state3.deleteConfirmation.value0.inputValue === show9(state3.deleteConfirmation.value0.confirmCode);
                        if ($368) return discard4(lift1(db.deleteCustomer(v2.value0)))(function() {
                            var newCustomers = filter(function(c2) {
                                return c2.id !== v2.value0;
                            })(state3.customers);
                            return discard4(modify_5(function(v12) {
                                var $369 = {};
                                for(var $370 in v12)if (({}).hasOwnProperty.call(v12, $370)) $369[$370] = v12[$370];
                                $369.customers = newCustomers;
                                $369.highlightedCustomerId = Nothing.value;
                                $369.deleteConfirmation = Nothing.value;
                                return $369;
                            }))(function() {
                                return $$void6(fork(bind7(liftEffect8(getCustomerListElement))(function(mbContainer) {
                                    if (mbContainer instanceof Just) return bind7(liftEffect8(getScrollTop(mbContainer.value0)))(function(scrollTop2) {
                                        return bind7(liftEffect8(getClientHeight(mbContainer.value0)))(function(clientHeight2) {
                                            return discard4(modify_5(function(v12) {
                                                var $373 = {};
                                                for(var $374 in v12)if (({}).hasOwnProperty.call(v12, $374)) $373[$374] = v12[$374];
                                                $373.scrollTop = scrollTop2;
                                                $373.containerHeight = clientHeight2;
                                                return $373;
                                            }))(function() {
                                                return handleAction3(dictMonadAff)(db)(MeasureRenderedRows.value);
                                            });
                                        });
                                    });
                                    if (mbContainer instanceof Nothing) return pure13(unit);
                                    throw new Error("Failed pattern match at Component.CustomerList (line 1866, column 13 - line 1875, column 35): " + [
                                        mbContainer.constructor.name
                                    ]);
                                })));
                            });
                        });
                        return pure13(unit);
                    }
                    return pure13(unit);
                });
                if (v2 instanceof CancelDelete) return modify_5(function(v12) {
                    var $379 = {};
                    for(var $380 in v12)if (({}).hasOwnProperty.call(v12, $380)) $379[$380] = v12[$380];
                    $379.deleteConfirmation = Nothing.value;
                    return $379;
                });
                if (v2 instanceof FocusDeleteInput) return liftEffect8(focusDeleteConfirmInput);
                if (v2 instanceof FocusEditInput) return liftEffect8(focusEditInput);
                if (v2 instanceof SortBy) return bind7(get7)(function(state3) {
                    var newSortState = function() {
                        if (state3.sortState.field instanceof Just && eq5(state3.sortState.field.value0)(v2.value0)) return {
                            field: new Just(v2.value0),
                            direction: toggleDirection(state3.sortState.direction)
                        };
                        return {
                            field: new Just(v2.value0),
                            direction: Ascending.value
                        };
                    }();
                    return modify_5(function(v12) {
                        var $384 = {};
                        for(var $385 in v12)if (({}).hasOwnProperty.call(v12, $385)) $384[$385] = v12[$385];
                        $384.sortState = newSortState;
                        return $384;
                    });
                });
                if (v2 instanceof HandleScroll) {
                    var mbTarget = target(v2.value0);
                    var v1 = bind13(mbTarget)(fromEventTarget2);
                    if (v1 instanceof Just) return bind7(liftEffect8(getScrollTop(v1.value0)))(function(scrollTop2) {
                        return bind7(liftEffect8(getClientHeight(v1.value0)))(function(clientHeight2) {
                            return discard4(modify_5(function(v22) {
                                var $389 = {};
                                for(var $390 in v22)if (({}).hasOwnProperty.call(v22, $390)) $389[$390] = v22[$390];
                                $389.scrollTop = scrollTop2;
                                $389.containerHeight = clientHeight2;
                                return $389;
                            }))(function() {
                                return handleAction3(dictMonadAff)(db)(MeasureRenderedRows.value);
                            });
                        });
                    });
                    if (v1 instanceof Nothing) return pure13(unit);
                    throw new Error("Failed pattern match at Component.CustomerList (line 1904, column 5 - line 1913, column 27): " + [
                        v1.constructor.name
                    ]);
                }
                if (v2 instanceof MeasureRenderedRows) return bind7(liftEffect8(measureRowHeights))(function(measurements) {
                    return bind7(get7)(function(state3) {
                        var updateCustomer = function(customer) {
                            var v12 = find2(function(m2) {
                                return m2.customerId === customer.id;
                            })(measurements);
                            if (v12 instanceof Just) return {
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
                            if (v12 instanceof Nothing) return customer;
                            throw new Error("Failed pattern match at Component.CustomerList (line 1922, column 9 - line 1924, column 30): " + [
                                v12.constructor.name
                            ]);
                        };
                        var updatedCustomers = map25(updateCustomer)(state3.customers);
                        return modify_5(function(v12) {
                            var $396 = {};
                            for(var $397 in v12)if (({}).hasOwnProperty.call(v12, $397)) $396[$397] = v12[$397];
                            $396.customers = updatedCustomers;
                            return $396;
                        });
                    });
                });
                if (v2 instanceof UpdateRenderedRange) return modify_5(function(v12) {
                    var $399 = {};
                    for(var $400 in v12)if (({}).hasOwnProperty.call(v12, $400)) $399[$400] = v12[$400];
                    $399.renderedRange = {
                        start: v2.value0,
                        end: v2.value1
                    };
                    return $399;
                });
                if (v2 instanceof RenderAroundAndScrollTo) return $$void6(fork(bind7(get7)(function(state3) {
                    var filteredCustomers = filterCustomers(state3.searchQuery)(state3.customers);
                    var sortedCustomers = applySorting(state3.sortState)(filteredCustomers);
                    var v12 = findIndex(function(c2) {
                        return c2.id === v2.value0;
                    })(sortedCustomers);
                    if (v12 instanceof Just) return bind7(liftEffect8(getCustomerListElement))(function(mbContainer) {
                        return bind7(function() {
                            if (mbContainer instanceof Just) return liftEffect8(getClientHeight(mbContainer.value0));
                            if (mbContainer instanceof Nothing) return pure13(state3.containerHeight);
                            throw new Error("Failed pattern match at Component.CustomerList (line 1958, column 27 - line 1960, column 50): " + [
                                mbContainer.constructor.name
                            ]);
                        }())(function(actualHeight) {
                            return discard4(when2(actualHeight !== state3.containerHeight)(modify_5(function(v22) {
                                var $407 = {};
                                for(var $408 in v22)if (({}).hasOwnProperty.call(v22, $408)) $407[$408] = v22[$408];
                                $407.containerHeight = actualHeight;
                                return $407;
                            })))(function() {
                                var roughYPosition = calculateHeightRange(sortedCustomers)(0)(v12.value0);
                                var roughScrollTop = max1(0)(roughYPosition - actualHeight + 100);
                                return discard4(liftEffect8(scrollToPosition(roughScrollTop)))(function() {
                                    return bind7(liftEffect8(waitForRowAndMeasureImpl(v12.value0)))(function(promise2) {
                                        return bind7(liftAff2(toAff(promise2)))(function(result) {
                                            return discard4(handleAction3(dictMonadAff)(db)(MeasureRenderedRows.value))(function() {
                                                var targetScrollTop = max1(0)(result.offsetTop + result.height - actualHeight);
                                                return liftEffect8(scrollToPosition(targetScrollTop));
                                            });
                                        });
                                    });
                                });
                            });
                        });
                    });
                    if (v12 instanceof Nothing) return pure13(unit);
                    throw new Error("Failed pattern match at Component.CustomerList (line 1954, column 7 - line 1981, column 29): " + [
                        v12.constructor.name
                    ]);
                })));
                if (v2 instanceof ScrollToCustomer) return bind7(get7)(function(state3) {
                    var filteredCustomers = filterCustomers(state3.searchQuery)(state3.customers);
                    var sortedCustomers = applySorting(state3.sortState)(filteredCustomers);
                    var v12 = find2(function(c2) {
                        return c2.name === v2.value0;
                    })(sortedCustomers);
                    if (v12 instanceof Just) return handleAction3(dictMonadAff)(db)(new RenderAroundAndScrollTo(v12.value0.id));
                    if (v12 instanceof Nothing) return pure13(unit);
                    throw new Error("Failed pattern match at Component.CustomerList (line 1987, column 5 - line 1989, column 27): " + [
                        v12.constructor.name
                    ]);
                });
                if (v2 instanceof ScrollToCustomerId) return handleAction3(dictMonadAff)(db)(new RenderAroundAndScrollTo(v2.value0));
                if (v2 instanceof UpdateSearchQuery) return modify_5(function(v12) {
                    var $416 = {};
                    for(var $417 in v12)if (({}).hasOwnProperty.call(v12, $417)) $416[$417] = v12[$417];
                    $416.searchQuery = v2.value0;
                    return $416;
                });
                throw new Error("Failed pattern match at Component.CustomerList (line 1689, column 19 - line 1995, column 40): " + [
                    v2.constructor.name
                ]);
            };
        };
    };
    var renderCustomerRow = function(state3) {
        return function(customer) {
            return function(startIdx) {
                var isPendingDelete = function() {
                    if (state3.deleteConfirmation instanceof Just) return state3.deleteConfirmation.value0.customerId === customer.id;
                    if (state3.deleteConfirmation instanceof Nothing) return false;
                    throw new Error("Failed pattern match at Component.CustomerList (line 829, column 23 - line 831, column 23): " + [
                        state3.deleteConfirmation.constructor.name
                    ]);
                }();
                var isHighlighted = eq4(state3.highlightedCustomerId)(new Just(customer.id));
                var isEditingField = function(field) {
                    if (state3.editing instanceof Just) return state3.editing.value0.customerId === customer.id && eq6(state3.editing.value0.field)(field);
                    if (state3.editing instanceof Nothing) return false;
                    throw new Error("Failed pattern match at Component.CustomerList (line 825, column 28 - line 827, column 23): " + [
                        state3.editing.constructor.name
                    ]);
                };
                var filteredCustomers = filterCustomers(state3.searchQuery)(state3.customers);
                var sortedCustomers = applySorting(state3.sortState)(filteredCustomers);
                var customerIndex = function() {
                    var v2 = findIndex(function(c2) {
                        return c2.id === customer.id;
                    })(sortedCustomers);
                    if (v2 instanceof Just) return v2.value0;
                    if (v2 instanceof Nothing) return 0;
                    throw new Error("Failed pattern match at Component.CustomerList (line 835, column 21 - line 837, column 19): " + [
                        v2.constructor.name
                    ]);
                }();
                var isEvenRow = mod3(customerIndex)(2) === 0;
                var rowClasses = function() {
                    if (isPendingDelete) return "customer-row customer-row-pending-delete";
                    if (isHighlighted) return "customer-row customer-row-highlighted";
                    if (isEvenRow) return "customer-row customer-row-even";
                    return "customer-row customer-row-odd";
                }();
                return div3([
                    class_(rowClasses),
                    attr2("data-row-index")(show9(customerIndex)),
                    attr2("data-customer-id")(show9(customer.id))
                ])([
                    span3([
                        class_("customer-id")
                    ])([
                        text(show9(customer.id))
                    ]),
                    renderEditableField(state3)(customer)(FieldName.value)("customer-name")("customer-name-input"),
                    renderMoneyField(state3)(customer)(true),
                    renderMoneyField(state3)(customer)(false),
                    div3([
                        class_("customer-gold-debit")
                    ])([
                        div_([
                            div3([
                                class_("gold-grams")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldJewelryGrams.value)(true)(textConstants.unitGrams)(renderGrams)(customer.gram_jewelry)
                            ]),
                            div3([
                                class_("gold-baht")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldJewelryBaht.value)(true)(textConstants.unitBaht)(renderBaht)(customer.baht_jewelry)
                            ])
                        ])
                    ]),
                    div3([
                        class_("customer-gold-credit")
                    ])([
                        div_([
                            div3([
                                class_("gold-grams")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldJewelryGrams.value)(false)(textConstants.unitGrams)(renderGrams)(customer.gram_jewelry)
                            ]),
                            div3([
                                class_("gold-baht")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldJewelryBaht.value)(false)(textConstants.unitBaht)(renderBaht)(customer.baht_jewelry)
                            ])
                        ])
                    ]),
                    div3([
                        class_("customer-gold-debit")
                    ])([
                        div_([
                            div3([
                                class_("gold-grams")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldBar96Grams.value)(true)(textConstants.unitGrams)(renderGrams)(customer.gram_bar96)
                            ]),
                            div3([
                                class_("gold-baht")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldBar96Baht.value)(true)(textConstants.unitBaht)(renderBaht)(customer.baht_bar96)
                            ])
                        ])
                    ]),
                    div3([
                        class_("customer-gold-credit")
                    ])([
                        div_([
                            div3([
                                class_("gold-grams")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldBar96Grams.value)(false)(textConstants.unitGrams)(renderGrams)(customer.gram_bar96)
                            ]),
                            div3([
                                class_("gold-baht")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldBar96Baht.value)(false)(textConstants.unitBaht)(renderBaht)(customer.baht_bar96)
                            ])
                        ])
                    ]),
                    div3([
                        class_("customer-gold-debit")
                    ])([
                        div_([
                            div3([
                                class_("gold-grams")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldBar99Grams.value)(true)(textConstants.unitGrams)(renderGrams)(customer.gram_bar99)
                            ]),
                            div3([
                                class_("gold-baht")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldBar99Baht.value)(true)(textConstants.unitBaht)(renderBaht)(customer.baht_bar99)
                            ])
                        ])
                    ]),
                    div3([
                        class_("customer-gold-credit")
                    ])([
                        div_([
                            div3([
                                class_("gold-grams")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldBar99Grams.value)(false)(textConstants.unitGrams)(renderGrams)(customer.gram_bar99)
                            ]),
                            div3([
                                class_("gold-baht")
                            ])([
                                renderGoldField(state3)(customer)(FieldGoldBar99Baht.value)(false)(textConstants.unitBaht)(renderBaht)(customer.baht_bar99)
                            ])
                        ])
                    ]),
                    span3([
                        class_("customer-updated")
                    ])([
                        text(function() {
                            if (customer.updated_at instanceof Just) return formatDateString(customer.updated_at.value0);
                            if (customer.updated_at instanceof Nothing) return "";
                            throw new Error("Failed pattern match at Component.CustomerList (line 917, column 23 - line 919, column 28): " + [
                                customer.updated_at.constructor.name
                            ]);
                        }())
                    ]),
                    div3([
                        class_("customer-actions")
                    ])([
                        button([
                            class_("btn btn-delete"),
                            onClick(function(v2) {
                                return new ShowDeleteConfirmation(customer.id);
                            }),
                            title("Delete")
                        ])([
                            deleteIcon
                        ])
                    ])
                ]);
            };
        };
    };
    var render3 = function(state3) {
        var filteredCustomers = filterCustomers(state3.searchQuery)(state3.customers);
        var sortedCustomers = applySorting(state3.sortState)(filteredCustomers);
        var totalRows = length(sortedCustomers);
        var v2 = function() {
            if (state3.forceRenderRange) return {
                start: state3.renderedRange.start,
                end: state3.renderedRange.end,
                topSpacerHeight: calculateHeightRange(sortedCustomers)(0)(state3.renderedRange.start)
            };
            return calculateVisibleRange(state3)(sortedCustomers);
        }();
        var visibleCustomers = slice(v2.start)(v2.end)(sortedCustomers);
        var totalHeight = calculateHeightRange(sortedCustomers)(0)(totalRows);
        return div3([
            class_("app-wrapper"),
            onClick(CancelEditOnClickOutside.create)
        ])([
            div3([
                class_("customer-app")
            ])([
                div3([
                    class_("customer-list-container")
                ])([
                    renderTableHeader(state3),
                    div3([
                        class_("customer-list"),
                        onScroll(HandleScroll.create)
                    ])([
                        div3([
                            class_("scroll-spacer"),
                            attr2("style")("height: " + (show13(totalHeight) + "px"))
                        ])([]),
                        div3([
                            class_("visible-rows"),
                            attr2("style")("transform: translateY(" + (show13(v2.topSpacerHeight) + "px)")),
                            id3("visible-rows-container")
                        ])(map25(function(c2) {
                            return renderCustomerRow(state3)(c2)(v2.start);
                        })(visibleCustomers))
                    ]),
                    renderTableFooter(state3)
                ]),
                renderDeleteConfirmationDialog(state3),
                renderStyles
            ])
        ]);
    };
    var component3 = function(dictMonadAff) {
        var handleAction1 = handleAction3(dictMonadAff);
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
                render: render3,
                "eval": mkEval({
                    handleQuery: defaultEval.handleQuery,
                    receive: defaultEval.receive,
                    finalize: defaultEval.finalize,
                    handleAction: handleAction1(db),
                    initialize: new Just(Initialize4.value)
                })
            });
        };
    };
    // output/Effect.Console/foreign.js
    var log2 = function(s2) {
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
    var log3 = function(dictMonadEffect) {
        var $67 = liftEffect(dictMonadEffect);
        return function($68) {
            return $67(log2($68));
        };
    };
    // output/Component.POS/index.js
    var show10 = /* @__PURE__ */ show(showInt);
    var map26 = /* @__PURE__ */ map(functorArray);
    var type_5 = /* @__PURE__ */ type_3(isPropInputType);
    var value5 = /* @__PURE__ */ value3(isPropString);
    var bind8 = /* @__PURE__ */ bind(bindHalogenM);
    var get8 = /* @__PURE__ */ get(monadStateHalogenM);
    var lift6 = /* @__PURE__ */ lift(monadTransHalogenM);
    var discard5 = /* @__PURE__ */ discard(discardUnit)(bindHalogenM);
    var modify_6 = /* @__PURE__ */ modify_2(monadStateHalogenM);
    var pure14 = /* @__PURE__ */ pure(applicativeHalogenM);
    var show14 = /* @__PURE__ */ show(showBoolean);
    var TodaysBillsView = /* @__PURE__ */ function() {
        function TodaysBillsView2() {}
        TodaysBillsView2.value = new TodaysBillsView2();
        return TodaysBillsView2;
    }();
    var CustomerBillsView = /* @__PURE__ */ function() {
        function CustomerBillsView2(value0) {
            this.value0 = value0;
        }
        CustomerBillsView2.create = function(value0) {
            return new CustomerBillsView2(value0);
        };
        return CustomerBillsView2;
    }();
    var NavigateToCustomers = /* @__PURE__ */ function() {
        function NavigateToCustomers2() {}
        NavigateToCustomers2.value = new NavigateToCustomers2();
        return NavigateToCustomers2;
    }();
    var Initialize5 = /* @__PURE__ */ function() {
        function Initialize6() {}
        Initialize6.value = new Initialize6();
        return Initialize6;
    }();
    var UpdateSearchQuery2 = /* @__PURE__ */ function() {
        function UpdateSearchQuery3(value0) {
            this.value0 = value0;
        }
        UpdateSearchQuery3.create = function(value0) {
            return new UpdateSearchQuery3(value0);
        };
        return UpdateSearchQuery3;
    }();
    var ClearSearch = /* @__PURE__ */ function() {
        function ClearSearch2() {}
        ClearSearch2.value = new ClearSearch2();
        return ClearSearch2;
    }();
    var SelectCustomer = /* @__PURE__ */ function() {
        function SelectCustomer2(value0) {
            this.value0 = value0;
        }
        SelectCustomer2.create = function(value0) {
            return new SelectCustomer2(value0);
        };
        return SelectCustomer2;
    }();
    var OpenCustomerManagement = /* @__PURE__ */ function() {
        function OpenCustomerManagement2() {}
        OpenCustomerManagement2.value = new OpenCustomerManagement2();
        return OpenCustomerManagement2;
    }();
    var DeleteBill = /* @__PURE__ */ function() {
        function DeleteBill2(value0) {
            this.value0 = value0;
        }
        DeleteBill2.create = function(value0) {
            return new DeleteBill2(value0);
        };
        return DeleteBill2;
    }();
    var OpenBillEditor = /* @__PURE__ */ function() {
        function OpenBillEditor2(value0) {
            this.value0 = value0;
        }
        OpenBillEditor2.create = function(value0) {
            return new OpenBillEditor2(value0);
        };
        return OpenBillEditor2;
    }();
    var CreateNewBill2 = /* @__PURE__ */ function() {
        function CreateNewBill3() {}
        CreateNewBill3.value = new CreateNewBill3();
        return CreateNewBill3;
    }();
    var renderStyles2 = /* @__PURE__ */ style_([
        /* @__PURE__ */ text("\n      .pos-container {\n        padding: 20px;\n        max-width: 1400px;\n        margin: 0 auto;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .pos-header {\n        margin-bottom: 20px;\n      }\n      \n      .pos-header h1 {\n        margin: 0;\n        font-size: 24px;\n        color: #333;\n      }\n      \n      /* Search box */\n      .pos-search-container {\n        display: flex;\n        gap: 8px;\n        margin-bottom: 20px;\n      }\n      \n      .pos-search-box {\n        position: relative;\n        width: 600px;\n      }\n      \n      .pos-search-input {\n        width: 100%;\n        padding: 10px 40px 10px 12px;\n        font-size: 16px;\n        border: 1px solid #ddd;\n        border-radius: 4px;\n        box-sizing: border-box;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .pos-search-input:focus {\n        outline: none;\n        border-color: #007bff;\n      }\n      \n      .pos-search-clear {\n        position: absolute;\n        right: 8px;\n        top: 50%;\n        transform: translateY(-50%);\n        background: none;\n        border: none;\n        font-size: 24px;\n        cursor: pointer;\n        color: #999;\n        padding: 0 8px;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .pos-search-clear:hover {\n        color: #333;\n      }\n      \n\n      \n      /* Search popup */\n      .pos-search-popup {\n        position: absolute;\n        top: 100%;\n        left: 0;\n        right: 0;\n        background: white;\n        border: 1px solid #ddd;\n        border-top: none;\n        border-radius: 0 0 4px 4px;\n        box-shadow: 0 4px 6px rgba(0,0,0,0.1);\n        max-height: 300px;\n        overflow-y: auto;\n        z-index: 1000;\n      }\n      \n      .pos-search-result {\n        padding: 12px;\n        border-bottom: 1px solid #eee;\n        cursor: pointer;\n      }\n      \n      .pos-search-result:hover {\n        background: #f5f5f5;\n      }\n      \n      .pos-search-result-name {\n        font-weight: 500;\n        font-size: 14px;\n      }\n      \n      .pos-search-no-results {\n        padding: 12px;\n        color: #999;\n        text-align: center;\n      }\n      \n      /* Content area */\n      .pos-content {\n        margin-top: 20px;\n      }\n      \n      .pos-content h2 {\n        margin: 0 0 16px 0;\n        font-size: 20px;\n        color: #333;\n      }\n      \n      /* Tables */\n      .pos-table {\n        width: 100%;\n        border-collapse: collapse;\n        background: white;\n        border: 1px solid #ddd;\n      }\n      \n      .pos-table th {\n        background: #f8f9fa;\n        padding: 12px 8px;\n        text-align: left;\n        font-weight: 600;\n        border-bottom: 2px solid #dee2e6;\n      }\n      \n      .pos-table td {\n        padding: 12px 8px;\n        border-bottom: 1px solid #eee;\n        vertical-align: top;\n      }\n      \n      .pos-table tr:hover {\n        background: #f5f5f5;\n      }\n      \n      /* Today's Bills table */\n      .pos-time-col {\n        text-align: right;\n        width: 80px;\n      }\n      \n      .pos-customer-name-cell {\n        cursor: pointer;\n      }\n      \n      .pos-customer-name-cell:hover {\n        background: #e8f4f8 !important;\n        text-decoration: underline;\n      }\n      \n      /* Customer Bills table */\n      .pos-date-col {\n        text-align: right;\n        width: 100px;\n      }\n      \n      .pos-gold-label {\n        text-align: left;\n        width: 120px;\n        line-height: 1.6;\n      }\n      \n      .pos-gold-value {\n        text-align: right;\n        width: 100px;\n        line-height: 1.6;\n      }\n      \n      .pos-money-label {\n        text-align: left;\n        width: 80px;\n      }\n      \n      .pos-money-value {\n        text-align: right;\n        width: 100px;\n      }\n      \n      .pos-actions-col {\n        text-align: center;\n        width: 60px;\n      }\n      \n      /* Clickable cells */\n      .pos-clickable-gold,\n      .pos-clickable-money {\n        cursor: pointer;\n      }\n      \n      .pos-gold-label:hover,\n      .pos-gold-label:hover + .pos-gold-value {\n        background: #e8f4f8 !important;\n      }\n      \n      .pos-gold-value:hover {\n        background: #e8f4f8 !important;\n      }\n      \n      .pos-money-label:hover,\n      .pos-money-label:hover + .pos-money-value {\n        background: #e8f4f8 !important;\n      }\n      \n      .pos-money-value:hover {\n        background: #e8f4f8 !important;\n      }\n      \n      /* Settlement row */\n      .pos-settlement-row {\n        background: #e3f2fd !important;\n        font-weight: 500;\n      }\n      \n      .pos-settlement-row .pos-clickable-gold:hover,\n      .pos-settlement-row .pos-clickable-money:hover {\n        background: #bbdefb !important;\n      }\n      \n      /* New bill row */\n      .pos-new-bill-row {\n        background: #fff9c4 !important;\n        text-align: center;\n        cursor: pointer;\n      }\n      \n      .pos-new-bill-row:hover {\n        background: #fff59d !important;\n      }\n      \n      .pos-new-bill-row td {\n        padding: 20px;\n        font-size: 24px;\n      }\n      \n      /* Icon buttons */\n      .pos-icon-btn {\n        background: none;\n        border: none;\n        font-size: 20px;\n        cursor: pointer;\n        padding: 4px 8px;\n        color: #666;\n        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n      }\n      \n      .pos-icon-btn:hover {\n        color: #333;\n      }\n      \n      .pos-delete-btn:hover {\n        color: #dc3545;\n      }\n    ")
    ]);
    var renderSettlementRow = function(customer) {
        return tr([
            class_("pos-settlement-row")
        ])([
            td([
                class_("pos-date-col")
            ])([
                text("2024-11-18")
            ]),
            td([
                class_("pos-gold-label pos-clickable-gold"),
                onClick(function(v2) {
                    return new OpenBillEditor(Nothing.value);
                })
            ])([
                text("\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E17\u0E2D\u0E07")
            ]),
            td([
                class_("pos-gold-value pos-clickable-gold"),
                onClick(function(v2) {
                    return new OpenBillEditor(Nothing.value);
                })
            ])([
                text("10.500g")
            ]),
            td([
                class_("pos-money-label pos-clickable-money"),
                onClick(function(v2) {
                    return new OpenBillEditor(Nothing.value);
                })
            ])([
                text("\u0E40\u0E2B\u0E25\u0E37\u0E2D\u0E40\u0E07\u0E34\u0E19")
            ]),
            td([
                class_("pos-money-value pos-clickable-money"),
                onClick(function(v2) {
                    return new OpenBillEditor(Nothing.value);
                })
            ])([
                text("5,000")
            ]),
            td([
                class_("pos-actions-col")
            ])([
                text("")
            ])
        ]);
    };
    var renderSearchResult = function(customer) {
        return div3([
            class_("pos-search-result"),
            onClick(function(v2) {
                return new SelectCustomer(customer);
            })
        ])([
            div3([
                class_("pos-search-result-name")
            ])([
                text(customer.name + (" (ID: " + (show10(customer.id) + ")")))
            ])
        ]);
    };
    var renderSearchPopup = function(state3) {
        return div3([
            class_("pos-search-popup")
        ])(function() {
            var $40 = length(state3.searchResults) === 0;
            if ($40) return [
                div3([
                    class_("pos-search-no-results")
                ])([
                    text(posConstants.noCustomersFound)
                ])
            ];
            return map26(renderSearchResult)(state3.searchResults);
        }());
    };
    var renderSearchBox = function(state3) {
        return div3([
            class_("pos-search-container")
        ])([
            div3([
                class_("pos-search-box")
            ])([
                input([
                    type_5(InputText.value),
                    class_("pos-search-input"),
                    placeholder2(posConstants.searchPlaceholder),
                    value5(state3.searchQuery),
                    onValueInput(UpdateSearchQuery2.create)
                ]),
                function() {
                    var $41 = state3.searchQuery !== "";
                    if ($41) return button([
                        class_("pos-search-clear"),
                        onClick(function(v2) {
                            return ClearSearch.value;
                        })
                    ])([
                        text("\xD7")
                    ]);
                    return text("");
                }(),
                function() {
                    if (state3.showSearchPopup) return renderSearchPopup(state3);
                    return text("");
                }()
            ])
        ]);
    };
    var renderNewBillRow = /* @__PURE__ */ tr([
        /* @__PURE__ */ class_("pos-new-bill-row"),
        /* @__PURE__ */ onClick(function(v2) {
            return CreateNewBill2.value;
        })
    ])([
        /* @__PURE__ */ td([
            /* @__PURE__ */ colSpan(6)
        ])([
            /* @__PURE__ */ text("\u2795")
        ])
    ]);
    var renderHeader3 = /* @__PURE__ */ text("");
    var renderCustomerBills = function(state3) {
        return function(customer) {
            return div3([
                class_("pos-content")
            ])([
                h2_([
                    text(customer.name + (" (ID: " + (show10(customer.id) + ")")))
                ]),
                table([
                    class_("pos-table pos-customer-bills-table")
                ])([
                    thead_([
                        tr_([
                            th([
                                class_("pos-date-col")
                            ])([
                                text("Date")
                            ]),
                            th([
                                class_("pos-gold-label")
                            ])([
                                text("Gold Label")
                            ]),
                            th([
                                class_("pos-gold-value")
                            ])([
                                text("Gold Value")
                            ]),
                            th([
                                class_("pos-money-label")
                            ])([
                                text("Money Label")
                            ]),
                            th([
                                class_("pos-money-value")
                            ])([
                                text("Money Value")
                            ]),
                            th([
                                class_("pos-actions-col")
                            ])([
                                text("\xD7")
                            ])
                        ])
                    ]),
                    tbody_([
                        renderSettlementRow(customer),
                        renderNewBillRow
                    ])
                ])
            ]);
        };
    };
    var initialState3 = function(database) {
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
        return tr_([
            td([
                class_("pos-time-col")
            ])([
                text(formatTime(bill.createdAt))
            ]),
            td([
                class_("pos-customer-name-cell"),
                onClick(function(v2) {
                    return new OpenBillEditor(new Just(bill.id));
                })
            ])([
                text(bill.customerName)
            ]),
            td([
                class_("pos-actions-col")
            ])([
                button([
                    class_("pos-icon-btn pos-delete-btn"),
                    onClick(function(v2) {
                        return new DeleteBill(bill.id);
                    }),
                    title("Delete bill")
                ])([
                    text("\uD83D\uDDD1\uFE0F")
                ])
            ])
        ]);
    };
    var renderTodaysBills = function(state3) {
        return div3([
            class_("pos-content")
        ])([
            h2_([
                text(posConstants.todaysBillsTitle(length(state3.todaysBills)))
            ]),
            table([
                class_("pos-table pos-todays-bills-table")
            ])([
                thead_([
                    tr_([
                        th_([
                            text(posConstants.columnTime)
                        ]),
                        th_([
                            text(posConstants.columnCustomerName)
                        ]),
                        th_([
                            text("")
                        ])
                    ])
                ]),
                tbody_(map26(renderTodaysBillRow)(state3.todaysBills))
            ])
        ]);
    };
    var renderContent3 = function(state3) {
        if (state3.view instanceof TodaysBillsView) return renderTodaysBills(state3);
        if (state3.view instanceof CustomerBillsView) return renderCustomerBills(state3)(state3.view.value0);
        throw new Error("Failed pattern match at Component.POS (line 413, column 3 - line 415, column 69): " + [
            state3.view.constructor.name
        ]);
    };
    var render4 = function(state3) {
        return div3([
            class_("pos-container")
        ])([
            renderStyles2,
            renderHeader3,
            renderSearchBox(state3),
            renderContent3(state3)
        ]);
    };
    var filterCustomers2 = function(query2) {
        return function(customers) {
            var $45 = query2 === "";
            if ($45) return [];
            var lowerQuery = toLower(query2);
            var matchesQuery = function(customer) {
                return contains(lowerQuery)(toLower(customer.name)) || contains(query2)(show10(customer.id));
            };
            var results = filter(matchesQuery)(customers);
            return results;
        };
    };
    var handleAction4 = function(dictMonadAff) {
        var MonadEffect0 = dictMonadAff.MonadEffect0();
        var lift1 = lift6(MonadEffect0.Monad0());
        var log5 = log3(MonadEffect0);
        return function(v2) {
            if (v2 instanceof Initialize5) return bind8(get8)(function(state3) {
                return bind8(lift1(state3.database.getAllCustomers))(function(customers) {
                    return discard5(lift1(log5("POS: Loaded " + (show10(length(customers)) + " customers"))))(function() {
                        return discard5(modify_6(function(v1) {
                            var $47 = {};
                            for(var $48 in v1)if (({}).hasOwnProperty.call(v1, $48)) $47[$48] = v1[$48];
                            $47.allCustomers = customers;
                            return $47;
                        }))(function() {
                            return pure14(unit);
                        });
                    });
                });
            });
            if (v2 instanceof UpdateSearchQuery2) return bind8(get8)(function(state3) {
                return discard5(lift1(log5("Search query: " + v2.value0)))(function() {
                    return discard5(lift1(log5("Total customers: " + show10(length(state3.allCustomers)))))(function() {
                        var searchResults = filterCustomers2(v2.value0)(state3.allCustomers);
                        return discard5(lift1(log5("Search results: " + show10(length(searchResults)))))(function() {
                            return discard5(lift1(log5("Show popup: " + show14(v2.value0 !== ""))))(function() {
                                return modify_6(function(v1) {
                                    var $50 = {};
                                    for(var $51 in v1)if (({}).hasOwnProperty.call(v1, $51)) $50[$51] = v1[$51];
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
            if (v2 instanceof ClearSearch) return modify_6(function(v1) {
                var $54 = {};
                for(var $55 in v1)if (({}).hasOwnProperty.call(v1, $55)) $54[$55] = v1[$55];
                $54.searchQuery = "";
                $54.showSearchPopup = false;
                $54.selectedCustomer = Nothing.value;
                $54.view = TodaysBillsView.value;
                return $54;
            });
            if (v2 instanceof SelectCustomer) return discard5(modify_6(function(v1) {
                var $57 = {};
                for(var $58 in v1)if (({}).hasOwnProperty.call(v1, $58)) $57[$58] = v1[$58];
                $57.selectedCustomer = new Just(v2.value0);
                $57.searchQuery = v2.value0.name;
                $57.showSearchPopup = false;
                $57.view = new CustomerBillsView(v2.value0);
                return $57;
            }))(function() {
                return pure14(unit);
            });
            if (v2 instanceof OpenCustomerManagement) return raise(NavigateToCustomers.value);
            if (v2 instanceof DeleteBill) return pure14(unit);
            if (v2 instanceof OpenBillEditor) return pure14(unit);
            if (v2 instanceof CreateNewBill2) return pure14(unit);
            throw new Error("Failed pattern match at Component.POS (line 546, column 16 - line 600, column 14): " + [
                v2.constructor.name
            ]);
        };
    };
    var component4 = function(dictMonadAff) {
        var handleAction1 = handleAction4(dictMonadAff);
        return function(database) {
            return mkComponent({
                initialState: initialState3(database),
                render: render4,
                "eval": mkEval({
                    handleQuery: defaultEval.handleQuery,
                    receive: defaultEval.receive,
                    finalize: defaultEval.finalize,
                    handleAction: handleAction1,
                    initialize: new Just(Initialize5.value)
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
                        return function(component7) {
                            return function(input3) {
                                return function(outputQuery) {
                                    return widget(new ComponentSlot(componentSlot22(label5)(p2)(component7)(input3)(function($11) {
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
    var modify_7 = /* @__PURE__ */ modify_2(monadStateHalogenM);
    var bind9 = /* @__PURE__ */ bind(bindHalogenM);
    var get9 = /* @__PURE__ */ get(monadStateHalogenM);
    var pure15 = /* @__PURE__ */ pure(applicativeHalogenM);
    var eq12 = /* @__PURE__ */ eq(/* @__PURE__ */ eqMaybe(eqInt));
    var show11 = /* @__PURE__ */ show(showInt);
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
    var slot3 = /* @__PURE__ */ slot2({
        reflectSymbol: function() {
            return "billList";
        }
    })(ordUnit);
    var slot4 = /* @__PURE__ */ slot2({
        reflectSymbol: function() {
            return "billEditor";
        }
    })(ordUnit);
    var POSRoute = /* @__PURE__ */ function() {
        function POSRoute2() {}
        POSRoute2.value = new POSRoute2();
        return POSRoute2;
    }();
    var CustomersRoute = /* @__PURE__ */ function() {
        function CustomersRoute2() {}
        CustomersRoute2.value = new CustomersRoute2();
        return CustomersRoute2;
    }();
    var BillsRoute = /* @__PURE__ */ function() {
        function BillsRoute2(value0) {
            this.value0 = value0;
        }
        BillsRoute2.create = function(value0) {
            return new BillsRoute2(value0);
        };
        return BillsRoute2;
    }();
    var BillEditorRoute = /* @__PURE__ */ function() {
        function BillEditorRoute2(value0, value1) {
            this.value0 = value0;
            this.value1 = value1;
        }
        BillEditorRoute2.create = function(value0) {
            return function(value1) {
                return new BillEditorRoute2(value0, value1);
            };
        };
        return BillEditorRoute2;
    }();
    var Navigate = /* @__PURE__ */ function() {
        function Navigate2(value0) {
            this.value0 = value0;
        }
        Navigate2.create = function(value0) {
            return new Navigate2(value0);
        };
        return Navigate2;
    }();
    var ToggleMenu = /* @__PURE__ */ function() {
        function ToggleMenu2() {}
        ToggleMenu2.value = new ToggleMenu2();
        return ToggleMenu2;
    }();
    var HandlePOSOutput = /* @__PURE__ */ function() {
        function HandlePOSOutput2(value0) {
            this.value0 = value0;
        }
        HandlePOSOutput2.create = function(value0) {
            return new HandlePOSOutput2(value0);
        };
        return HandlePOSOutput2;
    }();
    var HandleCustomerListOutput = /* @__PURE__ */ function() {
        function HandleCustomerListOutput2(value0) {
            this.value0 = value0;
        }
        HandleCustomerListOutput2.create = function(value0) {
            return new HandleCustomerListOutput2(value0);
        };
        return HandleCustomerListOutput2;
    }();
    var HandleBillListOutput = /* @__PURE__ */ function() {
        function HandleBillListOutput2(value0) {
            this.value0 = value0;
        }
        HandleBillListOutput2.create = function(value0) {
            return new HandleBillListOutput2(value0);
        };
        return HandleBillListOutput2;
    }();
    var HandleBillEditorOutput = /* @__PURE__ */ function() {
        function HandleBillEditorOutput2(value0) {
            this.value0 = value0;
        }
        HandleBillEditorOutput2.create = function(value0) {
            return new HandleBillEditorOutput2(value0);
        };
        return HandleBillEditorOutput2;
    }();
    var handleAction5 = function(dictMonadAff) {
        return function(v2) {
            if (v2 instanceof Navigate) return modify_7(function(v1) {
                var $64 = {};
                for(var $65 in v1)if (({}).hasOwnProperty.call(v1, $65)) $64[$65] = v1[$65];
                $64.currentRoute = v2.value0;
                $64.showMenu = false;
                return $64;
            });
            if (v2 instanceof ToggleMenu) return modify_7(function(s2) {
                var $68 = {};
                for(var $69 in s2)if (({}).hasOwnProperty.call(s2, $69)) $68[$69] = s2[$69];
                $68.showMenu = !s2.showMenu;
                return $68;
            });
            if (v2 instanceof HandlePOSOutput) return modify_7(function(v1) {
                var $72 = {};
                for(var $73 in v1)if (({}).hasOwnProperty.call(v1, $73)) $72[$73] = v1[$73];
                $72.currentRoute = CustomersRoute.value;
                return $72;
            });
            if (v2 instanceof HandleCustomerListOutput) return modify_7(function(v1) {
                var $77 = {};
                for(var $78 in v1)if (({}).hasOwnProperty.call(v1, $78)) $77[$78] = v1[$78];
                $77.customerCount = v2.value0.value0;
                return $77;
            });
            if (v2 instanceof HandleBillListOutput) {
                if (v2.value0 instanceof BillSelected) return bind9(get9)(function(state3) {
                    if (state3.currentRoute instanceof BillsRoute) return modify_7(function(v1) {
                        var $84 = {};
                        for(var $85 in v1)if (({}).hasOwnProperty.call(v1, $85)) $84[$85] = v1[$85];
                        $84.currentRoute = new BillEditorRoute(new Just(v2.value0.value0), state3.currentRoute.value0);
                        return $84;
                    });
                    return pure15(unit);
                });
                if (v2.value0 instanceof NewBillRequested) return bind9(get9)(function(state3) {
                    if (state3.currentRoute instanceof BillsRoute) return modify_7(function(v1) {
                        var $90 = {};
                        for(var $91 in v1)if (({}).hasOwnProperty.call(v1, $91)) $90[$91] = v1[$91];
                        $90.currentRoute = new BillEditorRoute(Nothing.value, state3.currentRoute.value0);
                        return $90;
                    });
                    return pure15(unit);
                });
                throw new Error("Failed pattern match at Component.Router (line 245, column 5 - line 255, column 25): " + [
                    v2.value0.constructor.name
                ]);
            }
            if (v2 instanceof HandleBillEditorOutput) {
                if (v2.value0 instanceof BillSaved) return pure15(unit);
                if (v2.value0 instanceof BillCancelled) return bind9(get9)(function(state3) {
                    if (state3.currentRoute instanceof BillEditorRoute) return modify_7(function(v1) {
                        var $98 = {};
                        for(var $99 in v1)if (({}).hasOwnProperty.call(v1, $99)) $98[$99] = v1[$99];
                        $98.currentRoute = new BillsRoute(state3.currentRoute.value1);
                        return $98;
                    });
                    return pure15(unit);
                });
                if (v2.value0 instanceof BillFinalized) return pure15(unit);
                throw new Error("Failed pattern match at Component.Router (line 258, column 5 - line 265, column 46): " + [
                    v2.value0.constructor.name
                ]);
            }
            throw new Error("Failed pattern match at Component.Router (line 227, column 16 - line 265, column 46): " + [
                v2.constructor.name
            ]);
        };
    };
    var eqRoute = {
        eq: function(x) {
            return function(y) {
                if (x instanceof POSRoute && y instanceof POSRoute) return true;
                if (x instanceof CustomersRoute && y instanceof CustomersRoute) return true;
                if (x instanceof BillsRoute && y instanceof BillsRoute) return x.value0 === y.value0;
                if (x instanceof BillEditorRoute && y instanceof BillEditorRoute) return eq12(x.value0)(y.value0) && x.value1 === y.value1;
                return false;
            };
        }
    };
    var eq22 = /* @__PURE__ */ eq(eqRoute);
    var renderDropdown = function(state3) {
        return div3([
            class_("app-nav-dropdown")
        ])([
            div3([
                class_("app-nav-item" + function() {
                    var $113 = eq22(state3.currentRoute)(POSRoute.value);
                    if ($113) return " active";
                    return "";
                }()),
                onClick(function(v2) {
                    return new Navigate(POSRoute.value);
                })
            ])([
                text(routerConstants.routePOS)
            ]),
            div3([
                class_("app-nav-item" + function() {
                    var $114 = eq22(state3.currentRoute)(CustomersRoute.value);
                    if ($114) return " active";
                    return "";
                }()),
                onClick(function(v2) {
                    return new Navigate(CustomersRoute.value);
                })
            ])([
                text(routerConstants.routeCustomers)
            ]),
            div3([
                class_("app-nav-item"),
                onClick(function(v2) {
                    return new Navigate(new BillsRoute(1));
                })
            ])([
                text("\u0E1A\u0E34\u0E25 (\u0E17\u0E14\u0E2A\u0E2D\u0E1A)")
            ])
        ]);
    };
    var renderNav = function(state3) {
        return div3([
            class_("app-nav")
        ])([
            style_([
                text("\n          .app-nav {\n            background: #f8f9fa;\n            border-bottom: 1px solid #dee2e6;\n            padding: 0;\n            margin: 0;\n            display: flex;\n            align-items: center;\n            height: 38px;\n          }\n          \n          .app-nav-menu {\n            position: relative;\n            display: inline-block;\n          }\n          \n          .app-nav-title {\n            font-size: 20px;\n            color: #333;\n            padding: 0 16px;\n            font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n          }\n          \n          .app-nav-toggle {\n            background: none;\n            border: none;\n            font-size: 20px;\n            padding: 8px 16px;\n            cursor: pointer;\n            color: #333;\n            height: 38px;\n            display: flex;\n            align-items: center;\n            font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n          }\n          \n          .app-nav-toggle:hover {\n            background: #e9ecef;\n          }\n          \n          .app-nav-dropdown {\n            position: absolute;\n            top: 100%;\n            left: 0;\n            background: white;\n            border: 1px solid #dee2e6;\n            border-radius: 0 0 4px 4px;\n            box-shadow: 0 4px 6px rgba(0,0,0,0.1);\n            min-width: 200px;\n            z-index: 1000;\n          }\n          \n          .app-nav-item {\n            padding: 12px 20px;\n            cursor: pointer;\n            border-bottom: 1px solid #eee;\n            font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;\n          }\n          \n          .app-nav-item:last-child {\n            border-bottom: none;\n          }\n          \n          .app-nav-item:hover {\n            background: #f8f9fa;\n          }\n          \n          .app-nav-item.active {\n            background: #e3f2fd;\n            font-weight: 600;\n          }\n        ")
            ]),
            div3([
                class_("app-nav-menu")
            ])([
                button([
                    class_("app-nav-toggle"),
                    title("Menu"),
                    onClick(function(v2) {
                        return ToggleMenu.value;
                    })
                ])([
                    text("\u2630")
                ]),
                function() {
                    if (state3.showMenu) return renderDropdown(state3);
                    return text("");
                }()
            ]),
            span3([
                class_("app-nav-title")
            ])([
                text(function() {
                    if (state3.currentRoute instanceof POSRoute) return routerConstants.routePOS;
                    if (state3.currentRoute instanceof CustomersRoute) return routerConstants.routeCustomers + (" (" + (show11(state3.customerCount) + " \u0E23\u0E32\u0E22)"));
                    if (state3.currentRoute instanceof BillsRoute) return "\u0E1A\u0E34\u0E25\u0E02\u0E2D\u0E07\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32 #" + show11(state3.currentRoute.value0);
                    if (state3.currentRoute instanceof BillEditorRoute) return "\u0E41\u0E01\u0E49\u0E44\u0E02\u0E1A\u0E34\u0E25 - \u0E25\u0E39\u0E01\u0E04\u0E49\u0E32 #" + show11(state3.currentRoute.value1);
                    throw new Error("Failed pattern match at Component.Router (line 178, column 21 - line 182, column 85): " + [
                        state3.currentRoute.constructor.name
                    ]);
                }())
            ])
        ]);
    };
    var _pos = /* @__PURE__ */ function() {
        return $$Proxy.value;
    }();
    var _customers = /* @__PURE__ */ function() {
        return $$Proxy.value;
    }();
    var _billList = /* @__PURE__ */ function() {
        return $$Proxy.value;
    }();
    var _billEditor = /* @__PURE__ */ function() {
        return $$Proxy.value;
    }();
    var renderPage = function(dictMonadAff) {
        var component1 = component4(dictMonadAff);
        var component22 = component3(dictMonadAff);
        var component32 = component2(dictMonadAff);
        var component42 = component(dictMonadAff);
        return function(state3) {
            if (state3.currentRoute instanceof POSRoute) return slot1(_pos)(unit)(component1(state3.database))(unit)(HandlePOSOutput.create);
            if (state3.currentRoute instanceof CustomersRoute) return slot22(_customers)(unit)(component22(state3.database))(unit)(HandleCustomerListOutput.create);
            if (state3.currentRoute instanceof BillsRoute) return slot3(_billList)(unit)(component32)({
                customerId: state3.currentRoute.value0,
                customerName: "Customer #" + show11(state3.currentRoute.value0)
            })(HandleBillListOutput.create);
            if (state3.currentRoute instanceof BillEditorRoute) return slot4(_billEditor)(unit)(component42)({
                billId: state3.currentRoute.value0,
                customerId: state3.currentRoute.value1,
                customerName: "Customer #" + show11(state3.currentRoute.value1)
            })(HandleBillEditorOutput.create);
            throw new Error("Failed pattern match at Component.Router (line 215, column 3 - line 223, column 145): " + [
                state3.currentRoute.constructor.name
            ]);
        };
    };
    var render5 = function(dictMonadAff) {
        var renderPage1 = renderPage(dictMonadAff);
        return function(state3) {
            return div3([
                style2("display: flex; flex-direction: column; height: 100vh;")
            ])([
                renderNav(state3),
                div3([
                    style2("flex: 1; overflow-y: auto; overflow-x: hidden;")
                ])([
                    renderPage1(state3)
                ])
            ]);
        };
    };
    var component5 = function(dictMonadAff) {
        var render1 = render5(dictMonadAff);
        var handleAction1 = handleAction5(dictMonadAff);
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
    // output/Database.Codecs/index.js
    var lmap5 = /* @__PURE__ */ lmap(bifunctorEither);
    var bind10 = /* @__PURE__ */ bind(bindEither);
    var decodeJson4 = /* @__PURE__ */ decodeJson(/* @__PURE__ */ decodeForeignObject2(decodeJsonJson));
    var getField5 = /* @__PURE__ */ getField2(decodeJsonInt);
    var getField13 = /* @__PURE__ */ getField2(decodeJsonString);
    var getField23 = /* @__PURE__ */ getField2(/* @__PURE__ */ decodeJsonMaybe(decodeJsonString));
    var pure16 = /* @__PURE__ */ pure(applicativeEither);
    var parseNumber3 = function(str) {
        var v2 = fromString(str);
        if (v2 instanceof Just) return new Right(v2.value0);
        if (v2 instanceof Nothing) return new Left(new TypeMismatch2("Invalid number: " + str));
        throw new Error("Failed pattern match at Database.Codecs (line 19, column 19 - line 21, column 61): " + [
            v2.constructor.name
        ]);
    };
    var decodeCustomer = function(json3) {
        return lmap5(printJsonDecodeError)(bind10(decodeJson4(json3))(function(obj) {
            return bind10(getField5(obj)("id"))(function(id4) {
                return bind10(getField13(obj)("name"))(function(name16) {
                    return bind10(getField13(obj)("money"))(function(moneyStr) {
                        return bind10(getField13(obj)("gram_jewelry"))(function(gramJewelryStr) {
                            return bind10(getField13(obj)("baht_jewelry"))(function(bahtJewelryStr) {
                                return bind10(getField13(obj)("gram_bar96"))(function(gramBar96Str) {
                                    return bind10(getField13(obj)("baht_bar96"))(function(bahtBar96Str) {
                                        return bind10(getField13(obj)("gram_bar99"))(function(gramBar99Str) {
                                            return bind10(getField13(obj)("baht_bar99"))(function(bahtBar99Str) {
                                                return bind10(getField23(obj)("created_at"))(function(created_at) {
                                                    return bind10(getField23(obj)("updated_at"))(function(updated_at) {
                                                        return bind10(parseNumber3(moneyStr))(function(money) {
                                                            return bind10(parseNumber3(gramJewelryStr))(function(gram_jewelry) {
                                                                return bind10(parseNumber3(bahtJewelryStr))(function(baht_jewelry) {
                                                                    return bind10(parseNumber3(gramBar96Str))(function(gram_bar96) {
                                                                        return bind10(parseNumber3(bahtBar96Str))(function(baht_bar96) {
                                                                            return bind10(parseNumber3(gramBar99Str))(function(gram_bar99) {
                                                                                return bind10(parseNumber3(bahtBar99Str))(function(baht_bar99) {
                                                                                    return pure16({
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
    var bind11 = /* @__PURE__ */ bind(bindAff);
    var liftEffect3 = /* @__PURE__ */ liftEffect(monadEffectAff);
    var log4 = /* @__PURE__ */ log3(monadEffectEffect);
    var throwError2 = /* @__PURE__ */ throwError(monadThrowAff);
    var decodeJson5 = /* @__PURE__ */ decodeJson(/* @__PURE__ */ decodeArray2(decodeJsonJson));
    var show15 = /* @__PURE__ */ show(showJsonDecodeError);
    var show16 = /* @__PURE__ */ show(showInt);
    var pure17 = /* @__PURE__ */ pure(applicativeAff);
    var traverse6 = /* @__PURE__ */ traverse(traversableArray)(applicativeEither);
    var gEncodeJsonCons2 = /* @__PURE__ */ gEncodeJsonCons(encodeJsonJString);
    var gEncodeJsonCons1 = /* @__PURE__ */ gEncodeJsonCons2(gEncodeJsonNil);
    var encodeJson3 = /* @__PURE__ */ encodeJson(/* @__PURE__ */ encodeRecord(/* @__PURE__ */ gEncodeJsonCons1({
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
    var apiUrl2 = "/api/customers";
    var createAPIDatabase = function(dictMonadAff) {
        var liftAff2 = liftAff(dictMonadAff);
        return {
            getAllCustomers: liftAff2(bind11(liftEffect3(log4("Fetching all customers...")))(function() {
                return bind11(get3(json2)(apiUrl2))(function(result) {
                    if (result instanceof Left) return bind11(liftEffect3(log4("API error: " + printError(result.value0))))(function() {
                        return throwError2(error("API error: " + printError(result.value0)));
                    });
                    if (result instanceof Right) return bind11(liftEffect3(log4("Got response, decoding JSON array...")))(function() {
                        return bind11(function() {
                            var v2 = decodeJson5(result.value0.body);
                            if (v2 instanceof Left) return bind11(liftEffect3(log4("JSON array decode error: " + show15(v2.value0))))(function() {
                                return throwError2(error("JSON array decode error: " + show15(v2.value0)));
                            });
                            if (v2 instanceof Right) return bind11(liftEffect3(log4("Decoded array with " + (show16(length(v2.value0)) + " items"))))(function() {
                                return pure17(v2.value0);
                            });
                            throw new Error("Failed pattern match at Database.API (line 36, column 28 - line 42, column 23): " + [
                                v2.constructor.name
                            ]);
                        }())(function(customersJson) {
                            return bind11(liftEffect3(log4("Decoding customers...")))(function() {
                                var v2 = traverse6(decodeCustomer)(customersJson);
                                if (v2 instanceof Left) return bind11(liftEffect3(log4("Customer decode error: " + v2.value0)))(function() {
                                    return throwError2(error("Customer decode error: " + v2.value0));
                                });
                                if (v2 instanceof Right) return bind11(liftEffect3(log4("Successfully decoded " + (show16(length(v2.value0)) + " customers"))))(function() {
                                    return pure17(v2.value0);
                                });
                                throw new Error("Failed pattern match at Database.API (line 44, column 11 - line 50, column 29): " + [
                                    v2.constructor.name
                                ]);
                            });
                        });
                    });
                    throw new Error("Failed pattern match at Database.API (line 30, column 7 - line 50, column 29): " + [
                        result.constructor.name
                    ]);
                });
            })),
            getChangesSince: function(since) {
                return liftAff2(bind11(get3(json2)(apiUrl2 + ("/changes?since=" + since)))(function(result) {
                    if (result instanceof Left) return throwError2(error("API error: " + printError(result.value0)));
                    if (result instanceof Right) return bind11(function() {
                        var v2 = decodeJson5(result.value0.body);
                        if (v2 instanceof Left) return throwError2(error("JSON array decode error: " + show15(v2.value0)));
                        if (v2 instanceof Right) return pure17(v2.value0);
                        throw new Error("Failed pattern match at Database.API (line 57, column 26 - line 59, column 34): " + [
                            v2.constructor.name
                        ]);
                    }())(function(changesJson) {
                        var v2 = traverse6(decodeCustomer)(changesJson);
                        if (v2 instanceof Left) return throwError2(error("Customer decode error: " + v2.value0));
                        if (v2 instanceof Right) return pure17(v2.value0);
                        throw new Error("Failed pattern match at Database.API (line 60, column 11 - line 62, column 46): " + [
                            v2.constructor.name
                        ]);
                    });
                    throw new Error("Failed pattern match at Database.API (line 54, column 7 - line 62, column 46): " + [
                        result.constructor.name
                    ]);
                }));
            },
            addNewCustomer: function(name16) {
                return liftAff2(bind11(post2(json2)(apiUrl2)(new Just(json(encodeJson3({
                    name: name16
                })))))(function(result) {
                    if (result instanceof Left) return throwError2(error("API error: " + printError(result.value0)));
                    if (result instanceof Right) {
                        var v2 = decodeCustomer(result.value0.body);
                        if (v2 instanceof Left) return throwError2(error("Customer decode error: " + v2.value0));
                        if (v2 instanceof Right) return pure17(v2.value0);
                        throw new Error("Failed pattern match at Database.API (line 68, column 27 - line 70, column 42): " + [
                            v2.constructor.name
                        ]);
                    }
                    throw new Error("Failed pattern match at Database.API (line 66, column 7 - line 70, column 42): " + [
                        result.constructor.name
                    ]);
                }));
            },
            updateCustomerField: function(v2) {
                return liftAff2(bind11(put2(json2)(apiUrl2 + ("/" + show16(v2.id)))(new Just(json(encodeJson1({
                    field: v2.field,
                    value: v2.value
                })))))(function(result) {
                    if (result instanceof Left) return throwError2(error("API error: " + printError(result.value0)));
                    if (result instanceof Right) {
                        var v1 = decodeCustomer(result.value0.body);
                        if (v1 instanceof Left) return throwError2(error("Customer decode error: " + v1.value0));
                        if (v1 instanceof Right) return pure17(v1.value0);
                        throw new Error("Failed pattern match at Database.API (line 76, column 27 - line 78, column 42): " + [
                            v1.constructor.name
                        ]);
                    }
                    throw new Error("Failed pattern match at Database.API (line 74, column 7 - line 78, column 42): " + [
                        result.constructor.name
                    ]);
                }));
            },
            deleteCustomer: function(id4) {
                return liftAff2(bind11(delete_2(apiUrl2 + ("/" + show16(id4))))(function(result) {
                    if (result instanceof Left) return throwError2(error("API error: " + printError(result.value0)));
                    if (result instanceof Right) return pure17(unit);
                    throw new Error("Failed pattern match at Database.API (line 82, column 7 - line 84, column 29): " + [
                        result.constructor.name
                    ]);
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
    var Loading = /* @__PURE__ */ function() {
        function Loading2() {}
        Loading2.value = new Loading2();
        return Loading2;
    }();
    var Interactive = /* @__PURE__ */ function() {
        function Interactive2() {}
        Interactive2.value = new Interactive2();
        return Interactive2;
    }();
    var Complete = /* @__PURE__ */ function() {
        function Complete2() {}
        Complete2.value = new Complete2();
        return Complete2;
    }();
    var parse = function(v2) {
        if (v2 === "loading") return new Just(Loading.value);
        if (v2 === "interactive") return new Just(Interactive.value);
        if (v2 === "complete") return new Just(Complete.value);
        return Nothing.value;
    };
    // output/Web.HTML.HTMLDocument/index.js
    var map28 = /* @__PURE__ */ map(functorEffect);
    var toParentNode = unsafeCoerce2;
    var toDocument = unsafeCoerce2;
    var readyState = function(doc) {
        return map28(function() {
            var $4 = fromMaybe(Loading.value);
            return function($5) {
                return $4(parse($5));
            };
        }())(function() {
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
    var bind14 = /* @__PURE__ */ bind(bindAff);
    var liftEffect4 = /* @__PURE__ */ liftEffect(monadEffectAff);
    var bindFlipped6 = /* @__PURE__ */ bindFlipped(bindEffect);
    var composeKleisliFlipped5 = /* @__PURE__ */ composeKleisliFlipped(bindEffect);
    var pure18 = /* @__PURE__ */ pure(applicativeAff);
    var bindFlipped1 = /* @__PURE__ */ bindFlipped(bindMaybe);
    var pure19 = /* @__PURE__ */ pure(applicativeEffect);
    var map29 = /* @__PURE__ */ map(functorEffect);
    var discard6 = /* @__PURE__ */ discard(discardUnit);
    var throwError3 = /* @__PURE__ */ throwError(monadThrowAff);
    var selectElement = function(query2) {
        return bind14(liftEffect4(bindFlipped6(composeKleisliFlipped5(function() {
            var $16 = querySelector(query2);
            return function($17) {
                return $16(toParentNode($17));
            };
        }())(document2))(windowImpl)))(function(mel) {
            return pure18(bindFlipped1(fromElement)(mel));
        });
    };
    var runHalogenAff = /* @__PURE__ */ runAff_(/* @__PURE__ */ either(throwException)(/* @__PURE__ */ $$const(/* @__PURE__ */ pure19(unit))));
    var awaitLoad = /* @__PURE__ */ makeAff(function(callback) {
        return function __do3() {
            var rs = bindFlipped6(readyState)(bindFlipped6(document2)(windowImpl))();
            if (rs instanceof Loading) {
                var et = map29(toEventTarget)(windowImpl)();
                var listener = eventListener(function(v2) {
                    return callback(new Right(unit));
                })();
                addEventListener2(domcontentloaded)(listener)(false)(et)();
                return effectCanceler(removeEventListener2(domcontentloaded)(listener)(false)(et));
            }
            callback(new Right(unit))();
            return nonCanceler;
        };
    });
    var awaitBody = /* @__PURE__ */ discard6(bindAff)(awaitLoad)(function() {
        return bind14(selectElement("body"))(function(body2) {
            return maybe(throwError3(error("Could not find body")))(pure18)(body2);
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
    var initDriverState = function(component7) {
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
                            component: component7,
                            state: component7.initialState(input3),
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
    var bindFlipped7 = /* @__PURE__ */ bindFlipped(bindMaybe);
    var lookup5 = /* @__PURE__ */ lookup2(ordSubscriptionId);
    var bind15 = /* @__PURE__ */ bind(bindAff);
    var liftEffect5 = /* @__PURE__ */ liftEffect(monadEffectAff);
    var discard7 = /* @__PURE__ */ discard(discardUnit);
    var discard1 = /* @__PURE__ */ discard7(bindAff);
    var traverse_12 = /* @__PURE__ */ traverse_(applicativeAff);
    var traverse_22 = /* @__PURE__ */ traverse_12(foldableList);
    var fork3 = /* @__PURE__ */ fork2(monadForkAff);
    var parSequence_3 = /* @__PURE__ */ parSequence_(parallelAff)(applicativeParAff)(foldableList);
    var pure20 = /* @__PURE__ */ pure(applicativeAff);
    var map30 = /* @__PURE__ */ map(functorCoyoneda);
    var parallel3 = /* @__PURE__ */ parallel(parallelAff);
    var map110 = /* @__PURE__ */ map(functorAff);
    var sequential2 = /* @__PURE__ */ sequential(parallelAff);
    var map210 = /* @__PURE__ */ map(functorMaybe);
    var insert7 = /* @__PURE__ */ insert3(ordSubscriptionId);
    var retractFreeAp2 = /* @__PURE__ */ retractFreeAp(applicativeParAff);
    var $$delete5 = /* @__PURE__ */ $$delete3(ordForkId);
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
                return traverse_4(unsubscribe)(bindFlipped7(lookup5(sid))(subs))();
            };
        };
    };
    var queueOrRun = function(ref2) {
        return function(au) {
            return bind15(liftEffect5(read(ref2)))(function(v2) {
                if (v2 instanceof Nothing) return au;
                if (v2 instanceof Just) return liftEffect5(write(new Just(new Cons(au, v2.value0)))(ref2));
                throw new Error("Failed pattern match at Halogen.Aff.Driver.Eval (line 188, column 33 - line 190, column 57): " + [
                    v2.constructor.name
                ]);
            });
        };
    };
    var handleLifecycle = function(lchs) {
        return function(f) {
            return discard1(liftEffect5(write({
                initializers: Nil.value,
                finalizers: Nil.value
            })(lchs)))(function() {
                return bind15(liftEffect5(f))(function(result) {
                    return bind15(liftEffect5(read(lchs)))(function(v2) {
                        return discard1(traverse_22(fork3)(v2.finalizers))(function() {
                            return discard1(parSequence_3(v2.initializers))(function() {
                                return pure20(result);
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
            return bind15(liftEffect5(read(ref2)))(function(v2) {
                return liftEffect5(modify$prime(function(i2) {
                    return {
                        state: i2 + 1 | 0,
                        value: f(i2)
                    };
                })(v2.fresh));
            });
        };
    };
    var evalQ = function(render6) {
        return function(ref2) {
            return function(q3) {
                return bind15(liftEffect5(read(ref2)))(function(v2) {
                    return evalM(render6)(ref2)(v2["component"]["eval"](new Query(map30(Just.create)(liftCoyoneda(q3)), $$const(Nothing.value))));
                });
            };
        };
    };
    var evalM = function(render6) {
        return function(initRef) {
            return function(v2) {
                var evalChildQuery = function(ref2) {
                    return function(cqb) {
                        return bind15(liftEffect5(read(ref2)))(function(v1) {
                            return unChildQueryBox(function(v22) {
                                var evalChild = function(v3) {
                                    return parallel3(bind15(liftEffect5(read(v3)))(function(dsx) {
                                        return unDriverStateX(function(ds) {
                                            return evalQ(render6)(ds.selfRef)(v22.value1);
                                        })(dsx);
                                    }));
                                };
                                return map110(v22.value2)(sequential2(v22.value0(applicativeParAff)(evalChild)(v1.children)));
                            })(cqb);
                        });
                    };
                };
                var go2 = function(ref2) {
                    return function(v1) {
                        if (v1 instanceof State) return bind15(liftEffect5(read(ref2)))(function(v22) {
                            var v3 = v1.value0(v22.state);
                            if (unsafeRefEq(v22.state)(v3.value1)) return pure20(v3.value0);
                            if (otherwise) return discard1(liftEffect5(write({
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
                                return discard1(handleLifecycle(v22.lifecycleHandlers)(render6(v22.lifecycleHandlers)(ref2)))(function() {
                                    return pure20(v3.value0);
                                });
                            });
                            throw new Error("Failed pattern match at Halogen.Aff.Driver.Eval (line 86, column 7 - line 92, column 21): " + [
                                v3.constructor.name
                            ]);
                        });
                        if (v1 instanceof Subscribe) return bind15(fresh(SubscriptionId)(ref2))(function(sid) {
                            return bind15(liftEffect5(subscribe(v1.value0(sid))(function(act) {
                                return handleAff(evalF(render6)(ref2)(new Action(act)));
                            })))(function(finalize) {
                                return bind15(liftEffect5(read(ref2)))(function(v22) {
                                    return discard1(liftEffect5(modify_(map210(insert7(sid)(finalize)))(v22.subscriptions)))(function() {
                                        return pure20(v1.value1(sid));
                                    });
                                });
                            });
                        });
                        if (v1 instanceof Unsubscribe) return discard1(liftEffect5(unsubscribe3(v1.value0)(ref2)))(function() {
                            return pure20(v1.value1);
                        });
                        if (v1 instanceof Lift2) return v1.value0;
                        if (v1 instanceof ChildQuery2) return evalChildQuery(ref2)(v1.value0);
                        if (v1 instanceof Raise) return bind15(liftEffect5(read(ref2)))(function(v22) {
                            return bind15(liftEffect5(read(v22.handlerRef)))(function(handler3) {
                                return discard1(queueOrRun(v22.pendingOuts)(handler3(v1.value0)))(function() {
                                    return pure20(v1.value1);
                                });
                            });
                        });
                        if (v1 instanceof Par) return sequential2(retractFreeAp2(hoistFreeAp(function() {
                            var $119 = evalM(render6)(ref2);
                            return function($120) {
                                return parallel3($119($120));
                            };
                        }())(v1.value0)));
                        if (v1 instanceof Fork) return bind15(fresh(ForkId)(ref2))(function(fid) {
                            return bind15(liftEffect5(read(ref2)))(function(v22) {
                                return bind15(liftEffect5($$new(false)))(function(doneRef) {
                                    return bind15(fork3($$finally(liftEffect5(function __do3() {
                                        modify_($$delete5(fid))(v22.forks)();
                                        return write(true)(doneRef)();
                                    }))(evalM(render6)(ref2)(v1.value0))))(function(fiber) {
                                        return discard1(liftEffect5(unlessM2(read(doneRef))(modify_(insert12(fid)(fiber))(v22.forks))))(function() {
                                            return pure20(v1.value1(fid));
                                        });
                                    });
                                });
                            });
                        });
                        if (v1 instanceof Join) return bind15(liftEffect5(read(ref2)))(function(v22) {
                            return bind15(liftEffect5(read(v22.forks)))(function(forkMap) {
                                return discard1(traverse_32(joinFiber)(lookup12(v1.value0)(forkMap)))(function() {
                                    return pure20(v1.value1);
                                });
                            });
                        });
                        if (v1 instanceof Kill) return bind15(liftEffect5(read(ref2)))(function(v22) {
                            return bind15(liftEffect5(read(v22.forks)))(function(forkMap) {
                                return discard1(traverse_32(killFiber(error("Cancelled")))(lookup12(v1.value0)(forkMap)))(function() {
                                    return pure20(v1.value1);
                                });
                            });
                        });
                        if (v1 instanceof GetRef) return bind15(liftEffect5(read(ref2)))(function(v22) {
                            return pure20(v1.value1(lookup22(v1.value0)(v22.refs)));
                        });
                        throw new Error("Failed pattern match at Halogen.Aff.Driver.Eval (line 83, column 12 - line 139, column 33): " + [
                            v1.constructor.name
                        ]);
                    };
                };
                return foldFree2(go2(initRef))(v2);
            };
        };
    };
    var evalF = function(render6) {
        return function(ref2) {
            return function(v2) {
                if (v2 instanceof RefUpdate) return liftEffect5(flip(modify_)(ref2)(mapDriverState(function(st) {
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
                if (v2 instanceof Action) return bind15(liftEffect5(read(ref2)))(function(v1) {
                    return evalM(render6)(ref2)(v1["component"]["eval"](new Action2(v2.value0, unit)));
                });
                throw new Error("Failed pattern match at Halogen.Aff.Driver.Eval (line 52, column 20 - line 58, column 62): " + [
                    v2.constructor.name
                ]);
            };
        };
    };
    // output/Halogen.Aff.Driver/index.js
    var bind16 = /* @__PURE__ */ bind(bindEffect);
    var discard8 = /* @__PURE__ */ discard(discardUnit);
    var for_2 = /* @__PURE__ */ for_(applicativeEffect)(foldableMaybe);
    var traverse_5 = /* @__PURE__ */ traverse_(applicativeAff)(foldableList);
    var fork4 = /* @__PURE__ */ fork2(monadForkAff);
    var bindFlipped8 = /* @__PURE__ */ bindFlipped(bindEffect);
    var traverse_13 = /* @__PURE__ */ traverse_(applicativeEffect);
    var traverse_23 = /* @__PURE__ */ traverse_13(foldableMaybe);
    var traverse_33 = /* @__PURE__ */ traverse_13(foldableMap);
    var discard22 = /* @__PURE__ */ discard8(bindAff);
    var parSequence_4 = /* @__PURE__ */ parSequence_(parallelAff)(applicativeParAff)(foldableList);
    var liftEffect6 = /* @__PURE__ */ liftEffect(monadEffectAff);
    var pure21 = /* @__PURE__ */ pure(applicativeEffect);
    var map31 = /* @__PURE__ */ map(functorEffect);
    var pure110 = /* @__PURE__ */ pure(applicativeAff);
    var when3 = /* @__PURE__ */ when(applicativeEffect);
    var renderStateX2 = /* @__PURE__ */ renderStateX(functorEffect);
    var $$void7 = /* @__PURE__ */ $$void(functorAff);
    var foreachSlot2 = /* @__PURE__ */ foreachSlot(applicativeEffect);
    var renderStateX_2 = /* @__PURE__ */ renderStateX_(applicativeEffect);
    var tailRecM3 = /* @__PURE__ */ tailRecM(monadRecEffect);
    var voidLeft3 = /* @__PURE__ */ voidLeft(functorEffect);
    var bind17 = /* @__PURE__ */ bind(bindAff);
    var liftEffect1 = /* @__PURE__ */ liftEffect(monadEffectEffect);
    var newLifecycleHandlers = /* @__PURE__ */ function() {
        return $$new({
            initializers: Nil.value,
            finalizers: Nil.value
        });
    }();
    var handlePending = function(ref2) {
        return function __do3() {
            var queue = read(ref2)();
            write(Nothing.value)(ref2)();
            return for_2(queue)(function() {
                var $59 = traverse_5(fork4);
                return function($60) {
                    return handleAff($59(reverse2($60)));
                };
            }())();
        };
    };
    var cleanupSubscriptionsAndForks = function(v2) {
        return function __do3() {
            bindFlipped8(traverse_23(traverse_33(unsubscribe)))(read(v2.subscriptions))();
            write(Nothing.value)(v2.subscriptions)();
            bindFlipped8(traverse_33(function() {
                var $61 = killFiber(error("finalized"));
                return function($62) {
                    return handleAff($61($62));
                };
            }()))(read(v2.forks))();
            return write(empty3)(v2.forks)();
        };
    };
    var runUI = function(renderSpec2) {
        return function(component7) {
            return function(i2) {
                var squashChildInitializers = function(lchs) {
                    return function(preInits) {
                        return unDriverStateX(function(st) {
                            var parentInitializer = evalM(render6)(st.selfRef)(st["component"]["eval"](new Initialize(unit)));
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
                                    bindFlipped8(unDriverStateX(function() {
                                        var $63 = render6(lchs);
                                        return function($64) {
                                            return $63(function(v2) {
                                                return v2.selfRef;
                                            }($64));
                                        };
                                    }()))(read($$var2))();
                                    bindFlipped8(squashChildInitializers(lchs)(pre2.initializers))(read($$var2))();
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
                                return unComponentSlot(function(slot5) {
                                    return function __do3() {
                                        var childrenIn = map31(slot5.pop)(read(childrenInRef))();
                                        var $$var2 = function() {
                                            if (childrenIn instanceof Just) {
                                                write(childrenIn.value0.value1)(childrenInRef)();
                                                var dsx = read(childrenIn.value0.value0)();
                                                unDriverStateX(function(st) {
                                                    return function __do4() {
                                                        flip(write)(st.handlerRef)(function() {
                                                            var $65 = maybe(pure110(unit))(handler3);
                                                            return function($66) {
                                                                return $65(slot5.output($66));
                                                            };
                                                        }())();
                                                        return handleAff(evalM(render6)(st.selfRef)(st["component"]["eval"](new Receive(slot5.input, unit))))();
                                                    };
                                                })(dsx)();
                                                return childrenIn.value0.value0;
                                            }
                                            if (childrenIn instanceof Nothing) return runComponent(lchs)(function() {
                                                var $67 = maybe(pure110(unit))(handler3);
                                                return function($68) {
                                                    return $67(slot5.output($68));
                                                };
                                            }())(slot5.input)(slot5.component)();
                                            throw new Error("Failed pattern match at Halogen.Aff.Driver (line 213, column 14 - line 222, column 98): " + [
                                                childrenIn.constructor.name
                                            ]);
                                        }();
                                        var isDuplicate = map31(function($69) {
                                            return isJust(slot5.get($69));
                                        })(read(childrenOutRef))();
                                        when3(isDuplicate)(warn("Halogen: Duplicate slot address was detected during rendering, unexpected results may occur"))();
                                        modify_(slot5.set($$var2))(childrenOutRef)();
                                        return bind16(read($$var2))(renderStateX2(function(v2) {
                                            if (v2 instanceof Nothing) return $$throw("Halogen internal error: child was not initialized in renderChild");
                                            if (v2 instanceof Just) return pure21(renderSpec2.renderChild(v2.value0));
                                            throw new Error("Failed pattern match at Halogen.Aff.Driver (line 227, column 37 - line 229, column 50): " + [
                                                v2.constructor.name
                                            ]);
                                        }))();
                                    };
                                });
                            };
                        };
                    };
                };
                var render6 = function(lchs) {
                    return function($$var2) {
                        return function __do3() {
                            var v2 = read($$var2)();
                            var shouldProcessHandlers = map31(isNothing)(read(v2.pendingHandlers))();
                            when3(shouldProcessHandlers)(write(new Just(Nil.value))(v2.pendingHandlers))();
                            write(empty4)(v2.childrenOut)();
                            write(v2.children)(v2.childrenIn)();
                            var handler3 = function() {
                                var $70 = queueOrRun(v2.pendingHandlers);
                                var $71 = evalF(render6)(v2.selfRef);
                                return function($72) {
                                    return $70($$void7($71($72)));
                                };
                            }();
                            var childHandler = function() {
                                var $73 = queueOrRun(v2.pendingQueries);
                                return function($74) {
                                    return $73(handler3(Action.create($74)));
                                };
                            }();
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
                                    traverse_23(function() {
                                        var $76 = traverse_5(fork4);
                                        return function($77) {
                                            return handleAff($76(reverse2($77)));
                                        };
                                    }())(handlers)();
                                    var mmore = read(v2.pendingHandlers)();
                                    var $52 = maybe(false)($$null)(mmore);
                                    if ($52) return voidLeft3(write(Nothing.value)(v2.pendingHandlers))(new Done(unit))();
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
                            var f = evalM(render6)(st.selfRef)(st["component"]["eval"](new Finalize(unit)));
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
                            return bind17(liftEffect6(read(disposed)))(function(v2) {
                                if (v2) return pure110(Nothing.value);
                                return evalQ(render6)(ref2)(q3);
                            });
                        };
                    };
                };
                var dispose = function(disposed) {
                    return function(lchs) {
                        return function(dsx) {
                            return handleLifecycle(lchs)(function __do3() {
                                var v2 = read(disposed)();
                                if (v2) return unit;
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
                return bind17(liftEffect6(newLifecycleHandlers))(function(lchs) {
                    return bind17(liftEffect6($$new(false)))(function(disposed) {
                        return handleLifecycle(lchs)(function __do3() {
                            var sio = create();
                            var dsx = bindFlipped8(read)(runComponent(lchs)(function() {
                                var $78 = notify(sio.listener);
                                return function($79) {
                                    return liftEffect6($78($79));
                                };
                            }())(i2)(component7))();
                            return unDriverStateX(function(st) {
                                return pure21({
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
    var map32 = /* @__PURE__ */ map(functorEffect);
    var parentNode2 = /* @__PURE__ */ function() {
        var $6 = map32(toMaybe);
        return function($7) {
            return $6(_parentNode($7));
        };
    }();
    var nextSibling = /* @__PURE__ */ function() {
        var $15 = map32(toMaybe);
        return function($16) {
            return $15(_nextSibling($16));
        };
    }();
    // output/Halogen.VDom.Driver/index.js
    var $runtime_lazy9 = function(name16, moduleName, init3) {
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
    var pure23 = /* @__PURE__ */ pure(applicativeEffect);
    var traverse_6 = /* @__PURE__ */ traverse_(applicativeEffect)(foldableMaybe);
    var unwrap5 = /* @__PURE__ */ unwrap();
    var when4 = /* @__PURE__ */ when(applicativeEffect);
    var not2 = /* @__PURE__ */ not(/* @__PURE__ */ heytingAlgebraFunction(/* @__PURE__ */ heytingAlgebraFunction(heytingAlgebraBoolean)));
    var identity13 = /* @__PURE__ */ identity(categoryFn);
    var bind18 = /* @__PURE__ */ bind(bindAff);
    var liftEffect7 = /* @__PURE__ */ liftEffect(monadEffectAff);
    var map33 = /* @__PURE__ */ map(functorEffect);
    var bindFlipped9 = /* @__PURE__ */ bindFlipped(bindEffect);
    var substInParent = function(v2) {
        return function(v1) {
            return function(v22) {
                if (v1 instanceof Just && v22 instanceof Just) return $$void8(insertBefore(v2)(v1.value0)(v22.value0));
                if (v1 instanceof Nothing && v22 instanceof Just) return $$void8(appendChild(v2)(v22.value0));
                return pure23(unit);
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
                    if (st instanceof Just) return halt(st.value0);
                    return unit;
                };
                var buildWidget2 = function(spec) {
                    var buildThunk2 = buildThunk(unwrap5)(spec);
                    var $lazy_patch = $runtime_lazy9("patch", "Halogen.VDom.Driver", function() {
                        return function(st, slot5) {
                            if (st instanceof Just) {
                                if (slot5 instanceof ComponentSlot) {
                                    halt(st.value0);
                                    return $lazy_renderComponentSlot(100)(slot5.value0);
                                }
                                if (slot5 instanceof ThunkSlot) {
                                    var step$prime = step(st.value0, slot5.value0);
                                    return mkStep(new Step(extract2(step$prime), new Just(step$prime), $lazy_patch(103), done));
                                }
                                throw new Error("Failed pattern match at Halogen.VDom.Driver (line 97, column 22 - line 103, column 79): " + [
                                    slot5.constructor.name
                                ]);
                            }
                            return $lazy_render(104)(slot5);
                        };
                    });
                    var $lazy_render = $runtime_lazy9("render", "Halogen.VDom.Driver", function() {
                        return function(slot5) {
                            if (slot5 instanceof ComponentSlot) return $lazy_renderComponentSlot(86)(slot5.value0);
                            if (slot5 instanceof ThunkSlot) {
                                var step3 = buildThunk2(slot5.value0);
                                return mkStep(new Step(extract2(step3), new Just(step3), $lazy_patch(89), done));
                            }
                            throw new Error("Failed pattern match at Halogen.VDom.Driver (line 84, column 7 - line 89, column 75): " + [
                                slot5.constructor.name
                            ]);
                        };
                    });
                    var $lazy_renderComponentSlot = $runtime_lazy9("renderComponentSlot", "Halogen.VDom.Driver", function() {
                        return function(cs) {
                            var renderChild = read(renderChildRef)();
                            var rsx = renderChild(cs)();
                            var node = getNode(rsx);
                            return mkStep(new Step(node, Nothing.value, $lazy_patch(117), done));
                        };
                    });
                    var patch2 = $lazy_patch(91);
                    var render6 = $lazy_render(82);
                    var renderComponentSlot = $lazy_renderComponentSlot(109);
                    return render6;
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
            var render6 = function(handler3) {
                return function(child) {
                    return function(v2) {
                        return function(v1) {
                            if (v1 instanceof Nothing) return function __do3() {
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
                            if (v1 instanceof Just) return function __do3() {
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
                            throw new Error("Failed pattern match at Halogen.VDom.Driver (line 157, column 5 - line 173, column 80): " + [
                                v1.constructor.name
                            ]);
                        };
                    };
                };
            };
            return {
                render: render6,
                renderChild: identity13,
                removeChild: removeChild3,
                dispose: removeChild3
            };
        };
    };
    var runUI2 = function(component7) {
        return function(i2) {
            return function(element4) {
                return bind18(liftEffect7(map33(toDocument)(bindFlipped9(document2)(windowImpl))))(function(document3) {
                    return runUI(renderSpec(document3)(element4))(component7)(i2);
                });
            };
        };
    };
    // output/Main/index.js
    var component6 = /* @__PURE__ */ component5(monadAffAff);
    var main2 = /* @__PURE__ */ runHalogenAff(/* @__PURE__ */ bind(bindAff)(awaitBody)(function(body2) {
        return runUI2(component6(createAPIDatabase(monadAffAff)))(unit)(body2);
    }));
    // <stdin>
    main2();
})();

//# sourceMappingURL=dist.088a9467.js.map
