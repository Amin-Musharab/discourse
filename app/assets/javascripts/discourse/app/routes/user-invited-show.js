import DiscourseRoute from "discourse/routes/discourse";
import Invite from "discourse/models/invite";
import { action } from "@ember/object";
import I18n from "I18n";

export default DiscourseRoute.extend({
  model(params) {
    this.inviteFilter = params.filter;
    return Invite.findInvitedBy(this.modelFor("user"), params.filter);
  },

  afterModel(model) {
    if (!model.can_see_invite_details) {
      this.replaceWith("userInvited.show", "redeemed");
    }
    this.controllerFor("user.invited").setProperties({
      invitesCount: model.counts,
    });
  },

  setupController(controller, model) {
    controller.setProperties({
      model,
      invitesCount: model.counts,
      user: this.controllerFor("user").get("model"),
      filter: this.inviteFilter,
      searchTerm: "",
    });
  },

  titleToken() {
    return I18n.t("user.invited." + this.inviteFilter + "_tab");
  },

  @action
  triggerRefresh() {
    this.refresh();
  },
});
