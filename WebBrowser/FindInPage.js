/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// 只对页面或iframe的origin与页面的origin相同时的文本有效

(function() {
"use strict";

var DEBUG_ENABLED = false;
var MATCH_HIGHLIGHT_ACTIVE = "#f19750";
var MATCH_HIGHLIGHT_INACTIVE = "#ffde49";
var SCROLL_INTERVAL_INCREMENT = 5;
var SCROLL_INTERVAL_DURATION = 400;
var SCROLL_OFFSET = 60;
var IFRAME_WIDTH_HEIGHT_THRESHOLD = 20; //对于iframe宽高做一个约束，过小的直接跳过

var activeHighlightSpan = null;
var lastSearch;
var scrollInterval;
var activeIndex = 0;
var highlightSpans = [];

function debug(str) {
  if (DEBUG_ENABLED) {
    console.log("FindInPage: " + str);
  }
}

function postJSBridgeMessage(message) {
  var element = document.createElement('iframe');
  element.style.display = 'none';

  var messageStr = JSON.stringify(message);
  var escapedMessageStr = encodeURI(messageStr);

  element.src = "zwfindinpage://message?json=" + escapedMessageStr;
  document.documentElement.appendChild(element);
  setTimeout(function() { document.documentElement.removeChild(element); }, 0);
}

function isElementVisible(elem) {
  return getComputedStyle(elem).visibility !== "hidden";
}

function isRectInViewport(rect) {
  var left = rect.left + document.body.scrollLeft;
  var right = rect.right + document.body.scrollLeft;
  var top = rect.top + document.body.scrollTop;
  var bottom = rect.bottom + document.body.scrollTop;

  return rect.width > 0 &&
         rect.height > 0 &&
         right >= 0 &&
         bottom >= 0 &&
         left <= document.body.scrollWidth &&
         top <= document.body.scrollHeight;
}

function findMatches(text) {
  // For case-insensitive matching.
  var lowerText = text.toLocaleLowerCase();
  var upperText = text.toLocaleUpperCase();

  var matches = [];
  var frames = window.frames;
  var framesOrWin = [];

  for (var i = 0; i < frames.length; i++) {
    framesOrWin.push(frames[i]);
  }
  framesOrWin.push(window);

  for (var m = 0;m < framesOrWin.length;m++){
      var winOrIframeDocument;
      //由于安全政策，当frame origin和页面origin不一致时，会抛出异常
      try {
        winOrIframeDocument = framesOrWin[m].window.document;
      }
      catch (e) {
        continue;
      }
      // 防止frame过多导致挂起
      if (!(framesOrWin[m].window.innerHeight > IFRAME_WIDTH_HEIGHT_THRESHOLD && framesOrWin[m].window.innerWidth > IFRAME_WIDTH_HEIGHT_THRESHOLD)) {
        continue;
      }

      var range = winOrIframeDocument.createRange();
      var walker = winOrIframeDocument.createTreeWalker(winOrIframeDocument.body, NodeFilter.SHOW_TEXT, null, false);
      var textLength = text.length;
      var node;
      while (node = walker.nextNode()) {
        var textContent = node.textContent;
        // 遍历节点所有字符
        findString: for (var i = 0; i < textContent.length - textLength + 1; ++i) {
          for (var j = 0; j < textLength; ++j) {
            var nextChar = textContent[i + j];
            if (lowerText[j] !== nextChar && upperText[j] !== nextChar) {
              continue findString;
            }
          }

          // This node is a TextNode, not an Element. Its parent is the nearest Element.
          var element = node.parentNode;

          // Find the rect of just the text for this match.
          range.setStart(node, i);
          range.setEnd(node, i + textLength);
          var textRect = range.getBoundingClientRect();

          // We have a match, but we need to make sure it's visible. The condition
          // below checks the following cases:
          // * If this element or any of its parents has style visibility hidden.
          //   The visibility style is inherited, so we need to check only this
          //   element and not all of its ancestors.
          // * If the highlight will be outside of the page's bounds. We determine
          //   this by comparing the bounds of the text rect.
          // * If the element style display is set to none. display:none collapses
          //   the element's space, so this will again be detected by looking at
          //   the text's rect: if the element is collapsed, the width and height
          //   will be zero.
          if (isElementVisible(element) && isRectInViewport(textRect)) {
            matches.push({ node: node, index: i });

            // Resume searching after this match to prevent overlapping results.
            i += textLength- 1;
          }
        }
      }
  }


  return matches;
}

function flattenNode(node) {
  var parent = node.parentNode;
  if (!parent) {
    return;
  }

  while (node.firstChild) {
    parent.insertBefore(node.firstChild, node);
  }

  node.remove();
  parent.normalize();
}

function clearHighlights() {
  if (highlightSpans.length > 0) {
    for (var span of highlightSpans) {
      flattenNode(span);
    }
    highlightSpans = [];
  }

  activeHighlightSpan = null;
}

function highlightAllMatches(text) {
  debug("Searching: " + text);

  clearHighlights();

  if (!text.trim()) {
  	postJSBridgeMessage({ totalResults: 0 });
    return;
  }

  var range = document.createRange();
  var matches = findMatches(text);
  var highlightTemplate = document.createElement("span");
  highlightTemplate.style.backgroundColor = MATCH_HIGHLIGHT_INACTIVE;

  // If there are multiple matches in the same node, inserting a highlight span before other matches
  // in that node will invalidate other matches since the node itself changes. By iterating through
  // results in reverse, we highlight matches last in the node first so earlier matches are unaffected.
  for (var i = matches.length - 1; i >= 0; --i) {
    var match = matches[i];
    var highlight = highlightTemplate.cloneNode();

    range.setStart(match.node, match.index);
    range.setEnd(match.node, match.index + text.length);
    range.surroundContents(highlight);
    highlightSpans.unshift(highlight);
  }

  debug(matches.length + " highlighted rects created!");
  postJSBridgeMessage({ totalResults: matches.length });
}

function getIDForRect(rect) {
  return rect.top + "," + rect.bottom + "," + rect.left + "," + rect.right;
}

function updateActiveHighlight() {
  // Reset the color of the previous highlight.
  if (activeHighlightSpan) {
    activeHighlightSpan.style.backgroundColor = MATCH_HIGHLIGHT_INACTIVE;
  }

  if (!highlightSpans.length) {
    return;
  }

  activeHighlightSpan = highlightSpans[activeIndex];
  activeHighlightSpan.style.backgroundColor = MATCH_HIGHLIGHT_ACTIVE;

  // Find the position of the element centered on the screen, then scroll to it.
  var rect = activeHighlightSpan.getBoundingClientRect();
  var top = SCROLL_OFFSET + rect.top + scrollY - window.innerHeight / 2;
  var left = rect.left + scrollX - window.innerWidth / 2;
  left = clamp(left, 0, document.body.scrollWidth);
  top = clamp(top, 0, document.body.scrollHeight);
  scrollToSelection(left, top, SCROLL_INTERVAL_DURATION);
  debug("Scrolled to: " + left + ", " + top);
}

function scrollToSelection(left, top, duration) {
  var time = 0;
  var startX = scrollX;
  var startY = scrollY;
  clearInterval(scrollInterval);
  scrollInterval = setInterval(function() {
    var xStep = easeOutCubic(time, startX, left - startX, duration);
    var yStep = easeOutCubic(time, startY, top - startY, duration);
    window.scrollTo(xStep, yStep);
    time += SCROLL_INTERVAL_INCREMENT;
    if (time >= duration) {
      clearInterval(scrollInterval);
    }                 
  }, SCROLL_INTERVAL_INCREMENT);
}

function easeOutCubic(currentTime, startValue, changeInValue, duration) {
  return changeInValue * (Math.pow(currentTime / duration - 1, 3) + 1) + startValue;
}

function clamp(number, min, max) {
  return Math.max(min, Math.min(number, max));
}

function updateSearch(text) {
  if (lastSearch == text) {
    // The text is the same, so we're either finding either the next or previous result.
    var totalResults = highlightSpans.length;
    activeIndex = (activeIndex + totalResults) % totalResults;
  } else {
    // Store the current active rect to decide which new match should be active.
    var activeHighlightRect = null;
    if (activeHighlightSpan) {
      activeHighlightRect = activeHighlightSpan.getBoundingClientRect();
    }

    // The search text changed, so scan the page for new results.
    highlightAllMatches(text);

    // If we found a match at or after the last match, use that position
    // instead of starting again from the top.
    activeIndex = 0;
    if (activeHighlightRect) {
      for (var i = 0; i < highlightSpans.length; i++) {
        var highlight = highlightSpans[i];
        var highlightRect = highlight.getBoundingClientRect();
        if ((highlightRect.top == activeHighlightRect.top && highlightRect.left >= activeHighlightRect.left) ||
            (highlightRect.top > activeHighlightRect.top)) {
          activeIndex = i;
          break;
        }
      }
    }

    lastSearch = text;
  }

  // Update the UI with the current match index.
  var currentResult = highlightSpans.length ? activeIndex + 1 : 0;
  postJSBridgeMessage({ currentResult: currentResult });

  updateActiveHighlight();
}

if (!window.__zhongwu__) {
  Object.defineProperty(window, '__zhongwu__', {
    enumerable: false,
    configurable: false,
    writable: false,
    value: {}
  });
}

Object.defineProperty(window.__zhongwu__, 'find', {
  enumerable: false,
  configurable: false,
  writable: false,
  value: function(text) {
    updateSearch(text);
  }
});

Object.defineProperty(window.__zhongwu__, 'findNext', {
  enumerable: false,
  configurable: false,
  writable: false,
  value: function(text) {
    activeIndex++;
    updateSearch(text);
  }
});

Object.defineProperty(window.__zhongwu__, 'findPrevious', {
  enumerable: false,
  configurable: false,
  writable: false,
  value: function(text) {
    activeIndex--;
    updateSearch(text);
  }
});

Object.defineProperty(window.__zhongwu__, 'findDone', {
  enumerable: false,
  configurable: false,
  writable: false,
  value: function() {
    clearHighlights();
    lastSearch = null;
  }
});

// 获取页内查找时选择的文本
Object.defineProperty(window.__zhongwu__, 'getSelection', {
  enumerable: false,
  configurable: false,
  writable: false,
  value: function() {
    var frames = window.frames;
    var framesOrWin = [];

    for (var i = 0; i < frames.length; i++) {
      framesOrWin.push(frames[i]);
    }
    framesOrWin.push(window);

    for (var i = 0;i < framesOrWin.length;i++){
        //由于安全政策，当frame origin和页面origin不一致时，会抛出异常
        try {
          if (!(framesOrWin[i].window.innerHeight > IFRAME_WIDTH_HEIGHT_THRESHOLD && framesOrWin[i].window.innerWidth > IFRAME_WIDTH_HEIGHT_THRESHOLD)) {
            continue;
          }
          var selectStr = framesOrWin[i].document.getSelection().toString();
          if (selectStr.length > 0){
              return selectStr;
          }
        }
        catch (e){}
    }
    return "";
  }
});

})();
