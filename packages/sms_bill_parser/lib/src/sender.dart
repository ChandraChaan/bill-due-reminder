import 'models.dart';

/// Indian commercial SMS headers: two letters (operator and circle), a dash,
/// the 6-character sender ID and, since 2025, an optional category suffix
/// (`-S` service, `-T` transactional, `-G` government, `-P` promotional).
final RegExp _headerPattern = RegExp(
  r'^[A-Z]{2}-([A-Z0-9]{3,9})(?:-([STGP]))?$',
  caseSensitive: false,
);

/// Some phones drop the two-letter prefix and show only `HDFCBK`.
final RegExp _barePattern = RegExp(r'^[A-Z][A-Z0-9]{5,8}$');

/// The 6-character sender ID inside [sender] (`VM-HDFCBK-S` → `HDFCBK`), or
/// null when [sender] is not a business header that may carry a bill:
/// phone numbers (personal messages) and promotional `-P` headers.
///
/// This is the privacy gate: the app passes an SMS on to the parser only
/// when this returns non-null, so personal messages are never read further.
String? businessSenderId(String sender) {
  final trimmed = sender.trim();
  final match = _headerPattern.firstMatch(trimmed);
  if (match != null) {
    if (match.group(2)?.toUpperCase() == 'P') return null;
    return match.group(1)!.toUpperCase();
  }
  if (_barePattern.hasMatch(trimmed)) return trimmed;
  return null;
}

/// Whether [sender] is a bank/biller header whose messages may be parsed.
bool isBusinessSender(String sender) => businessSenderId(sender) != null;

final class _Known {
  const _Known(this.id, this.name, [this.kind]);
  final String id;
  final String name;
  final BillKind? kind;
}

// Sender IDs written in the style of the headers Indian banks, card issuers,
// utilities and telcos use. Unknown senders still work: the issuer then
// comes from the message text or the header itself.
const Map<String, _Known> _bySenderId = {
  'HDFCBK': _Known('hdfc', 'HDFC Bank'),
  'HDFCBN': _Known('hdfc', 'HDFC Bank'),
  'ICICIB': _Known('icici', 'ICICI Bank'),
  'ICICIO': _Known('icici', 'ICICI Bank'),
  'SBICRD': _Known('sbicard', 'SBI Card', BillKind.creditCard),
  'SBIINB': _Known('sbi', 'State Bank of India'),
  'SBIBNK': _Known('sbi', 'State Bank of India'),
  'AXISBK': _Known('axis', 'Axis Bank'),
  'KOTAKB': _Known('kotak', 'Kotak Mahindra Bank'),
  'IDFCFB': _Known('idfcfirst', 'IDFC FIRST Bank'),
  'INDUSB': _Known('indusind', 'IndusInd Bank'),
  'YESBNK': _Known('yes', 'Yes Bank'),
  'RBLBNK': _Known('rbl', 'RBL Bank'),
  'RBLCRD': _Known('rbl', 'RBL Bank', BillKind.creditCard),
  'AUBANK': _Known('au', 'AU Small Finance Bank'),
  'SCBANK': _Known('sc', 'Standard Chartered'),
  'AMEXIN': _Known('amex', 'American Express', BillKind.creditCard),
  'BOBCRD': _Known('bobcard', 'BOBCARD', BillKind.creditCard),
  'BOIIND': _Known('boi', 'Bank of India'),
  'PNBSMS': _Known('pnb', 'Punjab National Bank'),
  'CANBNK': _Known('canara', 'Canara Bank'),
  'UNIONB': _Known('union', 'Union Bank of India'),
  'FEDBNK': _Known('federal', 'Federal Bank'),
  'ONECRD': _Known('onecard', 'OneCard', BillKind.creditCard),
  'BAJFIN': _Known('bajaj', 'Bajaj Finance'),
  'BFLEMI': _Known('bajaj', 'Bajaj Finance', BillKind.loanEmi),
  'TATACP': _Known('tatacapital', 'Tata Capital'),
  'HDBFSL': _Known('hdbfs', 'HDB Financial Services', BillKind.loanEmi),
  'LICHFL': _Known('lichfl', 'LIC Housing Finance', BillKind.loanEmi),
  'MUTHUT': _Known('muthoot', 'Muthoot Finance', BillKind.loanEmi),
  'AIRTEL': _Known('airtel', 'Airtel'),
  'AIRXTM': _Known('airtel', 'Airtel', BillKind.broadband),
  'JIOINF': _Known('jio', 'Jio'),
  'JIOFBR': _Known('jio', 'Jio', BillKind.broadband),
  'VICARE': _Known('vi', 'Vi'),
  'VIINFO': _Known('vi', 'Vi'),
  'BSNLIN': _Known('bsnl', 'BSNL'),
  'ACTFBR': _Known('act', 'ACT Fibernet', BillKind.broadband),
  'HTHWAY': _Known('hathway', 'Hathway', BillKind.broadband),
  'EXCITL': _Known('excitel', 'Excitel', BillKind.broadband),
  'BESCOM': _Known('bescom', 'BESCOM', BillKind.electricity),
  'MSEDCL': _Known('msedcl', 'MSEDCL (Mahavitaran)', BillKind.electricity),
  'TPDDLM': _Known('tpddl', 'Tata Power-DDL', BillKind.electricity),
  'TATAPW': _Known('tatapower', 'Tata Power', BillKind.electricity),
  'BSESRP': _Known('bsesrajdhani', 'BSES Rajdhani', BillKind.electricity),
  'BSESYP': _Known('bsesyamuna', 'BSES Yamuna', BillKind.electricity),
  'ADANIE': _Known('adanielec', 'Adani Electricity', BillKind.electricity),
  'TNEBLT': _Known('tneb', 'TNPDCL', BillKind.electricity),
  'TSSPDC': _Known('tgspdcl', 'TGSPDCL', BillKind.electricity),
  'APSPDC': _Known('apspdcl', 'APSPDCL', BillKind.electricity),
  'KSEBLT': _Known('kseb', 'KSEB', BillKind.electricity),
  'CESCLT': _Known('cesc', 'CESC', BillKind.electricity),
  'UPPCLM': _Known('uppcl', 'UPPCL', BillKind.electricity),
  'DJBWTR': _Known('djb', 'Delhi Jal Board', BillKind.water),
  'BWSSBB': _Known('bwssb', 'BWSSB', BillKind.water),
  'HMWSSB': _Known('hmwssb', 'HMWSSB', BillKind.water),
  'IGLGAS': _Known('igl', 'Indraprastha Gas', BillKind.gas),
  'MGLGAS': _Known('mgl', 'Mahanagar Gas', BillKind.gas),
  'GGLGAS': _Known('gujaratgas', 'Gujarat Gas', BillKind.gas),
  'ATGLGS': _Known('adanigas', 'Adani Total Gas', BillKind.gas),
  'LICIND': _Known('lic', 'LIC', BillKind.insurance),
  'HDFCLI': _Known('hdfclife', 'HDFC Life', BillKind.insurance),
  'IPRULI': _Known('iciciprulife', 'ICICI Prudential Life', BillKind.insurance),
  'SBILIF': _Known('sbilife', 'SBI Life', BillKind.insurance),
  'STARHI': _Known('starhealth', 'Star Health', BillKind.insurance),
  'NIVABU': _Known('nivabupa', 'Niva Bupa', BillKind.insurance),
  'TATAAI': _Known('tataaia', 'Tata AIA', BillKind.insurance),
};

