!function (root, factory) {
    "function" == typeof define && define.amd ? define(factory) : "object" == typeof exports ? module.exports = factory() : root.wdtLoading = factory()
}(this, function () {
    function hasClass(element, name) {
        var list = "string" == typeof element ? element : classList(element);
        return list.indexOf(" " + name + " ") >= 0
    }

    function addClass(element, name) {
        var oldList = classList(element), newList = oldList + name;
        hasClass(oldList, name) || (element.className = newList.substring(1))
    }

    function removeClass(element, name) {
        var newList, oldList = classList(element);
        hasClass(element, name) && (newList = oldList.replace(" " + name + " ", " "), element.className = newList.substring(1, newList.length - 1))
    }

    function classList(element) {
        return (" " + (element && element.className || "") + " ").replace(/\s+/gi, " ")
    }

    function removeElement(element) {
        element && element.parentNode && element.parentNode.removeChild(element)
    }

    function fadeOut(elem, speed ) {

        if (!elem.style.opacity) {
            elem.style.opacity = 1;
        } // end if

        var outInterval = setInterval(function() {
            elem.style.opacity -= 0.02;
            if (elem.style.opacity <= 0) {
                clearInterval(outInterval);
            } // end if
        }, speed/50 );

    } // end fadeOut()

    var wdtLoading = {};
    wdtLoading.defaults = {category: "default", speed: 2e3}, wdtLoading.start = function (options) {
        this.options = extend(wdtLoading.defaults, options), this.wdtLoadingScreen = document.querySelector(".wdt-loading-screen");
        for (var wdtPhraseCategories = document.querySelectorAll(".wdt-loading-phrase-category"), i = 0; i < wdtPhraseCategories.length; i++)css(wdtPhraseCategories[i], {display: "none"});
        this.wdtPhraseActiveCat = document.querySelector('.wdt-loading-phrase-category[data-category="' + this.options.category + '"]'), css(this.wdtPhraseActiveCat, {display: "block"}), this.activePhrases = this.wdtPhraseActiveCat.querySelectorAll(".wdt-loading-phrase"), this.activePhrasesCount = this.activePhrases.length, this.activePhrasesCount < 5 && console.warn("wdtLoading -->", "Add more phrase for better spin animation!");
        for (var sufflePhrases = [], i = 0; i < this.activePhrases.length; i++)sufflePhrases.push(this.activePhrases[i]), removeElement(this.activePhrases[i]);
        sufflePhrases = wdtLoading.shuffle(sufflePhrases);
        for (var i = 0; i < sufflePhrases.length; i++)this.wdtPhraseActiveCat.appendChild(sufflePhrases[i]);
        return css(this.wdtLoadingScreen, {display: "block"}), wdtLoading.spin(), this
    }, wdtLoading.spin = function () {
        var that = this;
        this.phraseHeight = that.wdtPhraseActiveCat.querySelector(".wdt-loading-phrase").scrollHeight, that.currentIndex = 0, that.currentTransform = 0, that.spinInternal = setInterval(function () {
            if (that.activePhrases = that.wdtPhraseActiveCat.querySelectorAll(".wdt-loading-phrase"), addClass(that.activePhrases[that.currentIndex], "wdt-checked"), that.currentIndex++, that.currentTransform = that.currentTransform - that.phraseHeight, css(that.wdtPhraseActiveCat, {transform: "translateY(" + that.currentTransform + "px)"}), that.currentIndex > 1) {
                var currentNone = that.activePhrases[that.currentIndex - 2], currentClone = currentNone.cloneNode(!0);
                removeClass(currentClone, "wdt-checked"), addClass(currentClone, "wdt-cloned-phrase"), currentClone.style.transform = "", that.wdtPhraseActiveCat.appendChild(currentClone)
            }
        }, this.options.speed)
    }, wdtLoading.done = function () {
        this.spinInternal && clearInterval(this.spinInternal);
        var self = this;

        fadeOut(this.wdtLoadingScreen, 500);

        setTimeout(function() {
            css(self.wdtLoadingScreen, {display: "none"});
        }, 350);

        for (var clonePhrases = document.querySelectorAll(".wdt-cloned-phrase"), allPhrases = document.querySelectorAll(".wdt-loading-phrase"), i = 0; i < allPhrases.length; i++)removeClass(allPhrases[i], "wdt-checked");
        this.wdtPhraseActiveCat.style.transform = "";
        for (var i = 0; i < clonePhrases.length; i++)removeElement(clonePhrases[i]);
        clearInterval(this.spinInternal)
    }, wdtLoading.shuffle = function (array) {
        for (var t, i, m = array.length; m;)i = Math.floor(Math.random() * m--), t = array[m], array[m] = array[i], array[i] = t;
        return array
    };
    var extend = function () {
        var extended = {}, deep = !1, i = 0, length = arguments.length;
        "[object Boolean]" === Object.prototype.toString.call(arguments[0]) && (deep = arguments[0], i++);
        for (var merge = function (obj) {
            for (var prop in obj)Object.prototype.hasOwnProperty.call(obj, prop) && (deep && "[object Object]" === Object.prototype.toString.call(obj[prop]) ? extended[prop] = extend(!0, extended[prop], obj[prop]) : extended[prop] = obj[prop])
        }; length > i; i++) {
            var obj = arguments[i];
            merge(obj)
        }
        return extended
    }, css = function () {
        function camelCase(string) {
            return string.replace(/^-ms-/, "ms-").replace(/-([\da-z])/gi, function (match, letter) {
                return letter.toUpperCase()
            })
        }

        function getVendorProp(name) {
            var style = document.body.style;
            if (name in style)return name;
            for (var vendorName, i = cssPrefixes.length, capName = name.charAt(0).toUpperCase() + name.slice(1); i--;)if (vendorName = cssPrefixes[i] + capName, vendorName in style)return vendorName;
            return name
        }

        function getStyleProp(name) {
            return name = camelCase(name), cssProps[name] || (cssProps[name] = getVendorProp(name))
        }

        function applyCss(element, prop, value) {
            prop = getStyleProp(prop), element.style[prop] = value
        }

        var cssPrefixes = ["Webkit", "O", "Moz", "ms"], cssProps = {};
        return function (element, properties) {
            var prop, value, args = arguments;
            if (2 == args.length)for (prop in properties)value = properties[prop], void 0 !== value && properties.hasOwnProperty(prop) && applyCss(element, prop, value); else applyCss(element, args[1], args[2])
        }
    }();
    return wdtLoading
});