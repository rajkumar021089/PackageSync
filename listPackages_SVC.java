package nbkPackageSync.services;

import com.wm.data.*;
import com.wm.app.b2b.server.ServiceException;
import com.wm.app.b2b.server.ServerAPI;
import java.util.TreeSet;

/** Inventory helper for the remote Integration Server. */
public final class listPackages_SVC {
    public static final void listPackages(IData pipeline) throws ServiceException {
        // [o] field:1:required packageNames
        // [o] field:0:required count
        // [o] field:0:required source
        String[] names = ServerAPI.getPackages();
        if (names == null) throw new ServiceException("ServerAPI.getPackages returned null");
        TreeSet<String> sorted = new TreeSet<String>();
        for (String name : names) if (name != null && !name.trim().isEmpty()) sorted.add(name.trim());
        IDataCursor c = pipeline.getCursor();
        IDataUtil.put(c, "packageNames", sorted.toArray(new String[sorted.size()]));
        IDataUtil.put(c, "count", Integer.toString(sorted.size()));
        IDataUtil.put(c, "source", "ServerAPI.getPackages");
        c.destroy();
    }
}