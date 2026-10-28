NBKPackageSync: Java service source for Integration Server 10.15
================================================================

IMPORTANT
- Source files are Java source, not a deployable Integration Server package ZIP.
- In Designer Java service SOURCE editor, insert the METHOD BODY text only.
  Don't replace Designer's package/class declarations or overwrite the generated
  .java file manually on a production server.
- Put contents of designer/IMPORTS.txt into the imports area.
- Put designer/COMPARE_PACKAGES_SHARED_CODE.txt into comparePackages Shared Code.
- The _SVC.java files are full source references corresponding to the screenshots
  package nbkPackageSync.services and Java services comparePackages/listPackages.

SERVICES TO CREATE IN PACKAGE NBKPackageSync
  nbkPackageSync.services:comparePackages (Java)
  nbkPackageSync.services:listPackages    (Java; install also on REMOTE/MIRROR)

comparePackages inputs:
 remoteAlias       String required  | non-load-balancer mirror server alias
 packages          String List opt  | if set, avoids remote inventory helper
 includePrefix     String optional  | e.g. NBK
 excludePackages   String List opt
 inventoryMode     String optional  | helper (default), wmroot (undocumented fallback)
 onlyDifferences   String optional  | true or false

outputs:
 packagesReport      Document List [package,status,mainlineAssets,mirrorAssets,differentAssets,error]
 assetsReport        Document List [package,assetName,status,mainlineChecksum,mirrorChecksum]
 outOfSyncPackages   String List
 unverifiedPackages  String List
 comparedPackages/matchingPackages/differentPackages/missingMainlinePackages/
 missingMirrorPackages/errorPackages/complete/hasDifferences/comparisonLevel/inventorySource
 all String

TEST
1. Save/compile listPackages in MAINLINE Designer; invoke locally.
2. Save/compile comparePackages in MAINLINE Designer.
3. Deploy ONLY the same read-only listPackages helper on the MIRROR (optional for explicit packages).
4. Test direct local pub.assets:getChecksums with packages=[a valid package].
5. Test remote pub.remote:invoke: $alias=YOUR_MIRROR_ALIAS,
   $service=pub.assets:getChecksums, packages=[same package].
6. Test comparePackages input remoteAlias=YOUR_MIRROR_ALIAS,
   packages=[same package], inventoryMode=helper, onlyDifferences=false.
7. Once verified, remove packages input and set includePrefix=NBK to discover all NBK packages.

Same IS VERSION only. Comparison covers loaded namespace assets and their checksums,
not package resource files, JARs, manifest, configs, ACLs, certificates, or
adapter connection state. A partially loaded package may be incomplete in the
checksum result. ERROR/unverifiedPackages are never reported as MATCH.

Make remote alias point to an exact mirror node, not a load balancer or retry
server. Restrict execute ACL for the services and alias. No code writes are made.