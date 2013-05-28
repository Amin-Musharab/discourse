/**
  This view handles the rendering of a topic list

  @class ListTopicsView
  @extends Discourse.View
  @namespace Discourse
  @uses Discourse.Scrolling
  @module Discourse
**/
Discourse.ListTopicsView = Discourse.View.extend(Discourse.Scrolling, {
  templateName: 'list/topics',
  categoryBinding: 'controller.controllers.list.category',
  canCreateTopicBinding: 'controller.controllers.list.canCreateTopic',
  listBinding: 'controller.model',
  loadedMore: false,
  currentTopicId: null,

  willDestroyElement: function() {
    this.unbindScrolling();
  },

  didInsertElement: function() {
    this.bindScrolling();
    var eyeline = new Discourse.Eyeline('.topic-list-item');

    var listTopicsView = this;
    eyeline.on('sawBottom', function() {
      listTopicsView.loadMore();
    });

    var scrollPos = Discourse.get('transient.topicListScrollPos');
    if (scrollPos) {
      Em.run.schedule('afterRender', function() {
        $('html, body').scrollTop(scrollPos);
      });
    } else {
      Em.run.schedule('afterRender', function() {
        $('html, body').scrollTop(0);
      });
    }
    this.set('eyeline', eyeline);
  },

  showTable: function() {
    return this.get('list.topics').length > 0 || Discourse.get('currentUser.userTrackingState.hasIncoming');
  }.property('list.topics','Discourse.currentUser.userTrackingState.hasIncoming'),

  loadMore: function() {
    var listTopicsView = this;
    listTopicsView.get('controller').loadMore().then(function (hasMoreResults) {
      Em.run.schedule('afterRender', function() {
        listTopicsView.saveScrollPos();
      });
      if (!hasMoreResults) {
        listTopicsView.get('eyeline').flushRest();
      }
    })
  },

  // Remember where we were scrolled to
  saveScrollPos: function() {
    return Discourse.set('transient.topicListScrollPos', $(window).scrollTop());
  },

  // When the topic list is scrolled
  scrolled: function(e) {
    var _ref;
    this.saveScrollPos();
    return (_ref = this.get('eyeline')) ? _ref.update() : void 0;
  }


});


