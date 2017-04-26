import CanCheckEmails from 'discourse/mixins/can-check-emails';
import { default as computed } from "ember-addons/ember-computed-decorators";
import PreferencesTabController from "discourse/mixins/preferences-tab-controller";

export default Ember.Controller.extend(CanCheckEmails, PreferencesTabController, {

  passwordProgress: null,

  cannotDeleteAccount: Em.computed.not('currentUser.can_delete_account'),
  deleteDisabled: Em.computed.or('model.isSaving', 'deleting', 'cannotDeleteAccount'),

  reset() {
    this.setProperties({
      passwordProgress: null
    });
  },

  @computed()
  canChangePassword() {
    return !this.siteSettings.enable_sso && this.siteSettings.enable_local_logins;
  },

  actions: {
    changePassword() {
      if (!this.get('passwordProgress')) {
        this.set('passwordProgress', I18n.t("user.change_password.in_progress"));
        return this.get('model').changePassword().then(() => {
          // password changed
          this.setProperties({
            changePasswordProgress: false,
            passwordProgress: I18n.t("user.change_password.success")
          });
        }).catch(() => {
          // password failed to change
          this.setProperties({
            changePasswordProgress: false,
            passwordProgress: I18n.t("user.change_password.error")
          });
        });
      }
    },

    delete() {
      this.set('deleting', true);
      const self = this,
        message = I18n.t('user.delete_account_confirm'),
        model = this.get('model'),
        buttons = [
          { label: I18n.t("cancel"),
            class: "cancel-inline",
            link:  true,
            callback: () => { this.set('deleting', false); }
          },
          { label: '<i class="fa fa-exclamation-triangle"></i> ' + I18n.t("user.delete_account"),
            class: "btn btn-danger",
            callback() {
              model.delete().then(function() {
                bootbox.alert(I18n.t('user.deleted_yourself'), function() {
                  window.location.pathname = Discourse.getURL('/');
                });
              }, function() {
                bootbox.alert(I18n.t('user.delete_yourself_not_allowed'));
                self.set('deleting', false);
              });
            }
          }
        ];
      bootbox.dialog(message, buttons, {"classes": "delete-account"});
    }
  }
});
