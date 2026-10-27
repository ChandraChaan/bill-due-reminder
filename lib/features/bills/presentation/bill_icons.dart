import 'package:flutter/material.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

IconData billIcon(BillKind kind) => switch (kind) {
  BillKind.creditCard => Icons.credit_card,
  BillKind.loanEmi => Icons.account_balance,
  BillKind.electricity => Icons.bolt,
  BillKind.water => Icons.water_drop_outlined,
  BillKind.gas => Icons.local_fire_department_outlined,
  BillKind.mobilePostpaid => Icons.smartphone,
  BillKind.broadband => Icons.wifi,
  BillKind.prepaidRecharge => Icons.sim_card_outlined,
  BillKind.insurance => Icons.health_and_safety_outlined,
  BillKind.other => Icons.receipt_long_outlined,
};
