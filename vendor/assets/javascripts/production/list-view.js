// ==========================================================================
// Project:   Ember ListView
// Copyright: ©2012-2013 Erik Bryn, Yapp Inc., and contributors.
// License:   Licensed under MIT license
// Version:   0.0.5
// ==========================================================================

(function(e){var t,i,n,r;(function(){var e;if(!Array.isArray){e=function(e){return Object.prototype.toString.call(e)==="[object Array]"}}else{e=Array.isArray}var s={},o={},l={};var h=false;t=function(t,i,n){if(!e(i)){n=i;i=[]}s[t]={deps:i,callback:n}};function a(e,t,i){var r=e.length;var s=new Array(r);var o;var l;for(var h=0,a=r;h<a;h++){o=e[h];if(o==="exports"){l=s[h]=i}else{s[h]=n(c(o,t))}}return{deps:s,exports:l}}r=n=i=function(e){if(l[e]!==h&&o.hasOwnProperty(e)){return o[e]}if(!s[e]){throw new Error("Could not find module "+e)}var t=s[e];var i;var n;var r=false;o[e]={};try{i=a(t.deps,e,o[e]);n=t.callback.apply(this,i.deps);r=true}finally{if(!r){l[e]=h}}return i.exports?o[e]:o[e]=n};function c(e,t){if(e.charAt(0)!=="."){return e}var i=e.split("/");var n=t.split("/");var r;if(n.length===1){r=n}else{r=n.slice(0,-1)}for(var s=0,o=i.length;s<o;s++){var l=i[s];if(l===".."){r.pop()}else if(l==="."){continue}else{r.push(l)}}return r.join("/")}r.entries=r._eak_seen=s;r.clear=function(){r.entries=r._eak_seen=s={};o=l={}}})();t("list-view/helper",["exports"],function(e){"use strict";e["default"]=function t(e){var t=e.hash;var i=e.hashTypes;t.content=t.items;delete t.items;i.content=i.items;delete i.items;if(!t.content){t.content="this";i.content="ID"}for(var n in t){if(/-/.test(n)){var r=Ember.String.camelize(n);t[r]=t[n];i[r]=i[n];delete t[n];delete i[n]}}return Ember.Handlebars.helpers.collection.call(this,"Ember.ListView",e)}});t("list-view/list_item_view",["list-view/list_item_view_mixin","exports"],function(e,t){"use strict";var i=e["default"];var n=Ember.get,r=Ember.set;function s(e){var t=[],i=e.childBuffers;Ember.ArrayPolyfills.forEach.call(i,function(e){var i=typeof e==="string";if(i){t.push(e)}else{e.array(t)}});return t.join("")}function o(e){if(e.willInsertElement){e.willInsertElement()}}function l(e){if(e.didInsertElement){e.didInsertElement()}}function h(){var e,t,i,h;e=n(this,"element");if(!e){return}i=n(this,"context");this.triggerRecursively("willClearRender");if(this.lengthAfterRender>this.lengthBeforeRender){this.clearRenderedChildren();this._childViews.length=this.lengthBeforeRender}if(i){t=Ember.RenderBuffer();t=this.renderToBuffer(t);h=this._childViews.length>0;if(h){this.invokeRecursively(o,false)}e.innerHTML=t.innerString?t.innerString():s(t);r(this,"element",e);var a=this._transitionTo?this._transitionTo:this.transitionTo;a.call(this,"inDOM");if(h){this.invokeRecursively(l,false)}}else{e.innerHTML=""}}t["default"]=Ember.View.extend(i,{updateContext:function(e){var t=n(this,"context");Ember.instrument("view.updateContext.render",this,function(){if(t!==e){r(this,"context",e);if(e&&e.isController){r(this,"controller",e)}}},this)},rerender:function(){Ember.run.scheduleOnce("render",this,h)},_contextDidChange:Ember.observer(h,"context","controller")})});t("list-view/list_item_view_mixin",["exports"],function(e){"use strict";var t=Ember.get,i=Ember.set;function n(e,t){return e&&t&&e.x===t.x&&e.y===t.y}function r(){var e,i,r;Ember.instrument("view.updateContext.positionElement",this,function(){e=t(this,"element");i=this.position;r=this._position;if(!i||!e){return}if(n(i,r)){return}Ember.run.schedule("render",this,this._parentView.applyTransform,e,i.x,i.y);this._position=i},this)}e["default"]=Ember.Mixin.create({init:function(){this._super();this.one("didInsertElement",r)},classNames:["ember-list-item-view"],_position:null,updatePosition:function(e){this.position=e;this._positionElement()},_positionElement:r})});t("list-view/list_view",["list-view/list_view_helper","list-view/list_view_mixin","exports"],function(e,t,i){"use strict";var n=e["default"];var r=t["default"];var s=Ember.get,o=Ember.set;i["default"]=Ember.ContainerView.extend(r,{css:{position:"relative",overflow:"auto","-webkit-overflow-scrolling":"touch","overflow-scrolling":"touch"},applyTransform:n.applyTransform,_scrollTo:function(e){var t=s(this,"element");if(t){t.scrollTop=e}},didInsertElement:function(){var e=this;var t=s(this,"element");this._updateScrollableHeight();this._scroll=function(t){e.scroll(t)};Ember.$(t).on("scroll",this._scroll)},willDestroyElement:function(){var e;e=s(this,"element");Ember.$(e).off("scroll",this._scroll)},scroll:function(e){this.scrollTo(e.target.scrollTop)},scrollTo:function(e){var t=s(this,"element");this._scrollTo(e);this._scrollContentTo(e)},totalHeightDidChange:Ember.observer(function(){Ember.run.scheduleOnce("afterRender",this,this._updateScrollableHeight)},"totalHeight"),_updateScrollableHeight:function(){var e,t;t=this._state||this.state;if(t==="inDOM"){if(this._isChildEmptyView()){e=""}else{e=s(this,"totalHeight")}this.$(".ember-list-container").css({height:e})}}})});t("list-view/list_view_helper",["exports"],function(e){"use strict";var t=document.createElement("div"),i=t.style;var n=["Webkit","Moz","O","ms"];function r(e){if(e in i)return e;var t=e.charAt(0).toUpperCase()+e.slice(1);for(var r=0;r<n.length;r++){var s=n[r]+t;if(s in i){return s}}return null}var s=r("transform");var o=r("perspective");var l=s!==null;var h=o!==null;e["default"]={transformProp:s,applyTransform:function(){if(l){return function(e,t,i){e.style[s]="translate("+t+"px, "+i+"px)"}}else{return function(e,t,i){e.style.top=i+"px";e.style.left=t+"px"}}}(),apply3DTransform:function(){if(h){return function(e,t,i){e.style[s]="translate3d("+t+"px, "+i+"px, 0)"}}else if(l){return function(e,t,i){e.style[s]="translate("+t+"px, "+i+"px)"}}else{return function(e,t,i){e.style.top=i+"px";e.style.left=t+"px"}}}()}});t("list-view/list_view_mixin",["list-view/reusable_list_item_view","exports"],function(e,t){"use strict";var i=e["default"];var n=Ember.get,r=Ember.set,s=Math.min,o=Math.max,l=Math.floor,h=Math.ceil,a=Ember.ArrayPolyfills.forEach;function c(){var e=n(this,"content");if(e){e.addArrayObserver(this)}}function u(e){this.removeObject(e);e.destroy()}function d(){Ember.run.once(this,"_syncChildViews")}function f(e,t){return n(e,"contentIndex")-n(t,"contentIndex")}function m(){if(Ember.View.notifyMutationListeners){Ember.run.once(Ember.View,"notifyMutationListeners")}}function v(){var e=n(this,"emptyView");if(e&&e instanceof Ember.View){e.removeFromParent();if(this.totalHeightDidChange!==undefined){this.totalHeightDidChange()}}}function g(){var e=n(this,"emptyView");if(!e){return}if("string"===typeof e){e=n(e)||e}e=this.createChildView(e);r(this,"emptyView",e);if(Ember.CoreView.detect(e)){this._createdEmptyView=e}this.unshiftObject(e)}var w=Ember.create(Ember.ContainerView.proto().domManager);w.prepend=function(e,t){e.$(".ember-list-container").prepend(t);m()};function p(){function e(e,t,i){console.time(e)}function t(e,t,i){console.timeEnd(e)}if(Ember.ENABLE_PROFILING){Ember.subscribe("view._scrollContentTo",{before:e,after:t});Ember.subscribe("view.updateContext",{before:e,after:t})}}t["default"]=Ember.Mixin.create({itemViewClass:i,emptyViewClass:Ember.View,classNames:["ember-list-view"],attributeBindings:["style"],classNameBindings:["_isGrid:ember-list-view-grid:ember-list-view-list"],domManager:w,scrollTop:0,bottomPadding:0,_lastEndingIndex:0,paddingCount:1,_cachedPos:0,_isGrid:Ember.computed("columnCount",function(){return this.get("columnCount")>1}).readOnly(),init:function(){this._super();this._cachedHeights=[0];this.on("didInsertElement",this._syncListContainerWidth);this.columnCountDidChange();this._syncChildViews();this._addContentArrayObserver()},_addContentArrayObserver:Ember.beforeObserver(function(){c.call(this)},"content"),render:function(e){e.push('<div class="ember-list-container">');this._super(e);e.push("</div>")},willInsertElement:function(){if(!this.get("height")||!this.get("rowHeight")){throw new Error("A ListView must be created with a height and a rowHeight.")}this._super()},style:Ember.computed("height","width",function(){var e,t,i,r;e=n(this,"height");t=n(this,"width");r=n(this,"css");i="";if(e){i+="height:"+e+"px;"}if(t){i+="width:"+t+"px;"}for(var s in r){if(r.hasOwnProperty(s)){i+=s+":"+r[s]+";"}}return i}),scrollTo:function(e){throw new Error("must override to perform the visual scroll and effectively delegate to _scrollContentTo")},_scrollTo:Ember.K,_scrollContentTo:function(e){var t,i,r,l,h,a,c,u,d;u=o(0,e);if(this.scrollTop===u){return}var f=o(0,n(this,"totalHeight")-n(this,"height"));u=s(u,f);d=n(this,"content");c=n(d,"length");t=this._startingIndex(c);Ember.instrument("view._scrollContentTo",{scrollTop:u,content:d,startingIndex:t,endingIndex:s(o(c-1,0),t+this._numChildViewsForViewport())},function(){this.scrollTop=u;h=o(c-1,0);t=this._startingIndex();l=t+this._numChildViewsForViewport();i=s(h,l);if(t===this._lastStartingIndex&&i===this._lastEndingIndex){this.trigger("scrollYChanged",e);return}else{Ember.run(this,function(){this._reuseChildren();this._lastStartingIndex=t;this._lastEndingIndex=i;this.trigger("scrollYChanged",e)})}},this)},totalHeight:Ember.computed("content.length","rowHeight","columnCount","bottomPadding",function(){if(typeof this.heightForIndex==="function"){return this._totalHeightWithHeightForIndex()}else{return this._totalHeightWithStaticRowHeight()}}),_doRowHeightDidChange:function(){this._cachedHeights=[0];this._cachedPos=0;this._syncChildViews()},_rowHeightDidChange:Ember.observer("rowHeight",function(){Ember.run.once(this,this._doRowHeightDidChange)}),_totalHeightWithHeightForIndex:function(){var e=this.get("content.length");return this._cachedHeightLookup(e)},_totalHeightWithStaticRowHeight:function(){var e,t,i,r;e=n(this,"content.length");t=n(this,"rowHeight");i=n(this,"columnCount");r=n(this,"bottomPadding");return h(e/i)*t+r},_prepareChildForReuse:function(e){e.prepareForReuse()},_reuseChildForContentIndex:function(e,t){var i,s,o,l,h,a,c;var u=this.itemViewForIndex(t);if(e.constructor!==u){var d=this._childViews.indexOf(e);e.destroy();e=this.createChildView(u);this.insertAt(d,e)}i=n(this,"content");a=n(this,"enableProfiling");h=this.positionForIndex(t);e.updatePosition(h);r(e,"contentIndex",t);if(a){Ember.instrument("view._reuseChildForContentIndex",h,function(){},this)}o=i.objectAt(t);e.updateContext(o)},positionForIndex:function(e){if(typeof this.heightForIndex!=="function"){return this._singleHeightPosForIndex(e)}else{return this._multiHeightPosForIndex(e)}},_singleHeightPosForIndex:function(e){var t,i,r,s,o,h;t=n(this,"elementWidth")||1;i=n(this,"width")||1;r=n(this,"columnCount");s=n(this,"rowHeight");o=s*l(e/r);h=e%r*t;return{y:o,x:h}},_multiHeightPosForIndex:function(e){var t,i,r,s,o,l;t=n(this,"elementWidth")||1;i=n(this,"width")||1;r=n(this,"columnCount");l=e%r*t;o=this._cachedHeightLookup(e);return{x:l,y:o}},_cachedHeightLookup:function(e){for(var t=this._cachedPos;t<e;t++){this._cachedHeights[t+1]=this._cachedHeights[t]+this.heightForIndex(t)}this._cachedPos=t;return this._cachedHeights[e]},_childViewCount:function(){var e,t;e=n(this,"content.length");t=this._numChildViewsForViewport();return s(e,t)},columnCount:Ember.computed("width","elementWidth",function(){var e,t,i;e=n(this,"elementWidth");t=n(this,"width");if(e&&t>e){i=l(t/e)}else{i=1}return i}),columnCountDidChange:Ember.observer(function(){var e,t,i,r,o,l,h,a;l=this._lastColumnCount;t=this.scrollTop;h=n(this,"columnCount");r=n(this,"maxScrollTop");a=n(this,"element");this._lastColumnCount=h;if(l){e=l/h;i=t*e;o=s(r,i);this._scrollTo(o);this.scrollTop=o}if(arguments.length>0){Ember.run.schedule("afterRender",this,this._syncListContainerWidth)}},"columnCount"),maxScrollTop:Ember.computed("height","totalHeight",function(){var e,t;e=n(this,"totalHeight");t=n(this,"height");return o(0,e-t)}),_isChildEmptyView:function(){var e=n(this,"emptyView");return e&&e instanceof Ember.View&&this._childViews.length===1&&this._childViews.indexOf(e)===0},_numChildViewsForViewport:function(){if(this.heightForIndex){return this._numChildViewsForViewportWithMultiHeight()}else{return this._numChildViewsForViewportWithoutMultiHeight()}},_numChildViewsForViewportWithoutMultiHeight:function(){var e,t,i,r;e=n(this,"height");t=n(this,"rowHeight");i=n(this,"paddingCount");r=n(this,"columnCount");return h(e/t)*r+i*r},_numChildViewsForViewportWithMultiHeight:function(){var e,t,i;var r=this.scrollTop;var s=this.get("height");var o=this.get("content.length");var l=0;var h=n(this,"paddingCount");var a=this._calculatedStartingIndex();var c=0;var u=this._cachedHeightLookup(a);for(var d=0;d<o;d++){if(this._cachedHeightLookup(a+d+1)-u>s){break}}return d+h+1},_startingIndex:function(e){var t,i,r,h,a;if(e===undefined){a=n(this,"content.length")}else{a=e}t=this.scrollTop;i=n(this,"rowHeight");r=n(this,"columnCount");if(this.heightForIndex){h=this._calculatedStartingIndex()}else{h=l(t/i)*r}var c=this._numChildViewsForViewport();var u=1*r;var d=o(a-c,0);return s(h,d)},_calculatedStartingIndex:function(){var e,t,i;var r=this.scrollTop;var s=this.get("height");var o=this.get("content.length");var l=0;var h=n(this,"paddingCount");for(var a=0;a<o;a++){if(this._cachedHeightLookup(a+1)>=r){break}}return a},contentWillChange:Ember.beforeObserver(function(){var e;e=n(this,"content");if(e){e.removeArrayObserver(this)}},"content"),contentDidChange:Ember.observer(function(){c.call(this);d.call(this)},"content"),needsSyncChildViews:Ember.observer(d,"height","width","columnCount"),_addItemView:function(e){var t,i;t=this.itemViewForIndex(e);i=this.createChildView(t);this.pushObject(i)},itemViewForIndex:function(e){return n(this,"itemViewClass")},heightForIndex:null,_syncChildViews:function(){var e,t,i,r,s,o,l,h,c,d,f;if(n(this,"isDestroyed")||n(this,"isDestroying")){return}h=n(this,"content.length");c=n(this,"emptyView");t=this._childViewCount();e=this.positionOrderedChildViews();if(this._isChildEmptyView()){v.call(this)}o=this._startingIndex();l=o+t;r=t;i=e.length;f=r-i;if(f===0){}else if(f>0){s=this._lastEndingIndex;for(d=0;d<f;d++,s++){this._addItemView(s)}}else{a.call(e.splice(r,i),u,this)}this._reuseChildren();this._lastStartingIndex=o;this._lastEndingIndex=this._lastEndingIndex+f;if(h===0||h===undefined){g.call(this)}},_syncListContainerWidth:function(){var e,t,i,r;e=n(this,"elementWidth");t=n(this,"columnCount");i=e*t;r=this.$(".ember-list-container");if(i&&r){r.css("width",i)}},_reuseChildren:function(){var e,t,i,r,l,h,a,c,u,d,f,m;m=this.scrollTop;e=n(this,"content.length");d=o(e-1,0);t=this.getReusableChildViews();i=t.length;r=this._startingIndex();u=r+this._numChildViewsForViewport();l=s(d,u);f=s(u,r+i);for(c=r;c<f;c++){h=t[c%i];this._reuseChildForContentIndex(h,c)}},getReusableChildViews:function(){return this._childViews},positionOrderedChildViews:function(){return this.getReusableChildViews().sort(f)},arrayWillChange:Ember.K,arrayDidChange:function(e,t,i,n){var r,s,o;if(this._isChildEmptyView()){v.call(this)}o=this._state||this.state;if(o==="inDOM"){if(t>=this._lastStartingIndex||t<this._lastEndingIndex){r=0;a.call(this.positionOrderedChildViews(),function(e){s=this._lastStartingIndex+r;this._reuseChildForContentIndex(e,s);r++},this)}d.call(this)}},destroy:function(){if(!this._super()){return}if(this._createdEmptyView){this._createdEmptyView.destroy()}return this}})});t("list-view/main",["list-view/reusable_list_item_view","list-view/virtual_list_view","list-view/list_item_view","list-view/helper","list-view/list_view","list-view/list_view_helper"],function(e,t,i,n,r,s){"use strict";var o=e["default"];var l=t["default"];var h=i["default"];var a=n["default"];var c=r["default"];var u=s["default"];Ember.ReusableListItemView=o;Ember.VirtualListView=l;Ember.ListItemView=h;Ember.ListView=c;Ember.ListViewHelper=u;Ember.Handlebars.registerHelper("ember-list",a)});t("list-view/reusable_list_item_view",["list-view/list_item_view_mixin","exports"],function(e,t){"use strict";var i=e["default"];var n=Ember.get,r=Ember.set;t["default"]=Ember.View.extend(i,{init:function(){this._super();var e=Ember.ObjectProxy.create();this.set("context",e);this._proxyContext=e},isVisible:Ember.computed("context.content",function(){return!!this.get("context.content")}),updateContext:function(e){var t=n(this._proxyContext,"content"),i;i=this._state||this.state;if(t!==e){if(i==="inDOM"){this.prepareForReuse(e)}r(this._proxyContext,"content",e);if(e&&e.isController){r(this,"controller",e)}}},prepareForReuse:Ember.K})});t("list-view/virtual_list_scroller_events",["exports"],function(e){"use strict";var t=/input|textarea|select/i,i="ontouchstart"in window||window.DocumentTouch&&document instanceof window.DocumentTouch,n,r,s,o,l,h,a,c;if(i){l="touchstart";n=function(e){var i=e.touches[0],n=i&&i.target;if(n&&t.test(n.tagName)){return}m(this.scrollerEventHandlers);this.willBeginScroll(e.touches,e.timeStamp);e.preventDefault()};h="touchmove";r=function(e){this.continueScroll(e.touches,e.timeStamp)};a="touchend";s=function(e){if(!this._isScrolling){w(e)}v(this.scrollerEventHandlers);this.endScroll(e.timeStamp)};c="touchcancel";o=function(e){v(this.scrollerEventHandlers);this.endScroll(e.timeStamp)}}else{l="mousedown";n=function(e){if(e.which!==1)return;var i=e.target;if(i&&t.test(i.tagName)){return}m(this.scrollerEventHandlers);this.willBeginScroll([e],e.timeStamp);e.preventDefault()};h="mousemove";r=function(e){this.continueScroll([e],e.timeStamp)};a="mouseup";s=function(e){v(this.scrollerEventHandlers);this.endScroll(e.timeStamp)};c="mouseout";o=function(e){if(e.relatedTarget)return;v(this.scrollerEventHandlers);this.endScroll(e.timeStamp)}}function u(e){this.mouseWheel(e);e.preventDefault()}function d(e,t){e.addEventListener(l,t.start,false);e.addEventListener("mousewheel",t.wheel,false)}function f(e,t){e.removeEventListener(l,t.start,false);e.removeEventListener("mousewheel",t.wheel,false)}function m(e){window.addEventListener(h,e.move,true);window.addEventListener(a,e.end,true);window.addEventListener(c,e.cancel,true)}function v(e){window.removeEventListener(h,e.move,true);window.removeEventListener(a,e.end,true);window.removeEventListener(c,e.cancel,true)}e["default"]=Ember.Mixin.create({init:function(){this.on("didInsertElement",this,"bindScrollerEvents");this.on("willDestroyElement",this,"unbindScrollerEvents");this.scrollerEventHandlers={start:g(this,n),move:g(this,r),end:g(this,s),cancel:g(this,o),wheel:g(this,u)};return this._super()},scrollElement:Ember.computed.oneWay("element").readOnly(),bindScrollerEvents:function(){var e=this.get("scrollElement"),t=this.scrollerEventHandlers;d(e,t)},unbindScrollerEvents:function(){var e=this.get("scrollElement"),t=this.scrollerEventHandlers;f(e,t);v(t)}});function g(e,t){return function(i){t.call(e,i)}}function w(e){var i=e.changedTouches[0],n=i.target,r;if(n&&t.test(n.tagName)){r=document.createEvent("MouseEvents");r.initMouseEvent("click",true,true,e.view,1,i.screenX,i.screenY,i.clientX,i.clientY,e.ctrlKey,e.altKey,e.shiftKey,e.metaKey,0,null);return n.dispatchEvent(r)}}});t("list-view/virtual_list_view",["list-view/list_view_mixin","list-view/list_view_helper","list-view/virtual_list_scroller_events","exports"],function(e,t,i,n){"use strict";var r=e["default"];var s=t["default"];var o=i["default"];var l=Math.max,h=Ember.get,a=Ember.set;function c(e){var t,i,n;e=e||this;t=h(e,"width");i=h(e,"height");n=h(e,"totalHeight");e.scroller.setDimensions(t,i,t,n);e.trigger("scrollerDimensionsDidChange")}n["default"]=Ember.ContainerView.extend(r,o,{_isScrolling:false,_mouseWheel:null,css:{position:"relative",overflow:"hidden"},init:function(){this._super();this.setupScroller();this.setupPullToRefresh()},_scrollerTop:0,applyTransform:s.apply3DTransform,setupScroller:function(){var e,t;e=this;e.scroller=new Scroller(function(t,i,n){var r=e._state||e.state;if(r!=="inDOM"){return}if(e.listContainerElement){e._scrollerTop=i;e._scrollContentTo(i);e.applyTransform(e.listContainerElement,0,-i)}},{scrollingX:false,scrollingComplete:function(){e.trigger("scrollingDidComplete")}});e.trigger("didInitializeScroller");c(e)},setupPullToRefresh:function(){if(!this.pullToRefreshViewClass){return}this._insertPullToRefreshView();this._activateScrollerPullToRefresh()},_insertPullToRefreshView:function(){this.pullToRefreshView=this.createChildView(this.pullToRefreshViewClass);this.insertAt(0,this.pullToRefreshView);var e=this;this.pullToRefreshView.on("didInsertElement",function(){Ember.run.schedule("afterRender",this,function(){e.applyTransform(this.get("element"),0,-1*e.pullToRefreshViewHeight)})})},_activateScrollerPullToRefresh:function(){var e=this;function t(){e.pullToRefreshView.set("active",true);e.trigger("activatePullToRefresh")}function i(){e.pullToRefreshView.set("active",false);e.trigger("deactivatePullToRefresh")}function n(){Ember.run(function(){e.pullToRefreshView.set("refreshing",true);function t(){if(e&&!e.get("isDestroyed")&&!e.get("isDestroying")){e.scroller.finishPullToRefresh();e.pullToRefreshView.set("refreshing",false)}}e.startRefresh(t)})}this.scroller.activatePullToRefresh(this.pullToRefreshViewHeight,t,i,n)},getReusableChildViews:function(){var e=this._childViews[0];if(e&&e===this.pullToRefreshView){return this._childViews.slice(1)}else{return this._childViews}},scrollerDimensionsNeedToChange:Ember.observer(function(){Ember.run.once(this,c)},"width","height","totalHeight"),didInsertElement:function(){this.listContainerElement=this.$("> .ember-list-container")[0]},willBeginScroll:function(e,t){this._isScrolling=false;this.trigger("scrollingDidStart");this.scroller.doTouchStart(e,t)},continueScroll:function(e,t){var i,n,r;if(this._isScrolling){this.scroller.doTouchMove(e,t)}else{i=this._scrollerTop;this.scroller.doTouchMove(e,t);n=this._scrollerTop;if(i!==n){r=Ember.$.Event("scrollerstart");Ember.$(e[0].target).trigger(r);this._isScrolling=true}}},endScroll:function(e){this.scroller.doTouchEnd(e)},scrollTo:function(e,t){if(t===undefined){t=true}this.scroller.scrollTo(0,e,t,1)},mouseWheel:function(e){var t,i,n;t=e.webkitDirectionInvertedFromDevice;i=e.wheelDeltaY*(t?.8:-.8);n=this.scroller.__scrollTop+i;if(n>=0&&n<=this.scroller.__maxScrollTop){this.scroller.scrollBy(0,i,true);e.stopPropagation()}return false}})});i("list-view/main")})(this);