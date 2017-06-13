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

  api.modifyClass('controller:composer', {
    actions: {
      insertDetails() {
        this.get("toolbarEvent").applySurround(
          `[details=${I18n.t("composer.details_title")}]`,
          "[/details]",
          "details_text",
          { multiline: false }
        );
        this.set('optionsVisible', false);
      }
    }
  });
}

export default {
  name: "apply-details",

  initialize() {
    withPluginApi('0.8.7', initializeDetails);
  }
};
