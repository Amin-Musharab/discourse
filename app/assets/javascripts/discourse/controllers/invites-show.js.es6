import { default as computed } from "ember-addons/ember-computed-decorators";
import getUrl from "discourse-common/lib/get-url";
import DiscourseURL from "discourse/lib/url";
import { ajax } from "discourse/lib/ajax";
import PasswordValidation from "discourse/mixins/password-validation";
import UsernameValidation from "discourse/mixins/username-validation";
import NameValidation from "discourse/mixins/name-validation";
import InviteEmailAuthValidation from "discourse/mixins/invite-email-auth-validation";
import UserFieldsValidation from "discourse/mixins/user-fields-validation";
import { findAll as findLoginMethods } from "discourse/models/login-method";

export default Ember.Controller.extend(
  PasswordValidation,
  UsernameValidation,
  NameValidation,
  InviteEmailAuthValidation,
  UserFieldsValidation,
  {
    login: Ember.inject.controller(),

    invitedBy: Ember.computed.alias("model.invited_by"),
    email: Ember.computed.alias("model.email"),
    accountUsername: Ember.computed.alias("model.username"),
    passwordRequired: Ember.computed.notEmpty("accountPassword"),
    successMessage: null,
    errorMessage: null,
    userFields: null,
    inviteImageUrl: getUrl("/images/envelope.svg"),
    hasAuthOptions: Ember.computed.notEmpty("authOptions"),

    @computed
    welcomeTitle() {
      return I18n.t("invites.welcome_to", {
        site_name: this.siteSettings.title
      });
    },

    @computed("email")
    yourEmailMessage(email) {
      return I18n.t("invites.your_email", { email: email });
    },

    authProviderDisplayName(providerName) {
      const matchingProvider = findLoginMethods().find(provider => {
        return provider.name === providerName;
      });
      return matchingProvider
        ? matchingProvider.get("prettyName")
        : providerName;
    },

    @computed
    externalAuthsEnabled() {
      return findLoginMethods().length > 0;
    },

    @computed
    inviteOnlyOauthEnabled() {
      return this.siteSettings.enable_invite_only_oauth;
    },

    @computed(
      "usernameValidation.failed",
      "passwordValidation.failed",
      "nameValidation.failed",
      "userFieldsValidation.failed",
      "inviteEmailAuthValidation.failed",
    )
    submitDisabled(
      usernameFailed,
      passwordFailed,
      nameFailed,
      userFieldsFailed,
      inviteEmailAuthFailed,
    ) {
      return usernameFailed || passwordFailed || nameFailed || userFieldsFailed || inviteEmailAuthFailed;
    },

    @computed
    fullnameRequired() {
      return (
        this.siteSettings.full_name_required || this.siteSettings.enable_names
      );
    },

    actions: {
      externalLogin(provider) {
        this.login.send("externalLogin", provider);
      },

      submit() {
        const userFields = this.userFields;
        let userCustomFields = {};
        if (!Ember.isEmpty(userFields)) {
          userFields.forEach(function(f) {
            userCustomFields[f.get("field.id")] = f.get("value");
          });
        }

        ajax({
          url: `/invites/show/${this.get("model.token")}.json`,
          type: "PUT",
          data: {
            username: this.accountUsername,
            name: this.accountName,
            password: this.accountPassword,
            user_custom_fields: userCustomFields
          }
        })
          .then(result => {
            if (result.success) {
              this.set(
                "successMessage",
                result.message || I18n.t("invites.success")
              );
              if (result.redirect_to) {
                DiscourseURL.redirectTo(result.redirect_to);
              }
            } else {
              if (
                result.errors &&
                result.errors.password &&
                result.errors.password.length > 0
              ) {
                this.rejectedPasswords.pushObject(this.accountPassword);
                this.rejectedPasswordsMessages.set(
                  this.accountPassword,
                  result.errors.password[0]
                );
              }
              if (result.message) {
                this.set("errorMessage", result.message);
              }
            }
          })
          .catch(error => {
            throw new Error(error);
          });
      }
    }
  }
);
