// Just add query params here to have them automatically passed to topic list filters.
export const queryParams = {
  order: { replace: true, refreshModel: true },
  ascending: { replace: true, refreshModel: true },
  status: { replace: true, refreshModel: true },
  state: { replace: true, refreshModel: true },
  search: { replace: true, refreshModel: true },
  max_posts: { replace: true, refreshModel: true },
  q: { replace: true, refreshModel: true },
  tags: { replace: true, refreshModel: true }
};

// Basic controller options
const controllerOpts = {
  discoveryTopics: Ember.inject.controller('discovery/topics'),
  queryParams: Object.keys(queryParams),
};

// Aliases for the values
controllerOpts.queryParams.forEach(p => controllerOpts[p] = Ember.computed.alias(`discoveryTopics.${p}`));

export default Ember.Controller.extend(controllerOpts);
