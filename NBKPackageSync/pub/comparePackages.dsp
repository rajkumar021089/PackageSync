<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>NBK PackageSync | Read-only comparison</title>
  <style>
    :root {color-scheme:light; --ink:#16253e; --muted:#64748b; --bg:#f5f7fb; --paper:#fff; --edge:#e2e8f0; --blue:#2153ba; --good:#087f5b; --bad:#bc3232; --warn:#9b6207; --shadow:0 10px 32px rgba(26,46,80,.05)}
    * {box-sizing:border-box}
    body {margin:0;background:var(--bg);font:14px/1.5 system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;color:var(--ink)}
    .wrap {max-width:1440px;margin:0 auto;padding:32px 24px 72px}
    .top {display:flex;gap:18px;justify-content:space-between;align-items:center;margin-bottom:24px}
    h1 {font-size:29px;line-height:1.2;margin:3px 0 6px;letter-spacing:-.6px}
    h2 {font-size:19px;margin:0 0 12px}
    .eyebrow {font-size:11px;letter-spacing:1.2px;text-transform:uppercase;color:var(--blue);font-weight:800}
    .muted,.note {color:var(--muted)}
    .note {font-size:12px}
    .chip {border:1px solid #d6e3ff;background:#edf3ff;color:#244f9c;font-size:12px;border-radius:100px;padding:7px 12px;font-weight:700;white-space:nowrap}
    .panel {background:var(--paper);border:1px solid var(--edge);box-shadow:var(--shadow);border-radius:15px;padding:22px;margin-bottom:20px}
    .grid-form {display:grid;grid-template-columns:1.5fr 1fr 1fr;gap:16px}
    label {font-weight:650;font-size:12px;display:block;margin-bottom:6px}
    input,select,textarea {display:block;width:100%;border-radius:9px;border:1px solid #cfd8e6;background:#fff;color:var(--ink);font:inherit;padding:10px 12px;outline-color:var(--blue)}
    textarea {min-height:64px;resize:vertical}
    .field-wide {grid-column:span 2}
    .actions {display:flex;align-items:center;gap:15px;flex-wrap:wrap;margin-top:18px}
    button {border:none;background:var(--blue);color:#fff;font:inherit;font-weight:750;border-radius:9px;padding:10px 17px;cursor:pointer}
    button:hover {background:#153b91}
    button.secondary {background:#eef2f8;color:var(--ink);border:1px solid #d8e1ee}
    .cards {display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:12px;margin-bottom:18px}
    .metric {background:#fff;border:1px solid var(--edge);border-radius:14px;padding:17px 18px;min-width:0}
    .metric .label {text-transform:uppercase;letter-spacing:.5px;font-size:10px;font-weight:800;color:var(--muted)}
    .metric .number {font-size:27px;line-height:1.2;letter-spacing:-.6px;font-weight:800;margin-top:5px;font-variant-numeric:tabular-nums}
    .banner {display:flex;gap:12px;align-items:start;padding:14px 17px;border-radius:11px;margin-bottom:16px;border:1px solid #d7e5ff;background:#eef4ff}
    .banner.good {background:#e8f8f1;border-color:#c6eede}
    .banner.warn {background:#fff5e5;border-color:#f8dcae}
    .banner.bad {background:#fff0f0;border-color:#f5cdcd}
    .toolbar {display:flex;align-items:center;justify-content:space-between;gap:15px;flex-wrap:wrap;margin:12px 0}
    .toolbar-left {display:flex;gap:9px;flex-wrap:wrap}
    .toolbar input {max-width:290px}
    .toolbar select {width:auto;min-width:175px}
    .scroll {overflow-x:auto;border:1px solid var(--edge);border-radius:10px}
    table {border-collapse:collapse;width:100%;min-width:720px}
    th {background:#f5f7fb;text-transform:uppercase;letter-spacing:.5px;text-align:left;font-size:10px;color:#59697f}
    td,th {padding:12px 13px;border-bottom:1px solid #e9edf3;vertical-align:top}
    tr:last-child td {border-bottom:none}
    tbody tr:hover {background:#f9fbff}
    .mono {font-family:ui-monospace,SFMono-Regular,Consolas,"Liberation Mono",monospace;font-size:12px;overflow-wrap:anywhere}
    .status {display:inline-block;padding:4px 9px;border-radius:99px;font-size:11px;font-weight:800;background:#edf1f7;color:#435268;white-space:nowrap}
    .status[data-status="MATCH"] {background:#e2f6ed;color:#087f5b}
    .status[data-status="DIFFERENT"], .status[data-status="MISSING_MAINLINE"], .status[data-status="MISSING_MIRROR"] {background:#fff1db;color:#965805}
    .status[data-status="ERROR"],.status[data-status="UNVERIFIED_CHECKSUM"] {background:#ffe4e4;color:#ae2727}
    .short {max-width:300px;overflow-wrap:anywhere}
    .section-title {display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap}
    .error {padding:16px;border:1px solid #f5c4c4;background:#fff0f0;border-radius:10px}
    .footer {text-align:center;font-size:12px;color:var(--muted);padding:12px}
    @media(max-width:900px){.grid-form{grid-template-columns:1fr 1fr}.cards{grid-template-columns:repeat(3,minmax(0,1fr))}}
    @media(max-width:600px){.wrap{padding:18px 12px 35px}.grid-form{grid-template-columns:1fr}.field-wide{grid-column:span 1}.cards{grid-template-columns:1fr 1fr}.top{align-items:start}h1{font-size:24px}}
    @media print{body{background:white}.wrap{max-width:none;padding:5px}.form-panel,.toolbar,button{display:none!important}.panel,.metric{box-shadow:none;break-inside:avoid}table{min-width:0;font-size:10px}}
  </style>
</head>
<body>
<main class="wrap">
  <header class="top">
    <div>
      <div class="eyebrow">Integration Server 10.15 / operations utility</div>
      <h1>PackageSync comparison dashboard</h1>
      <div class="muted">Compare MAINLINE against a specific MIRROR node using loaded namespace checksums.</div>
    </div>
    <span class="chip">READ ONLY · NO SYNC</span>
  </header>

  <section class="panel form-panel">
    <h2>Run a comparison</h2>
    <form method="POST" action="comparePackages.dsp" autocomplete="off">
      <input type="hidden" name="action" value="run">
      <div class="grid-form">
        <div>
          <label for="remoteAlias">Remote server alias (mirror) *</label>
          <input type="text" id="remoteAlias" name="remoteAlias" maxlength="100" required placeholder="e.g. PROD_MIRROR" value="%value remoteAlias%">
          <div class="note">Use a configured direct-node IS remote alias, not a load balancer.</div>
        </div>
        <div>
          <label for="includePrefix">Package prefix</label>
          <input type="text" id="includePrefix" name="includePrefix" maxlength="80" value="%value includePrefix null=NBK empty=NBK%">
          <div class="note">Default: NBK packages only</div>
        </div>
        <div>
          <label for="onlyDifferences">Report mode</label>
          <select name="onlyDifferences" id="onlyDifferences" data-selected="%value onlyDifferences%">
            <option value="true">Only differences</option>
            <option value="false">All packages (including matches)</option>
          </select>
        </div>
        <div class="field-wide">
          <label for="packagesText">Specific packages (optional)</label>
          <textarea name="packagesText" id="packagesText" placeholder="Leave blank to compare all packages with the prefix; or enter names separated by comma / new line">%value packagesText%</textarea>
        </div>
        <div>
          <label for="excludePackagesText">Exclude packages (optional)</label>
          <textarea name="excludePackagesText" id="excludePackagesText" placeholder="NBKLoggingPub">%value excludePackagesText%</textarea>
        </div>
      </div>
      <div class="actions">
        <button type="submit">Run read-only comparison</button>
        <span class="note">Comparison is performed only when you click Run. Nothing executes when you first open the page.</span>
      </div>
    </form>
  </section>

  %switch action%
  %case 'run'%
  %invoke nbkPackageSync.services:compareForDsp%
  <section id="report">
    <div class="section-title">
      <div>
        <h2>Latest comparison results</h2>
        <div class="note">Run at: <strong>%value runAt%</strong> · Mirror alias: <strong>%value remoteAlias%</strong></div>
      </div>
      <button class="secondary" type="button" onclick="window.print()">Print / Save PDF</button>
    </div>
    <br>
    <div class="cards">
      <div class="metric"><div class="label">Compared</div><div class="number">%value comparedPackages%</div></div>
      <div class="metric"><div class="label">Matching</div><div class="number">%value matchingPackages%</div></div>
      <div class="metric"><div class="label">Different</div><div class="number">%value differentPackages%</div></div>
      <div class="metric"><div class="label">Missing mainline</div><div class="number">%value missingMainlinePackages%</div></div>
      <div class="metric"><div class="label">Missing mirror</div><div class="number">%value missingMirrorPackages%</div></div>
      <div class="metric"><div class="label">Errors / unverified</div><div class="number">%value errorPackages%</div></div>
    </div>
    <div id="resultBanner" class="banner" data-complete="%value complete%" data-differences="%value hasDifferences%">
      <div>
        <strong id="resultHeadline">Comparison completed</strong>
        <div id="resultCaption" class="note">Summary is based on the Java service response. Errors must not be treated as a match.</div>
      </div>
    </div>
    <section class="panel">
      <div class="section-title">
        <h2>Package results</h2>
        <span class="note">Matching rows are omitted when "Only differences" is selected.</span>
      </div>
      <div class="toolbar">
        <div class="toolbar-left">
          <input id="filterText" type="search" placeholder="Find package / error ..." aria-label="Filter package rows">
          <select id="filterStatus" aria-label="Filter by comparison status">
            <option value="">All statuses</option>
            <option value="MATCH">Match</option><option value="DIFFERENT">Different</option>
            <option value="MISSING_MAINLINE">Missing mainline</option><option value="MISSING_MIRROR">Missing mirror</option><option value="ERROR">Error</option>
          </select>
        </div>
        <div class="toolbar-left">
          <span id="visibleRows" class="note"></span>
          <button type="button" class="secondary" onclick="exportTable('packagesTable','package-comparison.csv')">Export packages CSV</button>
        </div>
      </div>
      <div class="scroll">
        <table id="packagesTable">
          <thead><tr><th>Package</th><th>Status</th><th>Mainline assets</th><th>Mirror assets</th><th>Changed assets</th><th>Error / explanation</th></tr></thead>
          <tbody>
            %loop packagesReport%
            <tr data-status="%value status%">
              <td class="mono"><strong>%value package%</strong></td>
              <td><span class="status" data-status="%value status%">%value status%</span></td>
              <td>%value mainlineAssets%</td><td>%value mirrorAssets%</td><td>%value differentAssets%</td><td class="short">%value error%</td>
            </tr>
            %endloop%
          </tbody>
        </table>
      </div>
      <div class="note" style="margin-top:10px">If the table is empty and your report mode is "Only differences", there may be no reported differences. Verify the error count is zero.</div>
    </section>

    <section class="panel">
      <div class="section-title">
        <div><h2>Asset-level differences</h2><div class="note">One row per namespace asset missing or having a different checksum.</div></div>
        <button type="button" class="secondary" onclick="exportTable('assetsTable','asset-differences.csv')">Export assets CSV</button>
      </div>
      <br>
      <div class="scroll">
        <table id="assetsTable">
          <thead><tr><th>Package</th><th>Namespace asset</th><th>Status</th><th>Mainline checksum</th><th>Mirror checksum</th></tr></thead>
          <tbody>
            %loop assetsReport%
            <tr>
              <td class="mono">%value package%</td>
              <td class="mono">%value assetName%</td>
              <td><span class="status" data-status="%value status%">%value status%</span></td>
              <td class="mono">%value mainlineChecksum%</td><td class="mono">%value mirrorChecksum%</td>
            </tr>
            %endloop%
          </tbody>
        </table>
      </div>
    </section>
    <section class="panel">
      <h2>Scope &amp; confidence</h2>
      <p><strong>Comparison level:</strong> %value comparisonLevel%</p>
      <p><strong>Inventory source:</strong> %value inventorySource%</p>
      <p class="note"><strong>Important:</strong> This does NOT compare package config files, JARs, certificates, ACLs, adapter configuration or JVM settings. When running with explicit packages, a missing or unloaded package may be classified ERROR rather than MISSING. Never interpret ERROR as MATCH.</p>
    </section>
  </section>
  %onerror%
  <section class="panel">
    <div class="error" role="alert">
      <h2>Comparison failed</h2>
      <div><strong>Service:</strong> %value errorService%</div>
      <div><strong>Type:</strong> %value error%</div>
      <div><strong>Message:</strong> %value errorMessage%</div>
      <p class="note">Check your remote server alias, required ACLs, helper service on mirror, packages and connectivity. No synchronization was performed.</p>
    </div>
  </section>
  %endinvoke%
  %case%
  <section class="panel">
    <h2>Ready for your first comparison</h2>
    <p class="muted">Enter the mirror remote alias above, then click <strong>Run read-only comparison</strong>. The page will display summary counts, package status, exact differing assets and checksum values.</p>
  </section>
  %endswitch%
  <div class="footer">NBKPackageSync · Internal-use dashboard · Read-only namespace checksum comparison</div>
</main>
<script>
(function(){
  'use strict';
  var mode=document.getElementById('onlyDifferences');
  if (mode) {
    // Set the dropdown on a POST response without putting a DSP tag in JavaScript.
    var previous=mode.getAttribute('data-selected');
    if (previous==='false') mode.value='false';
  }
  var banner=document.getElementById('resultBanner');
  if (banner) {
    var complete=banner.getAttribute('data-complete')==='true';
    var diff=banner.getAttribute('data-differences')==='true';
    var title=document.getElementById('resultHeadline');
    var sub=document.getElementById('resultCaption');
    if (!complete) {banner.className+=' bad';title.textContent='Incomplete: errors or unverified packages';sub.textContent='Inspect the ERROR rows. Do not treat incomplete results as synchronized.';}
    else if (diff) {banner.className+=' warn';title.textContent='Differences found between MAINLINE and MIRROR';sub.textContent='Review missing packages and asset-level checksum differences below.';}
    else {banner.className+=' good';title.textContent='No differences reported in the checked scope';sub.textContent='This means only the compared namespace assets matched. Configurations and JARs are outside this check.';}
  }
  var textBox=document.getElementById('filterText'), statusBox=document.getElementById('filterStatus');
  function filter(){
    var rows=document.querySelectorAll('#packagesTable tbody tr');
    var term=(textBox.value||'').toLowerCase(), status=statusBox.value, visible=0;
    for(var i=0;i<rows.length;i++){
      var row=rows[i], ok=row.textContent.toLowerCase().indexOf(term)>=0 && (!status || row.getAttribute('data-status')===status);
      row.style.display=ok?'':'none';if(ok)visible++;
    }
    document.getElementById('visibleRows').textContent=visible+' visible / '+rows.length+' rows';
  }
  if(textBox && statusBox){textBox.addEventListener('input',filter);statusBox.addEventListener('change',filter);filter();}
  window.exportTable=function(id, filename){
    var table=document.getElementById(id);if(!table)return;
    var rows=table.querySelectorAll('tr'), csv=[];
    for(var i=0;i<rows.length;i++){
      if(rows[i].style.display==='none')continue;
      var cells=rows[i].querySelectorAll('th,td'), values=[];
      for(var j=0;j<cells.length;j++){
        var value=cells[j].textContent.trim().replace(/\r?\n/g,' ');
        // Spreadsheet formula injection guard for values starting with =, +, -, @.
        if (/^[=+\-@]/.test(value)) value="'"+value;
        values.push('"'+value.replace(/"/g,'""')+'"');
      }
      csv.push(values.join(','));
    }
    var blob=new Blob(['\ufeff'+csv.join('\r\n')],{type:'text/csv;charset=utf-8'});
    var url=URL.createObjectURL(blob), a=document.createElement('a');
    a.href=url;a.download=filename;document.body.appendChild(a);a.click();a.remove();
    setTimeout(function(){URL.revokeObjectURL(url);},1000);
  };
}());
</script>
</body>
</html>