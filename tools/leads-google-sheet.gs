/**
 * NewVis "Request a callback" receiver: saves each lead as a row in this Google Sheet
 * and emails the team. This replaces POST /api/leads when the site is hosted on Netlify.
 *
 * SETUP (once, about 5 minutes; see README.md "Leads on Netlify"):
 *   1. In the Gensolve Google account, create a Google Sheet called "NewVis leads".
 *   2. Extensions > Apps Script. Delete what's there, paste this whole file, click Save.
 *   3. Deploy > New deployment > type "Web app":
 *        Execute as:      Me
 *        Who has access:  Anyone
 *      Click Deploy, allow the permissions, and copy the Web app URL (ends in /exec).
 *   4. Put that URL in LEADS_URL in landing.html and push.
 *
 * After editing this script later: Deploy > Manage deployments > edit (pencil) >
 * Version: "New version" > Deploy. The URL stays the same.
 */

// Who gets an email for each new lead. Empty = the Google account that owns this script.
var NOTIFY_TO = '';

// Spam limits (no visitor IP is available here, so limits are per email address and site-wide).
var PER_EMAIL_PER_HOUR = 3;
var SITE_WIDE_PER_HOUR = 60;

var HEADERS = ['Received (IST)', 'Name', 'Phone', 'Email', 'Organisation', 'Use case', 'Message', 'Page', 'Browser'];
var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
var PHONE_RE = /^[0-9+()\-.\s]{7,30}$/;

function doPost(e) {
  try {
    var d = JSON.parse((e && e.postData && e.postData.contents) || '{}');
    if (String(d.website || '').trim()) return reply_({ ok: true });   // honeypot: pretend success, store nothing

    var lead = {
      name: clean_(d.name, 120), phone: clean_(d.phone, 30), email: clean_(d.email, 160),
      org: clean_(d.org, 160), use_case: clean_(d.use_case, 120), message: clean_(d.message, 1000),
      page: clean_(d.page, 200), browser: clean_(d.ua, 300)
    };
    if (!lead.name || !lead.email || !lead.phone || !lead.use_case)
      return reply_({ ok: false, detail: 'Please fill in name, phone, email and your use case.' });
    if (!EMAIL_RE.test(lead.email)) return reply_({ ok: false, detail: 'Please provide a valid email address.' });
    if (!PHONE_RE.test(lead.phone)) return reply_({ ok: false, detail: 'Please provide a valid phone number.' });

    var lock = LockService.getScriptLock();
    lock.waitLock(10000);
    try {
      if (overLimit_('site', SITE_WIDE_PER_HOUR) || overLimit_('email:' + lead.email.toLowerCase(), PER_EMAIL_PER_HOUR))
        return reply_({ ok: false, detail: 'Too many requests. Please try again later, or email us directly.' });

      var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
      if (sheet.getLastRow() === 0) { sheet.appendRow(HEADERS); sheet.setFrozenRows(1); sheet.getRange(1, 1, 1, HEADERS.length).setFontWeight('bold'); }
      var when = Utilities.formatDate(new Date(), 'Asia/Kolkata', 'yyyy-MM-dd HH:mm');
      // a leading apostrophe stops Sheets treating input like "=..." or "+91..." as a formula/number
      sheet.appendRow([when].concat([lead.name, lead.phone, lead.email, lead.org, lead.use_case, lead.message, lead.page, lead.browser].map(text_)));
    } finally {
      lock.releaseLock();
    }

    try { notify_(lead); } catch (err) { console.error('notify failed: ' + err); }   // the lead is saved; never fail the visitor
    return reply_({ ok: true });
  } catch (err) {
    console.error(err);
    return reply_({ ok: false, detail: 'Something went wrong. Please try again.' });
  }
}

// Opening the /exec URL in a browser shows this, which is handy to confirm the deployment works.
function doGet() { return reply_({ ok: true, service: 'NewVis leads' }); }

function notify_(lead) {
  var to = NOTIFY_TO || Session.getEffectiveUser().getEmail();
  if (!to) return;
  var body = ['Name: ' + lead.name, 'Phone: ' + lead.phone, 'Email: ' + lead.email, 'Organisation: ' + (lead.org || '-'),
              'Use case: ' + lead.use_case, '', 'Message:', lead.message || '-', '', 'All leads: ' + SpreadsheetApp.getActiveSpreadsheet().getUrl()].join('\n');
  MailApp.sendEmail({ to: to, replyTo: lead.email, subject: 'New NewVis callback request: ' + lead.name + ' (' + lead.use_case + ')', body: body });
}

function overLimit_(key, max) {
  var cache = CacheService.getScriptCache(), k = 'n:' + key, n = Number(cache.get(k) || 0);
  if (n >= max) return true;
  cache.put(k, String(n + 1), 3600);
  return false;
}

function clean_(v, max) { return String(v == null ? '' : v).replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g, '').trim().slice(0, max); }
function text_(v) { return v && /^[=+\-@]/.test(v) ? "'" + v : v; }
function reply_(obj) { return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON); }
