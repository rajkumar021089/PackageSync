package nbkPackageSync.services;

import com.wm.data.*;
import com.wm.app.b2b.server.Service;
import com.wm.app.b2b.server.ServiceException;
import com.wm.app.b2b.server.ServerAPI;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

/** Read-only package namespace checksum comparison. */
public final class comparePackages_SVC {
    public static final void comparePackages(IData pipeline) throws ServiceException {
        // [i] field:0:required remoteAlias
        // [i] field:1:optional packages
        // [i] field:0:optional includePrefix
        // [i] field:1:optional excludePackages
        // [i] field:0:optional inventoryMode
        // [i] field:0:optional onlyDifferences
        // [o] record:1:optional packagesReport
        // [o] - field:0:optional package
        // [o] - field:0:optional status
        // [o] - field:0:optional mainlineAssets
        // [o] - field:0:optional mirrorAssets
        // [o] - field:0:optional differentAssets
        // [o] - field:0:optional error
        // [o] record:1:optional assetsReport
        // [o] - field:0:optional package
        // [o] - field:0:optional assetName
        // [o] - field:0:optional status
        // [o] - field:0:optional mainlineChecksum
        // [o] - field:0:optional mirrorChecksum
        // [o] field:1:required outOfSyncPackages
        // [o] field:1:required unverifiedPackages
        // [o] field:0:required comparedPackages
        // [o] field:0:required matchingPackages
        // [o] field:0:required differentPackages
        // [o] field:0:required missingMainlinePackages
        // [o] field:0:required missingMirrorPackages
        // [o] field:0:required errorPackages
        // [o] field:0:required complete
        // [o] field:0:required hasDifferences
        // [o] field:0:required comparisonLevel
        // [o] field:0:required inventorySource
        IDataCursor ic = pipeline.getCursor();
        String alias = clean(IDataUtil.getString(ic, "remoteAlias"));
        String[] selection = IDataUtil.getStringArray(ic, "packages");
        String prefix = clean(IDataUtil.getString(ic, "includePrefix"));
        String[] excluded = IDataUtil.getStringArray(ic, "excludePackages");
        String mode = clean(IDataUtil.getString(ic, "inventoryMode"));
        boolean onlyDifferences = yes(IDataUtil.getString(ic, "onlyDifferences"));
        ic.destroy();

        if (alias.isEmpty()) throw new ServiceException("remoteAlias is mandatory. Configure a remote-server alias pointing to the specific production MIRROR, never the LB.");
        if (mode.isEmpty()) mode = "helper";
        if (!"helper".equalsIgnoreCase(mode) && !"wmroot".equalsIgnoreCase(mode)) {
            throw new ServiceException("inventoryMode must be helper or wmroot");
        }
        TreeSet<String> excludes = new TreeSet<String>();
        if (excluded != null) for (String x : excluded) if (x != null) excludes.add(x.trim());
        excludes.add("NBKPackageSync");

        TreeSet<String> mainline = new TreeSet<String>();
        TreeSet<String> mirror = new TreeSet<String>();
        boolean discover = selection == null || selection.length == 0;
        if (discover) {
            try {
                String[] localNames = ServerAPI.getPackages();
                if (localNames == null) throw new ServiceException("Local ServerAPI.getPackages returned null");
                for (String s : localNames) if (s != null && !s.trim().isEmpty()) mainline.add(s.trim());
                IData remoteResult;
                if ("helper".equalsIgnoreCase(mode)) {
                    remoteResult = invokeRemote(alias, "nbkPackageSync.services:listPackages", IDataFactory.create());
                    if (remoteResult == null) throw new ServiceException("Remote listPackages returned null");
                    IDataCursor r = remoteResult.getCursor();
                    String[] values = IDataUtil.getStringArray(r, "packageNames");
                    r.destroy();
                    if (values == null) throw new ServiceException("Mirror listPackages did not return packageNames. Verify NBKPackageSync installed on mirror.");
                    for (String s : values) if (s != null && !s.trim().isEmpty()) mirror.add(s.trim());
                } else {
                    // Optional fallback when the mirror cannot host NBKPackageSync.
                    // wm.server.packages:packageList is WmRoot internal and not guaranteed across versions.
                    remoteResult = invokeRemote(alias, "wm.server.packages:packageList", IDataFactory.create());
                    mirror.addAll(parseWmRootInventory(remoteResult));
                }
            } catch (Exception e) {
                throw new ServiceException("Inventory failed: " + err(e) + ". Use inventoryMode=helper with package on mirror, or supply explicit 'packages' list.");
            }
            if (mainline.isEmpty() || mirror.isEmpty()) throw new ServiceException("Empty package inventory; aborting to prevent incorrect MISSING/MATCH classifications.");
        } else {
            // Explicit-selection mode does not establish package existence.
            // Absent/disabled packages result in ERROR, never guessed MISSING.
            for (String s : selection) if (s != null && !s.trim().isEmpty()) {
                mainline.add(s.trim()); mirror.add(s.trim());
            }
            if (mainline.isEmpty()) throw new ServiceException("Explicit packages list contains no valid package names");
        }

        TreeSet<String> all = new TreeSet<String>(mainline);
        all.addAll(mirror);
        List<IData> packageRows = new ArrayList<IData>();
        List<IData> assetRows = new ArrayList<IData>();
        List<String> outOfSync = new ArrayList<String>();
        List<String> unverified = new ArrayList<String>();
        int examined = 0, matchCount = 0, diffCount = 0, missingLocal = 0, missingRemote = 0, errorCount = 0;
        for (String pkg : all) {
            if (excludes.contains(pkg) || pkg.isEmpty() || pkg.startsWith("Wm")) continue;
            if (!prefix.isEmpty() && !pkg.startsWith(prefix)) continue;
            examined++;
            String status = "MATCH", error = "";
            int countLocal = 0, countRemote = 0, diffAssets = 0;
            if (!mainline.contains(pkg)) {
                status = "MISSING_MAINLINE"; missingLocal++;
            } else if (!mirror.contains(pkg)) {
                status = "MISSING_MIRROR"; missingRemote++;
            } else {
                try {
                    Map<String, String> left = checksums(false, alias, pkg);
                    Map<String, String> right = checksums(true, alias, pkg);
                    countLocal = left.size(); countRemote = right.size();
                    if (left.isEmpty() || right.isEmpty()) {
                        throw new ServiceException("One or both inventories contain zero loaded namespace assets; not safe to classify as MATCH");
                    }
                    List<IData> thisPackageAssets = new ArrayList<IData>();
                    TreeSet<String> assetNames = new TreeSet<String>(left.keySet());
                    assetNames.addAll(right.keySet());
                    for (String asset : assetNames) {
                        String a = left.get(asset), b = right.get(asset);
                        String assetStatus;
                        if (!left.containsKey(asset)) assetStatus = "MISSING_MAINLINE";
                        else if (!right.containsKey(asset)) assetStatus = "MISSING_MIRROR";
                        else if (a == null || a.isEmpty() || b == null || b.isEmpty()) assetStatus = "UNVERIFIED_CHECKSUM";
                        else if (!a.equals(b)) assetStatus = "DIFFERENT";
                        else continue;
                        diffAssets++;
                        thisPackageAssets.add(doc("package", pkg, "assetName", asset,
                            "status", assetStatus, "mainlineChecksum", str(a), "mirrorChecksum", str(b)));
                        if ("UNVERIFIED_CHECKSUM".equals(assetStatus)) status = "ERROR";
                        else if (!"ERROR".equals(status)) status = "DIFFERENT";
                    }
                    assetRows.addAll(thisPackageAssets);
                } catch (Exception e) {
                    status = "ERROR"; error = err(e);
                }
                if ("MATCH".equals(status)) matchCount++;
                else if ("DIFFERENT".equals(status)) diffCount++;
                else errorCount++;
            }
            if ("ERROR".equals(status)) unverified.add(pkg);
            else if (!"MATCH".equals(status)) outOfSync.add(pkg);
            if (!onlyDifferences || !"MATCH".equals(status)) {
                packageRows.add(doc("package", pkg, "status", status,
                    "mainlineAssets", Integer.toString(countLocal),
                    "mirrorAssets", Integer.toString(countRemote),
                    "differentAssets", Integer.toString(diffAssets), "error", error));
            }
        }
        if (examined == 0) throw new ServiceException("No packages matched selection/includePrefix/excludePackages filters");
        IDataCursor oc = pipeline.getCursor();
        IDataUtil.put(oc, "packagesReport", packageRows.toArray(new IData[packageRows.size()]));
        IDataUtil.put(oc, "assetsReport", assetRows.toArray(new IData[assetRows.size()]));
        IDataUtil.put(oc, "outOfSyncPackages", outOfSync.toArray(new String[outOfSync.size()]));
        IDataUtil.put(oc, "unverifiedPackages", unverified.toArray(new String[unverified.size()]));
        IDataUtil.put(oc, "comparedPackages", Integer.toString(examined));
        IDataUtil.put(oc, "matchingPackages", Integer.toString(matchCount));
        IDataUtil.put(oc, "differentPackages", Integer.toString(diffCount));
        IDataUtil.put(oc, "missingMainlinePackages", Integer.toString(missingLocal));
        IDataUtil.put(oc, "missingMirrorPackages", Integer.toString(missingRemote));
        IDataUtil.put(oc, "errorPackages", Integer.toString(errorCount));
        IDataUtil.put(oc, "complete", errorCount == 0 ? "true" : "false");
        IDataUtil.put(oc, "hasDifferences", diffCount + missingLocal + missingRemote > 0 ? "true" : "false");
        IDataUtil.put(oc, "comparisonLevel", "Loaded namespace asset checksums only (same IS version). Does not compare package files/JARs/config/certificates or validate package fully loaded.");
        IDataUtil.put(oc, "inventorySource", discover ? ("helper".equalsIgnoreCase(mode) ? "ServerAPI.getPackages (both servers)" : "ServerAPI local / WmRoot mirror") : "Explicit package selection; missing-package status unverified");
        oc.destroy();
    }

