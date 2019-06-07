import { on } from "ember-addons/ember-computed-decorators";

export default Ember.Mixin.create({
  init() {
    this._super(...arguments);

    this.keys = {
      TAB: 9,
      ENTER: 13,
      ESC: 27,
      UP: 38,
      DOWN: 40,
      BACKSPACE: 8,
      LEFT: 37,
      RIGHT: 39,
      A: 65
    };
  },

  @on("didInsertElement")
  _setupEvents() {
    $(document).on("mousedown.select-kit", this._mouseDownHandler.bind(this));

    this.$header()
      .on("blur.select-kit", this._blurHeaderHandler.bind(this))
      .on("focus.select-kit", this._focusHeaderHandler.bind(this))
      .on("keydown.select-kit", this._keydownHeaderHandler.bind(this))
      .on("keypress.select-kit", this._keypressHeaderHandler.bind(this));

    this.$filterInput()
      .on("change.select-kit", this._changeFilterInputHandler.bind(this))
      .on("keypress.select-kit", this._keypressFilterInputHandler.bind(this))
      .on("focusout.select-kit", this._focusoutFilterInputHandler.bind(this))
      .on("keydown.select-kit", this._keydownFilterInputHandler.bind(this));
  },

  @on("willDestroyElement")
  _cleanUpEvents() {
    $(document).off("mousedown.select-kit", this._mouseDownHandler);

    if (this.$header().length) {
      this.$header()
        .off("blur.select-kit", this._blurHeaderHandler)
        .off("focus.select-kit", this._focusHeaderHandler)
        .off("keydown.select-kit", this._keydownHeaderHandler)
        .off("keypress.select-kit", this._keypressHeaderHandler);
    }

    if (this.$filterInput().length) {
      this.$filterInput()
        .off("change.select-kit", this._changeFilterInputHandler)
        .off("keydown.select-kit", this._keydownFilterInputHandler)
        .off("keypress.select-kit", this._keypressFilterInputHandler)
        .off("focusout.select-kit", this._focusoutFilterInputHandler);
    }
  },

  _mouseDownHandler(event) {
    if (!this.element || this.isDestroying || this.isDestroyed) {
      return true;
    }

    if (Ember.$.contains(this.element, event.target)) {
      event.stopPropagation();
      if (!this.renderedBodyOnce) return;
      if (!this.isFocused) return;
    } else {
      this.didClickOutside(event);
    }
  },

  _blurHeaderHandler() {
    if (!this.isExpanded && this.isFocused) {
      this.close();
    }
  },

  _focusHeaderHandler(event) {
    this.set("isFocused", true);
    this._destroyEvent(event);
  },

  _keydownHeaderHandler(event) {
    if (document.activeElement !== this.$header()[0]) return event;

    const keyCode = event.keyCode || event.which;

    if (keyCode === this.keys.TAB && event.shiftKey) {
      this.unfocus(event);
    }
    if (keyCode === this.keys.TAB && !event.shiftKey) this.tabFromHeader(event);
    if (Ember.isEmpty(this.filter) && keyCode === this.keys.BACKSPACE)
      this.backspaceFromHeader(event);
    if (keyCode === this.keys.ESC) this.escapeFromHeader(event);
    if (keyCode === this.keys.ENTER) this.enterFromHeader(event);
    if ([this.keys.UP, this.keys.DOWN].includes(keyCode))
      this.upAndDownFromHeader(event);
    if (
      Ember.isEmpty(this.filter) &&
      [this.keys.LEFT, this.keys.RIGHT].includes(keyCode)
    ) {
      this.leftAndRightFromHeader(event);
    }
    return event;
  },

  _keypressHeaderHandler(event) {
    const keyCode = event.keyCode || event.which;

    if (keyCode === this.keys.ENTER) return true;
    if (keyCode === this.keys.TAB) return true;

    this.expand(event);

    if (this.filterable || this.autoFilterable) {
      this.set("renderedFilterOnce", true);
    }

    Ember.run.schedule("afterRender", () => {
      this.$filterInput()
        .focus()
        .val(this.$filterInput().val() + String.fromCharCode(keyCode));
    });

    return false;
  },

  _keydownFilterInputHandler(event) {
    const keyCode = event.keyCode || event.which;

    if (
      Ember.isEmpty(this.filter) &&
      keyCode === this.keys.BACKSPACE &&
      typeof this.didPressBackspaceFromFilter === "function"
    ) {
      this.didPressBackspaceFromFilter(event);
    }

    if (keyCode === this.keys.TAB && event.shiftKey) {
      this.unfocus(event);
    }
    if (keyCode === this.keys.TAB && !event.shiftKey) this.tabFromFilter(event);
    if (keyCode === this.keys.ESC) this.escapeFromFilter(event);
    if (keyCode === this.keys.ENTER) this.enterFromFilter(event);
    if ([this.keys.UP, this.keys.DOWN].includes(keyCode))
      this.upAndDownFromFilter(event);

    if (
      Ember.isEmpty(this.filter) &&
      [this.keys.LEFT, this.keys.RIGHT].includes(keyCode)
    ) {
      this.leftAndRightFromFilter(event);
    }
  },

  _changeFilterInputHandler(event) {
    this.send("onFilterComputedContent", $(event.target).val());
  },
  _keypressFilterInputHandler(event) {
    event.stopPropagation();
  },
  _focusoutFilterInputHandler(event) {
    this.onFilterInputFocusout(event);
  },

  didPressTab(event) {
    if (this.$highlightedRow().length && this.isExpanded) {
      this.close(event);
      this.$header().focus();
      const guid = this.$highlightedRow().attr("data-guid");
      this.select(this._findComputedContentItemByGuid(guid));
      return true;
    }

    if (Ember.isEmpty(this.filter)) {
      this.close(event);
      return true;
    }

    return true;
  },

  didPressEnter(event) {
    if (!this.isExpanded) {
      this.expand(event);
    } else if (this.$highlightedRow().length) {
      this.close(event);
      this.$header().focus();
      const guid = this.$highlightedRow().attr("data-guid");
      this.select(this._findComputedContentItemByGuid(guid));
    }

    return true;
  },

  didClickSelectionItem(computedContentItem) {
    this.focus();
    this.deselect(computedContentItem);
  },

  didClickRow(computedContentItem) {
    this.close();
    this.focus();
    this.select(computedContentItem);
  },

  didPressEscape(event) {
    this._destroyEvent(event);

    if (this.highlightedSelection.length && this.isExpanded) {
      this.clearHighlightSelection();
    } else {
      this.unfocus(event);
    }
  },

  didPressUpAndDownArrows(event) {
    this._destroyEvent(event);

    this.clearHighlightSelection();

    const keyCode = event.keyCode || event.which;

    if (!this.isExpanded) {
      this.expand(event);

      if (this.$selectedRow().length === 1) {
        this._highlightRow(this.$selectedRow());
        return;
      }

      return;
    }

    const $rows = this.$rows();

    if (!$rows.length) {
      return;
    }

    if ($rows.length === 1) {
      this._rowSelection($rows, 0);
      return;
    }

    const direction = keyCode === 38 ? -1 : 1;

    Ember.run.throttle(this, this._moveHighlight, direction, $rows, 32);
  },

  didPressBackspaceFromFilter(event) {
    this.didPressBackspace(event);
  },
  didPressBackspace(event) {
    if (!this.isExpanded) {
      this.expand();
      if (event) event.stopImmediatePropagation();
      return;
    }

    if (!this.selection || !this.selection.length) return;

    if (!Ember.isEmpty(this.filter)) {
      this.clearHighlightSelection();
      return;
    }

    if (!this.highlightedSelection.length) {
      // try to highlight the last non locked item from the current selection
      Ember.makeArray(this.selection)
        .slice()
        .reverse()
        .some(selection => {
          if (!Ember.get(selection, "locked")) {
            this.highlightSelection(selection);
            return true;
          }
        });

      if (event) event.stopImmediatePropagation();
    } else {
      this.deselect(this.highlightedSelection);
      if (event) event.stopImmediatePropagation();
    }
  },

  didPressSelectAll() {
    this.highlightSelection(Ember.makeArray(this.selection));
  },

  didClickOutside(event) {
    if (this.isExpanded && $(event.target).parents(".select-kit").length) {
      this.close(event);
      return false;
    }

    this.close(event);
    return;
  },

  // make sure we don’t propagate a click outside component
  // to avoid closing a modal containing the component for example
  click(event) {
    this._destroyEvent(event);
  },

  didPressLeftAndRightArrows(event) {
    if (!this.isExpanded) {
      this.expand();
      event.stopImmediatePropagation();
      return;
    }

    if (Ember.isEmpty(this.selection)) return;

    const keyCode = event.keyCode || event.which;

    if (keyCode === this.keys.LEFT) {
      const prev = this.get("highlightedSelection.lastObject");
      const indexOfPrev = this.selection.indexOf(prev);

      if (this.selection[indexOfPrev - 1]) {
        this.highlightSelection(this.selection[indexOfPrev - 1]);
      } else {
        this.highlightSelection(this.get("selection.lastObject"));
      }
    } else {
      const prev = this.get("highlightedSelection.firstObject");
      const indexOfNext = this.selection.indexOf(prev);

      if (this.selection[indexOfNext + 1]) {
        this.highlightSelection(this.selection[indexOfNext + 1]);
      } else {
        this.highlightSelection(this.get("selection.firstObject"));
      }
    }
  },

  tabFromHeader(event) {
    this.didPressTab(event);
  },
  tabFromFilter(event) {
    this.didPressTab(event);
  },

  escapeFromHeader(event) {
    this.didPressEscape(event);
  },
  escapeFromFilter(event) {
    this.didPressEscape(event);
  },

  upAndDownFromHeader(event) {
    this.didPressUpAndDownArrows(event);
  },
  upAndDownFromFilter(event) {
    this.didPressUpAndDownArrows(event);
  },

  leftAndRightFromHeader(event) {
    this.didPressLeftAndRightArrows(event);
  },
  leftAndRightFromFilter(event) {
    this.didPressLeftAndRightArrows(event);
  },

  backspaceFromHeader(event) {
    this.didPressBackspace(event);
  },

  enterFromHeader(event) {
    this.didPressEnter(event);
  },
  enterFromFilter(event) {
    this.didPressEnter(event);
  },

  onFilterInputFocusout(event) {
    if (!Ember.$.contains(this.element, event.relatedTarget)) {
      this.close(event);
    }
  },

  _moveHighlight(direction, $rows) {
    const currentIndex = $rows.index(this.$highlightedRow());
    let nextIndex = currentIndex + direction;

    if (nextIndex < 0) {
      nextIndex = $rows.length - 1;
    } else if (nextIndex >= $rows.length) {
      nextIndex = 0;
    }

    this._rowSelection($rows, nextIndex);
  },

  _rowSelection($rows, nextIndex) {
    const highlightableValue = $rows.eq(nextIndex).attr("data-value");
    const $highlightableRow = this.$findRowByValue(highlightableValue);
    this._highlightRow($highlightableRow);
  },

  _highlightRow($row) {
    Ember.run.schedule("afterRender", () => {
      $row.trigger("mouseover").focus();
      this.focus();
    });
  }
});
