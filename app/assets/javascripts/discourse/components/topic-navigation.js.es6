import { observes } from 'ember-addons/ember-computed-decorators';

export default Ember.Component.extend({
  composerOpen: null,
  info: Em.Object.create(),

  _checkSize() {
    let info = this.get('info');

    if (info.get('topicProgressExpanded')) {

      info.setProperties({
        renderTimeline: true,
        renderAdminMenuButton: true
      });

    } else {

      let renderTimeline = !this.site.mobileView;

      if (renderTimeline) {

        const width = $(window).width();
        let height = $(window).height();

        if (this.get('composerOpen')) {
          height -= $('#reply-control').height();
        }

        renderTimeline = width > 960 && height > 520;
      }

      info.setProperties({
        renderTimeline,
        renderAdminMenuButton: !renderTimeline
      });
    }
  },

  // we need to store this so topic progress has something to init with
  _topicScrolled(event) {
    this.set('info.prevEvent', event);
  },

  @observes('info.topicProgressExpanded')
  _expanded() {
    if (this.get('info.topicProgressExpanded')) {
      $(window).on('click.hide-fullscreen', (e) => {
        if (!$(e.target).parents().is('.timeline-container, #topic-progress-wrapper')) {
          this._collapseFullscreen();
        }
      });
    } else {
      $(window).off('click.hide-fullscreen');
    }
    this._checkSize();
  },

  composerOpened() {
    this.set('composerOpen', true);
    // we need to do the check after animation is done
    setTimeout(()=>this._checkSize(), 500);
  },

  composerClosed() {
    this.set('composerOpen', false);
    this._checkSize();
  },

  _collapseFullscreen() {
    if (this.get('info.topicProgressExpanded')) {
      $('.timeline-fullscreen').removeClass('show');
      setTimeout(() => {
        this.set('info.topicProgressExpanded', false);
        this._checkSize();
      },500);
    }
  },

  keyboardTrigger(e) {
    if(e.type === "jump") {
      bootbox.prompt(I18n.t('topic.progress.jump_prompt_long'), postIndex => {
        if (postIndex === null) { return; }
        this.sendAction('jumpToIndex', postIndex);
      });

      // this is insanely hacky, for some reason shown event never fires,
      // something is bust in bootbox
      // TODO upgrade bootbox to see if this hack can be removed
      setTimeout(()=>{
        $('.bootbox.modal').trigger('shown');
      },50);

    }
  },

  didInsertElement() {
    this._super();

    this.appEvents
      .on('topic:current-post-scrolled', this, this._topicScrolled)
      .on('topic:jump-to-post', this, this._collapseFullscreen)
      .on('topic:keyboard-trigger', this, this.keyboardTrigger);

    if (!this.site.mobileView) {
      $(window).on('resize.discourse-topic-navigation', () => this._checkSize());
      this.appEvents.on('composer:will-open', this, this.composerOpened);
      this.appEvents.on('composer:will-close', this, this.composerClosed);
      $('#reply-control').on('div-resized.discourse-topic-navigation', () => this._checkSize());
    }

    this._checkSize();
  },

  willDestroyElement() {
    this._super();

    this.appEvents
      .off('topic:current-post-scrolled', this, this._topicScrolled)
      .off('topic:jump-to-post', this, this._collapseFullscreen)
      .off('topic:keyboard-trigger', this, this.keyboardTrigger);

    $(window).off('click.hide-fullscreen');

    if (!this.site.mobileView) {
      $(window).off('resize.discourse-topic-navigation');
      this.appEvents.off('composer:will-open', this, this.composerOpened);
      this.appEvents.off('composer:will-close', this, this.composerClosed);
      $('#reply-control').off('div-resized.discourse-topic-navigation');
    }
  }
});
