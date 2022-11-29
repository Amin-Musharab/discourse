import DiscourseTemplateMap from "discourse-common/lib/discourse-template-map";
import { expireConnectorCache } from "discourse/lib/plugin-connectors";

const modifications = [];

function generateTemplateModule(template) {
  return function (_exports) {
    Object.defineProperty(_exports, "__esModule", {
      value: true,
    });
    _exports.default = template;
  };
}

export function registerTemplateModule(moduleName, template) {
  const modificationData = {
    moduleName,
    existingModule: requirejs.entries[moduleName],
  };
  delete requirejs.entries[moduleName];
  define(moduleName, ["exports"], generateTemplateModule(template));
  modifications.push(modificationData);
  expireConnectorCache();
  DiscourseTemplateMap.setModuleNames(Object.keys(requirejs.entries));
}

export function cleanupTemporaryTemplateRegistrations() {
  for (const modificationData of modifications.reverse()) {
    const { moduleName, existingModule } = modificationData;
    delete requirejs.entries[moduleName];
    if (existingModule) {
      requirejs.entries[moduleName] = existingModule;
    }
  }
  if (modifications.length) {
    expireConnectorCache();
    DiscourseTemplateMap.setModuleNames(Object.keys(requirejs.entries));
  }
  modifications.clear();
}
