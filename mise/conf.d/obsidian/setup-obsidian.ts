// Upstream's utils/setup/generate_setup_uri.ts forces E2EE; this only encrypts
// when LIVESYNC_E2EE_PASSPHRASE is set. Prints the URI passphrase, then the URI.
import {
  createNewVaultSettings,
  encodeSettingsToSetupURI,
  PREFERRED_SETTING_SELF_HOSTED,
  upsertRemoteConfigurationInPlace,
} from "https://raw.githubusercontent.com/vrtmrz/obsidian-livesync/main/utils/setup/livesync-commonlib.ts";

function env(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

const e2eePassphrase = Deno.env.get("LIVESYNC_E2EE_PASSPHRASE")?.trim() ?? "";
const settings = createNewVaultSettings();
Object.assign(settings, PREFERRED_SETTING_SELF_HOSTED, {
  couchDB_URI: env("LIVESYNC_COUCHDB_URI"),
  couchDB_USER: env("LIVESYNC_COUCHDB_USER"),
  couchDB_PASSWORD: env("LIVESYNC_COUCHDB_PASSWORD"),
  couchDB_DBNAME: env("LIVESYNC_COUCHDB_DB"),
  batchSave: true,
  periodicReplication: true,
  syncOnStart: true,
  syncOnFileOpen: true,
  syncAfterMerge: true,
  isConfigured: true,
  encrypt: e2eePassphrase !== "",
  passphrase: e2eePassphrase,
  usePathObfuscation: e2eePassphrase !== "",
  // Hidden-file sync over customization sync: no per-device name to set up.
  syncInternalFiles: true,
  watchInternalFileChanges: true,
  syncInternalFilesIgnorePatterns: [
    "(^|\\/)\\.git\\/",
    "\\/node_modules\\/",
    "\\/obsidian-livesync\\/",
    "\\.DS_Store$",
    "\\/workspace(-mobile)?\\.json$",
  ].join(", "),
  usePluginSync: false,
});
upsertRemoteConfigurationInPlace(settings, "couchdb", { activate: true });

const bytes = crypto.getRandomValues(new Uint8Array(24));
const uriPassphrase = btoa(String.fromCharCode(...bytes))
  .replaceAll("+", "-").replaceAll("/", "_").replace(/=+$/, "");
const uri = await encodeSettingsToSetupURI(settings, uriPassphrase, [
  "pluginSyncExtendedSetting",
  "doNotUseFixedRevisionForChunks",
], true);
console.log(uriPassphrase);
console.log(uri.trim());
