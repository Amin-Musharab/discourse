import { UploadPreProcessorPlugin } from "discourse/lib/uppy-plugin-base";
import { Promise } from "rsvp";

export default class UppyChecksum extends UploadPreProcessorPlugin {
  static pluginId = "uppy-checksum";

  constructor(uppy, opts) {
    super(uppy, opts);
    this.capabilities = opts.capabilities;
  }

  _canUseSubtleCrypto() {
    if (!this._secureContext()) {
      this._consoleWarn(
        "Cannot generate cryptographic digests in an insecure context (not HTTPS)."
      );
      return false;
    }
    if (this.capabilities.isIE11) {
      this._consoleWarn(
        "The required cipher suite is unavailable in Internet Explorer 11."
      );
      return false;
    }
    if (!this._hasCryptoCipher()) {
      this._consoleWarn(
        "The required cipher suite is unavailable in this browser."
      );
      return false;
    }

    return true;
  }

  _generateChecksum(fileIds) {
    if (!this._canUseSubtleCrypto()) {
      return Promise.resolve();
    }

    let promises = fileIds.map((fileId) => {
      let file = this._getFile(fileId);

      this._emitProgress(file);

      return file.data.arrayBuffer().then((arrayBuffer) => {
        return window.crypto.subtle
          .digest("SHA-1", arrayBuffer)
          .then((hash) => {
            const hashArray = Array.from(new Uint8Array(hash));
            const hashHex = hashArray
              .map((b) => b.toString(16).padStart(2, "0"))
              .join("");
            this._setFileMeta(fileId, { sha1_checksum: hashHex });
            this._emitComplete(file);
          })
          .catch((err) => {
            if (
              err.message.toString().includes("Algorithm: Unrecognized name")
            ) {
              this._consoleWarn(
                "SHA-1 algorithm is unsupported in this browser."
              );
            } else {
              this._consoleWarn(
                `Error encountered when generating digest: ${err.message}`
              );
            }
            this._emitComplete(file);
          });
      });
    });

    return Promise.all(promises);
  }

  _secureContext() {
    return window.isSecureContext;
  }

  _hasCryptoCipher() {
    return window.crypto && window.crypto.subtle && window.crypto.subtle.digest;
  }

  install() {
    this._install(this._generateChecksum.bind(this));
  }

  uninstall() {
    this._uninstall(this._generateChecksum.bind(this));
  }
}