    private static String clean(String s) { return s == null ? "" : s.trim(); }
    private static String str(String s) { return s == null ? "" : s; }
    private static boolean yes(String s) { return "true".equalsIgnoreCase(clean(s)) || "1".equals(clean(s)); }
    private static String err(Throwable t) {
        String m = t.getMessage();
        return t.getClass().getSimpleName() + (m == null ? "" : ": " + m);
    }
    private static IData doc(String... kv) {
        IData o = IDataFactory.create(); IDataCursor c = o.getCursor();
        for (int i = 0; i < kv.length; i += 2) IDataUtil.put(c, kv[i], kv[i + 1]);
        c.destroy(); return o;
    }
    private static IData invokeRemote(String alias, String service, IData args) throws Exception {
        IDataCursor c = args.getCursor();
        IDataUtil.put(c, "$alias", alias);
        IDataUtil.put(c, "$service", service);
        IDataUtil.put(c, "$scope", "SESSION");
        IDataUtil.put(c, "$clusterRetry", "false");
        // The alias MUST point to an exact mirror host and have no retry server.
        c.destroy();
        return Service.doInvoke("pub.remote", "invoke", args);
    }
    private static Map<String, String> checksums(boolean remote, String alias, String pkg) throws Exception {
        IData req = IDataFactory.create();
        IDataCursor input = req.getCursor();
        IDataUtil.put(input, "packages", new String[]{pkg});
        input.destroy();
        IData result = remote ? invokeRemote(alias, "pub.assets:getChecksums", req)
                              : Service.doInvoke("pub.assets", "getChecksums", req);
        if (result == null) throw new ServiceException("No checksum pipeline for " + pkg);
        IDataCursor cursor = result.getCursor();
        IData[] rows = IDataUtil.getIDataArray(cursor, "checksums");
        cursor.destroy();
        if (rows == null) throw new ServiceException("Missing 'checksums' Document List for " + pkg);
        TreeMap<String, String> out = new TreeMap<String, String>();
        for (IData row : rows) {
            if (row == null) throw new ServiceException("Null checksum row in " + pkg);
            IDataCursor c = row.getCursor();
            String name = clean(IDataUtil.getString(c, "name"));
            String fromPkg = clean(IDataUtil.getString(c, "package"));
            String checksum = clean(IDataUtil.getString(c, "checksum"));
            c.destroy();
            if (name.isEmpty()) throw new ServiceException("Checksum record missing asset name: " + pkg);
            if (!pkg.equals(fromPkg) || checksum.isEmpty()) {
                throw new ServiceException("Checksum/package unavailable for " + name + "; check package load and List ACL on both servers");
            }
            if (out.containsKey(name)) throw new ServiceException("Duplicate checksum asset: " + name);
            out.put(name, checksum);
        }
        return out;
    }
    private static Set<String> parseWmRootInventory(IData result) throws Exception {
        if (result == null) throw new ServiceException("wm.server.packages:packageList returned no pipeline");
        IDataCursor c = result.getCursor();
        Object packages = IDataUtil.get(c, "packages");
        c.destroy();
        TreeSet<String> out = new TreeSet<String>();
        if (packages instanceof String[]) {
            for (String s : (String[])packages) if (s != null && !s.trim().isEmpty()) out.add(s.trim());
        } else if (packages instanceof IData[]) {
            for (IData row : (IData[])packages) {
                if (row == null) continue;
                IDataCursor p = row.getCursor();
                String name = clean(IDataUtil.getString(p, "name"));
                if (name.isEmpty()) name = clean(IDataUtil.getString(p, "packageName"));
                p.destroy();
                if (!name.isEmpty()) out.add(name);
            }
        } else {
            throw new ServiceException("Unrecognized WmRoot packageList response. Install helper on mirror.");
        }
        return out;
    }
}