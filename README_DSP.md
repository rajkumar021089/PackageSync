# NBKPackageSync DSP dashboard

Read-only browser dashboard for **webMethods Integration Server 10.15**, comparing loaded namespace asset checksums between MAINLINE and one specific MIRROR Integration Server node.

## Files
- `NBKPackageSync/pub/comparePackages.dsp`: DSP HTML dashboard (search/filter, status cards, package and asset differences, CSV export, print).
- `NBKPackageSync/pub/.access`: sample access control entry. **Merge into an existing pub/.access**; do not overwrite an existing ACL file.
- `designer/COMPARE_FOR_DSP_IMPORTS.txt`: imports for new Java service.
- `designer/COMPARE_FOR_DSP_METHOD_BODY.txt`: **method body only** for new Java service.

## Install
1. Verify existing service `nbkPackageSync.services:comparePackages` is working in package `NBKPackageSync` on MAINLINE. On MIRROR, install the read-only `nbkPackageSync.services:listPackages` helper for automatic package inventory.
2. In Designer create a new **Java service** `nbkPackageSync.services:compareForDsp`.
3. Define five **String** inputs: `remoteAlias`, `includePrefix`, `packagesText`, `excludePackagesText`, `onlyDifferences`. Define outputs matching `comparePackages` plus `runAt` String. In particular, `packagesReport` and `assetsReport` are Document Lists with nested fields matching `comparePackages`.
4. Paste imports from the imports file into Designer's **Imports** area; paste the method body file contents into **Method Body**, not the generated full Java source. Save and compile.
5. Copy `comparePackages.dsp` to `[IS-instance]/packages/NBKPackageSync/pub/comparePackages.dsp`. Merge the access entry into the package's `pub/.access` if one exists; restrict HTTP access to an approved operations ACL and require HTTPS.
6. Apply **Execute ACLs** to `compareForDsp` and `comparePackages`. Restrict remote aliases to specific mirror hosts (never load balancers), and disable retry servers. Keep CSRF Guard enabled and HTML output filtering in place.
7. Reload the package to refresh access rules; open `https://<IS-HOST>:<HTTPS-PORT>/NBKPackageSync/comparePackages.dsp`.
8. First test with an explicit known package and correct mirror alias, then use prefix `NBK` for automatic comparison. If automatic discovery fails, verify remote helper deployment.

## Limitations and safety
This is a **read-only** dashboard, not package synchronization. It compares **loaded namespace assets and checksums only**, and requires the same IS version on both servers. It does **not** verify full package content, resource files, JARs, configurations, adapters, ACLs, certificates, or JVM settings. Treat ERROR/unverified as unknown, never MATCH. Explicit package inputs cannot reliably distinguish a missing package from a failed or unloaded package. The page and Java service have not been tested against a live IS 10.15 instance; review, test and apply corporate security policies before deployment.

Do not publish a running dashboard on an Internet-facing Integration Server.