// Issuer names found in the text, for senders not in the table above.
final List<(RegExp, Issuer)> _byText = [
  (
    RegExp(r'\bhdfc bank\b', caseSensitive: false),
    const Issuer('hdfc', 'HDFC Bank'),
  ),
  (
    RegExp(r'\bicici bank\b', caseSensitive: false),
    const Issuer('icici', 'ICICI Bank'),
  ),
  (
    RegExp(r'\bsbi ?card\b', caseSensitive: false),
    const Issuer('sbicard', 'SBI Card'),
  ),
  (
    RegExp(r'\baxis bank\b', caseSensitive: false),
    const Issuer('axis', 'Axis Bank'),
  ),
  (
    RegExp(r'\bkotak\b', caseSensitive: false),
    const Issuer('kotak', 'Kotak Mahindra Bank'),
  ),
  (
    RegExp(r'\bairtel\b', caseSensitive: false),
    const Issuer('airtel', 'Airtel'),
  ),
  (RegExp(r'\bjio\b', caseSensitive: false), const Issuer('jio', 'Jio')),
  (RegExp(r'\bbsnl\b', caseSensitive: false), const Issuer('bsnl', 'BSNL')),
  (RegExp(r'\blic\b', caseSensitive: false), const Issuer('lic', 'LIC')),
];

/// What the sender header says about who sent the message.
final class SenderInfo {
  const SenderInfo(this.issuer, this.kindHint);
  final Issuer issuer;
  final BillKind? kindHint;
}

/// Resolves the issuer from the sender ID, then from the text, and finally
/// falls back to the sender ID itself (`XYZBIL` → issuer `xyzbil`).
SenderInfo resolveSender(String senderId, String body) {
  final known = _bySenderId[senderId];
  if (known != null) {
    return SenderInfo(Issuer(known.id, known.name), known.kind);
  }
  for (final (pattern, issuer) in _byText) {
    if (pattern.hasMatch(body)) return SenderInfo(issuer, null);
  }
  return SenderInfo(Issuer(senderId.toLowerCase(), senderId), null);
}
