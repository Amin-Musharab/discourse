export default Ember.View.extend({
  elementId: 'topic-entrance',
  classNameBindings: ['visible::hidden'],
  visible: Em.computed.notEmpty('controller.model'),

  _positionChanged: function() {
    var pos = this.get('controller.position');
    if (!pos) { return; }

    var $self = this.$();

    // Move after we render so the height is correct
    Em.run.schedule('afterRender', function() {
      var width = $self.width(),
          height = $self.height();
      pos.left = (parseInt(pos.left) - (width / 2));
      pos.top = (parseInt(pos.top) - (height / 2));

      var windowWidth = $(window).width();
      if (pos.left + width > windowWidth) {
        pos.left = (windowWidth - width) - 5;
      }
      $self.css(pos);
    });

    var self = this;
    $('html').off('mousedown.topic-entrance').on('mousedown.topic-entrance', function(e) {
      var $target = $(e.target);
      if (($target.prop('id') === 'topic-entrance') || ($self.has($target).length !== 0)) {
        return;
      }
      self._cleanUp();
    });
  }.observes('controller.position'),

  _removed: function() {
    $('html').off('mousedown.topic-entrance');
    this.appEvents.off('dom:clean', this, '_cleanUp');
  }.on('willDestroyElement'),

  _cleanUp: function() {
    this.set('controller.model', null);
    $('html').off('mousedown.topic-entrance');
  },

  _wireClean: function() {
    this.appEvents.on('dom:clean', this, '_cleanUp');
  }.on('didInsertElement'),

});
