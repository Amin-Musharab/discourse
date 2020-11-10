import Component from "@ember/component";
import { propertyEqual } from "discourse/lib/computed";
import { computed } from "@ember/object";
import { actionDescription } from "discourse/widgets/post-small-action";

export default Component.extend({
  classNameBindings: [
    ":user-stream-item",
    ":item", // DEPRECATED: 'item' class
    "hidden",
    "item.deleted:deleted",
    "moderatorAction",
  ],

  hidden: computed("item.hidden", function () {
    return (
      this.get("item.hidden") && !(this.currentUser && this.currentUser.staff)
    );
  }),
  moderatorAction: propertyEqual(
    "item.post_type",
    "site.post_types.moderator_action"
  ),
  actionDescription: actionDescription(
    "item.action_code",
    "item.created_at",
    "item.action_code_who"
  ),
});
