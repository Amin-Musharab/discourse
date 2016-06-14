import { withPluginApi } from 'discourse/lib/plugin-api';

function initializeDetails(api) {
  api.decorateCooked($elem => $("details", $elem).details());

  api.addToolbarPopupMenuOptionsCallback(() => {
    return {
      action: 'insertDetails',
      icon: 'caret-right',
      label: 'details.title'
    };
  });

  const ComposerController = api.container.lookup("controller:composer");
  ComposerController.reopen({
    actions: {
      insertDetails() {
        this.get("toolbarEvent").applySurround(
          `[details=${I18n.t("composer.details_title")}]`,
          "[/details]",
          "details_text")
        ;
      }
    }
  });
}

export default {
  name: "apply-details",
  after: 'inject-objects',

  initialize() {
    withPluginApi('0.5', initializeDetails);
  }
};
