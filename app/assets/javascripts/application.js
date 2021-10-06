//= require_tree ./truth-helpers/addon
//= require_tree ./discourse-common/addon
//= require ./polyfills
//= require_tree ./select-kit/addon
//= require ./discourse/app/app
//= require ./app-boot

// Stuff we need to load first
//= require ./discourse/app/lib/to-markdown
//= require ./discourse/app/lib/utilities
//= require ./discourse/app/lib/user-presence
//= require ./discourse/app/lib/logout
//= require ./discourse/app/mixins/singleton
//= require ./discourse/app/models/rest
//= require ./discourse/app/models/session
//= require ./discourse/app/lib/ajax
//= require ./discourse/app/lib/text
//= require ./discourse/app/lib/hash
//= require ./discourse/app/lib/load-script
//= require ./discourse/app/lib/notification-levels
//= require ./discourse/app/services/app-events
//= require ./discourse/app/lib/offset-calculator
//= require ./discourse/app/lib/lock-on
//= require ./discourse/app/lib/url
//= require ./discourse/app/lib/email-provider-default-settings
//= require ./discourse/app/lib/debounce
//= require ./discourse/app/lib/quote
//= require ./discourse/app/lib/key-value-store
//= require ./discourse/app/lib/computed
//= require ./discourse/app/lib/formatter
//= require ./discourse/app/lib/text-direction
//= require ./discourse/app/lib/eyeline
//= require ./discourse/app/lib/show-modal
//= require ./discourse/app/lib/download-calendar
//= require ./discourse/app/mixins/scrolling
//= require ./discourse/app/lib/ajax-error
//= require ./discourse/app/models/result-set
//= require ./discourse/app/models/store
//= require ./discourse/app/models/action-summary
//= require ./discourse/app/models/permission-type
//= require ./discourse/app/models/category
//= require ./discourse/app/models/topic
//= require ./discourse/app/models/draft
//= require ./discourse/app/models/composer
//= require ./discourse/app/models/badge-grouping
//= require ./discourse/app/models/badge
//= require ./discourse/app/models/permission-type
//= require ./discourse/app/models/user-action-group
//= require ./discourse/app/models/trust-level
//= require ./discourse/app/lib/search
//= require ./discourse/app/lib/user-search
//= require ./discourse/app/lib/export-csv
//= require ./discourse/app/lib/autocomplete
//= require ./discourse/app/lib/after-transition
//= require ./discourse/app/lib/safari-hacks
//= require ./discourse/app/lib/put-cursor-at-end
//= require_tree ./discourse/app/adapters
//= require ./discourse/app/models/post-action-type
//= require ./discourse/app/models/post
//= require ./discourse/app/lib/posts-with-placeholders
//= require ./discourse/app/models/post-stream
//= require ./discourse/app/models/topic-details
//= require ./discourse/app/models/topic
//= require ./discourse/app/models/user-action
//= require ./discourse/app/models/draft
//= require ./discourse/app/models/composer
//= require ./discourse/app/models/user-badge
//= require_tree ./discourse/app/lib
//= require_tree ./discourse/app/mixins
//= require ./discourse/app/models/invite
//= require ./discourse/app/controllers/discovery-sortable
//= require ./discourse/app/controllers/navigation/default
//= require ./discourse/app/components/edit-category-panel
//= require ./discourse/app/lib/link-mentions
//= require ./discourse/app/components/site-header
//= require ./discourse/app/components/d-editor
//= require ./discourse/app/lib/screen-track
//= require ./discourse/app/routes/discourse
//= require ./discourse/app/routes/build-topic-route
//= require ./discourse/app/routes/restricted-user
//= require ./discourse/app/routes/user-topic-list
//= require ./discourse/app/routes/user-activity-stream
//= require ./discourse/app/routes/topic-from-params
//= require ./discourse/app/components/text-field
//= require ./discourse/app/components/conditional-loading-spinner
//= require ./discourse/app/helpers/user-avatar
//= require ./discourse/app/helpers/cold-age-class
//= require ./discourse/app/helpers/loading-spinner
//= require ./discourse/app/helpers/category-link
//= require ./discourse/app/lib/export-result
//= require ./discourse/app/mapping-router

//= require_tree ./discourse/app/controllers
//= require_tree ./discourse/app/models
//= require_tree ./discourse/app/components
//= require_tree ./discourse/app/raw-views
//= require_tree ./discourse/app/helpers
//= require_tree ./discourse/app/templates
//= require_tree ./discourse/app/routes
//= require_tree ./discourse/app/pre-initializers
//= require_tree ./discourse/app/initializers
//= require_tree ./discourse/app/services

//= require_tree ./discourse/app/widgets
//= require ./widget-runtime
